Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34663 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759718AbcLAWTl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:41 -0500
Received: by mail-io0-f195.google.com with SMTP id r94so3917646ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:41 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/26] NFSv4: Add encode/decode of the layoutreturn op in DELEGRETURN
Date: Thu,  1 Dec 2016 17:19:13 -0500
Message-Id: <20161201221922.15657-18-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-17-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
 <20161201221922.15657-17-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add XDR encoding for the layoutreturn op, and storage for the layoutreturn
arguments to the DELEGRETURN compound.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 50 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4xdr.c        | 10 ++++++++++
 include/linux/nfs_xdr.h |  3 +++
 3 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9b9b0eabef9b..765af663257a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5608,11 +5608,15 @@ struct nfs4_delegreturndata {
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	unsigned long timestamp;
+	struct {
+		struct nfs4_layoutreturn_args arg;
+		struct nfs4_layoutreturn_res res;
+		u32 roc_barrier;
+		bool roc;
+	} lr;
 	struct nfs_fattr fattr;
 	int rpc_status;
 	struct inode *inode;
-	bool roc;
-	u32 roc_barrier;
 };
 
 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
@@ -5623,6 +5627,32 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		return;
 
 	trace_nfs4_delegreturn_exit(&data->args, &data->res, task->tk_status);
+
+	/* Handle Layoutreturn errors */
+	if (data->args.lr_args && task->tk_status != 0) {
+		switch(data->res.lr_ret) {
+		default:
+			data->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
+			break;
+		case 0:
+			data->args.lr_args = NULL;
+			data->res.lr_res = NULL;
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OLD_STATEID:
+		case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
+		case -NFS4ERR_WRONG_CRED:
+			data->args.lr_args = NULL;
+			data->res.lr_res = NULL;
+			data->res.lr_ret = 0;
+			rpc_restart_call_prepare(task);
+			return;
+		}
+	}
+
 	switch (task->tk_status) {
 	case 0:
 		renew_lease(data->res.server, data->timestamp);
@@ -5646,8 +5676,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		}
 	}
 	data->rpc_status = task->tk_status;
-	if (data->roc && data->rpc_status == 0)
-		pnfs_roc_set_barrier(data->inode, data->roc_barrier);
+	if (data->lr.roc && data->rpc_status == 0)
+		pnfs_roc_set_barrier(data->inode, data->lr.roc_barrier);
 }
 
 static void nfs4_delegreturn_release(void *calldata)
@@ -5656,7 +5686,7 @@ static void nfs4_delegreturn_release(void *calldata)
 	struct inode *inode = data->inode;
 
 	if (inode) {
-		if (data->roc)
+		if (data->lr.roc)
 			pnfs_roc_release(inode);
 		nfs_iput_and_deactive(inode);
 	}
@@ -5669,11 +5699,12 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (nfs4_wait_on_layoutreturn(d_data->inode, task))
+	if (!d_data->args.lr_args &&
+	    nfs4_wait_on_layoutreturn(d_data->inode, task))
 		return;
 
-	if (d_data->roc)
-		pnfs_roc_get_barrier(d_data->inode, &d_data->roc_barrier);
+	if (d_data->lr.roc)
+		pnfs_roc_get_barrier(d_data->inode, &d_data->lr.roc_barrier);
 
 	nfs4_setup_sequence(d_data->res.server,
 			&d_data->args.seq_args,
@@ -5720,12 +5751,13 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs4_stateid_copy(&data->stateid, stateid);
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
+	data->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
 	data->inode = nfs_igrab_and_active(inode);
 	if (data->inode)
-		data->roc = nfs4_roc(inode);
+		data->lr.roc = nfs4_roc(inode);
 
 	task_setup_data.callback_data = data;
 	msg.rpc_argp = &data->args;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 73d2a68f0698..84fdcf27138c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -710,11 +710,13 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_delegreturn_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
+				encode_layoutreturn_maxsz + \
 				encode_delegreturn_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_delegreturn_sz (compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
+				decode_layoutreturn_maxsz + \
 				decode_delegreturn_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_getacl_sz	(compound_encode_hdr_maxsz + \
@@ -2683,6 +2685,8 @@ static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fhandle, &hdr);
+	if (args->lr_args)
+		encode_layoutreturn(xdr, args->lr_args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_delegreturn(xdr, args->stateid, &hdr);
 	encode_nops(&hdr);
@@ -6942,6 +6946,12 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
+	if (res->lr_res) {
+		status = decode_layoutreturn(xdr, res->lr_res);
+		res->lr_ret = status;
+		if (status)
+			goto out;
+	}
 	status = decode_getfattr(xdr, res->fattr, res->server);
 	if (status != 0)
 		goto out;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 44ed64bb66ae..bfbd0cace91b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -552,12 +552,15 @@ struct nfs4_delegreturnargs {
 	const struct nfs_fh *fhandle;
 	const nfs4_stateid *stateid;
 	const u32 * bitmask;
+	struct nfs4_layoutreturn_args *lr_args;
 };
 
 struct nfs4_delegreturnres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr * fattr;
 	struct nfs_server *server;
+	struct nfs4_layoutreturn_res *lr_res;
+	int lr_ret;
 };
 
 /*
-- 
2.9.3

