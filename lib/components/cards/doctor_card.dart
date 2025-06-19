import 'package:docify/constants/route_constant.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onDelete,
  });

  final DoctorModel doctor;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final fotoUrl = doctor.foto;

    return Container(
      // FIXED: Removed horizontal margin to prevent overflow
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto dokter
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.grey[200],
            backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                ? NetworkImage(fotoUrl)
                : null,
            child: (fotoUrl == null || fotoUrl.isEmpty)
                ? const Icon(Icons.person, size: 36, color: Colors.blueGrey)
                : null,
          ),
          const SizedBox(width: 16),

          // Informasi dokter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.nama,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.biodata,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Tombol aksi - FIXED: Added proper wrapping for small screens
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstant.admin_doctorDetailView,
                            arguments: doctor,
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text("Detail"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: GoogleFonts.openSans(fontSize: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDocifyDialog(
                            context: context,
                            content: const Text('Apakah anda yakin ingin menghapus dokter ini?'),
                            confirmLabel: 'Hapus',
                            confirmColor: Colors.red,
                            cancelLabel: 'Batal',
                            onConfirm: onDelete,
                            onCancel: () => Navigator.pop(context),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text("Hapus"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: GoogleFonts.openSans(fontSize: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
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
    );
  }
}