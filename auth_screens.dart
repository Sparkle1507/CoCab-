import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/app_state.dart';
import '../../../navigation/main_navigation_screen.dart'; // ✨ Idhava pudhusa add pannu
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOtp() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.length != 10) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(phone: phoneNumber)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPremiumBlack,
      body: Stack(
        children: [
          Positioned(
            top: -120, right: -80, 
            child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, color: kPremiumIndigo.withOpacity(0.28)))
          ),
          Positioned(
            bottom: -140, left: -80, 
            child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: kPremiumGreen.withOpacity(0.10)))
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 54, height: 54, 
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.10))), 
                      child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 30)
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(20)), 
                      child: const Row(children: [
                        Icon(Icons.shield_outlined, size: 15, color: kPremiumGreen), 
                        SizedBox(width: 6), 
                        Text('Safe & smart', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 11))
                      ])
                    )
                  ]),
                  const SizedBox(height: 54),
                  const Text('Ride better.', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.8)),
                  const SizedBox(height: 6),
                  Text('Premium rides,\nshared smartly.', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 20, height: 1.25, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.075), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.08))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text('Enter your mobile number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1),
                          decoration: InputDecoration(
                            counterText: '', 
                            prefixText: '+91  ', 
                            prefixStyle: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 18, fontWeight: FontWeight.w700), 
                            hintText: '00000 00000', 
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontWeight: FontWeight.w600, letterSpacing: 2), 
                            filled: true, 
                            fillColor: Colors.white.withOpacity(0.06), 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), 
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 58, 
                          width: double.infinity, 
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp, 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kPremiumBlack, disabledBackgroundColor: Colors.white24), 
                            child: _isLoading 
                              ? const SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2.5, color: kPremiumBlack)) 
                              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 20)])
                          )
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(child: Text('By continuing, you agree to CoCab\'s terms & privacy policy.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.38), fontSize: 11, height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpScreen extends StatelessWidget {
  final String phone;
  OtpScreen({super.key, required this.phone});
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPremiumBlack,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Spacer(),
            Container(width: 68, height: 68, alignment: Alignment.center, decoration: BoxDecoration(color: kPremiumIndigo.withOpacity(0.18), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 34)),
            const SizedBox(height: 28),
            const Text('Verify your number', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2)),
            const SizedBox(height: 8),
            Text('Enter the 6-digit code sent to +91 $phone', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.58), fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),
            TextField(
              controller: _otpController, 
              keyboardType: TextInputType.number, 
              maxLength: 6, 
              textAlign: TextAlign.center, 
              autofocus: true, 
              style: const TextStyle(fontSize: 26, letterSpacing: 14, color: Colors.white, fontWeight: FontWeight.w800), 
              decoration: InputDecoration(counterText: '', filled: true, fillColor: Colors.white.withOpacity(0.07), hintText: '••••••', hintStyle: TextStyle(color: Colors.white.withOpacity(0.16), letterSpacing: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 22))
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 56, 
              child: ElevatedButton(
                onPressed: () async { 
  await AppState.login(phone); 
  if (context.mounted) {
    // ✨ Pazhaya screens ellathaiyum delete pannittu direct-a Home-ku porom!
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()), 
      (route) => false
    );
  }
}, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kPremiumBlack), 
                child: const Text('Confirm & Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))
              )
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: () {}, child: Text('Didn\'t receive a code?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w700))),
            const Spacer(),
          ]),
        ),
      ),
    );
  }
}