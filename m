Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:58580 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYAR1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:27 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so3200185igk.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:26 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Fix lock on-wire reordering issues
Date: Sat, 24 Jan 2015 19:17:19 -0500
Message-Id: <1422145041-81669-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145041-81669-3-git-send-email-trond.myklebust@primarydata.com>
References: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensures that the server cannot reorder our LOCK/LOCKU
requests if they are sent in parallel on the wire.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 29 ++++++++++++++++++++++++-----
 fs/nfs/nfs4xdr.c        |  6 +++---
 include/linux/nfs_xdr.h |  6 +++---
 3 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f12ded041a42..41e7c2fc046e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5393,7 +5393,6 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.fl = &p->fl;
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
-	p->arg.stateid = &lsp->ls_stateid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
@@ -5428,6 +5427,9 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
+			if (!nfs4_stateid_match(&calldata->arg.stateid,
+						&calldata->lsp->ls_stateid))
+				rpc_restart_call_prepare(task);
 			break;
 		default:
 			if (nfs4_async_handle_error(task, calldata->server,
@@ -5443,6 +5445,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		goto out_wait;
+	nfs4_stateid_copy(&calldata->arg.stateid, &calldata->lsp->ls_stateid);
 	if (test_bit(NFS_LOCK_INITIALIZED, &calldata->lsp->ls_flags) == 0) {
 		/* Note: exit _without_ running nfs4_locku_done */
 		goto out_no_action;
@@ -5584,7 +5587,6 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid, gfp_mask);
 	if (IS_ERR(p->arg.lock_seqid))
 		goto out_free_seqid;
-	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_seqid.owner_id;
 	p->arg.lock_owner.s_dev = server->s_dev;
@@ -5615,11 +5617,15 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0) {
 			goto out_release_lock_seqid;
 		}
-		data->arg.open_stateid = &state->open_stateid;
+		nfs4_stateid_copy(&data->arg.open_stateid,
+				&state->open_stateid);
 		data->arg.new_lock_owner = 1;
 		data->res.open_seqid = data->arg.open_seqid;
-	} else
+	} else {
 		data->arg.new_lock_owner = 0;
+		nfs4_stateid_copy(&data->arg.lock_stateid,
+				&data->lsp->ls_stateid);
+	}
 	if (!nfs4_valid_open_stateid(state)) {
 		data->rpc_status = -EBADF;
 		task->tk_action = NULL;
@@ -5651,7 +5657,8 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 		return;
 
 	data->rpc_status = task->tk_status;
-	if (task->tk_status == 0) {
+	switch (task->tk_status) {
+	case 0:
 		renew_lease(NFS_SERVER(data->ctx->dentry->d_inode),
 				data->timestamp);
 		if (data->arg.new_lock_owner != 0) {
@@ -5660,6 +5667,18 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
 		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
 			rpc_restart_call_prepare(task);
+		break;
+	case -NFS4ERR_BAD_STATEID:
+	case -NFS4ERR_OLD_STATEID:
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_EXPIRED:
+		if (data->arg.new_lock_owner != 0) {
+			if (!nfs4_stateid_match(&data->arg.open_stateid,
+						&lsp->ls_state->open_stateid))
+				rpc_restart_call_prepare(task);
+		} else if (!nfs4_stateid_match(&data->arg.lock_stateid,
+						&lsp->ls_stateid))
+				rpc_restart_call_prepare(task);
 	}
 	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d05fada4929c..e3018e7a316c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1304,12 +1304,12 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	*p = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
 		encode_nfs4_seqid(xdr, args->open_seqid);
-		encode_nfs4_stateid(xdr, args->open_stateid);
+		encode_nfs4_stateid(xdr, &args->open_stateid);
 		encode_nfs4_seqid(xdr, args->lock_seqid);
 		encode_lockowner(xdr, &args->lock_owner);
 	}
 	else {
-		encode_nfs4_stateid(xdr, args->lock_stateid);
+		encode_nfs4_stateid(xdr, &args->lock_stateid);
 		encode_nfs4_seqid(xdr, args->lock_seqid);
 	}
 }
@@ -1333,7 +1333,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	encode_op_hdr(xdr, OP_LOCKU, decode_locku_maxsz, hdr);
 	encode_uint32(xdr, nfs4_lock_type(args->fl, 0));
 	encode_nfs4_seqid(xdr, args->seqid);
-	encode_nfs4_stateid(xdr, args->stateid);
+	encode_nfs4_stateid(xdr, &args->stateid);
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	xdr_encode_hyper(p, nfs4_lock_length(args->fl));
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7e38d641236e..b6a6953c0f09 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -416,9 +416,9 @@ struct nfs_lock_args {
 	struct nfs_fh *		fh;
 	struct file_lock *	fl;
 	struct nfs_seqid *	lock_seqid;
-	nfs4_stateid *		lock_stateid;
+	nfs4_stateid		lock_stateid;
 	struct nfs_seqid *	open_seqid;
-	nfs4_stateid *		open_stateid;
+	nfs4_stateid		open_stateid;
 	struct nfs_lowner	lock_owner;
 	unsigned char		block : 1;
 	unsigned char		reclaim : 1;
@@ -437,7 +437,7 @@ struct nfs_locku_args {
 	struct nfs_fh *		fh;
 	struct file_lock *	fl;
 	struct nfs_seqid *	seqid;
-	nfs4_stateid *		stateid;
+	nfs4_stateid 		stateid;
 };
 
 struct nfs_locku_res {
-- 
2.1.0

