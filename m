Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43574 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1EWAB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 20:01:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 32/38] pnfs: layoutreturn
Date: Mon, 23 May 2011 03:01:45 +0300
Message-Id: <1306108905-29125-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFSv4.1 LAYOUTRETURN implementation

Currently, does not support layout-type payload encoding.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
[call pnfs_return_layout right before pnfs_destroy_layout]
[remove assert_spin_locked from pnfs_clear_lseg_list]
[remove wait parameter from the layoutreturn path.]
[remove return_type field from nfs4_layoutreturn_args]
[remove range from nfs4_layoutreturn_args]
[no need to send layoutcommit from _pnfs_return_layout]
[don't wait on sync layoutreturn]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c          |    3 +-
 fs/nfs/nfs4proc.c       |   82 ++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |  111 ++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/pnfs.c           |   56 ++++++++++++++++++++++++
 fs/nfs/pnfs.h           |   18 ++++++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |   21 +++++++++
 7 files changed, 285 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 57bb31a..e9c6d9f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1424,9 +1424,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
-	pnfs_destroy_layout(NFS_I(inode));
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
+	pnfs_return_layout(inode);
+	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
 	/* First call standard NFS clear_inode() code */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 92c8bc4..5b4124e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5673,6 +5673,88 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 	return status;
 }
 
+static void
+nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutreturn *lrp = calldata;
+
+	dprintk("--> %s\n", __func__);
+	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
+				&lrp->res.seq_res, 0, task))
+		return;
+	rpc_call_start(task);
+}
+
+static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutreturn *lrp = calldata;
+	struct nfs_server *server;
+
+	dprintk("--> %s\n", __func__);
+
+	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
+		return;
+
+	server = NFS_SERVER(lrp->args.inode);
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
+		nfs_restart_rpc(task, lrp->clp);
+		return;
+	}
+	if (task->tk_status == 0) {
+		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
+
+		if (lrp->res.lrs_present) {
+			spin_lock(&lo->plh_inode->i_lock);
+			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
+			spin_unlock(&lo->plh_inode->i_lock);
+		} else
+			BUG_ON(!list_empty(&lo->plh_segs));
+	}
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs4_layoutreturn_release(void *calldata)
+{
+	struct nfs4_layoutreturn *lrp = calldata;
+
+	dprintk("--> %s\n", __func__);
+	put_layout_hdr(NFS_I(lrp->args.inode)->layout);
+	kfree(calldata);
+	dprintk("<-- %s\n", __func__);
+}
+
+static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
+	.rpc_call_prepare = nfs4_layoutreturn_prepare,
+	.rpc_call_done = nfs4_layoutreturn_done,
+	.rpc_release = nfs4_layoutreturn_release,
+};
+
+int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
+{
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTRETURN],
+		.rpc_argp = &lrp->args,
+		.rpc_resp = &lrp->res,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = lrp->clp->cl_rpcclient,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_layoutreturn_call_ops,
+		.callback_data = lrp,
+	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = task->tk_status;
+	dprintk("<-- %s status=%d\n", __func__, status);
+	rpc_put_task(task);
+	return status;
+}
+
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c3ccd2c..e53d7d8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -338,7 +338,11 @@ static int nfs4_stat_to_errno(int);
 				1 /* layoutupdate4 layout type */ + \
 				1 /* NULL filelayout layoutupdate4 payload */)
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
-
+#define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
+				encode_stateid_maxsz + \
+				1 /* FIXME: opaque lrf_body always empty at the moment */)
+#define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
+				1 + decode_stateid_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -760,7 +764,14 @@ static int nfs4_stat_to_errno(int);
 				decode_putfh_maxsz + \
 				decode_layoutcommit_maxsz + \
 				decode_getattr_maxsz)
-
+#define NFS4_enc_layoutreturn_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz + \
+				encode_layoutreturn_maxsz)
+#define NFS4_dec_layoutreturn_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_layoutreturn_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1889,6 +1900,31 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	hdr->replen += decode_layoutcommit_maxsz;
 	return 0;
 }
+
+static void
+encode_layoutreturn(struct xdr_stream *xdr,
+		    const struct nfs4_layoutreturn_args *args,
+		    struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 20);
+	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
+	*p++ = cpu_to_be32(args->reclaim);
+	*p++ = cpu_to_be32(args->layout_type);
+	*p++ = cpu_to_be32(IOMODE_ANY);
+	*p = cpu_to_be32(RETURN_FILE);
+	p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
+	p = xdr_encode_hyper(p, 0);
+	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
+	spin_lock(&args->inode->i_lock);
+	xdr_encode_opaque_fixed(p, &NFS_I(args->inode)->layout->plh_stateid.data, NFS4_STATEID_SIZE);
+	spin_unlock(&args->inode->i_lock);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(0);
+	hdr->nops++;
+	hdr->replen += decode_layoutreturn_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2706,9 +2742,9 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 /*
  *  Encode LAYOUTCOMMIT request
  */
