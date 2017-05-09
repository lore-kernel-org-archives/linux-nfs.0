Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:46901 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753108AbdEIJVP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:15 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 22/32] sunrpc: properly type pc_decode callbacks
Date: Tue,  9 May 2017 11:20:00 +0200
Message-Id: <20170509092010.30752-23-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop the argp argument as it can trivially be derived from the rqstp
argument.  With that all functions now have the same prototype, and we
can remove the unsafe casting to kxdrproc_t.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/svc4proc.c        |  2 +-
 fs/lockd/svcproc.c         |  2 +-
 fs/lockd/xdr.c             | 29 ++++++++++++------
 fs/lockd/xdr4.c            | 29 ++++++++++++------
 fs/nfs/callback_xdr.c      |  4 +--
 fs/nfsd/nfs2acl.c          | 21 +++++++------
 fs/nfsd/nfs3acl.c          | 11 +++----
 fs/nfsd/nfs3proc.c         | 42 +++++++++++++-------------
 fs/nfsd/nfs3xdr.c          | 74 +++++++++++++++++++++++++++-------------------
 fs/nfsd/nfs4proc.c         |  2 +-
 fs/nfsd/nfs4xdr.c          |  4 ++-
 fs/nfsd/nfsproc.c          | 36 +++++++++++-----------
 fs/nfsd/nfssvc.c           |  5 ++--
 fs/nfsd/nfsxdr.c           | 53 ++++++++++++++++++++-------------
 fs/nfsd/xdr.h              | 34 ++++++++-------------
 fs/nfsd/xdr3.h             | 47 ++++++++++-------------------
 fs/nfsd/xdr4.h             |  3 +-
 include/linux/lockd/xdr.h  | 18 +++++------
 include/linux/lockd/xdr4.h | 18 +++++------
 include/linux/sunrpc/svc.h |  3 +-
 net/sunrpc/svc.c           |  9 ++++--
 21 files changed, 237 insertions(+), 209 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 3e4cba029d3d..804744f7528c 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -496,7 +496,7 @@ struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
  { .pc_func	= nlm4svc_proc_##name,	\
-   .pc_decode	= (kxdrproc_t) nlm4svc_decode_##xargt,	\
+   .pc_decode	= nlm4svc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
    .pc_release	= NULL,					\
    .pc_argsize	= sizeof(struct nlm_##argt),		\
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 3add50661fab..204a698f7d41 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -538,7 +538,7 @@ struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
  { .pc_func	= nlmsvc_proc_##name,			\
-   .pc_decode	= (kxdrproc_t) nlmsvc_decode_##xargt,	\
+   .pc_decode	= nlmsvc_decode_##xargt,		\
    .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
    .pc_release	= NULL,					\
    .pc_argsize	= sizeof(struct nlm_##argt),		\
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 5b651daad518..b57af63fba56 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -182,8 +182,9 @@ nlm_encode_testres(__be32 *p, struct nlm_res *resp)
  * First, the server side XDR functions
  */
 int
-nlmsvc_decode_testargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlmsvc_decode_testargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm_decode_cookie(p, &argp->cookie)))
@@ -207,8 +208,9 @@ nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlmsvc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlmsvc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm_decode_cookie(p, &argp->cookie)))
@@ -227,8 +229,9 @@ nlmsvc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlmsvc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlmsvc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm_decode_cookie(p, &argp->cookie)))
@@ -243,8 +246,10 @@ nlmsvc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlmsvc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlmsvc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	if (!(p = nlm_decode_cookie(p, &argp->cookie))
 	 || !(p = nlm_decode_lock(p, &argp->lock)))
 		return 0;
@@ -253,8 +258,9 @@ nlmsvc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlmsvc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlmsvc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_lock	*lock = &argp->lock;
 
 	memset(lock, 0, sizeof(*lock));
