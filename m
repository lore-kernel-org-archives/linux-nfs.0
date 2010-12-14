Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49543 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758197Ab0LNO7h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:59:37 -0500
Received: by mail-iw0-f174.google.com with SMTP id 9so864340iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:59:34 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 31/31] SUNRPC: New xdr_streams XDR decoder API
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:59:29 -0500
Message-ID: <20101214145929.2293.9555.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now that all client-side XDR decoder routines use xdr_streams, there
should be no need to support the legacy calling sequence [rpc_rqst *,
__be32 *, RPC res *] anywhere.  We can construct an xdr_stream in the
generic RPC code, instead of in each decoder function.

This is a refactoring change.  It should not cause different behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/lockd/clnt4xdr.c            |   20 +
 fs/lockd/clntxdr.c             |   20 +
 fs/lockd/mon.c                 |   30 +-
 fs/nfs/mount_clnt.c            |   30 +-
 fs/nfs/nfs2xdr.c               |   68 ++--
 fs/nfs/nfs3xdr.c               |  195 ++++++-------
 fs/nfs/nfs4xdr.c               |  619 ++++++++++++++++++++--------------------
 fs/nfsd/nfs4callback.c         |   16 +
 include/linux/sunrpc/auth.h    |    4 
 include/linux/sunrpc/clnt.h    |    2 
 include/linux/sunrpc/xdr.h     |    3 
 net/sunrpc/auth.c              |   14 +
 net/sunrpc/auth_gss/auth_gss.c |   13 +
 net/sunrpc/clnt.c              |    4 
 net/sunrpc/rpcb_clnt.c         |   46 +--
 15 files changed, 518 insertions(+), 566 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 974f1d9..f848b52 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -529,17 +529,16 @@ out:
 	return error;
 }
 
-static int nlm4_xdr_dec_testres(struct rpc_rqst *req, __be32 *p,
+static int nlm4_xdr_dec_testres(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
 				struct nlm_res *result)
 {
-	struct xdr_stream xdr;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_cookie(&xdr, &result->cookie);
+	error = decode_cookie(xdr, &result->cookie);
 	if (unlikely(error))
 		goto out;
-	error = decode_nlm4_testrply(&xdr, result);
+	error = decode_nlm4_testrply(xdr, result);
 out:
 	return error;
 }
@@ -550,17 +549,16 @@ out:
  *		nlm4_stat stat;
  *	};
  */
-static int nlm4_xdr_dec_res(struct rpc_rqst *req, __be32 *p,
+static int nlm4_xdr_dec_res(struct rpc_rqst *req,
+			    struct xdr_stream *xdr,
 			    struct nlm_res *result)
 {
-	struct xdr_stream xdr;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_cookie(&xdr, &result->cookie);
+	error = decode_cookie(xdr, &result->cookie);
 	if (unlikely(error))
 		goto out;
-	error = decode_nlm4_stat(&xdr, &result->status);
+	error = decode_nlm4_stat(xdr, &result->status);
 out:
 	return error;
 }
@@ -575,7 +573,7 @@ out:
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdreproc_t)nlm4_xdr_enc_##argtype,		\
-	.p_decode    = (kxdrproc_t)nlm4_xdr_dec_##restype,		\
+	.p_decode    = (kxdrdproc_t)nlm4_xdr_dec_##restype,		\
 	.p_arglen    = NLM4_##argtype##_sz,				\
 	.p_replen    = NLM4_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index c6fda8f..180ac34 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -527,17 +527,16 @@ out:
 	return error;
 }
 
-static int nlm_xdr_dec_testres(struct rpc_rqst *req, __be32 *p,
+static int nlm_xdr_dec_testres(struct rpc_rqst *req,
+			       struct xdr_stream *xdr,
 			       struct nlm_res *result)
 {
-	struct xdr_stream xdr;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_cookie(&xdr, &result->cookie);
+	error = decode_cookie(xdr, &result->cookie);
 	if (unlikely(error))
 		goto out;
-	error = decode_nlm_testrply(&xdr, result);
+	error = decode_nlm_testrply(xdr, result);
 out:
 	return error;
 }
@@ -548,17 +547,16 @@ out:
  *		nlm_stat stat;
  *	};
  */
-static int nlm_xdr_dec_res(struct rpc_rqst *req, __be32 *p,
+static int nlm_xdr_dec_res(struct rpc_rqst *req,
+			   struct xdr_stream *xdr,
 			   struct nlm_res *result)
 {
-	struct xdr_stream xdr;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_cookie(&xdr, &result->cookie);
+	error = decode_cookie(xdr, &result->cookie);
 	if (unlikely(error))
 		goto out;
-	error = decode_nlm_stat(&xdr, &result->status);
+	error = decode_nlm_stat(xdr, &result->status);
 out:
 	return error;
 }
@@ -573,7 +571,7 @@ out:
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdreproc_t)nlm_xdr_enc_##argtype,		\
-	.p_decode    = (kxdrproc_t)nlm_xdr_dec_##restype,		\
+	.p_decode    = (kxdrdproc_t)nlm_xdr_dec_##restype,		\
 	.p_arglen    = NLM_##argtype##_sz,				\
 	.p_replen    = NLM_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index baa77bc..23d7451 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -472,35 +472,35 @@ static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_mon_id(xdr, argp);
 }
 
