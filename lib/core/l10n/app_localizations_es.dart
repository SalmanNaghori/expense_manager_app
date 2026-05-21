// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gestor de Gastos Antigravedad';

  @override
  String get dashboard => 'Tablero';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get expense => 'Gasto';

  @override
  String get income => 'Ingreso';

  @override
  String get amount => 'Monto';

  @override
  String get bankAccount => 'Cuenta Bancaria';

  @override
  String get category => 'Categoría';

  @override
  String get tags => 'Etiquetas';

  @override
  String get date => 'Fecha';

  @override
  String get settings => 'Ajustes';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get currency => 'Moneda';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get importSuccess => '¡Datos importados con éxito!';

  @override
  String get importError =>
      'Error al importar datos. Por favor, compruebe el archivo.';

  @override
  String get standardModeMsg => 'Modo Estándar: El gasto reducirá el saldo.';

  @override
  String get antigravityActive => '⚡ ESTADO DE ANTIGRAVEDAD: ACTIVO';

  @override
  String antigravityWarning(String amount) {
    return 'Advertencia: Este gasto SUMARÁ $amount a su saldo.';
  }

  @override
  String get forceUpdateTitle => 'Actualización Requerida';

  @override
  String get forceUpdateMessage =>
      'Una nueva versión más segura de la aplicación está disponible. Por favor, actualice para continuar usando la aplicación.';

  @override
  String get updateButton => 'Actualizar Ahora';

  @override
  String get aa => 'Modo Antigravedad';
}