@@ -293,8 +299,9 @@ nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlmsvc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
+nlmsvc_decode_notify(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_lock	*lock = &argp->lock;
 
 	if (!(p = xdr_decode_string_inplace(p, &lock->caller,
@@ -305,8 +312,10 @@ nlmsvc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
 }
 
 int
-nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
+nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_reboot *argp = rqstp->rq_argp;
+
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
@@ -316,8 +325,10 @@ nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
 }
 
 int
-nlmsvc_decode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlmsvc_decode_res(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_argp;
+
 	if (!(p = nlm_decode_cookie(p, &resp->cookie)))
 		return 0;
 	resp->status = *p++;
@@ -325,7 +336,7 @@ nlmsvc_decode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlmsvc_decode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nlmsvc_decode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_argsize_check(rqstp, p);
 }
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index dfa4789cd460..46e18598a15c 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -179,8 +179,9 @@ nlm4_encode_testres(__be32 *p, struct nlm_res *resp)
  * First, the server side XDR functions
  */
 int
-nlm4svc_decode_testargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlm4svc_decode_testargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm4_decode_cookie(p, &argp->cookie)))
@@ -204,8 +205,9 @@ nlm4svc_encode_testres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlm4svc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlm4svc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm4_decode_cookie(p, &argp->cookie)))
@@ -224,8 +226,9 @@ nlm4svc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlm4svc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlm4svc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	u32	exclusive;
 
 	if (!(p = nlm4_decode_cookie(p, &argp->cookie)))
@@ -240,8 +243,10 @@ nlm4svc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlm4svc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlm4svc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
+
 	if (!(p = nlm4_decode_cookie(p, &argp->cookie))
 	 || !(p = nlm4_decode_lock(p, &argp->lock)))
 		return 0;
@@ -250,8 +255,9 @@ nlm4svc_decode_unlockargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
 }
 
 int
-nlm4svc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p, nlm_args *argp)
+nlm4svc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_lock	*lock = &argp->lock;
 
 	memset(lock, 0, sizeof(*lock));
@@ -290,8 +296,9 @@ nlm4svc_encode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlm4svc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
+nlm4svc_decode_notify(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_lock	*lock = &argp->lock;
 
 	if (!(p = xdr_decode_string_inplace(p, &lock->caller,
@@ -302,8 +309,10 @@ nlm4svc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
 }
 
 int
-nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
+nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_reboot *argp = rqstp->rq_argp;
+
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
@@ -313,8 +322,10 @@ nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp
 }
 
 int
-nlm4svc_decode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlm4svc_decode_res(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_argp;
+
 	if (!(p = nlm4_decode_cookie(p, &resp->cookie)))
 		return 0;
 	resp->status = *p++;
@@ -322,7 +333,7 @@ nlm4svc_decode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlm4svc_decode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nlm4svc_decode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_argsize_check(rqstp, p);
 }
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 659a221bce61..dff77a1ad6e6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -58,7 +58,7 @@ static __be32 nfs4_callback_null(struct svc_rqst *rqstp)
 	return htonl(NFS4_OK);
 }
 
-static int nfs4_decode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfs4_decode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_argsize_check(rqstp, p);
 }
@@ -1053,7 +1053,7 @@ static struct callback_op callback_ops[] = {
 static struct svc_procedure nfs4_callback_procedures1[] = {
 	[CB_NULL] = {
 		.pc_func = nfs4_callback_null,
-		.pc_decode = (kxdrproc_t)nfs4_decode_void,
+		.pc_decode = nfs4_decode_void,
 		.pc_encode = (kxdrproc_t)nfs4_encode_void,
 		.pc_xdrressize = 1,
 	},
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 302441027f50..bcfdaa83ee6c 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -182,9 +182,10 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 /*
  * XDR decode functions
  */
-static int nfsaclsvc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclargs *argp)
+static int nfsaclsvc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
+
 	p = nfs2svc_decode_fh(p, &argp->fh);
 	if (!p)
 		return 0;
@@ -194,9 +195,9 @@ static int nfsaclsvc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 
-static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_setaclargs *argp)
+static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
 	struct kvec *head = rqstp->rq_arg.head;
 	unsigned int base;
 	int n;
@@ -220,18 +221,20 @@ static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
 	return (n > 0);
 }
 
-static int nfsaclsvc_decode_fhandleargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd_fhandle *argp)
+static int nfsaclsvc_decode_fhandleargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_fhandle *argp = rqstp->rq_argp;
+
 	p = nfs2svc_decode_fh(p, &argp->fh);
 	if (!p)
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
 
-static int nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_accessargs *argp)
+static int nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_accessargs *argp = rqstp->rq_argp;
+
 	p = nfs2svc_decode_fh(p, &argp->fh);
 	if (!p)
 		return 0;
