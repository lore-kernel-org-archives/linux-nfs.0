Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:51027 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:50 -0400
Received: by mail-it0-f65.google.com with SMTP id j81-v6so11524304ite.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:14 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:13 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] NFS: Convert lookups of the open context to RCU
Date: Wed,  5 Sep 2018 15:23:58 -0400
Message-Id: <20180905192400.107485-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-5-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
 <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com>
 <20180905192400.107485-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce contention on the inode->i_lock by ensuring that we use RCU
when looking up the NFS open context.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c    | 11 ++++++-----
 fs/nfs/inode.c         | 35 +++++++++++++++--------------------
 fs/nfs/nfs4proc.c      | 30 ++++++++++++++++++++++++------
 fs/nfs/nfs4state.c     | 12 ++++++------
 fs/nfs/pnfs.c          |  5 ++++-
 include/linux/nfs_fs.h |  1 +
 6 files changed, 56 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index f033f3a69a3b..76d205d1c7bc 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -136,8 +136,8 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 	int err;
 
 again:
-	spin_lock(&inode->i_lock);
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ctx, &nfsi->open_files, list) {
 		state = ctx->state;
 		if (state == NULL)
 			continue;
@@ -147,8 +147,9 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 			continue;
 		if (!nfs4_stateid_match(&state->stateid, stateid))
 			continue;
-		get_nfs_open_context(ctx);
-		spin_unlock(&inode->i_lock);
+		if (!get_nfs_open_context(ctx))
+			continue;
+		rcu_read_unlock();
 		sp = state->owner;
 		/* Block nfs4_proc_unlck */
 		mutex_lock(&sp->so_delegreturn_mutex);
@@ -164,7 +165,7 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 			return err;
 		goto again;
 	}
-	spin_unlock(&inode->i_lock);
+	rcu_read_unlock();
 	return 0;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 052db41a7f80..5b1eee4952b7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -977,9 +977,9 @@ EXPORT_SYMBOL_GPL(alloc_nfs_open_context);
 
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
-	if (ctx != NULL)
-		refcount_inc(&ctx->lock_context.count);
-	return ctx;
+	if (ctx != NULL && refcount_inc_not_zero(&ctx->lock_context.count))
+		return ctx;
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
@@ -988,13 +988,13 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	struct inode *inode = d_inode(ctx->dentry);
 	struct super_block *sb = ctx->dentry->d_sb;
 
+	if (!refcount_dec_and_test(&ctx->lock_context.count))
+		return;
 	if (!list_empty(&ctx->list)) {
-		if (!refcount_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
-			return;
-		list_del(&ctx->list);
+		spin_lock(&inode->i_lock);
+		list_del_rcu(&ctx->list);
 		spin_unlock(&inode->i_lock);
-	} else if (!refcount_dec_and_test(&ctx->lock_context.count))
-		return;
+	}
 	if (inode != NULL)
 		NFS_PROTO(inode)->close_context(ctx, is_sync);
 	if (ctx->cred != NULL)
@@ -1002,7 +1002,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	dput(ctx->dentry);
 	nfs_sb_deactive(sb);
 	kfree(ctx->mdsthreshold);
-	kfree(ctx);
+	kfree_rcu(ctx, rcu_head);
 }
 
 void put_nfs_open_context(struct nfs_open_context *ctx)
@@ -1026,10 +1026,7 @@ void nfs_inode_attach_open_context(struct nfs_open_context *ctx)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
-	if (ctx->mode & FMODE_WRITE)
-		list_add(&ctx->list, &nfsi->open_files);
-	else
-		list_add_tail(&ctx->list, &nfsi->open_files);
+	list_add_tail_rcu(&ctx->list, &nfsi->open_files);
 	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
@@ -1050,16 +1047,17 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_open_context *pos, *ctx = NULL;
 
-	spin_lock(&inode->i_lock);
-	list_for_each_entry(pos, &nfsi->open_files, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pos, &nfsi->open_files, list) {
 		if (cred != NULL && pos->cred != cred)
 			continue;
 		if ((pos->mode & (FMODE_READ|FMODE_WRITE)) != mode)
 			continue;
 		ctx = get_nfs_open_context(pos);
-		break;
+		if (ctx)
+			break;
 	}
-	spin_unlock(&inode->i_lock);
+	rcu_read_unlock();
 	return ctx;
 }
 
@@ -1077,9 +1075,6 @@ void nfs_file_clear_open_context(struct file *filp)
 		if (ctx->error < 0)
 			invalidate_inode_pages2(inode->i_mapping);
 		filp->private_data = NULL;
