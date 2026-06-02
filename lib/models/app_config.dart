class AppConfig {
  const AppConfig({
    this.appName = 'Secure2share',
    this.splash = const SplashConfig(),
    this.login = const LoginConfig(),
    this.home = const HomeConfig(),
    this.screens = const ScreenConfig(),
    this.sharing = const SharingConfig(),
    this.google = const GoogleConfig(),
    this.driveFolder = const DriveFolderConfig(),
    this.firebase = const FirebaseDatabaseConfig(),
    this.allowedMimeTypes = const <String>[],
  });

  final String appName;
  final SplashConfig splash;
  final LoginConfig login;
  final HomeConfig home;
  final ScreenConfig screens;
  final SharingConfig sharing;
  final GoogleConfig google;
  final DriveFolderConfig driveFolder;
  final FirebaseDatabaseConfig firebase;
  final List<String> allowedMimeTypes;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] as String? ?? 'Secure2share',
      splash: SplashConfig.fromJson(json['splash'] as Map<String, dynamic>?),
      login: LoginConfig.fromJson(json['login'] as Map<String, dynamic>?),
      home: HomeConfig.fromJson(json['home'] as Map<String, dynamic>?),
      screens: ScreenConfig.fromJson(json['screens'] as Map<String, dynamic>?),
      sharing: SharingConfig.fromJson(json['sharing'] as Map<String, dynamic>?),
      google: GoogleConfig.fromJson(json['google'] as Map<String, dynamic>?),
      driveFolder: DriveFolderConfig.fromJson(
        json['driveFolder'] as Map<String, dynamic>?,
      ),
      firebase: FirebaseDatabaseConfig.fromJson(
        json['firebase'] as Map<String, dynamic>?,
      ),
      allowedMimeTypes:
          (json['allowedMimeTypes'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
    );
  }
}

class FirebaseDatabaseConfig {
  const FirebaseDatabaseConfig({
    this.userCollection = 'users',
    this.bankDetailsCollection = 'bankDetails',
    this.aadhaarDetailsCollection = 'aadhaarDetails',
    this.panDetailsCollection = 'panDetails',
    this.passportDetailsCollection = 'passportDetails',
    this.drivingLicenseDetailsCollection = 'drivingLicenseDetails',
    this.voterIdDetailsCollection = 'voterIdDetails',
    this.upiDetailsCollection = 'upiDetails',
    this.loginDetailsCollection = 'loginDetails',
    this.addressDetailsCollection = 'addressDetails',
    this.enableTableCollections = true,
    this.bankDetailsTableCollection = 'bankDetailsTable',
    this.aadhaarDetailsTableCollection = 'aadhaarDetailsTable',
    this.panDetailsTableCollection = 'panDetailsTable',
    this.passportDetailsTableCollection = 'passportDetailsTable',
    this.drivingLicenseDetailsTableCollection = 'drivingLicenseDetailsTable',
    this.voterIdDetailsTableCollection = 'voterIdDetailsTable',
    this.upiDetailsTableCollection = 'upiDetailsTable',
    this.loginDetailsTableCollection = 'loginDetailsTable',
    this.addressDetailsTableCollection = 'addressDetailsTable',
  });

  final String userCollection;
  final String bankDetailsCollection;
  final String aadhaarDetailsCollection;
  final String panDetailsCollection;
  final String passportDetailsCollection;
  final String drivingLicenseDetailsCollection;
  final String voterIdDetailsCollection;
  final String upiDetailsCollection;
  final String loginDetailsCollection;
  final String addressDetailsCollection;
  final bool enableTableCollections;
  final String bankDetailsTableCollection;
  final String aadhaarDetailsTableCollection;
  final String panDetailsTableCollection;
  final String passportDetailsTableCollection;
  final String drivingLicenseDetailsTableCollection;
  final String voterIdDetailsTableCollection;
  final String upiDetailsTableCollection;
  final String loginDetailsTableCollection;
  final String addressDetailsTableCollection;