@@ -351,7 +354,7 @@ struct nfsd3_voidargs { int dummy; };
 #define PROC(name, argt, rest, relt, cache, respsize)			\
 {									\
 	.pc_func	= nfsacld_proc_##name,				\
-	.pc_decode	= (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
+	.pc_decode	= nfsaclsvc_decode_##argt##args,		\
 	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
 	.pc_release	= nfsaclsvc_release_##relt,	\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 56cdff4e954c..4e68d6b5f409 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -124,9 +124,10 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 /*
  * XDR decode functions
  */
-static int nfs3svc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclargs *args)
+static int nfs3svc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_getaclargs *args = rqstp->rq_argp;
+
 	p = nfs3svc_decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -136,9 +137,9 @@ static int nfs3svc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 
-static int nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_setaclargs *args)
+static int nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_setaclargs *args = rqstp->rq_argp;
 	struct kvec *head = rqstp->rq_arg.head;
 	unsigned int base;
 	int n;
@@ -241,7 +242,7 @@ struct nfsd3_voidargs { int dummy; };
 #define PROC(name, argt, rest, relt, cache, respsize)			\
 {									\
 	.pc_func	= nfsd3_proc_##name,				\
-	.pc_decode	= (kxdrproc_t) nfs3svc_decode_##argt##args,	\
+	.pc_decode	= nfs3svc_decode_##argt##args,			\
 	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
 	.pc_release	= nfs3svc_release_##relt,			\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index f0cccc0768ce..ed83e8a9e7b4 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -685,7 +685,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_GETATTR] = {
 		.pc_func = nfsd3_proc_getattr,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
+		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_attrstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
@@ -695,7 +695,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_SETATTR] = {
 		.pc_func = nfsd3_proc_setattr,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_sattrargs,
+		.pc_decode = nfs3svc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_sattrargs),
@@ -705,7 +705,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_LOOKUP] = {
 		.pc_func = nfsd3_proc_lookup,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
+		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_diropres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
@@ -715,7 +715,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_ACCESS] = {
 		.pc_func = nfsd3_proc_access,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_accessargs,
+		.pc_decode = nfs3svc_decode_accessargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_accessres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_accessargs),
@@ -725,7 +725,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_READLINK] = {
 		.pc_func = nfsd3_proc_readlink,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_readlinkargs,
+		.pc_decode = nfs3svc_decode_readlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readlinkres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readlinkargs),
@@ -735,7 +735,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_READ] = {
 		.pc_func = nfsd3_proc_read,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_readargs,
+		.pc_decode = nfs3svc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readargs),
@@ -745,7 +745,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_WRITE] = {
 		.pc_func = nfsd3_proc_write,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_writeargs,
+		.pc_decode = nfs3svc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_writeres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_writeargs),
@@ -755,7 +755,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_CREATE] = {
 		.pc_func = nfsd3_proc_create,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_createargs,
+		.pc_decode = nfs3svc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_createargs),
@@ -765,7 +765,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_MKDIR] = {
 		.pc_func = nfsd3_proc_mkdir,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_mkdirargs,
+		.pc_decode = nfs3svc_decode_mkdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mkdirargs),
@@ -775,7 +775,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_SYMLINK] = {
 		.pc_func = nfsd3_proc_symlink,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_symlinkargs,
+		.pc_decode = nfs3svc_decode_symlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_symlinkargs),
@@ -785,7 +785,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_MKNOD] = {
 		.pc_func = nfsd3_proc_mknod,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_mknodargs,
+		.pc_decode = nfs3svc_decode_mknodargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mknodargs),
@@ -795,7 +795,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_REMOVE] = {
 		.pc_func = nfsd3_proc_remove,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
+		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
@@ -805,7 +805,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_RMDIR] = {
 		.pc_func = nfsd3_proc_rmdir,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
+		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
@@ -815,7 +815,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_RENAME] = {
 		.pc_func = nfsd3_proc_rename,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_renameargs,
+		.pc_decode = nfs3svc_decode_renameargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_renameres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_renameargs),
@@ -825,7 +825,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_LINK] = {
 		.pc_func = nfsd3_proc_link,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_linkargs,
+		.pc_decode = nfs3svc_decode_linkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_linkres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_linkargs),
@@ -835,7 +835,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_READDIR] = {
 		.pc_func = nfsd3_proc_readdir,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirargs,
+		.pc_decode = nfs3svc_decode_readdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirargs),
@@ -844,7 +844,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_READDIRPLUS] = {
 		.pc_func = nfsd3_proc_readdirplus,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirplusargs,
+		.pc_decode = nfs3svc_decode_readdirplusargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirplusargs),
@@ -853,7 +853,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_FSSTAT] = {
 		.pc_func = nfsd3_proc_fsstat,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
+		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsstatres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_fsstatres),
@@ -862,7 +862,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_FSINFO] = {
 		.pc_func = nfsd3_proc_fsinfo,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
+		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsinfores,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_fsinfores),
@@ -871,7 +871,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_PATHCONF] = {
 		.pc_func = nfsd3_proc_pathconf,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
+		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_pathconfres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_pathconfres),
@@ -880,7 +880,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 	[NFS3PROC_COMMIT] = {
 		.pc_func = nfsd3_proc_commit,
-		.pc_decode = (kxdrproc_t) nfs3svc_decode_commitargs,
+		.pc_decode = nfs3svc_decode_commitargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_commitres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_commitargs),
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index c3d3ef28347c..c56089ac2819 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -273,8 +273,10 @@ void fill_post_wcc(struct svc_fh *fhp)
  * XDR decode functions
  */
 int
