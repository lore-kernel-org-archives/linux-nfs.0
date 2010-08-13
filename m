Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab0HMVcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:23 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 22/50] pnfs_submit: layoutget
Date: Fri, 13 Aug 2010 17:31:34 -0400
Message-Id: <1281735122-1496-23-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-22-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c        |  114 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c         |  156 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c            |   19 ++++++
 fs/nfs/pnfs.h            |    5 ++
 include/linux/nfs4.h     |    1 +
 include/linux/pnfs_xdr.h |   26 ++++++++
 6 files changed, 321 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 72e5132..279a37d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5366,6 +5366,120 @@ out:
 	return status;
 }
 
+static void
+nfs4_pnfs_layoutget_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_pnfs_layoutget *lgp = calldata;
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
+static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_pnfs_layoutget *lgp = calldata;
+	struct inode *ino = lgp->args.inode;
+	struct nfs_server *server = NFS_SERVER(ino);
+
+	dprintk("--> %s\n", __func__);
+
+	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
+		return;
+
+	if (RPC_ASSASSINATED(task))
+		return;
+
+	pnfs_get_layout_done(lgp, task->tk_status);
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
+
+	lgp->status = task->tk_status;
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs4_pnfs_layoutget_release(void *calldata)
+{
+	struct nfs4_pnfs_layoutget *lgp = calldata;
+
+	dprintk("--> %s\n", __func__);
+	pnfs_layout_release(NFS_I(lgp->args.inode)->layout, NULL);
+	if (lgp->res.layout.buf != NULL)
+		free_page((unsigned long) lgp->res.layout.buf);
+	kfree(calldata);
+	dprintk("<-- %s\n", __func__);
+}
+
+static const struct rpc_call_ops nfs4_pnfs_layoutget_call_ops = {
+	.rpc_call_prepare = nfs4_pnfs_layoutget_prepare,
+	.rpc_call_done = nfs4_pnfs_layoutget_done,
+	.rpc_release = nfs4_pnfs_layoutget_release,
+};
+
+/* FIXME: We need to call nfs4_handle_exception
+ * and deal with retries.
+ * Currently we can't since we release lgp and its contents.
+ */
+static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
+{
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTGET],
+		.rpc_argp = &lgp->args,
+		.rpc_resp = &lgp->res,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_pnfs_layoutget_call_ops,
+		.callback_data = lgp,
+		.flags = RPC_TASK_ASYNC,
+	};
+	int status = 0;
+
+	dprintk("--> %s\n", __func__);
+
+	lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
+	if (lgp->res.layout.buf == NULL) {
+		nfs4_pnfs_layoutget_release(lgp);
+		return -ENOMEM;
+	}
+
+	lgp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
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
+int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
+{
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = nfs4_handle_exception(server, _pnfs4_proc_layoutget(lgp),
+					    &exception);
+	} while (exception.retry);
+	return err;
+}
+
 int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
 	struct nfs4_pnfs_getdeviceinfo_arg args = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 25aa191..a096e5b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -320,6 +320,11 @@ static int nfs4_stat_to_errno(int);
 				4 /* opaque devaddr4 length */ +\
 				4 /* notification bitmap length */ + \
 				4 /* notification bitmap */)
+#define encode_layoutget_sz	(op_encode_hdr_maxsz + 10 + \
+				encode_stateid_maxsz)
+#define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
+				decode_stateid_maxsz + \
+				XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -715,6 +720,14 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_getdeviceinfo_sz (compound_decode_hdr_maxsz +    \
 				decode_sequence_maxsz + \
 				decode_getdeviceinfo_maxsz)
+#define NFS4_enc_layoutget_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz +        \
+				encode_layoutget_sz)
+#define NFS4_dec_layoutget_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz +        \
+				decode_layoutget_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1766,6 +1779,36 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 	hdr->nops++;
 }
 
+static void
+encode_layoutget(struct xdr_stream *xdr,
+		      const struct nfs4_pnfs_layoutget_arg *args,
+		      struct compound_hdr *hdr)
+{
+	nfs4_stateid stateid;
+	__be32 *p;
+
+	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(OP_LAYOUTGET);
+	*p++ = cpu_to_be32(0);     /* Signal layout available */
+	*p++ = cpu_to_be32(args->type);
+	*p++ = cpu_to_be32(args->lseg.iomode);
+	p = xdr_encode_hyper(p, args->lseg.offset);
+	p = xdr_encode_hyper(p, args->lseg.length);
+	p = xdr_encode_hyper(p, args->minlength);
+	pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout);
+	p = xdr_encode_opaque_fixed(p, &stateid.u.data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(args->maxcount);
+
+	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
+		__func__,
+		args->type,
+		args->lseg.iomode,
+		(unsigned long)args->lseg.offset,
+		(unsigned long)args->lseg.length,
+		args->maxcount);
+	hdr->nops++;
+	hdr->replen += decode_layoutget_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2617,6 +2660,25 @@ static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
 	return 0;
 }
 
