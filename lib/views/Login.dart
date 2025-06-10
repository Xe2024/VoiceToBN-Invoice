import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _moveAnimation;
  bool _isPressed = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isSigningUp = false;
  bool _isGoogleSigningIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Even slower, more subtle
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03, // Very subtle scale
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.008, 0.008), // Very subtle movement
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final glassWidth = screenWidth * 0.85;
    final glassHeight = screenHeight * 0.70; // Increased from 0.55 to 0.70

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Shimmer animation value
          final shimmerPosition = (_controller.value * 2 - 0.5) % 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated purple vector PNG (cutouts)
              Transform.translate(
                offset: Offset(
                  screenWidth * _moveAnimation.value.dx,
                  screenHeight * _moveAnimation.value.dy,
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/loginPage/registerPageBg.png',
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: screenHeight,
                    ),
                  ),
                ),
              ),
              // Frosted glass particles/bubbles
              ...List.generate(8, (i) {
                final left =
                    (screenWidth * 0.2) + (i * 30.0) % (glassWidth * 0.7);
                final top =
                    (screenHeight * 0.25) + (i * 40.0) % (glassHeight * 0.7);
                return Positioned(
                  left: left,
                  top: top,
                  child: Container(
                    width: 18 + (i % 3) * 6.0,
                    height: 18 + (i % 3) * 6.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08 + (i % 3) * 0.04),
                    ),
                  ),
                );
              }),
              // Glassy form on top
              Center(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 1.03 : 1.0,
                    duration: Duration(milliseconds: 150),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Glass effect with border gradient and glow
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: glassWidth,
                              height: glassHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black.withOpacity(
                                  0.3,
                                ), // Subtle black glass
                                border: Border.all(
                                  width: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.18,
                                    ), // Subtle shadow, no blue
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: null,
                            ),
                          ),
                          // Animated shimmer/highlight
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  return CustomPaint(
                                    painter: _ShimmerPainter(shimmerPosition),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Form content
                          Container(
                            width: glassWidth,
                            height: glassHeight,
                            padding: EdgeInsets.all(screenWidth * 0.06),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.08,
                                    color: Colors.white,
                                    fontFamily:
                                        'AbhayaLibreMedium', // Make sure this font is added in pubspec.yaml
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                // Email Field
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.02,
                                  ),
                                  child: Focus(
                                    focusNode: _emailFocus,
                                    child: Builder(
                                      builder: (context) {
                                        final isFocused = Focus.of(
                                          context,
                                        ).hasFocus;
                                        return TextField(
                                          controller: _emailController,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'AbhayaLibreMedium',
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                    ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 0,
                                              ),
                                              child: Icon(
                                                Icons.email_outlined,
                                                color: isFocused
                                                    ? Colors.blue
                                                    : Colors.grey[400],
                                              ),
                                            ),
                                            hintText: 'Email',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontFamily: 'AbhayaLibreMedium',
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(
                                              0.07,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 16,
                                                  horizontal: 0,
                                                ),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Password Field
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.01,
                                  ),
                                  child: Focus(
                                    focusNode: _passwordFocus,
                                    child: Builder(
                                      builder: (context) {
                                        final isFocused = Focus.of(
                                          context,
                                        ).hasFocus;
                                        return TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'AbhayaLibreMedium',
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                    ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 0,
                                              ),
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: isFocused
                                                    ? Colors.blue
                                                    : Colors.grey[400],
                                              ),
                                            ),
                                            hintText: 'Password',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontFamily: 'AbhayaLibreMedium',
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(
                                              0.07,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 16,
                                                  horizontal: 0,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white.withOpacity(
                                        0.7,
                                      ),
                                      textStyle: TextStyle(
                                        fontFamily: 'AbhayaLibreMedium',
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                    child: Text('Forgot password?'),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                // Sign In Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSigningUp
                                        ? null
                                        : () async {
                                            setState(() => _isSigningUp = true);
                                            // Simulate loading
                                            await Future.delayed(
                                              Duration(seconds: 2),
                                            );
                                            setState(
                                              () => _isSigningUp = false,
                                            );
                                            // Handle sign up logic here
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isSigningUp
                                          ? Colors.white
                                          : Colors.blue,
                                      foregroundColor: _isSigningUp
                                          ? Colors.blue
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      textStyle: TextStyle(
                                        fontFamily: 'AbhayaLibreMedium',
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      elevation: 0,
                                      disabledBackgroundColor: Colors.white,
                                      disabledForegroundColor: Colors.blue,
                                    ),
                                    child: _isSigningUp
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.blue,
                                                      strokeWidth: 2.5,
                                                    ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Signing Up...',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontFamily:
                                                      'AbhayaLibreMedium',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text('Sign Up'),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                // Subtle Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontFamily: 'AbhayaLibreMedium',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                // Google Sign In Button
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: _isGoogleSigningIn
                                        ? null
                                        : () async {
                                            setState(
                                              () => _isGoogleSigningIn = true,
                                            );
                                            await Future.delayed(
                                              const Duration(seconds: 2),
                                            );
                                            setState(
                                              () => _isGoogleSigningIn = false,
                                            );
                                            // Handle Google sign in logic here
                                          },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      padding: EdgeInsets.all(
                                        _isGoogleSigningIn ? 2 : 0,
                                      ), // Show border when loading
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: _isGoogleSigningIn
                                            ? LinearGradient(
                                                colors: [
                                                  Color(
                                                    0xFF4285F4,
                                                  ), // Google Blue
                                                  Color(
                                                    0xFF34A853,
                                                  ), // Google Green
                                                  Color(
                                                    0xFFFBBC05,
                                                  ), // Google Yellow
                                                  Color(
                                                    0xFFEA4335,
                                                  ), // Google Red
                                                  Color(
                                                    0xFF4285F4,
                                                  ), // Google Blue again for smoothness
                                                ],
                                                stops: [
                                                  0.0,
                                                  0.25,
                                                  0.5,
                                                  0.75,
                                                  1.0,
                                                ],
                                              )
                                            : null,
                                        boxShadow: _isGoogleSigningIn
                                            ? [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(
                                                    0.3,
                                                  ),
                                                  blurRadius: 16,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _isGoogleSigningIn
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                  )
                                                : SvgPicture.asset(
                                                    'assets/loginPage/google_logo.svg',
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _isGoogleSigningIn
                                                  ? 'Signing In...'
                                                  : 'Sign in with Google',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'AbhayaLibreMedium',
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Shimmer painter for animated highlight
class _ShimmerPainter extends CustomPainter {
  final double position;
  _ShimmerPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.08), // Less intense highlight
        Colors.white.withOpacity(0.0),
      ],
      stops: [position - 0.08, position, position + 0.08],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..blendMode = BlendMode.lighten;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      oldDelegate.position != position;
}
