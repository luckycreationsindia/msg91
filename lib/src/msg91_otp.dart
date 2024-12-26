import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';

class OtpOptions {
  String templateId;
  num? expiry;
  bool? invisible = false;
  num? otp;
  num? userIp;
  num? otpLength;
  Unicode? unicode;
  Map<String, String>? variables;

  OtpOptions({
    required this.templateId,
    this.expiry,
    this.invisible,
    this.otp,
    this.userIp,
    this.otpLength,
    this.unicode,
    this.variables,
  });

  Map<String, dynamic> toJson() => {
        "templateId": templateId,
        "otp_expiry": expiry,
        "invisible": invisible! ? 1 : 0,
        "otp": otp,
        "userip": userIp,
        "otp_length": otpLength ?? 4,
        "unicode": unicode,
        "variables": variables,
      };
}

enum Unicode { NORMAL, UNICODE }

enum ResendOTPType { VOICE, TEXT }

class Otp {
  String authKey;
  final String _sendOTPUrl = "https://api.msg91.com/api/v5/otp";
  final String _verifyOTPUrl = "https://api.msg91.com/api/v5/otp/verify";
  final String _resendOTPUrl = "https://api.msg91.com/api/v5/otp/retry";

  Otp(this.authKey);

  late String _mobileNumber;

  void _validateMobileNumber() {
    if (_mobileNumber.isEmpty) {
      throw Msg91Exception("Mobile Number cannot be empty");
    }
  }

  /// Method to send OTP.
  /// <hr/>
  /// <br/>[mobileNumber] parameter (required) is where you set mobile number.
  /// <br/><br/>[options] parameter (required) is where you set [OtpOptions].
  /// <br/><br/>[options.templateId] parameter (required) is where you set template id.
  /// <br/><br/>[options.invisible] parameter (optional) - For MOBILE APP only (do not use for Browsers); 1 for ON, 0 for OFF; Mobile Number Automatically Verified if its Mobile Network is ON.
  /// <br/><br/>[options.otp] parameter (optional) - OTP you want to send; if you don't pass this value, MSG91 will generate it.
  /// <br/><br/>[options.userIp] parameter (optional) - User IP
  /// <br/><br/>[options.otpLength] parameter (optional) - Number of digits in OTP (default : 4, min : 4, max : 9)
  /// <br/><br/>[options.expiry] parameter (optional) - Enter the value of OTP expiry time (in minutes) (default: 24 hours, max: 7 days, min: 1 minute)
  /// <br/><br/>[options.unicode] parameter (optional) - Enter [Unicode.UNICODE] if sending SMS in languages other than English, for english pass [Unicode.NORMAL]<br/><br/>
  Future<dynamic> send(
      {required String mobileNumber, required OtpOptions options}) async {
    _mobileNumber = mobileNumber;
    _validateMobileNumber();

    if (options.templateId.isEmpty) {
      throw Msg91Exception("Template ID is required");
    }

    Map<String, dynamic> searchParameters = {
      "templateId": options.templateId,
      "mobile": _mobileNumber
    };

    Map<String, dynamic> data = {};

    if (options.invisible != null && options.invisible!) {
      searchParameters['invisible'] = 1;
    }
    if (options.otp != null && options.otp! > 0) {
      searchParameters['otp'] = options.otp!;
    }
    if (options.userIp != null && options.userIp! > 0) {
      searchParameters['userip'] = options.userIp!;
    }
    if (options.otpLength != null && options.otpLength! > 0) {
      searchParameters['otp_length'] = options.otpLength!;
    }
    if (options.expiry != null && options.expiry! > 0) {
      searchParameters['otp_expiry'] = options.expiry!;
    }
    if (options.unicode != null && options.unicode! == Unicode.UNICODE) {
      searchParameters['unicode'] = 1;
    }
    if (options.variables != null) {
      data = options.variables!;
    }

    Uri uri = Uri.parse(_sendOTPUrl);
    uri = uri.replace(queryParameters: searchParameters);

    try {
      http.Response result = await http.post(
        uri,
        headers: <String, String>{"authkey": authKey},
        body: jsonEncode(data),
      );

      if (result.statusCode == 200) {
        // Map<String, dynamic> response = jsonDecode(result.body);
        return Future.value("Success");
      } else {
        return Future.error(result.reasonPhrase ?? result.body);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Method to verify OTP.
  /// <hr/>
  /// <br/>[otp] parameter (required) is where you set otp to verify.
  /// <br/>[mobileNumber] parameter (required) is where you set mobile number.
  Future<dynamic> verify(
      {required String otp, required String mobileNumber}) async {
    _mobileNumber = mobileNumber;
    _validateMobileNumber();

    Map<String, dynamic> searchParameters = {
      "otp": otp,
      "mobile": _mobileNumber
    };

    Uri uri = Uri.parse(_verifyOTPUrl);
    uri = uri.replace(queryParameters: searchParameters);

    try {
      http.Response result = await http.post(
        uri,
        headers: <String, String>{"authkey": authKey},
      );

      if (result.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(result.body);
        String type = response['type'];
        String message = response['message'];

        switch (type) {
          case "success":
            return Future.value({"message": message});
          case "error":
            return Future.error({"message": message});
          default:
            return Future.value(result.body);
        }
      } else {
        return Future.error(result.reasonPhrase ?? result.body);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Method to resend OTP. Maximum Retry Limit is 2.
  /// <hr/>
  /// <br/>[otp] parameter (required) is where you set otp to verify.
  /// <br/>[mobileNumber] parameter (required) is where you set mobile number.
  /// <br/>[type] parameter (optional) is where you set type of OTP (default is voice).
  Future<dynamic> resend(
      {ResendOTPType type = ResendOTPType.VOICE,
      required String mobileNumber}) async {
    _mobileNumber = mobileNumber;
    _validateMobileNumber();

    late String otpType;

    switch (type) {
      case ResendOTPType.VOICE:
        otpType = "Voice";
        break;
      case ResendOTPType.TEXT:
        otpType = "text";
        break;
    }

    Map<String, dynamic> searchParameters = {
      "authkey": authKey,
      "retrytype": otpType,
      "mobile": _mobileNumber
    };

    Uri uri = Uri.parse(_resendOTPUrl);
    uri = uri.replace(queryParameters: searchParameters);

    try {
      http.Response result = await http.post(
        uri,
        headers: <String, String>{"authkey": authKey},
      );

      if (result.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(result.body);
        String type = response['type'];
        String message = response['message'];

        switch (type) {
          case "success":
            return Future.value({"message": message});
          case "error":
            return Future.error({"message": message});
          default:
            return Future.value(result.body);
        }
      } else {
        return Future.error(result.reasonPhrase ?? result.body);
      }
    } catch (error) {
      return Future.error(error);
    }
  }
}
