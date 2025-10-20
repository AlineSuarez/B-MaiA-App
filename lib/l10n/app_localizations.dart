import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'B-MaiA'**
  String get appName;

  /// Texto del indicador de carga
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// Etiqueta genérica de error
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// Mensaje genérico de éxito
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// Etiqueta del botón cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Etiqueta del botón aceptar
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// Etiqueta del botón guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Etiqueta del botón eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Etiqueta del botón editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Etiqueta del botón volver
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// Etiqueta del botón siguiente
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// Etiqueta del botón anterior
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get previous;

  /// Etiqueta del botón finalizar
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// Etiqueta del botón omitir
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// Etiqueta del botón reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Etiqueta del botón cerrar
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Placeholder del campo de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Etiqueta del botón filtrar
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// Etiqueta del botón ordenar
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Etiqueta de más opciones
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get more;

  /// Etiqueta de menos opciones
  ///
  /// In es, this message translates to:
  /// **'Menos'**
  String get less;

  /// Etiqueta de confirmación sí
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// Etiqueta de confirmación no
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// Mensaje de bienvenida general
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// Mensaje de bienvenida personalizado
  ///
  /// In es, this message translates to:
  /// **'Bienvenido, {name}'**
  String welcomeUser(String name);

  /// Mensaje de bienvenida de regreso
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenida {name}!'**
  String welcomeBack(String name);

  /// Subtítulo del mensaje de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar con B-MaiA'**
  String get signInToContinue;

  /// Etiqueta del botón de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// Mensaje de éxito al iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'¡Inicio de sesión exitoso!'**
  String get loginSuccess;

  /// Etiqueta del botón cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// Mensaje de confirmación de cierre de sesión
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get logoutConfirm;

  /// Etiqueta del botón de registro
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// Llamado a la acción de registro
  ///
  /// In es, this message translates to:
  /// **'Regístrate ahora'**
  String get registerNow;

  /// Título de crear cuenta
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccount;

  /// Subtítulo de registro
  ///
  /// In es, this message translates to:
  /// **'Únete a B-MaiA y comienza tu experiencia'**
  String get joinBMaia;

  /// Mensaje de éxito al registrarse
  ///
  /// In es, this message translates to:
  /// **'¡Registro exitoso!'**
  String get registerSuccess;

  /// Mensaje de ya tener cuenta
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// Mensaje de no tener cuenta
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// Etiqueta del enlace de iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// Etiqueta del enlace de registrarse
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get signUp;

  /// Etiqueta del campo de correo
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// Placeholder del campo de correo
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get emailPlaceholder;

  /// Sugerencia del campo de correo
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get emailHint;

  /// Etiqueta del campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Placeholder del campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get passwordPlaceholder;

  /// Etiqueta del campo confirmar contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// Placeholder del campo confirmar contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmPasswordPlaceholder;

  /// Etiqueta del campo nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// Etiqueta del campo contraseña actual
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get currentPassword;

  /// Etiqueta del campo nombre completo
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// Etiqueta del campo nombres
  ///
  /// In es, this message translates to:
  /// **'Nombres'**
  String get firstName;

  /// Etiqueta del campo apellidos
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get lastName;

  /// Etiqueta del campo teléfono
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// Etiqueta del campo dirección
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get address;

  /// Etiqueta del campo región
  ///
  /// In es, this message translates to:
  /// **'Región'**
  String get region;

  /// Etiqueta del campo comuna
  ///
  /// In es, this message translates to:
  /// **'Comuna'**
  String get commune;

  /// Etiqueta del campo RUT
  ///
  /// In es, this message translates to:
  /// **'RUT'**
  String get rut;

  /// Etiqueta del campo razón social
  ///
  /// In es, this message translates to:
  /// **'Razón Social'**
  String get businessName;

  /// Etiqueta del campo registro SAG
  ///
  /// In es, this message translates to:
  /// **'N° de Registro de Apicultor/a en el SAG'**
  String get sagRegistry;

  /// Mensaje de validación de campo requerido
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get requiredField;

  /// Mensaje de validación de todos los campos requeridos
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos'**
  String get requiredFields;

  /// Mensaje de validación de correo inválido
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo electrónico válido'**
  String get invalidEmail;

  /// Mensaje de validación de formato de correo inválido
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa un correo electrónico válido'**
  String get invalidEmailFormat;

  /// Mensaje de validación de contraseña muy corta
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {count} caracteres'**
  String passwordTooShort(int count);

  /// Mensaje de validación de contraseñas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordMismatch;

  /// Mensaje de validación de nombre muy corto
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos {count} caracteres'**
  String nameTooShort(int count);

  /// Mensaje de validación de aceptar términos
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get acceptTerms;

  /// Etiqueta del enlace de contraseña olvidada
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// Título de la pantalla de contraseña olvidada
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordTitle;

  /// Subtítulo de la pantalla de contraseña olvidada
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo y te enviaremos instrucciones para recuperarla'**
  String get forgotPasswordSubtitle;

  /// Etiqueta del botón restablecer contraseña
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get resetPassword;

  /// Etiqueta del botón enviar instrucciones
  ///
  /// In es, this message translates to:
  /// **'Enviar Instrucciones'**
  String get sendInstructions;

  /// Mensaje de confirmación de correo enviado
  ///
  /// In es, this message translates to:
  /// **'¡Correo Enviado!'**
  String get emailSent;

  /// Mensaje detallado de correo enviado
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo para restablecer tu contraseña'**
  String get emailSentMessage;

  /// Título de la pantalla de correo enviado
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get emailSentTitle;

  /// Mensaje de revisar correo
  ///
  /// In es, this message translates to:
  /// **'Te hemos enviado instrucciones para restablecer tu contraseña'**
  String get checkEmailMessage;

  /// Prefijo de correo enviado a
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un correo a:'**
  String get emailSentTo;

  /// Etiqueta del botón reenviar correo
  ///
  /// In es, this message translates to:
  /// **'Reenviar Correo'**
  String get resendEmail;

  /// Etiqueta del enlace volver al inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio de sesión'**
  String get backToLogin;

  /// Mensaje de validación de ingresar correo
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu correo'**
  String get enterEmail;

  /// Etiqueta del botón de inicio de sesión con Google
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// Separador de inicio de sesión alternativo
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get orContinueWith;

  /// Separador de registro alternativo
  ///
  /// In es, this message translates to:
  /// **'o regístrate con'**
  String get orRegisterWith;

  /// Mensaje de error de token de Google
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener el token de autenticación de Google'**
  String get googleTokenError;

  /// Texto del enlace de términos y condiciones
  ///
  /// In es, this message translates to:
  /// **'términos y condiciones'**
  String get termsAndConditions;

  /// Etiqueta del checkbox de aceptar términos
  ///
  /// In es, this message translates to:
  /// **'Acepto los {terms}'**
  String acceptTermsMessage(String terms);

  /// Título de la pantalla de inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// Etiqueta del asistente de IA
  ///
  /// In es, this message translates to:
  /// **'Asistente inteligente'**
  String get intelligentAssistant;

  /// Etiqueta del botón nueva conversación
  ///
  /// In es, this message translates to:
  /// **'Nueva conversación'**
  String get newConversation;

  /// Etiqueta de historial
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// Etiqueta del botón limpiar chat
  ///
  /// In es, this message translates to:
  /// **'Limpiar chat'**
  String get clearChat;

  /// Mensaje de confirmación de limpiar chat
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar todos los mensajes de esta conversación?'**
  String get clearChatConfirm;

  /// Etiqueta del botón limpiar
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// Placeholder del campo de entrada de mensaje
  ///
  /// In es, this message translates to:
  /// **'Escribe tu mensaje aquí...'**
  String get messageInputPlaceholder;

  /// Texto del indicador de escritura
  ///
  /// In es, this message translates to:
  /// **'B-MaiA está escribiendo...'**
  String get typingIndicator;

  /// Etiqueta del botón enviar mensaje
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get sendMessage;

  /// Mensaje de saludo de la IA
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy B-MaiA'**
  String get helloBMaia;

  /// Descripción del asistente de IA
  ///
  /// In es, this message translates to:
  /// **'Tu asistente de inteligencia artificial. Pregúntame lo que necesites, estoy aquí para ayudarte.'**
  String get aiAssistantDescription;

  /// Prompt de primera pregunta
  ///
  /// In es, this message translates to:
  /// **'Escribe tu primera pregunta'**
  String get writeFirstQuestion;

  /// Encabezado de sugerencias
  ///
  /// In es, this message translates to:
  /// **'Prueba preguntando:'**
  String get trySaying;

  /// Sugerencia 1
  ///
  /// In es, this message translates to:
  /// **'¿Cómo puedes ayudarme?'**
  String get howCanYouHelp;

  /// Sugerencia 2
  ///
  /// In es, this message translates to:
  /// **'Ayúdame con programación'**
  String get helpWithProgramming;

  /// Sugerencia 3
  ///
  /// In es, this message translates to:
  /// **'Explícame un concepto'**
  String get explainConcept;

  /// Sugerencia 4
  ///
  /// In es, this message translates to:
  /// **'Ayúdame a escribir'**
  String get helpMeWrite;

  /// Título de la pantalla de configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Título de la sección de apariencia
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// Título de la sección de aplicación
  ///
  /// In es, this message translates to:
  /// **'Aplicación'**
  String get application;

  /// Título de la sección de seguridad
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// Título de la sección de preferencias
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// Título de la sección de cuenta
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// Título de la sección de suscripción
  ///
  /// In es, this message translates to:
  /// **'Suscripción'**
  String get subscription;

  /// Etiqueta de configuración de tema
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Opción de tema claro
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Opción de tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// Opción de tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Seguir sistema'**
  String get themeSystem;

  /// Título del diálogo de selección de tema
  ///
  /// In es, this message translates to:
  /// **'Seleccionar tema'**
  String get selectTheme;

  /// Etiqueta de tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// Subtítulo de tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Seguir sistema'**
  String get systemThemeSubtitle;

  /// Etiqueta de modo claro
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get lightMode;

  /// Subtítulo de modo claro
  ///
  /// In es, this message translates to:
  /// **'Forzar modo claro'**
  String get lightModeSubtitle;

  /// Etiqueta de modo oscuro
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkMode;

  /// Subtítulo de modo oscuro
  ///
  /// In es, this message translates to:
  /// **'Forzar modo oscuro'**
  String get darkModeSubtitle;

  /// Opción de usar tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Usar el tema del sistema operativo'**
  String get useSystemTheme;

  /// Etiqueta de configuración de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Título del diálogo de selección de idioma
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma de la app'**
  String get selectLanguage;

  /// Opción de idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Opción de idioma inglés
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// Etiqueta de configuración de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// Subtítulo de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Preferencias de avisos'**
  String get notificationsSubtitle;

  /// Toggle de activar notificaciones
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get enableNotifications;

  /// Etiqueta de configuración de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Configuración de notificaciones'**
  String get notificationSettings;

  /// Etiqueta de ayuda y soporte
  ///
  /// In es, this message translates to:
  /// **'Ayuda y soporte'**
  String get helpSupport;

  /// Subtítulo de ayuda y soporte
  ///
  /// In es, this message translates to:
  /// **'Centro de ayuda y contacto'**
  String get helpSupportSubtitle;

  /// Etiqueta de centro de ayuda
  ///
  /// In es, this message translates to:
  /// **'Centro de ayuda'**
  String get helpCenter;

  /// Etiqueta de contactar soporte
  ///
  /// In es, this message translates to:
  /// **'Contactar soporte'**
  String get contactSupport;

  /// Etiqueta de preguntas frecuentes
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get faq;

  /// Etiqueta de documentación
  ///
  /// In es, this message translates to:
  /// **'Documentación'**
  String get documentation;

  /// Etiqueta de acerca de
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// Subtítulo de acerca de
  ///
  /// In es, this message translates to:
  /// **'Información de la aplicación'**
  String get aboutSubtitle;

  /// Etiqueta de versión
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// Etiqueta de compilación
  ///
  /// In es, this message translates to:
  /// **'Compilación'**
  String get build;

  /// Etiqueta de términos de servicio
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio'**
  String get termsOfService;

  /// Etiqueta de política de privacidad
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// Etiqueta de licencias
  ///
  /// In es, this message translates to:
  /// **'Licencias'**
  String get licenses;

  /// Etiqueta de perfil
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profile;

  /// Título de la pantalla mi perfil
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get myProfile;

  /// Etiqueta del botón editar perfil
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// Título de la sección de información personal
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get personalInfo;

  /// Título de la sección de ubicación
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// Título de la sección de datos legales
  ///
  /// In es, this message translates to:
  /// **'Datos legales'**
  String get legalData;

  /// Etiqueta del campo RUT en datos legales
  ///
  /// In es, this message translates to:
  /// **'RUT del usuario o Representante Legal'**
  String get legalDataRut;

  /// Etiqueta del campo razón social en datos legales
  ///
  /// In es, this message translates to:
  /// **'Razón Social'**
  String get legalDataBusinessName;

  /// Etiqueta del campo número de registro SAG
  ///
  /// In es, this message translates to:
  /// **'N° de Registro de Apicultor/a en el SAG'**
  String get sagRegistryNumber;

  /// Etiqueta de miembro desde
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get memberSince;

  /// Etiqueta de ID de usuario
  ///
  /// In es, this message translates to:
  /// **'ID de usuario'**
  String get userId;

  /// Etiqueta de foto de perfil
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get profilePicture;

  /// Título del diálogo de seleccionar foto
  ///
  /// In es, this message translates to:
  /// **'Seleccionar foto'**
  String get selectPhoto;

  /// Opción de tomar foto
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// Opción de elegir de galería
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get chooseFromGallery;

  /// Opción de eliminar foto
  ///
  /// In es, this message translates to:
  /// **'Eliminar foto'**
  String get removePhoto;

  /// Confirmación de foto seleccionada
  ///
  /// In es, this message translates to:
  /// **'Foto seleccionada (vista previa)'**
  String get photoSelected;

  /// Confirmación de foto eliminada
  ///
  /// In es, this message translates to:
  /// **'Foto eliminada (vista previa)'**
  String get photoRemoved;

  /// Etiqueta de cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// Subtítulo de cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu contraseña'**
  String get changePasswordSubtitle;

  /// Etiqueta de autenticación en dos pasos
  ///
  /// In es, this message translates to:
  /// **'Autenticación en dos pasos'**
  String get twoFactorAuth;

  /// Subtítulo de autenticación en dos pasos
  ///
  /// In es, this message translates to:
  /// **'Añade una capa extra de seguridad'**
  String get twoFactorAuthSubtitle;

  /// Etiqueta de configuración de seguridad
  ///
  /// In es, this message translates to:
  /// **'Configuración de seguridad'**
  String get securitySettings;

  /// Etiqueta de configuración de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageSettings;

  /// Subtítulo de idioma
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSubtitle;

  /// Etiqueta de gestión de datos
  ///
  /// In es, this message translates to:
  /// **'Gestión de datos'**
  String get dataManagement;

  /// Subtítulo de gestión de datos
  ///
  /// In es, this message translates to:
  /// **'Historial y almacenamiento'**
  String get dataManagementSubtitle;

  /// Etiqueta de gestión de almacenamiento
  ///
  /// In es, this message translates to:
  /// **'Gestión de almacenamiento'**
  String get storageManagement;

  /// Etiqueta del botón limpiar caché
  ///
  /// In es, this message translates to:
  /// **'Limpiar caché'**
  String get clearCache;

  /// Etiqueta del botón limpiar historial
  ///
  /// In es, this message translates to:
  /// **'Limpiar historial'**
  String get clearHistory;

  /// Etiqueta de plan gratuito
  ///
  /// In es, this message translates to:
  /// **'Plan Gratuito'**
  String get freePlan;

  /// Etiqueta de plan premium
  ///
  /// In es, this message translates to:
  /// **'Plan Premium'**
  String get premiumPlan;

  /// Etiqueta del botón actualizar plan
  ///
  /// In es, this message translates to:
  /// **'Actualizar plan'**
  String get upgradePlan;

  /// Subtítulo de actualizar plan
  ///
  /// In es, this message translates to:
  /// **'Actualiza para más funciones'**
  String get upgradeForMore;

  /// Etiqueta del botón ver planes premium
  ///
  /// In es, this message translates to:
  /// **'Ver planes Premium'**
  String get viewPremiumPlans;

  /// Etiqueta de plan actual
  ///
  /// In es, this message translates to:
  /// **'Plan actual'**
  String get currentPlan;

  /// Etiqueta de facturación
  ///
  /// In es, this message translates to:
  /// **'Facturación'**
  String get billing;

  /// Etiqueta de método de pago
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get paymentMethod;

  /// Etiqueta del botón eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccount;

  /// Mensaje de confirmación de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Se eliminarán todos tus datos y conversaciones.'**
  String get deleteAccountConfirm;

  /// Confirmación de cuenta eliminada
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get accountDeleted;

  /// Mensaje de bienvenida a B-MaiA
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a B-MaiA!'**
  String get welcomeToBMaia;

  /// Título de la pantalla de onboarding 1
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a B-MaiA!'**
  String get onboardingTitle1;

  /// Descripción de la pantalla de onboarding 1
  ///
  /// In es, this message translates to:
  /// **'Descubre una nueva forma de gestionar tus proyectos con inteligencia artificial avanzada.'**
  String get onboardingDesc1;

  /// Título de la pantalla de onboarding 2
  ///
  /// In es, this message translates to:
  /// **'Tecnología Avanzada'**
  String get onboardingTitle2;

  /// Descripción de la pantalla de onboarding 2
  ///
  /// In es, this message translates to:
  /// **'Utilizamos las últimas innovaciones en IA para brindarte la mejor experiencia posible.'**
  String get onboardingDesc2;

  /// Título de la pantalla de onboarding 3
  ///
  /// In es, this message translates to:
  /// **'Experiencia Personalizada'**
  String get onboardingTitle3;

  /// Descripción de la pantalla de onboarding 3
  ///
  /// In es, this message translates to:
  /// **'Cada función está diseñada pensando en tus necesidades específicas y preferencias.'**
  String get onboardingDesc3;

  /// Etiqueta del botón comenzar
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get getStarted;

  /// Etiqueta del botón ver introducción
  ///
  /// In es, this message translates to:
  /// **'Ver introducción'**
  String get viewIntroduction;

  /// Mensaje de error genérico
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error'**
  String get errorGeneric;

  /// Mensaje de error de conexión
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get errorConnection;

  /// Mensaje de error de tiempo agotado
  ///
  /// In es, this message translates to:
  /// **'Tiempo de espera agotado'**
  String get errorTimeout;

  /// Mensaje de error del servidor
  ///
  /// In es, this message translates to:
  /// **'Error del servidor'**
  String get errorServer;

  /// Mensaje de error no encontrado
  ///
  /// In es, this message translates to:
  /// **'No encontrado'**
  String get errorNotFound;

  /// Mensaje de error no autorizado
  ///
  /// In es, this message translates to:
  /// **'No autorizado'**
  String get errorUnauthorized;

  /// Mensaje de error acceso denegado
  ///
  /// In es, this message translates to:
  /// **'Acceso denegado'**
  String get errorForbidden;

  /// Mensaje de error intentar de nuevo
  ///
  /// In es, this message translates to:
  /// **'Por favor, inténtalo de nuevo'**
  String get errorTryAgain;

  /// Mensaje de error al seleccionar imagen
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar la imagen'**
  String get errorImageSelection;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Funcionalidad en desarrollo'**
  String get featureInDevelopment;

  /// Mensaje de éxito genérico
  ///
  /// In es, this message translates to:
  /// **'Operación exitosa'**
  String get successGeneric;

  /// Mensaje de éxito al guardar
  ///
  /// In es, this message translates to:
  /// **'Guardado exitosamente'**
  String get successSaved;

  /// Mensaje de éxito al actualizar
  ///
  /// In es, this message translates to:
  /// **'Actualizado exitosamente'**
  String get successUpdated;

  /// Mensaje de éxito al eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminado exitosamente'**
  String get successDeleted;

  /// Mensaje de éxito al enviar
  ///
  /// In es, this message translates to:
  /// **'Enviado exitosamente'**
  String get successSent;

  /// Etiqueta de menú
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get menu;

  /// Etiqueta de conversaciones
  ///
  /// In es, this message translates to:
  /// **'Conversaciones'**
  String get chats;

  /// Contador de historial de chat
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin conversaciones} =1{1 conversación} other{{count} conversaciones}}'**
  String chatHistory(int count);

  /// Etiqueta de mi cuenta
  ///
  /// In es, this message translates to:
  /// **'Mi Cuenta'**
  String get myAccount;

  /// Etiqueta de chat
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Etiqueta de mensaje
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get message;

  /// Etiqueta de mensajes
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get messages;

  /// Etiqueta de no hay mensajes
  ///
  /// In es, this message translates to:
  /// **'No hay mensajes'**
  String get noMessages;

  /// Indicador de escritura
  ///
  /// In es, this message translates to:
  /// **'Escribiendo...'**
  String get typing;

  /// Estado en línea
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get online;

  /// Estado desconectado
  ///
  /// In es, this message translates to:
  /// **'Desconectado'**
  String get offline;

  /// Etiqueta de visto por última vez
  ///
  /// In es, this message translates to:
  /// **'Visto por última vez'**
  String get lastSeen;

  /// Etiqueta de leído por
  ///
  /// In es, this message translates to:
  /// **'Leído por'**
  String get readBy;

  /// Etiqueta de entregado a
  ///
  /// In es, this message translates to:
  /// **'Entregado a'**
  String get deliveredTo;

  /// Estado enviado
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get sent;

  /// Estado recibido
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get received;

  /// Estado leído
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get read;

  /// Marca de tiempo ahora
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get now;

  /// Marca de tiempo hoy
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// Marca de tiempo ayer
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// Marca de tiempo hace minutos
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hace 1 minuto} other{Hace {count} minutos}}'**
  String minutesAgo(int count);

  /// Marca de tiempo hace horas
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hace 1 hora} other{Hace {count} horas}}'**
  String hoursAgo(int count);

  /// Marca de tiempo hace días
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hace 1 día} other{Hace {count} días}}'**
  String daysAgo(int count);

  /// Conjunción 'o'
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get orWord;

  /// Conjunción 'y'
  ///
  /// In es, this message translates to:
  /// **'y'**
  String get andWord;

  /// Preposición 'a'
  ///
  /// In es, this message translates to:
  /// **'a'**
  String get toWord;

  /// Preposición 'de'
  ///
  /// In es, this message translates to:
  /// **'de'**
  String get fromWord;

  /// Preposición 'en'
  ///
  /// In es, this message translates to:
  /// **'en'**
  String get inWord;

  /// Preposición 'en'
  ///
  /// In es, this message translates to:
  /// **'en'**
  String get atWord;

  /// Preposición 'el'
  ///
  /// In es, this message translates to:
  /// **'el'**
  String get onWord;

  /// Preposición 'por'
  ///
  /// In es, this message translates to:
  /// **'por'**
  String get byWord;

  /// Preposición 'con'
  ///
  /// In es, this message translates to:
  /// **'con'**
  String get withWord;

  /// Preposición 'sin'
  ///
  /// In es, this message translates to:
  /// **'sin'**
  String get withoutWord;

  /// Preposición 'para'
  ///
  /// In es, this message translates to:
  /// **'para'**
  String get forWord;

  /// Marcador de no disponible
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// Etiqueta de próximamente
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// Etiqueta de función beta
  ///
  /// In es, this message translates to:
  /// **'Beta'**
  String get betaLabel;

  /// Etiqueta de función nueva
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get newLabel;

  /// Validación de longitud mínima de nombre
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 3 caracteres'**
  String get nameMinLength;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
