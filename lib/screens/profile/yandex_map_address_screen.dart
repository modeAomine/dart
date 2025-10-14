import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../services/yandex_geocoder_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';

class YandexMapAddressScreen extends StatefulWidget {
  final Function(double, double, String) onAddressSelected;

  const YandexMapAddressScreen({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  _YandexMapAddressScreenState createState() => _YandexMapAddressScreenState();
}

class _YandexMapAddressScreenState extends State<YandexMapAddressScreen> {
  late YandexMapController? mapController;
  final List<MapObject> mapObjects = [];
  Point? selectedPoint;
  String? selectedAddress;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Выберите адрес на карте'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) async {
                    mapController = controller;
                    await _moveToInitialPosition();
                  },
                  mapObjects: mapObjects,
                  onMapTap: (Point point) => _onMapTapped(point),
                ),
                Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: selectedPoint != null ? AppColors.primary : AppColors.secondary,
                  ),
                ),
                if (selectedPoint != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _buildSelectedAddressCard(),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToInitialPosition() async {
    await mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: 55.7558, longitude: 37.6173),
          zoom: 10,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Введите адрес...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
              onSubmitted: _searchAddress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выбранный адрес:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
            ),
            SizedBox(height: 4),
            Text(
              selectedAddress ?? 'Адрес не определен',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      selectedPoint = null;
                      selectedAddress = null;
                      _clearMapObjects();
                    }),
                    child: Text('Отмена'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: _saveAddress,
                    child: Text('Выбрать'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _searchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final results = await YandexGeocoderService.searchAddress(query);
      if (results.isNotEmpty) {
        final firstResult = results.first;
        final point = Point(
          latitude: firstResult['latitude'],
          longitude: firstResult['longitude'],
        );

        setState(() {
          selectedPoint = point;
          selectedAddress = firstResult['full_address'];
          _updateMapMarker(point);
        });

        await mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: point,
              zoom: 16,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Адрес не найден')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска адреса: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMapTapped(Point point) async {
    setState(() {
      isLoading = true;
    });

    try {
      final address = await YandexGeocoderService.reverseGeocode(
        point.latitude,
        point.longitude,
      );

      setState(() {
        selectedPoint = point;
        selectedAddress = address?['address'] ?? '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        _updateMapMarker(point);
      });
    } catch (e) {
      setState(() {
        selectedPoint = point;
        selectedAddress = '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        _updateMapMarker(point);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateMapMarker(Point point) {
    _clearMapObjects();
    const assetName = 'assets/location_pin.png';
    setState(() {
      mapObjects.add(PlacemarkMapObject(
        mapId: MapObjectId('selected_location'),
        point: point,
        opacity: 1,
        isDraggable: false,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage(
            assetName,
          ),
          scale: 1.0,
        )),
      ));
    });
  }

  void _clearMapObjects() {
    setState(() {
      mapObjects.clear();
    });
  }

  void _moveToCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final point = Point(latitude: 55.7558, longitude: 37.6173);

      final address = await YandexGeocoderService.reverseGeocode(
        point.latitude,
        point.longitude,
      );

      setState(() {
        selectedPoint = point;
        selectedAddress = address?['address'] ?? 'Москва, Красная площадь';
        _updateMapMarker(point);
      });

      await mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: point,
            zoom: 16,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка перемещения к местоположению: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveAddress() {
    if (selectedPoint != null && selectedAddress != null) {
      widget.onAddressSelected(
        selectedPoint!.latitude,
        selectedPoint!.longitude,
        selectedAddress!,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите адрес на карте')),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}