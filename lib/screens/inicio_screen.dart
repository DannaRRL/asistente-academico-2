
import 'package:flutter/material.dart';
import '../widgets/fondo_ondas.dart';
import 'horario_screen.dart';
import 'import_horario_screen.dart';

const morado = Color(0xFF7048DB);
const tinta = Color(0xFF29204F);
const lavanda = Color(0xFFEDE5FF);

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int tab = 0;
  int dia = 0;

  final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];

  final materias = [
    (
      'Programación',
      '08:00 - 10:00',
      Icons.computer,
      Color(0xFF8056E8),
      Color(0xFFEDE6FF)
    ),
    (
      'Matemáticas',
      '10:00 - 12:00',
      Icons.calculate,
      Color(0xFF1AAE89),
      Color(0xFFE1F7F0)
    ),
    (
      'Bases de Datos',
      '12:00 - 14:00',
      Icons.storage,
      Color(0xFFFFB41F),
      Color(0xFFFFF4D8)
    ),
  ];

  void importar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ImportarHorarioScreen(),
      ),
    );
  }

  void horarioReal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HorarioScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      body: FondoOndas(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: tab,
                      children: [
                        inicio(),
                        horario(),
                        examenes(),
                        ajustes(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(
                      15, 0, 15, 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x307048DB),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NavigationBar(
                      height: 70,
                      backgroundColor: Colors.white,
                      indicatorColor: lavanda,
                      selectedIndex: tab,
                      onDestinationSelected: (i) {
                        setState(() => tab = i);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(
                            Icons.home_rounded,
                            color: morado,
                          ),
                          label: 'Inicio',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.calendar_month_outlined,
                          ),
                          selectedIcon: Icon(
                            Icons.calendar_month,
                            color: morado,
                          ),
                          label: 'Horario',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.description_outlined,
                          ),
                          selectedIcon: Icon(
                            Icons.description,
                            color: morado,
                          ),
                          label: 'Exámenes',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.settings_outlined,
                          ),
                          selectedIcon: Icon(
                            Icons.settings,
                            color: morado,
                          ),
                          label: 'Ajustes',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // COMPONENTES DEL DISEÑO

  Widget titulo(
    String texto, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: tinta,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget tarjeta({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x207048DB),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget icono(
    IconData icon,
    Color color, {
    double size = 46,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.white, .25)!,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * .52,
      ),
    );
  }

  // PANTALLA INICIO

  Widget inicio() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola! 👋',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Organiza tu día y alcanza tus metas ✨',
                    style: TextStyle(
                      color: Color(0xFFF4EFFF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => setState(() => tab = 3),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFFE8DEFF),
                  child: Icon(
                    Icons.person_rounded,
                    color: morado,
                    size: 27,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 45),

        // Próxima clase
        tarjeta(
          color: const Color(0xFFF1EBFF),
          child: Column(
            children: [
              Row(
                children: [
                  icono(
                    Icons.calendar_month,
                    morado,
                    size: 55,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRÓXIMA CLASE',
                          style: TextStyle(
                            fontSize: 11,
                            color: morado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Programación',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: tinta,
                          ),
                        ),
                        Text(
                          'Hoy · 8:00 AM',
                          style: TextStyle(
                            fontSize: 12,
                            color: tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: morado,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 17,
                      color: morado,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recordatorio de próxima clase',
                        style: TextStyle(
                          color: morado,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Tus clases de hoy',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: tinta,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => tab = 1),
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...materias.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: tarjeta(
              child: Row(
                children: [
                  icono(m.$3, m.$4, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.$1,
                          style: const TextStyle(
                            color: tinta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF81799C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: morado,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),
        const Text(
          'Próximos eventos',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: tinta,
          ),
        ),
        const SizedBox(height: 14),
        tarjeta(
          color: const Color(0xFFEDE5FF),
          child: Row(
            children: [
              icono(
                Icons.description_rounded,
                morado,
                size: 52,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo examen',
                      style: TextStyle(
                        fontSize: 12,
                        color: morado,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Bases de Datos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tinta,
                      ),
                    ),
                    Text(
                      '25 de octubre · 10:00 AM',
                      style: TextStyle(
                        fontSize: 12,
                        color: tinta,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PANTALLA HORARIO

  Widget horario() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            20, 32, 20, 100,
          ),
          children: [
            const Text(
              'Organiza tus clases ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mi horario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 55),

            tarjeta(
              child: Column(
                children: [
                  const Text(
                    'Selecciona un día',
                    style: TextStyle(
                      color: tinta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        dias.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(
                            right: 6,
                          ),
                          child: ChoiceChip(
                            label: Text(dias[i]),
                            selected: dia == i,
                            selectedColor: morado,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: dia == i
                                  ? Colors.white
                                  : tinta,
                            ),
                            onSelected: (_) {
                              setState(() => dia = i);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            titulo(
              [
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
              ][dia],
            ),

            if (dia == 0)
              ...materias.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: tarjeta(
                    color: m.$5,
                    child: Row(
                      children: [
                        icono(m.$3, m.$4, size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.$2,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: tinta,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                m.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tinta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: morado,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              tarjeta(
                child: const Text(
                  'Consulta tus clases guardadas para este día.',
                  style: TextStyle(color: tinta),
                ),
              ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: horarioReal,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Ver horario guardado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: morado,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(17),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: importar,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Importar horario'),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: morado,
            foregroundColor: Colors.white,
            onPressed: importar,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // PANTALLA EXÁMENES

  Widget examenes() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
      children: [
        const Text(
          'Prepárate para tus metas ✨',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mis exámenes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 55),

        tarjeta(
          color: const Color(0xFFF1EBFF),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: morado,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Organiza tus evaluaciones y estudia a tiempo.',
                  style: TextStyle(
                    color: tinta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        titulo(
          'Próximos exámenes',
          trailing: IconButton.filled(
            onPressed: agregarExamen,
            style: IconButton.styleFrom(
              backgroundColor: morado,
            ),
            icon: const Icon(Icons.add),
          ),
        ),

        examen(
          'Bases de Datos',
          '25 de octubre · 10:00 AM',
          const Color(0xFF8A5CF0),
          Icons.storage,
        ),
        examen(
          'Programación',
          '30 de octubre · 08:00 AM',
          const Color(0xFF4A92F4),
          Icons.computer,
        ),
        examen(
          'Matemáticas',
          '5 de noviembre · 11:00 AM',
          const Color(0xFF20B48D),
          Icons.calculate,
        ),
      ],
    );
  }

  Widget examen(
    String nombre,
    String fecha,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: tarjeta(
        child: Row(
          children: [
            icono(icon, color, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tinta,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF81799C),
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Ejemplo de recordatorio',
                    style: TextStyle(
                      color: morado,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              color: morado,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  void agregarExamen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9F7FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            28,
            22,
            MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo examen ✨',
                style: TextStyle(
                  fontSize: 23,
                  color: tinta,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Materia',
                  prefixIcon: Icon(Icons.book_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha y hora',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El guardado de exámenes aún no está conectado.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Guardar examen'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // PANTALLA AJUSTES

  Widget ajustes() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
      children: [
        const Text(
          'Personaliza tu experiencia ✨',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 55),

        tarjeta(
          color: const Color(0xFFF1EBFF),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: morado,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontSize: 18,
                        color: tinta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Asistente Académico',
                      style: TextStyle(
                        color: Color(0xFF81799C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        titulo('Preferencias'),

        opcion(
          Icons.person_outline,
          'Mi cuenta',
          'Información personal',
        ),
        opcion(
          Icons.notifications_outlined,
          'Notificaciones',
          'Avisos y recordatorios',
        ),
        opcion(
          Icons.watch_outlined,
          'Smartwatch',
          'Conectar con GloryFit',
        ),
        opcion(
          Icons.info_outline,
          'Acerca de',
          'Información de la aplicación',
        ),
        opcion(
          Icons.logout,
          'Cerrar sesión',
          'Salir de la cuenta',
        ),
      ],
    );
  }

  Widget opcion(
    IconData icon,
    String nombre,
    String detalle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(nombre),
              content: const Text(
                'Esta sección todavía no está conectada.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        },
        child: tarjeta(
          child: Row(
            children: [
              icono(icon, morado, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        color: tinta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF81799C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: morado,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
