Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab0HMVc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:28 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 28/50] pnfs_submit: layoutreturn
Date: Fri, 13 Aug 2010 17:31:40 -0400
Message-Id: <1281735122-1496-29-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-28-git-send-email-andros@netapp.com>
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
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c           |    3 +-
 fs/nfs/nfs4proc.c        |  106 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4state.c       |   20 ++++++++-
 fs/nfs/nfs4xdr.c         |  109 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c            |   25 ++++++++++-
 fs/nfs/pnfs.h            |   49 +++++++++++++++++++++
 include/linux/nfs4.h     |    1 +
 include/linux/pnfs_xdr.h |   22 +++++++++
 8 files changed, 332 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 97fb2d1..0360336 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1403,9 +1403,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_clear_inode(struct inode *inode)
 {
+	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
+
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
-	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 }
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5299c66..2f00a67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5587,6 +5587,112 @@ int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
 	return err;
 }
 
+static void
+nfs4_pnfs_layoutreturn_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_pnfs_layoutreturn *lrp = calldata;
+	struct inode *ino = lrp->args.inode;
+	struct nfs_server *server = NFS_SERVER(ino);
+
+	dprintk("--> %s\n", __func__);
+	if (nfs4_setup_sequence(server, &lrp->args.seq_args,
+				&lrp->res.seq_res, 0, task))
+		return;
+	rpc_call_start(task);
+}
+
+static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_pnfs_layoutreturn *lrp = calldata;
+	struct inode *ino = lrp->args.inode;
+	struct nfs_server *server = NFS_SERVER(ino);
+
+	dprintk("--> %s\n", __func__);
+
+	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
+		return;
+
+	if (RPC_ASSASSINATED(task))
+		return;
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
+
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs4_pnfs_layoutreturn_release(void *calldata)
+{
+	struct nfs4_pnfs_layoutreturn *lrp = calldata;
+	struct pnfs_layout_type *lo = NFS_I(lrp->args.inode)->layout;
+
+	dprintk("--> %s return_type %d lo %p\n", __func__,
+		lrp->args.return_type, lo);
+
+	if (lrp->args.return_type == RETURN_FILE) {
+		if (!lrp->res.lrs_present)
+			pnfs_set_layout_stateid(lo, &zero_stateid);
+		pnfs_layout_release(lo, &lrp->args.lseg);
+	}
+	kfree(calldata);
+	dprintk("<-- %s\n", __func__);
+}
+
+static const struct rpc_call_ops nfs4_pnfs_layoutreturn_call_ops = {
+	.rpc_call_prepare = nfs4_pnfs_layoutreturn_prepare,
+	.rpc_call_done = nfs4_pnfs_layoutreturn_done,
+	.rpc_release = nfs4_pnfs_layoutreturn_release,
+};
+
+int _pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool issync)
+{
+	struct inode *ino = lrp->args.inode;
+	struct nfs_server *server = NFS_SERVER(ino);
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTRETURN],
+		.rpc_argp = &lrp->args,
+		.rpc_resp = &lrp->res,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_pnfs_layoutreturn_call_ops,
+		.callback_data = lrp,
+		.flags = RPC_TASK_ASYNC,
+	};
+	int status = 0;
+
+	dprintk("--> %s\n", __func__);
+	lrp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	if (!issync)
+		goto out;
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = task->tk_status;
+out:
+	dprintk("<-- %s\n", __func__);
+	rpc_put_task(task);
+	return status;
+}
+
+int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool issync)
+{
+	struct nfs_server *server = NFS_SERVER(lrp->args.inode);
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = nfs4_handle_exception(server,
+				_pnfs4_proc_layoutreturn(lrp, issync),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
 int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
 	struct nfs4_pnfs_getdeviceinfo_arg args = {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 506a92f..a674452 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -53,6 +53,8 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include <linux/pnfs_xdr.h>
+#include <linux/nfs4_pnfs.h>
 #include "pnfs.h"
 
 #define OPENOWNER_POOL_SIZE	8
@@ -584,8 +586,24 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 	if (!call_close) {
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
-	} else
+	} else {
+		u32 roc_iomode;
+		struct nfs_inode *nfsi = NFS_I(state->inode);
+
+		if (has_layout(nfsi) &&
+		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
+			struct nfs4_pnfs_layout_segment range = {
+				.iomode = roc_iomode,
+				.offset = 0,
+				.length = NFS4_MAX_UINT64,
+			};
+
+			pnfs_return_layout(state->inode, &range, NULL,
+					   RETURN_FILE, wait);
+		}
+
 		nfs4_do_close(path, state, gfp_mask, wait);
+	}
 }
 
 void nfs4_close_state(struct path *path, struct nfs4_state *state, fmode_t fmode)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c63e2fb..82a3412 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -330,6 +330,12 @@ static int nfs4_stat_to_errno(int);
 				op_encode_hdr_maxsz +          \
 				encode_stateid_maxsz)
 #define decode_layoutcommit_maxsz (3 + op_decode_hdr_maxsz)
+#define encode_layoutreturn_sz	(8 + op_encode_hdr_maxsz + \
+				encode_stateid_maxsz + \
+				1 /* FIXME: opaque lrf_body always empty at
+				   *the moment */)
+#define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
+				1 + decode_stateid_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -743,6 +749,14 @@ static int nfs4_stat_to_errno(int);
 				decode_putfh_maxsz + \
 				decode_layoutcommit_maxsz + \
 				decode_getattr_maxsz)
