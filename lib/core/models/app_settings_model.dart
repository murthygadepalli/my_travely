class AppSettings {
  final String termsUrl;
  final String privacyUrl;
  final String supportEmail;
  final bool maintenanceMode;
  final String playStoreLink;
  final String appStoreLink;

  AppSettings({
    required this.termsUrl,
    required this.privacyUrl,
    required this.supportEmail,
    required this.maintenanceMode,
    required this.playStoreLink,
    required this.appStoreLink,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      termsUrl: json['termsAndConditionUrl'] ?? '',
      privacyUrl: json['privacyUrl'] ?? '',
      supportEmail: json['supportEmailId'] ?? '',
      maintenanceMode: json['appMaintenanceMode'] ?? false,
      playStoreLink: json['playStoreLink'] ?? '',
      appStoreLink: json['appStoreLink'] ?? '',
    );
  }
}
