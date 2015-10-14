Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 05/10] NFSv4: Pass nfs_open_context instead of nfs4_state to nfs4_proc_unlck()
Date: Wed, 14 Oct 2015 14:23:32 -0400
Message-Id: <65a07ff08d9c616d4189f956ef982e43c66c548b.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_proc_unlk() acquires the nfs_open_context from the file_lock's
fl_file->private, but we will not always have a referenced fl_file in this
path.  Instead, pass along the nfs_open_context from the call to
nfs4_proc_lock().  This allows us to use nfs4_proc_unlck() without a
valid reference in fl_file.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18a1ee7..c08f8ac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5668,8 +5668,9 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 	return rpc_run_task(&task_setup_data);
 }
 
-static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
+static int nfs4_proc_unlck(struct nfs_open_context *ctx, int cmd, struct file_lock *request)
 {
+	struct nfs4_state *state = ctx->state;
 	struct inode *inode = state->inode;
 	struct nfs4_state_owner *sp = state->owner;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -5705,7 +5706,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = -ENOMEM;
 	if (IS_ERR(seqid))
 		goto out;
-	task = nfs4_do_unlck(request, nfs_file_open_context(request->fl_file), lsp, seqid);
+	task = nfs4_do_unlck(request, ctx, lsp, seqid);
 	status = PTR_ERR(task);
 	if (IS_ERR(task))
 		goto out;
@@ -6129,7 +6130,7 @@ nfs4_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *request)
 
 	if (request->fl_type == F_UNLCK) {
 		if (state != NULL)
-			return nfs4_proc_unlck(state, cmd, request);
+			return nfs4_proc_unlck(ctx, cmd, request);
 		return 0;
 	}
 
-- 
1.7.1

