Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:32878 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933004AbdELQSY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:24 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 24/33] sunrpc: properly type pc_encode callbacks
Date: Fri, 12 May 2017 18:16:52 +0200
Message-Id: <20170512161701.22468-25-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop the resp argument as it can trivially be derived from the rqstp
argument.  With that all functions now have the same prototype, and we
can remove the unsafe casting to kxdrproc_t.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/lockd/svc4proc.c        |  2 +-
 fs/lockd/svcproc.c         |  2 +-
 fs/lockd/xdr.c             | 14 ++++++---
 fs/lockd/xdr4.c            | 14 ++++++---
 fs/nfs/callback_xdr.c      |  6 ++--
 fs/nfsd/nfs2acl.c          | 18 ++++++-----
 fs/nfsd/nfs3acl.c          | 11 +++----
 fs/nfsd/nfs3proc.c         | 44 +++++++++++++--------------
 fs/nfsd/nfs3xdr.c          | 74 +++++++++++++++++++++++++++-------------------
 fs/nfsd/nfs4proc.c         |  4 +--
 fs/nfsd/nfs4xdr.c          |  5 ++--
 fs/nfsd/nfsproc.c          | 36 +++++++++++-----------
 fs/nfsd/nfssvc.c           |  5 +---
 fs/nfsd/nfsxdr.c           | 31 +++++++++++--------
 fs/nfsd/xdr.h              | 14 ++++-----
 fs/nfsd/xdr3.h             | 45 ++++++++++------------------
 fs/nfsd/xdr4.h             |  5 ++--
 include/linux/lockd/xdr.h  |  8 ++---
 include/linux/lockd/xdr4.h |  8 ++---
 include/linux/sunrpc/svc.h |  3 +-
 net/sunrpc/svc.c           |  6 ++--
 21 files changed, 185 insertions(+), 170 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 804744f7528c..fed016155791 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -497,7 +497,7 @@ struct nlm_void			{ int dummy; };
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
  { .pc_func	= nlm4svc_proc_##name,	\
    .pc_decode	= nlm4svc_decode_##xargt,	\
-   .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
+   .pc_encode	= nlm4svc_encode_##xrest,	\
    .pc_release	= NULL,					\
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 204a698f7d41..14648b051eba 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -539,7 +539,7 @@ struct nlm_void			{ int dummy; };
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
  { .pc_func	= nlmsvc_proc_##name,			\
    .pc_decode	= nlmsvc_decode_##xargt,		\
-   .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
+   .pc_encode	= nlmsvc_encode_##xrest,		\
    .pc_release	= NULL,					\
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index b57af63fba56..442bbd0b0b29 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -200,8 +200,10 @@ nlmsvc_decode_testargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm_encode_testres(p, resp)))
 		return 0;
 	return xdr_ressize_check(rqstp, p);
@@ -280,8 +282,10 @@ nlmsvc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlmsvc_encode_shareres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlmsvc_encode_shareres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm_encode_cookie(p, &resp->cookie)))
 		return 0;
 	*p++ = resp->status;
@@ -290,8 +294,10 @@ nlmsvc_encode_shareres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm_encode_cookie(p, &resp->cookie)))
 		return 0;
 	*p++ = resp->status;
@@ -342,7 +348,7 @@ nlmsvc_decode_void(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 46e18598a15c..2a0cd5679c49 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -197,8 +197,10 @@ nlm4svc_decode_testargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlm4svc_encode_testres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlm4svc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm4_encode_testres(p, resp)))
 		return 0;
 	return xdr_ressize_check(rqstp, p);
@@ -277,8 +279,10 @@ nlm4svc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlm4svc_encode_shareres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlm4svc_encode_shareres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm4_encode_cookie(p, &resp->cookie)))
 		return 0;
 	*p++ = resp->status;
@@ -287,8 +291,10 @@ nlm4svc_encode_shareres(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
 }
 
 int
