import 'package:docify/constants/asset_constant.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  AuthProvider? authProvider;
  VoidCallback? _authListener;
  
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;
  
  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Initialize animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
      
      authProvider = Provider.of<AuthProvider>(context, listen: false);

      _authListener = () async {
        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;

        if (authProvider?.isLoggedIn == true) {
          Navigator.pushReplacementNamed(
            context,
            getUserHome(authProvider!.role)
          );
        } else {
          Navigator.pushReplacementNamed(context, RouteConstant.loginView);
        }
      };

      if (_authListener != null) {
        authProvider?.addListener(_authListener!);
      }
      authProvider?.checkLogin();
    });
  }
  
  void _startAnimations() async {
    // Start background animation
    _backgroundController.forward();
    
    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 1200));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    if (authProvider != null && _authListener != null) {
      authProvider!.removeListener(_authListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var brightness = Theme.of(context).brightness;
    var isDark = brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        (Colors.grey[900] ?? Colors.grey).withOpacity(0.8 + 0.2 * _backgroundAnimation.value),
                        (Colors.grey[800] ?? Colors.grey).withOpacity(0.9 + 0.1 * _backgroundAnimation.value),
                        (Colors.grey[850] ?? Colors.grey).withOpacity(0.8 + 0.2 * _backgroundAnimation.value),
                      ]
                    : [
                        (Colors.blue[50] ?? Colors.blue.shade50).withOpacity(0.8 + 0.2 * _backgroundAnimation.value),
                        Colors.white.withOpacity(0.9 + 0.1 * _backgroundAnimation.value),
                        (Colors.blue[100] ?? Colors.blue.shade100).withOpacity(0.8 + 0.2 * _backgroundAnimation.value),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background circles
                ...List.generate(3, (index) => 
                  Positioned(
                    top: size.height * (0.1 + index * 0.3) - 
                         50 * _backgroundAnimation.value,
                    right: size.width * (0.8 - index * 0.4) + 
                           30 * _backgroundAnimation.value,
                    child: Container(
                      width: 100 + index * 50,
                      height: 100 + index * 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary
                            .withOpacity(0.05 * _backgroundAnimation.value),
                      ),
                    ),
                  ),
                ),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animation
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Opacity(
                              opacity: _logoOpacityAnimation.value,
                              child: Container(
                                width: size.width * 0.35,
                                height: size.width * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    AssetConstant.docifyIcon,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // App name with animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textOpacityAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'Docify',
                                    style: GoogleFonts.lexend(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: size.width * 0.12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Temukan Dokter di Sekitarmu',
                                    style: GoogleFonts.lexend(
                                      color: Theme.of(context).colorScheme.onSurface
                                          .withOpacity(0.7),
                                      fontSize: size.width * 0.035,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading indicator with animation
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _progressAnimation.value,
                            child: Column(
                              children: [
                                // Custom loading bar
                                Container(
                                  width: size.width * 0.5,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Theme.of(context).colorScheme.primary
                                        .withOpacity(0.2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.primary
                                                .withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Loading...',
                                  style: GoogleFonts.lexend(
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withOpacity(0.6),
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Version info at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: Text(
                          'Version 1.0.0',
                          style: GoogleFonts.lexend(
                            color: Theme.of(context).colorScheme.onSurface
                                .withOpacity(0.4),
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}