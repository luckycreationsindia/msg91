import 'package:msg91/msg91.dart';

void main() {
  String authKey = "XXXXXXXXXX";
  final msg91 = Msg91().initialize(authKey: authKey);

  String templateId = "Template01";
  String mobile = "911111111111";
  String mobile2 = "911111111112";
  String? senderId = "John";
  bool shortUrl = false;
  Map<String, String> variables = {
    "name": "John Doe",
    "number": "1111111111",
    "email": "admin@localhost"
  };

  //Send to Single Recipient
  msg91
      .getSMS()
      .send(
          flowId: templateId,
          recipient: SmsRecipients(
            mobile: mobile,
            key: variables,
          ),
          options: SmsOptions(
            senderId: senderId,
            shortURL: shortUrl,
          ))
      .then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });

  //Send to Multiple Recipient
  msg91
      .getSMS()
      .sendMultiple(
          flowId: templateId,
          recipients: [
            SmsRecipients(
              mobile: mobile,
              key: variables,
            ),
            SmsRecipients(
              mobile: mobile2,
              key: variables,
            )
          ],
          options: SmsOptions(
            senderId: senderId,
            shortURL: shortUrl,
          ))
      .then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });

  //Add template
  msg91
      .getSMS()
      .addTemplate(
        template: "This is test Template ##mobile##, ##name##",
        senderId: "SENDER",
        templateName: "TEMPLATENAME",
      )
      .then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });
}
