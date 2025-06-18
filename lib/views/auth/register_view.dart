import 'package:dio/dio.dart';
import 'package:docify/components/dropdowns/plain_dropdown.dart';
import 'package:docify/components/text_fields/labeled_text_field.dart';
import 'package:docify/constants/asset_constant.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedGender;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.register(
          _emailController.text.trim(),
          _nameController.text.trim(),
          _phoneController.text.trim(),
          selectedGender!,
          _passwordController.text.trim(),
        );
        
        // Show success message
        _showSuccessSnackBar('Registrasi berhasil! Silakan login.');
        
        // Navigate to login after delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstant.loginView,
            (route) => false,
          );
        }
      } on DioException catch (e) {
        _showErrorSnackBar('Registrasi gagal: ${e.message ?? 'Terjadi kesalahan'}');
      } catch (e) {
        _showErrorSnackBar('Registrasi gagal: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Container(
          height: size.height,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header Section with Logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox(
                                width: size.width * 0.2,
                                height: size.width * 0.2,
                                child: Image.asset(
                                  AssetConstant.docifyLogo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Bergabung dengan Docify',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daftarkan diri Anda sebagai pasien\ndengan informasi yang valid',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Form Section
                    Flexible(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Form Fields
                                  LabeledTextField(
                                    label: 'Email',
                                    placeholder: 'Masukkan alamat email Anda',
                                    controller: _emailController,
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value!)) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  LabeledTextField(
                                    label: 'Nama Lengkap',
                                    placeholder: 'Masukkan nama lengkap Anda',
                                    controller: _nameController,
                                    prefixIcon: Icons.person_outline,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      if (value!.length < 2) {
                                        return 'Nama minimal 2 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  LabeledTextField(
                                    label: 'Nomor Telepon',
                                    placeholder: 'Masukkan nomor telepon Anda',
                                    controller: _phoneController,
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Nomor telepon tidak boleh kosong';
                                      }
                                      if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value!)) {
                                        return 'Format nomor telepon tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  SizedBox(
                                    width: size.width * 0.6, // Membatasi lebar dropdown
                                    child: PlainDropdown<String>(
                                      label: 'Jenis Kelamin',
                                      hint: 'Pilih jenis kelamin',
                                      items: const [
                                        'Laki-laki',
                                        'Perempuan',
                                      ],
                                      value: selectedGender,
                                      onChanged: (value) {
                                        setState(() => selectedGender = value);
                                      },
                                      prefixIcon: Icons.wc_outlined,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Jenis kelamin harus dipilih';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  LabeledTextField(
                                    label: 'Kata Sandi',
                                    placeholder: 'Buat kata sandi yang kuat',
                                    isPassword: true,
                                    controller: _passwordController,
                                    prefixIcon: Icons.lock_outline,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Kata sandi tidak boleh kosong';
                                      }
                                      if (value!.length < 8) {
                                        return 'Kata sandi minimal 8 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Register Button
                                  _buildGradientButton(
                                    text: 'Daftar Sekarang',
                                    onPressed: _register,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Login Link
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                        children: [
                                          const TextSpan(text: 'Sudah memiliki akun? '),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                RouteConstant.loginView,
                                                (route) => false,
                                              ),
                                              child: Text(
                                                'Masuk sekarang',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.primary,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}