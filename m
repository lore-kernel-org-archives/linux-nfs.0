From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] SUNRPC: Split portmap unregister API into separate
	function
Date: Wed, 13 Aug 2008 18:40:09 -0400
Message-ID: <20080813224008.13068.66471.stgit@manray.1015granger.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37287 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbYHMWl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:41:58 -0400
In-Reply-To: <20080813223653.13068.9467.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a separate server-level interface for unregistering RPC services.

The mechanics of, and the API for, registering and unregistering RPC
services will diverge further as support for IPv6 is added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   76 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 63 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2a6649f..58a8012 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -28,6 +28,8 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
+static void svc_unregister(const struct svc_serv *serv);
+
 #define svc_serv_is_pooled(serv)    ((serv)->sv_function)
 
 /*
@@ -417,9 +419,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-
 	/* Remove any stale portmap registrations */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 
 	return serv;
 }
@@ -488,8 +489,7 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
-	/* Unregister service with the portmapper */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
@@ -729,12 +729,10 @@ int
 svc_register(struct svc_serv *serv, int proto, unsigned short port)
 {
 	struct svc_program	*progp;
-	unsigned long		flags;
 	unsigned int		i;
 	int			error = 0, dummy;
 
-	if (!port)
-		clear_thread_flag(TIF_SIGPENDING);
+	BUG_ON(proto == 0 && port == 0);
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
@@ -755,20 +753,72 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
 			if (error < 0)
 				break;
-			if (port && !dummy) {
+			if (!dummy) {
 				error = -EACCES;
 				break;
 			}
 		}
 	}
 
-	if (!port) {
-		spin_lock_irqsave(&current->sighand->siglock, flags);
-		recalc_sigpending();
-		spin_unlock_irqrestore(&current->sighand->siglock, flags);
+	return error;
+}
+
+/*
+ * The local rpcbind daemon listens on either only IPv6 or only
+ * IPv4.  The kernel can't tell how it's configured.
+ *
+ * However, AF_INET addresses are mapped to AF_INET6 in IPv6-only
+ * configurations, so even an unregistration request on AF_INET
+ * will get to a local rpcbind daemon listening only on AF_INET6.
+ *
+ * So we always unregister via AF_INET (the loopback address is
+ * fairly unambiguous anyway).
+ *
+ * At this point we don't need rpcbind version 4 for unregistration:
+ * A v2 UNSET request will clear all transports (netids), addresses,
+ * and address families for [program, version].
+ *
+ * This should allow automatic support for both an all-IPv4 and
+ * an all-IPv6 configuration.
+ */
+static void __svc_unregister(struct svc_program *progp, u32 version)
+{
+	int error, boolean;
+
+	error = rpcb_register(progp->pg_prog, version, 0, 0, &boolean);
+	dprintk("svc: svc_unregister(%sv%u), error %d, %s\n",
+			progp->pg_name, version, error,
+			(boolean ? "succeeded" : "failed"));
+}
+
+/*
+ * All transport protocols and ports for this service are removed from
+ * the local rpcbind database if the service is not hidden.  The result
+ * of unregistration is reported via dprintk for those who want
+ * verification of the result, but is otherwise not important.
+ */
+static void svc_unregister(const struct svc_serv *serv)
+{
+	struct svc_program *progp;
+	unsigned long flags;
+
+	clear_thread_flag(TIF_SIGPENDING);
+
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		unsigned int i;
+		for (i = 0; i < progp->pg_nvers; i++) {
+			if (progp->pg_vers[i] == NULL)
+				continue;
+			if (progp->pg_vers[i]->vs_hidden)
+				continue;
+
+			__svc_unregister(progp, i);
+		}
 	}
 
-	return error;
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 }
 
 /*

