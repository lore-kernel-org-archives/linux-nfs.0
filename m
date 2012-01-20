Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3888 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab2ATUM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 15:12:26 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] SUNRPC: constify the rpc_program
Date: Fri, 20 Jan 2012 15:12:18 -0500
Message-Id: <1327090338-6496-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1327090338-6496-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1327090338-6496-1-git-send-email-Trond.Myklebust@netapp.com>
 <1327090338-6496-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/clnt4xdr.c          |    2 +-
 fs/lockd/clntxdr.c           |    8 ++++----
 fs/lockd/mon.c               |    8 ++++----
 fs/nfs/client.c              |    8 ++++----
 fs/nfs/internal.h            |    2 +-
 fs/nfs/mount_clnt.c          |   10 +++++-----
 fs/nfs/nfs2xdr.c             |    2 +-
 fs/nfs/nfs3xdr.c             |    4 ++--
 fs/nfs/nfs4xdr.c             |    2 +-
 fs/nfsd/nfs4callback.c       |    6 +++---
 include/linux/lockd/lockd.h  |    2 +-
 include/linux/lockd/xdr4.h   |    2 +-
 include/linux/nfs_xdr.h      |   10 +++++-----
 include/linux/sunrpc/clnt.h  |    8 ++++----
 include/linux/sunrpc/stats.h |    6 +++---
 net/sunrpc/clnt.c            |    8 ++++----
 net/sunrpc/rpcb_clnt.c       |   20 ++++++++++----------
 17 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index f848b52..3ddcbb1 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -598,7 +598,7 @@ static struct rpc_procinfo	nlm4_procedures[] = {
 	PROC(GRANTED_RES,	res,		norep),
 };
 