-nlm4svc_encode_res(struct svc_rqst *rqstp, __be32 *p, struct nlm_res *resp)
+nlm4svc_encode_res(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nlm_res *resp = rqstp->rq_resp;
+
 	if (!(p = nlm4_encode_cookie(p, &resp->cookie)))
 		return 0;
 	*p++ = resp->status;
@@ -339,7 +345,7 @@ nlm4svc_decode_void(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlm4svc_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nlm4svc_encode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 23ecbf7a40c1..acf75dc63e14 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -63,7 +63,7 @@ static int nfs4_decode_void(struct svc_rqst *rqstp, __be32 *p)
 	return xdr_argsize_check(rqstp, p);
 }
 
-static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
@@ -999,12 +999,12 @@ static struct svc_procedure nfs4_callback_procedures1[] = {
 	[CB_NULL] = {
 		.pc_func = nfs4_callback_null,
 		.pc_decode = nfs4_decode_void,
-		.pc_encode = (kxdrproc_t)nfs4_encode_void,
+		.pc_encode = nfs4_encode_void,
 		.pc_xdrressize = 1,
 	},
 	[CB_COMPOUND] = {
 		.pc_func = nfs4_callback_compound,
-		.pc_encode = (kxdrproc_t)nfs4_encode_void,
+		.pc_encode = nfs4_encode_void,
 		.pc_argsize = 256,
 		.pc_ressize = 256,
 		.pc_xdrressize = NFS4_CALLBACK_BUFSIZE,
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index bcfdaa83ee6c..fc6b179c8fff 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -251,15 +251,15 @@ static int nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p)
  * There must be an encoding function for void results so svc_process
  * will work properly.
  */
-static int nfsaclsvc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfsaclsvc_encode_voidres(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
 
 /* GETACL */
-static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclres *resp)
+static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
 	struct dentry *dentry = resp->fh.fh_dentry;
 	struct inode *inode;
 	struct kvec *head = rqstp->rq_res.head;
@@ -302,17 +302,19 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 	return (n > 0);
 }
 
-static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd_attrstat *resp)
+static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
+
 	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
 /* ACCESS */
-static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_accessres *resp)
+static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_accessres *resp = rqstp->rq_resp;
+
 	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->access);
 	return xdr_ressize_check(rqstp, p);
@@ -355,7 +357,7 @@ struct nfsd3_voidargs { int dummy; };
 {									\
 	.pc_func	= nfsacld_proc_##name,				\
 	.pc_decode	= nfsaclsvc_decode_##argt##args,		\
-	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
+	.pc_encode	= nfsaclsvc_encode_##rest##res,			\
 	.pc_release	= nfsaclsvc_release_##relt,	\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
 	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 4e68d6b5f409..9437b758cbfd 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -168,9 +168,9 @@ static int nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p)
  */
 
 /* GETACL */
-static int nfs3svc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclres *resp)
+static int nfs3svc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
 	struct dentry *dentry = resp->fh.fh_dentry;
 
 	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
@@ -213,9 +213,10 @@ static int nfs3svc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 }
 
 /* SETACL */
-static int nfs3svc_encode_setaclres(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_attrstat *resp)
+static int nfs3svc_encode_setaclres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+
 	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
 
 	return xdr_ressize_check(rqstp, p);
@@ -243,7 +244,7 @@ struct nfsd3_voidargs { int dummy; };
 {									\
 	.pc_func	= nfsd3_proc_##name,				\
 	.pc_decode	= nfs3svc_decode_##argt##args,			\
-	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
+	.pc_encode	= nfs3svc_encode_##rest##res,			\
 	.pc_release	= nfs3svc_release_##relt,			\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
 	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index ed83e8a9e7b4..17c90c41a3a6 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -677,7 +677,7 @@ struct nfsd3_voidargs { int dummy; };
 static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_NULL] = {
 		.pc_func = nfsd3_proc_null,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_voidres,
+		.pc_encode = nfs3svc_encode_voidres,
 		.pc_argsize = sizeof(struct nfsd3_voidargs),
 		.pc_ressize = sizeof(struct nfsd3_voidres),
 		.pc_cachetype = RC_NOCACHE,
@@ -686,7 +686,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_GETATTR] = {
 		.pc_func = nfsd3_proc_getattr,
 		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_attrstatres,
+		.pc_encode = nfs3svc_encode_attrstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_attrstatres),
@@ -696,7 +696,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_SETATTR] = {
 		.pc_func = nfsd3_proc_setattr,
 		.pc_decode = nfs3svc_decode_sattrargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
+		.pc_encode = nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_sattrargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
@@ -706,7 +706,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_LOOKUP] = {
 		.pc_func = nfsd3_proc_lookup,
 		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_diropres,
+		.pc_encode = nfs3svc_encode_diropres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_diropres),
@@ -716,7 +716,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_ACCESS] = {
 		.pc_func = nfsd3_proc_access,
 		.pc_decode = nfs3svc_decode_accessargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_accessres,
+		.pc_encode = nfs3svc_encode_accessres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_accessargs),
 		.pc_ressize = sizeof(struct nfsd3_accessres),
@@ -726,7 +726,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_READLINK] = {
 		.pc_func = nfsd3_proc_readlink,
 		.pc_decode = nfs3svc_decode_readlinkargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_readlinkres,
+		.pc_encode = nfs3svc_encode_readlinkres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readlinkargs),
 		.pc_ressize = sizeof(struct nfsd3_readlinkres),
