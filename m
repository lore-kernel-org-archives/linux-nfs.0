Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53254 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQSBj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:01:39 -0500
Received: by iwn35 with SMTP id 35so2389219iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:01:39 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/12] SUNRPC: New xdr_streams XDR encoder API
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:01:33 -0500
Message-ID: <20101117180133.29429.7631.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now that all XDR encoder routines use xdr_streams, there should be no need
to support the legacy calling sequence (rpc_rqst, __be32 *, RPC arg) anywhere.
We can construct the xdr_stream with xdr_init_encode() in the generic RPC code,
instead of in each encoder function.

Also, all the encoder functions return 0, making a return value superfluous.
Take this opportunity to convert them to return void instead.

This is a refactoring change.  It should not cause different behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/lockd/clnt4xdr.c            |   92 ++----
 fs/lockd/clntxdr.c             |   92 ++----
 fs/lockd/mon.c                 |   26 +-
 fs/nfs/mount_clnt.c            |   18 -
 fs/nfs/nfs2xdr.c               |  147 +++------
 fs/nfs/nfs3xdr.c               |  241 ++++++---------
 fs/nfs/nfs4xdr.c               |  663 ++++++++++++++++++----------------------
 fs/nfsd/nfs4callback.c         |   22 -
 include/linux/sunrpc/auth.h    |    4 
 include/linux/sunrpc/clnt.h    |    2 
 include/linux/sunrpc/xdr.h     |    9 -
 net/sunrpc/auth.c              |   14 +
 net/sunrpc/auth_gss/auth_gss.c |   31 +-
 net/sunrpc/clnt.c              |    4 
 net/sunrpc/rpcb_clnt.c         |   47 +--
 15 files changed, 606 insertions(+), 806 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 2338cc6..7311a87 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -385,17 +385,15 @@ static void encode_nlm4_lock(struct xdr_stream *xdr,
  *		struct nlm4_lock alock;
  *	};
  */
-static int nlm4_xdr_enc_testargs(struct rpc_rqst *req, __be32 *p,
-				 const struct nlm_args *args)
+static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm4_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm4_lock(xdr, lock);
 }
 
 /*
@@ -408,20 +406,18 @@ static int nlm4_xdr_enc_testargs(struct rpc_rqst *req, __be32 *p,
  *		int state;
  *	};
  */
-static int nlm4_xdr_enc_lockargs(struct rpc_rqst *req, __be32 *p,
-				 const struct nlm_args *args)
+static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, args->block);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm4_lock(&xdr, lock);
-	encode_bool(&xdr, args->reclaim);
-	encode_int32(&xdr, args->state);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, args->block);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm4_lock(xdr, lock);
+	encode_bool(xdr, args->reclaim);
+	encode_int32(xdr, args->state);
 }
 
 /*
@@ -432,18 +428,16 @@ static int nlm4_xdr_enc_lockargs(struct rpc_rqst *req, __be32 *p,
  *		struct nlm4_lock alock;
  *	};
  */
-static int nlm4_xdr_enc_cancargs(struct rpc_rqst *req, __be32 *p,
-				 const struct nlm_args *args)
+static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, args->block);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm4_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, args->block);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm4_lock(xdr, lock);
 }
 
 /*
@@ -452,16 +446,14 @@ static int nlm4_xdr_enc_cancargs(struct rpc_rqst *req, __be32 *p,
  *		struct nlm4_lock alock;
  *	};
  */
-static int nlm4_xdr_enc_unlockargs(struct rpc_rqst *req, __be32 *p,
-				   const struct nlm_args *args)
+static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_nlm4_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_nlm4_lock(xdr, lock);
 }
 
 /*
@@ -470,15 +462,12 @@ static int nlm4_xdr_enc_unlockargs(struct rpc_rqst *req, __be32 *p,
  *		nlm4_stat stat;
  *	};
  */
-static int nlm4_xdr_enc_res(struct rpc_rqst *req, __be32 *p,
-			    const struct nlm_res *result)
+static void nlm4_xdr_enc_res(struct rpc_rqst *req,
+			     struct xdr_stream *xdr,
+			     const struct nlm_res *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &result->cookie);
-	encode_nlm4_stat(&xdr, result->status);
-	return 0;
+	encode_cookie(xdr, &result->cookie);
+	encode_nlm4_stat(xdr, result->status);
 }
 
 /*
@@ -494,17 +483,14 @@ static int nlm4_xdr_enc_res(struct rpc_rqst *req, __be32 *p,
  *		nlm4_testrply test_stat;
  *	};
  */
-static int nlm4_xdr_enc_testres(struct rpc_rqst *req, __be32 *p,
-				const struct nlm_res *result)
+static void nlm4_xdr_enc_testres(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 const struct nlm_res *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &result->cookie);
-	encode_nlm4_stat(&xdr, result->status);
+	encode_cookie(xdr, &result->cookie);
+	encode_nlm4_stat(xdr, result->status);
 	if (result->status == nlm_lck_denied)
-		encode_nlm4_holder(&xdr, result);
-	return 0;
+		encode_nlm4_holder(xdr, result);
 }
 
 
@@ -588,7 +574,7 @@ out:
 #define PROC(proc, argtype, restype)					\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdrproc_t)nlm4_xdr_enc_##argtype,		\
+	.p_encode    = (kxdreproc_t)nlm4_xdr_enc_##argtype,		\
 	.p_decode    = (kxdrproc_t)nlm4_xdr_dec_##restype,		\
 	.p_arglen    = NLM4_##argtype##_sz,				\
 	.p_replen    = NLM4_##restype##_sz,				\
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index d93d6e9..603e56f 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -378,17 +378,15 @@ static void encode_nlm_lock(struct xdr_stream *xdr,
  *		struct nlm_lock alock;
  *	};
  */
-static int nlm_xdr_enc_testargs(struct rpc_rqst *req, __be32 *p,
-				const struct nlm_args *args)
+static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(xdr, lock);
 }
 
 /*
@@ -401,20 +399,18 @@ static int nlm_xdr_enc_testargs(struct rpc_rqst *req, __be32 *p,
  *		int state;
  *	};
  */
