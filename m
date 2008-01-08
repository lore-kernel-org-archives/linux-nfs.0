From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] SUNRPC: Split portmap unregister API into separate
	function
Date: Tue, 08 Jan 2008 11:31:10 -0500
Message-ID: <20080108163110.21088.37420.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:31871 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbYAHQbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:31:11 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m08GVAhJ010585
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 08:31:10 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m08GVAg4021120
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 11:31:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Registering and unregistering RPC services with the local portmapper are
sufficiently different that splitting these makes sense.  They will diverge
a bit more as we add support for AF_INET6.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |   49 ++++++++++++++++++++++++++++++--------------
 2 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8531a70..4f73a0d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -391,6 +391,7 @@ int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
 int		   svc_register(struct svc_serv *, int, unsigned short);
+void		   svc_unregister(struct svc_serv *serv);
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8b598b5..eb3bb24 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -419,9 +419,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-
-	/* Remove any stale portmap registrations */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 
 	return serv;
 }
@@ -492,8 +490,8 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
-	/* Unregister service with the portmapper */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
+
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
@@ -728,20 +726,14 @@ svc_exit_thread(struct svc_rqst *rqstp)
 
 /*
  * Register an RPC service with the local portmapper.
- * To unregister a service, call this routine with
- * proto and port == 0.
  */
 int
 svc_register(struct svc_serv *serv, int proto, unsigned short port)
 {
 	struct svc_program	*progp;
-	unsigned long		flags;
 	unsigned int		i;
 	int			error = 0, dummy;
 
-	if (!port)
-		clear_thread_flag(TIF_SIGPENDING);
-
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
 			if (progp->pg_vers[i] == NULL)
@@ -768,13 +760,38 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 		}
 	}
 
-	if (!port) {
-		spin_lock_irqsave(&current->sighand->siglock, flags);
-		recalc_sigpending();
-		spin_unlock_irqrestore(&current->sighand->siglock, flags);
+	return error;
+}
+
+/**
+ * svc_unregister - remove an RPC server from the local rpcbind database
+ * @serv: svc_serv struct for the service to register
+ *
+ * All transport protocols, and ports for this service are removed from
+ * the local rpcbind database.
+ */
+void svc_unregister(struct svc_serv *serv)
+{
+	struct svc_program *progp;
+	unsigned long flags;
+	u32 version;
+	int dummy;
+
+	clear_thread_flag(TIF_SIGPENDING);
+
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		for (version = 0; version < progp->pg_nvers; version++) {
+			if (progp->pg_vers[version] == NULL)
+				continue;
+			if (progp->pg_vers[version]->vs_hidden)
+				continue;
+			rpcb_register(progp->pg_prog, version, 0, 0, &dummy);
+		}
 	}
 
-	return error;
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 }
 
 /*

