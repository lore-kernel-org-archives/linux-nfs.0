Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33356 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbbC0Qw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:28 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 34/39] nfs/sunrpc: No more encode and decode function pointer casting
Date: Fri, 27 Mar 2015 17:50:32 +0100
Message-Id: <b9b6a20ded5ff2623917fb35ddd2ce30d9638044.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of casting the encode and decode functions to the required type when
assigning them to the p_encode and p_decode members of struct rpc_procinfo,
define the functions with their proper type and cast the additional obj
argument to the appropriate type inside those functions. This allows slightly
better type checking by the compiler at the cost of slightly more verbose code.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/lockd/clnt4xdr.c                  |  28 ++--
 fs/lockd/clntxdr.c                   |  28 ++--
 fs/lockd/mon.c                       |  20 ++-
 fs/nfs/mount_clnt.c                  |  21 +--
 fs/nfs/nfs2xdr.c                     |  55 ++++---
 fs/nfs/nfs3xdr.c                     | 123 +++++++++------
 fs/nfs/nfs4xdr.c                     | 292 +++++++++++++++++++++++------------
 fs/nfsd/nfs4callback.c               |  16 +-
 include/linux/sunrpc/xdr.h           |   5 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   4 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c    |   6 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h    |   4 +-
 net/sunrpc/clnt.c                    |   4 +-
 net/sunrpc/rpcb_clnt.c               |  51 +++---
 14 files changed, 421 insertions(+), 236 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index d3e40db..693f71a 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -381,8 +381,9 @@ static void encode_nlm4_lock(struct xdr_stream *xdr,
  */
 static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -402,8 +403,9 @@ static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -424,8 +426,9 @@ static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -442,8 +445,9 @@ static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nlm_args *args)
+				    void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -458,8 +462,9 @@ static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_res(struct rpc_rqst *req,
 			     struct xdr_stream *xdr,
-			     const struct nlm_res *result)
+			     void *obj)
 {
+	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
 }
@@ -479,8 +484,9 @@ static void nlm4_xdr_enc_res(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_testres(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_res *result)
+				 void *obj)
 {
+	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
 	if (result->status == nlm_lck_denied)
@@ -525,8 +531,9 @@ out:
 
 static int nlm4_xdr_dec_testres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nlm_res *result)
+				void *obj)
 {
+	struct nlm_res *result = obj;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -545,8 +552,9 @@ out:
  */
 static int nlm4_xdr_dec_res(struct rpc_rqst *req,
 			    struct xdr_stream *xdr,
-			    struct nlm_res *result)
+			    void *obj)
 {
+	struct nlm_res *result = obj;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -566,8 +574,8 @@ out:
 #define PROC(proc, argtype, restype)					\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nlm4_xdr_enc_##argtype,		\
-	.p_decode    = (kxdrdproc_t)nlm4_xdr_dec_##restype,		\
+	.p_encode    = nlm4_xdr_enc_##argtype,				\
+	.p_decode    = nlm4_xdr_dec_##restype,		\
 	.p_arglen    = NLM4_##argtype##_sz,				\
 	.p_replen    = NLM4_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 3e9f787..6ca581b 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -374,8 +374,9 @@ static void encode_nlm_lock(struct xdr_stream *xdr,
  */
 static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -395,8 +396,9 @@ static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -417,8 +419,9 @@ static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -435,8 +438,9 @@ static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nlm_args *args)
+				   void *obj)
 {
+	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -451,8 +455,9 @@ static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_res(struct rpc_rqst *req,
 			    struct xdr_stream *xdr,
-			    const struct nlm_res *result)
+			    void *obj)
 {
+	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
 }
@@ -479,8 +484,9 @@ static void encode_nlm_testrply(struct xdr_stream *xdr,
 
 static void nlm_xdr_enc_testres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				const struct nlm_res *result)
+				void *obj)
 {
+	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
 	encode_nlm_testrply(xdr, result);
@@ -523,8 +529,9 @@ out:
 
 static int nlm_xdr_dec_testres(struct rpc_rqst *req,
 			       struct xdr_stream *xdr,
-			       struct nlm_res *result)
+			       void *obj)
 {
+	struct nlm_res *result = obj;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -543,8 +550,9 @@ out:
  */
 static int nlm_xdr_dec_res(struct rpc_rqst *req,
 			   struct xdr_stream *xdr,
-			   struct nlm_res *result)
+			   void *obj)
 {
+	struct nlm_res *result = obj;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -564,8 +572,8 @@ out:
 #define PROC(proc, argtype, restype)	\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nlm_xdr_enc_##argtype,		\
-	.p_decode    = (kxdrdproc_t)nlm_xdr_dec_##restype,		\
+	.p_encode    = nlm_xdr_enc_##argtype,		\
+	.p_decode    = nlm_xdr_dec_##restype,		\
 	.p_arglen    = NLM_##argtype##_sz,				\
 	.p_replen    = NLM_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 47a32b6..395c39f 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -527,22 +527,25 @@ static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 }
 
 static void nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    const struct nsm_args *argp)
+			    void *obj)
 {
+	const struct nsm_args *argp = obj;
 	encode_mon_id(xdr, argp);
 	encode_priv(xdr, argp);
 }
 
 static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      const struct nsm_args *argp)
+			      void *obj)
 {
+	const struct nsm_args *argp = obj;
 	encode_mon_id(xdr, argp);
 }
 
 static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nsm_res *resp)
