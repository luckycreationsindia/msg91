import 'package:http/http.dart' as http;

enum RouteType { transactional, promotional, otp, wallet }

class Account {
  String authKey;
  final String _getRouteBalance = "https://control.msg91.com/api/balance.php";

  Account(this.authKey);

  /// Method to get account balance.
  /// <hr/>
  /// <br/>[routeType] parameter (optional) - Route Type to get balance for (default is wallet).
  Future<dynamic> checkBalance({RouteType routeType = RouteType.wallet}) async {
    late String type;

    if (routeType == RouteType.transactional) type = "4";
    if (routeType == RouteType.promotional) type = "1";
    if (routeType == RouteType.otp) type = "106";
    if (routeType == RouteType.wallet) type = "Wallet";

    Map<String, dynamic> searchParameters = {"authkey": authKey, "type": type};

    Uri uri = Uri.parse(_getRouteBalance);
    uri = uri.replace(queryParameters: searchParameters);

    try {
      http.Response result = await http.get(
        uri,
        headers: <String, String>{"authkey": authKey},
      );

      if (result.statusCode == 200) {
        return Future.value(result.body);
      } else {
        return Future.error(result.reasonPhrase ?? result.body);
      }
    } catch (error) {
      return Future.error(error);
    }
  }
}
