From: Greg Banks <gnb@sgi.com>
Subject: [patch 25/29] knfsd: allocate svc_serv.sv_stats dynamically
Date: Wed, 01 Apr 2009 07:28:25 +1100
Message-ID: <20090331202947.245344000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22591 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762690AbZCaVCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove some more anachronisms from the days when each svc_serv could
only handle a single svc_program.

One sv_serv statistics structure was pointed to by svc_serv.sv_stats
and updated as calls flowed.  However, a statically allocated svc_stat
was also pointed to by each svc_program.pg_stats, and the svc_serv
would take over the svc_stat of the first svc_program added to it,
ignoring the others.

This patch removes the svc_program.pg_stats field and the statically
allocated svc_stat structures.  A single svc_stat structure is
allocated dynamically when the svc_serv starts.

This is a preliminary step towards making the NFS server statistics
be gathered per-CPU.

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 fs/lockd/svc.c             |    6 ------
 fs/nfs/callback.c          |    3 ---
 fs/nfsd/nfssvc.c           |    4 ----
 fs/nfsd/stats.c            |    1 -
 include/linux/nfsd/stats.h |    1 -
 include/linux/sunrpc/svc.h |    1 -
 net/sunrpc/svc.c           |    9 ++++++++-
 7 files changed, 8 insertions(+), 17 deletions(-)

Index: bfields/fs/lockd/svc.c
===================================================================
--- bfields.orig/fs/lockd/svc.c
+++ bfields/fs/lockd/svc.c
@@ -569,8 +569,6 @@ static struct svc_version *	nlmsvc_versi
 #endif
 };
 
-static struct svc_stat		nlmsvc_stats;
-
 #define NLM_NRVERS	ARRAY_SIZE(nlmsvc_version)
 static struct svc_program	nlmsvc_program = {
 	.pg_prog		= NLM_PROGRAM,		/* program number */
@@ -578,6 +576,5 @@ static struct svc_program	nlmsvc_program
 	.pg_vers		= nlmsvc_version,	/* version table */
 	.pg_name		= "lockd",		/* service name */
 	.pg_class		= "nfsd",		/* share authentication with nfsd */
-	.pg_stats		= &nlmsvc_stats,	/* stats table */
 	.pg_authenticate = &lockd_authenticate	/* export authentication */
 };
Index: bfields/fs/nfs/callback.c
===================================================================
--- bfields.orig/fs/nfs/callback.c
+++ bfields/fs/nfs/callback.c
@@ -245,14 +245,11 @@ static struct svc_version *nfs4_callback
 	[1] = &nfs4_callback_version1,
 };
 
-static struct svc_stat nfs4_callback_stats;
-
 static struct svc_program nfs4_callback_program = {
 	.pg_prog = NFS4_CALLBACK,			/* RPC service number */
 	.pg_nvers = ARRAY_SIZE(nfs4_callback_version),	/* Number of entries */
 	.pg_vers = nfs4_callback_version,		/* version table */
 	.pg_name = "NFSv4 callback",			/* service name */
 	.pg_class = "nfs",				/* authentication class */
-	.pg_stats = &nfs4_callback_stats,
 	.pg_authenticate = nfs_callback_authenticate,
 };
Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -56,7 +56,6 @@ static inline void nfsd_stats_prefetch(n
 
 
 struct nfsd_stats	nfsdstats;
-struct svc_stat		nfsd_svcstats;
 
 nfsd_stats_hash_t nfsd_export_stats_hash;
 nfsd_stats_hash_t nfsd_client_stats_hash;
Index: bfields/fs/nfsd/nfssvc.c
===================================================================
--- bfields.orig/fs/nfsd/nfssvc.c
+++ bfields/fs/nfsd/nfssvc.c
@@ -68,7 +68,6 @@ DEFINE_MUTEX(nfsd_mutex);
 struct svc_serv 		*nfsd_serv;
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
 	[2] = &nfsd_acl_version2,
 	[3] = &nfsd_acl_version3,
@@ -84,11 +83,9 @@ static struct svc_program	nfsd_acl_progr
 	.pg_vers		= nfsd_acl_versions,
 	.pg_name		= "nfsacl",
 	.pg_class		= "nfsd",
-	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
 };
 
-static struct svc_stat	nfsd_acl_svcstats;
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
 
 static struct svc_version *	nfsd_version[] = {
@@ -114,7 +111,6 @@ struct svc_program		nfsd_program = {
 	.pg_vers		= nfsd_versions,	/* version table */
 	.pg_name		= "nfsd",		/* program name */
 	.pg_class		= "nfsd",		/* authentication class */
-	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
 
 };
Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -375,7 +375,6 @@ struct svc_program {
 	struct svc_version **	pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
 	char *			pg_class;	/* class name: services sharing authentication */
-	struct svc_stat *	pg_stats;	/* rpc statistics */
 	int			(*pg_authenticate)(struct svc_rqst *);
 };
 
Index: bfields/net/sunrpc/svc.c
===================================================================
--- bfields.orig/net/sunrpc/svc.c
+++ bfields/net/sunrpc/svc.c
@@ -371,7 +371,6 @@ __svc_create(struct svc_program *prog, u
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
-	serv->sv_stats     = prog->pg_stats;
 	if (bufsize > RPCSVC_MAXPAYLOAD)
 		bufsize = RPCSVC_MAXPAYLOAD;
 	serv->sv_max_payload = bufsize? bufsize : 4096;
@@ -396,11 +395,18 @@ __svc_create(struct svc_program *prog, u
 	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
+	serv->sv_stats = kzalloc(sizeof(struct svc_stat), GFP_KERNEL);
+	if (!serv->sv_stats) {
+		kfree(serv);
+		return NULL;
+	}
+
 	serv->sv_nrpools = npools;
 	serv->sv_pools =
 		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
 			GFP_KERNEL);
 	if (!serv->sv_pools) {
+		kfree(serv->sv_stats);
 		kfree(serv);
 		return NULL;
 	}
@@ -489,6 +495,7 @@ svc_destroy(struct svc_serv *serv)
 
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
+	kfree(serv->sv_stats);
 	kfree(serv);
 }
 EXPORT_SYMBOL_GPL(svc_destroy);
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -142,7 +142,6 @@ struct nfsd_stats_hiter {
 
 
 extern struct nfsd_stats	nfsdstats;
-extern struct svc_stat		nfsd_svcstats;
 extern nfsd_stats_hash_t	nfsd_export_stats_hash;
 extern nfsd_stats_hash_t	nfsd_client_stats_hash;
 

--
Greg
