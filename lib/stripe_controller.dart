import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '.env.dart';

class StripeController {
  // ===========================================================================
  // Create a payment intent
  // ===========================================================================
  Future<Map<String, dynamic>?> paymentIntent(Map<String, dynamic> data) async {
    try {
      log('çreating payment intent');
      http.Response? response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: <String, String>{
          'authorization': 'bearer $stripeSecretKey',
        },
        body: data,
      );
      log('response gotten');
      log(response.statusCode.toString());
      log(response.body.toString());
      if (int.parse(response.statusCode.toString().substring(0, 1)) == 2) {
        log('response was in 200s');
        var jsonData = jsonDecode(response.body);
        return jsonData;
      }
    } catch (exception) {
      log(exception.toString());
    }
    return null;
  }
}
