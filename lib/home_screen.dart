import 'dart:convert';
import 'dart:developer';
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
        child: pay.GooglePayButton(
          paymentConfigurationAsset: 'google_pay.json',
          onPaymentResult: onGooglePayResult,
          paymentItems: paymentItems,
        ),
      ),
    );
  }

  void onGooglePayResult(paymentResult) async {
    // Send the resulting Google Pay token to your server or PSP
    log(paymentResult.toString());
    String? clientSecret = await StripeController().paymentIntent({
      'amount': '50',
      'currency': 'USD',
      'payment_method_types[]': 'card',
    });
    log('Client Secret: $clientSecret');
    final token =
        paymentResult['paymentMethodData']['tokenizationData']['token'];
    final tokenJson = Map.castFrom(json.decode(token));
    log(tokenJson.toString());

    final params = PaymentMethodParams.cardFromToken(
      paymentMethodData: tokenJson['messageId'],
    );
    await Stripe.instance.confirmPayment(
      clientSecret!,
      params,
    );
  }
}