-static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
-			    struct nsm_res *resp)
+static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct nsm_res *resp)
 {
-	struct xdr_stream xdr;
+	__be32 *p;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	p = xdr_inline_decode(&xdr, 4 + 4);
+	p = xdr_inline_decode(xdr, 4 + 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 	resp->status = be32_to_cpup(p++);
 	resp->state = be32_to_cpup(p);
 
-	dprintk("lockd: xdr_dec_stat_res status %d state %d\n",
-			resp->status, resp->state);
+	dprintk("lockd: %s status %d state %d\n",
+		__func__, resp->status, resp->state);
 	return 0;
 }
 
-static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
-			struct nsm_res *resp)
+static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
+			    struct xdr_stream *xdr,
+			    struct nsm_res *resp)
 {
-	struct xdr_stream xdr;
+	__be32 *p;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	p = xdr_inline_decode(&xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 	resp->state = be32_to_cpup(p);
 
-	dprintk("lockd: xdr_dec_stat state %d\n", resp->state);
+	dprintk("lockd: %s state %d\n", __func__, resp->state);
 	return 0;
 }
 
@@ -517,7 +517,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
 		.p_encode	= (kxdreproc_t)nsm_xdr_enc_mon,
-		.p_decode	= (kxdrproc_t)xdr_dec_stat_res,
+		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
 		.p_statidx	= NSMPROC_MON,
@@ -526,7 +526,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
 		.p_encode	= (kxdreproc_t)nsm_xdr_enc_unmon,
-		.p_decode	= (kxdrproc_t)xdr_dec_stat,
+		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= NSMPROC_UNMON,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 979ebd7..697e072 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -340,18 +340,16 @@ static int decode_fhandle(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
-static int mnt_dec_mountres(struct rpc_rqst *req, __be32 *p,
-			    struct mountres *res)
+static int mnt_xdr_dec_mountres(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				struct mountres *res)
 {
-	struct xdr_stream xdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-
-	status = decode_status(&xdr, res);
+	status = decode_status(xdr, res);
 	if (unlikely(status != 0 || res->errno != 0))
 		return status;
-	return decode_fhandle(&xdr, res);
+	return decode_fhandle(xdr, res);
 }
 
 static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
@@ -434,30 +432,28 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
-static int mnt_dec_mountres3(struct rpc_rqst *req, __be32 *p,
-			     struct mountres *res)
+static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 struct mountres *res)
 {
-	struct xdr_stream xdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-
-	status = decode_fhs_status(&xdr, res);
+	status = decode_fhs_status(xdr, res);
 	if (unlikely(status != 0 || res->errno != 0))
 		return status;
-	status = decode_fhandle3(&xdr, res);
+	status = decode_fhandle3(xdr, res);
 	if (unlikely(status != 0)) {
 		res->errno = -EBADHANDLE;
 		return 0;
 	}
-	return decode_auth_flavors(&xdr, res);
+	return decode_auth_flavors(xdr, res);
 }
 
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
 		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrproc_t)mnt_dec_mountres,
+		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres_sz,
 		.p_statidx	= MOUNTPROC_MNT,
@@ -476,7 +472,7 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
 		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrproc_t)mnt_dec_mountres3,
+		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres3_sz,
 		.p_statidx	= MOUNTPROC3_MNT,
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 8f3acbe..51f1cfa 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -783,15 +783,13 @@ static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
  * "NFS: Network File System Protocol Specification".
  */
 
-static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_stat(struct rpc_rqst *req, struct xdr_stream *xdr,
 			     void *__unused)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_stat(&xdr, &status);
+	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS_OK)
@@ -802,22 +800,16 @@ out_default:
 	return nfs_stat_to_errno(status);
 }
 
-static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs_fattr *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	return decode_attrstat(&xdr, result);
+	return decode_attrstat(xdr, result);
 }
 
-static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs_diropok *result)
 {
-	struct xdr_stream xdr;
-
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	return decode_diropres(&xdr, result);
+	return decode_diropres(xdr, result);
 }
 
 /*
@@ -830,20 +822,18 @@ static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
  *		void;
  *	};
  */
-static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req, __be32 *p,
-				    void *__unused)
+static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req,
+				    struct xdr_stream *xdr, void *__unused)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_stat(&xdr, &status);
+	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_path(&xdr);
+	error = decode_path(xdr);
 out:
 	return error;
 out_default:
@@ -861,39 +851,33 @@ out_default:
  *		void;
  *	};
  */
-static int nfs2_xdr_dec_readres(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
 				struct nfs_readres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_stat(&xdr, &status);
+	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_fattr(&xdr, result->fattr);
+	error = decode_fattr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
-	error = decode_nfsdata(&xdr, result);
+	error = decode_nfsdata(xdr, result);
 out:
 	return error;
 out_default:
 	return nfs_stat_to_errno(status);
 }
 
