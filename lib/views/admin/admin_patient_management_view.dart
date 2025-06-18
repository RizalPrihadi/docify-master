import 'package:docify/components/cards/patient_card.dart';
import 'package:docify/components/text_fields/search_text_field.dart';
import 'package:docify/models/patient_model.dart';
import 'package:docify/providers/patient_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminPatientManagementView extends StatefulWidget {
  const AdminPatientManagementView({super.key});

  @override
  State<AdminPatientManagementView> createState() =>
      _AdminPatientManagementViewState();
}

class _AdminPatientManagementViewState extends State<AdminPatientManagementView>
    with TickerProviderStateMixin {
  PatientProvider get patientProvider => context.read<PatientProvider>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatients();
      _animationController.forward();
    });
  }

  Future<void> _loadPatients({String? nama, int? perPage, int? page}) async {
    if (!mounted) return;
    try {
      await patientProvider.getAllPatients(
        nama: nama,
        perPage: perPage ?? 20,
        page: page ?? 1,
      );
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> _nextPage() async {
    if (patientProvider.metaModel.currentPage <
        patientProvider.metaModel.lastPage) {
      await _loadPatients(
        perPage: 10,
        page: patientProvider.metaModel.currentPage + 1,
      );
    }
  }

  Future<void> _previousPage() async {
    if (patientProvider.metaModel.currentPage > 1) {
      await _loadPatients(
        perPage: 10,
        page: patientProvider.metaModel.currentPage - 1,
      );
    }
  }

  Future<void> _search(String? value) async {
    if (value != null && value.isNotEmpty) {
      await _loadPatients(nama: value);
    } else {
      await _loadPatients();
    }
  }

  Future<void> _delete(String id) async {
    try {
      await patientProvider.deletePatient(id);
    } catch (error) {
      showErrorSnackbar(context, error);
    } finally {
      _loadPatients();
      Navigator.pop(context);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manajemen Pasien',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola data pasien dengan mudah',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SearchTextField(
          controller: _searchController,
          onChanged: (value) => _search(value),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPaginationButton(
            icon: Icons.chevron_left,
            onPressed: patientProvider.metaModel.currentPage > 1 ? _previousPage : null,
            isEnabled: patientProvider.metaModel.currentPage > 1,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Halaman ${patientProvider.metaModel.currentPage}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPaginationButton(
            icon: Icons.chevron_right,
            onPressed: patientProvider.metaModel.currentPage < patientProvider.metaModel.lastPage
                ? _nextPage
                : null,
            isEnabled: patientProvider.metaModel.currentPage < patientProvider.metaModel.lastPage,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isEnabled ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.grey[500],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsList() {
    if (patientProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data pasien...'),
          ],
        ),
      );
    }

    if (patientProvider.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data pasien',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],  
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data pasien akan muncul di sini',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: patientProvider.patients.length,
        itemBuilder: (context, index) {
          final PatientModel patient = patientProvider.patients[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: PatientCard(
              patient: patient,
              onDelete: patient.id != null
                  ? () async {
                      await _delete(patient.id!);
                    }
                  : null,
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchSection(),
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    if (provider.patients.isNotEmpty) _buildPaginationControls(),
                    Expanded(
                      child: _buildPatientsList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}