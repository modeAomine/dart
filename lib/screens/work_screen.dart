import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_removal_app/models/employee_application.dart';
import 'package:trash_removal_app/models/job_position.dart';
import 'package:trash_removal_app/services/employee_service.dart';
import 'package:trash_removal_app/theme/colors.dart';
import 'package:trash_removal_app/theme/text_styles.dart';
import 'package:trash_removal_app/theme/button_styles.dart';
import 'package:trash_removal_app/widgets/base_scaffold.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:trash_removal_app/utils/input_masks.dart';
import 'package:trash_removal_app/theme/input_styles.dart';
import 'package:trash_removal_app/models/credit_card_brand.dart';


class WorkScreen extends StatelessWidget {
  const WorkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text('Работать'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            SizedBox(height: 20),
            _buildInfoCard(),
            SizedBox(height: 20),
            _buildRequirementsCard(),
            SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.work, size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Присоединяйтесь к команде!',
              style: AppTextStyles.headerMedium.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Станьте частью нашей команды и помогайте делать город чище',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Вакансии', style: AppTextStyles.headerSmall),
            SizedBox(height: 12),
            Text(
              'Мы предлагаем стабильную работу с конкурентной заработной платой и социальным пакетом.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 16),
            _buildWorkItem('Водитель мусоровоза', 'от 50 000 ₽/мес'),
            _buildWorkItem('Рабочий по вывозу ТКО', 'от 35 000 ₽/мес'),
            _buildWorkItem('Диспетчер', 'от 40 000 ₽/мес'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItem(String position, String salary) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(position, style: AppTextStyles.bodyMedium),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(salary, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Требования', style: AppTextStyles.headerSmall),
            SizedBox(height: 12),
            _buildRequirementItem('Гражданство РФ'),
            _buildRequirementItem('Медкнижка'),
            _buildRequirementItem('Права категории C (для водителей)'),
            _buildRequirementItem('Ответственность'),
            _buildRequirementItem('Опыт работы приветствуется'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppButtonStyles.primaryButton,
            onPressed: () => _startApplication(context),
            child: Text('Оставить заявку'),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppButtonStyles.secondaryButton,
            onPressed: () => _showJobDetails(context),
            child: Text('Узнать подробности'),
          ),
        ),
      ],
    );
  }

  void _startApplication(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ApplicationWizard(),
    );
  }

  void _showJobDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Подробности о работе', style: AppTextStyles.headerSmall),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: AppColors.outline),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Условия работы',
                      '- Официальное трудоустройство\n'
                          '- График 5/2, сменный график\n'
                          '- Полный рабочий день\n'
                          '- Возможность сверхурочных',
                    ),
                    SizedBox(height: 16),
                    _buildDetailSection(
                      'Заработная плата',
                      '- Водитель: от 50 000 ₽ + премии\n'
                          '- Рабочий: от 35 000 ₽ + премии\n'
                          '- Диспетчер: от 40 000 ₽ + премии\n'
                          '- Ежеквартальные бонусы',
                    ),
                    SizedBox(height: 16),
                    _buildDetailSection(
                      'Социальный пакет',
                      '- Медицинская страховка\n'
                          '- Оплачиваемый отпуск\n'
                          '- Больничные\n'
                          '- Обучение за счет компании\n'
                          '- Карьерный рост',
                    ),
                    SizedBox(height: 16),
                    _buildDetailSection(
                      'Процесс отбора',
                      '1. Подача заявки\n'
                          '2. Собеседование\n'
                          '3. Проверка документов\n'
                          '4. Медосмотр\n'
                          '5. Подписание договора',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () => Navigator.pop(context),
                child: Text('Понятно'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(content, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class ApplicationWizard extends StatefulWidget {
  @override
  _ApplicationWizardState createState() => _ApplicationWizardState();
}

class _ApplicationWizardState extends State<ApplicationWizard> {
  int _currentStep = 0;
  JobPosition? _selectedPosition;
  CreditCardBrand? _detectedBrand;
  final CreditCardValidator _validator = CreditCardValidator();

  final TextEditingController _passportSeriesController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _passportIssueDateController = TextEditingController();
  final TextEditingController _passportIssuedByController = TextEditingController();
  final TextEditingController _registrationAddressController = TextEditingController();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankCardController = TextEditingController();

  final TextEditingController _workExperienceController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Заявка на работу', style: AppTextStyles.headerSmall),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildStepper(),
          SizedBox(height: 20),
          Expanded(child: _buildStepContent()),
          SizedBox(height: 20),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStep(0, 'Должность'),
        _buildStepDivider(),
        _buildStep(1, 'Паспорт'),
        _buildStepDivider(),
        _buildStep(2, 'Банк'),
        _buildStepDivider(),
        _buildStep(3, 'Опыт'),
        _buildStepDivider(),
        _buildStep(4, 'Подтверждение'),
      ],
    );
  }

  Widget _buildStep(int step, String title) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _currentStep >= step ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: _currentStep >= step ? Colors.white : AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: _currentStep >= step ? AppColors.primary : AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Divider(color: AppColors.outline, thickness: 2),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPositionStep();
      case 1:
        return _buildPassportStep();
      case 2:
        return _buildBankStep();
      case 3:
        return _buildExperienceStep();
      case 4:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildPositionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Выберите должность', style: AppTextStyles.headerSmall),
        SizedBox(height: 16),
        ...JobPosition.values.map((position) => _buildPositionCard(position)).toList(),
      ],
    );
  }

  Widget _buildPositionCard(JobPosition position) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: _selectedPosition == position ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPosition == position ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.work, color: AppColors.primary),
        title: Text(position.title, style: AppTextStyles.bodyLarge),
        subtitle: Text(position.description, style: AppTextStyles.bodySmall),
        trailing: _selectedPosition == position ? Icon(Icons.check_circle, color: AppColors.primary) : null,
        onTap: () => setState(() => _selectedPosition = position),
      ),
    );
  }

  Widget _buildPassportStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Паспортные данные', style: AppTextStyles.headerSmall),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _passportSeriesController,
                  inputFormatters: [InputMasks.passportSeries],
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: AppInputStyles.textField(
                    labelText: 'Серия',
                    hintText: '1234',
                    prefixIcon: Icon(Icons.badge, color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _passportNumberController,
                  inputFormatters: [InputMasks.passportNumber],
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: AppInputStyles.textField(
                    labelText: 'Номер',
                    hintText: '123456',
                    prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _passportIssueDateController,
            inputFormatters: [InputMasks.dateMask],
            keyboardType: TextInputType.datetime,
            maxLength: 10,
            decoration: AppInputStyles.textField(
              labelText: 'Дата выдачи',
              hintText: 'ДД.ММ.ГГГГ',
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _passportIssuedByController,
            decoration: AppInputStyles.textField(
              labelText: 'Кем выдан',
              hintText: 'ОУФМС России по г. Москве',
              prefixIcon: Icon(Icons.account_balance, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _registrationAddressController,
            maxLines: 2,
            decoration: AppInputStyles.textField(
              labelText: 'Адрес регистрации',
              hintText: 'г. Москва, ул. Примерная, д. 1',
              prefixIcon: Icon(Icons.home, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Банковские реквизиты', style: AppTextStyles.headerSmall),
          SizedBox(height: 16),

          TextFormField(
            controller: _bankCardController,
            inputFormatters: [InputMasks.bankCardNumber],
            keyboardType: TextInputType.number,
            maxLength: 19,
            onChanged: (value) {
              final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
              if (cleanNumber.length >= 6) {
                final validation = _validator.validateCCNum(cleanNumber);
                setState(() {
                  _detectedBrand = validation.ccType as CreditCardBrand?;
                  if (_detectedBrand != null) {
                    _bankNameController.text = _getBankNameFromBrand(_detectedBrand!);
                  }
                });
              } else {
                setState(() {
                  _detectedBrand = null;
                });
              }
            },
            decoration: AppInputStyles.textField(
              labelText: 'Номер карты',
              hintText: '0000 0000 0000 0000',
              prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
              suffixIcon: _detectedBrand != null
                  ? Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(4),
                child: _buildBrandIcon(_detectedBrand!),
              )
                  : null,
            ),
          ),
          if (_detectedBrand != null) ...[
            SizedBox(height: 8),
            Text(
              'Платежная система: ${_getBrandName(_detectedBrand!)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
          SizedBox(height: 16),

          TextFormField(
            controller: _bankNameController,
            decoration: AppInputStyles.textField(
              labelText: 'Название банка',
              hintText: _detectedBrand != null ? _getBankNameFromBrand(_detectedBrand!) : 'Сбербанк, Тинькофф и т.д.',
              prefixIcon: Icon(Icons.account_balance, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _bankAccountController,
            inputFormatters: [InputMasks.bankAccount],
            keyboardType: TextInputType.number,
            maxLength: 20,
            decoration: AppInputStyles.textField(
              labelText: 'Номер счета',
              hintText: '20 цифр',
              prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(CreditCardBrand brand) {
    switch (brand) {
      case CreditCardBrand.visa:
        return Icon(Icons.credit_card, color: Colors.blue, size: 24);
      case CreditCardBrand.mastercard:
        return Icon(Icons.credit_card, color: Colors.red, size: 24);
      case CreditCardBrand.mir:
        return Icon(Icons.credit_card, color: Colors.green, size: 24);
      case CreditCardBrand.americanExpress:
        return Icon(Icons.credit_card, color: Colors.blueGrey, size: 24);
      case CreditCardBrand.unionpay:
        return Icon(Icons.credit_card, color: Colors.orange, size: 24);
      default:
        return Icon(Icons.credit_card, color: AppColors.primary, size: 24);
    }
  }

  String _getBrandName(CreditCardBrand brand) {
    switch (brand) {
      case CreditCardBrand.visa:
        return 'Visa';
      case CreditCardBrand.mastercard:
        return 'MasterCard';
      case CreditCardBrand.mir:
        return 'Мир';
      case CreditCardBrand.americanExpress:
        return 'American Express';
      case CreditCardBrand.unionpay:
        return 'UnionPay';
      default:
        return 'Неизвестно';
    }
  }

  String _getBankNameFromBrand(CreditCardBrand brand) {
    switch (brand) {
      case CreditCardBrand.visa:
      case CreditCardBrand.mastercard:
        return 'Сбербанк';
      case CreditCardBrand.mir:
        return 'Банк с поддержкой Мир';
      case CreditCardBrand.americanExpress:
        return 'Банк с поддержкой AmEx';
      case CreditCardBrand.unionpay:
        return 'Банк с поддержкой UnionPay';
      default:
        return 'Банк РФ';
    }
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Опыт работы', style: AppTextStyles.headerSmall),
          SizedBox(height: 16),

          TextFormField(
            controller: _workExperienceController,
            maxLines: 5,
            decoration: AppInputStyles.textField(
              labelText: 'Опишите ваш опыт работы',
              hintText: 'Работал водителем мусоровоза 3 года в компании "Чистый город"...',
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _additionalInfoController,
            maxLines: 3,
            decoration: AppInputStyles.textField(
              labelText: 'Дополнительная информация',
              hintText: 'Наличие прав, категории, рекомендации...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Подтверждение заявки', style: AppTextStyles.headerSmall),
          SizedBox(height: 16),
          Text('Проверьте правильность введенных данных перед отправкой', style: AppTextStyles.bodyMedium),
          SizedBox(height: 20),

          if (_selectedPosition != null) _buildReviewItem('Должность', _selectedPosition!.title),
          if (_passportSeriesController.text.isNotEmpty && _passportNumberController.text.isNotEmpty)
            _buildReviewItem('Паспорт', '${_passportSeriesController.text} ${_passportNumberController.text}'),
          if (_passportIssueDateController.text.isNotEmpty)
            _buildReviewItem('Дата выдачи', _passportIssueDateController.text),
          if (_passportIssuedByController.text.isNotEmpty)
            _buildReviewItem('Кем выдан', _passportIssuedByController.text),
          if (_registrationAddressController.text.isNotEmpty)
            _buildReviewItem('Адрес регистрации', _registrationAddressController.text),
          if (_bankNameController.text.isNotEmpty)
            _buildReviewItem('Банк', _bankNameController.text),
          if (_bankCardController.text.isNotEmpty)
            _buildReviewItem('Номер карты', _bankCardController.text),
          if (_bankAccountController.text.isNotEmpty)
            _buildReviewItem('Номер счета', _bankAccountController.text),
          if (_workExperienceController.text.isNotEmpty)
            _buildReviewItem('Опыт работы', _workExperienceController.text),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium),
          Divider(color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ElevatedButton(
              style: AppButtonStyles.secondaryButton,
              onPressed: () => setState(() => _currentStep--),
              child: Text('Назад'),
            ),
          ),
        if (_currentStep > 0) SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: AppButtonStyles.primaryButton,
            onPressed: _currentStep < 4 ? () => setState(() => _currentStep++) : _submitApplication,
            child: Text(_currentStep < 4 ? 'Далее' : 'Отправить'),
          ),
        ),
      ],
    );
  }

  void _submitApplication() {
    print('Отправка заявки на должность: $_selectedPosition');
    print('Паспорт: ${_passportSeriesController.text} ${_passportNumberController.text}');
    print('Банк: ${_bankNameController.text}');

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заявка успешно отправлена!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }
}