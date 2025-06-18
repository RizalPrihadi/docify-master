import 'package:docify/components/cards/appointment_card.dart';
import 'package:docify/models/appointment_model.dart';
import 'package:docify/providers/appointment_provider.dart';
import 'package:docify/utilities/appointment_status.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DoctorAppointmentManagementView extends StatefulWidget {
  DoctorAppointmentManagementView({super.key});

  @override
  State<DoctorAppointmentManagementView> createState() =>
      _DoctorAppointmentManagementViewState();
}

class _DoctorAppointmentManagementViewState
    extends State<DoctorAppointmentManagementView>
    with SingleTickerProviderStateMixin {
  AppointmentProvider get appointmentProvider =>
      context.read<AppointmentProvider>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDateRangePickerDialog() {
    final int tabIndex = _tabController.index;
    String? status;
    switch (tabIndex) {
      case 0:
        status = 'semua';
        break;
      case 1:
        status = 'diterima';
        break;
      case 2:
        status = 'dibatalkan';
        break;
      case 3:
        status = 'selesai';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.date_range,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Pilih Rentang Tanggal',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  height: 350,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SfDateRangePicker(
                    backgroundColor: Colors.transparent,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      firstDayOfWeek: 1,
                    ),
                    selectionMode: DateRangePickerSelectionMode.range,
                    selectionShape: DateRangePickerSelectionShape.rectangle,
                    showActionButtons: true,
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onSubmit: (object) {
                      if (object != null) {
                        appointmentProvider.sortAttendancesByDate(
                          (object as PickerDateRange),
                          status,
                        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'SEMUA'),
              Tab(text: AppointmentStatus.diterima.name.toUpperCase()),
              Tab(text: AppointmentStatus.dibatalkan.name.toUpperCase()),
              Tab(text: AppointmentStatus.selesai.name.toUpperCase()),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24, 24.0, 0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _showDateRangePickerDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          icon: Icon(Icons.filter_list, size: 20),
                          label: Text(
                            'Filter Tanggal',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          appointmentProvider.getAllAppointments();
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AppointmentList(),
                    AppointmentList(status: AppointmentStatus.diterima.name),
                    AppointmentList(status: AppointmentStatus.dibatalkan.name),
                    AppointmentList(status: AppointmentStatus.selesai.name),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentList extends StatefulWidget {
  const AppointmentList({super.key, this.status});

  final String? status;

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  AppointmentProvider get appointmentProvider =>
      context.read<AppointmentProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments({
    DateTime? startDate,
    DateTime? endDate,
    int? perPage,
    int? page,
  }) async {
    if (!mounted) return;
    try {
      await appointmentProvider.getAllAppointments(
        startDate: startDate,
        endDate: endDate,
        perPage: perPage ?? 20,
        page: page ?? 1,
        status: widget.status,
      );
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> _nextPage() async {
    if (appointmentProvider.metaModel.currentPage <
        appointmentProvider.metaModel.lastPage) {
      await appointmentProvider.getAllAppointments(
        perPage: 10,
        page: appointmentProvider.metaModel.currentPage + 1,
      );
    }
  }

  Future<void> _previousPage() async {
    if (appointmentProvider.metaModel.currentPage > 1) {
      await appointmentProvider.getAllAppointments(
        perPage: 10,
        page: appointmentProvider.metaModel.currentPage - 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        if (appointmentProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        } else if (appointmentProvider.appointments.isNotEmpty) {
          return Column(
            children: [
              if (appointmentProvider.appointments.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: appointmentProvider.metaModel.currentPage > 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: appointmentProvider.metaModel.currentPage > 1
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: IconButton(
                          onPressed: appointmentProvider.metaModel.currentPage > 1
                              ? _previousPage
                              : null,
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.all(16),
                            foregroundColor: appointmentProvider.metaModel.currentPage > 1
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Halaman ${appointmentProvider.metaModel.currentPage}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: appointmentProvider.metaModel.currentPage <
                                  appointmentProvider.metaModel.lastPage
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: appointmentProvider.metaModel.currentPage <
                                  appointmentProvider.metaModel.lastPage
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: IconButton(
                          onPressed: appointmentProvider.metaModel.currentPage <
                                  appointmentProvider.metaModel.lastPage
                              ? _nextPage
                              : null,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.all(16),
                            foregroundColor: appointmentProvider.metaModel.currentPage <
                                    appointmentProvider.metaModel.lastPage
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: appointmentProvider.appointments.length,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    final AppointmentModel appointment =
                        appointmentProvider.appointments[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppointmentCard(
                        appointment: appointment,
                        role: appointmentProvider.authProvider.role,
                        provider: appointmentProvider,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 16);
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Tidak ada data',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada appointment yang tersedia',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}