-nfs3svc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *args)
+nfs3svc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_fhandle *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -282,9 +284,10 @@ nfs3svc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *a
 }
 
 int
-nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_sattrargs *args)
+nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_sattrargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -300,9 +303,10 @@ nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_diropargs *args)
+nfs3svc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_diropargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->fh))
 	 || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -311,9 +315,10 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_accessargs *args)
+nfs3svc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_accessargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -323,9 +328,9 @@ nfs3svc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readargs *args)
+nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readargs *args = rqstp->rq_argp;
 	unsigned int len;
 	int v;
 	u32 max_blocksize = svc_max_payload(rqstp);
@@ -353,9 +358,9 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_writeargs *args)
+nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_writeargs *args = rqstp->rq_argp;
 	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
 	struct kvec *head = rqstp->rq_arg.head;
@@ -413,9 +418,10 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_createargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_createargs *args)
+nfs3svc_decode_createargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_createargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->fh))
 	 || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -435,10 +441,12 @@ nfs3svc_decode_createargs(struct svc_rqst *rqstp, __be32 *p,
 
 	return xdr_argsize_check(rqstp, p);
 }
+
 int
-nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_createargs *args)
+nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_createargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->fh)) ||
 	    !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -448,9 +456,9 @@ nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_symlinkargs *args)
+nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_symlinkargs *args = rqstp->rq_argp;
 	unsigned int len, avail;
 	char *old, *new;
 	struct kvec *vec;
@@ -500,9 +508,10 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_mknodargs *args)
+nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_mknodargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->fh))
 	 || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -522,9 +531,10 @@ nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_renameargs *args)
+nfs3svc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_renameargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->ffh))
 	 || !(p = decode_filename(p, &args->fname, &args->flen))
 	 || !(p = decode_fh(p, &args->tfh))
@@ -535,9 +545,10 @@ nfs3svc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readlinkargs *args)
+nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readlinkargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -547,9 +558,10 @@ nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_linkargs *args)
+nfs3svc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_linkargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->ffh))
 	 || !(p = decode_fh(p, &args->tfh))
 	 || !(p = decode_filename(p, &args->tname, &args->tlen)))
@@ -559,9 +571,9 @@ nfs3svc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readdirargs *args)
+nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readdirargs *args = rqstp->rq_argp;
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -576,9 +588,9 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readdirargs *args)
+nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readdirargs *args = rqstp->rq_argp;
 	int len;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