+#define NFS4_enc_layoutreturn_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz + \
+				encode_layoutreturn_sz)
+#define NFS4_dec_layoutreturn_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_layoutreturn_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1862,6 +1876,34 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	hdr->replen += decode_layoutcommit_maxsz;
 	return 0;
 }
+
+static void
+encode_layoutreturn(struct xdr_stream *xdr,
+		    const struct nfs4_pnfs_layoutreturn_arg *args,
+		    struct compound_hdr *hdr)
+{
+	nfs4_stateid stateid;
+	__be32 *p;
+
+	p = reserve_space(xdr, 20);
+	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
+	*p++ = cpu_to_be32(args->reclaim);
+	*p++ = cpu_to_be32(args->layout_type);
+	*p++ = cpu_to_be32(args->lseg.iomode);
+	*p = cpu_to_be32(args->return_type);
+	if (args->return_type == RETURN_FILE) {
+		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
+		p = xdr_encode_hyper(p, args->lseg.offset);
+		p = xdr_encode_hyper(p, args->lseg.length);
+		pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout);
+		p = xdr_encode_opaque_fixed(p, &stateid.u.data,
+					    NFS4_STATEID_SIZE);
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(0);
+	}
+	hdr->nops++;
+	hdr->replen += decode_layoutreturn_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2753,6 +2795,26 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ * Encode LAYOUTRETURN request
+ */
+static int nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req, uint32_t *p,
+				     struct nfs4_pnfs_layoutreturn_arg *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
+	encode_layoutreturn(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -5127,6 +5189,27 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_layoutreturn(struct xdr_stream *xdr,
+			       struct nfs4_pnfs_layoutreturn_res *res)
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
 				    struct pnfs_layoutcommit_res *res)
@@ -6232,6 +6315,31 @@ out:
 }
 
 /*
+ * Decode LAYOUTRETURN response
+ */
+static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp, uint32_t *p,
+				     struct nfs4_pnfs_layoutreturn_res *res)
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
+	status = decode_layoutreturn(&xdr, res);
+out:
+	return status;
+}
+
+/*
  * Decode LAYOUTCOMMIT response
  */
 static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp, uint32_t *p,
@@ -6440,6 +6548,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
   PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
+  PROC(PNFS_LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2ea3cbd..9f17ef5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -669,7 +669,30 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
 	      bool wait)
 {
-	return 0;
+	struct nfs4_pnfs_layoutreturn *lrp;
+	struct nfs_server *server = NFS_SERVER(ino);
+	int status = -ENOMEM;
+
+	dprintk("--> %s\n", __func__);
+
+	BUG_ON(type != RETURN_FILE);
+
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (lrp == NULL) {
+		if (lo && (type == RETURN_FILE))
+			pnfs_layout_release(lo, NULL);
+		goto out;
+	}
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = server->pnfs_curr_ld->id;
+	lrp->args.return_type = type;
+	lrp->args.lseg = *range;
+	lrp->args.inode = ino;
+
+	status = pnfs4_proc_layoutreturn(lrp, wait);
+out:
+	dprintk("<-- %s status: %d\n", __func__, status);
+	return status;
 }
 
 int
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a1648c0..74b9a70 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -27,6 +27,7 @@ extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
 extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
 				   int issync);
+extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
 void put_lseg(struct pnfs_layout_segment *lseg);
@@ -34,6 +35,9 @@ void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
+int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
+			const nfs4_stateid *stateid, /* optional */
+			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
@@ -75,6 +79,30 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
+/* Should the pNFS client commit and return the layout on close
+ */
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
+{
+	return nfsi->layout->roc_iomode;
+}
+
+static inline int pnfs_return_layout(struct inode *ino,
+				     struct nfs4_pnfs_layout_segment *lseg,
+				     const nfs4_stateid *stateid, /* optional */
+				     enum pnfs_layoutreturn_type type,
+				     bool wait)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs_server *nfss = NFS_SERVER(ino);
+
+	if (pnfs_enabled_sb(nfss) &&
+	    (type != RETURN_FILE || has_layout(nfsi)))
+		return _pnfs_return_layout(ino, lseg, stateid, type, wait);
+
+	return 0;
+}
+
 static inline void pnfs_update_layout(struct inode *ino,
 	struct nfs_open_context *ctx,
 	enum pnfs_iomode access_type,
@@ -122,6 +150,27 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	return 0;
 }
 
+static inline bool
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	return false;
+}
+
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
+{
+	return 0;
+}
+
+static inline int pnfs_return_layout(struct inode *ino,
+				     struct nfs4_pnfs_layout_segment *lseg,
+				     const nfs4_stateid *stateid, /* optional */
+				     enum pnfs_layoutreturn_type type,
+				     bool wait)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index f0cf013..004a867 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -548,6 +548,7 @@ enum {
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_PNFS_LAYOUTGET,
 	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
+	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 };
 
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 4921778..ed16c65 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -88,6 +88,28 @@ struct pnfs_layoutcommit_data {
 	int status;
 };
 
+struct nfs4_pnfs_layoutreturn_arg {
+	__u32   reclaim;
+	__u32   layout_type;
+	__u32   return_type;
+	struct nfs4_pnfs_layout_segment lseg;
+	struct inode *inode;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_pnfs_layoutreturn_res {
+	struct nfs4_sequence_res seq_res;
+	u32 lrs_present;
+	nfs4_stateid stateid;
+};
+
+struct nfs4_pnfs_layoutreturn {
+	struct nfs4_pnfs_layoutreturn_arg args;
+	struct nfs4_pnfs_layoutreturn_res res;
+	struct rpc_cred *cred;
+	int rpc_status;
+};
+
 struct nfs4_pnfs_getdeviceinfo_arg {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.6.2.5

