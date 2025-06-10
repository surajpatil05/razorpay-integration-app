import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  const RazorpayPaymentScreen({super.key});

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();

  void openCheckout(amount) async {
    amount *= 100;
    var options = <String, dynamic>{
      'key':
          dotenv.env['RAZORPAY_KEY_ID']!, // Replace with your Razorpay Key ID
      'amount': amount,
      'name': 'GiveAPaw',
      'currency': 'INR',
      'description': 'Donation for GiveAPaw',
      'prefill': {
        'contact': '1234567890',
        'email': 'testM@gmail.com',
        'external': {
          'wallets': ['paytm'],
        },
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    Fluttertoast.showToast(
      msg: "Payment Successful ${response.paymentId!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.message}');
    Fluttertoast.showToast(
      msg: "Payment UnSuccessful ${response.message!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Payment Error: ${response.walletName}');
    Fluttertoast.showToast(
      msg: "External Wallet ${response.walletName!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          'Razorpay Payment Integration',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          "GiveAPaw",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Quick and Secure Payments for a \n Paw-sitive Cause 🐾",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Enter Payment Amount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("How much would you like to pay?"),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextFormField(
                            controller: _amountController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.currency_rupee_rounded,
                                color: Colors.black,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 1.0,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 1.0,
                                ),
                              ),
                              labelText: 'Amount in INR',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_amountController.text.toString().isNotEmpty) {
                              setState(() {
                                int amount = int.parse(
                                  _amountController.text.toString(),
                                );
                                openCheckout(amount);
                              });
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please enter a valid amount",
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 95,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Continue Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                "Real Payments are Processed \n 2025 GiveAPaw",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
