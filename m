Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117Ab0JOGRm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:42 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/12] RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
Date: Sun, 10 Oct 2010 11:22:52 -0400
Message-Id: <1286724173-8493-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Add the ability to actually send LAYOUTGET and GETDEVICEINFO.  This also adds
in the machinery to handle layout state and the deviceid cache.  Note that
GETDEVICEINFO is not called directly by the generic layer.  Instead it
is called by the drivers while parsing the LAYOUTGET opaque data in response
to an unknown device id embedded therein.  RFC 5661 only encodes
device ids within the driver-specific opaque data.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c         |  142 +++++++++++++++++
 fs/nfs/nfs4xdr.c          |  302 +++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c             |  385 +++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/pnfs.h             |   73 +++++++++-
 include/linux/nfs4.h      |    2 +
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_xdr.h   |   49 ++++++
 7 files changed, 921 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c3b1d98..e93025d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -55,6 +55,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "callback.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -5248,6 +5249,147 @@ out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
 }
+
+static void
+nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutget *lgp = calldata;
+	struct inode *ino = lgp->args.inode;
+	struct nfs_server *server = NFS_SERVER(ino);
+
+	dprintk("--> %s\n", __func__);
+	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
+				&lgp->res.seq_res, 0, task))
+		return;
+	rpc_call_start(task);
+}
+
+static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutget *lgp = calldata;
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
+
+	dprintk("--> %s\n", __func__);
+
+	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
+		return;
+
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_LAYOUTTRYLATER:
+	case -NFS4ERR_RECALLCONFLICT:
+		task->tk_status = -NFS4ERR_DELAY;
+		/* Fall through */
+	default:
+		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
+			rpc_restart_call_prepare(task);
+			return;
+		}
+	}
+	lgp->status = task->tk_status;
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs4_layoutget_release(void *calldata)
+{
+	struct nfs4_layoutget *lgp = calldata;
+
+	dprintk("--> %s\n", __func__);
+	put_layout_hdr(lgp->args.inode);
+	if (lgp->res.layout.buf != NULL)
+		free_page((unsigned long) lgp->res.layout.buf);
+	put_nfs_open_context(lgp->args.ctx);
+	kfree(calldata);
+	dprintk("<-- %s\n", __func__);
+}
+
+static const struct rpc_call_ops nfs4_layoutget_call_ops = {
+	.rpc_call_prepare = nfs4_layoutget_prepare,
+	.rpc_call_done = nfs4_layoutget_done,
+	.rpc_release = nfs4_layoutget_release,
+};
+
+int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
+{
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
+		.rpc_argp = &lgp->args,
+		.rpc_resp = &lgp->res,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_layoutget_call_ops,
+		.callback_data = lgp,
+		.flags = RPC_TASK_ASYNC,
+	};
+	int status = 0;
+
+	dprintk("--> %s\n", __func__);
+
+	lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
+	if (lgp->res.layout.buf == NULL) {
+		nfs4_layoutget_release(lgp);
+		return -ENOMEM;
+	}
+
+	lgp->res.seq_res.sr_slot = NULL;
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = lgp->status;
+	if (status != 0)
+		goto out;
+	status = pnfs_layout_process(lgp);
+out:
+	rpc_put_task(task);
+	dprintk("<-- %s status=%d\n", __func__, status);
+	return status;
+}
+
+static int
+_nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+{
+	struct nfs4_getdeviceinfo_args args = {
+		.pdev = pdev,
+	};
+	struct nfs4_getdeviceinfo_res res = {
+		.pdev = pdev,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICEINFO],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
+
+	return status;
+}
+
+int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(server,
+					_nfs4_proc_getdeviceinfo(server, pdev),
+					&exception);
+	} while (exception.retry);
+	return err;
+}
+EXPORT_SYMBOL_GPL(nfs4_proc_getdeviceinfo);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6e4d18d..225f1e0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -52,6 +52,7 @@
 #include <linux/nfs_idmap.h>
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
@@ -310,6 +311,19 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
+#define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
+				XDR_QUADLEN(NFS4_DEVICEID4_SIZE))
+#define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
+				1 /* layout type */ + \
+				1 /* opaque devaddr4 length */ + \
+				  /* devaddr4 payload is read into page */ \
+				1 /* notification bitmap length */ + \
+				1 /* notification bitmap */)
+#define encode_layoutget_maxsz	(op_encode_hdr_maxsz + 10 + \
+				encode_stateid_maxsz)
+#define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
+				decode_stateid_maxsz + \
+				XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -699,6 +713,20 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_reclaim_complete_maxsz)
+#define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
+				encode_sequence_maxsz +\
+				encode_getdeviceinfo_maxsz)
+#define NFS4_dec_getdeviceinfo_sz (compound_decode_hdr_maxsz +    \
+				decode_sequence_maxsz + \
+				decode_getdeviceinfo_maxsz)
+#define NFS4_enc_layoutget_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz +        \
+				encode_layoutget_maxsz)
+#define NFS4_dec_layoutget_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz +        \
+				decode_layoutget_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1726,6 +1754,58 @@ static void encode_sequence(struct xdr_stream *xdr,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+#ifdef CONFIG_NFS_V4_1
+static void
+encode_getdeviceinfo(struct xdr_stream *xdr,
+		     const struct nfs4_getdeviceinfo_args *args,
+		     struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 16 + NFS4_DEVICEID4_SIZE);
+	*p++ = cpu_to_be32(OP_GETDEVICEINFO);
+	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
+				    NFS4_DEVICEID4_SIZE);
+	*p++ = cpu_to_be32(args->pdev->layout_type);
+	*p++ = cpu_to_be32(args->pdev->pglen);		/* gdia_maxcount */
+	*p++ = cpu_to_be32(0);				/* bitmap length 0 */
+	hdr->nops++;
+	hdr->replen += decode_getdeviceinfo_maxsz;
+}
+
+static void
+encode_layoutget(struct xdr_stream *xdr,
+		      const struct nfs4_layoutget_args *args,
+		      struct compound_hdr *hdr)
+{
+	nfs4_stateid stateid;
+	__be32 *p;
+
+	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(OP_LAYOUTGET);
+	*p++ = cpu_to_be32(0);     /* Signal layout available */
+	*p++ = cpu_to_be32(args->type);
+	*p++ = cpu_to_be32(args->range.iomode);
+	p = xdr_encode_hyper(p, args->range.offset);
+	p = xdr_encode_hyper(p, args->range.length);
+	p = xdr_encode_hyper(p, args->minlength);
+	pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
+				args->ctx->state);
+	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(args->maxcount);
+
+	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
+		__func__,
+		args->type,
+		args->range.iomode,
+		(unsigned long)args->range.offset,
+		(unsigned long)args->range.length,
+		args->maxcount);
+	hdr->nops++;
+	hdr->replen += decode_layoutget_maxsz;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -2543,6 +2623,51 @@ static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
 	return 0;
 }
 
