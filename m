Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbbL1Q2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 11:28:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/10] NFSv4: Pass nfs_open_context instead of nfs4_state to nfs4_proc_unlck()
Date: Mon, 28 Dec 2015 11:28:00 -0500
Message-Id: <e49386921f65ed84d1afe79fc1c709df6a353835.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_proc_unlk() acquires the nfs_open_context from the file_lock's
fl_file->private, but we will not always have a referenced fl_file in this
path.  Instead, pass along the nfs_open_context from the call to
nfs4_proc_lock().  This allows us to use nfs4_proc_unlck() without a
valid reference in fl_file.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 784ba4e..279c8b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5656,8 +5656,10 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 	return rpc_run_task(&task_setup_data);
 }
 
-static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
+static int nfs4_proc_unlck(struct nfs_open_context *ctx,
+		int cmd, struct file_lock *request)
 {
+	struct nfs4_state *state = ctx->state;
 	struct inode *inode = state->inode;
 	struct nfs4_state_owner *sp = state->owner;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -5693,7 +5695,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = -ENOMEM;
 	if (IS_ERR(seqid))
 		goto out;
-	task = nfs4_do_unlck(request, nfs_file_open_context(request->fl_file), lsp, seqid);
+	task = nfs4_do_unlck(request, ctx, lsp, seqid);
 	status = PTR_ERR(task);
 	if (IS_ERR(task))
 		goto out;
@@ -6117,7 +6119,7 @@ nfs4_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *request)
 
 	if (request->fl_type == F_UNLCK) {
 		if (state != NULL)
-			return nfs4_proc_unlck(state, cmd, request);
+			return nfs4_proc_unlck(ctx, cmd, request);
 		return 0;
 	}
 
-- 
1.7.1