-static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs_writeres *result)
 {
-	struct xdr_stream xdr;
-
 	/* All NFSv2 writes are "file sync" writes */
 	result->verf->committed = NFS_FILE_SYNC;
-
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	return decode_attrstat(&xdr, result->fattr);
+	return decode_attrstat(xdr, result->fattr);
 }
 
 /**
@@ -1008,20 +992,18 @@ out_cheating:
 	goto out;
 }
 
-static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req, __be32 *p,
-				   void *__unused)
+static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req,
+				   struct xdr_stream *xdr, void *__unused)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_stat(&xdr, &status);
+	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_readdirok(&xdr);
+	error = decode_readdirok(xdr);
 out:
 	return error;
 out_default:
@@ -1062,20 +1044,18 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, __be32 *p,
+static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, struct xdr_stream *xdr,
 				  struct nfs2_fsstat *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_stat(&xdr, &status);
+	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_info(&xdr, result);
+	error = decode_info(xdr, result);
 out:
 	return error;
 out_default:
@@ -1150,7 +1130,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdreproc_t)nfs2_xdr_enc_##argtype,		\
-	.p_decode   =  (kxdrproc_t)nfs2_xdr_dec_##restype,		\
+	.p_decode   =  (kxdrdproc_t)nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index ae1b1a43..df30a26 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1366,20 +1366,19 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
  *		void;
  *	};
  */
-static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
 				    struct nfs_fattr *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_fattr3(&xdr, result);
+	error = decode_fattr3(xdr, result);
 out:
 	return error;
 out_default:
@@ -1404,18 +1403,17 @@ out_default:
  *		SETATTR3resfail resfail;
  *	};
  */
-static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
 				    struct nfs_fattr *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result);
+	error = decode_wcc_data(xdr, result);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1446,30 +1444,29 @@ out_status:
  *		LOOKUP3resfail	resfail;
  *	};
  */
-static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs3_diropres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_nfs_fh3(&xdr, result->fh);
+	error = decode_nfs_fh3(xdr, result->fh);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr);
 out:
 	return error;
 out_default:
-	error = decode_post_op_attr(&xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
 	return nfs_stat_to_errno(status);
@@ -1494,23 +1491,22 @@ out_default:
  *		ACCESS3resfail	resfail;
  *	};
  */
-static int nfs3_xdr_dec_access3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs3_accessres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_uint32(&xdr, &result->access);
+	error = decode_uint32(xdr, &result->access);
 out:
 	return error;
 out_default:
@@ -1536,23 +1532,22 @@ out_default:
  *		READLINK3resfail resfail;
  *	};
  */
-static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
 				     struct nfs_fattr *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result);
+	error = decode_post_op_attr(xdr, result);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_nfspath3(&xdr);
+	error = decode_nfspath3(xdr);
 out:
 	return error;
 out_default:
@@ -1620,23 +1615,21 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs_readres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_read3resok(&xdr, result);
+	error = decode_read3resok(xdr, result);
 out:
 	return error;
 out_status:
@@ -1692,23 +1685,21 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 				  struct nfs_writeres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->fattr);
+	error = decode_wcc_data(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_write3resok(&xdr, result);
+	error = decode_write3resok(xdr, result);
 out:
 	return error;
 out_status:
@@ -1757,24 +1748,23 @@ out:
 	return error;
 }
 
-static int nfs3_xdr_dec_create3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs3_diropres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_create3resok(&xdr, result);
+	error = decode_create3resok(xdr, result);
 out:
 	return error;
 out_default:
-	error = decode_wcc_data(&xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
 	return nfs_stat_to_errno(status);
@@ -1798,18 +1788,17 @@ out_default:
  *		REMOVE3resfail resfail;
  *	};
  */
-static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_removeres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1840,21 +1829,20 @@ out_status:
  *		RENAME3resfail resfail;
  *	};
  */
-static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_renameres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->old_fattr);
+	error = decode_wcc_data(xdr, result->old_fattr);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->new_fattr);
+	error = decode_wcc_data(xdr, result->new_fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1885,21 +1873,19 @@ out_status:
  *		LINK3resfail	resfail;
  *	};
  */
-static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs3_linkres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -2085,24 +2071,23 @@ out:
 	return error;
 }
 
-static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
 				    struct nfs3_readdirres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_readdir3resok(&xdr, result);
+	error = decode_readdir3resok(xdr, result);
 out:
 	return error;
 out_default:
-	error = decode_post_op_attr(&xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
 	return nfs_stat_to_errno(status);
@@ -2154,23 +2139,22 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_fsstat *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_fsstat3resok(&xdr, result);
+	error = decode_fsstat3resok(xdr, result);
 out:
 	return error;
 out_status:
@@ -2231,23 +2215,22 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_fsinfo *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_fsinfo3resok(&xdr, result);
+	error = decode_fsinfo3resok(xdr, result);
 out:
 	return error;
 out_status:
@@ -2295,23 +2278,22 @@ out_overflow:
 	return -EIO;
 }
 
-static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
 				     struct nfs_pathconf *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(&xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_pathconf3resok(&xdr, result);
+	error = decode_pathconf3resok(xdr, result);
 out:
 	return error;
 out_status:
@@ -2337,23 +2319,22 @@ out_status:
  *		COMMIT3resfail	resfail;
  *	};
  */
