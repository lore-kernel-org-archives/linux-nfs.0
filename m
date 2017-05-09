Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:42486 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbdEIJUz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:55 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 15/32] sunrpc: mark all struct rpc_procinfo instances as const
Date: Tue,  9 May 2017 11:19:53 +0200
Message-Id: <20170509092010.30752-16-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct rpc_procinfo contains function pointers, and marking it as
constant avoids it being able to be used as an attach vector for
code injections.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/clnt4xdr.c                  |  2 +-
 fs/lockd/clntxdr.c                   |  2 +-
 fs/lockd/mon.c                       |  2 +-
 fs/nfs/internal.h                    |  6 +++---
 fs/nfs/mount_clnt.c                  |  4 ++--
 fs/nfs/nfs2xdr.c                     |  2 +-
 fs/nfs/nfs3xdr.c                     |  4 ++--
 fs/nfs/nfs4_fs.h                     |  2 +-
 fs/nfs/nfs4xdr.c                     |  2 +-
 fs/nfsd/nfs4callback.c               |  2 +-
 include/linux/sunrpc/clnt.h          |  4 ++--
 include/linux/sunrpc/sched.h         |  2 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  2 +-
 net/sunrpc/clnt.c                    |  4 ++--
 net/sunrpc/rpcb_clnt.c               | 19 ++++++++++---------
 net/sunrpc/stats.c                   |  2 +-
 16 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index f0ab7a99dd23..ff72662025fa 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -584,7 +584,7 @@ static int nlm4_xdr_dec_res(struct rpc_rqst *req,
 	.p_name      = #proc,						\
 	}
 