+/*
+ *  Encode LAYOUTGET request
+ */
+static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
+				  struct nfs4_pnfs_layoutget_arg *args)
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
@@ -4921,6 +4983,75 @@ out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
+
+static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
+			    struct nfs4_pnfs_layoutget_res *res)
+{
+	__be32 *p;
+	int status;
+	u32 layout_count, dummy;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTGET);
+	if (status)
+		return status;
+	p = xdr_inline_decode(xdr, 8 + NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->return_on_close = be32_to_cpup(p++);
+	p = xdr_decode_opaque_fixed(p, res->stateid.u.data, NFS4_STATEID_SIZE);
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
+	p = xdr_decode_hyper(p, &res->lseg.offset);
+	p = xdr_decode_hyper(p, &res->lseg.length);
+	res->lseg.iomode = be32_to_cpup(p++);
+	res->type = be32_to_cpup(p++);
+
+	status = decode_opaque_inline(xdr, &res->layout.len, (char **)&p);
+	if (unlikely(status))
+		return status;
+
+	dprintk("%s roff:%lu rlen:%lu riomode:%d, lo_type:0x%x, lo.len:%d\n",
+		__func__,
+		(unsigned long)res->lseg.offset,
+		(unsigned long)res->lseg.length,
+		res->lseg.iomode,
+		res->type,
+		res->layout.len);
+
+	/* presuambly, pnfs4_proc_layoutget allocated a single page */
+	if (res->layout.len > PAGE_SIZE)
+		return -ENOMEM;
+	memcpy(res->layout.buf, p, res->layout.len);
+
+	/* FIXME: the whole layout array should be passed up to the pnfs
+	 * client */
+	if (layout_count > 1) {
+		dprintk("%s: server responded with %d layouts, dropping tail\n",
+			__func__, layout_count);
+
+		while (--layout_count) {
+			p = xdr_inline_decode(xdr, 24);
+			if (unlikely(!p))
+				goto out_overflow;
+			status = decode_opaque_inline(xdr, &dummy, (char **)&p);
+			if (unlikely(status))
+				return status;
+		}
+	}
+
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -5973,6 +6104,30 @@ out:
 	return status;
 }
 
+/*
+ * Decode LAYOUTGET response
+ */
+static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
+				  struct nfs4_pnfs_layoutget_res *res)
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
@@ -6152,6 +6307,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
   PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
+  PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cfee1d6..36a3056 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -256,6 +256,12 @@ put_layout(struct inode *inode)
 }
 
 void
+pnfs_layout_release(struct pnfs_layout_type *lo,
+		    struct nfs4_pnfs_layout_segment *range)
+{
+}
+
+void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 	struct pnfs_layout_type *lo;
@@ -525,6 +531,19 @@ pnfs_alloc_layout(struct inode *ino)
 	return nfsi->layout;
 }
 
+void
+pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
+{
+}
+
+int
+pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
+{
+	int status = 0;
+
+	return status;
+}
+
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d8de4c1..8c1d50e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -24,11 +24,16 @@
 /* nfs4proc.c */
 extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
+extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
+
 /* pnfs.c */
 void put_lseg(struct pnfs_layout_segment *lseg);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
+void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
+int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
+void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 06912b0..a5f5c94 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -546,6 +546,7 @@ enum {
 	NFSPROC4_CLNT_SEQUENCE,
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
+	NFSPROC4_CLNT_PNFS_LAYOUTGET,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 };
 
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index e6743f3..b85320d 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -19,6 +19,10 @@ struct pnfs_deviceid {
 	char data[NFS4_PNFS_DEVICEID4_SIZE];
 };
 
+struct nfs4_pnfs_layout {
+	__u32 len;
+	void *buf;
+};
 
 struct nfs4_pnfs_layout_segment {
 	u32 iomode;
@@ -26,7 +30,29 @@ struct nfs4_pnfs_layout_segment {
 	u64 length;
 };
 
+struct nfs4_pnfs_layoutget_arg {
+	__u32 type;
+	struct nfs4_pnfs_layout_segment lseg;
+	__u64 minlength;
+	__u32 maxcount;
+	struct inode *inode;
+	struct nfs4_sequence_args seq_args;
+};
+
 struct nfs4_pnfs_layoutget_res {
+	__u32 return_on_close;
+	struct nfs4_pnfs_layout_segment lseg;
+	__u32 type;
+	nfs4_stateid stateid;
+	struct nfs4_pnfs_layout layout;
+	struct nfs4_sequence_res seq_res;
+};
+
+struct nfs4_pnfs_layoutget {
+	struct nfs4_pnfs_layoutget_arg args;
+	struct nfs4_pnfs_layoutget_res res;
+	struct pnfs_layout_segment **lsegpp;
+	int status;
 };
 
 struct nfs4_pnfs_getdeviceinfo_arg {
-- 
1.6.2.5

