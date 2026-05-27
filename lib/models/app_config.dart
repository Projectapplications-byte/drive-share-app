class AppConfig {
  const AppConfig({
    this.appName = 'Drive2Share',
    this.splash = const SplashConfig(),
    this.login = const LoginConfig(),
    this.home = const HomeConfig(),
    this.screens = const ScreenConfig(),
    this.sharing = const SharingConfig(),
    this.google = const GoogleConfig(),
    this.driveFolder = const DriveFolderConfig(),
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
  final List<String> allowedMimeTypes;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] as String? ?? 'Drive2Share',
      splash: SplashConfig.fromJson(json['splash'] as Map<String, dynamic>?),
      login: LoginConfig.fromJson(json['login'] as Map<String, dynamic>?),
      home: HomeConfig.fromJson(json['home'] as Map<String, dynamic>?),
      screens: ScreenConfig.fromJson(json['screens'] as Map<String, dynamic>?),
      sharing: SharingConfig.fromJson(json['sharing'] as Map<String, dynamic>?),
      google: GoogleConfig.fromJson(json['google'] as Map<String, dynamic>?),
      driveFolder: DriveFolderConfig.fromJson(
        json['driveFolder'] as Map<String, dynamic>?,
      ),
      allowedMimeTypes:
          (json['allowedMimeTypes'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
    );
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
  const DriveFolderConfig({this.name = 'Drive2Share', this.parentId = 'root'});

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
      name: name?.isNotEmpty == true ? name! : 'Drive2Share',
      parentId: parentId?.isNotEmpty == true ? parentId! : 'root',
    );
  }
}

class SplashConfig {
  const SplashConfig({
    this.subtitle = 'Import, preview, and share files securely',
  });

  final String subtitle;

  factory SplashConfig.fromJson(Map<String, dynamic>? json) {
    return SplashConfig(
      subtitle:
          json?['subtitle'] as String? ??
          'Import, preview, and share files securely',
    );
  }
}

class LoginConfig {
  const LoginConfig({
    this.title = 'Welcome to Drive2Share',
    this.subtitle =
        'Sign in with Google to browse your files, import them into private app storage, preview them, and share safely.',
    this.googleButtonText = 'Continue with Google',
  });

  final String title;
  final String subtitle;
  final String googleButtonText;

  factory LoginConfig.fromJson(Map<String, dynamic>? json) {
    return LoginConfig(
      title: json?['title'] as String? ?? 'Welcome to Drive2Share',
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
    this.recentSectionTitle = 'Recently imported',
    this.viewAllText = 'View all',
    this.emptyRecentText = 'Imported files will appear here',
    this.actions = const <String, HomeActionConfig>{
      'browse': HomeActionConfig(text: 'Browse', enabled: true),
      'device': HomeActionConfig(text: 'Device', enabled: true),
      'recent': HomeActionConfig(text: 'Recent', enabled: true),
      'sign_out': HomeActionConfig(text: 'Sign out', enabled: true),
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
          json?['recentSectionTitle'] as String? ?? 'Recently imported',
      viewAllText: json?['viewAllText'] as String? ?? 'View all',
      emptyRecentText:
          json?['emptyRecentText'] as String? ??
          'Imported files will appear here',
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
    this.previewTitle = 'Preview',
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
      previewTitle: json?['previewTitle'] as String? ?? 'Preview',
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