-static int nlm_xdr_enc_lockargs(struct rpc_rqst *req, __be32 *p,
-				const struct nlm_args *args)
+static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, args->block);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm_lock(&xdr, lock);
-	encode_bool(&xdr, args->reclaim);
-	encode_int32(&xdr, args->state);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, args->block);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(xdr, lock);
+	encode_bool(xdr, args->reclaim);
+	encode_int32(xdr, args->state);
 }
 
 /*
@@ -425,18 +421,16 @@ static int nlm_xdr_enc_lockargs(struct rpc_rqst *req, __be32 *p,
  *		struct nlm_lock alock;
  *	};
  */
-static int nlm_xdr_enc_cancargs(struct rpc_rqst *req, __be32 *p,
-				const struct nlm_args *args)
+static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_bool(&xdr, args->block);
-	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
-	encode_nlm_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_bool(xdr, args->block);
+	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(xdr, lock);
 }
 
 /*
@@ -445,16 +439,14 @@ static int nlm_xdr_enc_cancargs(struct rpc_rqst *req, __be32 *p,
  *		struct nlm_lock alock;
  *	};
  */
-static int nlm_xdr_enc_unlockargs(struct rpc_rqst *req, __be32 *p,
-				  const struct nlm_args *args)
+static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nlm_args *args)
 {
 	const struct nlm_lock *lock = &args->lock;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &args->cookie);
-	encode_nlm_lock(&xdr, lock);
-	return 0;
+	encode_cookie(xdr, &args->cookie);
+	encode_nlm_lock(xdr, lock);
 }
 
 /*
@@ -463,15 +455,12 @@ static int nlm_xdr_enc_unlockargs(struct rpc_rqst *req, __be32 *p,
  *		nlm_stat stat;
  *	};
  */
-static int nlm_xdr_enc_res(struct rpc_rqst *req, __be32 *p,
-			   const struct nlm_res *result)
+static void nlm_xdr_enc_res(struct rpc_rqst *req,
+			    struct xdr_stream *xdr,
+			    const struct nlm_res *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &result->cookie);
-	encode_nlm_stat(&xdr, result->status);
-	return 0;
+	encode_cookie(xdr, &result->cookie);
+	encode_nlm_stat(xdr, result->status);
 }
 
 /*
@@ -494,16 +483,13 @@ static void encode_nlm_testrply(struct xdr_stream *xdr,
 		encode_nlm_holder(xdr, result);
 }
 
-static int nlm_xdr_enc_testres(struct rpc_rqst *req, __be32 *p,
-			       const struct nlm_res *result)
+static void nlm_xdr_enc_testres(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				const struct nlm_res *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cookie(&xdr, &result->cookie);
-	encode_nlm_stat(&xdr, result->status);
-	encode_nlm_testrply(&xdr, result);
-	return 0;
+	encode_cookie(xdr, &result->cookie);
+	encode_nlm_stat(xdr, result->status);
+	encode_nlm_testrply(xdr, result);
 }
 
 
@@ -586,7 +572,7 @@ out:
 #define PROC(proc, argtype, restype)	\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdrproc_t)nlm_xdr_enc_##argtype,		\
+	.p_encode    = (kxdreproc_t)nlm_xdr_enc_##argtype,		\
 	.p_decode    = (kxdrproc_t)nlm_xdr_dec_##restype,		\
 	.p_arglen    = NLM_##argtype##_sz,				\
 	.p_replen    = NLM_##restype##_sz,				\
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d812818..baa77bc 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -459,25 +459,17 @@ static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 	xdr_encode_opaque_fixed(p, argp->priv->data, SM_PRIV_SIZE);
 }
 
-static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
-		       const struct nsm_args *argp)
+static void nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
+			    const struct nsm_args *argp)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_mon_id(&xdr, argp);
-	encode_priv(&xdr, argp);
-	return 0;
+	encode_mon_id(xdr, argp);
+	encode_priv(xdr, argp);
 }
 
-static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
-			 const struct nsm_args *argp)
+static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      const struct nsm_args *argp)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_mon_id(&xdr, argp);
-	return 0;
+	encode_mon_id(xdr, argp);
 }
 
 static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
@@ -524,7 +516,7 @@ static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
 static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
-		.p_encode	= (kxdrproc_t)xdr_enc_mon,
+		.p_encode	= (kxdreproc_t)nsm_xdr_enc_mon,
 		.p_decode	= (kxdrproc_t)xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
@@ -533,7 +525,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
-		.p_encode	= (kxdrproc_t)xdr_enc_unmon,
+		.p_encode	= (kxdreproc_t)nsm_xdr_enc_unmon,
 		.p_decode	= (kxdrproc_t)xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 2e238f3..fb96118 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -290,14 +290,10 @@ static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 	xdr_encode_opaque(p, pathname, pathname_len);
 }
 
-static int mnt_enc_dirpath(struct rpc_rqst *req, __be32 *p,
-			   const char *dirpath)
+static void mnt_xdr_enc_dirpath(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const char *dirpath)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_mntdirpath(&xdr, dirpath);
-	return 0;
+	encode_mntdirpath(xdr, dirpath);
 }
 
 /*
@@ -462,7 +458,7 @@ static int mnt_dec_mountres3(struct rpc_rqst *req, __be32 *p,
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
-		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
 		.p_decode	= (kxdrproc_t)mnt_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres_sz,
@@ -471,7 +467,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 	},
 	[MOUNTPROC_UMNT] = {
 		.p_proc		= MOUNTPROC_UMNT,
-		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC_UMNT,
 		.p_name		= "UMOUNT",
@@ -481,7 +477,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
-		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
 		.p_decode	= (kxdrproc_t)mnt_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres3_sz,
@@ -490,7 +486,7 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	},
 	[MOUNTPROC3_UMNT] = {
 		.p_proc		= MOUNTPROC3_UMNT,
-		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC3_UMNT,
 		.p_name		= "UMOUNT",
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 9ff0504..bf0cce1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -558,14 +558,11 @@ out_default:
  * "NFS: Network File System Protocol Specification".
  */
 
-static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
-				const struct nfs_fh *fh)
+static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 const struct nfs_fh *fh)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_fhandle(&xdr, fh);
-	return 0;
+	encode_fhandle(xdr, fh);
 }
 
 /*
@@ -576,37 +573,28 @@ static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
  *		sattr attributes;
  *	};
  */