+				void *obj)
 {
+	struct nsm_res *resp = obj;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
@@ -558,8 +561,9 @@ static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
 
 static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 			    struct xdr_stream *xdr,
-			    struct nsm_res *resp)
+			    void *obj)
 {
+	struct nsm_res *resp = obj;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -583,8 +587,8 @@ static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
-		.p_encode	= (kxdreproc_t)nsm_xdr_enc_mon,
-		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat_res,
+		.p_encode	= nsm_xdr_enc_mon,
+		.p_decode	= nsm_xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
 		.p_statidx	= NSMPROC_MON,
@@ -592,8 +596,8 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
-		.p_encode	= (kxdreproc_t)nsm_xdr_enc_unmon,
-		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat,
+		.p_encode	= nsm_xdr_enc_unmon,
+		.p_decode	= nsm_xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= NSMPROC_UNMON,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 99a4528..c02962a 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -306,8 +306,9 @@ static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 }
 
 static void mnt_xdr_enc_dirpath(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const char *dirpath)
+				void *obj)
 {
+	const char *dirpath = obj;
 	encode_mntdirpath(xdr, dirpath);
 }
 
@@ -359,8 +360,9 @@ static int decode_fhandle(struct xdr_stream *xdr, struct mountres *res)
 
 static int mnt_xdr_dec_mountres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct mountres *res)
+				void *obj)
 {
+	struct mountres *res = obj;
 	int status;
 
 	status = decode_status(xdr, res);
@@ -451,8 +453,9 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 
 static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct mountres *res)
+				 void *obj)
 {
+	struct mountres *res = obj;
 	int status;
 
 	status = decode_fhs_status(xdr, res);
@@ -469,8 +472,8 @@ static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres,
+		.p_encode	= mnt_xdr_enc_dirpath,
+		.p_decode	= mnt_xdr_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres_sz,
 		.p_statidx	= MOUNTPROC_MNT,
@@ -478,7 +481,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 	},
 	[MOUNTPROC_UMNT] = {
 		.p_proc		= MOUNTPROC_UMNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC_UMNT,
 		.p_name		= "UMOUNT",
@@ -488,8 +491,8 @@ static struct rpc_procinfo mnt_procedures[] = {
 static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres3,
+		.p_encode	= mnt_xdr_enc_dirpath,
+		.p_decode	= mnt_xdr_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres3_sz,
 		.p_statidx	= MOUNTPROC3_MNT,
@@ -497,7 +500,7 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	},
 	[MOUNTPROC3_UMNT] = {
 		.p_proc		= MOUNTPROC3_UMNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC3_UMNT,
 		.p_name		= "UMOUNT",
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index b4e03ed..91a988a 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -568,8 +568,9 @@ out_default:
 
 static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nfs_fh *fh)
+				 void *obj)
 {
+	const struct nfs_fh *fh = obj;
 	encode_fhandle(xdr, fh);
 }
 
@@ -583,23 +584,26 @@ static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_sattrargs *args)
+				   void *obj)
 {
+	const struct nfs_sattrargs *args = obj;
 	encode_fhandle(xdr, args->fh);
 	encode_sattr(xdr, args->sattr);
 }
 
 static void nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_diropargs *args)
+				   void *obj)
 {
+	const struct nfs_diropargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name, args->len);
 }
 
 static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs_readlinkargs *args)
+				      void *obj)
 {
+	const struct nfs_readlinkargs *args = obj;
 	encode_fhandle(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS_readlinkres_sz);
@@ -632,8 +636,9 @@ static void encode_readargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nfs_pgio_args *args)
+				  void *obj)
 {
+	const struct nfs_pgio_args *args = obj;
 	encode_readargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS_readres_sz);
@@ -672,8 +677,9 @@ static void encode_writeargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_pgio_args *args)
+				   void *obj)
 {
+	const struct nfs_pgio_args *args = obj;
 	encode_writeargs(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
 }
@@ -688,16 +694,18 @@ static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_createargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_createargs *args)
+				    void *obj)
 {
+	const struct nfs_createargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name, args->len);
 	encode_sattr(xdr, args->sattr);
 }
 
 static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_removeargs *args)
+				    void *obj)
 {
+	const struct nfs_removeargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name.name, args->name.len);
 }
 
@@ -711,8 +719,9 @@ static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_renameargs *args)
+				    void *obj)
 {
+	const struct nfs_renameargs *args = obj;
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
 
@@ -730,8 +739,9 @@ static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nfs_linkargs *args)
+				  void *obj)
 {
+	const struct nfs_linkargs *args = obj;
 	encode_fhandle(xdr, args->fromfh);
 	encode_diropargs(xdr, args->tofh, args->toname, args->tolen);
 }
@@ -747,8 +757,9 @@ static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_symlinkargs *args)
+				     void *obj)
 {
+	const struct nfs_symlinkargs *args = obj;
 	encode_diropargs(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_path(xdr, args->pages, args->pathlen);
 	encode_sattr(xdr, args->sattr);
@@ -777,8 +788,9 @@ static void encode_readdirargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_readdirargs *args)
+				     void *obj)
 {
+	const struct nfs_readdirargs *args = obj;
 	encode_readdirargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 					args->count, NFS_readdirres_sz);
@@ -809,14 +821,16 @@ out_default:
 }
 
 static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_fattr *result)
+				 void *obj)
 {
+	struct nfs_fattr *result = obj;
 	return decode_attrstat(xdr, result, NULL);
 }
 
 static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_diropok *result)
