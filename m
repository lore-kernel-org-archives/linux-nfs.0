Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:62983 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbAXFjg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 00:39:36 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so1033737igk.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:39:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Convert nfs_alloc_seqid() to return an ERR_PTR() if allocation fails
Date: Sat, 24 Jan 2015 00:39:26 -0500
Message-Id: <1422077968-116473-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422077968-116473-3-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we relax the sequencing on the NFSv4.1 OPEN/CLOSE code, we will want
to use the value NULL to indicate that no sequencing is needed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c  | 10 +++++-----
 fs/nfs/nfs4state.c | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a6c04a5812d0..c9c38077075c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -988,7 +988,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		goto err_free_p;
 
 	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
-	if (p->o_arg.seqid == NULL)
+	if (IS_ERR(p->o_arg.seqid))
 		goto err_free_label;
 	nfs_sb_active(dentry->d_sb);
 	p->dentry = dget(dentry);
@@ -2779,7 +2779,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->arg.fh = NFS_FH(state->inode);
 	/* Serialization for the sequence id */
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid, gfp_mask);
-	if (calldata->arg.seqid == NULL)
+	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
 	calldata->arg.bitmask = server->cache_consistency_bitmask;
@@ -5517,7 +5517,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 		goto out;
 	seqid = nfs_alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
 	status = -ENOMEM;
-	if (seqid == NULL)
+	if (IS_ERR(seqid))
 		goto out;
 	task = nfs4_do_unlck(request, nfs_file_open_context(request->fl_file), lsp, seqid);
 	status = PTR_ERR(task);
@@ -5558,10 +5558,10 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.fh = NFS_FH(inode);
 	p->arg.fl = &p->fl;
 	p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid, gfp_mask);
-	if (p->arg.open_seqid == NULL)
+	if (IS_ERR(p->arg.open_seqid))
 		goto out_free;
 	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid, gfp_mask);
-	if (p->arg.lock_seqid == NULL)
+	if (IS_ERR(p->arg.lock_seqid))
 		goto out_free_seqid;
 	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5194933ed419..b922e43d69b8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1003,11 +1003,11 @@ struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_m
 	struct nfs_seqid *new;
 
 	new = kmalloc(sizeof(*new), gfp_mask);
-	if (new != NULL) {
-		new->sequence = counter;
-		INIT_LIST_HEAD(&new->list);
-		new->task = NULL;
-	}
+	if (new == NULL)
+		return ERR_PTR(-ENOMEM);
+	new->sequence = counter;
+	INIT_LIST_HEAD(&new->list);
+	new->task = NULL;
 	return new;
 }
 
-- 
2.1.0

