import 'package:dio/dio.dart';
import 'package:docify/components/open_street_map_view.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/providers/appointment_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PatientAppointmentBookingView extends StatefulWidget {
  const PatientAppointmentBookingView({super.key});

  @override
  State<PatientAppointmentBookingView> createState() =>
      _PatientAppointmentBookingViewState();
}

class _PatientAppointmentBookingViewState
    extends State<PatientAppointmentBookingView> {
  DoctorModel? doctor;
  AppointmentProvider get appointmentProvider =>
      context.read<AppointmentProvider>();
  DateTime? pickedDateTime;
  bool _isLocaleInitialized = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _initializeLocale(); // Initialize locale first

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      setState(() {
        doctor = args as DoctorModel;
      });
    });
  }

  // Add this method to initialize Indonesian locale
  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _isLocaleInitialized = true;
    });
  }

  void _changeTime(TimeOfDay time) {
    try {
      if (pickedDateTime != null) {
        setState(() {
          pickedDateTime = DateTime(
            pickedDateTime!.year,
            pickedDateTime!.month,
            pickedDateTime!.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        throw Exception('Tanggal harus diisi terlebih dahulu!');
      }
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  void _changeDate(DateTime newDateTime) {
    if (pickedDateTime == null) {
      setState(() {
        pickedDateTime = DateTime(
          newDateTime.year,
          newDateTime.month,
          newDateTime.day,
        );
      });
    } else {
      setState(() {
        pickedDateTime = DateTime(
          newDateTime.year,
          newDateTime.month,
          newDateTime.day,
          pickedDateTime!.hour,
          pickedDateTime!.minute,
        );
      });
    }
  }

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Tanggal',
                  style: GoogleFonts.openSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  height: 350,
                  child: SfDateRangePicker(
                    backgroundColor: Colors.white,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      firstDayOfWeek: 1,
                    ),
                    selectionMode: DateRangePickerSelectionMode.single,
                    selectionShape: DateRangePickerSelectionShape.circle,
                    showActionButtons: true,
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onSubmit: (dateTime) {
                      if (dateTime != null) {
                        _changeDate((dateTime as DateTime));
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addAppointment() async {
    try {
      if (pickedDateTime == null) return;
      await appointmentProvider.addAppointment(
        pickedDateTime: pickedDateTime!,
        doctor: doctor!,
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstant.patient_homeView, (route) => false);
    } on DioException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    }
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
              ],
              Text(
                title,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method to format date safely
  String _formatDate(DateTime date) {
    if (!_isLocaleInitialized) {
      // Fallback to default format if locale not initialized
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  Widget _buildDateTimeSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_available,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Jadwal Janji Temu',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Date Selector
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        pickedDateTime != null
                            ? _formatDate(pickedDateTime!) // Use the safe format method
                            : 'Pilih tanggal',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: pickedDateTime != null
                              ? Colors.grey[800]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showDateRangePickerDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Pilih',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Time Selector
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        pickedDateTime != null && pickedDateTime!.hour != 0
                            ? DateFormat('HH:mm').format(pickedDateTime!)
                            : 'Pilih waktu',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: pickedDateTime != null && pickedDateTime!.hour != 0
                              ? Colors.grey[800]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            timePickerTheme: TimePickerThemeData(
                              backgroundColor: Colors.white,
                              hourMinuteShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      _changeTime(time);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Pilih',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Dokter',
          style: GoogleFonts.openSans(
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: doctor != null
          ? SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Profile Header
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: doctor!.foto != null && doctor!.foto!.isNotEmpty
                                ? Image.network(
                                    doctor!.foto!,
                                    fit: BoxFit.cover,
                                    width: 76,
                                    height: 76,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.white.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.white.withOpacity(0.1),
                                        child: Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.white.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor!.nama,
                                style: GoogleFonts.openSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                doctor!.spesialisasi,
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),

                  // Personal Information
                  _buildInfoCard(
                    title: 'Informasi Pribadi',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildInfoRow('Email', doctor!.email, Icons.email_outlined),
                        _buildInfoRow('Rumah Sakit', doctor!.rumahSakit, Icons.local_hospital_outlined),
                        _buildInfoRow('Nomor Telepon', doctor!.nomorTelepon, Icons.phone_outlined),
                      ],
                    ),
                  ),

                  // Biodata
                  _buildInfoCard(
                    title: 'Tentang Dokter',
                    icon: Icons.info_outline,
                    child: Text(
                      doctor!.biodata,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  // Location
                  _buildInfoCard(
                    title: 'Lokasi Praktik',
                    icon: Icons.location_on_outlined,
                    child: doctor?.lokasi != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: OpenStreetMapView(
                              height: size.height * 0.3,
                              latitude: doctor!.lokasi!.latitude,
                              longitude: doctor!.lokasi!.longitude,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_off,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Lokasi dokter belum diatur',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // Date Time Selector
                  _buildDateTimeSelector(),

                  SizedBox(height: 24),

                  // Book Appointment Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: pickedDateTime != null && pickedDateTime!.hour != 0
                          ? _addAppointment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: appointmentProvider.isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_available, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Buat Janji Temu',
                                  style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
    );
  }
}