@@ -736,7 +736,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_READ] = {
 		.pc_func = nfsd3_proc_read,
 		.pc_decode = nfs3svc_decode_readargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_readres,
+		.pc_encode = nfs3svc_encode_readres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readargs),
 		.pc_ressize = sizeof(struct nfsd3_readres),
@@ -746,7 +746,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_WRITE] = {
 		.pc_func = nfsd3_proc_write,
 		.pc_decode = nfs3svc_decode_writeargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_writeres,
+		.pc_encode = nfs3svc_encode_writeres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_writeargs),
 		.pc_ressize = sizeof(struct nfsd3_writeres),
@@ -756,7 +756,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_CREATE] = {
 		.pc_func = nfsd3_proc_create,
 		.pc_decode = nfs3svc_decode_createargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
+		.pc_encode = nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_createargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
@@ -766,7 +766,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_MKDIR] = {
 		.pc_func = nfsd3_proc_mkdir,
 		.pc_decode = nfs3svc_decode_mkdirargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
+		.pc_encode = nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mkdirargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
@@ -776,7 +776,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_SYMLINK] = {
 		.pc_func = nfsd3_proc_symlink,
 		.pc_decode = nfs3svc_decode_symlinkargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
+		.pc_encode = nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_symlinkargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
@@ -786,7 +786,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_MKNOD] = {
 		.pc_func = nfsd3_proc_mknod,
 		.pc_decode = nfs3svc_decode_mknodargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
+		.pc_encode = nfs3svc_encode_createres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mknodargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
@@ -796,7 +796,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_REMOVE] = {
 		.pc_func = nfsd3_proc_remove,
 		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
+		.pc_encode = nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
@@ -806,7 +806,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_RMDIR] = {
 		.pc_func = nfsd3_proc_rmdir,
 		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
+		.pc_encode = nfs3svc_encode_wccstatres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
@@ -816,7 +816,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_RENAME] = {
 		.pc_func = nfsd3_proc_rename,
 		.pc_decode = nfs3svc_decode_renameargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_renameres,
+		.pc_encode = nfs3svc_encode_renameres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_renameargs),
 		.pc_ressize = sizeof(struct nfsd3_renameres),
@@ -826,7 +826,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_LINK] = {
 		.pc_func = nfsd3_proc_link,
 		.pc_decode = nfs3svc_decode_linkargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_linkres,
+		.pc_encode = nfs3svc_encode_linkres,
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_linkargs),
 		.pc_ressize = sizeof(struct nfsd3_linkres),
@@ -836,7 +836,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_READDIR] = {
 		.pc_func = nfsd3_proc_readdir,
 		.pc_decode = nfs3svc_decode_readdirargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
+		.pc_encode = nfs3svc_encode_readdirres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirargs),
 		.pc_ressize = sizeof(struct nfsd3_readdirres),
@@ -845,7 +845,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_READDIRPLUS] = {
 		.pc_func = nfsd3_proc_readdirplus,
 		.pc_decode = nfs3svc_decode_readdirplusargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
+		.pc_encode = nfs3svc_encode_readdirres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirplusargs),
 		.pc_ressize = sizeof(struct nfsd3_readdirres),
@@ -854,7 +854,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_FSSTAT] = {
 		.pc_func = nfsd3_proc_fsstat,
 		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsstatres,
+		.pc_encode = nfs3svc_encode_fsstatres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_fsstatres),
 		.pc_cachetype = RC_NOCACHE,
@@ -863,7 +863,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_FSINFO] = {
 		.pc_func = nfsd3_proc_fsinfo,
 		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_fsinfores,
+		.pc_encode = nfs3svc_encode_fsinfores,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_fsinfores),
 		.pc_cachetype = RC_NOCACHE,
@@ -872,7 +872,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_PATHCONF] = {
 		.pc_func = nfsd3_proc_pathconf,
 		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_pathconfres,
+		.pc_encode = nfs3svc_encode_pathconfres,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_pathconfres),
 		.pc_cachetype = RC_NOCACHE,
@@ -881,7 +881,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	[NFS3PROC_COMMIT] = {
 		.pc_func = nfsd3_proc_commit,
 		.pc_decode = nfs3svc_decode_commitargs,
-		.pc_encode = (kxdrproc_t) nfs3svc_encode_commitres,
+		.pc_encode = nfs3svc_encode_commitres,
 		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_commitargs),
 		.pc_ressize = sizeof(struct nfsd3_commitres),
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index be8bf8af9917..349e355edc73 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -645,16 +645,17 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp, __be32 *p)
  * will work properly.
  */
 int