  factory FirebaseDatabaseConfig.fromJson(Map<String, dynamic>? json) {
    return FirebaseDatabaseConfig(
      userCollection: _readName(json, 'userCollection', 'users'),
      bankDetailsCollection: _readName(
        json,
        'bankDetailsCollection',
        'bankDetails',
      ),
      aadhaarDetailsCollection: _readName(
        json,
        'aadhaarDetailsCollection',
        'aadhaarDetails',
      ),
      panDetailsCollection: _readName(
        json,
        'panDetailsCollection',
        'panDetails',
      ),
      passportDetailsCollection: _readName(
        json,
        'passportDetailsCollection',
        'passportDetails',
      ),
      drivingLicenseDetailsCollection: _readName(
        json,
        'drivingLicenseDetailsCollection',
        'drivingLicenseDetails',
      ),
      voterIdDetailsCollection: _readName(
        json,
        'voterIdDetailsCollection',
        'voterIdDetails',
      ),
      upiDetailsCollection: _readName(
        json,
        'upiDetailsCollection',
        'upiDetails',
      ),
      loginDetailsCollection: _readName(
        json,
        'loginDetailsCollection',
        'loginDetails',
      ),
      addressDetailsCollection: _readName(
        json,
        'addressDetailsCollection',
        'addressDetails',
      ),
      enableTableCollections: json?['enableTableCollections'] as bool? ?? true,
      bankDetailsTableCollection: _readName(
        json,
        'bankDetailsTableCollection',
        'bankDetailsTable',
      ),
      aadhaarDetailsTableCollection: _readName(
        json,
        'aadhaarDetailsTableCollection',
        'aadhaarDetailsTable',
      ),
      panDetailsTableCollection: _readName(
        json,
        'panDetailsTableCollection',
        'panDetailsTable',
      ),
      passportDetailsTableCollection: _readName(
        json,
        'passportDetailsTableCollection',
        'passportDetailsTable',
      ),
      drivingLicenseDetailsTableCollection: _readName(
        json,
        'drivingLicenseDetailsTableCollection',
        'drivingLicenseDetailsTable',
      ),
      voterIdDetailsTableCollection: _readName(
        json,
        'voterIdDetailsTableCollection',
        'voterIdDetailsTable',
      ),
      upiDetailsTableCollection: _readName(
        json,
        'upiDetailsTableCollection',
        'upiDetailsTable',
      ),
      loginDetailsTableCollection: _readName(
        json,
        'loginDetailsTableCollection',
        'loginDetailsTable',
      ),
      addressDetailsTableCollection: _readName(
        json,
        'addressDetailsTableCollection',
        'addressDetailsTable',
      ),
    );
  }

  static String _readName(
    Map<String, dynamic>? json,
    String key,
    String fallback,
  ) {
    final value = (json?[key] as String?)?.trim();
    return value?.isNotEmpty == true ? value! : fallback;
  }
}

class GoogleConfig {
  const GoogleConfig({this.clientId = '', this.serverClientId = ''});

  final String clientId;
  final String serverClientId;

  factory GoogleConfig.fromJson(Map<String, dynamic>? json) {
    return GoogleConfig(
      clientId: json?['clientId'] as String? ?? '',
      serverClientId: json?['serverClientId'] as String? ?? '',
    );
  }
}

class DriveFolderConfig {
  const DriveFolderConfig({this.name = 'Secure2share', this.parentId = 'root'});

  final String name;
  final String parentId;

  DriveFolderConfig copyWith({String? name, String? parentId}) {
    return DriveFolderConfig(
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
    );
  }

  factory DriveFolderConfig.fromJson(Map<String, dynamic>? json) {
    final name = (json?['name'] as String?)?.trim();
    final parentId = (json?['parentId'] as String?)?.trim();
    return DriveFolderConfig(
      name: name?.isNotEmpty == true ? name! : 'Secure2share',
      parentId: parentId?.isNotEmpty == true ? parentId! : 'root',
    );
  }
}

class SplashConfig {
  const SplashConfig({
    this.subtitle = 'Create, save, and share private files securely',
  });

  final String subtitle;

  factory SplashConfig.fromJson(Map<String, dynamic>? json) {
    return SplashConfig(
      subtitle:
          json?['subtitle'] as String? ??
          'Create, save, and share private files securely',
    );
  }
}

