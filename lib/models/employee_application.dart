import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  draft('Черновик'),
  submitted('Отправлена'),
  underReview('На рассмотрении'),
  approved('Одобрена'),
  rejected('Отклонена'),
  hired('Принят');

  const ApplicationStatus(this.displayName);
  final String displayName;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
          (status) => status.name == value,
      orElse: () => ApplicationStatus.draft,
    );
  }
}

class EmployeeApplication extends Equatable {
  final String? id;
  final String userId;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? passportSeries;
  final String? passportNumber;
  final DateTime? passportIssueDate;
  final String? passportIssuedBy;
  final String? registrationAddress;

  final String? bankName;
  final String? bankAccount;
  final String? bankCardNumber;

  final String? desiredPosition;
  final String? workExperience;
  final String? additionalInfo;

  const EmployeeApplication({
    this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.updatedAt,

    this.passportSeries,
    this.passportNumber,
    this.passportIssueDate,
    this.passportIssuedBy,
    this.registrationAddress,

    this.bankName,
    this.bankAccount,
    this.bankCardNumber,

    this.desiredPosition,
    this.workExperience,
    this.additionalInfo,
  });

  factory EmployeeApplication.fromJson(Map<String, dynamic> json) {
    return EmployeeApplication(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      status: ApplicationStatus.fromString(json['status']?.toString() ?? 'draft'),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']?.toString() ?? '') : null,

      passportSeries: json['passport_series']?.toString(),
      passportNumber: json['passport_number']?.toString(),
      passportIssueDate: json['passport_issue_date'] != null ? DateTime.parse(json['passport_issue_date']?.toString() ?? '') : null,
      passportIssuedBy: json['passport_issued_by']?.toString(),
      registrationAddress: json['registration_address']?.toString(),

      bankName: json['bank_name']?.toString(),
      bankAccount: json['bank_account']?.toString(),
      bankCardNumber: json['bank_card_number']?.toString(),

      desiredPosition: json['desired_position']?.toString(),
      workExperience: json['work_experience']?.toString(),
      additionalInfo: json['additional_info']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),

      if (passportSeries != null) 'passport_series': passportSeries,
      if (passportNumber != null) 'passport_number': passportNumber,
      if (passportIssueDate != null) 'passport_issue_date': passportIssueDate!.toIso8601String(),
      if (passportIssuedBy != null) 'passport_issued_by': passportIssuedBy,
      if (registrationAddress != null) 'registration_address': registrationAddress,

      if (bankName != null) 'bank_name': bankName,
      if (bankAccount != null) 'bank_account': bankAccount,
      if (bankCardNumber != null) 'bank_card_number': bankCardNumber,

      if (desiredPosition != null) 'desired_position': desiredPosition,
      if (workExperience != null) 'work_experience': workExperience,
      if (additionalInfo != null) 'additional_info': additionalInfo,
    };
  }

  @override
  List<Object?> get props => [
    id, userId, status, createdAt, updatedAt,
    passportSeries, passportNumber, passportIssueDate, passportIssuedBy, registrationAddress,
    bankName, bankAccount, bankCardNumber,
    desiredPosition, workExperience, additionalInfo,
  ];

  EmployeeApplication copyWith({
    String? id,
    String? userId,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? passportSeries,
    String? passportNumber,
    DateTime? passportIssueDate,
    String? passportIssuedBy,
    String? registrationAddress,
    String? bankName,
    String? bankAccount,
    String? bankCardNumber,
    String? desiredPosition,
    String? workExperience,
    String? additionalInfo,
  }) {
    return EmployeeApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passportSeries: passportSeries ?? this.passportSeries,
      passportNumber: passportNumber ?? this.passportNumber,
      passportIssueDate: passportIssueDate ?? this.passportIssueDate,
      passportIssuedBy: passportIssuedBy ?? this.passportIssuedBy,
      registrationAddress: registrationAddress ?? this.registrationAddress,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      bankCardNumber: bankCardNumber ?? this.bankCardNumber,
      desiredPosition: desiredPosition ?? this.desiredPosition,
      workExperience: workExperience ?? this.workExperience,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}