+				 void *obj)
 {
+	struct nfs_diropok *result = obj;
 	return decode_diropres(xdr, result);
 }
 
@@ -860,8 +874,9 @@ out_default:
  *	};
  */
 static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_pgio_res *result)
+				void *obj)
 {
+	struct nfs_pgio_res *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -882,9 +897,10 @@ out_default:
 }
 
 static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_pgio_res *result)
+				 void *obj)
 {
 	/* All NFSv2 writes are "file sync" writes */
+	struct nfs_pgio_res *result = obj;
 	result->verf->committed = NFS_FILE_SYNC;
 	return decode_attrstat(xdr, result->fattr, &result->op_status);
 }
@@ -1034,8 +1050,9 @@ out_overflow:
 }
 
 static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs2_fsstat *result)
+				  void *obj)
 {
+	struct nfs2_fsstat *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1118,8 +1135,8 @@ static int nfs_stat_to_errno(enum nfs_stat status)
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-	.p_encode   =  (kxdreproc_t)nfs2_xdr_enc_##argtype,		\
-	.p_decode   =  (kxdrdproc_t)nfs2_xdr_dec_##restype,		\
+	.p_encode   =  nfs2_xdr_enc_##argtype,		\
+	.p_decode   =  nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 53852a4..d8f7744 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -846,8 +846,9 @@ static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
  */
 static void nfs3_xdr_enc_getattr3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs_fh *fh)
+				      void *obj)
 {
+	const struct nfs_fh *fh = obj;
 	encode_nfs_fh3(xdr, fh);
 }
 
@@ -884,8 +885,9 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_sattrargs *args)
+				      void *obj)
 {
+	const struct nfs3_sattrargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
 	encode_sattr3(xdr, args->sattr);
 	encode_sattrguard3(xdr, args);
@@ -900,8 +902,9 @@ static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_lookup3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_diropargs *args)
+				     void *obj)
 {
+	const struct nfs3_diropargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 }
 
@@ -922,8 +925,9 @@ static void encode_access3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_accessargs *args)
+				     void *obj)
 {
+	const struct nfs3_accessargs *args = obj;
 	encode_access3args(xdr, args);
 }
 
@@ -936,8 +940,9 @@ static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
 				       struct xdr_stream *xdr,
-				       const struct nfs3_readlinkargs *args)
+				       void *obj)
 {
+	const struct nfs3_readlinkargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS3_readlinkres_sz);
@@ -966,8 +971,9 @@ static void encode_read3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_pgio_args *args)
+				   void *obj)
 {
+	const struct nfs_pgio_args *args = obj;
 	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS3_readres_sz);
@@ -1008,8 +1014,9 @@ static void encode_write3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_pgio_args *args)
+				    void *obj)
 {
+	const struct nfs_pgio_args *args = obj;
 	encode_write3args(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
 }
@@ -1055,8 +1062,9 @@ static void encode_createhow3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_createargs *args)
+				     void *obj)
 {
+	const struct nfs3_createargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_createhow3(xdr, args);
 }
@@ -1071,8 +1079,9 @@ static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs3_mkdirargs *args)
+				    void *obj)
 {
+	const struct nfs3_mkdirargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_sattr3(xdr, args->sattr);
 }
@@ -1099,8 +1108,9 @@ static void encode_symlinkdata3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_symlinkargs *args)
+				      void *obj)
 {
+	const struct nfs3_symlinkargs *args = obj;
 	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_symlinkdata3(xdr, args);
 }
@@ -1159,8 +1169,9 @@ static void encode_mknoddata3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs3_mknodargs *args)
+				    void *obj)
 {
+	const struct nfs3_mknodargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_mknoddata3(xdr, args);
 }
@@ -1174,8 +1185,9 @@ static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_removeargs *args)
+				     void *obj)
 {
+	const struct nfs_removeargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name.name, args->name.len);
 }
 
@@ -1189,8 +1201,9 @@ static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_renameargs *args)
+				     void *obj)
 {
+	const struct nfs_renameargs *args = obj;
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
 
@@ -1208,8 +1221,9 @@ static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_link3args(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs3_linkargs *args)
+				   void *obj)
 {
+	const struct nfs3_linkargs *args = obj;
 	encode_nfs_fh3(xdr, args->fromfh);
 	encode_diropargs3(xdr, args->tofh, args->toname, args->tolen);
 }
@@ -1239,8 +1253,9 @@ static void encode_readdir3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_readdirargs *args)
+				      void *obj)
 {
+	const struct nfs3_readdirargs *args = obj;
 	encode_readdir3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
@@ -1279,8 +1294,9 @@ static void encode_readdirplus3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
 					  struct xdr_stream *xdr,
-					  const struct nfs3_readdirargs *args)
+					  void *obj)
 {
+	const struct nfs3_readdirargs *args = obj;
 	encode_readdirplus3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
@@ -1309,8 +1325,9 @@ static void encode_commit3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_commitargs *args)
+				     void *obj)
 {
+	const struct nfs_commitargs *args = obj;
 	encode_commit3args(xdr, args);
 }
 
@@ -1318,8 +1335,9 @@ static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
 
 static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_getaclargs *args)
+				     void *obj)
 {
+	const struct nfs3_getaclargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
 	encode_uint32(xdr, args->mask);
 	if (args->mask & (NFS_ACL | NFS_DFACL))
@@ -1330,8 +1348,9 @@ static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 
 static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_setaclargs *args)
