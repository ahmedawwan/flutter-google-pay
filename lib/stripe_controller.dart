import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '.env.dart';

class StripeController {
  // ===========================================================================
  // Create a payment intent
  // ===========================================================================
  Future<String?> paymentIntent(Map<String, dynamic> data) async {
    try {
      log('çreating payment intent');
      http.Response? response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: <String, String>{
          'authorization': stripeSecretKey,
        },
        body: data,
      );
      log('response gotten');
      log(response.statusCode.toString());
      if (int.parse(response.statusCode.toString().substring(0, 1)) == 2) {
        log('response was in 200s');
        var jsonData = jsonDecode(response.body);
        log(jsonData.toString());
        return jsonData['client_secret'];
      }
    } catch (exception) {
      log(exception.toString());
    }
    return null;
  }
}
