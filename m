From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] SUNRPC: Split portmap unregister API into separate
	function
Date: Mon, 18 Aug 2008 19:34:08 -0400
Message-ID: <20080818233407.1214.52540.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:43853 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbYHSMHK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:07:10 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a separate server-level interface for unregistering RPC services.

The mechanics of, and the API for, registering and unregistering RPC
services will diverge further as support for IPv6 is added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   62 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 50 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c2eb72c..3d4c0b0 100644
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
 	int			error = 0;
 
-	if (!port)
-		clear_thread_flag(TIF_SIGPENDING);
+	BUG_ON(proto == 0 && port == 0);
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
@@ -758,13 +756,53 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
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
+ * All transport protocols and ports for this service are removed
+ * from the local rpcbind database if the service is not hidden.
+ *
+ * The result of unregistration is reported via dprintk for those
+ * who want verification of the result, but is otherwise not
+ * important.
+ *
+ * The local rpcbind daemon listens on either only IPv6 or only
+ * IPv4.  The kernel can't tell how it's configured.  However,
+ * AF_INET addresses are mapped to AF_INET6 in IPv6-only config-
+ * urations, so even an unregistration request on AF_INET will
+ * get to a local rpcbind daemon listening only on AF_INET6.  So
+ * we always unregister via AF_INET.
+ *
+ * At this point we don't need rpcbind version 4 for unregis-
+ * tration:  A v2 UNSET request will clear all transports (netids),
+ * addresses, and address families for [program, version].
+ */
+static void svc_unregister(const struct svc_serv *serv)
+{
+	struct svc_program *progp;
+	unsigned long flags;
+	unsigned int i;
+	int error;
+
+	clear_thread_flag(TIF_SIGPENDING);
+
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		for (i = 0; i < progp->pg_nvers; i++) {
+			if (progp->pg_vers[i] == NULL)
+				continue;
+			if (progp->pg_vers[i]->vs_hidden)
+				continue;
+
+			error = rpcb_register(progp->pg_prog, i, 0, 0);
+			dprintk("svc: svc_unregister(%sv%u), error %d\n",
+					progp->pg_name, i, error);
+		}
 	}
 
-	return error;
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 }
 
 /*

