import 'dart:convert';

import 'package:docify/constants/asset_constant.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docify/utilities/user_roles.dart';

// Data Storage Functions
Future<void> storeDataToLocal(String key, Map<String, dynamic> json) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, jsonEncode(json));
}

Future<Map<String, dynamic>?> getDataFromLocal(String key) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString(key) == null) return null;
  return jsonDecode(prefs.getString(key)!);
}

Future<void> removeDataFromLocal(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

// User Role Functions
String getUserHome(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return RouteConstant.admin_homeView;
    case UserRole.dokter:
      return RouteConstant.doctor_homeView;
    case UserRole.pasien:
      return RouteConstant.patient_homeView;
  }
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

UserRole userRoleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'dokter':
      return UserRole.dokter;
    case 'pasien':
      return UserRole.pasien;
    default:
      throw Exception('Undefined role: $role');
  }
}

// Modern UI Components
void showErrorSnackbar(BuildContext context, dynamic error) {
  final String errorString = error.toString();
  logger.e(error);
  showModernSnackBar(
    context: context,
    message: errorString.length < 50 ? errorString : 'Something went wrong.',
    type: SnackBarType.error,
  );
}

enum SnackBarType { success, error, warning, info }

void showModernSnackBar({
  required BuildContext context,
  required String message,
  SnackBarType type = SnackBarType.info,
  int? durationInSeconds,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  Color backgroundColor;
  Color textColor;
  IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xFF4CAF50);
      textColor = Colors.white;
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = const Color(0xFFE53E3E);
      textColor = Colors.white;
      icon = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = const Color(0xFFF59E0B);
      textColor = Colors.white;
      icon = Icons.warning_amber_outlined;
      break;
    case SnackBarType.info:
      backgroundColor = const Color(0xFF3B82F6);
      textColor = Colors.white;
      icon = Icons.info_outline;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: durationInSeconds ?? 4),
      action: onAction != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onAction,
            )
          : null,
    ),
  );
}

// Legacy SnackBar (for backward compatibility)
void showSnackBar({
  required BuildContext context,
  required String message,
  int? durationInSeconds,
}) {
  showModernSnackBar(
    context: context,
    message: message,
    durationInSeconds: durationInSeconds,
  );
}

void showModernDialog({
  required BuildContext context,
  required Widget content,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Color? confirmColor,
  bool isDangerous = false,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AssetConstant.docifyLogo,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (title != null)
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
            
            // Actions
            if (confirmLabel != null || cancelLabel != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cancelLabel != null) ...[
                      ModernButton(
                        text: cancelLabel,
                        onPressed: onCancel ?? () => Navigator.of(context).pop(),
                        variant: ButtonVariant.outlined,
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (confirmLabel != null)
                      ModernButton(
                        text: confirmLabel,
                        onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                        variant: isDangerous ? ButtonVariant.danger : ButtonVariant.primary,
                        backgroundColor: confirmColor,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// Legacy Dialog (for backward compatibility)
void showDocifyDialog({
  required BuildContext context,
  required Widget content,
  String? confirmLabel,
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Color? confirmColor,
}) {
  showModernDialog(
    context: context,
    content: content,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    onConfirm: onConfirm,
    onCancel: onCancel,
    confirmColor: confirmColor,
  );
}

// Modern Button Component
enum ButtonVariant { primary, outlined, danger, success }

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Color? backgroundColor;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.backgroundColor,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      switch (variant) {
        case ButtonVariant.primary:
          return Theme.of(context).primaryColor;
        case ButtonVariant.outlined:
          return Colors.transparent;
        case ButtonVariant.danger:
          return const Color(0xFFE53E3E);
        case ButtonVariant.success:
          return const Color(0xFF4CAF50);
      }
    }

    Color getTextColor() {
      switch (variant) {
        case ButtonVariant.outlined:
          return Theme.of(context).primaryColor;
        default:
          return Colors.white;
      }
    }

    BorderSide? getBorder() {
      switch (variant) {
        case ButtonVariant.outlined:
          return BorderSide(color: Theme.of(context).primaryColor, width: 1.5);
        default:
          return null;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: variant == ButtonVariant.outlined ? 0 : 2,
          shadowColor: getBackgroundColor().withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: getBorder() ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Success SnackBar Helper
void showSuccessSnackbar(BuildContext context, String message) {
  showModernSnackBar(
    context: context,
    message: message,
    type: SnackBarType.success,
  );
}

// Warning SnackBar Helper
void showWarningSnackbar(BuildContext context, String message) {
  showModernSnackBar(
    context: context,
    message: message,
    type: SnackBarType.warning,
  );
}

// Info SnackBar Helper
void showInfoSnackbar(BuildContext context, String message) {
  showModernSnackBar(
    context: context,
    message: message,
    type: SnackBarType.info,
  );
}

// Modern Loading Dialog
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message ?? 'Loading...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}