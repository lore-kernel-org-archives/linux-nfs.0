Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45679 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933025AbdELQSs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:48 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 32/33] sunrpc: mark all struct svc_version instances as const
Date: Fri, 12 May 2017 18:17:00 +0200
Message-Id: <20170512161701.22468-33-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/lockd/svc.c             | 38 +++++++++++++++++++-------------------
 fs/nfs/callback.c          |  2 +-
 fs/nfs/callback_xdr.c      |  4 ++--
 fs/nfs/internal.h          |  4 ++--
 fs/nfs/nfs4_fs.h           |  4 ++--
 fs/nfsd/nfs2acl.c          | 14 +++++++-------
 fs/nfsd/nfs3acl.c          | 14 +++++++-------
 fs/nfsd/nfs3proc.c         | 14 +++++++-------
 fs/nfsd/nfs4proc.c         |  2 +-
 fs/nfsd/nfsd.h             |  6 +++---
 fs/nfsd/nfsproc.c          | 14 +++++++-------
 fs/nfsd/nfssvc.c           |  8 ++++----
 include/linux/sunrpc/svc.h |  2 +-
 net/sunrpc/svc.c           |  4 ++--
 14 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index cc6abe6280bc..726b6cecf430 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -740,32 +740,32 @@ module_exit(exit_nlm);
  * Define NLM program and procedures
  */
 static unsigned int nlmsvc_version1_count[17];
-static struct svc_version	nlmsvc_version1 = {
-		.vs_vers	= 1,
-		.vs_nproc	= 17,
-		.vs_proc	= nlmsvc_procedures,
-		.vs_count	= nlmsvc_version1_count,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version	nlmsvc_version1 = {
+	.vs_vers	= 1,
+	.vs_nproc	= 17,
+	.vs_proc	= nlmsvc_procedures,
+	.vs_count	= nlmsvc_version1_count,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 static unsigned int nlmsvc_version3_count[24];
-static struct svc_version	nlmsvc_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 24,
-		.vs_proc	= nlmsvc_procedures,
-		.vs_count	= nlmsvc_version3_count,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version	nlmsvc_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 24,
+	.vs_proc	= nlmsvc_procedures,
+	.vs_count	= nlmsvc_version3_count,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
 static unsigned int nlmsvc_version4_count[24];
-static struct svc_version	nlmsvc_version4 = {
-		.vs_vers	= 4,
-		.vs_nproc	= 24,
-		.vs_proc	= nlmsvc_procedures4,
-		.vs_count	= nlmsvc_version4_count,
-		.vs_xdrsize	= NLMSVC_XDRSIZE,
+static const struct svc_version	nlmsvc_version4 = {
+	.vs_vers	= 4,
+	.vs_nproc	= 24,
+	.vs_proc	= nlmsvc_procedures4,
+	.vs_count	= nlmsvc_version4_count,
+	.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
-static struct svc_version *	nlmsvc_version[] = {
+static const struct svc_version *nlmsvc_version[] = {
 	[1] = &nlmsvc_version1,
 	[3] = &nlmsvc_version3,
 #ifdef CONFIG_LOCKD_V4
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 73a1f928226c..34323877ec13 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -439,7 +439,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 /*
  * Define NFS4 callback program
  */
-static struct svc_version *nfs4_callback_version[] = {
+static const struct svc_version *nfs4_callback_version[] = {
 	[1] = &nfs4_callback_version1,
 	[4] = &nfs4_callback_version4,
 };
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index ae249f27297f..01a430e51daa 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -1012,7 +1012,7 @@ static const struct svc_procedure nfs4_callback_procedures1[] = {
 };
 
 static unsigned int nfs4_callback_count1[ARRAY_SIZE(nfs4_callback_procedures1)];
-struct svc_version nfs4_callback_version1 = {
+const struct svc_version nfs4_callback_version1 = {
 	.vs_vers = 1,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
@@ -1024,7 +1024,7 @@ struct svc_version nfs4_callback_version1 = {
 };
 
 static unsigned int nfs4_callback_count4[ARRAY_SIZE(nfs4_callback_procedures1)];
-struct svc_version nfs4_callback_version4 = {
+const struct svc_version nfs4_callback_version4 = {
 	.vs_vers = 4,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c21254924389..9976d8498cf3 100644
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
index c3f6b8a6b659..6276ec8608b0 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -379,11 +379,11 @@ static const struct svc_procedure nfsd_acl_procedures2[] = {
 };
 
 static unsigned int nfsd_acl_count2[ARRAY_SIZE(nfsd_acl_procedures2)];
-struct svc_version	nfsd_acl_version2 = {
-		.vs_vers	= 2,
-		.vs_nproc	= 5,
-		.vs_proc	= nfsd_acl_procedures2,
-		.vs_count	= nfsd_acl_count2,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_acl_version2 = {
+	.vs_vers	= 2,
+	.vs_nproc	= 5,
+	.vs_proc	= nfsd_acl_procedures2,
+	.vs_count	= nfsd_acl_count2,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 1a482ac9d4e9..01976529f042 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -264,12 +264,12 @@ static const struct svc_procedure nfsd_acl_procedures3[] = {
 };
 
 static unsigned int nfsd_acl_count3[ARRAY_SIZE(nfsd_acl_procedures3)];
-struct svc_version	nfsd_acl_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 3,
-		.vs_proc	= nfsd_acl_procedures3,
-		.vs_count	= nfsd_acl_count3,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_acl_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 3,
+	.vs_proc	= nfsd_acl_procedures3,
+	.vs_count	= nfsd_acl_count3,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 96e0e6a2af51..2cb56a0d6625 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -891,11 +891,11 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 };
 
 static unsigned int nfsd_count3[ARRAY_SIZE(nfsd_procedures3)];
-struct svc_version	nfsd_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 22,
-		.vs_proc	= nfsd_procedures3,
-		.vs_count	= nfsd_count3,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+const struct svc_version nfsd_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 22,
+	.vs_proc	= nfsd_procedures3,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_count	= nfsd_count3,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a4d8aa3abc63..e814c1946f6e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2555,7 +2555,7 @@ static const struct svc_procedure nfsd_procedures4[2] = {
 };
 
 static unsigned int nfsd_count3[ARRAY_SIZE(nfsd_procedures4)];
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
index a68b686fda12..5076ae2b8258 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -744,13 +744,13 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 
 
 static unsigned int nfsd_count2[ARRAY_SIZE(nfsd_procedures2)];
-struct svc_version	nfsd_version2 = {
-		.vs_vers	= 2,
-		.vs_nproc	= 18,
-		.vs_proc	= nfsd_procedures2,
-		.vs_count	= nfsd_count2,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS2_SVC_XDRSIZE,
+const struct svc_version nfsd_version2 = {
+	.vs_vers	= 2,
+	.vs_nproc	= 18,
+	.vs_proc	= nfsd_procedures2,
+	.vs_count	= nfsd_count2,
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
index 984e6b9c3043..e85267899753 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -383,7 +383,7 @@ struct svc_program {
 	unsigned int		pg_lovers;	/* lowest version */
 	unsigned int		pg_hivers;	/* highest version */
 	unsigned int		pg_nvers;	/* number of versions */
-	struct svc_version **	pg_vers;	/* version array */
+	const struct svc_version **pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 049963d676a7..45b4f2d2e3bd 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1008,7 +1008,7 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		 const unsigned short port)
 {
 	struct svc_program	*progp;
-	struct svc_version	*vers;
+	const struct svc_version *vers;
 	unsigned int		i;
 	int			error = 0;
 
@@ -1151,7 +1151,7 @@ static int
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

