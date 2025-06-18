import 'package:docify/components/cards/doctor_booking_card.dart';
import 'package:docify/components/text_fields/search_text_field.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/providers/doctor_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientDoctorListView extends StatefulWidget {
  const PatientDoctorListView({super.key});

  @override
  State<PatientDoctorListView> createState() =>
      _PatientDoctorListViewState();
}

class _PatientDoctorListViewState extends State<PatientDoctorListView>
    with TickerProviderStateMixin {
  DoctorProvider get doctorProvider => context.read<DoctorProvider>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctors();
      _fadeController.forward();
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

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0A0E1A) 
          : const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      // Tambahkan ini untuk mengatasi keyboard overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B).withOpacity(0.9),
                      const Color(0xFF0F172A).withOpacity(0.9),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      const Color(0xFFF1F5F9).withOpacity(0.9),
                    ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
            ],
          ).createShader(bounds),
          child: Text(
            'Daftar Dokter',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0A0E1A),
                      const Color(0xFF1E293B).withOpacity(0.3),
                      const Color(0xFF0A0E1A),
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      Colors.white.withOpacity(0.5),
                      const Color(0xFFF8FAFC),
                    ],
            ),
          ),
          child: SafeArea(
            child: Consumer<DoctorProvider>(
              builder: (context, provider, child) {
                return CustomScrollView(
                  slivers: [
                    // Header Section dengan Search
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 16, 20.0, 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E293B),
                                      const Color(0xFF334155),
                                    ]
                                  : [
                                      Colors.white,
                                      const Color(0xFFF8FAFC),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.primary.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.medical_services_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Temukan Dokter Terbaik',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cari dan booking jadwal konsultasi',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SearchTextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  _search(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Pagination Controls
                    if (provider.doctors.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPaginationButton(
                                  icon: Icons.chevron_left_rounded,
                                  onPressed: provider.metaModel.currentPage > 1
                                      ? _previousPage
                                      : null,
                                  colorScheme: colorScheme,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary.withOpacity(0.1),
                                        colorScheme.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Halaman ${provider.metaModel.currentPage}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                _buildPaginationButton(
                                  icon: Icons.chevron_right_rounded,
                                  onPressed: provider.metaModel.currentPage <
                                          provider.metaModel.lastPage
                                      ? _nextPage
                                      : null,
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    
                    // Content Section
                    provider.isLoading
                        ? SliverFillRemaining(
                            child: _buildLoadingState(colorScheme),
                          )
                        : provider.doctors.isNotEmpty
                            ? SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (index >= provider.doctors.length) {
                                        return const SizedBox.shrink();
                                      }
                                      
                                      final DoctorModel doctor = provider.doctors[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: DoctorBookingCard(doctor: doctor),
                                      );
                                    },
                                    childCount: provider.doctors.length,
                                  ),
                                ),
                              )
                            : SliverFillRemaining(
                                child: _buildEmptyState(colorScheme),
                              ),
                    
                    // Bottom padding untuk keyboard
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              )
            : null,
        color: onPressed == null ? colorScheme.outline.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null 
              ? Colors.white 
              : colorScheme.outline.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memuat data dokter...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada data dokter',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian atau\nrefresh halaman ini',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}