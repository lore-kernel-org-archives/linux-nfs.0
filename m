Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab0HMVc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:27 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 26/50] pnfs_submit: layoutcommit
Date: Fri, 13 Aug 2010 17:31:38 -0400
Message-Id: <1281735122-1496-27-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-26-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |  107 ++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c          |  132 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c             |   62 +++++++++++++++++++++
 fs/nfs/pnfs.h             |    8 +++
 fs/nfs/write.c            |   14 +++++-
 include/linux/nfs4.h      |    1 +
 include/linux/nfs4_pnfs.h |   13 +++++
 7 files changed, 336 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 279a37d..5299c66 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5480,6 +5480,113 @@ int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
 	return err;
 }
 
+static void pnfs_layoutcommit_prepare(struct rpc_task *task, void *data)
+{
+	struct pnfs_layoutcommit_data *ldata =
+		(struct pnfs_layoutcommit_data *)data;
+	struct nfs_server *server = NFS_SERVER(ldata->args.inode);
+
+	if (nfs4_setup_sequence(server, &ldata->args.seq_args,
+				&ldata->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+
+static void
+pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
+{
+	struct pnfs_layoutcommit_data *data =
+		(struct pnfs_layoutcommit_data *)calldata;
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
+
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return;
+
+	if (RPC_ASSASSINATED(task))
+		return;
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
+
+	data->status = task->tk_status;
+}
+
+static void pnfs_layoutcommit_release(void *lcdata)
+{
+	struct pnfs_layoutcommit_data *data =
+		(struct pnfs_layoutcommit_data *)lcdata;
+
+	/* Matched by get_layout in pnfs_layoutcommit_inode */
+	put_layout(data->args.inode);
+	put_rpccred(data->cred);
+	pnfs_layoutcommit_free(lcdata);
+}
+
+static const struct rpc_call_ops pnfs_layoutcommit_ops = {
+	.rpc_call_prepare = pnfs_layoutcommit_prepare,
+	.rpc_call_done = pnfs_layoutcommit_done,
+	.rpc_release = pnfs_layoutcommit_release,
+};
+
+/* Execute a layoutcommit to the server */
+static int
+_pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.task = &data->task,
+		.rpc_client = NFS_CLIENT(data->args.inode),
+		.rpc_message = &msg,
+		.callback_ops = &pnfs_layoutcommit_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
+	struct rpc_task *task;
+	int status = 0;
+
+	dprintk("NFS: %4d initiating layoutcommit call. %llu@%llu lbw: %llu "
+		"type: %d issync %d\n",
+		data->task.tk_pid,
+		data->args.lseg.length,
+		data->args.lseg.offset,
+		data->args.lastbytewritten,
+		data->args.layout_type, issync);
+
+	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	if (!issync)
+		goto out;
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = data->status;
+out:
+	dprintk("%s: status %d\n", __func__, status);
+	rpc_put_task(task);
+	return 0;
+}
+
+int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
+{
+	struct nfs4_exception exception = { };
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
+	int err;
+
+	do {
+		err = nfs4_handle_exception(server,
+					_pnfs4_proc_layoutcommit(data, issync),
+					&exception);
+	} while (exception.retry);
+	return err;
+}
+
 int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
 	struct nfs4_pnfs_getdeviceinfo_arg args = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a096e5b..c63e2fb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -325,6 +325,11 @@ static int nfs4_stat_to_errno(int);
 #define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
 				decode_stateid_maxsz + \
 				XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
+#define encode_layoutcommit_sz	(18 +                           \
+				XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE) + \
+				op_encode_hdr_maxsz +          \
+				encode_stateid_maxsz)
+#define decode_layoutcommit_maxsz (3 + op_decode_hdr_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -728,6 +733,16 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz +        \
 				decode_layoutget_maxsz)
+#define NFS4_enc_layoutcommit_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz +\
+				encode_putfh_maxsz + \
+				encode_layoutcommit_sz + \
+				encode_getattr_maxsz)
+#define NFS4_dec_layoutcommit_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_layoutcommit_maxsz + \
+				decode_getattr_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1809,6 +1824,44 @@ encode_layoutget(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_layoutget_maxsz;
 }