-static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req, __be32 *p,
-				  const struct nfs_sattrargs *args)
+static void nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nfs_sattrargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_fhandle(&xdr, args->fh);
-	encode_sattr(&xdr, args->sattr);
-	return 0;
+	encode_fhandle(xdr, args->fh);
+	encode_sattr(xdr, args->sattr);
 }
 
-static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
-				  const struct nfs_diropargs *args)
+static void nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nfs_diropargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs(&xdr, args->fh, args->name, args->len);
-	return 0;
+	encode_diropargs(xdr, args->fh, args->name, args->len);
 }
 
-static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
-				     const struct nfs_readlinkargs *args)
+static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      const struct nfs_readlinkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_fhandle(&xdr, args->fh);
+	encode_fhandle(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS_readlinkres_sz);
-	return 0;
 }
 
 /*
@@ -634,17 +622,14 @@ static void encode_readargs(struct xdr_stream *xdr,
 	*p = cpu_to_be32(count);
 }
 
-static int nfs2_xdr_enc_readargs(struct rpc_rqst *req, __be32 *p,
-				 const struct nfs_readargs *args)
+static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  const struct nfs_readargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_readargs(&xdr, args);
+	encode_readargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS_readres_sz);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
-	return 0;
 }
 
 /*
@@ -677,15 +662,12 @@ static void encode_writeargs(struct xdr_stream *xdr,
 	xdr_write_pages(xdr, args->pages, args->pgbase, count);
 }
 
-static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
-				  const struct nfs_writeargs *args)
+static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nfs_writeargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_writeargs(&xdr, args);
-	xdr.buf->flags |= XDRBUF_WRITE;
-	return 0;
+	encode_writeargs(xdr, args);
+	xdr->buf->flags |= XDRBUF_WRITE;
 }
 
 /*
@@ -696,25 +678,19 @@ static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
  *		sattr attributes;
  *	};
  */
-static int nfs2_xdr_enc_createargs(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs_createargs *args)
+static void nfs2_xdr_enc_createargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs_createargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs(&xdr, args->fh, args->name, args->len);
-	encode_sattr(&xdr, args->sattr);
-	return 0;
+	encode_diropargs(xdr, args->fh, args->name, args->len);
+	encode_sattr(xdr, args->sattr);
 }
 
-static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs_removeargs *args)
+static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs_removeargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs(&xdr, args->fh, args->name.name, args->name.len);
-	return 0;
+	encode_diropargs(xdr, args->fh, args->name.name, args->name.len);
 }
 
 /*
@@ -725,17 +701,15 @@ static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
  *		diropargs to;
  *	};
  */
-static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs_renameargs *args)
+static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs_renameargs *args)
 {
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs(&xdr, args->old_dir, old->name, old->len);
-	encode_diropargs(&xdr, args->new_dir, new->name, new->len);
-	return 0;
+	encode_diropargs(xdr, args->old_dir, old->name, old->len);
+	encode_diropargs(xdr, args->new_dir, new->name, new->len);
 }
 
 /*
@@ -746,15 +720,12 @@ static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
  *		diropargs to;
  *	};
  */
-static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req, __be32 *p,
-				 const struct nfs_linkargs *args)
+static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  const struct nfs_linkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_fhandle(&xdr, args->fromfh);
-	encode_diropargs(&xdr, args->tofh, args->toname, args->tolen);
-	return 0;
+	encode_fhandle(xdr, args->fromfh);
+	encode_diropargs(xdr, args->tofh, args->toname, args->tolen);
 }
 
 /*
@@ -766,16 +737,13 @@ static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req, __be32 *p,
  *		sattr attributes;
  *	};
  */
-static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs_symlinkargs *args)
+static void nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs_symlinkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs(&xdr, args->fromfh, args->fromname, args->fromlen);
-	encode_path(&xdr, args->pages, args->pathlen);
-	encode_sattr(&xdr, args->sattr);
-	return 0;
+	encode_diropargs(xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_path(xdr, args->pages, args->pathlen);
+	encode_sattr(xdr, args->sattr);
 }
 
 /*
@@ -799,16 +767,13 @@ static void encode_readdirargs(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs_readdirargs *args)
+static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs_readdirargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_readdirargs(&xdr, args);
+	encode_readdirargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 					args->count, NFS_readdirres_sz);
-	return 0;
 }
 
 /*
@@ -1182,7 +1147,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-	.p_encode   =  (kxdrproc_t)nfs2_xdr_enc_##argtype,		\
+	.p_encode   =  (kxdreproc_t)nfs2_xdr_enc_##argtype,		\
 	.p_decode   =  (kxdrproc_t)nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 8388d87..b70428d 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -835,14 +835,11 @@ static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
  *		nfs_fh3  object;
  *	};
  */
-static int nfs3_xdr_enc_getattr3args(struct rpc_rqst *req, __be32 *p,
-				     const struct nfs_fh *fh)
+static void nfs3_xdr_enc_getattr3args(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      const struct nfs_fh *fh)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, fh);
-	return 0;
+	encode_nfs_fh3(xdr, fh);
 }
 
 /*
@@ -876,16 +873,13 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 	}
 }
 
-static int nfs3_xdr_enc_setattr3args(struct rpc_rqst *req, __be32 *p,
-				     const struct nfs3_sattrargs *args)
+static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      const struct nfs3_sattrargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, args->fh);
-	encode_sattr3(&xdr, args->sattr);
-	encode_sattrguard3(&xdr, args);
-	return 0;
+	encode_nfs_fh3(xdr, args->fh);
+	encode_sattr3(xdr, args->sattr);
+	encode_sattrguard3(xdr, args);
 }
 
 /*
@@ -895,14 +889,11 @@ static int nfs3_xdr_enc_setattr3args(struct rpc_rqst *req, __be32 *p,
  *		diropargs3  what;
  *	};
  */
-static int nfs3_xdr_enc_lookup3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs3_diropargs *args)
+static void nfs3_xdr_enc_lookup3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs3_diropargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fh, args->name, args->len);
-	return 0;
+	encode_diropargs3(xdr, args->fh, args->name, args->len);
 }
 
 /*
@@ -920,14 +911,11 @@ static void encode_access3args(struct xdr_stream *xdr,
 	encode_uint32(xdr, args->access);
 }
 
-static int nfs3_xdr_enc_access3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs3_accessargs *args)
+static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs3_accessargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_access3args(&xdr, args);
-	return 0;
+	encode_access3args(xdr, args);
 }
 
 /*
@@ -937,16 +925,13 @@ static int nfs3_xdr_enc_access3args(struct rpc_rqst *req, __be32 *p,
  *		nfs_fh3	symlink;
  *	};
  */