@@ -602,9 +614,9 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfs3svc_decode_commitargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_commitargs *args)
+nfs3svc_decode_commitargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_commitargs *args = rqstp->rq_argp;
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 54f778cb3068..7bba53a91af9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2527,7 +2527,7 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 	},
 	[NFSPROC4_COMPOUND] = {
 		.pc_func = nfsd4_proc_compound,
-		.pc_decode = (kxdrproc_t) nfs4svc_decode_compoundargs,
+		.pc_decode = nfs4svc_decode_compoundargs,
 		.pc_encode = (kxdrproc_t) nfs4svc_encode_compoundres,
 		.pc_argsize = sizeof(struct nfsd4_compoundargs),
 		.pc_ressize = sizeof(struct nfsd4_compoundres),
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c67aaf59fa3f..6c3e2ec7c104 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4556,8 +4556,10 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 }
 
 int
-nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compoundargs *args)
+nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+
 	if (rqstp->rq_arg.head[0].iov_len % 4) {
 		/* client is nuts */
 		dprintk("%s: compound not properly padded! (peeraddr=%pISc xid=0x%x)",
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index dc32e0f8480d..d351d0ef6d34 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -576,7 +576,7 @@ struct nfsd_void { int dummy; };
 static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_NULL] = {
 		.pc_func = nfsd_proc_null,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_void,
+		.pc_decode = nfssvc_decode_void,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -585,7 +585,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_GETATTR] = {
 		.pc_func = nfsd_proc_getattr,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_fhandle,
+		.pc_decode = nfssvc_decode_fhandle,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
@@ -595,7 +595,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_SETATTR] = {
 		.pc_func = nfsd_proc_setattr,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_sattrargs,
+		.pc_decode = nfssvc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_sattrargs),
@@ -604,7 +604,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+AT,
 	},
 	[NFSPROC_ROOT] = {
-		.pc_decode = (kxdrproc_t) nfssvc_decode_void,
+		.pc_decode = nfssvc_decode_void,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -613,7 +613,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_LOOKUP] = {
 		.pc_func = nfsd_proc_lookup,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
+		.pc_decode = nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
@@ -623,7 +623,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_READLINK] = {
 		.pc_func = nfsd_proc_readlink,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_readlinkargs,
+		.pc_decode = nfssvc_decode_readlinkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readlinkres,
 		.pc_argsize = sizeof(struct nfsd_readlinkargs),
 		.pc_ressize = sizeof(struct nfsd_readlinkres),
@@ -632,7 +632,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_READ] = {
 		.pc_func = nfsd_proc_read,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_readargs,
+		.pc_decode = nfssvc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_readargs),
@@ -641,7 +641,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_xdrressize = ST+AT+1+NFSSVC_MAXBLKSIZE_V2/4,
 	},
 	[NFSPROC_WRITECACHE] = {
-		.pc_decode = (kxdrproc_t) nfssvc_decode_void,
+		.pc_decode = nfssvc_decode_void,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -650,7 +650,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_WRITE] = {
 		.pc_func = nfsd_proc_write,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_writeargs,
+		.pc_decode = nfssvc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_writeargs),
@@ -660,7 +660,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_CREATE] = {
 		.pc_func = nfsd_proc_create,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
+		.pc_decode = nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
@@ -670,7 +670,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_REMOVE] = {
 		.pc_func = nfsd_proc_remove,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
+		.pc_decode = nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -679,7 +679,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_RENAME] = {
 		.pc_func = nfsd_proc_rename,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_renameargs,
+		.pc_decode = nfssvc_decode_renameargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_renameargs),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -688,7 +688,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_LINK] = {
 		.pc_func = nfsd_proc_link,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_linkargs,
+		.pc_decode = nfssvc_decode_linkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_linkargs),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -697,7 +697,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_SYMLINK] = {
 		.pc_func = nfsd_proc_symlink,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_symlinkargs,
+		.pc_decode = nfssvc_decode_symlinkargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_symlinkargs),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -706,7 +706,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_MKDIR] = {
 		.pc_func = nfsd_proc_mkdir,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
+		.pc_decode = nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
@@ -716,7 +716,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_RMDIR] = {
 		.pc_func = nfsd_proc_rmdir,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
+		.pc_decode = nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_void),
@@ -725,7 +725,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_READDIR] = {
 		.pc_func = nfsd_proc_readdir,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_readdirargs,
+		.pc_decode = nfssvc_decode_readdirargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readdirres,
 		.pc_argsize = sizeof(struct nfsd_readdirargs),
 		.pc_ressize = sizeof(struct nfsd_readdirres),
@@ -733,7 +733,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_STATFS] = {
 		.pc_func = nfsd_proc_statfs,
-		.pc_decode = (kxdrproc_t) nfssvc_decode_fhandle,
+		.pc_decode = nfssvc_decode_fhandle,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_statfsres,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
 		.pc_ressize = sizeof(struct nfsd_statfsres),
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d64895fd8d25..3e00499d7ad7 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -801,9 +801,8 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	 */
 	rqstp->rq_cachetype = proc->pc_cachetype;
 	/* Decode arguments */
-	xdr = proc->pc_decode;
-	if (xdr && !xdr(rqstp, (__be32*)rqstp->rq_arg.head[0].iov_base,
-			rqstp->rq_argp)) {
+	if (proc->pc_decode &&
+	    !proc->pc_decode(rqstp, (__be32*)rqstp->rq_arg.head[0].iov_base)) {
 		dprintk("nfsd: failed to decode arguments!\n");
 		*statp = rpc_garbage_args;
 		return 1;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 2facfc6ac8f3..19cf04ebf388 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -206,14 +206,16 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *f
  * XDR decode functions
  */
 int
-nfssvc_decode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nfssvc_decode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_argsize_check(rqstp, p);
 }
 
 int
-nfssvc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *args)
+nfssvc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_fhandle *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -221,9 +223,10 @@ nfssvc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *ar
 }
 
 int
