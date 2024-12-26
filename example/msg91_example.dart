import 'package:msg91/msg91.dart';

void main() {
  String authKey = "XXXXXXXXXX";
  final msg91 = Msg91().initialize(authKey: authKey);

  String templateId = "Template01";
  String mobile = "911111111111";
  String mobile2 = "911111111112";
  String? senderId = "John";
  bool shortUrl = false;
  Map<String, String> variables = {"name": "John Doe", "number": "1111111111", "email": "admin@localhost"};

  //Send to Single Recipient
  msg91
      .getSMS()
      .send(
          flowId: templateId,
          recipient: SmsRecipient(
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
            SmsRecipient(
              mobile: mobile,
              key: variables,
            ),
            SmsRecipient(
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

  //Send OTP
  msg91.getOtp().send(mobileNumber: mobile, options: OtpOptions(templateId: templateId)).then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });

  //Verify OTP
  msg91.getOtp().verify(otp: "123456", mobileNumber: mobile).then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });

  //Resend OTP
  msg91.getOtp().resend(mobileNumber: mobile, type: ResendOTPType.VOICE).then((value) {
    print("Response: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });

  //Get Account Balance
  msg91.getAccount().checkBalance(routeType: RouteType.transactional).then((value) {
    print("Balance: $value");
  }).catchError((err) {
    print("Err Response: $err");
  });
}
