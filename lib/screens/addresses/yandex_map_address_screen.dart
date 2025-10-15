import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../services/yandex_geocoder_service.dart';
import '../../services/network_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/network_status_banner.dart';

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
  double currentZoom = 10.0;
  final Location _location = Location();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkService = Provider.of<NetworkService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Выберите адрес'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: networkService.isConnected ? _moveToCurrentLocation : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Баннер сети
          if (!networkService.isConnected) NetworkStatusBanner(),

          _buildSearchBar(networkService.isConnected),
          _buildZoomSlider(),
          Expanded(
            child: Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) async {
                    mapController = controller;
                    await _moveToInitialPosition();
                  },
                  mapObjects: mapObjects,
                  onMapTap: networkService.isConnected ? _onMapTapped : null,
                  onCameraPositionChanged: (cameraPosition, reason, finished) {
                    if (finished) {
                      setState(() {
                        currentZoom = cameraPosition.zoom;
                      });
                    }
                  },
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
                // Сообщение при отсутствии сети
                if (!networkService.isConnected)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wifi_off, size: 50, color: AppColors.secondary),
                                SizedBox(height: 16),
                                Text(
                                  'Карта недоступна',
                                  style: AppTextStyles.headerSmall,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Для работы карты требуется подключение к интернету',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: networkService.isConnected ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildSearchBar(bool isConnected) {
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
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        enabled: isConnected,
        decoration: InputDecoration(
          hintText: isConnected ? 'Введите адрес...' : 'Поиск недоступен',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.search,
              color: isConnected ? AppColors.primary : AppColors.secondary),
          suffixIcon: _searchController.text.isNotEmpty && isConnected
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          )
              : null,
        ),
        onSubmitted: isConnected ? _searchAddress : null,
      ),
    );
  }

  Widget _buildZoomSlider() {
    final networkService = Provider.of<NetworkService>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.zoom_out,
              color: networkService.isConnected ? AppColors.primary : AppColors.secondary),
          Expanded(
            child: Slider(
              value: currentZoom,
              min: 2.0,
              max: 20.0,
              divisions: 18,
              onChanged: networkService.isConnected ? (value) {
                setState(() {
                  currentZoom = value;
                });
                _updateZoom(value);
              } : null,
            ),
          ),
          Icon(Icons.zoom_in,
              color: networkService.isConnected ? AppColors.primary : AppColors.secondary),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _confirmAddress,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: Icon(Icons.check),
      label: Text('Готово'),
    );
  }

  void _searchAddress(String query) async {
    if (query.isEmpty) return;

    final networkService = Provider.of<NetworkService>(context, listen: false);
    if (!networkService.isConnected) return;

    setState(() {
      isLoading = true;
    });

    try {
      final results = await YandexGeocoderService.searchAddress(query);
      if (results.isNotEmpty) {
        final firstResult = results.first;
        await _moveToPointWithAddress(
          Point(
            latitude: firstResult['latitude'],
            longitude: firstResult['longitude'],
          ),
          firstResult['full_address'],
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

  Future<void> _moveToPointWithAddress(Point point, String address) async {
    setState(() {
      selectedPoint = point;
      selectedAddress = address;
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
  }

  void _updateZoom(double zoom) async {
    final currentPosition = await mapController!.getCameraPosition();
    await mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPosition.target,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _moveToInitialPosition() async {
    await mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: 55.7558, longitude: 37.6173),
          zoom: currentZoom,
        ),
      ),
    );
  }

  void _onMapTapped(Point point) async {
    final networkService = Provider.of<NetworkService>(context, listen: false);
    if (!networkService.isConnected) return;

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
    setState(() {
      mapObjects.add(PlacemarkMapObject(
        mapId: MapObjectId('selected_location'),
        point: point,
        opacity: 1,
        isDraggable: false,
      ));
    });
  }

  void _clearMapObjects() {
    setState(() {
      mapObjects.removeWhere((obj) => obj.mapId.value == 'selected_location');
    });
  }

  void _moveToCurrentLocation() async {
    final networkService = Provider.of<NetworkService>(context, listen: false);
    if (!networkService.isConnected) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Сервис геолокации отключен')),
          );
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Разрешение на геолокацию не предоставлено')),
          );
          return;
        }
      }

      final locationData = await _location.getLocation();
      final point = Point(
        latitude: locationData.latitude ?? 55.7558,
        longitude: locationData.longitude ?? 37.6173,
      );

      final address = await YandexGeocoderService.reverseGeocode(
        point.latitude,
        point.longitude,
      );

      setState(() {
        selectedPoint = point;
        selectedAddress = address?['address'] ?? 'Текущее местоположение';
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
        SnackBar(content: Text('Ошибка получения местоположения: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmAddress() {
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}