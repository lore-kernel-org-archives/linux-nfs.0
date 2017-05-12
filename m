Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39755 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932359AbdELQSO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:14 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 21/33] sunrpc: properly type pc_func callbacks
Date: Fri, 12 May 2017 18:16:49 +0200
Message-Id: <20170512161701.22468-22-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop the argp and resp arguments as they can trivially be derived from
the rqstp argument.  With that all functions now have the same prototype,
and we can remove the unsafe casting to svc_procfunc as well as the
svc_procfunc typedef itself.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/svc4proc.c        | 118 ++++++++++++++++++++++-------------
 fs/lockd/svcproc.c         | 118 ++++++++++++++++++++++-------------
 fs/nfs/callback_xdr.c      |   7 ++-
 fs/nfsd/nfs2acl.c          |  25 ++++----
 fs/nfsd/nfs3acl.c          |  15 ++---
 fs/nfsd/nfs3proc.c         | 151 ++++++++++++++++++++++++++-------------------
 fs/nfsd/nfs4proc.c         |   9 +--
 fs/nfsd/nfsproc.c          | 104 +++++++++++++++++--------------
 fs/nfsd/nfssvc.c           |   2 +-
 include/linux/sunrpc/svc.h |   4 +-
 net/sunrpc/svc.c           |   2 +-
 11 files changed, 328 insertions(+), 227 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 09c576f26c7b..3e4cba029d3d 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -62,7 +62,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
  * NULL: Test for presence of service
  */
 static __be32
-nlm4svc_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nlm4svc_proc_null(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: NULL          called\n");
 	return rpc_success;
@@ -72,9 +72,9 @@ nlm4svc_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
  * TEST: Check for conflicting lock
  */
 static __be32
-nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
-				         struct nlm_res  *resp)
+__nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	__be32 rc = rpc_success;
@@ -99,9 +99,15 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 }
 
 static __be32
-nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				         struct nlm_res  *resp)
+nlm4svc_proc_test(struct svc_rqst *rqstp)
 {
+	return __nlm4svc_proc_test(rqstp, rqstp->rq_resp);
+}
+
+static __be32
+__nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_res *resp)
+{
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	__be32 rc = rpc_success;
@@ -141,9 +147,15 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 }
 
 static __be32
-nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
-				           struct nlm_res  *resp)
+nlm4svc_proc_lock(struct svc_rqst *rqstp)
+{
+	return __nlm4svc_proc_lock(rqstp, rqstp->rq_resp);
+}
+
+static __be32
+__nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -170,13 +182,19 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlm4svc_proc_cancel(struct svc_rqst *rqstp)
+{
+	return __nlm4svc_proc_cancel(rqstp, rqstp->rq_resp);
+}
+
 /*
  * UNLOCK: release a lock
  */
 static __be32
-nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				           struct nlm_res  *resp)
+__nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -203,14 +221,21 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlm4svc_proc_unlock(struct svc_rqst *rqstp)
+{
+	return __nlm4svc_proc_unlock(rqstp, rqstp->rq_resp);
+}
+
 /*
  * GRANTED: A server calls us to tell that a process' lock request
  * was granted
  */
 static __be32
-nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+__nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
@@ -219,6 +244,12 @@ nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlm4svc_proc_granted(struct svc_rqst *rqstp)
+{
+	return __nlm4svc_proc_granted(rqstp, rqstp->rq_resp);
+}
+
 /*
  * This is the generic lockd callback for async RPC calls
  */
@@ -243,9 +274,10 @@ static const struct rpc_call_ops nlm4svc_callback_ops = {
  * because we send the callback before the reply proper. I hope this
  * doesn't break any clients.
  */
-static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args *argp,
-		__be32 (*func)(struct svc_rqst *, struct nlm_args *, struct nlm_res  *))
+static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc,
+		__be32 (*func)(struct svc_rqst *,  struct nlm_res *))
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_rqst	*call;
 	__be32 stat;
@@ -261,7 +293,7 @@ static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 	if (call == NULL)
 		return rpc_system_err;
 
-	stat = func(rqstp, argp, &call->a_res);
+	stat = func(rqstp, &call->a_res);
 	if (stat != 0) {
 		nlmsvc_release_call(call);
 		return stat;
@@ -273,48 +305,44 @@ static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 	return rpc_success;
 }
 
-static __be32 nlm4svc_proc_test_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void	     *resp)
+static __be32 nlm4svc_proc_test_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: TEST_MSG      called\n");
-	return nlm4svc_callback(rqstp, NLMPROC_TEST_RES, argp, nlm4svc_proc_test);
+	return nlm4svc_callback(rqstp, NLMPROC_TEST_RES, __nlm4svc_proc_test);
 }
 
-static __be32 nlm4svc_proc_lock_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void	     *resp)
+static __be32 nlm4svc_proc_lock_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: LOCK_MSG      called\n");
-	return nlm4svc_callback(rqstp, NLMPROC_LOCK_RES, argp, nlm4svc_proc_lock);
+	return nlm4svc_callback(rqstp, NLMPROC_LOCK_RES, __nlm4svc_proc_lock);
 }
 
-static __be32 nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					       void	       *resp)
+static __be32 nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: CANCEL_MSG    called\n");
-	return nlm4svc_callback(rqstp, NLMPROC_CANCEL_RES, argp, nlm4svc_proc_cancel);
+	return nlm4svc_callback(rqstp, NLMPROC_CANCEL_RES, __nlm4svc_proc_cancel);
 }
 
-static __be32 nlm4svc_proc_unlock_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-                                               void            *resp)
+static __be32 nlm4svc_proc_unlock_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: UNLOCK_MSG    called\n");
-	return nlm4svc_callback(rqstp, NLMPROC_UNLOCK_RES, argp, nlm4svc_proc_unlock);
+	return nlm4svc_callback(rqstp, NLMPROC_UNLOCK_RES, __nlm4svc_proc_unlock);
 }
 