-static int nfs3_xdr_enc_readlink3args(struct rpc_rqst *req, __be32 *p,
-				      const struct nfs3_readlinkargs *args)
+static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       const struct nfs3_readlinkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, args->fh);
+	encode_nfs_fh3(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS3_readlinkres_sz);
-	return 0;
 }
 
 /*
@@ -970,17 +955,14 @@ static void encode_read3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static int nfs3_xdr_enc_read3args(struct rpc_rqst *req, __be32 *p,
-				  const struct nfs_readargs *args)
+static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nfs_readargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_read3args(&xdr, args);
+	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS3_readres_sz);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
-	return 0;
 }
 
 /*
@@ -1015,15 +997,12 @@ static void encode_write3args(struct xdr_stream *xdr,
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 }
 
-static int nfs3_xdr_enc_write3args(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs_writeargs *args)
+static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs_writeargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_write3args(&xdr, args);
-	xdr.buf->flags |= XDRBUF_WRITE;
-	return 0;
+	encode_write3args(xdr, args);
+	xdr->buf->flags |= XDRBUF_WRITE;
 }
 
 /*
@@ -1065,15 +1044,12 @@ static void encode_createhow3(struct xdr_stream *xdr,
 	}
 }
 
-static int nfs3_xdr_enc_create3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs3_createargs *args)
+static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs3_createargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fh, args->name, args->len);
-	encode_createhow3(&xdr, args);
-	return 0;
+	encode_diropargs3(xdr, args->fh, args->name, args->len);
+	encode_createhow3(xdr, args);
 }
 
 /*
@@ -1084,15 +1060,12 @@ static int nfs3_xdr_enc_create3args(struct rpc_rqst *req, __be32 *p,
  *		sattr3		attributes;
  *	};
  */
-static int nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs3_mkdirargs *args)
+static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs3_mkdirargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fh, args->name, args->len);
-	encode_sattr3(&xdr, args->sattr);
-	return 0;
+	encode_diropargs3(xdr, args->fh, args->name, args->len);
+	encode_sattr3(xdr, args->sattr);
 }
 
 /*
@@ -1115,15 +1088,12 @@ static void encode_symlinkdata3(struct xdr_stream *xdr,
 	encode_nfspath3(xdr, args->pages, args->pathlen);
 }
 
-static int nfs3_xdr_enc_symlink3args(struct rpc_rqst *req, __be32 *p,
-				     const struct nfs3_symlinkargs *args)
+static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      const struct nfs3_symlinkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fromfh, args->fromname, args->fromlen);
-	encode_symlinkdata3(&xdr, args);
-	return 0;
+	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_symlinkdata3(xdr, args);
 }
 
 /*
@@ -1178,15 +1148,12 @@ static void encode_mknoddata3(struct xdr_stream *xdr,
 	}
 }
 
-static int nfs3_xdr_enc_mknod3args(struct rpc_rqst *req, __be32 *p,
-				   const struct nfs3_mknodargs *args)
+static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const struct nfs3_mknodargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fh, args->name, args->len);
-	encode_mknoddata3(&xdr, args);
-	return 0;
+	encode_diropargs3(xdr, args->fh, args->name, args->len);
+	encode_mknoddata3(xdr, args);
 }
 
 /*
@@ -1196,14 +1163,11 @@ static int nfs3_xdr_enc_mknod3args(struct rpc_rqst *req, __be32 *p,
  *		diropargs3  object;
  *	};
  */
-static int nfs3_xdr_enc_remove3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs_removeargs *args)
+static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs_removeargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->fh, args->name.name, args->name.len);
-	return 0;
+	encode_diropargs3(xdr, args->fh, args->name.name, args->name.len);
 }
 
 /*
@@ -1214,17 +1178,15 @@ static int nfs3_xdr_enc_remove3args(struct rpc_rqst *req, __be32 *p,
  *		diropargs3	to;
  *	};
  */
-static int nfs3_xdr_enc_rename3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs_renameargs *args)
+static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs_renameargs *args)
 {
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
-	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_diropargs3(&xdr, args->old_dir, old->name, old->len);
-	encode_diropargs3(&xdr, args->new_dir, new->name, new->len);
-	return 0;
+	encode_diropargs3(xdr, args->old_dir, old->name, old->len);
+	encode_diropargs3(xdr, args->new_dir, new->name, new->len);
 }
 
 /*
@@ -1235,15 +1197,12 @@ static int nfs3_xdr_enc_rename3args(struct rpc_rqst *req, __be32 *p,
  *		diropargs3	link;
  *	};
  */
