// ignore_for_file: unnecessary_null_comparison

import 'package:docify/components/dropdowns/plain_dropdown.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/models/appointment_model.dart';
import 'package:docify/providers/appointment_provider.dart';
import 'package:docify/utilities/appointment_status.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorAppointmentDetailView extends StatefulWidget {
  const DoctorAppointmentDetailView({super.key});

  @override
  State<DoctorAppointmentDetailView> createState() =>
      _DoctorAppointmentDetailViewState();
}

class _DoctorAppointmentDetailViewState
    extends State<DoctorAppointmentDetailView> {
  AppointmentProvider get appointmentProvider =>
      context.read<AppointmentProvider>();
  AppointmentModel? appointment;
  String? selectedStatus;
  bool onUpdateStatus = false;
  bool _localeInitialized = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _initializeLocale(); // Initialize locale first

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      setState(() {
        appointment = args as AppointmentModel;
        selectedStatus = capitalize(appointment!.status.name);
      });
    });
  }

  // Add this method to initialize Indonesian locale
  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id', null);
    setState(() {
      _localeInitialized = true;
    });
  }

  Future<void> _deleteMedicalRecord() async {
    if (appointment?.medicalRecord == null) return;
    try {
      await appointmentProvider.deleteMedicalRecord(appointment!);
    } catch (e) {
      showErrorSnackbar(context, e);
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateStatus() async {
    try {
      AppointmentStatus parsedStatus = AppointmentStatus.values.firstWhere(
        (e) => e.name == selectedStatus?.toLowerCase(),
        orElse: () => AppointmentStatus.belum,
      );

      await appointmentProvider.updateStatus(appointment!, parsedStatus);
    } catch (e) {
      showErrorSnackbar(context, e);
    } finally {
      setState(() {
        onUpdateStatus = false;
      });
      Navigator.of(context).pop();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum':
        return Colors.orange;
      case 'diterima':
        return Colors.blue;
      case 'dibatalkan':
        return Colors.red;
      case 'diperiksa':
        return Colors.purple;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'belum':
        return Icons.schedule;
      case 'diterima':
        return Icons.check_circle;
      case 'dibatalkan':
        return Icons.cancel;
      case 'diperiksa':
        return Icons.medical_services;
      case 'selesai':
        return Icons.task_alt;
      default:
        return Icons.help;
    }
  }

  // Helper method to format date safely
  String _formatDate(DateTime date) {
    if (!_localeInitialized) {
      // Fallback to basic formatting if locale not ready
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Janji Temu',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: appointment != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today,
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
                                    'Informasi Janji Temu',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(appointment!.waktu), // Use the safe formatting method
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // Doctor Profile Picture
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: appointment!.doctor!.foto != null && 
                                       appointment!.doctor!.foto!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: Uri.encodeFull(appointment!.doctor!.foto!),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: Icon(
                                            Icons.person_outline,
                                            color: Colors.white.withOpacity(0.7),
                                            size: 30,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: Icon(
                                            Icons.person_outline,
                                            color: Colors.white.withOpacity(0.7),
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.white.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person_outline,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 30,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dokter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    appointment!.doctor!.nama,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (appointment!.doctor!.spesialisasi != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      appointment!.doctor!.spesialisasi,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Status Section
                  if (selectedStatus != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timeline,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Status Appointment',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(selectedStatus!).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(selectedStatus!).withOpacity(0.3),
                                    ),
                                  ),
                                  child: PlainDropdown<String>(
                                    label: '',
                                    items: [
                                      capitalize(AppointmentStatus.belum.name),
                                      capitalize(AppointmentStatus.diterima.name),
                                      capitalize(AppointmentStatus.dibatalkan.name),
                                      capitalize(AppointmentStatus.diperiksa.name),
                                      capitalize(AppointmentStatus.selesai.name),
                                    ],
                                    value: selectedStatus,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStatus = value;
                                        onUpdateStatus = true;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (onUpdateStatus) ...[
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _updateStatus,
                                  icon: const Icon(Icons.update, size: 18),
                                  label: const Text('Update'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(selectedStatus!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(selectedStatus!),
                                  color: _getStatusColor(selectedStatus!),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: $selectedStatus',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(selectedStatus!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Medical Record Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_information,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Rekam Medis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            appointment?.medicalRecord == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue, Colors.blue.shade400],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        final updatedAppointment =
                                            await Navigator.pushNamed(
                                          context,
                                          RouteConstant.doctor_medicalRecordAddFormView,
                                          arguments: appointment,
                                        );
                                        if (updatedAppointment != null) {
                                          setState(() {
                                            appointment = (updatedAppointment as AppointmentModel);
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.add, color: Colors.white),
                                      tooltip: 'Tambah Rekam Medis',
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.red, Colors.red.shade400],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        showDocifyDialog(
                                          context: context,
                                          content: const Text('Apakah anda yakin ingin menghapus rekam medis?'),
                                          confirmLabel: 'Hapus',
                                          confirmColor: Colors.red,
                                          cancelLabel: 'Batal',
                                          onConfirm: _deleteMedicalRecord,
                                          onCancel: () => Navigator.pop(context),
                                        );
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      tooltip: 'Hapus Rekam Medis',
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        appointment?.medicalRecord != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Catatan Dokter',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          appointment!.medicalRecord!.catatan,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Lampiran Dokumen',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: size.height * 0.4,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: Uri.encodeFull(
                                          appointment!.medicalRecord!.file,
                                        ),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[100],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Gagal memuat gambar',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.medical_information_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Belum ada rekam medis',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Tambahkan rekam medis untuk appointment ini',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}