-		spin_lock(&inode->i_lock);
-		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
-		spin_unlock(&inode->i_lock);
 		put_nfs_open_context_sync(ctx);
 	}
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8220a168282e..10c20a5b075d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1933,23 +1933,41 @@ nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 	return ret;
 }
 
-static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *state)
+static struct nfs_open_context *
+nfs4_state_find_open_context_mode(struct nfs4_state *state, fmode_t mode)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_open_context *ctx;
 
-	spin_lock(&state->inode->i_lock);
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ctx, &nfsi->open_files, list) {
 		if (ctx->state != state)
 			continue;
-		get_nfs_open_context(ctx);
-		spin_unlock(&state->inode->i_lock);
+		if ((ctx->mode & mode) != mode)
+			continue;
+		if (!get_nfs_open_context(ctx))
+			continue;
+		rcu_read_unlock();
 		return ctx;
 	}
-	spin_unlock(&state->inode->i_lock);
+	rcu_read_unlock();
 	return ERR_PTR(-ENOENT);
 }
 
+static struct nfs_open_context *
+nfs4_state_find_open_context(struct nfs4_state *state)
+{
+	struct nfs_open_context *ctx;
+
+	ctx = nfs4_state_find_open_context_mode(state, FMODE_READ|FMODE_WRITE);
+	if (!IS_ERR(ctx))
+		return ctx;
+	ctx = nfs4_state_find_open_context_mode(state, FMODE_WRITE);
+	if (!IS_ERR(ctx))
+		return ctx;
+	return nfs4_state_find_open_context_mode(state, FMODE_READ);
+}
+
 static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx,
 		struct nfs4_state *state, enum open_claim_type4 claim)
 {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 40a08cd483f0..be92ce4259e9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1437,8 +1437,8 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 	struct nfs4_state *state;
 	bool found = false;
 
-	spin_lock(&inode->i_lock);
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ctx, &nfsi->open_files, list) {
 		state = ctx->state;
 		if (state == NULL)
 			continue;
@@ -1456,7 +1456,7 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		    nfs4_state_mark_reclaim_nograce(clp, state))
 			found = true;
 	}
-	spin_unlock(&inode->i_lock);
+	rcu_read_unlock();
 
 	nfs_inode_find_delegation_state_and_recover(inode, stateid);
 	if (found)
@@ -1469,13 +1469,13 @@ static void nfs4_state_mark_open_context_bad(struct nfs4_state *state)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_open_context *ctx;
 
-	spin_lock(&inode->i_lock);
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ctx, &nfsi->open_files, list) {
 		if (ctx->state != state)
 			continue;
 		set_bit(NFS_CONTEXT_BAD, &ctx->flags);
 	}
-	spin_unlock(&inode->i_lock);
+	rcu_read_unlock();
 }
 
 static void nfs4_state_mark_recovery_failed(struct nfs4_state *state, int error)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c5672c02afd6..06cb90e9bc6e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1339,6 +1339,7 @@ bool pnfs_roc(struct inode *ino,
 	if (!nfs_have_layout(ino))
 		return false;
 retry:
+	rcu_read_lock();
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
 	if (!lo || !pnfs_layout_is_valid(lo) ||
@@ -1349,6 +1350,7 @@ bool pnfs_roc(struct inode *ino,
 	pnfs_get_layout_hdr(lo);
 	if (test_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags)) {
 		spin_unlock(&ino->i_lock);
+		rcu_read_unlock();
 		wait_on_bit(&lo->plh_flags, NFS_LAYOUT_RETURN,
 				TASK_UNINTERRUPTIBLE);
 		pnfs_put_layout_hdr(lo);
@@ -1362,7 +1364,7 @@ bool pnfs_roc(struct inode *ino,
 		skip_read = true;
 	}
 
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
+	list_for_each_entry_rcu(ctx, &nfsi->open_files, list) {
 		state = ctx->state;
 		if (state == NULL)
 			continue;
@@ -1410,6 +1412,7 @@ bool pnfs_roc(struct inode *ino,
 
 out_noroc:
 	spin_unlock(&ino->i_lock);
+	rcu_read_unlock();
 	pnfs_layoutcommit_inode(ino, true);
 	if (roc) {
 		struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d2f4f88a0e66..6e0417c02279 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -83,6 +83,7 @@ struct nfs_open_context {
 
 	struct list_head list;
 	struct nfs4_threshold	*mdsthreshold;
+	struct rcu_head	rcu_head;
 };
 
 struct nfs_open_dir_context {
-- 
2.17.1