-static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_writeres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(&xdr, result->fattr);
+	error = decode_wcc_data(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_status;
-	error = decode_writeverf3(&xdr, result->verf->verifier);
+	error = decode_writeverf3(xdr, result->verf->verifier);
 out:
 	return error;
 out_status:
@@ -2406,40 +2387,38 @@ out:
 	return error;
 }
 
-static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs3_getaclres *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_getacl3resok(&xdr, result);
+	error = decode_getacl3resok(xdr, result);
 out:
 	return error;
 out_default:
 	return nfs_stat_to_errno(status);
 }
 
-static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req, __be32 *p,
+static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
 				   struct nfs_fattr *result)
 {
-	struct xdr_stream xdr;
 	enum nfs_stat status;
 	int error;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	error = decode_nfsstat3(&xdr, &status);
+	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_post_op_attr(&xdr, result);
+	error = decode_post_op_attr(xdr, result);
 out:
 	return error;
 out_default:
@@ -2452,7 +2431,7 @@ out_default:
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = (kxdreproc_t)nfs3_xdr_enc_##argtype##3args,	\
-	.p_decode    = (kxdrproc_t)nfs3_xdr_dec_##restype##3res,	\
+	.p_decode    = (kxdrdproc_t)nfs3_xdr_dec_##restype##3res,	\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##res_sz,				\
 	.p_timer     = timer,						\
@@ -2495,7 +2474,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = (kxdreproc_t)nfs3_xdr_enc_getacl3args,
-		.p_decode = (kxdrproc_t)nfs3_xdr_dec_getacl3res,
+		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
@@ -2504,7 +2483,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
 		.p_encode = (kxdreproc_t)nfs3_xdr_enc_setacl3args,
-		.p_decode = (kxdrproc_t)nfs3_xdr_dec_setacl3res,
+		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6ec38b3..f3f9915 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5013,26 +5013,26 @@ out_overflow:
 /*
  * Decode OPEN_DOWNGRADE response
  */
-static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
+static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
+				       struct xdr_stream *xdr,
+				       struct nfs_closeres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_open_downgrade(&xdr, res);
+	status = decode_open_downgrade(xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5041,26 +5041,25 @@ out:
 /*
  * Decode ACCESS response
  */
-static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_accessres *res)
+static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs4_accessres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
-	status = decode_access(&xdr, res);
+	status = decode_access(xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5069,26 +5068,28 @@ out:
 /*
  * Decode LOOKUP response
  */
-static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lookup_res *res)
+static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs4_lookup_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_lookup(&xdr)) != 0)
+	status = decode_lookup(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_getfh(&xdr, res->fh)) != 0)
+	status = decode_getfh(xdr, res->fh);
+	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server
+	status = decode_getfattr(xdr, res->fattr, res->server
 			,!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5097,23 +5098,25 @@ out:
 /*
  * Decode LOOKUP_ROOT response
  */
-static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lookup_res *res)
+static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    struct nfs4_lookup_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putrootfh(&xdr)) != 0)
+	status = decode_putrootfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_getfh(&xdr, res->fh)) == 0)
-		status = decode_getfattr(&xdr, res->fattr, res->server,
+	status = decode_getfh(xdr, res->fh);
+	if (status == 0)
+		status = decode_getfattr(xdr, res->fattr, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5122,24 +5125,25 @@ out:
 /*
  * Decode REMOVE response
  */
-static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_removeres *res)
+static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs_removeres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
+	status = decode_remove(xdr, &res->cinfo);
+	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server,
+	decode_getfattr(xdr, res->dir_attr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5148,34 +5152,38 @@ out:
 /*
  * Decode RENAME response
  */
-static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs_renameres *res)
+static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs_renameres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_savefh(&xdr)) != 0)
+	status = decode_savefh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_rename(&xdr, &res->old_cinfo, &res->new_cinfo)) != 0)
+	status = decode_rename(xdr, &res->old_cinfo, &res->new_cinfo);
+	if (status)
 		goto out;
 	/* Current FH is target directory */
-	if (decode_getfattr(&xdr, res->new_fattr, res->server,
+	if (decode_getfattr(xdr, res->new_fattr, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
-	if ((status = decode_restorefh(&xdr)) != 0)
+	status = decode_restorefh(xdr);
+	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->old_fattr, res->server,
+	decode_getfattr(xdr, res->old_fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5184,37 +5192,41 @@ out:
 /*
  * Decode LINK response
  */
-static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link_res *res)
+static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			     struct nfs4_link_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_savefh(&xdr)) != 0)
+	status = decode_savefh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_link(&xdr, &res->cinfo)) != 0)
+	status = decode_link(xdr, &res->cinfo);
+	if (status)
 		goto out;
 	/*
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(&xdr, res->dir_attr, res->server,
+	if (decode_getfattr(xdr, res->dir_attr, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
-	if ((status = decode_restorefh(&xdr)) != 0)
+	status = decode_restorefh(xdr);
+	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5223,33 +5235,37 @@ out:
 /*
  * Decode CREATE response
  */
-static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_create_res *res)
+static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs4_create_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_savefh(&xdr)) != 0)
+	status = decode_savefh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_create(&xdr,&res->dir_cinfo)) != 0)
+	status = decode_create(xdr, &res->dir_cinfo);
+	if (status)
 		goto out;
