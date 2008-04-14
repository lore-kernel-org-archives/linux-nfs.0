From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/24] SUNRPC: Split portmap unregister API into separate
	function
Date: Mon, 14 Apr 2008 12:29:13 -0400
Message-ID: <20080414162913.12741.35120.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:54260 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759883AbYDNQ3i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:29:38 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Registering RPC services with the local portmapper is sufficiently
different from unregistering them that providing a separate API for each
makes sense.

The mechanics of and API for registering and unregistering RPC services
will diverge further as support for IPv6 is added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |   66 +++++++++++++++++++++++++++++++++-----------
 2 files changed, 51 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 64c9755..48ad59c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -395,6 +395,7 @@ int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
 int		   svc_register(struct svc_serv *, int, unsigned short);
+void		   svc_unregister(const struct svc_serv *serv);
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 86a5b56..576efa7 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -420,9 +420,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-
 	/* Remove any stale portmap registrations */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 
 	return serv;
 }
@@ -490,8 +489,7 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
-	/* Unregister service with the portmapper */
-	svc_register(serv, 0, 0);
+	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
@@ -753,21 +751,21 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL(svc_exit_thread);
 
-/*
- * Register an RPC service with the local portmapper.
- * To unregister a service, call this routine with
- * proto and port == 0.
+/**
+ * svc_register - register an RPC service with the local portmapper
+ * @serv: svc_serv struct for the service to register
+ * @protocol: transport protocol number to advertise
+ * @port: port to advertise
+ *
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
+	BUG_ON(proto == 0 && port == 0);
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
@@ -795,13 +793,49 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 		}
 	}
 
-	if (!port) {
-		spin_lock_irqsave(&current->sighand->siglock, flags);
-		recalc_sigpending();
-		spin_unlock_irqrestore(&current->sighand->siglock, flags);
+	return error;
+}
+
+static void __svc_unregister(struct svc_program *program, u32 version)
+{
+	int error, boolean = 0;
+
+	error = rpcb_register(program->pg_prog, version, 0, 0, &boolean);
+	dprintk("svc: svc_unregister(%sv%u), error %d, %s\n",
+			program->pg_name, version, error,
+			(boolean ? "succeeded" : "failed"));
+}
+
+/**
+ * svc_unregister - remove an RPC server from the local rpcbind database
+ * @serv: svc_serv struct for the service to register
+ *
+ * All transport protocols and ports for this service are removed from
+ * the local rpcbind database.  The result of unregistration is reported
+ * via dprintk for those who want verification of the result, but is
+ * otherwise not important.
+ */
+void svc_unregister(const struct svc_serv *serv)
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
+			if (program->pg_vers[version]->vs_hidden)
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

