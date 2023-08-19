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

class Msg91 {
  String? authKey;
  bool initialized = false;

  Msg91 initialize({String? authKey}) {
    if (initialized) {
      throw Msg91Exception("MSG91 already initialized");
    }
    this.authKey = authKey;
    initialized = true;

    return this;
  }

  validateInit() {
    if (!initialized) {
      throw Msg91Exception("Call the initialize() first");
    }
  }

  validateAuthKey(String? authKey) {
    if (authKey == null || authKey.isEmpty) {
      throw Msg91Exception("AuthKey is missing");
    }
  }

  Sms getSMS({String? authKey}) {
    validateInit();
    String? key = authKey ?? this.authKey;
    validateAuthKey(key);

    return Sms(key!);
  }
}

class Sms {
  String authKey;
  late String flowId;
  late dynamic recipients;

  validateTemplateId() {
    if (flowId.isEmpty) {
      throw Msg91Exception("Flow/Template ID is missing");
    }
  }

  validateRecipients() {
    if (recipients == null) {
      throw Msg91Exception("Recipient is missing");
    }
    if (recipients is! List<SmsRecipients>) {
      if (recipients.mobile == null || recipients.mobile.isEmpty) {
        throw Msg91Exception("Mobile Number is invalid");
      }
    } else if(recipients.isEmpty) {
      throw Msg91Exception("Recipient List is empty");
    }
  }

  Sms(this.authKey);

  Future<dynamic> send(
      {required String flowId,
      required dynamic recipients,
      SmsOptions? options}) async {
    this.flowId = flowId;
    this.recipients = recipients;

    validateTemplateId();
    validateRecipients();

    String url = "https://api.msg91.com/api/v5/flow/";
    Map<String, dynamic> data = {
      "flow_id": flowId,
    };

    if (recipients is! List<SmsRecipients>) {
      if (recipients.key != null) {
        data.addAll(recipients.key);
      }
      data['mobiles'] = recipients.mobile;
    } else {
      data['recipients'] =
          recipients.map((e) => jsonEncode(e.toJson())).toList();
    }

    if (options != null) {
      if (options.senderId != null) {
        data['sender'] = options.senderId;
      }
      data['short_url'] =
          options.shortURL == null || !options.shortURL! ? '0' : '1';
    }

    try {
      http.Response result = await http.post(
        Uri.parse(url),
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
}

class Msg91Exception implements Exception {
  String message;

  Msg91Exception(this.message);
}