+/*
+ * Encode GETDEVICEINFO request
+ */
+static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
+				      struct nfs4_getdeviceinfo_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_getdeviceinfo(&xdr, args, &hdr);
+
+	/* set up reply kvec. Subtract notification bitmap max size (2)
+	 * so that notification bitmap is put in xdr_buf tail */
+	xdr_inline_pages(&req->rq_rcv_buf, (hdr.replen - 2) << 2,
+			 args->pdev->pages, args->pdev->pgbase,
+			 args->pdev->pglen);
+
+	encode_nops(&hdr);
+	return 0;
+}
+
+/*
+ *  Encode LAYOUTGET request
+ */
+static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
+				  struct nfs4_layoutget_args *args)
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
+	encode_layoutget(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -4783,6 +4908,134 @@ out_overflow:
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+static int decode_getdeviceinfo(struct xdr_stream *xdr,
+				struct pnfs_device *pdev)
+{
+	__be32 *p;
+	uint32_t len, type;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETDEVICEINFO);
+	if (status) {
+		if (status == -ETOOSMALL) {
+			p = xdr_inline_decode(xdr, 4);
+			if (unlikely(!p))
+				goto out_overflow;
+			pdev->mincount = be32_to_cpup(p);
+			dprintk("%s: Min count too small. mincnt = %u\n",
+				__func__, pdev->mincount);
+		}
+		return status;
+	}
+
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+	type = be32_to_cpup(p++);
+	if (type != pdev->layout_type) {
+		dprintk("%s: layout mismatch req: %u pdev: %u\n",
+			__func__, pdev->layout_type, type);
+		return -EINVAL;
+	}
+	/*
+	 * Get the length of the opaque device_addr4. xdr_read_pages places
+	 * the opaque device_addr4 in the xdr_buf->pages (pnfs_device->pages)
+	 * and places the remaining xdr data in xdr_buf->tail
+	 */
+	pdev->mincount = be32_to_cpup(p);
+	xdr_read_pages(xdr, pdev->mincount); /* include space for the length */
+
+	/* Parse notification bitmap, verifying that it is zero. */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	len = be32_to_cpup(p);
+	if (len) {
+		int i;
+
+		p = xdr_inline_decode(xdr, 4 * len);
+		if (unlikely(!p))
+			goto out_overflow;
+		for (i = 0; i < len; i++, p++) {
+			if (be32_to_cpup(p)) {
+				dprintk("%s: notifications not supported\n",
+					__func__);
+				return -EIO;
+			}
+		}
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
+			    struct nfs4_layoutget_res *res)
+{
+	__be32 *p;
+	int status;
+	u32 layout_count;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTGET);
+	if (status)
+		return status;
+	p = xdr_inline_decode(xdr, 8 + NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->return_on_close = be32_to_cpup(p++);
+	p = xdr_decode_opaque_fixed(p, res->stateid.data, NFS4_STATEID_SIZE);
+	layout_count = be32_to_cpup(p);
+	if (!layout_count) {
+		dprintk("%s: server responded with empty layout array\n",
+			__func__);
+		return -EINVAL;
+	}
+
+	p = xdr_inline_decode(xdr, 24);
+	if (unlikely(!p))
+		goto out_overflow;
+	p = xdr_decode_hyper(p, &res->range.offset);
+	p = xdr_decode_hyper(p, &res->range.length);
+	res->range.iomode = be32_to_cpup(p++);
+	res->type = be32_to_cpup(p++);
+
+	status = decode_opaque_inline(xdr, &res->layout.len, (char **)&p);
+	if (unlikely(status))
+		return status;
+
+	dprintk("%s roff:%lu rlen:%lu riomode:%d, lo_type:0x%x, lo.len:%d\n",
+		__func__,
+		(unsigned long)res->range.offset,
+		(unsigned long)res->range.length,
+		res->range.iomode,
+		res->type,
+		res->layout.len);
+
+	/* nfs4_proc_layoutget allocated a single page */
+	if (res->layout.len > PAGE_SIZE)
+		return -ENOMEM;
+	memcpy(res->layout.buf, p, res->layout.len);
+
+	if (layout_count > 1) {
+		/* We only handle a length one array at the moment.  Any
+		 * further entries are just ignored.  Note that this means
+		 * the client may see a response that is less than the
+		 * minimum it requested.
+		 */
+		dprintk("%s: server responded with %d layouts, dropping tail\n",
+			__func__, layout_count);
+	}
+
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -5810,6 +6063,53 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
 		status = decode_reclaim_complete(&xdr, (void *)NULL);
 	return status;
 }
+
+/*
+ * Decode GETDEVINFO response
+ */
+static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
+				      struct nfs4_getdeviceinfo_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status != 0)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status != 0)
+		goto out;
+	status = decode_getdeviceinfo(&xdr, res->pdev);
+out:
+	return status;
+}
+
+/*
+ * Decode LAYOUTGET response
+ */
+static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
+				  struct nfs4_layoutget_res *res)
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
+	status = decode_layoutget(&xdr, rqstp, res);
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -5988,6 +6288,8 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
+  PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
+  PROC(LAYOUTGET,  enc_layoutget,     dec_layoutget),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 891a0c3..d1ad7df 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -140,6 +140,11 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		printk(KERN_ERR "%s id 0 is reserved\n", __func__);
 		return status;
 	}
