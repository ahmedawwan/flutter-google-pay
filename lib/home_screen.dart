import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe_google_pay/.env.dart';
import 'package:pay/pay.dart' as pay;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_google_pay/stripe_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // https://levelup.gitconnected.com/google-pay-in-flutter-1d9a848cc11a
  final paymentItems = [
    const pay.PaymentItem(
      label: 'Total',
      amount: '0.50',
      status: pay.PaymentItemStatus.final_price,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // =====================================================================
        // Google Pay Button Button
        // =====================================================================
        child: pay.GooglePayButton(
          paymentConfigurationAsset: 'google_pay.json',
          onPaymentResult: onGooglePayResult,
          paymentItems: paymentItems,
          onPressed: () async {
            // 1. Add your stripe publishable key to assets/google_pay.json
            await debugChangedStripePublishableKey();
          },
          childOnError:
              const Text('Google Pay is not available in this device'),
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'There was an error while trying to perform the payment'),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // On Google Pay Result
  // ===========================================================================

  Future<void> onGooglePayResult(paymentResult) async {
    log('===========================================================================');
    log('payment result');
    log('===========================================================================');
    log(paymentResult.toString());

    // 2. Fetch payment intent and get the client secret
    final paymentIntentResponse = await StripeController().paymentIntent({
      'amount': '50',
      'currency': 'USD',
      'payment_method_types[]': 'card',
    });
    log('===========================================================================');
    log('payment intent response');
    log('===========================================================================');
    log(paymentIntentResponse.toString());
    final clientSecret = paymentIntentResponse!['client_secret'];

    log('CLIENT SECRET: $clientSecret');
    // 3. Get the token from
    final token =
        paymentResult['paymentMethodData']['tokenizationData']['token'];
    final tokenJson = Map.castFrom(json.decode(token));
    log('===========================================================================');
    log('TOKEN JSON');
    log('===========================================================================');
    log(tokenJson.toString());

      final params = PaymentMethodParams.cardFromToken(
        paymentMethodData: PaymentMethodDataCardFromToken(
          token: tokenJson['id'], // TODO extract the actual token
        ),
    );

    await Stripe.instance.confirmPayment(
      clientSecret,
      params,
    );
  }

  // ===========================================================================
  // Check Whether the publishable key is added
  // ===========================================================================

  Future<void> debugChangedStripePublishableKey() async {
    if (kDebugMode) {
      final profile = await rootBundle.loadString('assets/google_pay.json');
      final isValidKey = profile.contains(
          "pk_test_51Lp3F3BgRJyJbTUM1b8YAicAqA4KbrGLYQSiuspBTxsKzuzz9JbND6792C4FQ4zPgbhsvFTtJFUKuFdgoIV3uUrw00dHFpKEc5");
      assert(
        isValidKey,
        'No stripe publishable key added to the google pay json file',
      );
    }
  }
}

// void onGooglePayResult(paymentResult) async {
//   // Send the resulting Google Pay token to your server or PSP
//   log(paymentResult.toString());
//   String? clientSecret = await StripeController().paymentIntent({
//     'amount': '50',
//     'currency': 'USD',
//     'payment_method_types[]': 'card',
//   });
//   log('Client Secret: $clientSecret');
//   final token =
//       paymentResult['paymentMethodData']['tokenizationData']['token'];
//   final tokenJson = Map.castFrom(json.decode(token));
//   log(tokenJson.toString());

//   final params = PaymentMethodParams.cardFromToken(
//     paymentMethodData: tokenJson['messageId'],
//   );
//   await Stripe.instance.confirmPayment(
//     clientSecret!,
//     params,
//   );
// }