-nfssvc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_sattrargs *args)
+nfssvc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_sattrargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -233,9 +236,10 @@ nfssvc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_diropargs *args)
+nfssvc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_diropargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->fh))
 	 || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -244,9 +248,9 @@ nfssvc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_readargs *args)
+nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readargs *args = rqstp->rq_argp;
 	unsigned int len;
 	int v;
 	p = decode_fh(p, &args->fh);
@@ -276,9 +280,9 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_writeargs *args)
+nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_writeargs *args = rqstp->rq_argp;
 	unsigned int len, hdr, dlen;
 	struct kvec *head = rqstp->rq_arg.head;
 	int v;
@@ -332,9 +336,10 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_createargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_createargs *args)
+nfssvc_decode_createargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_createargs *args = rqstp->rq_argp;
+
 	if (   !(p = decode_fh(p, &args->fh))
 	    || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
@@ -344,9 +349,10 @@ nfssvc_decode_createargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_renameargs *args)
+nfssvc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_renameargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->ffh))
 	 || !(p = decode_filename(p, &args->fname, &args->flen))
 	 || !(p = decode_fh(p, &args->tfh))
@@ -357,8 +363,10 @@ nfssvc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd_readlinkargs *args)
+nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readlinkargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -368,9 +376,10 @@ nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd_readli
 }
 
 int
-nfssvc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_linkargs *args)
+nfssvc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_linkargs *args = rqstp->rq_argp;
+
 	if (!(p = decode_fh(p, &args->ffh))
 	 || !(p = decode_fh(p, &args->tfh))
 	 || !(p = decode_filename(p, &args->tname, &args->tlen)))
@@ -380,9 +389,10 @@ nfssvc_decode_linkargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_symlinkargs *args)
+nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_symlinkargs *args = rqstp->rq_argp;
+
 	if (   !(p = decode_fh(p, &args->ffh))
 	    || !(p = decode_filename(p, &args->fname, &args->flen))
 	    || !(p = decode_pathname(p, &args->tname, &args->tlen)))