+	if (!ld_type->alloc_lseg || !ld_type->free_lseg) {
+		printk(KERN_ERR "%s Layout driver must provide "
+		       "alloc_lseg and free_lseg.\n", __func__);
+		return status;
+	}
 
 	spin_lock(&pnfs_spinlock);
 	tmp = find_pnfs_driver_locked(ld_type->id);
@@ -168,6 +173,10 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 }
 EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
 
+/*
+ * pNFS client layout cache
+ */
+
 static void
 get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
@@ -190,7 +199,7 @@ put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 	}
 }
 
-static void
+void
 put_layout_hdr(struct inode *inode)
 {
 	spin_lock(&inode->i_lock);
@@ -215,7 +224,7 @@ destroy_lseg(struct kref *kref)
 	struct inode *ino = lseg->layout->inode;
 
 	dprintk("--> %s\n", __func__);
-	kfree(lseg);
+	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 	put_layout_hdr(ino);
 }
@@ -249,6 +258,9 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 	/* List does not take a reference, so no need for put here */
 	list_del_init(&lo->layouts);
 	spin_unlock(&clp->cl_lock);
+	write_seqlock(&lo->seqlock);
+	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	write_sequnlock(&lo->seqlock);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -307,40 +319,135 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	}
 }
 
-static void pnfs_insert_layout(struct pnfs_layout_hdr *lo,
-			       struct pnfs_layout_segment *lseg);
+/* update lo->stateid with new if is more recent
+ *
+ * lo->stateid could be the open stateid, in which case we just use what given.
+ */
+static void
+pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
+			const nfs4_stateid *new)
+{
+	nfs4_stateid *old = &lo->stateid;
+	bool overwrite = false;
+
+	write_seqlock(&lo->seqlock);
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
+	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
+		overwrite = true;
+	else {
+		u32 oldseq, newseq;
+
+		oldseq = be32_to_cpu(old->stateid.seqid);
+		newseq = be32_to_cpu(new->stateid.seqid);
+		if ((int)(newseq - oldseq) > 0)
+			overwrite = true;
+	}
+	if (overwrite)
+		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
+	write_sequnlock(&lo->seqlock);
+}
+
+static void
+pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
+			      struct nfs4_state *state)
+{
+	int seq;
+
+	dprintk("--> %s\n", __func__);
+	write_seqlock(&lo->seqlock);
+	do {
+		seq = read_seqbegin(&state->seqlock);
+		memcpy(lo->stateid.data, state->stateid.data,
+		       sizeof(state->stateid.data));
+	} while (read_seqretry(&state->seqlock, seq));
+	set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	write_sequnlock(&lo->seqlock);
+	dprintk("<-- %s\n", __func__);
+}
+
+void
+pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
+			struct nfs4_state *open_state)
+{
+	int seq;
 
-/* Get layout from server. */
+	dprintk("--> %s\n", __func__);
+	do {
+		seq = read_seqbegin(&lo->seqlock);
+		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
+			/* This will trigger retry of the read */
+			pnfs_layout_from_open_stateid(lo, open_state);
+		} else
+			memcpy(dst->data, lo->stateid.data,
+			       sizeof(lo->stateid.data));
+	} while (read_seqretry(&lo->seqlock, seq));
+	dprintk("<-- %s\n", __func__);
+}
+
+/*
+* Get layout from server.
+*    for now, assume that whole file layouts are requested.
+*    arg->offset: 0
+*    arg->length: all ones
+*/
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
 	   u32 iomode)
 {
 	struct inode *ino = lo->inode;
-	struct pnfs_layout_segment *lseg;
+	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs4_layoutget *lgp;
+	struct pnfs_layout_segment *lseg = NULL;
+
+	dprintk("--> %s\n", __func__);
 
-	/* Lets pretend we sent LAYOUTGET and got a response */
-	lseg = kzalloc(sizeof(*lseg), GFP_KERNEL);
+	BUG_ON(ctx == NULL);
+	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
+	if (lgp == NULL) {
+		put_layout_hdr(lo->inode);
+		return NULL;
+	}
+	lgp->args.minlength = NFS4_MAX_UINT64;
+	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
+	lgp->args.range.iomode = iomode;
+	lgp->args.range.offset = 0;
+	lgp->args.range.length = NFS4_MAX_UINT64;
+	lgp->args.type = server->pnfs_curr_ld->id;
+	lgp->args.inode = ino;
+	lgp->args.ctx = get_nfs_open_context(ctx);
+	lgp->lsegpp = &lseg;
+
+	/* Synchronously retrieve layout information from server and
+	 * store in lseg.
+	 */
+	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
+		/* remember that LAYOUTGET failed and suspend trying */
 		set_bit(lo_fail_bit(iomode), &lo->state);
-		spin_lock(&ino->i_lock);
-		put_layout_hdr_locked(lo);
-		spin_unlock(&ino->i_lock);
-		return NULL;
 	}
