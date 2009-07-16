From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: [PATCH 3/4] NLM: Kill PROC macro from NLMv1 and NLMv3 client procedures
Date: Thu, 16 Jul 2009 17:31:45 +0800
Message-ID: <4A5EF381.7010101@cn.fujitsu.com>
References: <4A5EF29B.1050100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51698 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754682AbZGPJch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 05:32:37 -0400
In-Reply-To: <4A5EF29B.1050100@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to make the code more clear, kill PROC macro from NLMv1 and NLMv3
client procedures.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/lockd/xdr.c |  201 +++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 171 insertions(+), 30 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 0336f2b..1b36274 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -536,38 +536,179 @@ nlmclt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
  */
 #define nlmclt_decode_norep	NULL
 
-#define PROC(proc, argtype, restype)	\
-[NLMPROC_##proc] = {							\
-	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
-	.p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
-	.p_arglen    = NLM_##argtype##_sz,				\
-	.p_replen    = NLM_##restype##_sz,				\
-	.p_statidx   = NLMPROC_##proc,					\
-	.p_name      = #proc,						\
-	}
-
 static struct rpc_procinfo	nlm_procedures[] = {
-    PROC(TEST,		testargs,	testres),
-    PROC(LOCK,		lockargs,	res),
-    PROC(CANCEL,	cancargs,	res),
-    PROC(UNLOCK,	unlockargs,	res),
-    PROC(GRANTED,	testargs,	res),
-    PROC(TEST_MSG,	testargs,	norep),
-    PROC(LOCK_MSG,	lockargs,	norep),
-    PROC(CANCEL_MSG,	cancargs,	norep),
-    PROC(UNLOCK_MSG,	unlockargs,	norep),
-    PROC(GRANTED_MSG,	testargs,	norep),
-    PROC(TEST_RES,	testres,	norep),
-    PROC(LOCK_RES,	res,		norep),
-    PROC(CANCEL_RES,	res,		norep),
-    PROC(UNLOCK_RES,	res,		norep),
-    PROC(GRANTED_RES,	res,		norep),
+	[NLMPROC_TEST] = {
+		.p_proc		= NLMPROC_TEST,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_testargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_testres,
+		.p_arglen	= NLM_testargs_sz,
+		.p_replen	= NLM_testres_sz,
+		.p_statidx	= NLMPROC_TEST,
+		.p_name		= "TEST",
+	},
+	[NLMPROC_LOCK] = {
+		.p_proc		= NLMPROC_LOCK,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_lockargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_res,
+		.p_arglen	= NLM_lockargs_sz,
+		.p_replen	= NLM_res_sz,
+		.p_statidx	= NLMPROC_LOCK,
+		.p_name		= "LOCK",
+	},
+	[NLMPROC_CANCEL] = {
+		.p_proc		= NLMPROC_CANCEL,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_cancargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_res,
+		.p_arglen	= NLM_cancargs_sz,
+		.p_replen	= NLM_res_sz,
+		.p_statidx	= NLMPROC_CANCEL,
+		.p_name		= "CANCEL",
+	},
+	[NLMPROC_UNLOCK] = {
+		.p_proc		= NLMPROC_UNLOCK,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_unlockargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_res,
+		.p_arglen	= NLM_unlockargs_sz,
+		.p_replen	= NLM_res_sz,
+		.p_statidx	= NLMPROC_UNLOCK,
+		.p_name		= "UNLOCK",
+	},
+	[NLMPROC_GRANTED] = {
+		.p_proc		= NLMPROC_GRANTED,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_testargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_res,
+		.p_arglen	= NLM_testargs_sz,
+		.p_replen	= NLM_res_sz,
+		.p_statidx	= NLMPROC_GRANTED,
+		.p_name		= "GRANTED",
+	},
+	[NLMPROC_TEST_MSG] = {
+		.p_proc		= NLMPROC_TEST_MSG,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_testargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_testargs_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_TEST_MSG,
+		.p_name		= "TEST_MSG",
+	},
+	[NLMPROC_LOCK_MSG] = {
+		.p_proc		= NLMPROC_LOCK_MSG,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_lockargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_lockargs_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_LOCK_MSG,
+		.p_name		= "LOCK_MSG",
+	},
+	[NLMPROC_CANCEL_MSG] = {
+		.p_proc		= NLMPROC_CANCEL_MSG,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_cancargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_cancargs_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_CANCEL_MSG,
+		.p_name		= "CANCEL_MSG",
+	},
+	[NLMPROC_UNLOCK_MSG] = {
+		.p_proc		= NLMPROC_UNLOCK_MSG,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_unlockargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_unlockargs_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_UNLOCK_MSG,
+		.p_name		= "UNLOCK_MSG",
+	},
+	[NLMPROC_GRANTED_MSG] = {
+		.p_proc		= NLMPROC_GRANTED_MSG,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_testargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_testargs_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_GRANTED_MSG,
+		.p_name		= "GRANTED_MSG",
+	},
+	[NLMPROC_TEST_RES] = {
+		.p_proc		= NLMPROC_TEST_RES,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_testres,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_testres_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_TEST_RES,
+		.p_name		= "TEST_RES",
+	},
+	[NLMPROC_LOCK_RES] = {
+		.p_proc		= NLMPROC_LOCK_RES,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_res,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_res_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_LOCK_RES,
+		.p_name		= "LOCK_RES",
+	},
+	[NLMPROC_CANCEL_RES] = {
+		.p_proc		= NLMPROC_CANCEL_RES,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_res,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_res_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_CANCEL_RES,
+		.p_name		= "CANCEL_RES",
+	},
+	[NLMPROC_UNLOCK_RES] = {
+		.p_proc		= NLMPROC_UNLOCK_RES,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_res,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_res_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_UNLOCK_RES,
+		.p_name		= "UNLOCK_RES",
+	},
+	[NLMPROC_GRANTED_RES] = {
+		.p_proc		= NLMPROC_GRANTED_RES,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_res,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_norep,
+		.p_arglen	= NLM_res_sz,
+		.p_replen	= NLM_norep_sz,
+		.p_statidx	= NLMPROC_GRANTED_RES,
+		.p_name		= "GRANTED_RES",
+	},
 #ifdef NLMCLNT_SUPPORT_SHARES
-    PROC(SHARE,		shareargs,	shareres),
-    PROC(UNSHARE,	shareargs,	shareres),
-    PROC(NM_LOCK,	lockargs,	res),
-    PROC(FREE_ALL,	notify,		void),
+	[NLMPROC_SHARE] = {
+		.p_proc		= NLMPROC_SHARE,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_shareargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_shareres,
+		.p_arglen	= NLM_shareargs_sz,
+		.p_replen	= NLM_shareres_sz,
+		.p_statidx	= NLMPROC_SHARE,
+		.p_name		= "SHARE",
+	},
+	[NLMPROC_UNSHARE] = {
+		.p_proc		= NLMPROC_UNSHARE,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_shareargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_shareres,
+		.p_arglen	= NLM_shareargs_sz,
+		.p_replen	= NLM_shareres_sz,
+		.p_statidx	= NLMPROC_UNSHARE,
+		.p_name		= "UNSHARE",
+	},
+	[NLMPROC_NM_LOCK] = {
+		.p_proc		= NLMPROC_NM_LOCK,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_lockargs,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_res,
+		.p_arglen	= NLM_lockargs_sz,
+		.p_replen	= NLM_res_sz,
+		.p_statidx	= NLMPROC_NM_LOCK,
+		.p_name		= "NM_LOCK",
+	},
+	[NLMPROC_FREE_ALL] = {
+		.p_proc		= NLMPROC_FREE_ALL,
+		.p_encode	= (kxdrproc_t) nlmclt_encode_notify,
+		.p_decode	= (kxdrproc_t) nlmclt_decode_void,
+		.p_arglen	= NLM_notify_sz,
+		.p_replen	= NLM_void_sz,
+		.p_statidx	= NLMPROC_FREE_ALL,
+		.p_name		= "FREE_ALL",
+	},
 #endif
 };
 
-- 
1.6.0.3