+				     void *obj)
 {
+	const struct nfs3_setaclargs *args = obj;
 	unsigned int base;
 	int error;
 
@@ -1381,8 +1400,9 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs_fattr *result)
+				    void *obj)
 {
+	struct nfs_fattr *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1418,8 +1438,9 @@ out_default:
  */
 static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs_fattr *result)
+				    void *obj)
 {
+	struct nfs_fattr *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1459,8 +1480,9 @@ out_status:
  */
 static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_diropres *result)
+				   void *obj)
 {
+	struct nfs3_diropres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1506,8 +1528,9 @@ out_default:
  */
 static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_accessres *result)
+				   void *obj)
 {
+	struct nfs3_accessres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1547,8 +1570,9 @@ out_default:
  */
 static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_fattr *result)
+				     void *obj)
 {
+	struct nfs_fattr *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1625,8 +1649,9 @@ out_overflow:
 }
 
 static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_pgio_res *result)
+				 void *obj)
 {
+	struct nfs_pgio_res *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1698,8 +1723,9 @@ out_eio:
 }
 
 static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs_pgio_res *result)
+				  void *obj)
 {
+	struct nfs_pgio_res *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1763,8 +1789,9 @@ out:
 
 static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_diropres *result)
+				   void *obj)
 {
+	struct nfs3_diropres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1803,8 +1830,9 @@ out_default:
  */
 static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_removeres *result)
+				   void *obj)
 {
+	struct nfs_removeres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1844,8 +1872,9 @@ out_status:
  */
 static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_renameres *result)
+				   void *obj)
 {
+	struct nfs_renameres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -1887,8 +1916,9 @@ out_status:
  *	};
  */
 static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs3_linkres *result)
+				 void *obj)
 {
+	struct nfs3_linkres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2071,8 +2101,9 @@ out:
 
 static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs3_readdirres *result)
+				    void *obj)
 {
+	struct nfs3_readdirres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2139,8 +2170,9 @@ out_overflow:
 
 static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fsstat *result)
+				   void *obj)
 {
+	struct nfs_fsstat *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2215,8 +2247,9 @@ out_overflow:
 
 static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fsinfo *result)
+				   void *obj)
 {
+	struct nfs_fsinfo *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2278,8 +2311,9 @@ out_overflow:
 
 static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_pathconf *result)
+				     void *obj)
 {
+	struct nfs_pathconf *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2319,8 +2353,9 @@ out_status:
  */
 static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_commitres *result)
+				   void *obj)
 {
+	struct nfs_commitres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2388,8 +2423,9 @@ out:
 
 static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_getaclres *result)
+				   void *obj)
 {
+	struct nfs3_getaclres *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2407,8 +2443,9 @@ out_default:
 
 static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fattr *result)
+				   void *obj)
 {
+	struct nfs_fattr *result = obj;
 	enum nfs_stat status;
 	int error;
 
@@ -2494,8 +2531,8 @@ static int nfs3_stat_to_errno(enum nfs_stat status)
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nfs3_xdr_enc_##argtype##3args,	\
-	.p_decode    = (kxdrdproc_t)nfs3_xdr_dec_##restype##3res,	\
+	.p_encode    = nfs3_xdr_enc_##argtype##3args,	\
+	.p_decode    = nfs3_xdr_dec_##restype##3res,	\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##res_sz,				\
 	.p_timer     = timer,						\
@@ -2537,8 +2574,8 @@ const struct rpc_version nfs_version3 = {
 static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
-		.p_encode = (kxdreproc_t)nfs3_xdr_enc_getacl3args,
-		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_getacl3res,
+		.p_encode = nfs3_xdr_enc_getacl3args,
+		.p_decode = nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
@@ -2546,8 +2583,8 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
-		.p_encode = (kxdreproc_t)nfs3_xdr_enc_setacl3args,
-		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_setacl3res,
+		.p_encode = nfs3_xdr_enc_setacl3args,
+		.p_decode = nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5c399ec..8775318 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2060,8 +2060,9 @@ static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
  * Encode an ACCESS request
  */
 static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_accessargs *args)
+				void *obj)
 {
+	const struct nfs4_accessargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2078,8 +2079,9 @@ static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode LOOKUP request
  */
 static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_lookup_arg *args)
+				void *obj)
 {
+	const struct nfs4_lookup_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2098,8 +2100,9 @@ static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs4_lookup_root_arg *args)
+				     void *obj)
 {
+	const struct nfs4_lookup_root_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2116,8 +2119,9 @@ static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
  * Encode REMOVE request
  */
 static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs_removeargs *args)
+				void *obj)
 {
+	const struct nfs_removeargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2133,8 +2137,9 @@ static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode RENAME request
  */
 static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs_renameargs *args)
+				void *obj)
 {
+	const struct nfs_renameargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2152,8 +2157,9 @@ static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode LINK request
  */
 static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct nfs4_link_arg *args)
+			     void *obj)
 {
+	const struct nfs4_link_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2173,8 +2179,9 @@ static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode CREATE request
  */
 static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_create_arg *args)
+				void *obj)
 {
+	const struct nfs4_create_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2192,17 +2199,18 @@ static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode SYMLINK request
  */
 static void nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_create_arg *args)
+				 void *obj)
 {
-	nfs4_xdr_enc_create(req, xdr, args);
+	nfs4_xdr_enc_create(req, xdr, obj);
 }
 
 /*
  * Encode GETATTR request
  */
 static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_getattr_arg *args)