-	if ((status = decode_getfh(&xdr, res->fh)) != 0)
+	status = decode_getfh(xdr, res->fh);
+	if (status)
 		goto out;
-	if (decode_getfattr(&xdr, res->fattr, res->server,
+	if (decode_getfattr(xdr, res->fattr, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
-	if ((status = decode_restorefh(&xdr)) != 0)
+	status = decode_restorefh(xdr);
+	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->dir_fattr, res->server,
+	decode_getfattr(xdr, res->dir_fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5258,31 +5274,31 @@ out:
 /*
  * Decode SYMLINK response
  */
-static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_create_res *res)
+static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+				struct nfs4_create_res *res)
 {
-	return nfs4_xdr_dec_create(rqstp, p, res);
+	return nfs4_xdr_dec_create(rqstp, xdr, res);
 }
 
 /*
  * Decode GETATTR response
  */
-static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_getattr_res *res)
+static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+				struct nfs4_getattr_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server,
+	status = decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5309,24 +5325,22 @@ static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Decode SETACL response
  */
 static int
-nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
+nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		    struct nfs_setaclres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr);
+	status = decode_setattr(xdr);
 out:
 	return status;
 }
@@ -5335,24 +5349,22 @@ out:
  * Decode GETACL response
  */
 static int
-nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
+nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		    struct nfs_getaclres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_getacl(&xdr, rqstp, &res->acl_len);
+	status = decode_getacl(xdr, rqstp, &res->acl_len);
 
 out:
 	return status;
@@ -5361,23 +5373,22 @@ out:
 /*
  * Decode CLOSE response
  */
-static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
+static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			      struct nfs_closeres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_close(&xdr, res);
+	status = decode_close(xdr, res);
 	if (status != 0)
 		goto out;
 	/*
@@ -5386,7 +5397,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5395,36 +5406,35 @@ out:
 /*
  * Decode OPEN response
  */
-static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
+static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			     struct nfs_openres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_savefh(&xdr);
+	status = decode_savefh(xdr);
 	if (status)
 		goto out;
-	status = decode_open(&xdr, res);
+	status = decode_open(xdr, res);
 	if (status)
 		goto out;
-	if (decode_getfh(&xdr, &res->fh) != 0)
+	if (decode_getfh(xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->f_attr, res->server,
+	if (decode_getfattr(xdr, res->f_attr, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
-	if (decode_restorefh(&xdr) != 0)
+	if (decode_restorefh(xdr) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server,
+	decode_getfattr(xdr, res->dir_attr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5433,20 +5443,20 @@ out:
 /*
  * Decode OPEN_CONFIRM response
  */
-static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp, __be32 *p, struct nfs_open_confirmres *res)
+static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp,
+				     struct xdr_stream *xdr,
+				     struct nfs_open_confirmres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_open_confirm(&xdr, res);
+	status = decode_open_confirm(xdr, res);
 out:
 	return status;
 }
@@ -5454,26 +5464,26 @@ out:
 /*
  * Decode OPEN response
  */
-static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
+static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    struct nfs_openres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_open(&xdr, res);
+	status = decode_open(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->f_attr, res->server,
+	decode_getfattr(xdr, res->f_attr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5482,26 +5492,26 @@ out:
 /*
  * Decode SETATTR response
  */
-static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_setattrres *res)
+static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct nfs_setattrres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr);
+	status = decode_setattr(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5510,23 +5520,22 @@ out:
 /*
  * Decode LOCK response
  */
-static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_res *res)
+static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			     struct nfs_lock_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_lock(&xdr, res);
+	status = decode_lock(xdr, res);
 out:
 	return status;
 }
@@ -5534,23 +5543,22 @@ out:
 /*
  * Decode LOCKT response
  */
-static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lockt_res *res)
+static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			      struct nfs_lockt_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_lockt(&xdr, res);
+	status = decode_lockt(xdr, res);
 out:
 	return status;
 }
@@ -5558,61 +5566,58 @@ out:
 /*
  * Decode LOCKU response
  */
-static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_locku_res *res)
+static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			      struct nfs_locku_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_locku(&xdr, res);
+	status = decode_locku(xdr, res);
 out:
 	return status;
 }
 
-static int nfs4_xdr_dec_release_lockowner(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfs4_xdr_dec_release_lockowner(struct rpc_rqst *rqstp,
+					  struct xdr_stream *xdr, void *dummy)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_release_lockowner(&xdr);
+		status = decode_release_lockowner(xdr);
 	return status;
 }
 
 /*
  * Decode READLINK response
  */
-static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
+static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp,
+				 struct xdr_stream *xdr,
 				 struct nfs4_readlink_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_readlink(&xdr, rqstp);
+	status = decode_readlink(xdr, rqstp);
 out:
 	return status;
 }
@@ -5620,23 +5625,22 @@ out:
 /*
  * Decode READDIR response
  */
-static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_readdir_res *res)
+static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+				struct nfs4_readdir_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_readdir(&xdr, rqstp, res);
+	status = decode_readdir(xdr, rqstp, res);
 out:
 	return status;
 }
@@ -5644,23 +5648,22 @@ out:
 /*
  * Decode Read response
  */