class LoginConfig {
  const LoginConfig({
    this.title = 'Welcome to Secure2share',
    this.subtitle =
        'Sign in with Google to browse your files, import them into private app storage, preview them, and share safely.',
    this.googleButtonText = 'Continue with Google',
  });

  final String title;
  final String subtitle;
  final String googleButtonText;

  factory LoginConfig.fromJson(Map<String, dynamic>? json) {
    return LoginConfig(
      title: json?['title'] as String? ?? 'Welcome to Secure2share',
      subtitle:
          json?['subtitle'] as String? ??
          'Sign in with Google to browse your files, import them into private app storage, preview them, and share safely.',
      googleButtonText:
          json?['googleButtonText'] as String? ?? 'Continue with Google',
    );
  }
}

class HomeConfig {
  const HomeConfig({
    this.greetingPrefix = 'Hello',
    this.recentSectionTitle = 'Saved secure files',
    this.viewAllText = 'View all',
    this.emptyRecentText = 'Secure details will appear here',
    this.actions = const <String, HomeActionConfig>{
      'browse': HomeActionConfig(text: 'My files', enabled: false),
      'device': HomeActionConfig(text: 'Create', enabled: false),
      'recent': HomeActionConfig(text: 'Recent files', enabled: true),
      'sign_out': HomeActionConfig(text: 'Sign out', enabled: false),
    },
  });

  final String greetingPrefix;
  final String recentSectionTitle;
  final String viewAllText;
  final String emptyRecentText;
  final Map<String, HomeActionConfig> actions;

  factory HomeConfig.fromJson(Map<String, dynamic>? json) {
    final defaults = const HomeConfig().actions;
    final actions = <String, HomeActionConfig>{...defaults};
    final actionList = json?['actions'] as List<dynamic>?;
    if (actionList != null) {
      for (final item in actionList.whereType<Map<String, dynamic>>()) {
        final id = item['id'] as String?;
        if (id == null || id.isEmpty) continue;
        actions[id] = HomeActionConfig(
          text: item['text'] as String? ?? defaults[id]?.text ?? id,
          enabled: item['enabled'] as bool? ?? defaults[id]?.enabled ?? true,
        );
      }
    }

    return HomeConfig(
      greetingPrefix: json?['greetingPrefix'] as String? ?? 'Hello',
      recentSectionTitle:
          json?['recentSectionTitle'] as String? ?? 'Saved secure files',
      viewAllText: json?['viewAllText'] as String? ?? 'View all',
      emptyRecentText:
          json?['emptyRecentText'] as String? ??
          'Secure details will appear here',
      actions: actions,
    );
  }
}

class HomeActionConfig {
  const HomeActionConfig({required this.text, required this.enabled});

  final String text;
  final bool enabled;
}

class ScreenConfig {
  const ScreenConfig({
    this.filesTitle = 'Files',
    this.filesEmptyText = 'No files found',
    this.recentTitle = 'Recent files',
    this.recentEmptyText = 'No imported files yet',
    this.previewTitle = 'File details',
  });

  final String filesTitle;
  final String filesEmptyText;
  final String recentTitle;
  final String recentEmptyText;
  final String previewTitle;

  factory ScreenConfig.fromJson(Map<String, dynamic>? json) {
    return ScreenConfig(
      filesTitle: json?['filesTitle'] as String? ?? 'Files',
      filesEmptyText: json?['filesEmptyText'] as String? ?? 'No files found',
      recentTitle: json?['recentTitle'] as String? ?? 'Recent files',
      recentEmptyText:
          json?['recentEmptyText'] as String? ?? 'No imported files yet',
      previewTitle: json?['previewTitle'] as String? ?? 'File details',
    );
  }
}

class SharingConfig {
  const SharingConfig({
    this.shareButtonText = 'Share',
    this.openButtonText = 'Open',
  });

  final String shareButtonText;
  final String openButtonText;

  factory SharingConfig.fromJson(Map<String, dynamic>? json) {
    return SharingConfig(
      shareButtonText: json?['shareButtonText'] as String? ?? 'Share',
      openButtonText: json?['openButtonText'] as String? ?? 'Open',
    );
  }
}
