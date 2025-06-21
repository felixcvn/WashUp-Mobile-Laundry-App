import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

export const notifyNewOrder = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const adminSnapshot = await admin.firestore()
      .collection("users")
      .where("role", "==", "admin")
      .get();
    const tokens: string[] = adminSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter(Boolean);
    if (tokens.length > 0) {
      await admin.messaging().sendMulticast({
        tokens,
        notification: {
          title: "Pesanan Baru",
          body: `Ada pesanan baru dari ${order.userName}`,
        },
        data: {
          route: "/admin/orders",
          orderId: context.params.orderId,
        },
      });
    }
  });

export const notifyCourierDelivery = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const orderAfter = change.after.data();
    const orderBefore = change.before.data();
    if (orderBefore.status !== "completed" &&
        orderAfter.status === "completed") {
      const courierDoc = await admin.firestore()
        .collection("users")
        .doc(orderAfter.courierId)
        .get();
      const courierToken = courierDoc.data()?.fcmToken;
      if (courierToken) {
        await admin.messaging().send({
          token: courierToken,
          notification: {
            title: "Pesanan Siap Diantar",
            body: `Pesanan #${context.params.orderId} siap untuk diantar`,
          },
          data: {
            route: "/courier/deliveries",
            orderId: context.params.orderId,
          },
        });
      }
    }
  });

export const notifyCustomerDelivery = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const orderAfter = change.after.data();
    const orderBefore = change.before.data();
    if (orderBefore.deliveryStatus !== "ongoing" &&
        orderAfter.deliveryStatus === "ongoing") {
      const customerDoc = await admin.firestore()
        .collection("users")
        .doc(orderAfter.userId)
        .get();
      const customerToken = customerDoc.data()?.fcmToken;
      if (customerToken) {
        await admin.messaging().send({
          token: customerToken,
          notification: {
            title: "Pesanan Dalam Perjalanan",
            body: "Pesanan Anda sedang dalam perjalanan",
          },
          data: {
            route: "/orders",
            orderId: context.params.orderId,
          },
        });
      }
    }
  });