-	init_lseg(lo, lseg);
-	lseg->iomode = IOMODE_RW;
-	spin_lock(&ino->i_lock);
-	pnfs_insert_layout(lo, lseg);
-	put_layout_hdr_locked(lo);
-	spin_unlock(&ino->i_lock);
 	return lseg;
 }
 
+/*
+ * Compare two layout segments for sorting into layout cache.
+ * We want to preferentially return RW over RO layouts, so ensure those
+ * are seen first.
+ */
+static s64
+cmp_layout(u32 iomode1, u32 iomode2)
+{
+	/* read > read/write */
+	return (int)(iomode2 == IOMODE_READ) - (int)(iomode1 == IOMODE_READ);
+}
+
 static void
 pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		   struct pnfs_layout_segment *lseg)
 {
+	struct pnfs_layout_segment *lp;
+	int found = 0;
+
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->inode->i_lock);
@@ -352,19 +459,28 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		list_add_tail(&lo->layouts, &clp->cl_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	get_layout_hdr_locked(lo);
-	/* STUB - add the constructed lseg if necessary */
-	if (list_empty(&lo->segs)) {
+	list_for_each_entry(lp, &lo->segs, fi_list) {
+		if (cmp_layout(lp->range.iomode, lseg->range.iomode) > 0)
+			continue;
+		list_add_tail(&lseg->fi_list, &lp->fi_list);
+		dprintk("%s: inserted lseg %p "
+			"iomode %d offset %llu length %llu before "
+			"lp %p iomode %d offset %llu length %llu\n",
+			__func__, lseg, lseg->range.iomode,
+			lseg->range.offset, lseg->range.length,
+			lp, lp->range.iomode, lp->range.offset,
+			lp->range.length);
+		found = 1;
+		break;
+	}
+	if (!found) {
 		list_add_tail(&lseg->fi_list, &lo->segs);
-		dprintk("%s: inserted lseg %p iomode %d at tail\n",
-			__func__, lseg, lseg->iomode);
-	} else {
-		/* There is no harm for the moment in calling this
-		 * with the lock held, and the call will be removed
-		 * with the STUB.
-		 */
-		put_lseg(lseg);
+		dprintk("%s: inserted lseg %p "
+			"iomode %d offset %llu length %llu at tail\n",
+			__func__, lseg, lseg->range.iomode,
+			lseg->range.offset, lseg->range.length);
 	}
+	get_layout_hdr_locked(lo);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -380,6 +496,7 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo->refcount = 1;
 	INIT_LIST_HEAD(&lo->layouts);
 	INIT_LIST_HEAD(&lo->segs);
+	seqlock_init(&lo->seqlock);
 	lo->inode = ino;
 	return lo;
 }
@@ -407,11 +524,46 @@ pnfs_find_alloc_layout(struct inode *ino)
 	return nfsi->layout;
 }
 
