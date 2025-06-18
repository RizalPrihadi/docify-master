import 'package:docify/components/cards/doctor_card.dart';
import 'package:docify/components/text_fields/search_text_field.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/providers/doctor_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminDoctorManagementView extends StatefulWidget {
  const AdminDoctorManagementView({super.key});

  @override
  State<AdminDoctorManagementView> createState() =>
      _AdminDoctorManagementViewState();
}

class _AdminDoctorManagementViewState extends State<AdminDoctorManagementView>
    with TickerProviderStateMixin {
  DoctorProvider get doctorProvider => context.read<DoctorProvider>();
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
      _loadDoctors();
      _animationController.forward();
    });
  }

  Future<void> _loadDoctors({String? nama, int? perPage, int? page}) async {
    if (!mounted) return;
    try {
      await doctorProvider.getAllDoctors(
        nama: nama,
        perPage: perPage ?? 10,
        page: page ?? 1,
      );
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> _nextPage() async {
    if (doctorProvider.metaModel.currentPage <
        doctorProvider.metaModel.lastPage) {
      await _loadDoctors(
        perPage: 10,
        page: doctorProvider.metaModel.currentPage + 1,
      );
    }
  }

  Future<void> _previousPage() async {
    if (doctorProvider.metaModel.currentPage > 1) {
      await _loadDoctors(
        perPage: 10,
        page: doctorProvider.metaModel.currentPage - 1,
      );
    }
  }

  Future<void> _search(String? value) async {
    if (value != null && value.isNotEmpty) {
      await _loadDoctors(nama: value);
    } else {
      await _loadDoctors();
    }
  }

  Future<void> _delete(String id) async {
    try {
      await doctorProvider.deleteDoctor(id);
    } catch (error) {
      showErrorSnackbar(context, error);
    } finally {
      _loadDoctors();
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
              'Manajemen Dokter',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola data dokter dengan mudah',
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

  Widget _buildSearchAndAddSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteConstant.admin_adminDoctorAddFormView,
                  ).then((_) async {
                    await _loadDoctors();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            onPressed: doctorProvider.metaModel.currentPage > 1 ? _previousPage : null,
            isEnabled: doctorProvider.metaModel.currentPage > 1,
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
                    'Halaman ${doctorProvider.metaModel.currentPage}',
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
            onPressed: doctorProvider.metaModel.currentPage < doctorProvider.metaModel.lastPage
                ? _nextPage
                : null,
            isEnabled: doctorProvider.metaModel.currentPage < doctorProvider.metaModel.lastPage,
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

  Widget _buildDoctorsList() {
    if (doctorProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data dokter...'),
          ],
        ),
      );
    }

    if (doctorProvider.doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data dokter',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan dokter pertama Anda',
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
        itemCount: doctorProvider.doctors.length,
        itemBuilder: (context, index) {
          final DoctorModel doctor = doctorProvider.doctors[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: DoctorCard(
              doctor: doctor,
              onDelete: doctor.id != null
                  ? () async {
                      await _delete(doctor.id!);
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
          _buildSearchAndAddSection(),
          Expanded(
            child: Consumer<DoctorProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    if (provider.doctors.isNotEmpty) _buildPaginationControls(),
                    Expanded(
                      child: _buildDoctorsList(),
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