import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/login_screen/login_screen.dart';
import 'package:english_word_app/screens/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './api/supabase_api.dart';
import './api/tts_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set your desired color here
      statusBarIconBrightness: Brightness.dark, // For Android: dark icons
      statusBarBrightness: Brightness.light, // For iOS: light background
    ),
  );

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  KakaoSdk.init(nativeAppKey: '2cbfd4051974d27b76cca48b55922508');

  /* 카카오 키 해시값 확인용
  String keyHash = await KakaoSdk.origin;
  print("🔑 Kakao Key Hash: $keyHash");
  */

  SupabaseAPI.getInstance().init();
  TTSAPI.getInstance().init();

  final secureStorage = FlutterSecureStorage();

  // 사용자를 supabase에서 임의로 지웠을 경우, 리프레시 토큰도 삭제해주어야 함
  // await secureStorage.write(key: "refreshToken", value: null);

  String? refreshToken = null;
  UserInfo? userInfo = null;
  bool isExistToken = (await secureStorage.read(key: 'refreshToken')) != null;
  // 리프레시 토큰이 저장되어 있다면, SSO 인증을 시작한다.
  if (isExistToken) {
    refreshToken = await secureStorage.read(key: 'refreshToken');

    SupabaseAPI client = SupabaseAPI.getInstance();
    userInfo = await client.LoginWithJWT(refreshToken!);
  }

  runApp(ProviderScope(child: EnglishWordApp(userInfo: userInfo)));
}

class EnglishWordApp extends ConsumerStatefulWidget {
  UserInfo? userInfo;

  EnglishWordApp({super.key, required this.userInfo});

  @override
  ConsumerState<EnglishWordApp> createState() => _EnglishWordAppState();
}

class _EnglishWordAppState extends ConsumerState<EnglishWordApp> {
  @override
  void initState() {
    super.initState();
    SupabaseAPI client = SupabaseAPI.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionTokenProvider);
    final userSession = ref.read(userSessionTokenProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userInfo != null) {
        // userInfo 세션을 전달한 뒤,
        userSession.setSession(widget.userInfo!);
        // 자신을 null로 만든다.
        widget.userInfo = null;
      }
    });

    return MaterialApp(
      locale: Locale('ko'),
      supportedLocales: [Locale('en'), Locale('ko')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: userSession.isLoggedIn() ? MainScreen() : LoginScreen(),
    );
  }
}
