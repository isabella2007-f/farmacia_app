const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

// ─── CONFIGURACIÓN DE EMAIL ────────────────────────────────
// Configura con tu proveedor de email (Gmail, SendGrid, etc.)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().email.user,     // Tu email
    pass: functions.config().email.password, // Tu contraseña de app Gmail
  },
});

// ─── FUNCIÓN PROGRAMADA ────────────────────────────────────
// Se ejecuta todos los días a las 8:00 AM (zona horaria Colombia)
exports.verificarMedicamentosVencimiento = functions
  .region("us-central1")
  .pubsub
  .schedule("0 8 * * *")  // Cron: cada día a las 8am
  .timeZone("America/Bogota")
  .onRun(async (context) => {
    console.log("🔔 Verificando medicamentos...");

    try {
      const ahora = admin.firestore.Timestamp.now();

      // Buscar medicamentos donde:
      // 1. La fecha de alerta ya llegó (fechaAlerta <= ahora)
      // 2. No han vencido aún (fechaVencimiento > ahora)
      // 3. No se ha enviado alerta todavía
      const snapshot = await db
        .collection("medicamentos")
        .where("fechaAlerta", "<=", ahora)
        .where("fechaVencimiento", ">", ahora)
        .where("alertaEnviada", "==", false)
        .get();

      if (snapshot.empty) {
        console.log("✅ No hay alertas pendientes hoy");
        return null;
      }

      console.log(`📋 Encontrados ${snapshot.size} medicamentos con alerta pendiente`);

      // Procesar cada medicamento
      const promesas = snapshot.docs.map(async (doc) => {
        const med = doc.data();

        // Calcular días restantes
        const fechaVenc = med.fechaVencimiento.toDate();
        const diasRestantes = Math.ceil(
          (fechaVenc - new Date()) / (1000 * 60 * 60 * 24)
        );

        // Obtener datos del usuario
        const usuarioDoc = await db.collection("usuarios").doc(med.userId).get();
        const usuario = usuarioDoc.data();

        if (!usuario) return;

        // ─── 1. NOTIFICACIÓN PUSH ──────────────────────────
        // Obtener token FCM del dispositivo del usuario
        // (En una app real, guardarías el token en Firestore)
        await enviarNotificacionPush(med, diasRestantes, usuario);

        // ─── 2. EMAIL ──────────────────────────────────────
        await enviarEmail(med, diasRestantes, usuario);

        // ─── 3. MARCAR COMO ENVIADA ────────────────────────
        await doc.ref.update({ alertaEnviada: true });

        console.log(`✉️ Alerta enviada para: ${med.nombre}`);
      });

      await Promise.all(promesas);
      console.log("✅ Proceso completado");
      return null;

    } catch (error) {
      console.error("❌ Error en verificación:", error);
      throw error;
    }
  });


// ─── FUNCIÓN: Notificación Push ────────────────────────────
async function enviarNotificacionPush(med, diasRestantes, usuario) {
  try {
    // Buscar dispositivos registrados del usuario
    const tokensSnap = await db
      .collection("fcm_tokens")
      .where("userId", "==", med.userId)
      .get();

    if (tokensSnap.empty) return;

    const tokens = tokensSnap.docs.map((d) => d.data().token);

    const message = {
      tokens: tokens,
      notification: {
        title: "⚠️ Medicamento próximo a vencer",
        body: `${med.nombre} vence en ${diasRestantes} días (${med.laboratorioNombre})`,
      },
      data: {
        medicamentoId: med.medicamentoId || "",
        tipo: "alerta_vencimiento",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "farmacia_alerts",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: { sound: "default", badge: 1 },
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`📱 Push enviado: ${response.successCount} exitosos`);

  } catch (error) {
    console.error("Error enviando push:", error);
  }
}

// ─── FUNCIÓN: Enviar Email ─────────────────────────────────
async function enviarEmail(med, diasRestantes, usuario) {
  try {
    const fechaVenc = med.fechaVencimiento.toDate();
    const fechaFormateada = fechaVenc.toLocaleDateString("es-CO", {
      year: "numeric", month: "long", day: "numeric",
    });

    const mailOptions = {
      from: `Farmacia App <${functions.config().email.user}>`,
      to: usuario.email,
      subject: `⚠️ Alerta: ${med.nombre} vence en ${diasRestantes} días`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; background: #f5f5f5; }
            .container { max-width: 600px; margin: 20px auto; background: white; 
                         border-radius: 12px; overflow: hidden; }
            .header { background: #2D2D2D; color: white; padding: 24px; }
            .content { padding: 24px; }
            .alert-box { background: #FEF3C7; border: 1px solid #F59E0B; 
                         border-radius: 8px; padding: 16px; margin: 16px 0; }
            .info-row { display: flex; margin: 8px 0; }
            .label { font-weight: bold; width: 160px; color: #555; }
            .footer { background: #f5f5f5; padding: 16px; text-align: center; 
                      font-size: 12px; color: #999; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h2 style="margin:0">💊 Alerta de Vencimiento</h2>
              <p style="margin:8px 0 0; opacity:0.8">${usuario.farmacia || 'Tu Farmacia'}</p>
            </div>
            <div class="content">
              <p>Hola <strong>${usuario.nombre || usuario.email}</strong>,</p>
              <p>Te informamos que el siguiente medicamento está próximo a vencer:</p>
              
              <div class="alert-box">
                <strong>⏰ ${diasRestantes} días restantes</strong>
              </div>
              
              <div class="info-row">
                <span class="label">💊 Medicamento:</span>
                <span>${med.nombre}</span>
              </div>
              <div class="info-row">
                <span class="label">🏭 Laboratorio:</span>
                <span>${med.laboratorioNombre}</span>
              </div>
              <div class="info-row">
                <span class="label">📅 Fecha vencimiento:</span>
                <span>${fechaFormateada}</span>
              </div>
              <div class="info-row">
                <span class="label">📦 Stock disponible:</span>
                <span>${med.cantidad} unidades</span>
              </div>
              
              <p style="margin-top:24px; color:#666;">
                Toma las acciones necesarias para evitar pérdidas o riesgos para los clientes.
              </p>
            </div>
            <div class="footer">
              Farmacia App · Sistema de Gestión de Medicamentos
            </div>
          </div>
        </body>
        </html>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`📧 Email enviado a: ${usuario.email}`);

  } catch (error) {
    console.error("Error enviando email:", error);
  }
}


// ─── FUNCIÓN HTTP: Guardar token FCM ──────────────────────
// Llamada desde la app cuando el usuario inicia sesión
exports.guardarFCMToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated", "Debes estar autenticado"
    );
  }

  const { token } = data;
  const userId = context.auth.uid;

  // Guardar/actualizar token en Firestore
  await db.collection("fcm_tokens").doc(userId).set({
    userId,
    token,
    actualizadoEn: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});