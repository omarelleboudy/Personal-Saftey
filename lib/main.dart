import 'package:flutter/material.dart';
import 'package:personal_safety/Auth/confirmCode.dart';
import 'package:personal_safety/Auth/Confirm_newEmail.dart';
import 'package:personal_safety/Auth/login.dart';
import 'package:personal_safety/Auth/logout.dart';
import 'package:personal_safety/Auth/newPassword.dart';
import 'package:personal_safety/Auth/signup.dart';
import 'package:personal_safety/Auth/signupSuccessful.dart';
import 'package:personal_safety/componants/card.dart';
import 'package:get_it/get_it.dart';
import 'package:personal_safety/models/refresh_token.dart';
import 'package:personal_safety/providers/event.dart';
import 'package:personal_safety/screens/events.dart';
import 'package:personal_safety/screens/main_page.dart';
import 'package:personal_safety/screens/news.dart';
import 'package:personal_safety/screens/search.dart';
import 'package:personal_safety/services/SocketHandler.dart';
import 'package:personal_safety/services/change_password_service.dart';
import 'package:personal_safety/services/event_categories_service.dart';
import 'package:personal_safety/services/getEvent_service.dart';
import 'package:personal_safety/services/get_profile_service.dart';
import 'package:personal_safety/services/refresh_token_service.dart';
import 'package:personal_safety/services/service_confirm.dart';
import 'package:personal_safety/services/service_firstLogin.dart';
import 'package:personal_safety/services/service_forgetpassword.dart';
import 'package:personal_safety/services/service_login.dart';
import 'package:personal_safety/services/service_register.dart';
import 'package:provider/provider.dart';
import 'screens/events.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'others/StaticVariables.dart';

void setupLocator() {
  GetIt.instance.registerLazySingleton(() => LoginService());
  GetIt.instance.registerLazySingleton(() => RegisterService());
  GetIt.instance.registerLazySingleton(() => ConfirmService());
  GetIt.instance.registerLazySingleton(() => FirstLoginService());
  GetIt.instance.registerLazySingleton(() => EventCategoriesService());
  GetIt.instance.registerLazySingleton(() => ChangePasswordService());
  GetIt.instance.registerLazySingleton(() => RefreshTokenService());
  GetIt.instance.registerLazySingleton(() => ForgetPasswordService());
  GetIt.instance.registerLazySingleton(() => GetEventsService());
  GetIt.instance.registerLazySingleton(() => GetProfileService());
}

RefreshTokenService get userService => GetIt.instance<RefreshTokenService>();

Future<bool> saveTokenPreference(String token, String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = token;
  prefs.setString(key, value);
}

void refreshTokenMethod() async {
  var currentDate = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  await StaticVariables.Init();

  StaticVariables.prefs.setString("activerequeststate", "Searching");
  var tokenDate = StaticVariables.prefs.getString('tokenDate');
  if (tokenDate == null) {
    //Do Nothing
  } else {
    var oldDate = DateTime.parse(tokenDate);
    var token = StaticVariables.prefs.getString('token');
    var refreshToken = StaticVariables.prefs.getString('refreshToken');
    final refreshTokenService = RefreshTokenCredentials(
      token: token,
      refreshToken: refreshToken,
    );
    print("OLD DATE before change: " + oldDate.toString());
    print("NEW DATE before change: " + currentDate.toString());
    var diff = currentDate.difference(oldDate);
    print("Difference in hours between dates is: ${diff.inHours}");
    if (diff.inHours >= 2) {
      final result = await userService.RefreshToken(refreshTokenService);
      print("from refresh token in main: " + result.status.toString());
      print("from refresh token in main: " + result.result.toString());
      print("from refresh token in main: " + result.hasErrors.toString());
      saveTokenPreference(currentDate.toString(), "tokenDate");
      oldDate = currentDate;
      print("OLD DATE after change: " + oldDate.toString());
      print("NEW DATE after change: " + currentDate.toString());
    } else {
      print("Two Hours have not passed, yet.");
      print("OLD DATE is: " + oldDate.toString());
      print("CURRENT DATE is: " + currentDate.toString());
    }
  }
}

Future<void> main() async {
  refreshTokenMethod();

  WidgetsFlutterBinding.ensureInitialized();
  await StaticVariables.Init();
  StaticVariables.prefs.setString("activerequeststate", "Searching");

  bool firstlogin = StaticVariables.prefs.getBool("firstlogin");
  if (firstlogin == null) StaticVariables.prefs.setBool("firstlogin", false);

  if (!StaticVariables.prefs.containsKey("firstlogin"))
    StaticVariables.prefs.setBool("firstlogin", true);

  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  print('First Login token is: $firstlogin');
  var token = StaticVariables.prefs.getString('token');
  var refreshToken = StaticVariables.prefs.getString('refreshToken');
  print("Saved token used for Remember Me: $token");
  print("Saved Refersh token used for Remember Me: $refreshToken");
  bool goHomeOrGoLogout = false;
  if (token == null || firstlogin == true)
    goHomeOrGoLogout = true;
  else
    goHomeOrGoLogout = false;

  runApp(ChangeNotifierProvider(
    builder: (context) => EventModel(),
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: goHomeOrGoLogout ? Logout() : MainPage()
//      home: SignUpSuccessful(),
        //home: News(),
        ),
  ));
}
