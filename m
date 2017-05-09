Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:59318 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753210AbdEIJVl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:41 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 31/32] sunrpc: mark all struct svc_version instances as const
Date: Tue,  9 May 2017 11:20:09 +0200
Message-Id: <20170509092010.30752-32-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/svc.c             | 32 ++++++++++++++++----------------
 fs/nfs/callback.c          |  2 +-
 fs/nfs/callback_xdr.c      |  4 ++--
 fs/nfs/internal.h          |  4 ++--
 fs/nfs/nfs4_fs.h           |  4 ++--
 fs/nfsd/nfs2acl.c          | 12 ++++++------
 fs/nfsd/nfs3acl.c          | 12 ++++++------
 fs/nfsd/nfs3proc.c         | 12 ++++++------
 fs/nfsd/nfs4proc.c         |  2 +-
 fs/nfsd/nfsd.h             |  6 +++---
 fs/nfsd/nfsproc.c          | 12 ++++++------
 fs/nfsd/nfssvc.c           |  8 ++++----
 include/linux/sunrpc/svc.h |  2 +-
 net/sunrpc/svc.c           |  4 ++--
 14 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index e7c8b9c76e48..448f326fb8ec 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -737,27 +737,27 @@ module_exit(exit_nlm);
 /*
  * Define NLM program and procedures
  */