-struct rpc_version	nlm_version4 = {
+const struct rpc_version nlm_version4 = {
 	.number		= 4,
 	.nrprocs	= ARRAY_SIZE(nlm4_procedures),
 	.procs		= nlm4_procedures,
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 180ac34..3d35e3e 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -596,19 +596,19 @@ static struct rpc_procinfo	nlm_procedures[] = {
 	PROC(GRANTED_RES,	res,		norep),
 };
 
-static struct rpc_version	nlm_version1 = {
+static const struct rpc_version	nlm_version1 = {
 		.number		= 1,
 		.nrprocs	= ARRAY_SIZE(nlm_procedures),
 		.procs		= nlm_procedures,
 };
 
-static struct rpc_version	nlm_version3 = {
+static const struct rpc_version	nlm_version3 = {
 		.number		= 3,
 		.nrprocs	= ARRAY_SIZE(nlm_procedures),
 		.procs		= nlm_procedures,
 };
 
-static struct rpc_version	*nlm_versions[] = {
+static const struct rpc_version	*nlm_versions[] = {
 	[1] = &nlm_version1,
 	[3] = &nlm_version3,
 #ifdef CONFIG_LOCKD_V4
@@ -618,7 +618,7 @@ static struct rpc_version	*nlm_versions[] = {
 
 static struct rpc_stat		nlm_rpc_stats;
 
-struct rpc_program		nlm_program = {
+const struct rpc_program	nlm_program = {
 		.name		= "lockd",
 		.number		= NLM_PROGRAM,
 		.nrvers		= ARRAY_SIZE(nlm_versions),
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 65ba36b..c196030 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -47,7 +47,7 @@ struct nsm_res {
 	u32			state;
 };
 
-static struct rpc_program	nsm_program;
+static const struct rpc_program	nsm_program;
 static				LIST_HEAD(nsm_handles);
 static				DEFINE_SPINLOCK(nsm_lock);
 
@@ -534,19 +534,19 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 };
 
-static struct rpc_version	nsm_version1 = {
+static const struct rpc_version nsm_version1 = {
 		.number		= 1,
 		.nrprocs	= ARRAY_SIZE(nsm_procedures),
 		.procs		= nsm_procedures
 };
 
-static struct rpc_version *	nsm_version[] = {
+static const struct rpc_version *nsm_version[] = {
 	[1] = &nsm_version1,
 };
 
 static struct rpc_stat		nsm_stats;
 
-static struct rpc_program	nsm_program = {
+static const struct rpc_program nsm_program = {
 		.name		= "statd",
 		.number		= NSM_PROGRAM,
 		.nrvers		= ARRAY_SIZE(nsm_version),
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 34c8d1c..98af1cb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -89,7 +89,7 @@ static bool nfs4_disable_idmapping = true;
 /*
  * RPC cruft for NFS
  */
-static struct rpc_version *nfs_version[5] = {
+static const struct rpc_version *nfs_version[5] = {
 	[2]			= &nfs_version2,
 #ifdef CONFIG_NFS_V3
 	[3]			= &nfs_version3,
@@ -99,7 +99,7 @@ static struct rpc_version *nfs_version[5] = {
 #endif
 };
 
-struct rpc_program nfs_program = {
+const struct rpc_program nfs_program = {
 	.name			= "nfs",
 	.number			= NFS_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfs_version),
@@ -115,11 +115,11 @@ struct rpc_stat nfs_rpcstat = {
 
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static struct rpc_version *	nfsacl_version[] = {
+static const struct rpc_version *nfsacl_version[] = {
 	[3]			= &nfsacl_version3,
 };
 
-struct rpc_program		nfsacl_program = {
+const struct rpc_program nfsacl_program = {
 	.name			= "nfsacl",
 	.number			= NFS_ACL_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfsacl_version),
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index eda4cde4..cdb121d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -145,7 +145,7 @@ extern int nfs_mount(struct nfs_mount_request *info);
 extern void nfs_umount(const struct nfs_mount_request *info);
 
 /* client.c */
-extern struct rpc_program nfs_program;
+extern const struct rpc_program nfs_program;
 
 extern void nfs_cleanup_cb_ident_idr(void);
 extern void nfs_put_client(struct nfs_client *);
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 4fbe3a8..b37ca34 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -67,7 +67,7 @@ enum {
 	MOUNTPROC3_EXPORT	= 5,
 };
 
-static struct rpc_program	mnt_program;
+static const struct rpc_program mnt_program;
 
 /*
  * Defined by OpenGroup XNFS Version 3W, chapter 8
@@ -488,19 +488,19 @@ static struct rpc_procinfo mnt3_procedures[] = {
 };
 
 
-static struct rpc_version mnt_version1 = {
+static const struct rpc_version mnt_version1 = {
 	.number		= 1,
 	.nrprocs	= ARRAY_SIZE(mnt_procedures),
 	.procs		= mnt_procedures,
 };
 
-static struct rpc_version mnt_version3 = {
+static const struct rpc_version mnt_version3 = {
 	.number		= 3,
 	.nrprocs	= ARRAY_SIZE(mnt3_procedures),
 	.procs		= mnt3_procedures,
 };
 
-static struct rpc_version *mnt_version[] = {
+static const struct rpc_version *mnt_version[] = {
 	NULL,
 	&mnt_version1,
 	NULL,
@@ -509,7 +509,7 @@ static struct rpc_version *mnt_version[] = {
 
 static struct rpc_stat mnt_stats;
 
-static struct rpc_program mnt_program = {
+static const struct rpc_program mnt_program = {
 	.name		= "mount",
 	.number		= NFS_MNT_PROGRAM,
 	.nrvers		= ARRAY_SIZE(mnt_version),
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 792cb13..1f56000 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1150,7 +1150,7 @@ struct rpc_procinfo	nfs_procedures[] = {
 	PROC(STATFS,	fhandle,	statfsres,	0),
 };
 
-struct rpc_version		nfs_version2 = {
+const struct rpc_version nfs_version2 = {
 	.number			= 2,
 	.nrprocs		= ARRAY_SIZE(nfs_procedures),
 	.procs			= nfs_procedures
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 183c6b1..a77cc9a 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2461,7 +2461,7 @@ struct rpc_procinfo	nfs3_procedures[] = {
 	PROC(COMMIT,		commit,		commit,		5),
 };
 
-struct rpc_version		nfs_version3 = {
+const struct rpc_version nfs_version3 = {
 	.number			= 3,
 	.nrprocs		= ARRAY_SIZE(nfs3_procedures),
 	.procs			= nfs3_procedures
@@ -2489,7 +2489,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 };
 
-struct rpc_version		nfsacl_version3 = {
+const struct rpc_version nfsacl_version3 = {
 	.number			= 3,
 	.nrprocs		= sizeof(nfs3_acl_procedures)/
 				  sizeof(nfs3_acl_procedures[0]),
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 95e92e4..4633d40 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7109,7 +7109,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 };
 
-struct rpc_version		nfs_version4 = {
+const struct rpc_version nfs_version4 = {
 	.number			= 4,
 	.nrprocs		= ARRAY_SIZE(nfs4_procedures),
 	.procs			= nfs4_procedures
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 426ccb1..0e262f3 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -605,18 +605,18 @@ static struct rpc_version nfs_cb_version4 = {
 	.procs			= nfs4_cb_procedures
 };
 
-static struct rpc_version *nfs_cb_version[] = {
+static const struct rpc_version *nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
-static struct rpc_program cb_program;
+static const struct rpc_program cb_program;
 
 static struct rpc_stat cb_stats = {
 	.program		= &cb_program
 };
 
 #define NFS4_CALLBACK 0x40000000
-static struct rpc_program cb_program = {
+static const struct rpc_program cb_program = {
 	.name			= "nfs4_cb",
 	.number			= NFS4_CALLBACK,
 	.nrvers			= ARRAY_SIZE(nfs_cb_version),
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 88a114f..8949167 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -188,7 +188,7 @@ struct nlm_block {
 /*
  * Global variables
  */
-extern struct rpc_program	nlm_program;
+extern const struct rpc_program	nlm_program;
 extern struct svc_procedure	nlmsvc_procedures[];
 #ifdef CONFIG_LOCKD_V4
 extern struct svc_procedure	nlmsvc_procedures4[];
diff --git a/include/linux/lockd/xdr4.h b/include/linux/lockd/xdr4.h
index 7353821..e58c88b 100644
--- a/include/linux/lockd/xdr4.h
+++ b/include/linux/lockd/xdr4.h
@@ -42,6 +42,6 @@ int	nlmclt_encode_lockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_cancargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_unlockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
  */
-extern struct rpc_version nlm_version4;
+extern const struct rpc_version nlm_version4;
 
 #endif /* LOCKD_XDR4_H */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f5188e1..144419a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1274,11 +1274,11 @@ struct nfs_rpc_ops {
 extern const struct nfs_rpc_ops	nfs_v2_clientops;
 extern const struct nfs_rpc_ops	nfs_v3_clientops;
 extern const struct nfs_rpc_ops	nfs_v4_clientops;
-extern struct rpc_version	nfs_version2;
-extern struct rpc_version	nfs_version3;
-extern struct rpc_version	nfs_version4;
+extern const struct rpc_version nfs_version2;
+extern const struct rpc_version nfs_version3;
+extern const struct rpc_version nfs_version4;
 
-extern struct rpc_version	nfsacl_version3;
-extern struct rpc_program	nfsacl_program;
+extern const struct rpc_version nfsacl_version3;
+extern const struct rpc_program nfsacl_program;
 
 #endif
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 4a46ffd..a4c62e9 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -61,7 +61,7 @@ struct rpc_clnt {
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
-	struct rpc_program *	cl_program;
+	const struct rpc_program *cl_program;
 	char			*cl_principal;	/* target to authenticate to */
 };
 
@@ -73,7 +73,7 @@ struct rpc_program {
 	const char *		name;		/* protocol name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
-	struct rpc_version **	version;	/* version array */
+	const struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
 	const char *		pipe_dir_name;	/* path to rpc_pipefs dir */
 };
@@ -109,7 +109,7 @@ struct rpc_create_args {
 	struct sockaddr		*saddress;
 	const struct rpc_timeout *timeout;
 	const char		*servername;
-	struct rpc_program	*program;
+	const struct rpc_program *program;
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
 	rpc_authflavor_t	authflavor;
@@ -128,7 +128,7 @@ struct rpc_create_args {
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
-				struct rpc_program *, u32);
+				const struct rpc_program *, u32);
 void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 void		rpc_shutdown_client(struct rpc_clnt *);
diff --git a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stats.h
index 4720b12..ae55c38 100644
--- a/include/linux/sunrpc/stats.h
+++ b/include/linux/sunrpc/stats.h
@@ -12,7 +12,7 @@
 #include <linux/proc_fs.h>
 
 struct rpc_stat {
-	struct rpc_program *	program;
+	const struct rpc_program *program;
 
 	unsigned int		netcnt,
 				netudpcnt,
@@ -60,7 +60,7 @@ void			rpc_modcount(struct inode *, int);
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *	rpc_proc_register(struct net *,struct rpc_stat *);
 void			rpc_proc_unregister(struct net *,const char *);
-void			rpc_proc_zero(struct rpc_program *);
+void			rpc_proc_zero(const struct rpc_program *);
 struct proc_dir_entry *	svc_proc_register(struct net *, struct svc_stat *,
 					  const struct file_operations *);
 void			svc_proc_unregister(struct net *, const char *);
@@ -71,7 +71,7 @@ void			svc_seq_show(struct seq_file *,
 
 static inline struct proc_dir_entry *rpc_proc_register(struct net *, struct rpc_stat *s) { return NULL; }
 static inline void rpc_proc_unregisterstruct net *, (const char *p) {}
-static inline void rpc_proc_zero(struct rpc_program *p) {}
+static inline void rpc_proc_zero(const struct rpc_program *p) {}
 
 static inline struct proc_dir_entry *svc_proc_register(struct net *net, struct svc_stat *s,
 						       const struct file_operations *f) { return NULL; }
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1b2317f..db7220d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -238,8 +238,8 @@ void rpc_clients_notifier_unregister(void)
 
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
 {
-	struct rpc_program	*program = args->program;
-	struct rpc_version	*version;
+	const struct rpc_program *program = args->program;
+	const struct rpc_version *version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
 	int err;
@@ -626,11 +626,11 @@ rpc_release_client(struct rpc_clnt *clnt)
  * The Sun NFSv2/v3 ACL protocol can do this.
  */
 struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
-				      struct rpc_program *program,
+				      const struct rpc_program *program,
 				      u32 vers)
 {
 	struct rpc_clnt *clnt;
-	struct rpc_version *version;
+	const struct rpc_version *version;
 	int err;
 
 	BUG_ON(vers >= program->nrvers || !program->version[vers]);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d397801..b1f08bd 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -112,7 +112,7 @@ enum {
 
 static void			rpcb_getport_done(struct rpc_task *, void *);
 static void			rpcb_map_release(void *data);
-static struct rpc_program	rpcb_program;
+static const struct rpc_program	rpcb_program;
 
 struct rpcbind_args {
 	struct rpc_xprt *	r_xprt;
@@ -137,8 +137,8 @@ struct rpcb_info {
 	struct rpc_procinfo *	rpc_proc;
 };
 
-static struct rpcb_info rpcb_next_version[];
-static struct rpcb_info rpcb_next_version6[];
+static const struct rpcb_info rpcb_next_version[];
+static const struct rpcb_info rpcb_next_version6[];
 
 static const struct rpc_call_ops rpcb_getport_ops = {
 	.rpc_call_done		= rpcb_getport_done,
@@ -1051,7 +1051,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 };
 
-static struct rpcb_info rpcb_next_version[] = {
+static const struct rpcb_info rpcb_next_version[] = {
 	{
 		.rpc_vers	= RPCBVERS_2,
 		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
@@ -1061,7 +1061,7 @@ static struct rpcb_info rpcb_next_version[] = {
 	},
 };
 
-static struct rpcb_info rpcb_next_version6[] = {
+static const struct rpcb_info rpcb_next_version6[] = {
 	{
 		.rpc_vers	= RPCBVERS_4,
 		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETADDR],
@@ -1075,25 +1075,25 @@ static struct rpcb_info rpcb_next_version6[] = {
 	},
 };
 
-static struct rpc_version rpcb_version2 = {
+static const struct rpc_version rpcb_version2 = {
 	.number		= RPCBVERS_2,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures2),
 	.procs		= rpcb_procedures2
 };
 
-static struct rpc_version rpcb_version3 = {
+static const struct rpc_version rpcb_version3 = {
 	.number		= RPCBVERS_3,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures3),
 	.procs		= rpcb_procedures3
 };
 
-static struct rpc_version rpcb_version4 = {
+static const struct rpc_version rpcb_version4 = {
 	.number		= RPCBVERS_4,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures4),
 	.procs		= rpcb_procedures4
 };
 
-static struct rpc_version *rpcb_version[] = {
+static const struct rpc_version *rpcb_version[] = {
 	NULL,
 	NULL,
 	&rpcb_version2,
@@ -1103,7 +1103,7 @@ static struct rpc_version *rpcb_version[] = {
 
 static struct rpc_stat rpcb_stats;
 
-static struct rpc_program rpcb_program = {
+static const struct rpc_program rpcb_program = {
 	.name		= "rpcbind",
 	.number		= RPCBIND_PROGRAM,
 	.nrvers		= ARRAY_SIZE(rpcb_version),
-- 
1.7.7.5

