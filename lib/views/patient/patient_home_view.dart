import 'package:docify/constants/route_constant.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:docify/views/patient/patient_appointment_management_view.dart';
import 'package:docify/views/patient/patient_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientHomeView extends StatefulWidget {
  @override
  _PatientHomeViewState createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AuthProvider get authProvider => context.read<AuthProvider>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await authProvider.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConstant.loginView,
        (route) => false,
      );
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Menu Pasien',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                showDocifyDialog(
                  context: context,
                  content: Text(
                    'Apakah anda yakin ingin keluar?',
                    style: GoogleFonts.openSans(fontSize: 16),
                  ),
                  confirmLabel: 'Logout',
                  confirmColor: Colors.red,
                  cancelLabel: 'Batal',
                  onConfirm: _logout,
                  onCancel: () => Navigator.pop(context),
                );
              },
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            PatientAppointmentManagementView(),
            PatientProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _tabController.index == 0
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 24,
                  ),
                ),
                text: 'Janji Temu',
              ),
              Tab(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _tabController.index == 1
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 24,
                  ),
                ),
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}