-/* STUB - LAYOUTGET never succeeds, so cache is empty */
+/*
+ * iomode matching rules:
+ * iomode	lseg	match
+ * -----	-----	-----
+ * ANY		READ	true
+ * ANY		RW	true
+ * RW		READ	false
+ * RW		RW	true
+ * READ		READ	true
+ * READ		RW	true
+ */
+static int
+is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
+{
+	return (iomode != IOMODE_RW || lseg->range.iomode == IOMODE_RW);
+}
+
+/*
+ * lookup range in layout
+ */
 static struct pnfs_layout_segment *
 pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
 {
-	return NULL;
+	struct pnfs_layout_segment *lseg, *ret = NULL;
+
+	dprintk("%s:Begin\n", __func__);
+
+	assert_spin_locked(&lo->inode->i_lock);
+	list_for_each_entry(lseg, &lo->segs, fi_list) {
+		if (is_matching_lseg(lseg, iomode)) {
+			ret = lseg;
+			break;
+		}
+		if (cmp_layout(iomode, lseg->range.iomode) > 0)
+			break;
+	}
+
+	dprintk("%s:Return lseg %p ref %d\n",
+		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0);
+	return ret;
 }
 
 /*
@@ -448,7 +600,7 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
 		goto out_unlock;
 
-	get_layout_hdr_locked(lo);
+	get_layout_hdr_locked(lo); /* Matched in nfs4_layoutget_release */
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, iomode);
@@ -460,3 +612,172 @@ out_unlock:
 	spin_unlock(&ino->i_lock);
 	goto out;
 }
