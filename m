From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH 2/3] Add DRC for NLM using sunrpc's common DRC
Date: Mon, 02 Nov 2009 17:39:07 +0800
Message-ID: <4AEEA8BB.4040304@cn.fujitsu.com>
References: <4AEEA622.6000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, bfields@fieldses.org,
	mingo@elte.hu
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57686 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbZKBJiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 04:38:03 -0500
In-Reply-To: <4AEEA622.6000705@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When use sunrpc's common DRC:
  At first : define a global variable to record the cache with struct drc_cache;
  At second: initialize the variable when NLM module be load at init_nlm() by
             call drc_reply_cache_init();
  At third : the variable will be used to record the request by a new function
             nlm_dispatch();
  At last  : release the variable when NLM module be unload at exit_nlm() by 
             call drc_reply_cache_shutdown().

This patch's implemention:
  1. define a global variable nlm_dc to record the request;
  2. add a nlm_dispatch() function reference to nfsd_dispatch(), nlm_dispatch
     will be used to process NLM's request;
  3. add ".vs_dispatch = nlm_dispatch" to nlmsvc_version1, nlmsvc_version3,
     and nlmsvc_version4, which cause the request be processd by nlm_dispatch;
  4. add cache type to nlmsvc_procedures4[], only "lock" is RC_REPLSTAT,others
     are RC_NOCACHE.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/lockd/svc.c              |   66 +++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/svc4proc.c         |   52 +++++++++++++++++----------------
 include/linux/lockd/lockd.h |    6 ++++
 3 files changed, 99 insertions(+), 25 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1a54ae1..66d97ce 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -32,6 +32,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <net/ip.h>
 #include <linux/lockd/lockd.h>
@@ -76,6 +77,9 @@ static const int		nlm_port_min = 0, nlm_port_max = 65535;
 static struct ctl_table_header * nlm_sysctl_table;
 #endif
 
+/* DRC for NLM */
+struct drc_cache nlm_dc;
+
 static unsigned long get_lockd_grace_period(void)
 {
 	/* Note: nlm_timeout should always be nonzero */
@@ -363,6 +367,63 @@ out:
 }
 EXPORT_SYMBOL_GPL(lockd_down);
 
