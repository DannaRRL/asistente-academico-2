// Copiar a lib/prueba_firebase.dart en el proyecto Flutter.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> probarBaseDeDatos() async {
  // Activar previamente el proveedor Anonymous en Firebase Authentication.
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
  final firestore = FirebaseFirestore.instance;
  final perfil = firestore.collection('usuarios').doc(user.uid);
  final ahora = Timestamp.now();
  await perfil.set({
    'nombre': 'Estudiante de prueba', 'correo': user.email ?? '',
    'zonaHoraria': 'America/Mexico_City', 'creadoEn': ahora,
    'actualizadoEn': ahora,
  });
  final clase = await perfil.collection('horarios').add({
    'materia': 'Programación', 'dia': 1, 'horaInicio': '08:00',
    'horaFin': '10:00', 'color': '#6655EE', 'origen': 'manual',
    'creadoEn': ahora, 'actualizadoEn': ahora,
  });
  final guardada = await clase.get();
  assert(guardada.exists && guardada.data()?['materia'] == 'Programación');
  print('Lectura correcta: ${guardada.id} → ${guardada.data()?['materia']}');
  // Eliminar la clase de prueba cuando se haya comprobado en la consola.
}