+
+int
+pnfs_layout_process(struct nfs4_layoutget *lgp)
+{
+	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
+	struct nfs4_layoutget_res *res = &lgp->res;
+	struct pnfs_layout_segment *lseg;
+	struct inode *ino = lo->inode;
+	int status = 0;
+
+	/* Inject layout blob into I/O device driver */
+	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res);
+	if (!lseg || IS_ERR(lseg)) {
+		if (!lseg)
+			status = -ENOMEM;
+		else
+			status = PTR_ERR(lseg);
+		dprintk("%s: Could not allocate layout: error %d\n",
+		       __func__, status);
+		goto out;
+	}
+
+	spin_lock(&ino->i_lock);
+	init_lseg(lo, lseg);
+	lseg->range = res->range;
+	*lgp->lsegpp = lseg;
+	pnfs_insert_layout(lo, lseg);
+
+	/* Done processing layoutget. Set the layout stateid */
+	pnfs_set_layout_stateid(lo, &res->stateid);
+	spin_unlock(&ino->i_lock);
+out:
+	return status;
+}
+
+/*
+ * Device ID cache. Currently supports one layout type per struct nfs_client.
+ * Add layout type to the lookup key to expand to support multiple types.
+ */
+int
+pnfs_alloc_init_deviceid_cache(struct nfs_client *clp,
+			 void (*free_callback)(struct pnfs_deviceid_node *))
+{
+	struct pnfs_deviceid_cache *c;
+
+	c = kzalloc(sizeof(struct pnfs_deviceid_cache), GFP_KERNEL);
+	if (!c)
+		return -ENOMEM;
+	spin_lock(&clp->cl_lock);
+	if (clp->cl_devid_cache != NULL) {
+		atomic_inc(&clp->cl_devid_cache->dc_ref);
+		dprintk("%s [kref [%d]]\n", __func__,
+			atomic_read(&clp->cl_devid_cache->dc_ref));
+		kfree(c);
+	} else {
+		/* kzalloc initializes hlists */
+		spin_lock_init(&c->dc_lock);
+		atomic_set(&c->dc_ref, 1);
+		c->dc_free_callback = free_callback;
+		clp->cl_devid_cache = c;
+		dprintk("%s [new]\n", __func__);
+	}
+	spin_unlock(&clp->cl_lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(pnfs_alloc_init_deviceid_cache);
+
+/*
+ * Called from pnfs_layoutdriver_type->free_lseg
+ * last layout segment reference frees deviceid
+ */
+void
+pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
+		  struct pnfs_deviceid_node *devid)
+{
+	struct nfs4_deviceid *id = &devid->de_id;
+	struct pnfs_deviceid_node *d;
+	struct hlist_node *n;
+	long h = nfs4_deviceid_hash(id);
+
+	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
+	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
+		return;
+
+	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
+		if (!memcmp(&d->de_id, id, sizeof(*id))) {
+			hlist_del_rcu(&d->de_node);
+			spin_unlock(&c->dc_lock);
+			synchronize_rcu();
+			c->dc_free_callback(devid);
+			return;
+		}
+	spin_unlock(&c->dc_lock);
+	/* Why wasn't it found in  the list? */
+	BUG();
+}
+EXPORT_SYMBOL_GPL(pnfs_put_deviceid);
+
+/* Find and reference a deviceid */
+struct pnfs_deviceid_node *
+pnfs_find_get_deviceid(struct pnfs_deviceid_cache *c, struct nfs4_deviceid *id)
+{
+	struct pnfs_deviceid_node *d;
+	struct hlist_node *n;
+	long hash = nfs4_deviceid_hash(id);
+
+	dprintk("--> %s hash %ld\n", __func__, hash);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
+		if (!memcmp(&d->de_id, id, sizeof(*id))) {
+			if (!atomic_inc_not_zero(&d->de_ref)) {
+				goto fail;
+			} else {
+				rcu_read_unlock();
+				return d;
+			}
+		}
+	}
+fail:
+	rcu_read_unlock();
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(pnfs_find_get_deviceid);
+
+/*
+ * Add a deviceid to the cache.
+ * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
+ */
+struct pnfs_deviceid_node *
+pnfs_add_deviceid(struct pnfs_deviceid_cache *c, struct pnfs_deviceid_node *new)
+{
+	struct pnfs_deviceid_node *d;
+	long hash = nfs4_deviceid_hash(&new->de_id);
+
+	dprintk("--> %s hash %ld\n", __func__, hash);
+	spin_lock(&c->dc_lock);
+	d = pnfs_find_get_deviceid(c, &new->de_id);
+	if (d) {
+		spin_unlock(&c->dc_lock);
+		dprintk("%s [discard]\n", __func__);
+		c->dc_free_callback(new);
+		return d;
+	}
+	INIT_HLIST_NODE(&new->de_node);
+	atomic_set(&new->de_ref, 1);
+	hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
+	spin_unlock(&c->dc_lock);
+	dprintk("%s [new]\n", __func__);
+	return new;
+}
+EXPORT_SYMBOL_GPL(pnfs_add_deviceid);
+
+void
+pnfs_put_deviceid_cache(struct nfs_client *clp)
+{
+	struct pnfs_deviceid_cache *local = clp->cl_devid_cache;
+
+	dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_devid_cache);
+	if (atomic_dec_and_lock(&local->dc_ref, &clp->cl_lock)) {
+		int i;
+		/* Verify cache is empty */
+		for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++)
+			BUG_ON(!hlist_empty(&local->dc_deviceids[i]));
+		clp->cl_devid_cache = NULL;
+		spin_unlock(&clp->cl_lock);
+		kfree(local);
+	}
+}
+EXPORT_SYMBOL_GPL(pnfs_put_deviceid_cache);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1c3eb02..cbba28c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,7 +32,7 @@
 
 struct pnfs_layout_segment {
 	struct list_head fi_list;
-	u32 iomode;
+	struct pnfs_layout_range range;
 	struct kref kref;
 	struct pnfs_layout_hdr *layout;
 };
