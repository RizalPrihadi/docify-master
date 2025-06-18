import 'package:docify/constants/route_constant.dart';
import 'package:docify/models/appointment_model.dart';
import 'package:docify/providers/appointment_provider.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.role,
    required this.provider,
  });

  final AppointmentModel appointment;
  final UserRole role;
  final AppointmentProvider provider;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('HH:mm, dd MMM yyyy').format(widget.appointment.waktu);
    final isDokter = widget.role == UserRole.dokter;
    final nama = isDokter
        ? widget.appointment.patient?.nama ?? "Pasien"
        : widget.appointment.doctor?.nama ?? "Dokter";
    final fotoUrl = isDokter
        ? widget.appointment.patient?.foto
        : widget.appointment.doctor?.foto;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.grey[200],
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
            child: fotoUrl == null
                ? Icon(Icons.person, size: 36, color: Colors.blueGrey)
                : null,
          ),
          const SizedBox(width: 16),

          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama
                Text(
                  nama,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Tanggal & waktu
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Status janji temu
                if (!isDokter)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      capitalize(widget.appointment.status.name),
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Tombol detail
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        isDokter
                            ? RouteConstant.doctor_appointmentDetailView
                            : RouteConstant.patient_appointmentDetailView,
                        arguments: widget.appointment,
                      ).then((_) {
                        widget.provider.getAllAppointments();
                      });
                    },
                    icon: Icon(Icons.info_outline),
                    label: Text("Detail"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: GoogleFonts.openSans(fontSize: 14),
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
}
