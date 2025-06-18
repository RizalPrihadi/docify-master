import 'package:docify/constants/color_constant.dart';
import 'package:docify/constants/route_constant.dart';
import 'package:docify/providers/appointment_provider.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/providers/doctor_provider.dart';
import 'package:docify/providers/patient_provider.dart';
import 'package:docify/services/appointment_service.dart';
import 'package:docify/services/auth_service.dart';
import 'package:docify/services/doctor_service.dart';
import 'package:docify/services/patient_service.dart';
import 'package:docify/views/admin/admin_doctor_add_form_view.dart';
import 'package:docify/views/admin/admin_doctor_detail_view.dart';
import 'package:docify/views/admin/admin_home_view.dart';
import 'package:docify/views/admin/admin_patient_detail_view.dart';
import 'package:docify/views/auth/login_view.dart';
import 'package:docify/views/auth/register_view.dart';
import 'package:docify/views/auth/splash_view.dart';
import 'package:docify/views/doctor/doctor_appointment_detail_view.dart';
import 'package:docify/views/doctor/doctor_appointment_management_view.dart';
import 'package:docify/views/doctor/doctor_change_location.dart';
import 'package:docify/views/doctor/doctor_home_view.dart';
import 'package:docify/views/doctor/doctor_medical_record_add_form.dart';
import 'package:docify/views/patient/patient_appointment_booking_view.dart';
import 'package:docify/views/patient/patient_appointment_detail_view.dart';
import 'package:docify/views/patient/patient_doctor_list_view.dart';
import 'package:docify/views/patient/patient_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DoctorProvider>(
          create:
              (context) => DoctorProvider(
                DoctorService(),
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update:
              (context, authProvider, previous) =>
                  DoctorProvider(DoctorService(), authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PatientProvider>(
          create:
              (context) => PatientProvider(
                PatientService(),
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update:
              (context, authProvider, previous) =>
                  PatientProvider(PatientService(), authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
          create:
              (context) => AppointmentProvider(
                AppointmentService(),
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update:
              (context, authProvider, previous) =>
                  AppointmentProvider(AppointmentService(), authProvider),
        ),
      ],
      child: MyApp(),
    ),
  );
}

final ThemeData appTheme = ThemeData(
  primaryColor: ColorConstant.primaryColor,
  colorScheme: ColorScheme(
    primary: ColorConstant.primaryColor,
    primaryContainer: ColorConstant.primaryLightColor,
    secondary: ColorConstant.secondaryColor,
    secondaryContainer: ColorConstant.secondaryColor.withOpacity(0.7),
    background: ColorConstant.backgroundColor,
    surface: ColorConstant.surfaceColor,
    error: ColorConstant.errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.white,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: RouteConstant.splashView,
      routes: {
        RouteConstant.splashView: (context) => SplashView(),
        RouteConstant.registerView: (context) => RegisterView(),
        RouteConstant.loginView: (context) => LoginView(),
        RouteConstant.admin_homeView:
            (context) => AdminHomeView(),
        RouteConstant.admin_doctorDetailView:
            (context) => AdminDoctorDetailView(),
        RouteConstant.admin_patientDetailView:
            (context) => AdminPatientDetailView(),
        RouteConstant.admin_adminDoctorAddFormView:
            (context) => AdminDoctorAddFormView(),
        RouteConstant.doctor_homeView:
            (context) => DoctorHomeView(),
        RouteConstant.doctor_appointmentManagementView:
            (context) => DoctorAppointmentManagementView(),
        RouteConstant.doctor_appointmentDetailView:
            (context) => DoctorAppointmentDetailView(),
        RouteConstant.doctor_medicalRecordAddFormView:
            (context) => DoctorMedicalRecordAddFormView(),
        RouteConstant.doctor_changeLocationView:
            (context) => DoctorChangeLocationView(),
        RouteConstant.patient_homeView:
            (context) => PatientHomeView(),
        RouteConstant.patient_appointmentDetailView:
            (context) => PatientAppointmentDetailView(),
        RouteConstant.patient_appointmentBookingView:
            (context) => PatientAppointmentBookingView(),
        RouteConstant.patient_doctorListView:
            (context) => PatientDoctorListView(),
      },
    );
  }
}