-static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readres *res)
+static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			     struct nfs_readres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_read(&xdr, rqstp, res);
+	status = decode_read(xdr, rqstp, res);
 	if (!status)
 		status = res->count;
 out:
@@ -5670,26 +5673,25 @@ out:
 /*
  * Decode WRITE response
  */
-static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writeres *res)
+static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			      struct nfs_writeres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_write(&xdr, res);
+	status = decode_write(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 	if (!status)
 		status = res->count;
@@ -5700,26 +5702,25 @@ out:
 /*
  * Decode COMMIT response
  */
-static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writeres *res)
+static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       struct nfs_writeres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_commit(&xdr, res);
+	status = decode_commit(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5728,85 +5729,80 @@ out:
 /*
  * Decode FSINFO response
  */
-static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
+static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
 			       struct nfs4_fsinfo_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, &res->seq_res, req);
+		status = decode_sequence(xdr, &res->seq_res, req);
 	if (!status)
-		status = decode_putfh(&xdr);
+		status = decode_putfh(xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, res->fsinfo);
+		status = decode_fsinfo(xdr, res->fsinfo);
 	return status;
 }
 
 /*
  * Decode PATHCONF response
  */
-static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
+static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs4_pathconf_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, &res->seq_res, req);
+		status = decode_sequence(xdr, &res->seq_res, req);
 	if (!status)
-		status = decode_putfh(&xdr);
+		status = decode_putfh(xdr);
 	if (!status)
-		status = decode_pathconf(&xdr, res->pathconf);
+		status = decode_pathconf(xdr, res->pathconf);
 	return status;
 }
 
 /*
  * Decode STATFS response
  */
-static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
+static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
 			       struct nfs4_statfs_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, &res->seq_res, req);
+		status = decode_sequence(xdr, &res->seq_res, req);
 	if (!status)
-		status = decode_putfh(&xdr);
+		status = decode_putfh(xdr);
 	if (!status)
-		status = decode_statfs(&xdr, res->fsstat);
+		status = decode_statfs(xdr, res->fsstat);
 	return status;
 }
 
 /*
  * Decode GETATTR_BITMAP response
  */
-static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4_server_caps_res *res)
+static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    struct nfs4_server_caps_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, req);
+	status = decode_sequence(xdr, &res->seq_res, req);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	status = decode_server_caps(&xdr, res);
+	status = decode_server_caps(xdr, res);
 out:
 	return status;
 }
@@ -5814,79 +5810,77 @@ out:
 /*
  * Decode RENEW response
  */
-static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			      void *__unused)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_renew(&xdr);
+		status = decode_renew(xdr);
 	return status;
 }
 
 /*
  * Decode SETCLIENTID response
  */
-static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
-		struct nfs4_setclientid_res *res)
+static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    struct nfs4_setclientid_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_setclientid(&xdr, res);
+		status = decode_setclientid(xdr, res);
 	return status;
 }
 
 /*
  * Decode SETCLIENTID_CONFIRM response
  */
-static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
+static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
+					    struct xdr_stream *xdr,
+					    struct nfs_fsinfo *fsinfo)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_setclientid_confirm(&xdr);
+		status = decode_setclientid_confirm(xdr);
 	if (!status)
-		status = decode_putrootfh(&xdr);
+		status = decode_putrootfh(xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, fsinfo);
+		status = decode_fsinfo(xdr, fsinfo);
 	return status;
 }
 
 /*
  * Decode DELEGRETURN response
  */
-static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_delegreturnres *res)
+static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    struct nfs4_delegreturnres *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
-	status = decode_delegreturn(&xdr);
+	status = decode_delegreturn(xdr);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5895,26 +5889,27 @@ out:
 /*
  * Decode FS_LOCATIONS response
  */
-static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
+static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
 				     struct nfs4_fs_locations_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, req);
+	status = decode_sequence(xdr, &res->seq_res, req);
 	if (status)
 		goto out;
-	if ((status = decode_putfh(&xdr)) != 0)
+	status = decode_putfh(xdr);
+	if (status)
 		goto out;
-	if ((status = decode_lookup(&xdr)) != 0)
+	status = decode_lookup(xdr);
+	if (status)
 		goto out;
-	xdr_enter_page(&xdr, PAGE_SIZE);
-	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
+	xdr_enter_page(xdr, PAGE_SIZE);
+	status = decode_getfattr(xdr, &res->fs_locations->fattr,
 				 res->fs_locations->server,
 				 !RPC_IS_ASYNC(req->rq_task));
 out:
@@ -5925,129 +5920,122 @@ out:
 /*
  * Decode EXCHANGE_ID response
  */
-static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
 				    void *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_exchange_id(&xdr, res);
+		status = decode_exchange_id(xdr, res);
 	return status;
 }
 
 /*
  * Decode CREATE_SESSION response
  */
-static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp,
+				       struct xdr_stream *xdr,
 				       struct nfs41_create_session_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_create_session(&xdr, res);
+		status = decode_create_session(xdr, res);
 	return status;
 }
 
 /*
  * Decode DESTROY_SESSION response
  */
-static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
-					void *dummy)
+static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					void *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_destroy_session(&xdr, dummy);
+		status = decode_destroy_session(xdr, res);
 	return status;
 }
 
 /*
  * Decode SEQUENCE response
  */