-nfs3svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nfs3svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
 
 /* GETATTR */
 int
-nfs3svc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_attrstat *resp)
+nfs3svc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+
 	if (resp->status == 0) {
 		lease_get_mtime(d_inode(resp->fh.fh_dentry),
 				&resp->stat.mtime);
@@ -665,18 +666,20 @@ nfs3svc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p,
 
 /* SETATTR, REMOVE, RMDIR */
 int
-nfs3svc_encode_wccstat(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_attrstat *resp)
+nfs3svc_encode_wccstat(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+
 	p = encode_wcc_data(rqstp, p, &resp->fh);
 	return xdr_ressize_check(rqstp, p);
 }
 
 /* LOOKUP */
 int
-nfs3svc_encode_diropres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_diropres *resp)
+nfs3svc_encode_diropres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_diropres *resp = rqstp->rq_resp;
+
 	if (resp->status == 0) {
 		p = encode_fh(p, &resp->fh);
 		p = encode_post_op_attr(rqstp, p, &resp->fh);
@@ -687,9 +690,10 @@ nfs3svc_encode_diropres(struct svc_rqst *rqstp, __be32 *p,
 
 /* ACCESS */
 int
-nfs3svc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_accessres *resp)
+nfs3svc_encode_accessres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_accessres *resp = rqstp->rq_resp;
+
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0)
 		*p++ = htonl(resp->access);
@@ -698,9 +702,10 @@ nfs3svc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
 
 /* READLINK */
 int
-nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readlinkres *resp)
+nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readlinkres *resp = rqstp->rq_resp;
+
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0) {
 		*p++ = htonl(resp->len);
@@ -719,9 +724,10 @@ nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p,
 
 /* READ */
 int
-nfs3svc_encode_readres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readres *resp)
+nfs3svc_encode_readres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readres *resp = rqstp->rq_resp;
+
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0) {
 		*p++ = htonl(resp->count);
@@ -743,9 +749,9 @@ nfs3svc_encode_readres(struct svc_rqst *rqstp, __be32 *p,
 
 /* WRITE */
 int
-nfs3svc_encode_writeres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_writeres *resp)
+nfs3svc_encode_writeres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_writeres *resp = rqstp->rq_resp;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	p = encode_wcc_data(rqstp, p, &resp->fh);
@@ -760,9 +766,10 @@ nfs3svc_encode_writeres(struct svc_rqst *rqstp, __be32 *p,
 
 /* CREATE, MKDIR, SYMLINK, MKNOD */
 int
-nfs3svc_encode_createres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_diropres *resp)
+nfs3svc_encode_createres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_diropres *resp = rqstp->rq_resp;
+
 	if (resp->status == 0) {
 		*p++ = xdr_one;
 		p = encode_fh(p, &resp->fh);
@@ -774,9 +781,10 @@ nfs3svc_encode_createres(struct svc_rqst *rqstp, __be32 *p,
 
 /* RENAME */
 int
-nfs3svc_encode_renameres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_renameres *resp)
+nfs3svc_encode_renameres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_renameres *resp = rqstp->rq_resp;
+
 	p = encode_wcc_data(rqstp, p, &resp->ffh);
 	p = encode_wcc_data(rqstp, p, &resp->tfh);
 	return xdr_ressize_check(rqstp, p);
@@ -784,9 +792,10 @@ nfs3svc_encode_renameres(struct svc_rqst *rqstp, __be32 *p,
 
 /* LINK */
 int
-nfs3svc_encode_linkres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_linkres *resp)
+nfs3svc_encode_linkres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_linkres *resp = rqstp->rq_resp;
+
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	p = encode_wcc_data(rqstp, p, &resp->tfh);
 	return xdr_ressize_check(rqstp, p);
@@ -794,9 +803,10 @@ nfs3svc_encode_linkres(struct svc_rqst *rqstp, __be32 *p,
 
 /* READDIR */
 int
-nfs3svc_encode_readdirres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_readdirres *resp)
+nfs3svc_encode_readdirres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
+
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 
 	if (resp->status == 0) {
@@ -1044,9 +1054,9 @@ nfs3svc_encode_entry_plus(void *cd, const char *name,
 
 /* FSSTAT */
 int
-nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_fsstatres *resp)
+nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_fsstatres *resp = rqstp->rq_resp;
 	struct kstatfs	*s = &resp->stats;
 	u64		bs = s->f_bsize;
 
@@ -1066,9 +1076,10 @@ nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, __be32 *p,
 
 /* FSINFO */
 int
-nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_fsinfores *resp)
+nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_fsinfores *resp = rqstp->rq_resp;
+
 	*p++ = xdr_zero;	/* no post_op_attr */
 
 	if (resp->status == 0) {
@@ -1090,9 +1101,10 @@ nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, __be32 *p,
 
 /* PATHCONF */
 int
-nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_pathconfres *resp)
+nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_pathconfres *resp = rqstp->rq_resp;
+
 	*p++ = xdr_zero;	/* no post_op_attr */
 
 	if (resp->status == 0) {
@@ -1109,9 +1121,9 @@ nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, __be32 *p,
 
 /* COMMIT */
 int
-nfs3svc_encode_commitres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_commitres *resp)
+nfs3svc_encode_commitres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd3_commitres *resp = rqstp->rq_resp;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	p = encode_wcc_data(rqstp, p, &resp->fh);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6ff434b77a9e..ad0622efae4e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2520,7 +2520,7 @@ struct nfsd4_voidargs { int dummy; };
 static struct svc_procedure		nfsd_procedures4[2] = {
 	[NFSPROC4_NULL] = {
 		.pc_func = nfsd4_proc_null,
-		.pc_encode = (kxdrproc_t) nfs4svc_encode_voidres,
+		.pc_encode = nfs4svc_encode_voidres,
 		.pc_argsize = sizeof(struct nfsd4_voidargs),
 		.pc_ressize = sizeof(struct nfsd4_voidres),
 		.pc_cachetype = RC_NOCACHE,
@@ -2529,7 +2529,7 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 	[NFSPROC4_COMPOUND] = {
 		.pc_func = nfsd4_proc_compound,
 		.pc_decode = nfs4svc_decode_compoundargs,
-		.pc_encode = (kxdrproc_t) nfs4svc_encode_compoundres,
+		.pc_encode = nfs4svc_encode_compoundres,
 		.pc_argsize = sizeof(struct nfsd4_compoundargs),
 		.pc_ressize = sizeof(struct nfsd4_compoundres),
 		.pc_release = nfsd4_release_compoundargs,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3a7e117bd11e..54e212e3541e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4538,7 +4538,7 @@ nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
 }
 
 int
-nfs4svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nfs4svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p)
 {
         return xdr_ressize_check(rqstp, p);
 }
@@ -4584,11 +4584,12 @@ nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compoundres *resp)
+nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p)
 {
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct xdr_buf *buf = resp->xdr.buf;
 
 	WARN_ON_ONCE(buf->len != buf->head[0].iov_len + buf->page_len +
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index d351d0ef6d34..0ef88d0e67d9 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -577,7 +577,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_NULL] = {
 		.pc_func = nfsd_proc_null,
 		.pc_decode = nfssvc_decode_void,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_NOCACHE,
@@ -586,7 +586,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_GETATTR] = {
 		.pc_func = nfsd_proc_getattr,
 		.pc_decode = nfssvc_decode_fhandle,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
+		.pc_encode = nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
@@ -596,7 +596,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_SETATTR] = {
 		.pc_func = nfsd_proc_setattr,
 		.pc_decode = nfssvc_decode_sattrargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
+		.pc_encode = nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_sattrargs),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
@@ -605,7 +605,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_ROOT] = {
 		.pc_decode = nfssvc_decode_void,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_NOCACHE,
@@ -614,7 +614,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_LOOKUP] = {
 		.pc_func = nfsd_proc_lookup,
 		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
+		.pc_encode = nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
@@ -624,7 +624,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_READLINK] = {
 		.pc_func = nfsd_proc_readlink,
 		.pc_decode = nfssvc_decode_readlinkargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_readlinkres,
+		.pc_encode = nfssvc_encode_readlinkres,
 		.pc_argsize = sizeof(struct nfsd_readlinkargs),
 		.pc_ressize = sizeof(struct nfsd_readlinkres),
 		.pc_cachetype = RC_NOCACHE,
@@ -633,7 +633,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_READ] = {
 		.pc_func = nfsd_proc_read,
 		.pc_decode = nfssvc_decode_readargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_readres,
+		.pc_encode = nfssvc_encode_readres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_readargs),
 		.pc_ressize = sizeof(struct nfsd_readres),
@@ -642,7 +642,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	},
 	[NFSPROC_WRITECACHE] = {
 		.pc_decode = nfssvc_decode_void,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_void),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_NOCACHE,