-static __be32 nlm4svc_proc_granted_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-                                                void            *resp)
+static __be32 nlm4svc_proc_granted_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: GRANTED_MSG   called\n");
-	return nlm4svc_callback(rqstp, NLMPROC_GRANTED_RES, argp, nlm4svc_proc_granted);
+	return nlm4svc_callback(rqstp, NLMPROC_GRANTED_RES, __nlm4svc_proc_granted);
 }
 
 /*
  * SHARE: create a DOS share or alter existing share.
  */
 static __be32
-nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
-				          struct nlm_res  *resp)
+nlm4svc_proc_share(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+	struct nlm_res *resp = rqstp->rq_resp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -345,9 +373,10 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
  * UNSHARE: Release a DOS share.
  */
 static __be32
-nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+nlm4svc_proc_unshare(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+	struct nlm_res *resp = rqstp->rq_resp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -378,22 +407,23 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
  * NM_LOCK: Create an unmonitored lock
  */
 static __be32
-nlm4svc_proc_nm_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+nlm4svc_proc_nm_lock(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	dprintk("lockd: NM_LOCK       called\n");
 
 	argp->monitor = 0;		/* just clean the monitor flag */
-	return nlm4svc_proc_lock(rqstp, argp, resp);
+	return nlm4svc_proc_lock(rqstp);
 }
 
 /*
  * FREE_ALL: Release all locks and shares held by client
  */
 static __be32
-nlm4svc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void            *resp)
+nlm4svc_proc_free_all(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 
 	/* Obtain client */
@@ -409,9 +439,10 @@ nlm4svc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
  * SM_NOTIFY: private callback from statd (not part of official NLM proto)
  */
 static __be32
-nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
-					      void	        *resp)
+nlm4svc_proc_sm_notify(struct svc_rqst *rqstp)
 {
+	struct nlm_reboot *argp = rqstp->rq_argp;
+
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -429,9 +460,10 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
  * client sent a GRANTED_RES, let's remove the associated block
  */
 static __be32
-nlm4svc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
-                                                void            *resp)
+nlm4svc_proc_granted_res(struct svc_rqst *rqstp)
 {
+	struct nlm_res *argp = rqstp->rq_argp;
+
         if (!nlmsvc_ops)
                 return rpc_success;
 
@@ -463,7 +495,7 @@ nlm4svc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
 struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
- { .pc_func	= (svc_procfunc) nlm4svc_proc_##name,	\
+ { .pc_func	= nlm4svc_proc_##name,	\
    .pc_decode	= (kxdrproc_t) nlm4svc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
    .pc_release	= NULL,					\
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index fb26b9f522e7..3add50661fab 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -92,7 +92,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
  * NULL: Test for presence of service
  */
 static __be32
-nlmsvc_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nlmsvc_proc_null(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: NULL          called\n");
 	return rpc_success;
@@ -102,9 +102,9 @@ nlmsvc_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
  * TEST: Check for conflicting lock
  */
 static __be32
-nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
-				         struct nlm_res  *resp)
+__nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	__be32 rc = rpc_success;
@@ -130,9 +130,15 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 }
 
 static __be32
-nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				         struct nlm_res  *resp)
+nlmsvc_proc_test(struct svc_rqst *rqstp)
 {
+	return __nlmsvc_proc_test(rqstp, rqstp->rq_resp);
+}
+
+static __be32
+__nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_res *resp)
+{
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	__be32 rc = rpc_success;
@@ -172,9 +178,15 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 }
 
 static __be32
-nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
-				           struct nlm_res  *resp)
+nlmsvc_proc_lock(struct svc_rqst *rqstp)
+{
+	return __nlmsvc_proc_lock(rqstp, rqstp->rq_resp);
+}
+
+static __be32
+__nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	struct net *net = SVC_NET(rqstp);
@@ -202,13 +214,19 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlmsvc_proc_cancel(struct svc_rqst *rqstp)
+{
+	return __nlmsvc_proc_cancel(rqstp, rqstp->rq_resp);
+}
+
 /*
  * UNLOCK: release a lock
  */
 static __be32
-nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				           struct nlm_res  *resp)
+__nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 	struct net *net = SVC_NET(rqstp);
@@ -236,14 +254,21 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlmsvc_proc_unlock(struct svc_rqst *rqstp)
+{
+	return __nlmsvc_proc_unlock(rqstp, rqstp->rq_resp);
+}
+
 /*
  * GRANTED: A server calls us to tell that a process' lock request
  * was granted
  */
 static __be32
-nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+__nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_res *resp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
@@ -252,6 +277,12 @@ nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return rpc_success;
 }
 
+static __be32
+nlmsvc_proc_granted(struct svc_rqst *rqstp)
+{
+	return __nlmsvc_proc_granted(rqstp, rqstp->rq_resp);
+}
+
 /*
  * This is the generic lockd callback for async RPC calls
  */
@@ -284,9 +315,10 @@ static const struct rpc_call_ops nlmsvc_callback_ops = {
  * because we send the callback before the reply proper. I hope this
  * doesn't break any clients.
  */
-static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args *argp,
-		__be32 (*func)(struct svc_rqst *, struct nlm_args *, struct nlm_res  *))
+static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc,
+		__be32 (*func)(struct svc_rqst *, struct nlm_res *))
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 	struct nlm_rqst	*call;
 	__be32 stat;
@@ -302,7 +334,7 @@ static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 	if (call == NULL)
 		return rpc_system_err;
 
-	stat = func(rqstp, argp, &call->a_res);
+	stat = func(rqstp, &call->a_res);
 	if (stat != 0) {
 		nlmsvc_release_call(call);
 		return stat;
@@ -314,50 +346,46 @@ static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 	return rpc_success;
 }
 
-static __be32 nlmsvc_proc_test_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void	     *resp)
+static __be32 nlmsvc_proc_test_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: TEST_MSG      called\n");
-	return nlmsvc_callback(rqstp, NLMPROC_TEST_RES, argp, nlmsvc_proc_test);
+	return nlmsvc_callback(rqstp, NLMPROC_TEST_RES, __nlmsvc_proc_test);
 }
 
