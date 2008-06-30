From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] SUNRPC: Split portmap unregister API into separate
	function
Date: Mon, 30 Jun 2008 18:45:45 -0400
Message-ID: <20080630224545.24887.61618.stgit@ellison.1015granger.net>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:46841 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932752AbYF3WqM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:46:12 -0400
In-Reply-To: <20080630224147.24887.18730.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a separate server-level interface for unregistering RPC services.

The mechanics of and the API for registering and unregistering RPC
services will diverge further as support for IPv6 is added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   71 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 59 insertions(+), 12 deletions(-)


diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d0e7865..a41b163 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -27,6 +27,8 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
+static void svc_unregister(const struct svc_serv *serv);
+
 #define svc_serv_is_pooled(serv)    ((serv)->sv_function)
 
 /*
@@ -426,9 +428,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-
 	/* Remove any stale portmap registrations */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 
 	return serv;
 }
@@ -496,8 +497,7 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
-	/* Unregister service with the portmapper */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
@@ -758,12 +758,10 @@ int
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
@@ -791,13 +789,62 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
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
+static void __svc_unregister(struct svc_program *program, u32 version)
+{
+	int error, boolean;
+
+	error = rpcb_register(program->pg_prog, version, 0, 0, &boolean);
+	dprintk("svc: svc_unregister(%sv%u), error %d, %s\n",
+			program->pg_name, version, error,
+			(boolean ? "succeeded" : "failed"));
+}
+
+/*
+ * All transport protocols and ports for this service are removed from
+ * the local rpcbind database.  The result of unregistration is reported
+ * via dprintk for those who want verification of the result, but is
+ * otherwise not important.
+ */
+static void svc_unregister(const struct svc_serv *serv)
+{
+	struct svc_program *program;
+	unsigned long flags;
+	u32 version;
+
+	clear_thread_flag(TIF_SIGPENDING);
+
+	for (program = serv->sv_program; program; program = program->pg_next) {
+		for (version = 0; version < program->pg_nvers; version++) {
+			if (program->pg_vers[version] == NULL)
+				continue;
+			__svc_unregister(program, version);
+		}
 	}
 
-	return error;
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 }
 
 /*