@@ -651,7 +651,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_WRITE] = {
 		.pc_func = nfsd_proc_write,
 		.pc_decode = nfssvc_decode_writeargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
+		.pc_encode = nfssvc_encode_attrstat,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_writeargs),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
@@ -661,7 +661,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_CREATE] = {
 		.pc_func = nfsd_proc_create,
 		.pc_decode = nfssvc_decode_createargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
+		.pc_encode = nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
@@ -671,7 +671,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_REMOVE] = {
 		.pc_func = nfsd_proc_remove,
 		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_REPLSTAT,
@@ -680,7 +680,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_RENAME] = {
 		.pc_func = nfsd_proc_rename,
 		.pc_decode = nfssvc_decode_renameargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_renameargs),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_REPLSTAT,
@@ -689,7 +689,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_LINK] = {
 		.pc_func = nfsd_proc_link,
 		.pc_decode = nfssvc_decode_linkargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_linkargs),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_REPLSTAT,
@@ -698,7 +698,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_SYMLINK] = {
 		.pc_func = nfsd_proc_symlink,
 		.pc_decode = nfssvc_decode_symlinkargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_symlinkargs),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_REPLSTAT,
@@ -707,7 +707,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_MKDIR] = {
 		.pc_func = nfsd_proc_mkdir,
 		.pc_decode = nfssvc_decode_createargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
+		.pc_encode = nfssvc_encode_diropres,
 		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
@@ -717,7 +717,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_RMDIR] = {
 		.pc_func = nfsd_proc_rmdir,
 		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_void,
+		.pc_encode = nfssvc_encode_void,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_void),
 		.pc_cachetype = RC_REPLSTAT,
