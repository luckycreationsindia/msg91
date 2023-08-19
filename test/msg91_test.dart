import 'package:msg91/msg91.dart';
import 'package:test/test.dart';

void main() {
  group('MSG91 Group Test', () {
    late Msg91 msg91;

    setUp(() {
      msg91 = Msg91().initialize(authKey: "AuthKey");
    });

    test('Test Single Message', () async {
      try {
        Map<String, dynamic> result = await msg91.getSMS().send(
          flowId: "FlowId",
          recipients: SmsRecipients(
            mobile: "919999999999",
            key: {"a": "b"},
          ),
        );
        expect(result.containsKey('message'), isTrue);
      } catch(err) {
        expect(err, {'message': 'The provided flow ID or template ID is invalid.'});
      }
    });
  });
}
