import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';

class Intermediate extends StatefulWidget {
  const Intermediate({super.key});

  @override
  State<Intermediate> createState() => _IntermediateState();
}

class _IntermediateState extends State<Intermediate>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white, // Change Background color
        systemNavigationBarIconBrightness: Brightness.dark, // Change Icon color
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Transform.scale(
                scale: 1.5,
                child: SvgPicture.asset("assets/loginPage/gradientSphere.svg"),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.scale(
                scale: 0.5,
                child: SvgPicture.asset("assets/loginPage/gradientSphere.svg"),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - _controller.value)),
                      child: Text(
                        "Lets get Started!",
                        style: GoogleFonts.abhayaLibre(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