-static int nfs3_xdr_enc_link3args(struct rpc_rqst *req, __be32 *p,
-				  const struct nfs3_linkargs *args)
+static void nfs3_xdr_enc_link3args(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const struct nfs3_linkargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, args->fromfh);
-	encode_diropargs3(&xdr, args->tofh, args->toname, args->tolen);
-	return 0;
+	encode_nfs_fh3(xdr, args->fromfh);
+	encode_diropargs3(xdr, args->tofh, args->toname, args->tolen);
 }
 
 /*
@@ -1269,16 +1228,13 @@ static void encode_readdir3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static int nfs3_xdr_enc_readdir3args(struct rpc_rqst *req, __be32 *p,
-				     const struct nfs3_readdirargs *args)
+static void nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      const struct nfs3_readdirargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_readdir3args(&xdr, args);
+	encode_readdir3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
-	return 0;
 }
 
 /*
@@ -1312,16 +1268,13 @@ static void encode_readdirplus3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static int nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req, __be32 *p,
-					 const struct nfs3_readdirargs *args)
+static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
+					  struct xdr_stream *xdr,
+					  const struct nfs3_readdirargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_readdirplus3args(&xdr, args);
+	encode_readdirplus3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
-	return 0;
 }
 
 /*
@@ -1345,57 +1298,49 @@ static void encode_commit3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static int nfs3_xdr_enc_commit3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs_writeargs *args)
+static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs_writeargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_commit3args(&xdr, args);
-	return 0;
+	encode_commit3args(xdr, args);
 }
 
 #ifdef CONFIG_NFS_V3_ACL
 
-static int nfs3_xdr_enc_getacl3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs3_getaclargs *args)
+static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs3_getaclargs *args)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, args->fh);
-	encode_uint32(&xdr, args->mask);
+	encode_nfs_fh3(xdr, args->fh);
+	encode_uint32(xdr, args->mask);
 	if (args->mask & (NFS_ACL | NFS_DFACL))
 		prepare_reply_buffer(req, args->pages, 0,
 					NFSACL_MAXPAGES << PAGE_SHIFT,
 					ACL3_getaclres_sz);
-	return 0;
 }
 
-static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req, __be32 *p,
-				    const struct nfs3_setaclargs *args)
+static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs3_setaclargs *args)
 {
-	struct xdr_stream xdr;
 	unsigned int base;
 	int error;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_nfs_fh3(&xdr, NFS_FH(args->inode));
-	encode_uint32(&xdr, args->mask);
+	encode_nfs_fh3(xdr, NFS_FH(args->inode));
+	encode_uint32(xdr, args->mask);
 	if (args->npages != 0)
-		xdr_write_pages(&xdr, args->pages, 0, args->len);
+		xdr_write_pages(xdr, args->pages, 0, args->len);
 
 	base = req->rq_slen;
-	error = nfsacl_encode(xdr.buf, base, args->inode,
+	error = nfsacl_encode(xdr->buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
 			    args->acl_access : NULL, 1, 0);
 	BUG_ON(error < 0);
-	error = nfsacl_encode(xdr.buf, base + error, args->inode,
+	error = nfsacl_encode(xdr->buf, base + error, args->inode,
 			    (args->mask & NFS_DFACL) ?
 			    args->acl_default : NULL, 1,
 			    NFS_ACL_DEFAULT);
 	BUG_ON(error < 0);
-	return 0;
 }
 
 #endif  /* CONFIG_NFS_V3_ACL */
@@ -2502,7 +2447,7 @@ out_default:
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-	.p_encode    = (kxdrproc_t)nfs3_xdr_enc_##argtype##3args,	\
+	.p_encode    = (kxdreproc_t)nfs3_xdr_enc_##argtype##3args,	\
 	.p_decode    = (kxdrproc_t)nfs3_xdr_dec_##restype##3res,	\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##res_sz,				\
@@ -2545,7 +2490,7 @@ struct rpc_version		nfs_version3 = {
 static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
-		.p_encode = (kxdrproc_t)nfs3_xdr_enc_getacl3args,
+		.p_encode = (kxdreproc_t)nfs3_xdr_enc_getacl3args,
 		.p_decode = (kxdrproc_t)nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
@@ -2554,7 +2499,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
-		.p_encode = (kxdrproc_t)nfs3_xdr_enc_setacl3args,
+		.p_encode = (kxdreproc_t)nfs3_xdr_enc_setacl3args,
 		.p_decode = (kxdrproc_t)nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1daff25..b64e0c5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1510,7 +1510,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->replen += decode_restorefh_maxsz;
 }
 
-static int
+static void
 encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1521,14 +1521,12 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
-	if (arg->acl_len % 4)
-		return -EINVAL;
+	BUG_ON(arg->acl_len % 4);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
 	hdr->replen += decode_setacl_maxsz;
-	return 0;
 }
 
 static void
@@ -1833,393 +1831,362 @@ static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
 /*
  * Encode an ACCESS request
  */
-static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs4_accessargs *args)
+static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs4_accessargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_access(&xdr, args->access, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_access(xdr, args->access, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode LOOKUP request
  */
-static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_arg *args)
+static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs4_lookup_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->dir_fh, &hdr);
-	encode_lookup(&xdr, args->name, &hdr);
-	encode_getfh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->dir_fh, &hdr);
+	encode_lookup(xdr, args->name, &hdr);
+	encode_getfh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode LOOKUP_ROOT request
  */
-static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_root_arg *args)
+static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_lookup_root_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putrootfh(&xdr, &hdr);
-	encode_getfh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putrootfh(xdr, &hdr);
+	encode_getfh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode REMOVE request
  */
-static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs_removeargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_remove(&xdr, &args->name, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_remove(xdr, &args->name, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode RENAME request
  */
-static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs_renameargs *args)
+static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs_renameargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->old_dir, &hdr);
-	encode_savefh(&xdr, &hdr);
-	encode_putfh(&xdr, args->new_dir, &hdr);
-	encode_rename(&xdr, args->old_name, args->new_name, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
-	encode_restorefh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->old_dir, &hdr);
+	encode_savefh(xdr, &hdr);
+	encode_putfh(xdr, args->new_dir, &hdr);
+	encode_rename(xdr, args->old_name, args->new_name, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_restorefh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode LINK request
  */
-static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_link_arg *args)
+static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     const struct nfs4_link_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_savefh(&xdr, &hdr);
-	encode_putfh(&xdr, args->dir_fh, &hdr);
-	encode_link(&xdr, args->name, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
-	encode_restorefh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_savefh(xdr, &hdr);
+	encode_putfh(xdr, args->dir_fh, &hdr);
+	encode_link(xdr, args->name, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_restorefh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode CREATE request
  */
-static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs4_create_arg *args)
+static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs4_create_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->dir_fh, &hdr);
-	encode_savefh(&xdr, &hdr);
-	encode_create(&xdr, args, &hdr);
-	encode_getfh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
-	encode_restorefh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->dir_fh, &hdr);
+	encode_savefh(xdr, &hdr);
+	encode_create(xdr, args, &hdr);
+	encode_getfh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_restorefh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode SYMLINK request
  */
-static int nfs4_xdr_enc_symlink(struct rpc_rqst *req, __be32 *p, const struct nfs4_create_arg *args)
+static void nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 const struct nfs4_create_arg *args)
 {
-	return nfs4_xdr_enc_create(req, p, args);
+	nfs4_xdr_enc_create(req, xdr, args);
 }
 
 /*
  * Encode GETATTR request
  */
-static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nfs4_getattr_arg *args)
+static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 const struct nfs4_getattr_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a CLOSE request
  */