+/*
+ * DRC for NLM
+ */
+int
+nlm_dispatch(struct svc_rqst *rqstp, u32 *statp)
+{
+	struct svc_procedure *proc;
+	kxdrproc_t	   xdr;
+
+	dprintk("nlm_dispatch: vers %d proc %d\n",
+			rqstp->rq_vers, rqstp->rq_proc);
+	proc = rqstp->rq_procinfo;
+
+	/* Check whether we have this call in the cache. */
+	switch (drc_cache_lookup(rqstp, proc->pc_cachetype, &nlm_dc)) {
+	case RC_INTR:
+	case RC_DROPIT:
+		return 0;
+	case RC_REPLY:
+		return 1;
+	case RC_DOIT:;
+		/* do it */
+	}
+
+	/* Decode arguments */
+	xdr = proc->pc_decode;
+	if (xdr && !xdr(rqstp, (u32*)rqstp->rq_arg.head[0].iov_base,
+			rqstp->rq_argp)) {
+		dprintk("nlm: failed to decode arguments!\n");
+		drc_cache_update(rqstp, RC_NOCACHE, NULL, &nlm_dc);
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+
+	*statp = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+
+	if (*statp == rpc_drop_reply) {
+		dprintk("nlm: Dropping request due to malloc failure!\n");
+		drc_cache_update(rqstp, RC_NOCACHE, NULL, &nlm_dc);
+		return 0;
+	}
+
+	if (*statp ==rpc_success && (xdr = proc->pc_encode) && !xdr(rqstp,
+	    (rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len),
+	     rqstp->rq_resp)) {
+	     dprintk("nlm: failed to encode result!\n");
+	     drc_cache_update(rqstp, RC_NOCACHE, NULL, &nlm_dc);
+	     *statp = rpc_system_err;
+	     return 1;
+	}
+
+	/* Store reply in cache */
+	drc_cache_update(rqstp, proc->pc_cachetype, statp + 1, &nlm_dc);
+	return 1;
+
+}
+
 #ifdef CONFIG_SYSCTL
 
 /*
@@ -525,6 +586,7 @@ module_param(nlm_max_connections, uint, 0644);
 
 static int __init init_nlm(void)
 {
+	drc_reply_cache_init(&nlm_dc);
 #ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
 	return nlm_sysctl_table ? 0 : -ENOMEM;
@@ -536,6 +598,7 @@ static int __init init_nlm(void)
 static void __exit exit_nlm(void)
 {
 	/* FIXME: delete all NLM clients */
+	drc_reply_cache_shutdown(&nlm_dc);
 	nlm_shutdown_hosts();
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
@@ -552,12 +615,14 @@ static struct svc_version	nlmsvc_version1 = {
 		.vs_vers	= 1,
 		.vs_nproc	= 17,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch	= nlm_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 static struct svc_version	nlmsvc_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch    = nlm_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
@@ -565,6 +630,7 @@ static struct svc_version	nlmsvc_version4 = {
 		.vs_vers	= 4,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures4,
+		.vs_dispatch    = nlm_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index bd173a6..e78cb89 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -13,6 +13,7 @@
 #include <linux/smp_lock.h>
 #include <linux/in.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
@@ -468,7 +469,7 @@ nlm4svc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
 
 struct nlm_void			{ int dummy; };
 
-#define PROC(name, xargt, xrest, argt, rest, respsize)	\
+#define PROC(name, xargt, xrest, argt, rest, respsize, cache)	\
  { .pc_func	= (svc_procfunc) nlm4svc_proc_##name,	\
    .pc_decode	= (kxdrproc_t) nlm4svc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
@@ -476,36 +477,37 @@ struct nlm_void			{ int dummy; };
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
    .pc_xdrressize = respsize,				\
+   .pc_cachetype = cache, 				\
  }
 #define	Ck	(1+XDR_QUADLEN(NLM_MAXCOOKIELEN))	/* cookie */
 #define	No	(1+1024/4)				/* netobj */
 #define	St	1					/* status */
 #define	Rg	4					/* range (offset + length) */
 struct svc_procedure		nlmsvc_procedures4[] = {
-  PROC(null,		void,		void,		void,	void, 1),
-  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
-  PROC(lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(cancel,		cancargs,	res,		args,	res, Ck+St),
-  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St),
-  PROC(granted,		testargs,	res,		args,	res, Ck+St),
-  PROC(test_msg,	testargs,	norep,		args,	void, 1),
-  PROC(lock_msg,	lockargs,	norep,		args,	void, 1),
-  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1),
-  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1),
-  PROC(granted_msg,	testargs,	norep,		args,	void, 1),
-  PROC(test_res,	testres,	norep,		res,	void, 1),
-  PROC(lock_res,	lockres,	norep,		res,	void, 1),
-  PROC(cancel_res,	cancelres,	norep,		res,	void, 1),
-  PROC(unlock_res,	unlockres,	norep,		res,	void, 1),
-  PROC(granted_res,	res,		norep,		res,	void, 1),
+  PROC(null,		void,		void,		void,	void, 1, RC_NOCACHE),
+  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg, RC_NOCACHE),
+  PROC(lock,		lockargs,	res,		args,	res, Ck+St, RC_REPLSTAT),
+  PROC(cancel,		cancargs,	res,		args,	res, Ck+St, RC_NOCACHE),
+  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St, RC_NOCACHE),
+  PROC(granted,		testargs,	res,		args,	res, Ck+St, RC_NOCACHE),
+  PROC(test_msg,	testargs,	norep,		args,	void, 1, RC_NOCACHE),
+  PROC(lock_msg,	lockargs,	norep,		args,	void, 1, RC_NOCACHE),
+  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1, RC_NOCACHE),
+  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1, RC_NOCACHE),
+  PROC(granted_msg,	testargs,	norep,		args,	void, 1, RC_NOCACHE),
+  PROC(test_res,	testres,	norep,		res,	void, 1, RC_NOCACHE),
+  PROC(lock_res,	lockres,	norep,		res,	void, 1, RC_NOCACHE),
+  PROC(cancel_res,	cancelres,	norep,		res,	void, 1, RC_NOCACHE),
+  PROC(unlock_res,	unlockres,	norep,		res,	void, 1, RC_NOCACHE),
+  PROC(granted_res,	res,		norep,		res,	void, 1, RC_NOCACHE),
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(free_all,	notify,		void,		args,	void, 1),
+  PROC(sm_notify,	reboot,		void,		reboot,	void, 1, RC_NOCACHE),
+  PROC(none,		void,		void,		void,	void, 0, RC_NOCACHE),
+  PROC(none,		void,		void,		void,	void, 0, RC_NOCACHE),
+  PROC(none,		void,		void,		void,	void, 0, RC_NOCACHE),
+  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1, RC_NOCACHE),
+  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1, RC_NOCACHE),
+  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St, RC_NOCACHE),
+  PROC(free_all,	notify,		void,		args,	void, 1, RC_NOCACHE),
 
 };
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a34dea4..7bfea5c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -198,6 +198,12 @@ extern int			nsm_use_hostnames;
 extern u32			nsm_local_state;
 
 /*
+ * DRC for NLM
+ */
+
+int nlm_dispatch(struct svc_rqst *rqstp, u32 *stap);
+
+/*
  * Lockd client functions
  */
 struct nlm_rqst * nlm_alloc_call(struct nlm_host *host);
-- 
1.6.2


