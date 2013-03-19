Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389Ab3CSNHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] NFSv4: The stateid must remain the same for replayed RPC calls
Date: Tue, 19 Mar 2013 09:07:36 -0400
Message-Id: <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we replay a READ or WRITE call, we should not be changing the
stateid. Currently, we may end up doing so, because the stateid
is only selected at xdr encode time.

This patch ensures that we select the stateid after we get an NFSv4.1
session slot, and that we keep that same stateid across retries.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |  4 ++++
 fs/nfs/nfs4filelayout.c | 14 ++++++++++----
 fs/nfs/nfs4proc.c       | 27 +++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c        | 28 ++--------------------------
 include/linux/nfs_xdr.h |  2 ++
 5 files changed, 41 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9ce9013..8309e98 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -234,6 +234,10 @@ extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
+extern void nfs4_set_rw_stateid(nfs4_stateid *stateid,
+		const struct nfs_open_context *ctx,
+		const struct nfs_lock_context *l_ctx,
+		fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2533ad4..c5656c5 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -318,10 +318,13 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 	}
 	rdata->read_done_cb = filelayout_read_done_cb;
 
-	nfs41_setup_sequence(rdata->ds_clp->cl_session,
+	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
 			&rdata->args.seq_args,
 			&rdata->res.seq_res,
-			task);
+			task))
+		return;
+	nfs4_set_rw_stateid(&rdata->args.stateid, rdata->args.context,
+			rdata->args.lock_context, FMODE_READ);
 }
 
 static void filelayout_read_call_done(struct rpc_task *task, void *data)
@@ -422,10 +425,13 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 		rpc_exit(task, 0);
 		return;
 	}
-	nfs41_setup_sequence(wdata->ds_clp->cl_session,
+	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 			&wdata->args.seq_args,
 			&wdata->res.seq_res,
-			task);
+			task))
+		return;
+	nfs4_set_rw_stateid(&wdata->args.stateid, wdata->args.context,
+			wdata->args.lock_context, FMODE_WRITE);
 }
 
 static void filelayout_write_call_done(struct rpc_task *task, void *data)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a6b3c9..aaf935b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3454,6 +3454,19 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
+void nfs4_set_rw_stateid(nfs4_stateid *stateid,
+		const struct nfs_open_context *ctx,
+		const struct nfs_lock_context *l_ctx,
+		fmode_t fmode)
+{
+	const struct nfs_lockowner *lockowner = NULL;
+
+	if (l_ctx != NULL)
+		lockowner = &l_ctx->lockowner;
+	nfs4_select_rw_stateid(stateid, ctx->state, fmode, lockowner);
+}
+EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
+
 void __nfs4_read_done_cb(struct nfs_read_data *data)
 {
 	nfs_invalidate_atime(data->header->inode);
@@ -3496,10 +3509,13 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 
 static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
 {
-	nfs4_setup_sequence(NFS_SERVER(data->header->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 			&data->args.seq_args,
 			&data->res.seq_res,
-			task);
+			task))
+		return;
+	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
+			data->args.lock_context, FMODE_READ);
 }
 
 static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
@@ -3560,10 +3576,13 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 
 static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
 {
-	nfs4_setup_sequence(NFS_SERVER(data->header->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 			&data->args.seq_args,
 			&data->res.seq_res,
-			task);
+			task))
+		return;
+	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
+			data->args.lock_context, FMODE_WRITE);
 }
 
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e3edda5..9d32877 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1506,35 +1506,12 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	encode_op_hdr(xdr, OP_PUTROOTFH, decode_putrootfh_maxsz, hdr);
 }
 
-static void encode_open_stateid(struct xdr_stream *xdr,
-		const struct nfs_open_context *ctx,
-		const struct nfs_lock_context *l_ctx,
-		fmode_t fmode,
-		int zero_seqid)
-{
-	nfs4_stateid stateid;
-
-	if (ctx->state != NULL) {
-		const struct nfs_lockowner *lockowner = NULL;
-
-		if (l_ctx != NULL)
-			lockowner = &l_ctx->lockowner;
-		nfs4_select_rw_stateid(&stateid, ctx->state,
-				fmode, lockowner);
-		if (zero_seqid)
-			stateid.seqid = 0;
-		encode_nfs4_stateid(xdr, &stateid);
-	} else
-		encode_nfs4_stateid(xdr, &zero_stateid);
-}
-
 static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_READ, decode_read_maxsz, hdr);
-	encode_open_stateid(xdr, args->context, args->lock_context,
-			FMODE_READ, hdr->minorversion);
+	encode_nfs4_stateid(xdr, &args->stateid);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
@@ -1670,8 +1647,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_WRITE, decode_write_maxsz, hdr);
-	encode_open_stateid(xdr, args->context, args->lock_context,
-			FMODE_WRITE, hdr->minorversion);
+	encode_nfs4_stateid(xdr, &args->stateid);
 
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4b993d3..90a4aa1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -486,6 +486,7 @@ struct nfs_readargs {
 	struct nfs_fh *		fh;
 	struct nfs_open_context *context;
 	struct nfs_lock_context *lock_context;
+	nfs4_stateid		stateid;
 	__u64			offset;
 	__u32			count;
 	unsigned int		pgbase;
@@ -507,6 +508,7 @@ struct nfs_writeargs {
 	struct nfs_fh *		fh;
 	struct nfs_open_context *context;
 	struct nfs_lock_context *lock_context;
+	nfs4_stateid		stateid;
 	__u64			offset;
 	__u32			count;
 	enum nfs3_stable_how	stable;
-- 
1.8.1.4

