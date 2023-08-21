# 💬 msg91 - msg91.com Official API Wrapper (Unofficial Dart Package)

API for [msg91](https://msg91.com) - Secure and robust APIs for SMS, Email, Voice, Authentication and more

## Features

This package provides functionality to send sms via msg91 API with ease

## Getting started

Just install the package and check example for usage

## Usage

```dart
import 'package:msg91/msg91.dart';

final msg91 = Msg91().initialize(authKey: "AUTH_KEY");
final sms = msg91.getSMS();
sms.send(
    flowId: "templateId",
    recipients: SmsRecipients(
        mobile: "mobile",
        key: {"name": "John Doe"},
    ),
    options: SmsOptions(
        senderId: "senderId",
        shortURL: false,
    ),
).then((value) {
    print("Response: $value");
}).catchError((err) {
    print("Err Response: $err");
});
```

## 📝 Feature List Roadmap

| # | Feature               | Status |
|---|-----------------------|--------|
| 1 | Send SMS              | 🟢     |
| 2 | Send OTP              | 🔴     |
| 3 | Launch Campaign       | 🔴     |
| 4 | Check Balance         | 🔴     |
| 5 | Add SMS Template      | 🟢     |
| 6 | Send WhatsApp Message | 🔴     |

#### Much more features will be added as the project grows and it'll be really helpful if anyone can contribute to this package.

<br/>
🔴 Pending<br/>
🟢 Complete<br/>
<br/>

