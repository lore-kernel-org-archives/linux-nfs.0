Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35210 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f196.google.com with SMTP id h133so6821973ioe.2
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:33 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] pNFS: Allow layout drivers to manage private data in struct nfs4_layoutreturn
Date: Sat,  3 Dec 2016 15:57:19 -0500
Message-Id: <20161203205725.12961-5-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-4-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cleanup to allow layout drivers to attach private data to layoutreturn,
and manage the data.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 6 ++++++
 fs/nfs/nfs4xdr.c        | 4 +++-
 fs/nfs/pnfs.c           | 1 +
 include/linux/nfs_xdr.h | 2 ++
 4 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1c629f5e1ae5..f992281c9b29 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3039,6 +3039,7 @@ struct nfs4_closedata {
 	struct {
 		struct nfs4_layoutreturn_args arg;
 		struct nfs4_layoutreturn_res res;
+		struct nfs4_xdr_opaque_data ld_private;
 		u32 roc_barrier;
 		bool roc;
 	} lr;
@@ -3267,6 +3268,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
+	calldata->lr.arg.ld_private = &calldata->lr.ld_private;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
@@ -5599,6 +5601,7 @@ struct nfs4_delegreturndata {
 	struct {
 		struct nfs4_layoutreturn_args arg;
 		struct nfs4_layoutreturn_res res;
+		struct nfs4_xdr_opaque_data ld_private;
 		u32 roc_barrier;
 		bool roc;
 	} lr;
@@ -5735,6 +5738,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
 	data->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
+	data->lr.arg.ld_private = &data->lr.ld_private;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
@@ -8633,6 +8637,8 @@ static void nfs4_layoutreturn_release(void *calldata)
 	nfs4_sequence_free_slot(&lrp->res.seq_res);
 	pnfs_put_layout_hdr(lrp->args.layout);
 	nfs_iput_and_deactive(lrp->inode);
+	if (lrp->ld_private.ops && lrp->ld_private.ops->free)
+		lrp->ld_private.ops->free(&lrp->ld_private);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 84fdcf27138c..1c1768a8fcd1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2035,7 +2035,9 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	spin_lock(&args->inode->i_lock);
 	encode_nfs4_stateid(xdr, &args->stateid);
 	spin_unlock(&args->inode->i_lock);
-	if (lr_ops->encode_layoutreturn)
+	if (args->ld_private->ops && args->ld_private->ops->encode)
+		args->ld_private->ops->encode(xdr, args, args->ld_private);
+	else if (lr_ops->encode_layoutreturn)
 		lr_ops->encode_layoutreturn(xdr, args);
 	else
 		encode_uint32(xdr, 0);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0b25a1c820ba..4631d15227ae 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1086,6 +1086,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 	}
 
 	pnfs_init_layoutreturn_args(&lrp->args, lo, stateid, iomode);
+	lrp->args.ld_private = &lrp->ld_private;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 331a3200eb01..b64177d669fd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -320,6 +320,7 @@ struct nfs4_layoutreturn_args {
 	struct pnfs_layout_range range;
 	nfs4_stateid stateid;
 	__u32   layout_type;
+	struct nfs4_xdr_opaque_data *ld_private;
 };
 
 struct nfs4_layoutreturn_res {
@@ -335,6 +336,7 @@ struct nfs4_layoutreturn {
 	struct nfs_client *clp;
 	struct inode *inode;
 	int rpc_status;
+	struct nfs4_xdr_opaque_data ld_private;
 };
 
 #define PNFS_LAYOUTSTATS_MAXSIZE 256
-- 
2.9.3