+				 void *obj)
 {
+	const struct nfs4_getattr_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2218,8 +2226,9 @@ static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a CLOSE request
  */
 static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_closeargs *args)
+			       void *obj)
 {
+	struct nfs_closeargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2236,8 +2245,9 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode an OPEN request
  */
 static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_openargs *args)
+			      void *obj)
 {
+	struct nfs_openargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2258,8 +2268,9 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs_open_confirmargs *args)
+				      void *obj)
 {
+	struct nfs_open_confirmargs *args = obj;
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
@@ -2275,8 +2286,9 @@ static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_openargs *args)
+				     void *obj)
 {
+	struct nfs_openargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2296,8 +2308,9 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs_closeargs *args)
+					void *obj)
 {
+	struct nfs_closeargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2314,8 +2327,9 @@ static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
  * Encode a LOCK request
  */
 static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_lock_args *args)
+			      void *obj)
 {
+	struct nfs_lock_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2331,8 +2345,9 @@ static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a LOCKT request
  */
 static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_lockt_args *args)
+			       void *obj)
 {
+	struct nfs_lockt_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2348,8 +2363,9 @@ static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a LOCKU request
  */
 static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_locku_args *args)
+			       void *obj)
 {
+	struct nfs_locku_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2363,8 +2379,9 @@ static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
 					   struct xdr_stream *xdr,
-					struct nfs_release_lockowner_args *args)
+					void *obj)
 {
+	struct nfs_release_lockowner_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = 0,
 	};
@@ -2378,8 +2395,9 @@ static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
  * Encode a READLINK request
  */
 static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  const struct nfs4_readlink *args)
+				  void *obj)
 {
+	const struct nfs4_readlink *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2398,8 +2416,9 @@ static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a READDIR request
  */
 static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_readdir_arg *args)
+				 void *obj)
 {
+	const struct nfs4_readdir_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2421,8 +2440,9 @@ static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a READ request
  */
 static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_pgio_args *args)
+			      void *obj)
 {
+	struct nfs_pgio_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2442,8 +2462,9 @@ static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode an SETATTR request
  */
 static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_setattrargs *args)
+				 void *obj)
 {
+	struct nfs_setattrargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2460,8 +2481,9 @@ static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a GETACL request
  */
 static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_getaclargs *args)
+				void *obj)
 {
+	struct nfs_getaclargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2483,8 +2505,9 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a WRITE request
  */
 static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_pgio_args *args)
+			       void *obj)
 {
+	struct nfs_pgio_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2503,8 +2526,9 @@ static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
  *  a COMMIT request
  */
 static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_commitargs *args)
+				void *obj)
 {
+	struct nfs_commitargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2520,8 +2544,9 @@ static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
  * FSINFO request
  */
 static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs4_fsinfo_arg *args)
+				void *obj)
 {
+	struct nfs4_fsinfo_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2537,8 +2562,9 @@ static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
  * a PATHCONF request
  */
 static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  const struct nfs4_pathconf_arg *args)
+				  void *obj)
 {
+	const struct nfs4_pathconf_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2555,8 +2581,9 @@ static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
  * a STATFS request
  */
 static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_statfs_arg *args)
+				void *obj)
 {
+	const struct nfs4_statfs_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2574,8 +2601,9 @@ static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_server_caps_arg *args)
+				     void *obj)
 {
+	struct nfs4_server_caps_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2595,8 +2623,9 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
  * a RENEW request
  */
 static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_client *clp)
+			       void *obj)
 {
+	struct nfs_client *clp = obj;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2611,8 +2640,9 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_setclientid *sc)
+				     void *obj)
 {
+	struct nfs4_setclientid *sc = obj;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2627,8 +2657,9 @@ static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 					     struct xdr_stream *xdr,
-					     struct nfs4_setclientid_res *arg)
+					     void *obj)
 {
+	struct nfs4_setclientid_res *arg = obj;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2643,8 +2674,9 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs4_delegreturnargs *args)
+				     void *obj)
 {
+	const struct nfs4_delegreturnargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2662,8 +2694,9 @@ static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_fs_locations_arg *args)
+				      void *obj)
 {
+	struct nfs4_fs_locations_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2695,8 +2728,9 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs4_secinfo_arg *args)
+				void *obj)
 {
+	struct nfs4_secinfo_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2713,8 +2747,9 @@ static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_fsid_present_arg *args)
+				      void *obj)
 {
+	struct nfs4_fsid_present_arg *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2734,8 +2769,9 @@ static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs41_bind_conn_to_session_args *args)
+				void *obj)
 {
+	struct nfs41_bind_conn_to_session_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2750,8 +2786,9 @@ static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs41_exchange_id_args *args)
+				     void *obj)
 {
+	struct nfs41_exchange_id_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2766,8 +2803,9 @@ static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs41_create_session_args *args)
+					void *obj)
 {
+	struct nfs41_create_session_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2782,8 +2820,9 @@ static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
 					 struct xdr_stream *xdr,
-					 struct nfs4_session *session)
+					 void *obj)
 {
+	struct nfs4_session *session = obj;
 	struct compound_hdr hdr = {
 		.minorversion = session->clp->cl_mvops->minor_version,
 	};
@@ -2798,8 +2837,9 @@ static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
 					 struct xdr_stream *xdr,
-					 struct nfs_client *clp)
+					 void *obj)
 {
+	struct nfs_client *clp = obj;
 	struct compound_hdr hdr = {
 		.minorversion = clp->cl_mvops->minor_version,
 	};
@@ -2813,8 +2853,9 @@ static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
  * a SEQUENCE request
  */
 static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs4_sequence_args *args)
