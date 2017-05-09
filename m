Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52890 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753025AbdEIJVD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:03 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 18/32] nfsd: use named initializers in PROC()
Date: Tue,  9 May 2017 11:19:56 +0200
Message-Id: <20170509092010.30752-19-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs2acl.c  | 22 +++++++++++-----------
 fs/nfsd/nfs3acl.c  | 22 +++++++++++-----------
 fs/nfsd/nfs4proc.c | 10 +++++-----
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 838f90f3f890..12933d07204c 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -345,17 +345,17 @@ static int nfsaclsvc_release_access(struct svc_rqst *rqstp, __be32 *p,
 #define nfsd3_voidres		nfsd3_voidargs
 struct nfsd3_voidargs { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
- { (svc_procfunc) nfsacld_proc_##name,		\
-   (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
-   (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
-   (kxdrproc_t) nfsaclsvc_release_##relt,		\
-   sizeof(struct nfsd3_##argt##args),		\
-   sizeof(struct nfsd3_##rest##res),		\
-   0,						\
-   cache,					\
-   respsize,					\
- }
+#define PROC(name, argt, rest, relt, cache, respsize)			\
+{									\
+	.pc_func	= (svc_procfunc) nfsacld_proc_##name,		\
+	.pc_decode	= (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
+	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
+	.pc_release	= (kxdrproc_t) nfsaclsvc_release_##relt,	\
+	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
+	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
+	.pc_cachetype	= cache,					\
+	.pc_xdrressize	= respsize,					\
+}
 
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index dcb5f79076c0..db988a229b3a 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -237,17 +237,17 @@ static int nfs3svc_release_getacl(struct svc_rqst *rqstp, __be32 *p,
 #define nfsd3_voidres			nfsd3_voidargs
 struct nfsd3_voidargs { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
- { (svc_procfunc) nfsd3_proc_##name,		\
-   (kxdrproc_t) nfs3svc_decode_##argt##args,	\
-   (kxdrproc_t) nfs3svc_encode_##rest##res,	\
-   (kxdrproc_t) nfs3svc_release_##relt,		\
-   sizeof(struct nfsd3_##argt##args),		\
-   sizeof(struct nfsd3_##rest##res),		\
-   0,						\
-   cache,					\
-   respsize,					\
- }
+#define PROC(name, argt, rest, relt, cache, respsize)			\
+{									\
+	.pc_func	= (svc_procfunc) nfsd3_proc_##name,		\
+	.pc_decode	= (kxdrproc_t) nfs3svc_decode_##argt##args,	\
+	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
+	.pc_release	= (kxdrproc_t) nfs3svc_release_##relt,		\
+	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
+	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
+	.pc_cachetype	= cache,					\
+	.pc_xdrressize	= respsize,					\
+}
 
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d86031b6ad79..2a7bf4fb81bd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1672,10 +1672,10 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
  * COMPOUND call.
  */
 static __be32
-nfsd4_proc_compound(struct svc_rqst *rqstp,
-		    struct nfsd4_compoundargs *args,
-		    struct nfsd4_compoundres *resp)
+nfsd4_proc_compound(struct svc_rqst *rqstp, void *arg, void *res)
 {
+	struct nfsd4_compoundargs *args = arg;
+	struct nfsd4_compoundres *resp = res;
 	struct nfsd4_op	*op;
 	struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
@@ -2517,7 +2517,7 @@ struct nfsd4_voidargs { int dummy; };
 
 static struct svc_procedure		nfsd_procedures4[2] = {
 	[NFSPROC4_NULL] = {
-		.pc_func = (svc_procfunc) nfsd4_proc_null,
+		.pc_func = nfsd4_proc_null,
 		.pc_encode = (kxdrproc_t) nfs4svc_encode_voidres,
 		.pc_argsize = sizeof(struct nfsd4_voidargs),
 		.pc_ressize = sizeof(struct nfsd4_voidres),
@@ -2525,7 +2525,7 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 		.pc_xdrressize = 1,
 	},
 	[NFSPROC4_COMPOUND] = {
-		.pc_func = (svc_procfunc) nfsd4_proc_compound,
+		.pc_func = nfsd4_proc_compound,
 		.pc_decode = (kxdrproc_t) nfs4svc_decode_compoundargs,
 		.pc_encode = (kxdrproc_t) nfs4svc_encode_compoundres,
 		.pc_argsize = sizeof(struct nfsd4_compoundargs),
-- 
2.11.0