+
+static int
+encode_layoutcommit(struct xdr_stream *xdr,
+		    const struct pnfs_layoutcommit_arg *args,
+		    struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	dprintk("%s: %llu@%llu lbw: %llu type: %d\n", __func__,
+		args->lseg.length, args->lseg.offset, args->lastbytewritten,
+		args->layout_type);
+
+	p = reserve_space(xdr, 40 + NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
+	p = xdr_encode_hyper(p, args->lseg.offset);
+	p = xdr_encode_hyper(p, args->lseg.length);
+	*p++ = cpu_to_be32(0);     /* reclaim */
+	p = xdr_encode_opaque_fixed(p, args->stateid.u.data, NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(1);     /* newoffset = TRUE */
+	p = xdr_encode_hyper(p, args->lastbytewritten);
+	*p = cpu_to_be32(args->time_modify_changed != 0);
+	if (args->time_modify_changed) {
+		p = reserve_space(xdr, 12);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(args->time_modify.tv_sec);
+		*p = cpu_to_be32(args->time_modify.tv_nsec);
+	}
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(args->layout_type);
+
+	p = reserve_space(xdr, 4);
+	xdr_encode_opaque(p, NULL, 0);
+
+	hdr->nops++;
+	hdr->replen += decode_layoutcommit_maxsz;
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2679,6 +2732,27 @@ static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ *  Encode LAYOUTCOMMIT request
+ */
+static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req, uint32_t *p,
+				     struct pnfs_layoutcommit_arg *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_layoutcommit(&xdr, args, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -5052,6 +5126,34 @@ out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
+
+static int decode_layoutcommit(struct xdr_stream *xdr,
+				    struct rpc_rqst *req,
+				    struct pnfs_layoutcommit_res *res)
+{
+	__be32 *p;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->sizechanged = be32_to_cpup(p);
+
+	if (res->sizechanged) {
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
+		xdr_decode_hyper(p, &res->newsize);
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -6128,6 +6230,35 @@ static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
 out:
 	return status;
 }
+
+/*
+ * Decode LAYOUTCOMMIT response
+ */
+static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp, uint32_t *p,
+				     struct pnfs_layoutcommit_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_layoutcommit(&xdr, rqstp, res);
+	if (status)
+		goto out;
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -6308,6 +6439,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
   PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
   PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
+  PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 96d379d..d0a6320 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1040,6 +1040,68 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	dprintk("<-- %s Status %d\n", __func__, result);
 	return result;
 }
+
+/* Issue a async layoutcommit for an inode.
+ */
+int
+pnfs_layoutcommit_inode(struct inode *inode, int sync)
+{
+	struct pnfs_layoutcommit_data *data;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	loff_t write_begin_pos;
+	loff_t write_end_pos;
+
+	int status = 0;
+
+	dprintk("%s Begin (sync:%d)\n", __func__, sync);
+
+	BUG_ON(!has_layout(nfsi));
+
+	data = pnfs_layoutcommit_alloc();
+	if (!data)
+		return -ENOMEM;
+
+	spin_lock(&inode->i_lock);
+	if (!layoutcommit_needed(nfsi)) {
+		spin_unlock(&inode->i_lock);
+		goto out_free;
+	}
+
+	/* Clear layoutcommit properties in the inode so
+	 * new lc info can be generated
+	 */
+	write_begin_pos = nfsi->layout->pnfs_write_begin_pos;
+	write_end_pos = nfsi->layout->pnfs_write_end_pos;
+	data->cred = nfsi->layout->lo_cred;
+	nfsi->layout->pnfs_write_begin_pos = 0;
+	nfsi->layout->pnfs_write_end_pos = 0;
+	nfsi->layout->lo_cred = NULL;
+	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
+	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
+
+	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
+	get_layout(NFS_I(inode)->layout);
+
+	spin_unlock(&inode->i_lock);
+
+	/* Set up layout commit args */
+	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
+					 write_end_pos);
+	if (status) {
+		/* The layout driver failed to setup the layoutcommit */
+		put_rpccred(data->cred);
+		put_layout(inode);
+		goto out_free;
+	}
+	status = pnfs4_proc_layoutcommit(data, sync);
+out:
+	dprintk("%s end (err:%d)\n", __func__, status);
+	return status;
+out_free:
+	pnfs_layoutcommit_free(data);
+	goto out;
+}
+
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6410617..a1648c0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -25,6 +25,8 @@
 extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
+extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
+				   int issync);
 
 /* pnfs.c */
 void put_lseg(struct pnfs_layout_segment *lseg);
@@ -37,6 +39,7 @@ void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
 void pnfs_uninitialize(void);
 void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
+int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
@@ -114,6 +117,11 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		*lsegpp = NULL;
 }
 
+static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 874972d..4d37229 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -28,6 +28,7 @@
 #include "iostat.h"
 #include "nfs4_fs.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -1465,7 +1466,18 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	return nfs_commit_unstable_pages(inode, wbc);
+	int ret;
+	ret = nfs_commit_unstable_pages(inode, wbc);
+	if (ret >= 0 && layoutcommit_needed(NFS_I(inode))) {
+		int err, sync = wbc->sync_mode;
+
+		if (wbc->nonblocking || wbc->for_background)
+			sync = 0;
+		err = pnfs_layoutcommit_inode(inode, sync);
+		if (err < 0)
+			ret = err;
+	}
+	return ret;
 }
 
 /*
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2e11a3d..4c4c4cc 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -547,6 +547,7 @@ enum {
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_PNFS_LAYOUTGET,
+	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 };
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 482659f..52f7a21 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -60,6 +60,13 @@ has_layout(struct nfs_inode *nfsi)
 	return nfsi->layout != NULL;
 }
 
+static inline bool
+layoutcommit_needed(struct nfs_inode *nfsi)
+{
+	return has_layout(nfsi) &&
+	       test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
+}
+
 #else /* CONFIG_NFS_V4_1 */
 
 static inline bool
@@ -68,6 +75,12 @@ has_layout(struct nfs_inode *nfsi)
 	return false;
 }
 
+static inline bool
+layoutcommit_needed(struct nfs_inode *nfsi)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct pnfs_layout_segment {
-- 
1.6.2.5