+				  void *obj)
 {
+	struct nfs4_sequence_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(args),
 	};
@@ -2829,8 +2870,9 @@ static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs4_get_lease_time_args *args)
+					void *obj)
 {
+	struct nfs4_get_lease_time_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
@@ -2848,8 +2890,9 @@ static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
 					  struct xdr_stream *xdr,
-				struct nfs41_reclaim_complete_args *args)
+					  void *obj)
 {
+	struct nfs41_reclaim_complete_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args)
 	};
@@ -2865,8 +2908,9 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
 				       struct xdr_stream *xdr,
-				       struct nfs4_getdeviceinfo_args *args)
+				       void *obj)
 {
+	struct nfs4_getdeviceinfo_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2889,8 +2933,9 @@ static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs4_layoutget_args *args)
+				   void *obj)
 {
+	struct nfs4_layoutget_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2911,8 +2956,9 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_layoutcommit_args *args)
+				      void *obj)
 {
+	struct nfs4_layoutcommit_args *args = obj;
 	struct nfs4_layoutcommit_data *data =
 		container_of(args, struct nfs4_layoutcommit_data, args);
 	struct compound_hdr hdr = {
@@ -2932,8 +2978,9 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_layoutreturn_args *args)
+				      void *obj)
 {
+	struct nfs4_layoutreturn_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2950,8 +2997,9 @@ static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
  */
 static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs41_secinfo_no_name_args *args)
+					void *obj)
 {
+	struct nfs41_secinfo_no_name_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2969,8 +3017,9 @@ static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs41_test_stateid_args *args)
+				      void *obj)
 {
+	struct nfs41_test_stateid_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2986,8 +3035,9 @@ static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs41_free_stateid_args *args)
+				     void *obj)
 {
+	struct nfs41_free_stateid_args *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -5987,8 +6037,9 @@ static int decode_free_stateid(struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs_closeres *res)
+				       void *obj)
 {
+	struct nfs_closeres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6013,8 +6064,9 @@ out:
  * Decode ACCESS response
  */
 static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_accessres *res)
+			       void *obj)
 {
+	struct nfs4_accessres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6039,8 +6091,9 @@ out:
  * Decode LOOKUP response
  */
 static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_lookup_res *res)
+			       void *obj)
 {
+	struct nfs4_lookup_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6069,8 +6122,9 @@ out:
  */
 static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs4_lookup_res *res)
+				    void *obj)
 {
+	struct nfs4_lookup_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6095,8 +6149,9 @@ out:
  * Decode REMOVE response
  */
 static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_removeres *res)
+			       void *obj)
 {
+	struct nfs_removeres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6118,8 +6173,9 @@ out:
  * Decode RENAME response
  */
 static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_renameres *res)
+			       void *obj)
 {
+	struct nfs_renameres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6147,8 +6203,9 @@ out:
  * Decode LINK response
  */
 static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs4_link_res *res)
+			     void *obj)
 {
+	struct nfs4_link_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6186,8 +6243,9 @@ out:
  * Decode CREATE response
  */
 static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_create_res *res)
+			       void *obj)
 {
+	struct nfs4_create_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6215,8 +6273,9 @@ out:
  * Decode SYMLINK response
  */
 static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_create_res *res)
+				void *obj)
 {
+	struct nfs4_create_res *res = obj;
 	return nfs4_xdr_dec_create(rqstp, xdr, res);
 }
 
@@ -6224,8 +6283,9 @@ static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode GETATTR response
  */
 static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_getattr_res *res)
+				void *obj)
 {
+	struct nfs4_getattr_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6247,8 +6307,9 @@ out:
  * Encode an SETACL request
  */
 static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_setaclargs *args)
+				void *obj)
 {
+	struct nfs_setaclargs *args = obj;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -6265,8 +6326,9 @@ static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int
 nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-		    struct nfs_setaclres *res)
+		    void *obj)
 {
+	struct nfs_setaclres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6289,8 +6351,9 @@ out:
  */
 static int
 nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-		    struct nfs_getaclres *res)
+		    void *obj)
 {
+	struct nfs_getaclres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6317,8 +6380,9 @@ out:
  * Decode CLOSE response
  */
 static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_closeres *res)
+			      void *obj)
 {
+	struct nfs_closeres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6349,8 +6413,9 @@ out:
  * Decode OPEN response
  */
 static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_openres *res)
+			     void *obj)
 {
+	struct nfs_openres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6381,8 +6446,9 @@ out:
  */
 static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs_open_confirmres *res)
+				     void *obj)
 {
+	struct nfs_open_confirmres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6402,8 +6468,9 @@ out:
  */
 static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs_openres *res)
+				    void *obj)
 {
+	struct nfs_openres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6431,8 +6498,9 @@ out:
  */
 static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nfs_setattrres *res)
+				void *obj)
 {
+	struct nfs_setattrres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6457,8 +6525,9 @@ out:
  * Decode LOCK response
  */
 static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_lock_res *res)
+			     void *obj)
 {
+	struct nfs_lock_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6480,8 +6549,9 @@ out:
  * Decode LOCKT response
  */
 static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_lockt_res *res)
+			      void *obj)
 {
+	struct nfs_lockt_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6503,8 +6573,9 @@ out:
  * Decode LOCKU response
  */
 static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_locku_res *res)
