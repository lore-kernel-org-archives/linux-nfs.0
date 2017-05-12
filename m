Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39703 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932359AbdELQSR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:17 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 22/33] sunrpc: properly type pc_release callbacks
Date: Fri, 12 May 2017 18:16:50 +0200
Message-Id: <20170512161701.22468-23-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop the p and resp arguments as they are always NULL or can trivially
be derived from the rqstp argument.  With that all functions now have the
same prototype, and we can remove the unsafe casting to kxdrproc_t.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs2acl.c          | 22 +++++++++++-----------
 fs/nfsd/nfs3acl.c          |  8 ++++----
 fs/nfsd/nfs3proc.c         | 36 ++++++++++++++++++------------------
 fs/nfsd/nfs3xdr.c          | 16 ++++++++--------
 fs/nfsd/nfs4xdr.c          |  4 +---
 fs/nfsd/nfsproc.c          | 14 +++++++-------
 fs/nfsd/nfsxdr.c           |  8 ++++----
 fs/nfsd/xdr.h              |  2 +-
 fs/nfsd/xdr3.h             |  6 ++----
 fs/nfsd/xdr4.h             |  2 +-
 include/linux/sunrpc/svc.h |  3 ++-
 net/sunrpc/svc.c           |  8 ++++----
 12 files changed, 63 insertions(+), 66 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 4b7f84fa1fa5..302441027f50 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -318,27 +318,27 @@ static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
 /*
  * XDR release functions
  */
-static int nfsaclsvc_release_getacl(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclres *resp)
+static void nfsaclsvc_release_getacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh);
 	posix_acl_release(resp->acl_access);
 	posix_acl_release(resp->acl_default);
-	return 1;
 }
 
-static int nfsaclsvc_release_attrstat(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd_attrstat *resp)
+static void nfsaclsvc_release_attrstat(struct svc_rqst *rqstp)
 {
+	struct nfsd_attrstat *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh);
-	return 1;
 }
 
-static int nfsaclsvc_release_access(struct svc_rqst *rqstp, __be32 *p,
-               struct nfsd3_accessres *resp)
+static void nfsaclsvc_release_access(struct svc_rqst *rqstp)
 {
-       fh_put(&resp->fh);
-       return 1;
+	struct nfsd3_accessres *resp = rqstp->rq_resp;
+
+	fh_put(&resp->fh);
 }
 
 #define nfsaclsvc_decode_voidargs	NULL
@@ -353,7 +353,7 @@ struct nfsd3_voidargs { int dummy; };
 	.pc_func	= nfsacld_proc_##name,				\
 	.pc_decode	= (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
 	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
-	.pc_release	= (kxdrproc_t) nfsaclsvc_release_##relt,	\
+	.pc_release	= nfsaclsvc_release_##relt,	\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
 	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
 	.pc_cachetype	= cache,					\
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 5e42004035e0..56cdff4e954c 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -223,13 +223,13 @@ static int nfs3svc_encode_setaclres(struct svc_rqst *rqstp, __be32 *p,
 /*
  * XDR release functions
  */
-static int nfs3svc_release_getacl(struct svc_rqst *rqstp, __be32 *p,
-		struct nfsd3_getaclres *resp)
+static void nfs3svc_release_getacl(struct svc_rqst *rqstp)
 {
+	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh);
 	posix_acl_release(resp->acl_access);
 	posix_acl_release(resp->acl_default);
-	return 1;
 }
 
 #define nfs3svc_decode_voidargs		NULL
@@ -243,7 +243,7 @@ struct nfsd3_voidargs { int dummy; };
 	.pc_func	= nfsd3_proc_##name,				\
 	.pc_decode	= (kxdrproc_t) nfs3svc_decode_##argt##args,	\
 	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
-	.pc_release	= (kxdrproc_t) nfs3svc_release_##relt,		\
+	.pc_release	= nfs3svc_release_##relt,			\
 	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
 	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
 	.pc_cachetype	= cache,					\
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 4a2bae07cfbf..f0cccc0768ce 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -687,7 +687,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_getattr,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_fhandleargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_attrstatres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
 		.pc_ressize = sizeof(struct nfsd3_attrstatres),
 		.pc_cachetype = RC_NOCACHE,
@@ -697,7 +697,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_setattr,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_sattrargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -707,7 +707,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_lookup,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_diropres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_diropres),
 		.pc_cachetype = RC_NOCACHE,