-static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
+static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       struct nfs_closeargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_close(&xdr, args, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_close(xdr, args, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode an OPEN request
  */
-static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
+static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      struct nfs_openargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_savefh(&xdr, &hdr);
-	encode_open(&xdr, args, &hdr);
-	encode_getfh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
-	encode_restorefh(&xdr, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_savefh(xdr, &hdr);
+	encode_open(xdr, args, &hdr);
+	encode_getfh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_restorefh(xdr, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode an OPEN_CONFIRM request
  */
-static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_open_confirmargs *args)
+static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      struct nfs_open_confirmargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_open_confirm(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_open_confirm(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode an OPEN request with no attributes.
  */
-static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
+static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs_openargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_open(&xdr, args, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_open(xdr, args, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode an OPEN_DOWNGRADE request
  */
-static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
+static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					struct nfs_closeargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_open_downgrade(&xdr, args, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_open_downgrade(xdr, args, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a LOCK request
  */
-static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_args *args)
+static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      struct nfs_lock_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_lock(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_lock(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a LOCKT request
  */
-static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_args *args)
+static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       struct nfs_lockt_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_lockt(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_lockt(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a LOCKU request
  */
-static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_args *args)
+static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       struct nfs_locku_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_locku(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_locku(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
-static int nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req, __be32 *p, struct nfs_release_lockowner_args *args)
+static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
+					   struct xdr_stream *xdr,
+					struct nfs_release_lockowner_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = 0,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_release_lockowner(&xdr, &args->lock_owner, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_release_lockowner(xdr, &args->lock_owner, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a READLINK request
  */
-static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct nfs4_readlink *args)
+static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
+				  const struct nfs4_readlink *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_readlink(&xdr, args, req, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_readlink(xdr, args, req, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
 			args->pgbase, args->pglen);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a READDIR request
  */
-static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nfs4_readdir_arg *args)
+static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 const struct nfs4_readdir_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_readdir(&xdr, args, req, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_readdir(xdr, args, req, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
 			 args->pgbase, args->count);
@@ -2227,428 +2194,387 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 			__func__, hdr.replen << 2, args->pages,
 			args->pgbase, args->count);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a READ request
  */
-static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
+static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      struct nfs_readargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_read(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_read(xdr, args, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode an SETATTR request
  */
-static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_setattrargs *args)
+static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 struct nfs_setattrargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_setattr(&xdr, args, args->server, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_setattr(xdr, args, args->server, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a GETACL request
  */
-static int
-nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
-		struct nfs_getaclargs *args)
+static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
+				struct nfs_getaclargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	uint32_t replen;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
 	replen = hdr.replen + op_decode_hdr_maxsz + nfs4_fattr_bitmap_maxsz + 1;
-	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
+	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode a WRITE request
  */
-static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
+static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       struct nfs_writeargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_write(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_write(xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  *  a COMMIT request
  */
-static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
+static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
+				struct nfs_writeargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_commit(&xdr, args, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_commit(xdr, args, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * FSINFO request
  */
-static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsinfo_arg *args)
+static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
+				struct nfs4_fsinfo_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_fsinfo(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_fsinfo(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a PATHCONF request
  */
-static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct nfs4_pathconf_arg *args)
+static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
+				  const struct nfs4_pathconf_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getattr_one(xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a STATFS request
  */
-static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs4_statfs_arg *args)
+static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const struct nfs4_statfs_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getattr_two(xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * GETATTR_BITMAP request
  */
-static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
-				    struct nfs4_server_caps_arg *args)
+static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs4_server_caps_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fhandle, &hdr);
-	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fhandle, &hdr);
+	encode_getattr_one(xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
 			   FATTR4_WORD0_SYMLINK_SUPPORT|
 			   FATTR4_WORD0_ACLSUPPORT, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a RENEW request
  */
-static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client *clp)
+static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       struct nfs_client *clp)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_renew(&xdr, clp, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_renew(xdr, clp, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a SETCLIENTID request
  */
-static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4_setclientid *sc)
+static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs4_setclientid *sc)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_setclientid(&xdr, sc, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_setclientid(xdr, sc, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a SETCLIENTID_CONFIRM request
  */
-static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs4_setclientid_res *arg)
+static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
+					     struct xdr_stream *xdr,
+					     struct nfs4_setclientid_res *arg)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_setclientid_confirm(&xdr, arg, &hdr);
-	encode_putrootfh(&xdr, &hdr);
-	encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_setclientid_confirm(xdr, arg, &hdr);
+	encode_putrootfh(xdr, &hdr);
+	encode_fsinfo(xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * DELEGRETURN request
  */
-static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struct nfs4_delegreturnargs *args)
+static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_delegreturnargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fhandle, &hdr);
-	encode_delegreturn(&xdr, args->stateid, &hdr);
-	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fhandle, &hdr);
+	encode_delegreturn(xdr, args->stateid, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode FS_LOCATIONS request
  */
-static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations_arg *args)
+static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      struct nfs4_fs_locations_arg *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	uint32_t replen;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->dir_fh, &hdr);
-	encode_lookup(&xdr, args->name, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->dir_fh, &hdr);
+	encode_lookup(xdr, args->name, &hdr);
 	replen = hdr.replen;	/* get the attribute into args->page */
-	encode_fs_locations(&xdr, args->bitmask, &hdr);
+	encode_fs_locations(xdr, args->bitmask, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
 			0, PAGE_SIZE);
 	encode_nops(&hdr);
-	return 0;
 }
 
 #if defined(CONFIG_NFS_V4_1)
 /*
  * EXCHANGE_ID request
  */
-static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
-				    struct nfs41_exchange_id_args *args)
+static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs41_exchange_id_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_exchange_id(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_exchange_id(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a CREATE_SESSION request
  */
-static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
-				       struct nfs41_create_session_args *args)
+static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					struct nfs41_create_session_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_create_session(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_create_session(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a DESTROY_SESSION request
  */
-static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
-					struct nfs4_session *session)
+static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
+					 struct xdr_stream *xdr,
+					 struct nfs4_session *session)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = session->clp->cl_mvops->minor_version,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_destroy_session(&xdr, session, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_destroy_session(xdr, session, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a SEQUENCE request
  */
-static int nfs4_xdr_enc_sequence(struct rpc_rqst *req, uint32_t *p,
-				 struct nfs4_sequence_args *args)
+static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
+				  struct nfs4_sequence_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a GET_LEASE_TIME request
  */
-static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
-				       struct nfs4_get_lease_time_args *args)
+static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					struct nfs4_get_lease_time_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->la_seq_args, &hdr);
-	encode_putrootfh(&xdr, &hdr);
-	encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->la_seq_args, &hdr);
+	encode_putrootfh(xdr, &hdr);
+	encode_fsinfo(xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * a RECLAIM_COMPLETE request
  */
-static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
-				     struct nfs41_reclaim_complete_args *args)
+static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
+					  struct xdr_stream *xdr,
+				struct nfs41_reclaim_complete_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args)
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_reclaim_complete(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_reclaim_complete(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  * Encode GETDEVICEINFO request
  */
-static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
-				      struct nfs4_getdeviceinfo_args *args)
+static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       struct nfs4_getdeviceinfo_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_getdeviceinfo(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_getdeviceinfo(xdr, args, &hdr);
 
 	/* set up reply kvec. Subtract notification bitmap max size (2)
 	 * so that notification bitmap is put in xdr_buf tail */
@@ -2657,27 +2583,24 @@ static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
 			 args->pdev->pglen);
 
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
  *  Encode LAYOUTGET request
  */
-static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
-				  struct nfs4_layoutget_args *args)
+static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   struct nfs4_layoutget_args *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
-	encode_layoutget(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
+	encode_layoutget(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -5368,22 +5291,18 @@ out:
 /*
  * Encode an SETACL request
  */
-static int
-nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
+static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
+				struct nfs_setaclargs *args)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
-	int status;
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	status = encode_setacl(&xdr, args, &hdr);
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_setacl(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return status;
 }
 
 /*
@@ -6312,7 +6231,7 @@ nfs4_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
-	.p_encode = (kxdrproc_t)nfs4_xdr_##argtype,		\
+	.p_encode = (kxdreproc_t)nfs4_xdr_##argtype,		\
 	.p_decode = (kxdrproc_t)nfs4_xdr_##restype,		\
 	.p_arglen = NFS4_##argtype##_sz,			\
 	.p_replen = NFS4_##restype##_sz,			\
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6529534..c363efd 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -499,34 +499,28 @@ out_default:
 /*
  * NB: Without this zero space reservation, callbacks over krb5p fail
  */
-static int nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p, void *__unused)
+static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 void *__unused)
 {
-	struct xdr_stream xdrs, *xdr = &xdrs;
-
-	xdr_init_encode(&xdrs, &req->rq_snd_buf, p);
 	xdr_reserve_space(xdr, 0);
-	return 0;
 }
 
 /*
  * 20.2. Operation 4: CB_RECALL - Recall a Delegation
  */
-static int nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
-				  const struct nfsd4_callback *cb)
+static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
+				   const struct nfsd4_callback *cb)
 {
-	struct xdr_stream xdr;
 	const struct nfs4_delegation *args = cb->cb_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = cb->cb_clp->cl_cb_ident,
 		.minorversion = cb->cb_minorversion,
 	};
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_cb_compound4args(&xdr, &hdr);
-	encode_cb_sequence4args(&xdr, cb, &hdr);
-	encode_cb_recall4args(&xdr, args, &hdr);
+	encode_cb_compound4args(xdr, &hdr);
+	encode_cb_sequence4args(xdr, cb, &hdr);
+	encode_cb_recall4args(xdr, args, &hdr);
 	encode_cb_nops(&hdr);
-	return 0;
 }
 
 
@@ -583,7 +577,7 @@ out_default:
 #define PROC(proc, call, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {						\
 	.p_proc    = NFSPROC4_CB_##call,				\
-	.p_encode  = (kxdrproc_t)nfs4_xdr_enc_##argtype,		\
+	.p_encode  = (kxdreproc_t)nfs4_xdr_enc_##argtype,		\
 	.p_decode  = (kxdrproc_t)nfs4_xdr_dec_##restype,		\
 	.p_arglen  = NFS4_enc_##argtype##_sz,				\
 	.p_replen  = NFS4_dec_##restype##_sz,				\
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b202475..d88cffb 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -110,7 +110,7 @@ struct rpc_credops {
 	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
-	int			(*crwrap_req)(struct rpc_task *, kxdrproc_t,
+	int			(*crwrap_req)(struct rpc_task *, kxdreproc_t,
 						void *, __be32 *, void *);
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrproc_t,
 						void *, __be32 *, void *);
@@ -139,7 +139,7 @@ struct rpc_cred *	rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *
 void			put_rpccred(struct rpc_cred *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
-int			rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp, __be32 *data, void *obj);
+int			rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp, __be32 *data, void *obj);
 int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp, __be32 *data, void *obj);
 int			rpcauth_refreshcred(struct rpc_task *);
 void			rpcauth_invalcred(struct rpc_task *);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a5a55f2..7b19c4e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -89,7 +89,7 @@ struct rpc_version {
  */
 struct rpc_procinfo {
 	u32			p_proc;		/* RPC procedure number */
-	kxdrproc_t		p_encode;	/* XDR encode function */
+	kxdreproc_t		p_encode;	/* XDR encode function */
 	kxdrproc_t		p_decode;	/* XDR decode function */
 	unsigned int		p_arglen;	/* argument hdr length (u32) */
 	unsigned int		p_replen;	/* reply hdr length (u32) */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 498ab93..a21cf53 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -33,8 +33,8 @@ struct xdr_netobj {
 };
 
 /*
- * This is the generic XDR function. rqstp is either a rpc_rqst (client
- * side) or svc_rqst pointer (server side).
+ * This is the legacy generic XDR function. rqstp is either a rpc_rqst
+ * (client side) or svc_rqst pointer (server side).
  * Encode functions always assume there's enough room in the buffer.
  */
 typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
@@ -203,6 +203,11 @@ struct xdr_stream {
 	struct kvec *iov;	/* pointer to the current kvec */
 };
 
+/*
+ * This is the xdr_stream style generic XDR function.
+ */
+typedef void	(*kxdreproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
+
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index afe6784..651c9da 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -563,8 +563,17 @@ rpcauth_checkverf(struct rpc_task *task, __be32 *p)
 	return cred->cr_ops->crvalidate(task, p);
 }
 
+static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
+				   __be32 *data, void *obj)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data);
+	encode(rqstp, &xdr, obj);
+}
+
 int
-rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp,
+rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
@@ -574,7 +583,8 @@ rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp,
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
-	return encode(rqstp, data, obj);
+	rpcauth_wrap_req_encode(encode, rqstp, data, obj);
+	return 0;
 }
 
 int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3835ce3..42b46f9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1231,9 +1231,19 @@ out_bad:
 	return NULL;
 }
 
+static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
+				__be32 *p, void *obj)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p);
+	encode(rqstp, &xdr, obj);
+}
+
 static inline int
 gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		kxdrproc_t encode, struct rpc_rqst *rqstp, __be32 *p, void *obj)