+			      void *obj)
 {
+	struct nfs_locku_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6539,8 +6610,9 @@ static int nfs4_xdr_dec_release_lockowner(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp,
 				 struct xdr_stream *xdr,
-				 struct nfs4_readlink_res *res)
+				 void *obj)
 {
+	struct nfs4_readlink_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6562,8 +6634,9 @@ out:
  * Decode READDIR response
  */
 static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_readdir_res *res)
+				void *obj)
 {
+	struct nfs4_readdir_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6585,8 +6658,9 @@ out:
  * Decode Read response
  */
 static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_pgio_res *res)
+			     void *obj)
 {
+	struct nfs_pgio_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6611,8 +6685,9 @@ out:
  * Decode WRITE response
  */
 static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_pgio_res *res)
+			      void *obj)
 {
+	struct nfs_pgio_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6641,8 +6716,9 @@ out:
  * Decode COMMIT response
  */
 static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_commitres *res)
+			       void *obj)
 {
+	struct nfs_commitres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6665,8 +6741,9 @@ out:
  * Decode FSINFO response
  */
 static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs4_fsinfo_res *res)
+			       void *obj)
 {
+	struct nfs4_fsinfo_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6684,8 +6761,9 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Decode PATHCONF response
  */
 static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs4_pathconf_res *res)
+				 void *obj)
 {
+	struct nfs4_pathconf_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6703,8 +6781,9 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Decode STATFS response
  */
 static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs4_statfs_res *res)
+			       void *obj)
 {
+	struct nfs4_statfs_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6723,8 +6802,9 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs4_server_caps_res *res)
+				    void *obj)
 {
+	struct nfs4_server_caps_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6762,8 +6842,9 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs4_setclientid_res *res)
+				    void *obj)
 {
+	struct nfs4_setclientid_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6793,8 +6874,9 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
  */
 static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs4_delegreturnres *res)
+				    void *obj)
 {
+	struct nfs4_delegreturnres *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6820,8 +6902,9 @@ out:
  */
 static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_fs_locations_res *res)
+				     void *obj)
 {
+	struct nfs4_fs_locations_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6863,8 +6946,9 @@ out:
  */
 static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nfs4_secinfo_res *res)
+				void *obj)
 {
+	struct nfs4_secinfo_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6887,8 +6971,9 @@ out:
  */
 static int nfs4_xdr_dec_fsid_present(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_fsid_present_res *res)
+				     void *obj)
 {
+	struct nfs4_fsid_present_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6948,8 +7033,9 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs41_create_session_res *res)
+				       void *obj)
 {
+	struct nfs41_create_session_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6996,8 +7082,9 @@ static int nfs4_xdr_dec_destroy_clientid(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
 				 struct xdr_stream *xdr,
-				 struct nfs4_sequence_res *res)
+				 void *obj)
 {
+	struct nfs4_sequence_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7012,8 +7099,9 @@ static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs4_get_lease_time_res *res)
+				       void *obj)
 {
+	struct nfs4_get_lease_time_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7032,8 +7120,9 @@ static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
 					 struct xdr_stream *xdr,
-					 struct nfs41_reclaim_complete_res *res)
+					 void *obj)
 {
+	struct nfs41_reclaim_complete_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7050,8 +7139,9 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
 				      struct xdr_stream *xdr,
-				      struct nfs4_getdeviceinfo_res *res)
+				      void *obj)
 {
+	struct nfs4_getdeviceinfo_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7071,8 +7161,9 @@ out:
  */
 static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfs4_layoutget_res *res)
+				  void *obj)
 {
+	struct nfs4_layoutget_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7095,8 +7186,9 @@ out:
  */
 static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_layoutreturn_res *res)
+				     void *obj)
 {
+	struct nfs4_layoutreturn_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7119,8 +7211,9 @@ out:
  */
 static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_layoutcommit_res *res)
+				     void *obj)
 {
+	struct nfs4_layoutcommit_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7146,8 +7239,9 @@ out:
  */
 static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
 					struct xdr_stream *xdr,
-					struct nfs4_secinfo_res *res)
+					void *obj)
 {
+	struct nfs4_secinfo_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7170,8 +7264,9 @@ out:
  */
 static int nfs4_xdr_dec_test_stateid(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs41_test_stateid_res *res)
+				     void *obj)
 {
+	struct nfs41_test_stateid_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7191,8 +7286,9 @@ out:
  */
 static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs41_free_stateid_res *res)
