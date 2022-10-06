import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_google_pay/stripe_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GooglePayButton(
          onTap: () {},
        ),
      ),
    );
  }

  void onGooglePayResult(paymentResult) async {
    // Send the resulting Google Pay token to your server or PSP
    log(paymentResult.toString());
    String? clientSecret = await StripeController().paymentIntent({
      'amount': '500',
      'currency': 'USD',
      'type': 'card',
    });
    final token =
        paymentResult['paymentMethodData']['tokenizationData']['token'];
    final tokenJson = Map.castFrom(json.decode(token));

    final params = PaymentMethodParams.cardFromToken(
      paymentMethodData: tokenJson['id'], 
    );
    await Stripe.instance.confirmPayment(
      clientSecret!,
      params,
    );
  }
}
