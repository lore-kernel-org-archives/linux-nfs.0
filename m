From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: [PATCH 1/4] NLM: Kill PROC macro from NLMv1 and NLMv3 server procedures
Date: Thu, 16 Jul 2009 17:29:31 +0800
Message-ID: <4A5EF2FB.1010403@cn.fujitsu.com>
References: <4A5EF29B.1050100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62329 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbZGPJaa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 05:30:30 -0400
In-Reply-To: <4A5EF29B.1050100@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to make the code more clear, PROC macro from NLMv1 and NLMv3
server procedures.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/lockd/svcproc.c |  236 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 202 insertions(+), 34 deletions(-)

diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index e1d28dd..f9596a5 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -499,15 +499,16 @@ nlmsvc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
 
 struct nlm_void			{ int dummy; };
 
-#define PROC(name, xargt, xrest, argt, rest, respsize)	\
- { .pc_func	= (svc_procfunc) nlmsvc_proc_##name,	\
-   .pc_decode	= (kxdrproc_t) nlmsvc_decode_##xargt,	\
-   .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
-   .pc_release	= NULL,					\
-   .pc_argsize	= sizeof(struct nlm_##argt),		\
-   .pc_ressize	= sizeof(struct nlm_##rest),		\
-   .pc_xdrressize = respsize,				\
- }
+#define NLMSVC_NONE_PROC \
+{								\
+	.pc_func	= (svc_procfunc) nlmsvc_proc_none,	\
+	.pc_decode	= (kxdrproc_t) nlmsvc_decode_void,	\
+	.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,	\
+	.pc_release	= NULL,					\
+	.pc_argsize	= sizeof(struct nlm_void),		\
+	.pc_ressize	= sizeof(struct nlm_void),		\
+	.pc_xdrressize	= 1,					\
+}
 
 #define	Ck	(1+XDR_QUADLEN(NLM_MAXCOOKIELEN))	/* cookie */
 #define	St	1				/* status */
@@ -515,30 +516,197 @@ struct nlm_void			{ int dummy; };
 #define	Rg	2				/* range - offset + size */
 
 struct svc_procedure		nlmsvc_procedures[] = {
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
+	[NLMPROC_NULL] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_null,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_void,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_void),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_TEST] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_test,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_testargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_testres,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St+2+No+Rg,
+	},
+	[NLMPROC_LOCK] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_lock,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_lockargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_res,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St,
+	},
+	[NLMPROC_CANCEL] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_cancel,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_cancargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_res,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St,
+	},
+	[NLMPROC_UNLOCK] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_unlock,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_unlockargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_res,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St,
+	},
+	[NLMPROC_GRANTED] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_granted,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_testargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_res,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St,
+	},
+	[NLMPROC_TEST_MSG] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_test_msg,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_testargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_LOCK_MSG] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_lock_msg,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_lockargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_CANCEL_MSG] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_cancel_msg,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_cancargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_UNLOCK_MSG] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_unlock_msg,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_unlockargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_GRANTED_MSG] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_granted_msg,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_testargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_TEST_RES] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_test_res,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_testres,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_res),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_LOCK_RES] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_lock_res,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_lockres,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_res),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_CANCEL_RES] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_cancel_res,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_cancelres,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_res),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_UNLOCK_RES] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_unlock_res,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_unlockres,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_res),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	[NLMPROC_GRANTED_RES] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_granted_res,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_res,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_norep,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_res),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(free_all,	notify,		void,		args,	void, 0),
-
+	[NLMPROC_NSM_NOTIFY] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_sm_notify,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_reboot,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_reboot),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 1,
+	},
+	NLMSVC_NONE_PROC,
+	NLMSVC_NONE_PROC,
+	NLMSVC_NONE_PROC,
+	[NLMPROC_SHARE] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_share,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_shareargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_shareres,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St+1,
+	},
+	[NLMPROC_UNSHARE] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_unshare,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_shareargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_shareres,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St+1,
+	},
+	[NLMPROC_NM_LOCK] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_nm_lock,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_lockargs,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_res,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_res),
+		.pc_xdrressize	= Ck+St,
+	},
+	[NLMPROC_FREE_ALL] = {
+		.pc_func	= (svc_procfunc) nlmsvc_proc_free_all,
+		.pc_decode	= (kxdrproc_t) nlmsvc_decode_notify,
+		.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,
+		.pc_release	= NULL,
+		.pc_argsize	= sizeof(struct nlm_args),
+		.pc_ressize	= sizeof(struct nlm_void),
+		.pc_xdrressize	= 0,
+	},
 };
-- 
1.6.0.3