-static struct rpc_procinfo	nlm4_procedures[] = {
+static const struct rpc_procinfo nlm4_procedures[] = {
 	PROC(TEST,		testargs,	testres),
 	PROC(LOCK,		lockargs,	res),
 	PROC(CANCEL,		cancargs,	res),
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 17e7f08b3a22..cccf5c2ffadb 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -582,7 +582,7 @@ static int nlm_xdr_dec_res(struct rpc_rqst *req,
 	.p_name      = #proc,						\
 	}
 
-static struct rpc_procinfo	nlm_procedures[] = {
+static const struct rpc_procinfo nlm_procedures[] = {
 	PROC(TEST,		testargs,	testres),
 	PROC(LOCK,		lockargs,	res),
 	PROC(CANCEL,		cancargs,	res),
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 80630f0347e1..2c41de8db1f0 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -531,7 +531,7 @@ static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 #define SM_monres_sz	2
 #define SM_unmonres_sz	1
 
-static struct rpc_procinfo	nsm_procedures[] = {
+static const struct rpc_procinfo nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
 		.p_encode	= nsm_xdr_enc_mon,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7b38fedb7e03..76d0f5e993ba 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -270,12 +270,12 @@ static inline bool nfs_match_open_context(const struct nfs_open_context *ctx1,
 }
 
 /* nfs2xdr.c */
-extern struct rpc_procinfo nfs_procedures[];
+extern const struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
 /* nfs3xdr.c */
-extern struct rpc_procinfo nfs3_procedures[];
+extern const struct rpc_procinfo nfs3_procedures[];
 extern int nfs3_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
@@ -292,7 +292,7 @@ extern const u32 nfs41_maxgetdevinfo_overhead;
 
 /* nfs4proc.c */
 #if IS_ENABLED(CONFIG_NFS_V4)
-extern struct rpc_procinfo nfs4_procedures[];
+extern const struct rpc_procinfo nfs4_procedures[];
 #endif
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 806657d65074..55b5a62accbc 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -466,7 +466,7 @@ static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
 	return decode_auth_flavors(xdr, res);
 }
 
-static struct rpc_procinfo mnt_procedures[] = {
+static const struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
 		.p_encode	= mnt_xdr_enc_dirpath,
@@ -485,7 +485,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 	},
 };
 
-static struct rpc_procinfo mnt3_procedures[] = {
+static const struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
 		.p_encode	= mnt_xdr_enc_dirpath,
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index a299648ea321..1ecc03fca5ce 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1152,7 +1152,7 @@ static int nfs_stat_to_errno(enum nfs_stat status)
 	.p_statidx  =  NFSPROC_##proc,					\
 	.p_name     =  #proc,						\
 	}
-struct rpc_procinfo	nfs_procedures[] = {
+const struct rpc_procinfo nfs_procedures[] = {
 	PROC(GETATTR,	fhandle,	attrstat,	1),
 	PROC(SETATTR,	sattrargs,	attrstat,	0),
 	PROC(LOOKUP,	diropargs,	diropres,	2),
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index cc272eb8be3e..82d2007a7be5 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2554,7 +2554,7 @@ static int nfs3_stat_to_errno(enum nfs_stat status)
 	.p_name      = #proc,						\
 	}
 
-struct rpc_procinfo	nfs3_procedures[] = {
+const struct rpc_procinfo nfs3_procedures[] = {
 	PROC(GETATTR,		getattr,	getattr,	1),
 	PROC(SETATTR,		setattr,	setattr,	0),
 	PROC(LOOKUP,		lookup,		lookup,		2),
@@ -2585,7 +2585,7 @@ const struct rpc_version nfs_version3 = {
 };
 
 #ifdef CONFIG_NFS_V3_ACL
-static struct rpc_procinfo	nfs3_acl_procedures[] = {
+static const struct rpc_procinfo nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = nfs3_xdr_enc_getacl3args,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc27ccf..9b0cf3872722 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -493,7 +493,7 @@ static inline void nfs4_unregister_sysctl(void)
 #endif
 
 /* nfs4xdr.c */
-extern struct rpc_procinfo nfs4_procedures[];
+extern const struct rpc_procinfo nfs4_procedures[];
 
 struct nfs4_mount_data;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index af20e9b9554c..dea3f5ddc179 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7606,7 +7606,7 @@ nfs4_stat_to_errno(int stat)
 	.p_name = #proc,	\
 }
 
-struct rpc_procinfo	nfs4_procedures[] = {
+const struct rpc_procinfo nfs4_procedures[] = {
 	PROC(READ,		enc_read,		dec_read),
 	PROC(WRITE,		enc_write,		dec_write),
 	PROC(COMMIT,		enc_commit,		dec_commit),
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a2bedbd05b2b..9c36b037c6fc 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -696,7 +696,7 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 	.p_name    = #proc,						\
 }
 
-static struct rpc_procinfo nfs4_cb_procedures[] = {
+static const struct rpc_procinfo nfs4_cb_procedures[] = {
 	PROC(CB_NULL,	NULL,		cb_null,	cb_null),
 	PROC(CB_RECALL,	COMPOUND,	cb_recall,	cb_recall),
 #ifdef CONFIG_NFSD_PNFS
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index d1f6778c7da7..bcf0b3d0463e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -39,7 +39,7 @@ struct rpc_clnt {
 	struct list_head	cl_tasks;	/* List of tasks */
 	spinlock_t		cl_lock;	/* spinlock */
 	struct rpc_xprt __rcu *	cl_xprt;	/* transport */
-	struct rpc_procinfo *	cl_procinfo;	/* procedure info */
+	const struct rpc_procinfo *cl_procinfo;	/* procedure info */
 	u32			cl_prog,	/* RPC program number */
 				cl_vers,	/* RPC version number */
 				cl_maxproc;	/* max procedure number */
@@ -87,7 +87,7 @@ struct rpc_program {
 struct rpc_version {
 	u32			number;		/* version number */
 	unsigned int		nrprocs;	/* number of procs */
-	struct rpc_procinfo *	procs;		/* procedure array */
+	const struct rpc_procinfo *procs;	/* procedure array */
 };
 
 /*
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7ba040c797ec..ed60253abd0a 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -22,7 +22,7 @@
  */
 struct rpc_procinfo;
 struct rpc_message {
-	struct rpc_procinfo *	rpc_proc;	/* Procedure information */
+	const struct rpc_procinfo *rpc_proc;	/* Procedure information */
 	void *			rpc_argp;	/* Arguments */
 	void *			rpc_resp;	/* Result */
 	struct rpc_cred *	rpc_cred;	/* Credentials */
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index a80b8e607478..38175b430dd1 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -63,7 +63,7 @@ enum {
 	.p_name   = #proc,				\
 }
 
-static struct rpc_procinfo gssp_procedures[] = {
+static const struct rpc_procinfo gssp_procedures[] = {
 	PROC(INDICATE_MECHS, indicate_mechs),
         PROC(GET_CALL_CONTEXT, get_call_context),
         PROC(IMPORT_AND_CANON_NAME, import_and_canon_name),
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e6d2ae49d791..b6256b55b4ac 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1679,7 +1679,7 @@ call_allocate(struct rpc_task *task)
 	unsigned int slack = task->tk_rqstp->rq_cred->cr_auth->au_cslack;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
-	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
+	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 	int status;
 
 	dprint_status(task);
@@ -2494,7 +2494,7 @@ static int rpcproc_decode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	return 0;
 }
 
-static struct rpc_procinfo rpcproc_null = {
+static const struct rpc_procinfo rpcproc_null = {
 	.p_encode = rpcproc_encode_null,
 	.p_decode = rpcproc_decode_null,
 };
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index f67b9e2897b4..c628e23c259a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -128,13 +128,13 @@ struct rpcbind_args {
 	int			r_status;
 };
 
-static struct rpc_procinfo rpcb_procedures2[];
-static struct rpc_procinfo rpcb_procedures3[];
-static struct rpc_procinfo rpcb_procedures4[];
+static const struct rpc_procinfo rpcb_procedures2[];
+static const struct rpc_procinfo rpcb_procedures3[];
+static const struct rpc_procinfo rpcb_procedures4[];
 
 struct rpcb_info {
 	u32			rpc_vers;
-	struct rpc_procinfo *	rpc_proc;
+	const struct rpc_procinfo *rpc_proc;
 };
 
 static const struct rpcb_info rpcb_next_version[];
@@ -620,7 +620,8 @@ int rpcb_v4_register(struct net *net, const u32 program, const u32 version,
 	return -EAFNOSUPPORT;
 }
 
-static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbind_args *map, struct rpc_procinfo *proc)
+static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt,
+		struct rpcbind_args *map, const struct rpc_procinfo *proc)
 {
 	struct rpc_message msg = {
 		.rpc_proc = proc,
@@ -671,7 +672,7 @@ static struct rpc_clnt *rpcb_find_transport_owner(struct rpc_clnt *clnt)
 void rpcb_getport_async(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt;
-	struct rpc_procinfo *proc;
+	const struct rpc_procinfo *proc;
 	u32 bind_version;
 	struct rpc_xprt *xprt;
 	struct rpc_clnt	*rpcb_clnt;
@@ -994,7 +995,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
  * since the Linux kernel RPC code requires only these.
  */
 
-static struct rpc_procinfo rpcb_procedures2[] = {
+static const struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_mapping,
@@ -1027,7 +1028,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 };
 
-static struct rpc_procinfo rpcb_procedures3[] = {
+static const struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_getaddr,
@@ -1060,7 +1061,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 };
 
-static struct rpc_procinfo rpcb_procedures4[] = {
+static const struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_getaddr,
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 88b1e18c0dd6..42053510b96b 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -191,7 +191,7 @@ void rpc_count_iostats(const struct rpc_task *task, struct rpc_iostats *stats)
 EXPORT_SYMBOL_GPL(rpc_count_iostats);
 
 static void _print_name(struct seq_file *seq, unsigned int op,
-			struct rpc_procinfo *procs)
+			const struct rpc_procinfo *procs)
 {
 	if (procs[op].p_name)
 		seq_printf(seq, "\t%12s: ", procs[op].p_name);
-- 
2.11.0