-static __be32 nlmsvc_proc_lock_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void	     *resp)
+static __be32 nlmsvc_proc_lock_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: LOCK_MSG      called\n");
-	return nlmsvc_callback(rqstp, NLMPROC_LOCK_RES, argp, nlmsvc_proc_lock);
+	return nlmsvc_callback(rqstp, NLMPROC_LOCK_RES, __nlmsvc_proc_lock);
 }
 
-static __be32 nlmsvc_proc_cancel_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-					       void	       *resp)
+static __be32 nlmsvc_proc_cancel_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: CANCEL_MSG    called\n");
-	return nlmsvc_callback(rqstp, NLMPROC_CANCEL_RES, argp, nlmsvc_proc_cancel);
+	return nlmsvc_callback(rqstp, NLMPROC_CANCEL_RES, __nlmsvc_proc_cancel);
 }
 
 static __be32
-nlmsvc_proc_unlock_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-                                               void            *resp)
+nlmsvc_proc_unlock_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: UNLOCK_MSG    called\n");
-	return nlmsvc_callback(rqstp, NLMPROC_UNLOCK_RES, argp, nlmsvc_proc_unlock);
+	return nlmsvc_callback(rqstp, NLMPROC_UNLOCK_RES, __nlmsvc_proc_unlock);
 }
 
 static __be32
-nlmsvc_proc_granted_msg(struct svc_rqst *rqstp, struct nlm_args *argp,
-                                                void            *resp)
+nlmsvc_proc_granted_msg(struct svc_rqst *rqstp)
 {
 	dprintk("lockd: GRANTED_MSG   called\n");
-	return nlmsvc_callback(rqstp, NLMPROC_GRANTED_RES, argp, nlmsvc_proc_granted);
+	return nlmsvc_callback(rqstp, NLMPROC_GRANTED_RES, __nlmsvc_proc_granted);
 }
 
 /*
  * SHARE: create a DOS share or alter existing share.
  */
 static __be32
-nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
-				          struct nlm_res  *resp)
+nlmsvc_proc_share(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+	struct nlm_res *resp = rqstp->rq_resp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -388,9 +416,10 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
  * UNSHARE: Release a DOS share.
  */
 static __be32
-nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+nlmsvc_proc_unshare(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+	struct nlm_res *resp = rqstp->rq_resp;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -421,22 +450,23 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
  * NM_LOCK: Create an unmonitored lock
  */
 static __be32
-nlmsvc_proc_nm_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
-				            struct nlm_res  *resp)
+nlmsvc_proc_nm_lock(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	dprintk("lockd: NM_LOCK       called\n");
 
 	argp->monitor = 0;		/* just clean the monitor flag */
-	return nlmsvc_proc_lock(rqstp, argp, resp);
+	return nlmsvc_proc_lock(rqstp);
 }
 
 /*
  * FREE_ALL: Release all locks and shares held by client
  */
 static __be32
-nlmsvc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
-					     void            *resp)
+nlmsvc_proc_free_all(struct svc_rqst *rqstp)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 
 	/* Obtain client */
@@ -452,9 +482,10 @@ nlmsvc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
  * SM_NOTIFY: private callback from statd (not part of official NLM proto)
  */
 static __be32
-nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
-					      void	        *resp)
+nlmsvc_proc_sm_notify(struct svc_rqst *rqstp)
 {
+	struct nlm_reboot *argp = rqstp->rq_argp;
+
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -472,9 +503,10 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
  * client sent a GRANTED_RES, let's remove the associated block
  */
 static __be32
-nlmsvc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
-                                                void            *resp)
+nlmsvc_proc_granted_res(struct svc_rqst *rqstp)
 {
+	struct nlm_res *argp = rqstp->rq_argp;
+
 	if (!nlmsvc_ops)
 		return rpc_success;
 
@@ -505,7 +537,7 @@ nlmsvc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
 struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
- { .pc_func	= (svc_procfunc) nlmsvc_proc_##name,	\
+ { .pc_func	= nlmsvc_proc_##name,			\
    .pc_decode	= (kxdrproc_t) nlmsvc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
    .pc_release	= NULL,					\
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 287c02202b25..5a14bdaa5986 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -53,7 +53,7 @@ struct callback_op {
 
 static struct callback_op callback_ops[];
 
-static __be32 nfs4_callback_null(struct svc_rqst *rqstp, void *argp, void *resp)
+static __be32 nfs4_callback_null(struct svc_rqst *rqstp)
 {
 	return htonl(NFS4_OK);
 }
@@ -880,7 +880,7 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 /*
  * Decode, process and encode a COMPOUND
  */
-static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *resp)
+static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 {
 	struct cb_compound_hdr_arg hdr_arg = { 0 };
 	struct cb_compound_hdr_res hdr_res = { NULL };
@@ -916,7 +916,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	while (status == 0 && nops != hdr_arg.nops) {
 		status = process_op(nops, rqstp, &xdr_in,
-				    argp, &xdr_out, resp, &cps);
+				    rqstp->rq_argp, &xdr_out, rqstp->rq_resp,
+				    &cps);
 		nops++;
 	}
 
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 12933d07204c..4b7f84fa1fa5 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -19,7 +19,7 @@
  * NULL call.
  */
 static __be32
-nfsacld_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nfsacld_proc_null(struct svc_rqst *rqstp)
 {
 	return nfs_ok;
 }
@@ -27,9 +27,10 @@ nfsacld_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 /*
  * Get the Access and/or Default ACL of a file.
  */
-static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
-		struct nfsd3_getaclargs *argp, struct nfsd3_getaclres *resp)
+static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
 	struct posix_acl *acl;
 	struct inode *inode;
 	svc_fh *fh;
@@ -87,10 +88,10 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
 /*
  * Set the Access and/or Default ACL of a file.
  */
-static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
-		struct nfsd3_setaclargs *argp,
-		struct nfsd_attrstat *resp)
+static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	struct inode *inode;
 	svc_fh *fh;
 	__be32 nfserr = 0;
@@ -141,9 +142,10 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
 /*
  * Check file attributes
  */
-static __be32 nfsacld_proc_getattr(struct svc_rqst * rqstp,
-		struct nfsd_fhandle *argp, struct nfsd_attrstat *resp)
+static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	__be32 nfserr;
 	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
 
@@ -158,9 +160,10 @@ static __be32 nfsacld_proc_getattr(struct svc_rqst * rqstp,
 /*
  * Check file access
  */
-static __be32 nfsacld_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessargs *argp,
-		struct nfsd3_accessres *resp)
+static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 {
+	struct nfsd3_accessargs *argp = rqstp->rq_argp;
+	struct nfsd3_accessres *resp = rqstp->rq_resp;
 	__be32 nfserr;
 
 	dprintk("nfsd: ACCESS(2acl)   %s 0x%x\n",
@@ -347,7 +350,7 @@ struct nfsd3_voidargs { int dummy; };
 
 #define PROC(name, argt, rest, relt, cache, respsize)			\
 {									\
-	.pc_func	= (svc_procfunc) nfsacld_proc_##name,		\
+	.pc_func	= nfsacld_proc_##name,				\
 	.pc_decode	= (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
 	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
 	.pc_release	= (kxdrproc_t) nfsaclsvc_release_##relt,	\
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index db988a229b3a..5e42004035e0 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -18,7 +18,7 @@
  * NULL call.
  */
 static __be32
-nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nfsd3_proc_null(struct svc_rqst *rqstp)
 {
 	return nfs_ok;
 }
@@ -26,9 +26,10 @@ nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 /*
  * Get the Access and/or Default ACL of a file.
  */
-static __be32 nfsd3_proc_getacl(struct svc_rqst * rqstp,
-		struct nfsd3_getaclargs *argp, struct nfsd3_getaclres *resp)
+static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
 	struct posix_acl *acl;
 	struct inode *inode;
 	svc_fh *fh;
@@ -80,10 +81,10 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst * rqstp,
 /*
  * Set the Access and/or Default ACL of a file.
  */
-static __be32 nfsd3_proc_setacl(struct svc_rqst * rqstp,
-		struct nfsd3_setaclargs *argp,
-		struct nfsd3_attrstat *resp)
+static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
 	struct inode *inode;
 	svc_fh *fh;
 	__be32 nfserr = 0;
@@ -239,7 +240,7 @@ struct nfsd3_voidargs { int dummy; };
 
 #define PROC(name, argt, rest, relt, cache, respsize)			\
 {									\
-	.pc_func	= (svc_procfunc) nfsd3_proc_##name,		\
+	.pc_func	= nfsd3_proc_##name,				\
 	.pc_decode	= (kxdrproc_t) nfs3svc_decode_##argt##args,	\
 	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
 	.pc_release	= (kxdrproc_t) nfs3svc_release_##relt,		\
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 24e035190770..4a2bae07cfbf 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -31,7 +31,7 @@ static int	nfs3_ftypes[] = {
  * NULL call.
  */
 static __be32
-nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nfsd3_proc_null(struct svc_rqst *rqstp)
 {
 	return nfs_ok;
 }
@@ -40,9 +40,10 @@ nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
  * Get a file's attributes
  */
 static __be32
-nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
-					   struct nfsd3_attrstat *resp)
+nfsd3_proc_getattr(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: GETATTR(3)  %s\n",
@@ -63,9 +64,10 @@ nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
  * Set a file's attributes
  */
 static __be32
-nfsd3_proc_setattr(struct svc_rqst *rqstp, struct nfsd3_sattrargs *argp,
-					   struct nfsd3_attrstat  *resp)
+nfsd3_proc_setattr(struct svc_rqst *rqstp)
 {
+	struct nfsd3_sattrargs *argp = rqstp->rq_argp;
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: SETATTR(3)  %s\n",
@@ -81,9 +83,10 @@ nfsd3_proc_setattr(struct svc_rqst *rqstp, struct nfsd3_sattrargs *argp,
  * Look up a path name component
  */
 static __be32
-nfsd3_proc_lookup(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
-					  struct nfsd3_diropres  *resp)
+nfsd3_proc_lookup(struct svc_rqst *rqstp)
 {
+	struct nfsd3_diropargs *argp = rqstp->rq_argp;
+	struct nfsd3_diropres  *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: LOOKUP(3)   %s %.*s\n",
@@ -105,9 +108,10 @@ nfsd3_proc_lookup(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
  * Check file access
  */
 static __be32
-nfsd3_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessargs *argp,
-					  struct nfsd3_accessres *resp)
+nfsd3_proc_access(struct svc_rqst *rqstp)
 {
+	struct nfsd3_accessargs *argp = rqstp->rq_argp;
+	struct nfsd3_accessres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: ACCESS(3)   %s 0x%x\n",
@@ -124,9 +128,10 @@ nfsd3_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessargs *argp,
  * Read a symlink.
  */
 static __be32
-nfsd3_proc_readlink(struct svc_rqst *rqstp, struct nfsd3_readlinkargs *argp,
-					   struct nfsd3_readlinkres *resp)
+nfsd3_proc_readlink(struct svc_rqst *rqstp)
 {
+	struct nfsd3_readlinkargs *argp = rqstp->rq_argp;
+	struct nfsd3_readlinkres *resp = rqstp->rq_resp;
 	__be32 nfserr;
 
 	dprintk("nfsd: READLINK(3) %s\n", SVCFH_fmt(&argp->fh));
@@ -142,9 +147,10 @@ nfsd3_proc_readlink(struct svc_rqst *rqstp, struct nfsd3_readlinkargs *argp,
  * Read a portion of a file.
  */
 static __be32
-nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
-				        struct nfsd3_readres  *resp)
+nfsd3_proc_read(struct svc_rqst *rqstp)
 {
+	struct nfsd3_readargs *argp = rqstp->rq_argp;
+	struct nfsd3_readres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	u32	max_blocksize = svc_max_payload(rqstp);
 	unsigned long cnt = min(argp->count, max_blocksize);
@@ -179,9 +185,10 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
  * Write data to a file
  */
 static __be32
-nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
-					 struct nfsd3_writeres  *resp)
+nfsd3_proc_write(struct svc_rqst *rqstp)
 {
+	struct nfsd3_writeargs *argp = rqstp->rq_argp;
+	struct nfsd3_writeres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	unsigned long cnt = argp->len;
 
@@ -206,9 +213,10 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
  * first reports about SunOS compatibility problems start to pour in...
  */
 static __be32
-nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
-					  struct nfsd3_diropres   *resp)
+nfsd3_proc_create(struct svc_rqst *rqstp)
 {
+	struct nfsd3_createargs *argp = rqstp->rq_argp;
+	struct nfsd3_diropres *resp = rqstp->rq_resp;
 	svc_fh		*dirfhp, *newfhp = NULL;
 	struct iattr	*attr;
 	__be32		nfserr;
@@ -243,9 +251,10 @@ nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
  * Make directory. This operation is not idempotent.
  */
 static __be32
-nfsd3_proc_mkdir(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
-					 struct nfsd3_diropres   *resp)
+nfsd3_proc_mkdir(struct svc_rqst *rqstp)
 {
+	struct nfsd3_createargs *argp = rqstp->rq_argp;
+	struct nfsd3_diropres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: MKDIR(3)    %s %.*s\n",
@@ -263,9 +272,10 @@ nfsd3_proc_mkdir(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
 }
 
 static __be32
-nfsd3_proc_symlink(struct svc_rqst *rqstp, struct nfsd3_symlinkargs *argp,
-					   struct nfsd3_diropres    *resp)
+nfsd3_proc_symlink(struct svc_rqst *rqstp)
 {
+	struct nfsd3_symlinkargs *argp = rqstp->rq_argp;
+	struct nfsd3_diropres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: SYMLINK(3)  %s %.*s -> %.*s\n",
@@ -284,9 +294,10 @@ nfsd3_proc_symlink(struct svc_rqst *rqstp, struct nfsd3_symlinkargs *argp,
  * Make socket/fifo/device.
  */
 static __be32
-nfsd3_proc_mknod(struct svc_rqst *rqstp, struct nfsd3_mknodargs *argp,
-					 struct nfsd3_diropres  *resp)
+nfsd3_proc_mknod(struct svc_rqst *rqstp)
 {
+	struct nfsd3_mknodargs *argp = rqstp->rq_argp;
+	struct nfsd3_diropres  *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	int type;
 	dev_t	rdev = 0;
@@ -321,9 +332,10 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp, struct nfsd3_mknodargs *argp,
  * Remove file/fifo/socket etc.
  */
 static __be32
-nfsd3_proc_remove(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
-					  struct nfsd3_attrstat  *resp)
+nfsd3_proc_remove(struct svc_rqst *rqstp)
 {
+	struct nfsd3_diropargs *argp = rqstp->rq_argp;
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: REMOVE(3)   %s %.*s\n",
@@ -342,9 +354,10 @@ nfsd3_proc_remove(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
  * Remove a directory
  */
 static __be32
-nfsd3_proc_rmdir(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
-					 struct nfsd3_attrstat  *resp)
+nfsd3_proc_rmdir(struct svc_rqst *rqstp)
 {
+	struct nfsd3_diropargs *argp = rqstp->rq_argp;
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: RMDIR(3)    %s %.*s\n",
@@ -359,9 +372,10 @@ nfsd3_proc_rmdir(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
 }
 
 static __be32
-nfsd3_proc_rename(struct svc_rqst *rqstp, struct nfsd3_renameargs *argp,
-					  struct nfsd3_renameres  *resp)
+nfsd3_proc_rename(struct svc_rqst *rqstp)
 {
+	struct nfsd3_renameargs *argp = rqstp->rq_argp;
+	struct nfsd3_renameres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: RENAME(3)   %s %.*s ->\n",
@@ -381,9 +395,10 @@ nfsd3_proc_rename(struct svc_rqst *rqstp, struct nfsd3_renameargs *argp,
 }
 
 static __be32
-nfsd3_proc_link(struct svc_rqst *rqstp, struct nfsd3_linkargs *argp,
-					struct nfsd3_linkres  *resp)
+nfsd3_proc_link(struct svc_rqst *rqstp)
 {
+	struct nfsd3_linkargs *argp = rqstp->rq_argp;
+	struct nfsd3_linkres  *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: LINK(3)     %s ->\n",
@@ -404,9 +419,10 @@ nfsd3_proc_link(struct svc_rqst *rqstp, struct nfsd3_linkargs *argp,
  * Read a portion of a directory.
  */
 static __be32
-nfsd3_proc_readdir(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
-					   struct nfsd3_readdirres  *resp)
+nfsd3_proc_readdir(struct svc_rqst *rqstp)
 {
+	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
+	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
 	__be32		nfserr;
 	int		count;
 
@@ -440,9 +456,10 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
  * For now, we choose to ignore the dircount parameter.
  */
 static __be32
-nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
-					       struct nfsd3_readdirres  *resp)
+nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 {
+	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
+	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	int	count = 0;
 	loff_t	offset;
@@ -507,9 +524,10 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
  * Get file system stats
  */
 static __be32
-nfsd3_proc_fsstat(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
-					   struct nfsd3_fsstatres *resp)
+nfsd3_proc_fsstat(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd3_fsstatres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: FSSTAT(3)   %s\n",
@@ -524,9 +542,10 @@ nfsd3_proc_fsstat(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
  * Get file system info
  */
 static __be32
-nfsd3_proc_fsinfo(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
-					   struct nfsd3_fsinfores *resp)
+nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd3_fsinfores *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	u32	max_blocksize = svc_max_payload(rqstp);
 
@@ -567,9 +586,10 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
  * Get pathconf info for the specified file
  */
 static __be32
-nfsd3_proc_pathconf(struct svc_rqst * rqstp, struct nfsd_fhandle      *argp,
-					     struct nfsd3_pathconfres *resp)
+nfsd3_proc_pathconf(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd3_pathconfres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: PATHCONF(3) %s\n",
@@ -610,9 +630,10 @@ nfsd3_proc_pathconf(struct svc_rqst * rqstp, struct nfsd_fhandle      *argp,
  * Commit a file (range) to stable storage.
  */
 static __be32
-nfsd3_proc_commit(struct svc_rqst * rqstp, struct nfsd3_commitargs *argp,
-					   struct nfsd3_commitres  *resp)
+nfsd3_proc_commit(struct svc_rqst *rqstp)
 {
+	struct nfsd3_commitargs *argp = rqstp->rq_argp;
+	struct nfsd3_commitres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: COMMIT(3)   %s %u@%Lu\n",
@@ -655,7 +676,7 @@ struct nfsd3_voidargs { int dummy; };
 
 static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_NULL] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_null,
+		.pc_func = nfsd3_proc_null,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_voidres,
 		.pc_argsize = sizeof(struct nfsd3_voidargs),
 		.pc_ressize = sizeof(struct nfsd3_voidres),
@@ -663,7 +684,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST,
 	},
 	[NFS3PROC_GETATTR] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_getattr,
+		.pc_func = nfsd3_proc_getattr,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_attrstatres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -673,7 +694,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+AT,
 	},
 	[NFS3PROC_SETATTR] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_setattr,
+		.pc_func = nfsd3_proc_setattr,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -683,7 +704,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 	},
 	[NFS3PROC_LOOKUP] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_lookup,
+		.pc_func = nfsd3_proc_lookup,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_diropres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -693,7 +714,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+FH+pAT+pAT,
 	},
 	[NFS3PROC_ACCESS] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_access,
+		.pc_func = nfsd3_proc_access,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_accessargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_accessres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -703,7 +724,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+1,
 	},
 	[NFS3PROC_READLINK] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_readlink,
+		.pc_func = nfsd3_proc_readlink,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readlinkres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -713,7 +734,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+1+NFS3_MAXPATHLEN/4,
 	},
 	[NFS3PROC_READ] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_read,
+		.pc_func = nfsd3_proc_read,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -723,7 +744,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+4+NFSSVC_MAXBLKSIZE/4,
 	},
 	[NFS3PROC_WRITE] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_write,
+		.pc_func = nfsd3_proc_write,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_writeres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -733,7 +754,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC+4,
 	},
 	[NFS3PROC_CREATE] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_create,
+		.pc_func = nfsd3_proc_create,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -743,7 +764,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 	},
 	[NFS3PROC_MKDIR] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_mkdir,
+		.pc_func = nfsd3_proc_mkdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_mkdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -753,7 +774,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 	},
 	[NFS3PROC_SYMLINK] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_symlink,
+		.pc_func = nfsd3_proc_symlink,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_symlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -763,7 +784,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 	},
 	[NFS3PROC_MKNOD] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_mknod,
+		.pc_func = nfsd3_proc_mknod,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_mknodargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -773,7 +794,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 	},
 	[NFS3PROC_REMOVE] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_remove,
+		.pc_func = nfsd3_proc_remove,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -783,7 +804,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 	},
 	[NFS3PROC_RMDIR] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_rmdir,
+		.pc_func = nfsd3_proc_rmdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -793,7 +814,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 	},
 	[NFS3PROC_RENAME] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_rename,
+		.pc_func = nfsd3_proc_rename,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_renameargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_renameres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -803,7 +824,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC+WC,
 	},
 	[NFS3PROC_LINK] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_link,
+		.pc_func = nfsd3_proc_link,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_linkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_linkres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
@@ -813,7 +834,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+WC,
 	},
 	[NFS3PROC_READDIR] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_readdir,
+		.pc_func = nfsd3_proc_readdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -822,7 +843,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_cachetype = RC_NOCACHE,
 	},
 	[NFS3PROC_READDIRPLUS] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_readdirplus,
+		.pc_func = nfsd3_proc_readdirplus,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirplusargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
@@ -831,7 +852,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_cachetype = RC_NOCACHE,
 	},
 	[NFS3PROC_FSSTAT] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_fsstat,
+		.pc_func = nfsd3_proc_fsstat,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsstatres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
@@ -840,7 +861,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+2*6+1,
 	},
 	[NFS3PROC_FSINFO] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_fsinfo,
+		.pc_func = nfsd3_proc_fsinfo,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsinfores,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
@@ -849,7 +870,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+12,
 	},
 	[NFS3PROC_PATHCONF] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_pathconf,
+		.pc_func = nfsd3_proc_pathconf,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_pathconfres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
@@ -858,7 +879,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+6,
 	},
 	[NFS3PROC_COMMIT] = {
-		.pc_func = (svc_procfunc) nfsd3_proc_commit,
+		.pc_func = nfsd3_proc_commit,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_commitargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_commitres,
 		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 695e17605b67..7a0112bc3531 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1510,7 +1510,7 @@ nfsd4_layoutreturn(struct svc_rqst *rqstp,
  * NULL call.
  */
 static __be32
-nfsd4_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nfsd4_proc_null(struct svc_rqst *rqstp)
 {
 	return nfs_ok;
 }
@@ -1524,6 +1524,7 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+
 typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
 typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
 
@@ -1673,10 +1674,10 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
  * COMPOUND call.
  */
 static __be32
-nfsd4_proc_compound(struct svc_rqst *rqstp, void *arg, void *res)
+nfsd4_proc_compound(struct svc_rqst *rqstp)
 {
-	struct nfsd4_compoundargs *args = arg;
-	struct nfsd4_compoundres *resp = res;
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_op	*op;
 	struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 03a7e9da4da0..448505b939db 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -17,7 +17,7 @@ typedef struct svc_buf	svc_buf;
 
 
 static __be32
-nfsd_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+nfsd_proc_null(struct svc_rqst *rqstp)
 {
 	return nfs_ok;
 }
@@ -39,9 +39,10 @@ nfsd_return_dirop(__be32 err, struct nfsd_diropres *resp)
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
-					  struct nfsd_attrstat *resp)
+nfsd_proc_getattr(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	__be32 nfserr;
 	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
 
@@ -56,9 +57,10 @@ nfsd_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_setattr(struct svc_rqst *rqstp, struct nfsd_sattrargs *argp,
-					  struct nfsd_attrstat  *resp)
+nfsd_proc_setattr(struct svc_rqst *rqstp)
 {
+	struct nfsd_sattrargs *argp = rqstp->rq_argp;
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	struct iattr *iap = &argp->attrs;
 	struct svc_fh *fhp;
 	__be32 nfserr;
@@ -122,9 +124,10 @@ nfsd_proc_setattr(struct svc_rqst *rqstp, struct nfsd_sattrargs *argp,
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_lookup(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
-					 struct nfsd_diropres  *resp)
+nfsd_proc_lookup(struct svc_rqst *rqstp)
 {
+	struct nfsd_diropargs *argp = rqstp->rq_argp;
+	struct nfsd_diropres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: LOOKUP   %s %.*s\n",
@@ -142,9 +145,10 @@ nfsd_proc_lookup(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
  * Read a symlink.
  */
 static __be32
-nfsd_proc_readlink(struct svc_rqst *rqstp, struct nfsd_readlinkargs *argp,
-					   struct nfsd_readlinkres *resp)
+nfsd_proc_readlink(struct svc_rqst *rqstp)
 {
+	struct nfsd_readlinkargs *argp = rqstp->rq_argp;
+	struct nfsd_readlinkres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: READLINK %s\n", SVCFH_fmt(&argp->fh));
@@ -162,9 +166,10 @@ nfsd_proc_readlink(struct svc_rqst *rqstp, struct nfsd_readlinkargs *argp,
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
-				       struct nfsd_readres  *resp)
+nfsd_proc_read(struct svc_rqst *rqstp)
 {
+	struct nfsd_readargs *argp = rqstp->rq_argp;
+	struct nfsd_readres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: READ    %s %d bytes at %d\n",
@@ -200,9 +205,10 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
-					struct nfsd_attrstat  *resp)
+nfsd_proc_write(struct svc_rqst *rqstp)
 {
+	struct nfsd_writeargs *argp = rqstp->rq_argp;
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	unsigned long cnt = argp->len;
 
@@ -222,9 +228,10 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
  * N.B. After this call _both_ argp->fh and resp->fh need an fh_put
  */
 static __be32
-nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
-					 struct nfsd_diropres   *resp)
+nfsd_proc_create(struct svc_rqst *rqstp)
 {
+	struct nfsd_createargs *argp = rqstp->rq_argp;
+	struct nfsd_diropres *resp = rqstp->rq_resp;
 	svc_fh		*dirfhp = &argp->fh;
 	svc_fh		*newfhp = &resp->fh;
 	struct iattr	*attr = &argp->attrs;
@@ -377,9 +384,9 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
 }
 
 static __be32
-nfsd_proc_remove(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
-					 void		       *resp)
+nfsd_proc_remove(struct svc_rqst *rqstp)
 {
+	struct nfsd_diropargs *argp = rqstp->rq_argp;
 	__be32	nfserr;
 
 	dprintk("nfsd: REMOVE   %s %.*s\n", SVCFH_fmt(&argp->fh),
@@ -392,9 +399,9 @@ nfsd_proc_remove(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
 }
 
 static __be32
-nfsd_proc_rename(struct svc_rqst *rqstp, struct nfsd_renameargs *argp,
-				  	 void		        *resp)
+nfsd_proc_rename(struct svc_rqst *rqstp)
 {
+	struct nfsd_renameargs *argp = rqstp->rq_argp;
 	__be32	nfserr;
 
 	dprintk("nfsd: RENAME   %s %.*s -> \n",
@@ -410,9 +417,9 @@ nfsd_proc_rename(struct svc_rqst *rqstp, struct nfsd_renameargs *argp,
 }
 
 static __be32
-nfsd_proc_link(struct svc_rqst *rqstp, struct nfsd_linkargs *argp,
-				void			    *resp)
+nfsd_proc_link(struct svc_rqst *rqstp)
 {
+	struct nfsd_linkargs *argp = rqstp->rq_argp;
 	__be32	nfserr;
 
 	dprintk("nfsd: LINK     %s ->\n",
@@ -430,9 +437,9 @@ nfsd_proc_link(struct svc_rqst *rqstp, struct nfsd_linkargs *argp,
 }
 
 static __be32
-nfsd_proc_symlink(struct svc_rqst *rqstp, struct nfsd_symlinkargs *argp,
-				          void			  *resp)
+nfsd_proc_symlink(struct svc_rqst *rqstp)
 {
+	struct nfsd_symlinkargs *argp = rqstp->rq_argp;
 	struct svc_fh	newfh;
 	__be32		nfserr;
 
@@ -460,9 +467,10 @@ nfsd_proc_symlink(struct svc_rqst *rqstp, struct nfsd_symlinkargs *argp,
  * N.B. After this call resp->fh needs an fh_put
  */
 static __be32
-nfsd_proc_mkdir(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
-					struct nfsd_diropres   *resp)
+nfsd_proc_mkdir(struct svc_rqst *rqstp)
 {
+	struct nfsd_createargs *argp = rqstp->rq_argp;
+	struct nfsd_diropres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: MKDIR    %s %.*s\n", SVCFH_fmt(&argp->fh), argp->len, argp->name);
@@ -484,9 +492,9 @@ nfsd_proc_mkdir(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
  * Remove a directory
  */
 static __be32
-nfsd_proc_rmdir(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
-				 	void		      *resp)
+nfsd_proc_rmdir(struct svc_rqst *rqstp)
 {
+	struct nfsd_diropargs *argp = rqstp->rq_argp;
 	__be32	nfserr;
 
 	dprintk("nfsd: RMDIR    %s %.*s\n", SVCFH_fmt(&argp->fh), argp->len, argp->name);
@@ -500,9 +508,10 @@ nfsd_proc_rmdir(struct svc_rqst *rqstp, struct nfsd_diropargs *argp,
  * Read a portion of a directory.
  */
 static __be32
-nfsd_proc_readdir(struct svc_rqst *rqstp, struct nfsd_readdirargs *argp,
-					  struct nfsd_readdirres  *resp)
+nfsd_proc_readdir(struct svc_rqst *rqstp)
 {
+	struct nfsd_readdirargs *argp = rqstp->rq_argp;
+	struct nfsd_readdirres *resp = rqstp->rq_resp;
 	int		count;
 	__be32		nfserr;
 	loff_t		offset;
@@ -540,9 +549,10 @@ nfsd_proc_readdir(struct svc_rqst *rqstp, struct nfsd_readdirargs *argp,
  * Get file system info
  */
 static __be32
-nfsd_proc_statfs(struct svc_rqst * rqstp, struct nfsd_fhandle   *argp,
-					  struct nfsd_statfsres *resp)
+nfsd_proc_statfs(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct nfsd_statfsres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
 	dprintk("nfsd: STATFS   %s\n", SVCFH_fmt(&argp->fh));
@@ -565,7 +575,7 @@ struct nfsd_void { int dummy; };
 
 static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_NULL] = {
-		.pc_func = (svc_procfunc) nfsd_proc_null,
+		.pc_func = nfsd_proc_null,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_void,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
@@ -574,7 +584,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_GETATTR] = {
-		.pc_func = (svc_procfunc) nfsd_proc_getattr,
+		.pc_func = nfsd_proc_getattr,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_fhandle,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -584,7 +594,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+AT,
 	},
 	[NFSPROC_SETATTR] = {
-		.pc_func = (svc_procfunc) nfsd_proc_setattr,
+		.pc_func = nfsd_proc_setattr,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -602,7 +612,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_LOOKUP] = {
-		.pc_func = (svc_procfunc) nfsd_proc_lookup,
+		.pc_func = nfsd_proc_lookup,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -612,7 +622,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+FH+AT,
 	},
 	[NFSPROC_READLINK] = {
-		.pc_func = (svc_procfunc) nfsd_proc_readlink,
+		.pc_func = nfsd_proc_readlink,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_readlinkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readlinkres,
 		.pc_argsize = sizeof(struct nfsd_readlinkargs),
@@ -621,7 +631,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+1+NFS_MAXPATHLEN/4,
 	},
 	[NFSPROC_READ] = {
-		.pc_func = (svc_procfunc) nfsd_proc_read,
+		.pc_func = nfsd_proc_read,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readres,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -639,7 +649,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_WRITE] = {
-		.pc_func = (svc_procfunc) nfsd_proc_write,
+		.pc_func = nfsd_proc_write,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -649,7 +659,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+AT,
 	},
 	[NFSPROC_CREATE] = {
-		.pc_func = (svc_procfunc) nfsd_proc_create,
+		.pc_func = nfsd_proc_create,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -659,7 +669,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+FH+AT,
 	},
 	[NFSPROC_REMOVE] = {
-		.pc_func = (svc_procfunc) nfsd_proc_remove,
+		.pc_func = nfsd_proc_remove,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
@@ -668,7 +678,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_RENAME] = {
-		.pc_func = (svc_procfunc) nfsd_proc_rename,
+		.pc_func = nfsd_proc_rename,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_renameargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_renameargs),
@@ -677,7 +687,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_LINK] = {
-		.pc_func = (svc_procfunc) nfsd_proc_link,
+		.pc_func = nfsd_proc_link,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_linkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_linkargs),
@@ -686,7 +696,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_SYMLINK] = {
-		.pc_func = (svc_procfunc) nfsd_proc_symlink,
+		.pc_func = nfsd_proc_symlink,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_symlinkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_symlinkargs),
@@ -695,7 +705,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_MKDIR] = {
-		.pc_func = (svc_procfunc) nfsd_proc_mkdir,
+		.pc_func = nfsd_proc_mkdir,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
@@ -705,7 +715,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+FH+AT,
 	},
 	[NFSPROC_RMDIR] = {
-		.pc_func = (svc_procfunc) nfsd_proc_rmdir,
+		.pc_func = nfsd_proc_rmdir,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
@@ -714,7 +724,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST,
 	},
 	[NFSPROC_READDIR] = {
-		.pc_func = (svc_procfunc) nfsd_proc_readdir,
+		.pc_func = nfsd_proc_readdir,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_readdirargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readdirres,
 		.pc_argsize = sizeof(struct nfsd_readdirargs),
@@ -722,7 +732,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_cachetype = RC_NOCACHE,
 	},
 	[NFSPROC_STATFS] = {
-		.pc_func = (svc_procfunc) nfsd_proc_statfs,
+		.pc_func = nfsd_proc_statfs,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_fhandle,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_statfsres,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 59979f0bbd4b..d64895fd8d25 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -827,7 +827,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	rqstp->rq_res.head[0].iov_len += sizeof(__be32);
 
 	/* Now call the procedure handler, and encode NFS status. */
-	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	nfserr = proc->pc_func(rqstp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
 	if (nfserr == nfserr_dropit || test_bit(RQ_DROPME, &rqstp->rq_flags)) {
 		dprintk("nfsd: Dropping request; may be revisited later\n");
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 94631026f79c..5c222af2db41 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -418,9 +418,9 @@ struct svc_version {
 /*
  * RPC procedure info
  */
-typedef __be32	(*svc_procfunc)(struct svc_rqst *, void *argp, void *resp);
 struct svc_procedure {
-	svc_procfunc		pc_func;	/* process the request */
+	/* process the request: */
+	__be32			(*pc_func)(struct svc_rqst *);
 	kxdrproc_t		pc_decode;	/* XDR decode args */
 	kxdrproc_t		pc_encode;	/* XDR encode result */
 	kxdrproc_t		pc_release;	/* XDR free result */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index bc0f5a0ecbdc..95335455ad38 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1281,7 +1281,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp))
 			goto err_garbage;
 
-		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+		*statp = procp->pc_func(rqstp);
 
 		/* Encode reply */
 		if (*statp == rpc_drop_reply ||
-- 
2.11.0