+		   kxdreproc_t encode, struct rpc_rqst *rqstp,
+		   __be32 *p, void *obj)
 {
 	struct xdr_buf	*snd_buf = &rqstp->rq_snd_buf;
 	struct xdr_buf	integ_buf;
@@ -1249,9 +1259,7 @@ gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	status = encode(rqstp, p, obj);
-	if (status)
-		return status;
+	gss_wrap_req_encode(encode, rqstp, p, obj);
 
 	if (xdr_buf_subsegment(snd_buf, &integ_buf,
 				offset, snd_buf->len - offset))
@@ -1325,7 +1333,8 @@ out:
 
 static inline int
 gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		kxdrproc_t encode, struct rpc_rqst *rqstp, __be32 *p, void *obj)
+		  kxdreproc_t encode, struct rpc_rqst *rqstp,
+		  __be32 *p, void *obj)
 {
 	struct xdr_buf	*snd_buf = &rqstp->rq_snd_buf;
 	u32		offset;
@@ -1342,9 +1351,7 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	status = encode(rqstp, p, obj);
-	if (status)
-		return status;
+	gss_wrap_req_encode(encode, rqstp, p, obj);
 
 	status = alloc_enc_pages(rqstp);
 	if (status)
@@ -1394,7 +1401,7 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 
 static int
 gss_wrap_req(struct rpc_task *task,
-	     kxdrproc_t encode, void *rqstp, __be32 *p, void *obj)
+	     kxdreproc_t encode, void *rqstp, __be32 *p, void *obj)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 	struct gss_cred	*gss_cred = container_of(cred, struct gss_cred,
@@ -1407,12 +1414,14 @@ gss_wrap_req(struct rpc_task *task,
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
-		status = encode(rqstp, p, obj);
+		gss_wrap_req_encode(encode, rqstp, p, obj);
+		status = 0;
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
 		case RPC_GSS_SVC_NONE:
-			status = encode(rqstp, p, obj);
+			gss_wrap_req_encode(encode, rqstp, p, obj);
+			status = 0;
 			break;
 		case RPC_GSS_SVC_INTEGRITY:
 			status = gss_wrap_req_integ(cred, ctx, encode,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..1ab7a34 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1089,7 +1089,7 @@ static void
 rpc_xdr_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrproc_t	encode;
+	kxdreproc_t	encode;
 	__be32		*p;
 
 	dprint_status(task);
@@ -1770,7 +1770,7 @@ out_overflow:
 	goto out_garbage;
 }
 
-static int rpcproc_encode_null(void *rqstp, __be32 *data, void *obj)
+static int rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
 {
 	return 0;
 }
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d2a2ea0..93bb72d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -693,25 +693,21 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
  * XDR functions for rpcbind
  */
 
-static int rpcb_enc_mapping(struct rpc_rqst *req, __be32 *p,
-			    const struct rpcbind_args *rpcb)
+static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     const struct rpcbind_args *rpcb)
 {
 	struct rpc_task *task = req->rq_task;
-	struct xdr_stream xdr;
+	__be32 *p;
 
 	dprintk("RPC: %5u encoding PMAP_%s call (%u, %u, %d, %u)\n",
 			task->tk_pid, task->tk_msg.rpc_proc->p_name,
 			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-
-	p = xdr_reserve_space(&xdr, RPCB_mappingargs_sz << 2);
+	p = xdr_reserve_space(xdr, RPCB_mappingargs_sz << 2);
 	*p++ = cpu_to_be32(rpcb->r_prog);
 	*p++ = cpu_to_be32(rpcb->r_vers);
 	*p++ = cpu_to_be32(rpcb->r_prot);
 	*p   = cpu_to_be32(rpcb->r_port);
-
-	return 0;
 }
 
 static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
@@ -773,27 +769,24 @@ static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 	xdr_encode_opaque(p, string, len);
 }
 
-static int rpcb_enc_getaddr(struct rpc_rqst *req, __be32 *p,
-			    const struct rpcbind_args *rpcb)
+static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     const struct rpcbind_args *rpcb)
 {
 	struct rpc_task *task = req->rq_task;
-	struct xdr_stream xdr;
+	__be32 *p;
 
 	dprintk("RPC: %5u encoding RPCB_%s call (%u, %u, '%s', '%s')\n",
 			task->tk_pid, task->tk_msg.rpc_proc->p_name,
 			rpcb->r_prog, rpcb->r_vers,
 			rpcb->r_netid, rpcb->r_addr);
 
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-
-	p = xdr_reserve_space(&xdr, (RPCB_program_sz + RPCB_version_sz) << 2);
+	p = xdr_reserve_space(xdr, (RPCB_program_sz + RPCB_version_sz) << 2);
 	*p++ = cpu_to_be32(rpcb->r_prog);
 	*p = cpu_to_be32(rpcb->r_vers);
 
-	encode_rpcb_string(&xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN);
-	encode_rpcb_string(&xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN);
-	encode_rpcb_string(&xdr, rpcb->r_owner, RPCB_MAXOWNERLEN);
-	return 0;
+	encode_rpcb_string(xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN);
+	encode_rpcb_string(xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN);
+	encode_rpcb_string(xdr, rpcb->r_owner, RPCB_MAXOWNERLEN);
 }
 
 static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
@@ -853,7 +846,7 @@ out_fail:
 static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -863,7 +856,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -873,7 +866,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_GETPORT] = {
 		.p_proc		= RPCBPROC_GETPORT,
-		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
 		.p_decode	= (kxdrproc_t)rpcb_dec_getport,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_getportres_sz,
@@ -886,7 +879,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -896,7 +889,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -906,7 +899,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
@@ -919,7 +912,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -929,7 +922,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -939,7 +932,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
 		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,