-static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
+				 struct xdr_stream *xdr,
 				 struct nfs4_sequence_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, res, rqstp);
+		status = decode_sequence(xdr, res, rqstp);
 	return status;
 }
 
 /*
  * Decode GET_LEASE_TIME response
  */
-static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp,
+				       struct xdr_stream *xdr,
 				       struct nfs4_get_lease_time_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, &res->lr_seq_res, rqstp);
+		status = decode_sequence(xdr, &res->lr_seq_res, rqstp);
 	if (!status)
-		status = decode_putrootfh(&xdr);
+		status = decode_putrootfh(xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, res->lr_fsinfo);
+		status = decode_fsinfo(xdr, res->lr_fsinfo);
 	return status;
 }
 
 /*
  * Decode RECLAIM_COMPLETE response
  */
-static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
+					 struct xdr_stream *xdr,
 					 struct nfs41_reclaim_complete_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
-		status = decode_sequence(&xdr, &res->seq_res, rqstp);
+		status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (!status)
-		status = decode_reclaim_complete(&xdr, (void *)NULL);
+		status = decode_reclaim_complete(xdr, (void *)NULL);
 	return status;
 }
 
 /*
  * Decode GETDEVINFO response
  */
-static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
+				      struct xdr_stream *xdr,
 				      struct nfs4_getdeviceinfo_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status != 0)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status != 0)
 		goto out;
-	status = decode_getdeviceinfo(&xdr, res->pdev);
+	status = decode_getdeviceinfo(xdr, res->pdev);
 out:
 	return status;
 }
@@ -6055,24 +6043,23 @@ out:
 /*
  * Decode LAYOUTGET response
  */
-static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
+static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp,
+				  struct xdr_stream *xdr,
 				  struct nfs4_layoutget_res *res)
 {
-	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
+	status = decode_compound_hdr(xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status)
 		goto out;
-	status = decode_putfh(&xdr);
+	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_layoutget(&xdr, rqstp, res);
+	status = decode_layoutget(xdr, rqstp, res);
 out:
 	return status;
 }
@@ -6236,7 +6223,7 @@ nfs4_stat_to_errno(int stat)
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
 	.p_encode = (kxdreproc_t)nfs4_xdr_##argtype,		\
-	.p_decode = (kxdrproc_t)nfs4_xdr_##restype,		\
+	.p_decode = (kxdrdproc_t)nfs4_xdr_##restype,		\
 	.p_arglen = NFS4_##argtype##_sz,			\
 	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c363efd..21a63da 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -533,7 +533,8 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Protocol".
  */
 
-static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p, void *__unused)
+static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *__unused)
 {
 	return 0;
 }
@@ -541,26 +542,25 @@ static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p, void *__unused)
 /*
  * 20.2. Operation 4: CB_RECALL - Recall a Delegation
  */
-static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
+static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
+				  struct xdr_stream *xdr,
 				  struct nfsd4_callback *cb)
 {
-	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
 	enum nfsstat4 nfserr;
 	int status;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_cb_compound4res(&xdr, &hdr);
+	status = decode_cb_compound4res(xdr, &hdr);
 	if (unlikely(status))
 		goto out;
 
 	if (cb != NULL) {
-		status = decode_cb_sequence4res(&xdr, cb);
+		status = decode_cb_sequence4res(xdr, cb);
 		if (unlikely(status))
 			goto out;
 	}
 
-	status = decode_cb_op_status(&xdr, OP_CB_RECALL, &nfserr);
+	status = decode_cb_op_status(xdr, OP_CB_RECALL, &nfserr);
 	if (unlikely(status))
 		goto out;
 	if (unlikely(nfserr != NFS4_OK))
@@ -578,7 +578,7 @@ out_default:
 [NFSPROC4_CLNT_##proc] = {						\
 	.p_proc    = NFSPROC4_CB_##call,				\
 	.p_encode  = (kxdreproc_t)nfs4_xdr_enc_##argtype,		\
-	.p_decode  = (kxdrproc_t)nfs4_xdr_dec_##restype,		\
+	.p_decode  = (kxdrdproc_t)nfs4_xdr_dec_##restype,		\
 	.p_arglen  = NFS4_enc_##argtype##_sz,				\
 	.p_replen  = NFS4_dec_##restype##_sz,				\
 	.p_statidx = NFSPROC4_CB_##call,				\
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index d88cffb..8521067 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -112,7 +112,7 @@ struct rpc_credops {
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
 	int			(*crwrap_req)(struct rpc_task *, kxdreproc_t,
 						void *, __be32 *, void *);
-	int			(*crunwrap_resp)(struct rpc_task *, kxdrproc_t,
+	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
 };
 
@@ -140,7 +140,7 @@ void			put_rpccred(struct rpc_cred *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
 int			rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp, __be32 *data, void *obj);
-int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp, __be32 *data, void *obj);
+int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp, __be32 *data, void *obj);
 int			rpcauth_refreshcred(struct rpc_task *);
 void			rpcauth_invalcred(struct rpc_task *);
 int			rpcauth_uptodatecred(struct rpc_task *);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 7b19c4e..ef9476a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -90,7 +90,7 @@ struct rpc_version {
 struct rpc_procinfo {
 	u32			p_proc;		/* RPC procedure number */
 	kxdreproc_t		p_encode;	/* XDR encode function */
-	kxdrproc_t		p_decode;	/* XDR decode function */
+	kxdrdproc_t		p_decode;	/* XDR decode function */
 	unsigned int		p_arglen;	/* argument hdr length (u32) */
 	unsigned int		p_replen;	/* reply hdr length (u32) */
 	unsigned int		p_count;	/* call count */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index a21cf53..9a21e81 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -204,9 +204,10 @@ struct xdr_stream {
 };
 
 /*
- * This is the xdr_stream style generic XDR function.
+ * These are the xdr_stream style generic XDR encode and decode functions.
  */
 typedef void	(*kxdreproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
+typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 651c9da..67e3127 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -587,8 +587,18 @@ rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp,
 	return 0;
 }
 
+static int
+rpcauth_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
+			  __be32 *data, void *obj)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data);
+	return decode(rqstp, &xdr, obj);
+}
+
 int
-rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
+rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
@@ -599,7 +609,7 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
 	/* By default, we decode the arguments normally. */
-	return decode(rqstp, data, obj);
+	return rpcauth_unwrap_req_decode(decode, rqstp, data, obj);
 }
 
 int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 42b46f9..45dbf15 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1503,10 +1503,19 @@ gss_unwrap_resp_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	return 0;
 }
 
+static int
+gss_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
+		      __be32 *p, void *obj)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	return decode(rqstp, &xdr, obj);
+}
 
 static int
 gss_unwrap_resp(struct rpc_task *task,
-		kxdrproc_t decode, void *rqstp, __be32 *p, void *obj)
+		kxdrdproc_t decode, void *rqstp, __be32 *p, void *obj)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred,
@@ -1537,7 +1546,7 @@ gss_unwrap_resp(struct rpc_task *task,
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
 						+ (savedlen - head->iov_len);
 out_decode:
-	status = decode(rqstp, p, obj);
+	status = gss_unwrap_req_decode(decode, rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d446a32..4e8210d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1535,7 +1535,7 @@ call_decode(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
+	kxdrdproc_t	decode = task->tk_msg.rpc_proc->p_decode;
 	__be32		*p;
 
 	dprintk("RPC: %5u call_decode (status %d)\n",
@@ -1780,7 +1780,7 @@ static void rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
 {
 }
 
-static int rpcproc_decode_null(void *rqstp, __be32 *data, void *obj)
+static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
 {
 	return 0;
 }
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 63912a1..c652e4c 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -706,18 +706,16 @@ static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
 	*p   = cpu_to_be32(rpcb->r_port);
 }
 
-static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
+static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
 			    struct rpcbind_args *rpcb)
 {
 	struct rpc_task *task = req->rq_task;
-	struct xdr_stream xdr;
 	unsigned long port;
-
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	__be32 *p;
 
 	rpcb->r_port = 0;
 
-	p = xdr_inline_decode(&xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 
@@ -731,20 +729,18 @@ static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int rpcb_dec_set(struct rpc_rqst *req, __be32 *p,
+static int rpcb_dec_set(struct rpc_rqst *req, struct xdr_stream *xdr,
 			unsigned int *boolp)
 {
 	struct rpc_task *task = req->rq_task;
-	struct xdr_stream xdr;
-
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	__be32 *p;
 
-	p = xdr_inline_decode(&xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 
 	*boolp = 0;
-	if (*p)
+	if (*p != xdr_zero)
 		*boolp = 1;
 
 	dprintk("RPC: %5u RPCB_%s call %s\n",
@@ -785,20 +781,18 @@ static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_rpcb_string(xdr, rpcb->r_owner, RPCB_MAXOWNERLEN);
 }
 
-static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
+static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 			    struct rpcbind_args *rpcb)
 {
 	struct sockaddr_storage address;
 	struct sockaddr *sap = (struct sockaddr *)&address;
 	struct rpc_task *task = req->rq_task;
-	struct xdr_stream xdr;
+	__be32 *p;
 	u32 len;
 
 	rpcb->r_port = 0;
 
-	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-
-	p = xdr_inline_decode(&xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		goto out_fail;
 	len = be32_to_cpup(p);
@@ -816,7 +810,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
 	if (unlikely(len > RPCBIND_MAXUADDRLEN))
 		goto out_fail;
 
-	p = xdr_inline_decode(&xdr, len);
+	p = xdr_inline_decode(xdr, len);
 	if (unlikely(p == NULL))
 		goto out_fail;
 	dprintk("RPC: %5u RPCB_%s reply: %s\n", task->tk_pid,
@@ -843,7 +837,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -853,7 +847,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -863,7 +857,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_GETPORT] = {
 		.p_proc		= RPCBPROC_GETPORT,
 		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrproc_t)rpcb_dec_getport,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_getport,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_getportres_sz,
 		.p_statidx	= RPCBPROC_GETPORT,
@@ -876,7 +870,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -886,7 +880,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -896,7 +890,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,
@@ -909,7 +903,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -919,7 +913,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -929,7 +923,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
 		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
+		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,

