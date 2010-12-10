Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab0LJGIn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:43 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLh023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:43 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/22] Revert "pnfs-submit refactor layoutcommit xdr structures"
Date: Thu,  9 Dec 2010 20:22:41 -0500
Message-Id: <1291944177-7819-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 4cce4b96893b2d76a3e65c6dc84dc86425ee718b.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |   23 ++++++++++++-----------
 fs/nfs/nfs4xdr.c        |   27 +++++++++++++++++----------
 fs/nfs/pnfs.c           |   21 ++++++++++++---------
 include/linux/nfs_xdr.h |   19 ++++++++++---------
 4 files changed, 51 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3a1e578..f993a4a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5530,7 +5530,7 @@ static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_layoutcommit_data *ldata =
 		(struct nfs4_layoutcommit_data *)data;
-	struct nfs_server *server = NFS_SERVER(ldata->inode);
+	struct nfs_server *server = NFS_SERVER(ldata->args.inode);
 
 	if (nfs4_setup_sequence(server, NULL, &ldata->args.seq_args,
 				&ldata->res.seq_res, 1, task))
@@ -5543,7 +5543,7 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutcommit_data *data =
 		(struct nfs4_layoutcommit_data *)calldata;
-	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
@@ -5560,8 +5560,8 @@ static void nfs4_layoutcommit_release(void *lcdata)
 		(struct nfs4_layoutcommit_data *)lcdata;
 
 	/* Matched by get_layout in pnfs_layoutcommit_inode */
-	put_layout_hdr(data->inode);
-	put_rpccred(data->args.cred);
+	put_layout_hdr(data->args.inode);
+	put_rpccred(data->cred);
 	kfree(lcdata);
 }
 
@@ -5579,11 +5579,11 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int issync)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTCOMMIT],
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = data->args.cred,
+		.rpc_cred = data->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.task = &data->task,
-		.rpc_client = NFS_CLIENT(data->inode),
+		.rpc_client = NFS_CLIENT(data->args.inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutcommit_ops,
 		.callback_data = data,
@@ -5592,12 +5592,13 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int issync)
 	struct rpc_task *task;
 	int status = 0;
 