-static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     struct nfs4_layoutcommit_args *args)
+static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      struct nfs4_layoutcommit_args *args)
 {
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
@@ -2720,7 +2756,24 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 	encode_layoutcommit(xdr, args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return 0;
+}
+
+/*
+ * Encode LAYOUTRETURN request
+ */
+static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      struct nfs4_layoutreturn_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
+	encode_layoutreturn(xdr, args, &hdr);
+	encode_nops(&hdr);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -5203,6 +5256,27 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_layoutreturn(struct xdr_stream *xdr,
+			       struct nfs4_layoutreturn_res *res)
+{
+	__be32 *p;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTRETURN);
+	if (status)
+		return status;
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->lrs_present = be32_to_cpup(p);
+	if (res->lrs_present)
+		status = decode_stateid(xdr, &res->stateid);
+	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_layoutcommit(struct xdr_stream *xdr,
 			       struct rpc_rqst *req,
 			       struct nfs4_layoutcommit_res *res)
@@ -6320,6 +6394,30 @@ out:
 }
 
 /*
+ * Decode LAYOUTRETURN response
+ */
+static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp,
+				     struct xdr_stream *xdr,
+				     struct nfs4_layoutreturn_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_layoutreturn(xdr, res);
+out:
+	return status;
+}
+
+/*
  * Decode LAYOUTCOMMIT response
  */
 static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
@@ -6547,6 +6645,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
 	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
+	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d39fcca..040219b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -619,6 +619,62 @@ out_err_free:
 	return NULL;
 }
 
+static int
+return_layout(struct inode *ino)
+{
+	struct nfs4_layoutreturn *lrp;
+	struct nfs_server *server = NFS_SERVER(ino);
+	int status = -ENOMEM;
+
+	dprintk("--> %s\n", __func__);
+
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (lrp == NULL) {
+		put_layout_hdr(NFS_I(ino)->layout);
+		goto out;
+	}
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = server->pnfs_curr_ld->id;
+	lrp->args.inode = ino;
+	lrp->clp = server->nfs_client;
+
+	status = nfs4_proc_layoutreturn(lrp);
+out:
+	dprintk("<-- %s status: %d\n", __func__, status);
+	return status;
+}
+
+/* Initiates a LAYOUTRETURN(FILE) */
+int
+_pnfs_return_layout(struct inode *ino)
+{
+	struct pnfs_layout_hdr *lo = NULL;
+	struct nfs_inode *nfsi = NFS_I(ino);
+	LIST_HEAD(tmp_list);
+	int status = 0;
+
+	dprintk("--> %s\n", __func__);
+
+	spin_lock(&ino->i_lock);
+	lo = nfsi->layout;
+	if (!lo || !mark_matching_lsegs_invalid(lo, &tmp_list, NULL)) {
+		spin_unlock(&ino->i_lock);
+		dprintk("%s: no layout segments to return\n", __func__);
+		goto out;
+	}
+	/* Reference matched in nfs4_layoutreturn_release */
+	get_layout_hdr(lo);
+	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&tmp_list);
+
+	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
+
+	status = return_layout(ino);
+out:
+	dprintk("<-- %s status: %d\n", __func__, status);
+	return status;
+}
+
 bool pnfs_roc(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8a6e1f1..21daebb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -129,6 +129,7 @@ extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
+extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
@@ -165,6 +166,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
+int _pnfs_return_layout(struct inode *);
 int pnfs_ld_write_done(struct nfs_write_data *);
 int pnfs_ld_read_done(struct nfs_read_data *);
 
@@ -256,6 +258,17 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 		put_lseg(req->wb_commit_lseg);
 }
 
+static inline int pnfs_return_layout(struct inode *ino)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs_server *nfss = NFS_SERVER(ino);
+
+	if (pnfs_enabled_sb(nfss) && nfsi->layout)
+		return _pnfs_return_layout(ino);
+
+	return 0;
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -298,6 +311,11 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static inline int pnfs_return_layout(struct inode *ino)
+{
+	return 0;
+}
+
 static inline bool
 pnfs_roc(struct inode *ino)
 {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 178fafe..9376eaf 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -562,6 +562,7 @@ enum {
 	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_LAYOUTCOMMIT,
+	NFSPROC4_CLNT_LAYOUTRETURN,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7c8ff09..1629b69 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -269,6 +269,27 @@ struct nfs4_layoutcommit_data {
 	struct nfs4_layoutcommit_res res;
 };
 
+struct nfs4_layoutreturn_args {
+	__u32   reclaim;
+	__u32   layout_type;
+	struct inode *inode;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_layoutreturn_res {
+	struct nfs4_sequence_res seq_res;
+	u32 lrs_present;
+	nfs4_stateid stateid;
+};
+
+struct nfs4_layoutreturn {
+	struct nfs4_layoutreturn_args args;
+	struct nfs4_layoutreturn_res res;
+	struct rpc_cred *cred;
+	struct nfs_client *clp;
+	int rpc_status;
+};
+
 /*
  * Arguments to the open call.
  */
-- 
1.7.3.4

