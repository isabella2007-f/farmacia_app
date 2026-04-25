import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Handler para mensajes en segundo plano (debe ser función top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Mensaje en background: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Canal de notificaciones Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'farmacia_alerts',         // ID del canal
    'Alertas de Farmacia',     // Nombre visible
    description: 'Notificaciones de medicamentos próximos a vencer',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initialize() async {
    // 1. Configurar handler de background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Solicitar permisos
    await _requestPermissions();

    // 3. Inicializar notificaciones locales
    await _initLocalNotifications();

    // 4. Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Crear canal Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Permisos FCM: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Aquí puedes navegar a una pantalla específica
        debugPrint('Notificación tocada: ${details.payload}');
      },
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Cuando llega un mensaje con la app abierta, mostrar notificación local
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      showLocalNotification(
        title: notification.title ?? 'Farmacia App',
        body: notification.body ?? '',
        payload: message.data['medicamentoId'],
      );
    }
  }

  /// Mostrar una notificación local inmediata
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'farmacia_alerts',
      'Alertas de Farmacia',
      channelDescription: 'Alertas de medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Obtener el token FCM del dispositivo (se envía a Firebase Functions)
  Future<String?> getFCMToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error obteniendo FCM token: $e');
      return null;
    }
  }

  // Llamar esto cuando el usuario hace login
Future<void> guardarTokenEnServidor() async {
  try {
    final token = await getFCMToken();
    if (token == null) return;

    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('guardarFCMToken');
    await callable.call({'token': token});
    
    debugPrint('Token FCM guardado en servidor');
  } catch (e) {
    debugPrint('Error guardando token FCM: $e');
  }
}
}