-	dprintk("NFS: initiating layoutcommit call. %llu@%llu lbw: %llu "
+	dprintk("NFS: %4d initiating layoutcommit call. %llu@%llu lbw: %llu "
 		"type: %d issync %d\n",
-		data->args.op.range.length,
-		data->args.op.range.offset,
-		data->args.op.lastbytewritten,
-		data->args.op.layout_type, issync);
+		data->task.tk_pid,
+		data->args.range.length,
+		data->args.range.offset,
+		data->args.lastbytewritten,
+		data->args.layout_type, issync);
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dc63895..eb5c922 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1868,7 +1868,7 @@ encode_layoutget(struct xdr_stream *xdr,
 
 static int
 encode_layoutcommit(struct xdr_stream *xdr,
-		    const struct nfs4_layoutcommit_op_args *args,
+		    const struct nfs4_layoutcommit_args *args,
 		    struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1885,7 +1885,14 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1);     /* newoffset = TRUE */
 	p = xdr_encode_hyper(p, args->lastbytewritten);
-	*p = cpu_to_be32(0); /* nt_timechanged = FALSE */
+	*p = cpu_to_be32(args->time_modify_changed != 0);
+	if (args->time_modify_changed) {
+		p = reserve_space(xdr, 12);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(args->time_modify.tv_sec);
+		*p = cpu_to_be32(args->time_modify.tv_nsec);
+	}
+
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(args->layout_type);
 
@@ -2812,7 +2819,7 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req, uint32_t *p,
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
-	encode_layoutcommit(&xdr, &args->op, &hdr);
+	encode_layoutcommit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 	return 0;
@@ -5301,10 +5308,10 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_layoutcommit(struct xdr_stream *xdr)
+static int decode_layoutcommit(struct xdr_stream *xdr,
+				    struct rpc_rqst *req,
+				    struct nfs4_layoutcommit_res *res)
 {
-	u32 sizechanged;
-	u64 newsize;
 	__be32 *p;
 	int status;
 
@@ -5315,13 +5322,13 @@ static int decode_layoutcommit(struct xdr_stream *xdr)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	sizechanged = be32_to_cpup(p);
+	res->sizechanged = be32_to_cpup(p);
 
-	if (sizechanged) {
+	if (res->sizechanged) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		xdr_decode_hyper(p, &newsize);
+		xdr_decode_hyper(p, &res->newsize);
 	}
 	return 0;
 out_overflow:
@@ -6456,7 +6463,7 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp, uint32_t *p,
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_layoutcommit(&xdr);
+	status = decode_layoutcommit(&xdr, rqstp, res);
 	if (status)
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 36955e1..8dbac82 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1203,18 +1203,21 @@ pnfs_layoutcommit_setup(struct inode *inode,
 
 	dprintk("--> %s\n", __func__);
 
-	data->inode = inode;
+	data->args.inode = inode;
 	data->args.fh = NFS_FH(inode);
-	data->args.op.layout_type = nfss->pnfs_curr_ld->id;
+	data->args.layout_type = nfss->pnfs_curr_ld->id;
 	data->res.fattr = &data->fattr;
 	nfs_fattr_init(&data->fattr);
 
+	/* TODO: Need to determine the correct values */
+	data->args.time_modify_changed = 0;
+
 	/* Set values from inode so it can be reset
 	 */
-	data->args.op.range.iomode = IOMODE_RW;
-	data->args.op.range.offset = write_begin_pos;
-	data->args.op.range.length = write_end_pos - write_begin_pos + 1;
-	data->args.op.lastbytewritten =  min(write_end_pos,
+	data->args.range.iomode = IOMODE_RW;
+	data->args.range.offset = write_begin_pos;
+	data->args.range.length = write_end_pos - write_begin_pos + 1;
+	data->args.lastbytewritten =  min(write_end_pos,
 					  i_size_read(inode) - 1);
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
@@ -1254,12 +1257,12 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	 */
 	write_begin_pos = nfsi->layout->write_begin_pos;
 	write_end_pos = nfsi->layout->write_end_pos;
-	data->args.cred = nfsi->layout->cred;
+	data->cred = nfsi->layout->cred;
 	nfsi->layout->write_begin_pos = 0;
 	nfsi->layout->write_end_pos = 0;
 	nfsi->layout->cred = NULL;
 	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
-	memcpy(data->args.op.stateid.data, nfsi->layout->stateid.data,
+	memcpy(data->args.stateid.data, nfsi->layout->stateid.data,
 	       NFS4_STATEID_SIZE);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
@@ -1272,7 +1275,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 					 write_end_pos);
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
-		put_rpccred(data->args.cred);
+		put_rpccred(data->cred);
 		put_layout_hdr(inode);
 		goto out_free;
 	}
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1b7364f..ece0b2e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -225,24 +225,25 @@ struct nfs4_layoutget {
 	struct pnfs_layout_segment **lsegpp;
 };
 
-struct nfs4_layoutcommit_op_args {
+struct nfs4_layoutcommit_args {
 	nfs4_stateid stateid;
 	__u64 lastbytewritten;
+	__u32 time_modify_changed;
+	struct timespec time_modify;
+	const u32 *bitmask;
+	struct nfs_fh *fh;
+	struct inode *inode;
 
 	/* Values set by layout driver */
 	struct pnfs_layout_range range;
 	__u32 layout_type;
-};
-
-struct nfs4_layoutcommit_args {
-	struct nfs4_layoutcommit_op_args op;
-	const u32 *bitmask;
-	struct nfs_fh *fh;
-	struct rpc_cred *cred;
+	void *layoutdriver_data;
 	struct nfs4_sequence_args seq_args;
 };
 
 struct nfs4_layoutcommit_res {
+	__u32 sizechanged;
+	__u64 newsize;
 	struct nfs_fattr *fattr;
 	const struct nfs_server *server;
 	struct nfs4_sequence_res seq_res;
@@ -250,7 +251,7 @@ struct nfs4_layoutcommit_res {
 
 struct nfs4_layoutcommit_data {
 	struct rpc_task task;
-	struct inode *inode;
+	struct rpc_cred *cred;
 	struct nfs_fattr fattr;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;
-- 
1.7.2.1