@@ -44,6 +44,7 @@ struct pnfs_layout_segment {
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
+	NFS_LAYOUT_STATEID_SET,		/* have a valid layout stateid */
 };
 
 /* Per-layout driver specific registration structure */
@@ -54,26 +55,96 @@ struct pnfs_layoutdriver_type {
 	struct module *owner;
 	int (*initialize_mountpoint) (struct nfs_server *);
 	int (*uninitialize_mountpoint) (struct nfs_server *);
+	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
+	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 };
 
 struct pnfs_layout_hdr {
 	unsigned long		refcount;
 	struct list_head	layouts;   /* other client layouts */
 	struct list_head	segs;      /* layout segments list */
+	seqlock_t		seqlock;   /* Protects the stateid */
+	nfs4_stateid		stateid;
 	unsigned long		state;
 	struct inode		*inode;
 };
 
+struct pnfs_device {
+	struct nfs4_deviceid dev_id;
+	unsigned int  layout_type;
+	unsigned int  mincount;
+	struct page **pages;
+	void          *area;
+	unsigned int  pgbase;
+	unsigned int  pglen;
+};
+
+/*
+ * Device ID RCU cache. A device ID is unique per client ID and layout type.
+ */
+#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
+#define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
+
+static inline u32
+nfs4_deviceid_hash(struct nfs4_deviceid *id)
+{
+	unsigned char *cptr = (unsigned char *)id->data;
+	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
+	u32 x = 0;
+
+	while (nbytes--) {
+		x *= 37;
+		x += *cptr++;
+	}
+	return x & NFS4_DEVICE_ID_HASH_MASK;
+}
+
+struct pnfs_deviceid_node {
+	struct hlist_node	de_node;
+	struct nfs4_deviceid	de_id;
+	atomic_t		de_ref;
+};
+
+struct pnfs_deviceid_cache {
+	spinlock_t		dc_lock;
+	atomic_t		dc_ref;
+	void			(*dc_free_callback)(struct pnfs_deviceid_node *);
+	struct hlist_head	dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
+};
+
+extern int pnfs_alloc_init_deviceid_cache(struct nfs_client *,
+			void (*free_callback)(struct pnfs_deviceid_node *));
+extern void pnfs_put_deviceid_cache(struct nfs_client *);
+extern struct pnfs_deviceid_node *pnfs_find_get_deviceid(
+				struct pnfs_deviceid_cache *,
+				struct nfs4_deviceid *);
+extern struct pnfs_deviceid_node *pnfs_add_deviceid(
+				struct pnfs_deviceid_cache *,
+				struct pnfs_deviceid_node *);
+extern void pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
+			      struct pnfs_deviceid_node *devid);
+
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
+/* nfs4proc.c */
+extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
+				   struct pnfs_device *dev);
+extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
+
+/* pnfs.c */
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
+void put_layout_hdr(struct inode *inode);
+void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
+			     struct nfs4_state *open_state);
 
 
 static inline int lo_fail_bit(u32 iomode)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 34da324..a9683d6 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -545,6 +545,8 @@ enum {
 	NFSPROC4_CLNT_SEQUENCE,
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
+	NFSPROC4_CLNT_LAYOUTGET,
+	NFSPROC4_CLNT_GETDEVICEINFO,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e670a9c..54acb68 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -83,6 +83,7 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
+	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d89920c..b90819b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -186,6 +186,55 @@ struct nfs4_get_lease_time_res {
 	struct nfs4_sequence_res	lr_seq_res;
 };
 
+#define PNFS_LAYOUT_MAXSIZE 4096
+
+struct nfs4_layoutdriver_data {
+	__u32 len;
+	void *buf;
+};
+
+struct pnfs_layout_range {
+	u32 iomode;
+	u64 offset;
+	u64 length;
+};
+
+struct nfs4_layoutget_args {
+	__u32 type;
+	struct pnfs_layout_range range;
+	__u64 minlength;
+	__u32 maxcount;
+	struct inode *inode;
+	struct nfs_open_context *ctx;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_layoutget_res {
+	__u32 return_on_close;
+	struct pnfs_layout_range range;
+	__u32 type;
+	nfs4_stateid stateid;
+	struct nfs4_layoutdriver_data layout;
+	struct nfs4_sequence_res seq_res;
+};
+
+struct nfs4_layoutget {
+	struct nfs4_layoutget_args args;
+	struct nfs4_layoutget_res res;
+	struct pnfs_layout_segment **lsegpp;
+	int status;
+};
+
+struct nfs4_getdeviceinfo_args {
+	struct pnfs_device *pdev;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_getdeviceinfo_res {
+	struct pnfs_device *pdev;
+	struct nfs4_sequence_res seq_res;
+};
+
 /*
  * Arguments to the open call.
  */
-- 
1.7.2.1