@@ -717,7 +717,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_access,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_accessargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_accessres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_accessargs),
 		.pc_ressize = sizeof(struct nfsd3_accessres),
 		.pc_cachetype = RC_NOCACHE,
@@ -727,7 +727,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_readlink,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readlinkres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readlinkargs),
 		.pc_ressize = sizeof(struct nfsd3_readlinkres),
 		.pc_cachetype = RC_NOCACHE,
@@ -737,7 +737,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_read,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readargs),
 		.pc_ressize = sizeof(struct nfsd3_readres),
 		.pc_cachetype = RC_NOCACHE,
@@ -747,7 +747,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_write,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_writeres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_writeargs),
 		.pc_ressize = sizeof(struct nfsd3_writeres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -757,7 +757,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_create,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_createargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -767,7 +767,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_mkdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_mkdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mkdirargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -777,7 +777,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_symlink,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_symlinkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_symlinkargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -787,7 +787,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_mknod,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_mknodargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_createres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mknodargs),
 		.pc_ressize = sizeof(struct nfsd3_createres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -797,7 +797,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_remove,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -807,7 +807,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_rmdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_wccstatres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_diropargs),
 		.pc_ressize = sizeof(struct nfsd3_wccstatres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -817,7 +817,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_rename,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_renameargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_renameres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_renameargs),
 		.pc_ressize = sizeof(struct nfsd3_renameres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -827,7 +827,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_link,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_linkargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_linkres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle2,
+		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_linkargs),
 		.pc_ressize = sizeof(struct nfsd3_linkres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -837,7 +837,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_readdir,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirargs),
 		.pc_ressize = sizeof(struct nfsd3_readdirres),
 		.pc_cachetype = RC_NOCACHE,
@@ -846,7 +846,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_readdirplus,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_readdirplusargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_readdirres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_readdirplusargs),
 		.pc_ressize = sizeof(struct nfsd3_readdirres),
 		.pc_cachetype = RC_NOCACHE,
@@ -882,7 +882,7 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 		.pc_func = nfsd3_proc_commit,
 		.pc_decode = (kxdrproc_t) nfs3svc_decode_commitargs,
 		.pc_encode = (kxdrproc_t) nfs3svc_encode_commitres,
-		.pc_release = (kxdrproc_t) nfs3svc_release_fhandle,
+		.pc_release = nfs3svc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd3_commitargs),
 		.pc_ressize = sizeof(struct nfsd3_commitres),
 		.pc_cachetype = RC_NOCACHE,
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 12feac6ee2fd..7fd361a75287 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -1114,19 +1114,19 @@ nfs3svc_encode_commitres(struct svc_rqst *rqstp, __be32 *p,
 /*
  * XDR release functions
  */
-int
-nfs3svc_release_fhandle(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_attrstat *resp)
+void
+nfs3svc_release_fhandle(struct svc_rqst *rqstp)
 {
+	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh);
-	return 1;
 }
 
-int
-nfs3svc_release_fhandle2(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd3_fhandle_pair *resp)
+void
+nfs3svc_release_fhandle2(struct svc_rqst *rqstp)
 {
+	struct nfsd3_fhandle_pair *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh1);
 	fh_put(&resp->fh2);
-	return 1;
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 26780d53a6f9..5aa847bdfc63 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4543,9 +4543,8 @@ nfs4svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
         return xdr_ressize_check(rqstp, p);
 }
 
-int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
+void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 {
-	struct svc_rqst *rqstp = rq;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 
 	if (args->ops != args->iops) {
@@ -4559,7 +4558,6 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 		args->to_free = tb->next;
 		kfree(tb);
 	}
-	return 1;
 }
 
 int
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 448505b939db..dc32e0f8480d 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -587,7 +587,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_getattr,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_fhandle,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_fhandle),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
 		.pc_cachetype = RC_NOCACHE,
@@ -597,7 +597,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_setattr,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_sattrargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_sattrargs),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
 		.pc_cachetype = RC_REPLBUFF,
@@ -615,7 +615,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_lookup,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_diropargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_diropargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
 		.pc_cachetype = RC_NOCACHE,
@@ -634,7 +634,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_read,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_readargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_readres,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_readargs),
 		.pc_ressize = sizeof(struct nfsd_readres),
 		.pc_cachetype = RC_NOCACHE,
@@ -652,7 +652,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_write,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_writeargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_attrstat,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_writeargs),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
 		.pc_cachetype = RC_REPLBUFF,
@@ -662,7 +662,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_create,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
 		.pc_cachetype = RC_REPLBUFF,
