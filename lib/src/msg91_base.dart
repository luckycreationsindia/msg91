import 'package:msg91/src/msg91_account.dart';

import 'exceptions.dart';
import 'msg91_otp.dart';
import 'msg91_sms.dart';

/// Msg91 main class
class Msg91 {
  String? _authKey;
  bool _initialized = false;

  /// Method to initialize main class (Providing [authKey] is optional here as you can provide in sub methods)
  Msg91 initialize({String? authKey}) {
    if (_initialized) {
      throw Msg91Exception("MSG91 already initialized");
    }
    _authKey = authKey;
    _initialized = true;

    return this;
  }

  void _validateInit() {
    if (!_initialized) {
      throw Msg91Exception("Call the initialize() first");
    }
  }

  void _validateAuthKey(String? authKey) {
    if (authKey == null || authKey.isEmpty) {
      throw Msg91Exception("AuthKey is missing");
    }
  }

  /// Method to get all SMS related APIs (Provide [authKey] if you have not provided while initialization or if you want to use different authKey)
  Sms getSMS({String? authKey}) {
    _validateInit();
    String? key = authKey ?? _authKey;
    _validateAuthKey(key);

    return Sms(key!);
  }

  /// Method to get all OTP related APIs
  /// <br/><br/>[authKey] parameter (optional) - Provide this parameter if you have not provided while initialization or if you want to use different authKey
  /// <br/><br/>
  Otp getOtp({String? authKey}) {
    _validateInit();
    String? key = authKey ?? _authKey;
    _validateAuthKey(key);

    return Otp(key!);
  }

  /// Method to get all Account related APIs
  /// <br/><br/>[authKey] parameter (optional) - Provide this parameter if you have not provided while initialization or if you want to use different authKey
  /// <br/><br/>
  Account getAccount({String? authKey}) {
    _validateInit();
    String? key = authKey ?? _authKey;
    _validateAuthKey(key);

    return Account(key!);
  }
}