+				     void *obj)
 {
+	struct nfs41_free_stateid_res *res = obj;
 	struct compound_hdr hdr;
 	int status;
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5827785..a7167b8 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -486,8 +486,9 @@ static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
  * 20.2. Operation 4: CB_RECALL - Recall a Delegation
  */
 static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
-				   const struct nfsd4_callback *cb)
+				   void *obj)
 {
+	const struct nfsd4_callback *cb = obj;
 	const struct nfs4_delegation *dp = cb_to_delegation(cb);
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = cb->cb_clp->cl_cb_ident,
@@ -521,8 +522,9 @@ static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfsd4_callback *cb)
+				  void *obj)
 {
+	struct nfsd4_callback *cb = obj;
 	struct nfs4_cb_compound_hdr hdr;
 	enum nfsstat4 nfserr;
 	int status;
@@ -601,8 +603,9 @@ static void encode_cb_layout4args(struct xdr_stream *xdr,
 
 static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfsd4_callback *cb)
+				   void *obj)
 {
+	const struct nfsd4_callback *cb = obj;
 	const struct nfs4_layout_stateid *ls =
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
 	struct nfs4_cb_compound_hdr hdr = {
@@ -618,8 +621,9 @@ static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 
 static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfsd4_callback *cb)
+				  void *obj)
 {
+	struct nfsd4_callback *cb = obj;
 	struct nfs4_cb_compound_hdr hdr;
 	enum nfsstat4 nfserr;
 	int status;
@@ -648,8 +652,8 @@ out:
 #define PROC(proc, call, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {						\
 	.p_proc    = NFSPROC4_CB_##call,				\
-	.p_encode  = (kxdreproc_t)nfs4_xdr_enc_##argtype,		\
-	.p_decode  = (kxdrdproc_t)nfs4_xdr_dec_##restype,		\
+	.p_encode  = nfs4_xdr_enc_##argtype,		\
+	.p_decode  = nfs4_xdr_dec_##restype,		\
 	.p_arglen  = NFS4_enc_##argtype##_sz,				\
 	.p_replen  = NFS4_dec_##restype##_sz,				\
 	.p_statidx = NFSPROC4_CB_##call,				\
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 70c6b92..7177815 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -210,8 +210,9 @@ struct xdr_stream {
 /*
  * These are the xdr_stream style generic XDR encode and decode functions.
  */
-typedef void	(*kxdreproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
-typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
+struct rpc_rqst;
+typedef void	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj);
+typedef int	(*kxdrdproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 59eeed4..d06117a 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -55,8 +55,8 @@ enum {
 #define PROC(proc, name)				\
 [GSSX_##proc] = {					\
 	.p_proc   = GSSX_##proc,			\
-	.p_encode = (kxdreproc_t)gssx_enc_##name,	\
-	.p_decode = (kxdrdproc_t)gssx_dec_##name,	\
+	.p_encode = gssx_enc_##name,	\
+	.p_decode = gssx_dec_##name,	\
 	.p_arglen = GSSX_ARG_##name##_sz,		\
 	.p_replen = GSSX_RES_##name##_sz, 		\
 	.p_statidx = GSSX_##proc,			\
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 1ec19f6..6b9dc37 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -733,8 +733,9 @@ static int gssx_enc_cb(struct xdr_stream *xdr, struct gssx_cb *cb)
 
 void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct gssx_arg_accept_sec_context *arg)
+				 void *obj)
 {
+	struct gssx_arg_accept_sec_context *arg = obj;
 	int err;
 
 	err = gssx_enc_call_ctx(xdr, &arg->call_ctx);
@@ -789,8 +790,9 @@ done:
 
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct gssx_res_accept_sec_context *res)
+				void *obj)
 {
+	struct gssx_res_accept_sec_context *res = obj;
 	u32 value_follows;
 	int err;
 
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index 9d88c62..eb98597 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -179,10 +179,10 @@ struct gssx_res_accept_sec_context {
 #define gssx_dec_init_sec_context NULL
 void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct gssx_arg_accept_sec_context *args);
+				 void *);
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct gssx_res_accept_sec_context *res);
+				void *);
 #define gssx_enc_release_handle NULL
 #define gssx_dec_release_handle NULL
 #define gssx_enc_get_mic NULL
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 612aa73..8bee221 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2392,11 +2392,11 @@ out_overflow:
 	goto out_garbage;
 }
 
-static void rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
+static void rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj)
 {
 }
 
-static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
+static int rpcproc_decode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj)
 {
 	return 0;
 }
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index cf5770d..7c71283 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -845,8 +845,9 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
  */
 
 static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct rpcbind_args *rpcb)
+			     void *obj)
 {
+	const struct rpcbind_args *rpcb = obj;
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding PMAP_%s call (%u, %u, %d, %u)\n",
@@ -862,8 +863,9 @@ static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    struct rpcbind_args *rpcb)
+			    void *obj)
 {
+	struct rpcbind_args *rpcb = obj;
 	unsigned long port;
 	__be32 *p;
 
@@ -884,8 +886,9 @@ static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_set(struct rpc_rqst *req, struct xdr_stream *xdr,
-			unsigned int *boolp)
+			void *obj)
 {
+	unsigned int *boolp = obj;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -919,8 +922,9 @@ static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 }
 
 static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct rpcbind_args *rpcb)
+			     void *obj)
 {
+	const struct rpcbind_args *rpcb = obj;
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding RPCB_%s call (%u, %u, '%s', '%s')\n",
@@ -939,8 +943,9 @@ static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    struct rpcbind_args *rpcb)
+			    void *obj)
 {
+	struct rpcbind_args *rpcb = obj;
 	struct sockaddr_storage address;
 	struct sockaddr *sap = (struct sockaddr *)&address;
 	__be32 *p;
@@ -994,8 +999,8 @@ out_fail:
 static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_mapping,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1004,8 +1009,8 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_mapping,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1014,8 +1019,8 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_GETPORT] = {
 		.p_proc		= RPCBPROC_GETPORT,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getport,
+		.p_encode	= rpcb_enc_mapping,
+		.p_decode	= rpcb_dec_getport,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_getportres_sz,
 		.p_statidx	= RPCBPROC_GETPORT,
@@ -1027,8 +1032,8 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1037,8 +1042,8 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1047,8 +1052,8 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,
@@ -1060,8 +1065,8 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1070,8 +1075,8 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1080,8 +1085,8 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
+		.p_decode	= rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,
-- 
2.1.0

