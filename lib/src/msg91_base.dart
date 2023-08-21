import 'dart:convert';

import 'package:http/http.dart' as http;

class SmsRecipients {
  late String mobile;
  Map<String, String>? key;

  SmsRecipients({required this.mobile, this.key});

  Map<String, dynamic> toJson() => {"mobile": mobile, "key": key};
}

class SmsOptions {
  String? senderId;
  bool? shortURL = false;

  SmsOptions({this.senderId, this.shortURL});

  Map<String, dynamic> toJson() => {"senderId": senderId, "shortURL": shortURL};
}

enum SMSType { NORMAL, UNICODE }

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
}

class Sms {
  String authKey;
  late String _flowId;
  late dynamic _recipients;
  final String _smsUrl = "https://api.msg91.com/api/v5/flow/";
  final String _addTemplateUrl =
      "https://control.msg91.com/api/v5/sms/addTemplate";

  void _validateTemplateId() {
    if (_flowId.isEmpty) {
      throw Msg91Exception("Flow/Template ID is missing");
    }
  }

  void _validateRecipients() {
    if (_recipients == null) {
      throw Msg91Exception("Recipient is missing");
    }
    if (_recipients is! List<SmsRecipients>) {
      if (_recipients.mobile == null || _recipients.mobile.isEmpty) {
        throw Msg91Exception("Recipient Mobile is invalid");
      }
    } else if (_recipients.isEmpty) {
      throw Msg91Exception("Recipient List is empty");
    }
  }

  Sms(this.authKey);

  /// Method to send Single SMS. [flowId] parameter (Flow ID is your Template ID) and [recipient] are required. Provide options if you have replacement variable for SMS Template.
  Future<dynamic> send(
      {required String flowId,
      required SmsRecipients recipient,
      SmsOptions? options}) async {
    _flowId = flowId;
    _recipients = recipient;

    _validateTemplateId();
    _validateRecipients();

    Map<String, dynamic> data = {
      "flow_id": flowId,
    };

    if (recipient.key != null) {
      recipient.key!.forEach((key, value) {
        data[key] = value;
      });
    }

    data['mobiles'] = recipient.mobile;

    if (options != null) {
      if (options.senderId != null) {
        data['sender'] = options.senderId;
      }
      data['short_url'] =
          options.shortURL == null || !options.shortURL! ? '0' : '1';
    }

    try {
      http.Response result = await http.post(
        Uri.parse(_smsUrl),
        headers: <String, String>{"authkey": authKey},
        body: jsonEncode(data),
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
            return Future.value(data);
        }
      } else {
        return Future.error(data);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Method to send SMS to multiple recipients. [flowId] parameter (Flow ID is your Template ID) and [recipients] are required. Provide options if you have replacement variable for SMS Template. You can also provide keys within [recipients] parameters for replacement of variable on different numbers.
  Future<dynamic> sendMultiple(
      {required String flowId,
      required List<SmsRecipients> recipients,
      SmsOptions? options}) async {
    _flowId = flowId;
    _recipients = recipients;

    _validateTemplateId();
    _validateRecipients();

    Map<String, dynamic> data = {
      "flow_id": flowId,
    };

    data['recipients'] = recipients.map((e) => jsonEncode(e.toJson())).toList();

    if (options != null) {
      if (options.senderId != null) {
        data['sender'] = options.senderId;
      }
      data['short_url'] =
          options.shortURL == null || !options.shortURL! ? '0' : '1';
    }

    try {
      http.Response result = await http.post(
        Uri.parse(_smsUrl),
        headers: <String, String>{"authkey": authKey},
        body: jsonEncode(data),
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

  late String _template, _senderId, _templateName;

  void _validateTemplate() {
    if (_template.isEmpty) {
      throw Msg91Exception("Template cannot be empty");
    }
  }

  void _validateSenderId() {
    if (_senderId.isEmpty) {
      throw Msg91Exception("Sender ID cannot be empty");
    } else if (_senderId.length < 3) {
      throw Msg91Exception("Minimum Characters in Sender ID should be 3");
    } else if (_senderId.length > 6) {
      throw Msg91Exception("Maximum Characters in Sender ID should not be greater than 6");
    }
  }

  void _validateTemplateName() {
    if (_templateName.isEmpty) {
      throw Msg91Exception("Template name cannot be empty");
    }
  }

  /// Method to add SMS Template.
  /// [template] parameter (required) is where you add your actual template with variables in format ##VAR1##, ##VAR2##.
  /// <br/><br/>[senderId] parameter (required) is where you add your Sender ID you want to use for this template. Minimum is 3 characters and Max is 6.
  /// <br/><br/>[templateName] parameter (required) is where you name your template.
  /// <br/><br/>[dltTemplateId] parameter (optional) It's mandatory to add this for Indian Users. DLT Registration is mandatory for Indian Users (Follow this URL for more: https://msg91.com/help/MSG91/entity-registration-on-dlt-platform)
  /// <br/><br/>[smsType] parameter (optional) You can provide SMS template type. For English - NORMAL; For unicode content - UNICODE
  Future<dynamic> addTemplate({
    required String template,
    required String senderId,
    required String templateName,
    String? dltTemplateId,
    SMSType? smsType,
  }) async {
    _template = template;
    _senderId = senderId;
    _templateName = templateName;

    _validateTemplate();
    _validateSenderId();
    _validateTemplateName();

    Map<String, dynamic> data = {
      "template": template,
      "sender_id": senderId,
      "template_name": templateName,
    };

    if(dltTemplateId != null && dltTemplateId.isNotEmpty) {
      data['dlt_template_id'] = dltTemplateId;
    }

    data['smsType'] = smsType == null ? 'NORMAL' : smsType.toString();

    try {
      http.Response result = await http.post(
        Uri.parse(_addTemplateUrl),
        headers: <String, String>{"authkey": authKey},
        body: jsonEncode(data),
      );

      if (result.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(result.body);
        return Future.value("Success");
      } else {
        return Future.error(result.reasonPhrase ?? result.body);
      }
    } catch (error) {
      return Future.error(error);
    }
  }
}

class Msg91Exception implements Exception {
  String message;

  Msg91Exception(this.message);
}