-static struct svc_version	nlmsvc_version1 = {
-		.vs_vers	= 1,
-		.vs_nproc	= 17,
-		.vs_proc	= nlmsvc_procedures,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version nlmsvc_version1 = {
+	.vs_vers	= 1,
+	.vs_nproc	= 17,
+	.vs_proc	= nlmsvc_procedures,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
-static struct svc_version	nlmsvc_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 24,
-		.vs_proc	= nlmsvc_procedures,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version nlmsvc_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 24,
+	.vs_proc	= nlmsvc_procedures,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
-static struct svc_version	nlmsvc_version4 = {
-		.vs_vers	= 4,
-		.vs_nproc	= 24,
-		.vs_proc	= nlmsvc_procedures4,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version nlmsvc_version4 = {
+	.vs_vers	= 4,
+	.vs_nproc	= 24,
+	.vs_proc	= nlmsvc_procedures4,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
-static struct svc_version *	nlmsvc_version[] = {
+static const struct svc_version *nlmsvc_version[] = {
 	[1] = &nlmsvc_version1,
 	[3] = &nlmsvc_version3,
 #ifdef CONFIG_LOCKD_V4
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 773774531aff..e8bd5d7b229d 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -431,7 +431,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 /*
  * Define NFS4 callback program
  */
-static struct svc_version *nfs4_callback_version[] = {
+static const struct svc_version *nfs4_callback_version[] = {
 	[1] = &nfs4_callback_version1,
 	[4] = &nfs4_callback_version4,
 };
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 6753bbc6a70a..04313b7670e6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -1066,7 +1066,7 @@ static const struct svc_procedure nfs4_callback_procedures1[] = {
 	}
 };
 
-struct svc_version nfs4_callback_version1 = {
+const struct svc_version nfs4_callback_version1 = {
 	.vs_vers = 1,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
@@ -1076,7 +1076,7 @@ struct svc_version nfs4_callback_version1 = {
 	.vs_need_cong_ctrl = true,
 };
 
-struct svc_version nfs4_callback_version4 = {
+const struct svc_version nfs4_callback_version4 = {
 	.vs_vers = 4,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 76d0f5e993ba..89eecd146da3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -225,8 +225,8 @@ static inline void nfs_fs_proc_exit(void)
 #endif
 
 /* callback_xdr.c */
-extern struct svc_version nfs4_callback_version1;
-extern struct svc_version nfs4_callback_version4;
+extern const struct svc_version nfs4_callback_version1;
+extern const struct svc_version nfs4_callback_version4;
 
 struct nfs_pageio_descriptor;
 /* pagelist.c */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9b0cf3872722..40bd05f05e74 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -498,8 +498,8 @@ extern const struct rpc_procinfo nfs4_procedures[];
 struct nfs4_mount_data;
 
 /* callback_xdr.c */
-extern struct svc_version nfs4_callback_version1;
-extern struct svc_version nfs4_callback_version4;
+extern const struct svc_version nfs4_callback_version1;
+extern const struct svc_version nfs4_callback_version4;
 
 static inline void nfs4_stateid_copy(nfs4_stateid *dst, const nfs4_stateid *src)
 {
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 95c5804be5ed..0faa9c05d491 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -378,10 +378,10 @@ static const struct svc_procedure nfsd_acl_procedures2[] = {
   PROC(access,	access,		access,		access,   RC_NOCACHE, ST+AT+1),
 };
 
-struct svc_version	nfsd_acl_version2 = {
-		.vs_vers	= 2,
-		.vs_nproc	= 5,
-		.vs_proc	= nfsd_acl_procedures2,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_acl_version2 = {
+	.vs_vers	= 2,
+	.vs_nproc	= 5,
+	.vs_proc	= nfsd_acl_procedures2,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 10be7c58d1d3..47ea93e90447 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -263,11 +263,11 @@ static const struct svc_procedure nfsd_acl_procedures3[] = {
   PROC(setacl,	setacl,		setacl,		fhandle,  RC_NOCACHE, ST+pAT),
 };
 
-struct svc_version	nfsd_acl_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 3,
-		.vs_proc	= nfsd_acl_procedures3,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_acl_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 3,
+	.vs_proc	= nfsd_acl_procedures3,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index df636d30f18a..58245aaac329 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -890,10 +890,10 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 	},
 };
 
-struct svc_version	nfsd_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 22,
-		.vs_proc	= nfsd_procedures3,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 22,
+	.vs_proc	= nfsd_procedures3,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4e406bc1cb24..f52130a94d8d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2553,7 +2553,7 @@ static const struct svc_procedure nfsd_procedures4[2] = {
 	},
 };
 
-struct svc_version	nfsd_version4 = {
+const struct svc_version nfsd_version4 = {
 	.vs_vers		= 4,
 	.vs_nproc		= 2,
 	.vs_proc		= nfsd_procedures4,
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d96606801d47..b9c538ab7a59 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -60,7 +60,7 @@ struct readdir_cd {
 
 
 extern struct svc_program	nfsd_program;
-extern struct svc_version	nfsd_version2, nfsd_version3,
+extern const struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
 extern struct mutex		nfsd_mutex;
 extern spinlock_t		nfsd_drc_lock;
@@ -86,12 +86,12 @@ void		nfsd_destroy(struct net *net);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
-extern struct svc_version nfsd_acl_version2;
+extern const struct svc_version nfsd_acl_version2;
 #else
 #define nfsd_acl_version2 NULL
 #endif
 #ifdef CONFIG_NFSD_V3_ACL
-extern struct svc_version nfsd_acl_version3;
+extern const struct svc_version nfsd_acl_version3;
 #else
 #define nfsd_acl_version3 NULL
 #endif
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 900acf05f962..200d76685e90 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -743,12 +743,12 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 };
 
 
-struct svc_version	nfsd_version2 = {
-		.vs_vers	= 2,
-		.vs_nproc	= 18,
-		.vs_proc	= nfsd_procedures2,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS2_SVC_XDRSIZE,
+const struct svc_version nfsd_version2 = {
+	.vs_vers	= 2,
+	.vs_nproc	= 18,
+	.vs_proc	= nfsd_procedures2,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS2_SVC_XDRSIZE,
 };
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 379b310c445d..063ae7de2c12 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -68,14 +68,14 @@ unsigned long	nfsd_drc_mem_used;
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
-static struct svc_version *	nfsd_acl_version[] = {
+static const struct svc_version *nfsd_acl_version[] = {
 	[2] = &nfsd_acl_version2,
 	[3] = &nfsd_acl_version3,
 };
 
 #define NFSD_ACL_MINVERS            2
 #define NFSD_ACL_NRVERS		ARRAY_SIZE(nfsd_acl_version)
-static struct svc_version *nfsd_acl_versions[NFSD_ACL_NRVERS];
+static const struct svc_version *nfsd_acl_versions[NFSD_ACL_NRVERS];
 
 static struct svc_program	nfsd_acl_program = {
 	.pg_prog		= NFS_ACL_PROGRAM,
@@ -92,7 +92,7 @@ static struct svc_stat	nfsd_acl_svcstats = {
 };
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
 
-static struct svc_version *	nfsd_version[] = {
+static const struct svc_version *nfsd_version[] = {
 	[2] = &nfsd_version2,
 #if defined(CONFIG_NFSD_V3)
 	[3] = &nfsd_version3,
@@ -104,7 +104,7 @@ static struct svc_version *	nfsd_version[] = {
 
 #define NFSD_MINVERS    	2
 #define NFSD_NRVERS		ARRAY_SIZE(nfsd_version)
-static struct svc_version *nfsd_versions[NFSD_NRVERS];
+static const struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6c4637621ca5..76dfc1d023b6 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -384,7 +384,7 @@ struct svc_program {
 	unsigned int		pg_lovers;	/* lowest version */
 	unsigned int		pg_hivers;	/* highest version */
 	unsigned int		pg_nvers;	/* number of versions */
-	struct svc_version **	pg_vers;	/* version array */
+	const struct svc_version **pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4a3ec1a55110..1dda932b4124 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -950,7 +950,7 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		 const unsigned short port)
 {
 	struct svc_program	*progp;
-	struct svc_version	*vers;
+	const struct svc_version *vers;
 	unsigned int		i;
 	int			error = 0;
 
@@ -1093,7 +1093,7 @@ static int
 svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 {
 	struct svc_program	*progp;
-	struct svc_version	*versp = NULL;	/* compiler food */
+	const struct svc_version *versp = NULL;	/* compiler food */
 	const struct svc_procedure *procp = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
 	__be32			*statp;
-- 
2.11.0

