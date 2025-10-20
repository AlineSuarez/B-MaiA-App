// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'B-MaiA';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get back => 'Volver';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get finish => 'Finalizar';

  @override
  String get skip => 'Omitir';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get more => 'Más';

  @override
  String get less => 'Menos';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get welcome => 'Bienvenido';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String welcomeBack(String name) {
    return '¡Bienvenida $name!';
  }

  @override
  String get signInToContinue => 'Inicia sesión para continuar con B-MaiA';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginSuccess => '¡Inicio de sesión exitoso!';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get register => 'Regístrate';

  @override
  String get registerNow => 'Regístrate ahora';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get joinBMaia => 'Únete a B-MaiA y comienza tu experiencia';

  @override
  String get registerSuccess => '¡Registro exitoso!';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailPlaceholder => 'Ingresa tu correo';

  @override
  String get emailHint => 'ejemplo@correo.com';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordPlaceholder => 'Ingresa tu contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmPasswordPlaceholder => 'Confirma tu contraseña';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get firstName => 'Nombres';

  @override
  String get lastName => 'Apellidos';

  @override
  String get phone => 'Teléfono';

  @override
  String get address => 'Dirección';

  @override
  String get region => 'Región';

  @override
  String get commune => 'Comuna';

  @override
  String get rut => 'RUT';

  @override
  String get businessName => 'Razón Social';

  @override
  String get sagRegistry => 'N° de Registro de Apicultor/a en el SAG';

  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get requiredFields => 'Por favor, completa todos los campos';

  @override
  String get invalidEmail => 'Ingresa un correo electrónico válido';

  @override
  String get invalidEmailFormat =>
      'Por favor, ingresa un correo electrónico válido';

  @override
  String passwordTooShort(int count) {
    return 'La contraseña debe tener al menos $count caracteres';
  }

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String nameTooShort(int count) {
    return 'El nombre debe tener al menos $count caracteres';
  }

  @override
  String get acceptTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu correo y te enviaremos instrucciones para recuperarla';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get sendInstructions => 'Enviar Instrucciones';

  @override
  String get emailSent => '¡Correo Enviado!';

  @override
  String get emailSentMessage =>
      'Revisa tu correo para restablecer tu contraseña';

  @override
  String get emailSentTitle => 'Revisa tu correo';

  @override
  String get checkEmailMessage =>
      'Te hemos enviado instrucciones para restablecer tu contraseña';

  @override
  String get emailSentTo => 'Hemos enviado un correo a:';

  @override
  String get resendEmail => 'Reenviar Correo';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get enterEmail => 'Por favor ingresa tu correo';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get orRegisterWith => 'o regístrate con';

  @override
  String get googleTokenError =>
      'No se pudo obtener el token de autenticación de Google';

  @override
  String get termsAndConditions => 'términos y condiciones';

  @override
  String acceptTermsMessage(String terms) {
    return 'Acepto los $terms';
  }

  @override
  String get home => 'Inicio';

  @override
  String get intelligentAssistant => 'Asistente inteligente';

  @override
  String get newConversation => 'Nueva conversación';

  @override
  String get history => 'Historial';

  @override
  String get clearChat => 'Limpiar chat';

  @override
  String get clearChatConfirm =>
      '¿Estás seguro de que deseas eliminar todos los mensajes de esta conversación?';

  @override
  String get clear => 'Limpiar';

  @override
  String get messageInputPlaceholder => 'Escribe tu mensaje aquí...';

  @override
  String get typingIndicator => 'B-MaiA está escribiendo...';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get helloBMaia => '¡Hola! Soy B-MaiA';

  @override
  String get aiAssistantDescription =>
      'Tu asistente de inteligencia artificial. Pregúntame lo que necesites, estoy aquí para ayudarte.';

  @override
  String get writeFirstQuestion => 'Escribe tu primera pregunta';

  @override
  String get trySaying => 'Prueba preguntando:';

  @override
  String get howCanYouHelp => '¿Cómo puedes ayudarme?';

  @override
  String get helpWithProgramming => 'Ayúdame con programación';

  @override
  String get explainConcept => 'Explícame un concepto';

  @override
  String get helpMeWrite => 'Ayúdame a escribir';

  @override
  String get settings => 'Configuración';

  @override
  String get appearance => 'Apariencia';

  @override
  String get application => 'Aplicación';

  @override
  String get security => 'Seguridad';

  @override
  String get preferences => 'Preferencias';

  @override
  String get account => 'Cuenta';

  @override
  String get subscription => 'Suscripción';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Seguir sistema';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get systemThemeSubtitle => 'Seguir sistema';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get lightModeSubtitle => 'Forzar modo claro';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkModeSubtitle => 'Forzar modo oscuro';

  @override
  String get useSystemTheme => 'Usar el tema del sistema operativo';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma de la app';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Preferencias de avisos';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get notificationSettings => 'Configuración de notificaciones';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get helpSupportSubtitle => 'Centro de ayuda y contacto';

  @override
  String get helpCenter => 'Centro de ayuda';

  @override
  String get contactSupport => 'Contactar soporte';

  @override
  String get faq => 'Preguntas frecuentes';

  @override
  String get documentation => 'Documentación';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutSubtitle => 'Información de la aplicación';

  @override
  String get version => 'Versión';

  @override
  String get build => 'Compilación';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get licenses => 'Licencias';

  @override
  String get profile => 'Mi Perfil';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get location => 'Ubicación';

  @override
  String get legalData => 'Datos legales';

  @override
  String get legalDataRut => 'RUT del usuario o Representante Legal';

  @override
  String get legalDataBusinessName => 'Razón Social';

  @override
  String get sagRegistryNumber => 'N° de Registro de Apicultor/a en el SAG';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get userId => 'ID de usuario';

  @override
  String get profilePicture => 'Foto de perfil';

  @override
  String get selectPhoto => 'Seleccionar foto';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de galería';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get photoSelected => 'Foto seleccionada (vista previa)';

  @override
  String get photoRemoved => 'Foto eliminada (vista previa)';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get changePasswordSubtitle => 'Actualiza tu contraseña';

  @override
  String get twoFactorAuth => 'Autenticación en dos pasos';

  @override
  String get twoFactorAuthSubtitle => 'Añade una capa extra de seguridad';

  @override
  String get securitySettings => 'Configuración de seguridad';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get languageSubtitle => 'Español';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get dataManagementSubtitle => 'Historial y almacenamiento';

  @override
  String get storageManagement => 'Gestión de almacenamiento';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get clearHistory => 'Limpiar historial';

  @override
  String get freePlan => 'Plan Gratuito';

  @override
  String get premiumPlan => 'Plan Premium';

  @override
  String get upgradePlan => 'Actualizar plan';

  @override
  String get upgradeForMore => 'Actualiza para más funciones';

  @override
  String get viewPremiumPlans => 'Ver planes Premium';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get billing => 'Facturación';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirm =>
      'Esta acción es irreversible. Se eliminarán todos tus datos y conversaciones.';

  @override
  String get accountDeleted => 'Cuenta eliminada';

  @override
  String get welcomeToBMaia => '¡Bienvenido a B-MaiA!';

  @override
  String get onboardingTitle1 => '¡Bienvenido a B-MaiA!';

  @override
  String get onboardingDesc1 =>
      'Descubre una nueva forma de gestionar tus proyectos con inteligencia artificial avanzada.';

  @override
  String get onboardingTitle2 => 'Tecnología Avanzada';

  @override
  String get onboardingDesc2 =>
      'Utilizamos las últimas innovaciones en IA para brindarte la mejor experiencia posible.';

  @override
  String get onboardingTitle3 => 'Experiencia Personalizada';

  @override
  String get onboardingDesc3 =>
      'Cada función está diseñada pensando en tus necesidades específicas y preferencias.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get viewIntroduction => 'Ver introducción';

  @override
  String get errorGeneric => 'Ha ocurrido un error';

  @override
  String get errorConnection => 'Error de conexión';

  @override
  String get errorTimeout => 'Tiempo de espera agotado';

  @override
  String get errorServer => 'Error del servidor';

  @override
  String get errorNotFound => 'No encontrado';

  @override
  String get errorUnauthorized => 'No autorizado';

  @override
  String get errorForbidden => 'Acceso denegado';

  @override
  String get errorTryAgain => 'Por favor, inténtalo de nuevo';

  @override
  String get errorImageSelection => 'Error al seleccionar la imagen';

  @override
  String get featureInDevelopment => 'Funcionalidad en desarrollo';

  @override
  String get successGeneric => 'Operación exitosa';

  @override
  String get successSaved => 'Guardado exitosamente';

  @override
  String get successUpdated => 'Actualizado exitosamente';

  @override
  String get successDeleted => 'Eliminado exitosamente';

  @override
  String get successSent => 'Enviado exitosamente';

  @override
  String get menu => 'Menú';

  @override
  String get chats => 'Conversaciones';

  @override
  String chatHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversaciones',
      one: '1 conversación',
      zero: 'Sin conversaciones',
    );
    return '$_temp0';
  }

  @override
  String get myAccount => 'Mi Cuenta';

  @override
  String get chat => 'Chat';

  @override
  String get message => 'Mensaje';

  @override
  String get messages => 'Mensajes';

  @override
  String get noMessages => 'No hay mensajes';

  @override
  String get typing => 'Escribiendo...';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Desconectado';

  @override
  String get lastSeen => 'Visto por última vez';

  @override
  String get readBy => 'Leído por';

  @override
  String get deliveredTo => 'Entregado a';

  @override
  String get sent => 'Enviado';

  @override
  String get received => 'Recibido';

  @override
  String get read => 'Leído';

  @override
  String get now => 'Ahora';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count minutos',
      one: 'Hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count horas',
      one: 'Hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get orWord => 'o';

  @override
  String get andWord => 'y';

  @override
  String get toWord => 'a';

  @override
  String get fromWord => 'de';

  @override
  String get inWord => 'en';

  @override
  String get atWord => 'en';

  @override
  String get onWord => 'el';

  @override
  String get byWord => 'por';

  @override
  String get withWord => 'con';

  @override
  String get withoutWord => 'sin';

  @override
  String get forWord => 'para';

  @override
  String get notAvailable => '—';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get betaLabel => 'Beta';

  @override
  String get newLabel => 'Nuevo';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 3 caracteres';
}