@@ -708,7 +708,7 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 		.pc_func = nfsd_proc_mkdir,
 		.pc_decode = (kxdrproc_t) nfssvc_decode_createargs,
 		.pc_encode = (kxdrproc_t) nfssvc_encode_diropres,
-		.pc_release = (kxdrproc_t) nfssvc_release_fhandle,
+		.pc_release = nfssvc_release_fhandle,
 		.pc_argsize = sizeof(struct nfsd_createargs),
 		.pc_ressize = sizeof(struct nfsd_diropres),
 		.pc_cachetype = RC_REPLBUFF,
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 6a4947a3f4fa..de7b07ee489e 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -550,10 +550,10 @@ nfssvc_encode_entry(void *ccdv, const char *name,
 /*
  * XDR release functions
  */
-int
-nfssvc_release_fhandle(struct svc_rqst *rqstp, __be32 *p,
-					struct nfsd_fhandle *resp)
+void
+nfssvc_release_fhandle(struct svc_rqst *rqstp)
 {
+	struct nfsd_fhandle *resp = rqstp->rq_resp;
+
 	fh_put(&resp->fh);
-	return 1;
 }
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 4f0481d63804..2c21fa843fbf 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -164,7 +164,7 @@ int nfssvc_encode_readdirres(struct svc_rqst *, __be32 *, struct nfsd_readdirres
 int nfssvc_encode_entry(void *, const char *name,
 			int namlen, loff_t offset, u64 ino, unsigned int);
 
-int nfssvc_release_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
+void nfssvc_release_fhandle(struct svc_rqst *);
 
 /* Helper functions for NFSv2 ACL code */
 __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp, struct kstat *stat);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 335e04aaf7db..23fe456a223b 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -330,10 +330,8 @@ int nfs3svc_encode_pathconfres(struct svc_rqst *, __be32 *,
 int nfs3svc_encode_commitres(struct svc_rqst *, __be32 *,
 				struct nfsd3_commitres *);
 
-int nfs3svc_release_fhandle(struct svc_rqst *, __be32 *,
-				struct nfsd3_attrstat *);
-int nfs3svc_release_fhandle2(struct svc_rqst *, __be32 *,
-				struct nfsd3_fhandle_pair *);
+void nfs3svc_release_fhandle(struct svc_rqst *);
+void nfs3svc_release_fhandle2(struct svc_rqst *);
 int nfs3svc_encode_entry(void *, const char *name,
 				int namlen, loff_t offset, u64 ino,
 				unsigned int);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 8fda4abdf3b1..a158579d55a2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -743,7 +743,7 @@ extern __be32
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_release_lockowner *rlockowner);
-extern int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp);
+extern void nfsd4_release_compoundargs(struct svc_rqst *rqstp);
 extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
 extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5c222af2db41..1381e1343640 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -423,7 +423,8 @@ struct svc_procedure {
 	__be32			(*pc_func)(struct svc_rqst *);
 	kxdrproc_t		pc_decode;	/* XDR decode args */
 	kxdrproc_t		pc_encode;	/* XDR encode result */
-	kxdrproc_t		pc_release;	/* XDR free result */
+	/* XDR free result: */
+	void			(*pc_release)(struct svc_rqst *);
 	unsigned int		pc_argsize;	/* argument struct size */
 	unsigned int		pc_ressize;	/* result struct size */
 	unsigned int		pc_count;	/* call count */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 95335455ad38..4611cb7adc04 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1287,12 +1287,12 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		if (*statp == rpc_drop_reply ||
 		    test_bit(RQ_DROPME, &rqstp->rq_flags)) {
 			if (procp->pc_release)
-				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+				procp->pc_release(rqstp);
 			goto dropit;
 		}
 		if (*statp == rpc_autherr_badcred) {
 			if (procp->pc_release)
-				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+				procp->pc_release(rqstp);
 			goto err_bad_auth;
 		}
 		if (*statp == rpc_success &&
@@ -1307,7 +1307,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		if (!versp->vs_dispatch(rqstp, statp)) {
 			/* Release reply info */
 			if (procp->pc_release)
-				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+				procp->pc_release(rqstp);
 			goto dropit;
 		}
 	}
@@ -1318,7 +1318,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 
 	/* Release reply info */
 	if (procp->pc_release)
-		procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+		procp->pc_release(rqstp);
 
 	if (procp->pc_encode == NULL)
 		goto dropit;
-- 
2.11.0