@@ -393,9 +403,10 @@ nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_readdirargs *args)
+nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readdirargs *args = rqstp->rq_argp;
+
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 2c21fa843fbf..8eeb752cf6f8 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -131,28 +131,18 @@ union nfsd_xdrstore {
 #define NFS2_SVC_XDRSIZE	sizeof(union nfsd_xdrstore)
 
 
-int nfssvc_decode_void(struct svc_rqst *, __be32 *, void *);
-int nfssvc_decode_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
-int nfssvc_decode_sattrargs(struct svc_rqst *, __be32 *,
-				struct nfsd_sattrargs *);
-int nfssvc_decode_diropargs(struct svc_rqst *, __be32 *,
-				struct nfsd_diropargs *);
-int nfssvc_decode_readargs(struct svc_rqst *, __be32 *,
-				struct nfsd_readargs *);
-int nfssvc_decode_writeargs(struct svc_rqst *, __be32 *,
-				struct nfsd_writeargs *);
-int nfssvc_decode_createargs(struct svc_rqst *, __be32 *,
-				struct nfsd_createargs *);
-int nfssvc_decode_renameargs(struct svc_rqst *, __be32 *,
-				struct nfsd_renameargs *);
-int nfssvc_decode_readlinkargs(struct svc_rqst *, __be32 *,
-				struct nfsd_readlinkargs *);
-int nfssvc_decode_linkargs(struct svc_rqst *, __be32 *,
-				struct nfsd_linkargs *);
-int nfssvc_decode_symlinkargs(struct svc_rqst *, __be32 *,
-				struct nfsd_symlinkargs *);
-int nfssvc_decode_readdirargs(struct svc_rqst *, __be32 *,
-				struct nfsd_readdirargs *);
+int nfssvc_decode_void(struct svc_rqst *, __be32 *);
+int nfssvc_decode_fhandle(struct svc_rqst *, __be32 *);
+int nfssvc_decode_sattrargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_diropargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_readargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_writeargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_createargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_renameargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_readlinkargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_linkargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_symlinkargs(struct svc_rqst *, __be32 *);
+int nfssvc_decode_readdirargs(struct svc_rqst *, __be32 *);
 int nfssvc_encode_void(struct svc_rqst *, __be32 *, void *);
 int nfssvc_encode_attrstat(struct svc_rqst *, __be32 *, struct nfsd_attrstat *);
 int nfssvc_encode_diropres(struct svc_rqst *, __be32 *, struct nfsd_diropres *);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 23fe456a223b..f79be4c42e4a 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -269,37 +269,22 @@ union nfsd3_xdrstore {
 
 #define NFS3_SVC_XDRSIZE		sizeof(union nfsd3_xdrstore)
 
-int nfs3svc_decode_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
-int nfs3svc_decode_sattrargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_sattrargs *);
-int nfs3svc_decode_diropargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_diropargs *);
-int nfs3svc_decode_accessargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_accessargs *);
-int nfs3svc_decode_readargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_readargs *);
-int nfs3svc_decode_writeargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_writeargs *);
-int nfs3svc_decode_createargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_createargs *);
-int nfs3svc_decode_mkdirargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_createargs *);
-int nfs3svc_decode_mknodargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_mknodargs *);
-int nfs3svc_decode_renameargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_renameargs *);
-int nfs3svc_decode_readlinkargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_readlinkargs *);
-int nfs3svc_decode_linkargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_linkargs *);
-int nfs3svc_decode_symlinkargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_symlinkargs *);
-int nfs3svc_decode_readdirargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_readdirargs *);
-int nfs3svc_decode_readdirplusargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_readdirargs *);
-int nfs3svc_decode_commitargs(struct svc_rqst *, __be32 *,
-				struct nfsd3_commitargs *);
+int nfs3svc_decode_fhandle(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_sattrargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_diropargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_accessargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_readargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_writeargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_createargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_mkdirargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_mknodargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_renameargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_readlinkargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_linkargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_symlinkargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_readdirargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_readdirplusargs(struct svc_rqst *, __be32 *);
+int nfs3svc_decode_commitargs(struct svc_rqst *, __be32 *);
 int nfs3svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
 int nfs3svc_encode_attrstat(struct svc_rqst *, __be32 *,
 				struct nfsd3_attrstat *);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index a158579d55a2..2a53c1233884 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -683,8 +683,7 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 
 bool nfsd4_mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp);
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
-int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
-		struct nfsd4_compoundargs *);
+int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *);
 int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundres *);
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index d39ed1cc5fbf..0416600844ce 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -95,19 +95,19 @@ struct nlm_reboot {
  */
 #define NLMSVC_XDRSIZE		sizeof(struct nlm_args)
 
-int	nlmsvc_decode_testargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlmsvc_decode_testargs(struct svc_rqst *, __be32 *);
 int	nlmsvc_encode_testres(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlmsvc_decode_lockargs(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlmsvc_decode_cancargs(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlmsvc_decode_unlockargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlmsvc_decode_lockargs(struct svc_rqst *, __be32 *);
+int	nlmsvc_decode_cancargs(struct svc_rqst *, __be32 *);
+int	nlmsvc_decode_unlockargs(struct svc_rqst *, __be32 *);
 int	nlmsvc_encode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlmsvc_decode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlmsvc_decode_res(struct svc_rqst *, __be32 *);
 int	nlmsvc_encode_void(struct svc_rqst *, __be32 *, void *);
-int	nlmsvc_decode_void(struct svc_rqst *, __be32 *, void *);
-int	nlmsvc_decode_shareargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlmsvc_decode_void(struct svc_rqst *, __be32 *);
+int	nlmsvc_decode_shareargs(struct svc_rqst *, __be32 *);
 int	nlmsvc_encode_shareres(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlmsvc_decode_notify(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlmsvc_decode_reboot(struct svc_rqst *, __be32 *, struct nlm_reboot *);
+int	nlmsvc_decode_notify(struct svc_rqst *, __be32 *);
+int	nlmsvc_decode_reboot(struct svc_rqst *, __be32 *);
 /*
 int	nlmclt_encode_testargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_lockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
diff --git a/include/linux/lockd/xdr4.h b/include/linux/lockd/xdr4.h
index e58c88b52ce1..951bbe31fdb8 100644
--- a/include/linux/lockd/xdr4.h
+++ b/include/linux/lockd/xdr4.h
@@ -23,19 +23,19 @@
 
 
 
-int	nlm4svc_decode_testargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlm4svc_decode_testargs(struct svc_rqst *, __be32 *);
 int	nlm4svc_encode_testres(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlm4svc_decode_lockargs(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlm4svc_decode_cancargs(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlm4svc_decode_unlockargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlm4svc_decode_lockargs(struct svc_rqst *, __be32 *);
+int	nlm4svc_decode_cancargs(struct svc_rqst *, __be32 *);
+int	nlm4svc_decode_unlockargs(struct svc_rqst *, __be32 *);
 int	nlm4svc_encode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlm4svc_decode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlm4svc_decode_res(struct svc_rqst *, __be32 *);
 int	nlm4svc_encode_void(struct svc_rqst *, __be32 *, void *);
-int	nlm4svc_decode_void(struct svc_rqst *, __be32 *, void *);
-int	nlm4svc_decode_shareargs(struct svc_rqst *, __be32 *, struct nlm_args *);
+int	nlm4svc_decode_void(struct svc_rqst *, __be32 *);
+int	nlm4svc_decode_shareargs(struct svc_rqst *, __be32 *);
 int	nlm4svc_encode_shareres(struct svc_rqst *, __be32 *, struct nlm_res *);
-int	nlm4svc_decode_notify(struct svc_rqst *, __be32 *, struct nlm_args *);
-int	nlm4svc_decode_reboot(struct svc_rqst *, __be32 *, struct nlm_reboot *);
+int	nlm4svc_decode_notify(struct svc_rqst *, __be32 *);
+int	nlm4svc_decode_reboot(struct svc_rqst *, __be32 *);
 /*
 int	nlmclt_encode_testargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_lockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index f962e3385965..ae971b7e441c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -422,7 +422,8 @@ struct svc_version {
 struct svc_procedure {
 	/* process the request: */
 	__be32			(*pc_func)(struct svc_rqst *);
-	kxdrproc_t		pc_decode;	/* XDR decode args */
+	/* XDR decode args: */
+	int			(*pc_decode)(struct svc_rqst *, __be32 *data);
 	kxdrproc_t		pc_encode;	/* XDR encode result */
 	/* XDR free result: */
 	void			(*pc_release)(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index df540275933d..5fadf179e3c6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1218,9 +1218,12 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 
 	/* Call the function that processes the request. */
 	if (!versp->vs_dispatch) {
-		/* Decode arguments */
-		xdr = procp->pc_decode;
-		if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp))
+		/*
+		 * Decode arguments
+		 * XXX: why do we ignore the return value?
+		 */
+		if (procp->pc_decode &&
+		    !procp->pc_decode(rqstp, argv->iov_base))
 			goto err_garbage;
 
 		*statp = procp->pc_func(rqstp);
-- 
2.11.0