@@ -726,7 +726,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_READDIR] = {
 		.pc_func = nfsd_proc_readdir,
 		.pc_decode = nfssvc_decode_readdirargs,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_readdirres,
+		.pc_encode = nfssvc_encode_readdirres,
 		.pc_argsize = sizeof(struct nfsd_readdirargs),
 		.pc_ressize = sizeof(struct nfsd_readdirres),
 		.pc_cachetype = RC_NOCACHE,
@@ -734,7 +734,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 	[NFSPROC_STATFS] = {
 		.pc_func = nfsd_proc_statfs,
 		.pc_decode = nfssvc_decode_fhandle,
-		.pc_encode = (kxdrproc_t) nfssvc_encode_statfsres,
+		.pc_encode = nfssvc_encode_statfsres,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
 		.pc_ressize = sizeof(struct nfsd_statfsres),
 		.pc_cachetype = RC_NOCACHE,
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 3e00499d7ad7..555233664124 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -782,7 +782,6 @@ int
 nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 {
 	struct svc_procedure	*proc;
-	kxdrproc_t		xdr;
 	__be32			nfserr;
 	__be32			*nfserrp;
 
@@ -841,9 +840,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	 * For NFSv2, additional info is never returned in case of an error.
 	 */
 	if (!(nfserr && rqstp->rq_vers == 2)) {
-		xdr = proc->pc_encode;
-		if (xdr && !xdr(rqstp, nfserrp,
-				rqstp->rq_resp)) {
+		if (proc->pc_encode && !proc->pc_encode(rqstp, nfserrp)) {
 			/* Failed to encode result. Release cache entry */
 			dprintk("nfsd: failed to encode result!\n");
 			nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 0957ceebe1aa..bb1998c5ae61 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -429,32 +429,35 @@ nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
  * XDR encode functions
  */
 int
-nfssvc_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+nfssvc_encode_void(struct svc_rqst *rqstp, __be32 *p)
 {
 	return xdr_ressize_check(rqstp, p);
 }
 
 int
-nfssvc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_attrstat *resp)
+nfssvc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
+
 	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
 int
-nfssvc_encode_diropres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_diropres *resp)
+nfssvc_encode_diropres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_diropres *resp = rqstp->rq_resp;
+
 	p = encode_fh(p, &resp->fh);
 	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
 int
-nfssvc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_readlinkres *resp)
+nfssvc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readlinkres *resp = rqstp->rq_resp;
+
 	*p++ = htonl(resp->len);
 	xdr_ressize_check(rqstp, p);
 	rqstp->rq_res.page_len = resp->len;
@@ -468,9 +471,10 @@ nfssvc_encode_readlinkres(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_encode_readres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_readres *resp)
+nfssvc_encode_readres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readres *resp = rqstp->rq_resp;
+
 	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->count);
 	xdr_ressize_check(rqstp, p);
@@ -487,9 +491,10 @@ nfssvc_encode_readres(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_encode_readdirres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_readdirres *resp)
+nfssvc_encode_readdirres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_readdirres *resp = rqstp->rq_resp;
+
 	xdr_ressize_check(rqstp, p);
 	p = resp->buffer;
 	*p++ = 0;			/* no more entries */
@@ -500,9 +505,9 @@ nfssvc_encode_readdirres(struct svc_rqst *rqstp, __be32 *p,
 }
 
 int
-nfssvc_encode_statfsres(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_statfsres *resp)
+nfssvc_encode_statfsres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct nfsd_statfsres *resp = rqstp->rq_resp;
 	struct kstatfs	*stat = &resp->stats;
 
 	*p++ = htonl(NFSSVC_MAXBLKSIZE_V2);	/* max transfer size */
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 8eeb752cf6f8..457ce45e5084 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -143,13 +143,13 @@ int nfssvc_decode_readlinkargs(struct svc_rqst *, __be32 *);
 int nfssvc_decode_linkargs(struct svc_rqst *, __be32 *);
 int nfssvc_decode_symlinkargs(struct svc_rqst *, __be32 *);
 int nfssvc_decode_readdirargs(struct svc_rqst *, __be32 *);
-int nfssvc_encode_void(struct svc_rqst *, __be32 *, void *);
-int nfssvc_encode_attrstat(struct svc_rqst *, __be32 *, struct nfsd_attrstat *);
-int nfssvc_encode_diropres(struct svc_rqst *, __be32 *, struct nfsd_diropres *);
-int nfssvc_encode_readlinkres(struct svc_rqst *, __be32 *, struct nfsd_readlinkres *);
-int nfssvc_encode_readres(struct svc_rqst *, __be32 *, struct nfsd_readres *);
-int nfssvc_encode_statfsres(struct svc_rqst *, __be32 *, struct nfsd_statfsres *);
-int nfssvc_encode_readdirres(struct svc_rqst *, __be32 *, struct nfsd_readdirres *);
+int nfssvc_encode_void(struct svc_rqst *, __be32 *);
+int nfssvc_encode_attrstat(struct svc_rqst *, __be32 *);
+int nfssvc_encode_diropres(struct svc_rqst *, __be32 *);
+int nfssvc_encode_readlinkres(struct svc_rqst *, __be32 *);
+int nfssvc_encode_readres(struct svc_rqst *, __be32 *);
+int nfssvc_encode_statfsres(struct svc_rqst *, __be32 *);
+int nfssvc_encode_readdirres(struct svc_rqst *, __be32 *);
 
 int nfssvc_encode_entry(void *, const char *name,
 			int namlen, loff_t offset, u64 ino, unsigned int);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index f79be4c42e4a..80d7da620e91 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -285,35 +285,22 @@ int nfs3svc_decode_symlinkargs(struct svc_rqst *, __be32 *);
 int nfs3svc_decode_readdirargs(struct svc_rqst *, __be32 *);
 int nfs3svc_decode_readdirplusargs(struct svc_rqst *, __be32 *);
 int nfs3svc_decode_commitargs(struct svc_rqst *, __be32 *);
-int nfs3svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
-int nfs3svc_encode_attrstat(struct svc_rqst *, __be32 *,
-				struct nfsd3_attrstat *);
-int nfs3svc_encode_wccstat(struct svc_rqst *, __be32 *,
-				struct nfsd3_attrstat *);
-int nfs3svc_encode_diropres(struct svc_rqst *, __be32 *,
-				struct nfsd3_diropres *);
-int nfs3svc_encode_accessres(struct svc_rqst *, __be32 *,
-				struct nfsd3_accessres *);
-int nfs3svc_encode_readlinkres(struct svc_rqst *, __be32 *,
-				struct nfsd3_readlinkres *);
-int nfs3svc_encode_readres(struct svc_rqst *, __be32 *, struct nfsd3_readres *);
-int nfs3svc_encode_writeres(struct svc_rqst *, __be32 *, struct nfsd3_writeres *);
-int nfs3svc_encode_createres(struct svc_rqst *, __be32 *,
-				struct nfsd3_diropres *);
-int nfs3svc_encode_renameres(struct svc_rqst *, __be32 *,
-				struct nfsd3_renameres *);
-int nfs3svc_encode_linkres(struct svc_rqst *, __be32 *,
-				struct nfsd3_linkres *);
-int nfs3svc_encode_readdirres(struct svc_rqst *, __be32 *,
-				struct nfsd3_readdirres *);
-int nfs3svc_encode_fsstatres(struct svc_rqst *, __be32 *,
-				struct nfsd3_fsstatres *);
-int nfs3svc_encode_fsinfores(struct svc_rqst *, __be32 *,
-				struct nfsd3_fsinfores *);
-int nfs3svc_encode_pathconfres(struct svc_rqst *, __be32 *,
-				struct nfsd3_pathconfres *);
-int nfs3svc_encode_commitres(struct svc_rqst *, __be32 *,
-				struct nfsd3_commitres *);
+int nfs3svc_encode_voidres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_attrstat(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_wccstat(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_diropres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_accessres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_readlinkres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_readres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_writeres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_createres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_renameres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_linkres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_readdirres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_fsstatres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_fsinfores(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_pathconfres(struct svc_rqst *, __be32 *);
+int nfs3svc_encode_commitres(struct svc_rqst *, __be32 *);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
 void nfs3svc_release_fhandle2(struct svc_rqst *);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2a53c1233884..eb7f9239304f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -682,10 +682,9 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 
 
 bool nfsd4_mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp);
-int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
+int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *);
 int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *);
-int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
-		struct nfsd4_compoundres *);
+int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *);
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op);
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index 0416600844ce..7acbecc21a40 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -96,16 +96,16 @@ struct nlm_reboot {
 #define NLMSVC_XDRSIZE		sizeof(struct nlm_args)
 
 int	nlmsvc_decode_testargs(struct svc_rqst *, __be32 *);
-int	nlmsvc_encode_testres(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlmsvc_encode_testres(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_lockargs(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_cancargs(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_unlockargs(struct svc_rqst *, __be32 *);
-int	nlmsvc_encode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlmsvc_encode_res(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_res(struct svc_rqst *, __be32 *);
-int	nlmsvc_encode_void(struct svc_rqst *, __be32 *, void *);
+int	nlmsvc_encode_void(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_void(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_shareargs(struct svc_rqst *, __be32 *);
-int	nlmsvc_encode_shareres(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlmsvc_encode_shareres(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_notify(struct svc_rqst *, __be32 *);
 int	nlmsvc_decode_reboot(struct svc_rqst *, __be32 *);
 /*
diff --git a/include/linux/lockd/xdr4.h b/include/linux/lockd/xdr4.h
index 951bbe31fdb8..bf1645609225 100644
--- a/include/linux/lockd/xdr4.h
+++ b/include/linux/lockd/xdr4.h
@@ -24,16 +24,16 @@
 
 
 int	nlm4svc_decode_testargs(struct svc_rqst *, __be32 *);
-int	nlm4svc_encode_testres(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlm4svc_encode_testres(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_lockargs(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_cancargs(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_unlockargs(struct svc_rqst *, __be32 *);
-int	nlm4svc_encode_res(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlm4svc_encode_res(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_res(struct svc_rqst *, __be32 *);
-int	nlm4svc_encode_void(struct svc_rqst *, __be32 *, void *);
+int	nlm4svc_encode_void(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_void(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_shareargs(struct svc_rqst *, __be32 *);
-int	nlm4svc_encode_shareres(struct svc_rqst *, __be32 *, struct nlm_res *);
+int	nlm4svc_encode_shareres(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_notify(struct svc_rqst *, __be32 *);
 int	nlm4svc_decode_reboot(struct svc_rqst *, __be32 *);
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 047f04411dd4..6cfe41db7f31 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -423,7 +423,8 @@ struct svc_procedure {
 	__be32			(*pc_func)(struct svc_rqst *);
 	/* XDR decode args: */
 	int			(*pc_decode)(struct svc_rqst *, __be32 *data);
-	kxdrproc_t		pc_encode;	/* XDR encode result */
+	/* XDR encode result: */
+	int			(*pc_encode)(struct svc_rqst *, __be32 *data);
 	/* XDR free result: */
 	void			(*pc_release)(struct svc_rqst *);
 	unsigned int		pc_argsize;	/* argument struct size */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 18024c1b9b7b..aa643a29fdc6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1154,7 +1154,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	struct svc_version	*versp = NULL;	/* compiler food */
 	struct svc_procedure	*procp = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
-	kxdrproc_t		xdr;
 	__be32			*statp;
 	u32			prog, vers, proc;
 	__be32			auth_stat, rpc_stat;
@@ -1298,9 +1297,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 				procp->pc_release(rqstp);
 			goto err_bad_auth;
 		}
-		if (*statp == rpc_success &&
-		    (xdr = procp->pc_encode) &&
-		    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+		if (*statp == rpc_success && procp->pc_encode &&
+		    !procp->pc_encode(rqstp, resv->iov_base + resv->iov_len)) {
 			dprintk("svc: failed to encode reply\n");
 			/* serv->sv_stats->rpcsystemerr++; */
 			*statp = rpc_system_err;
-- 
2.11.0

