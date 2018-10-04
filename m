Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw1-f67.google.com ([209.85.161.67]:36831 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727614AbeJEBjb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2018 21:39:31 -0400
Received: by mail-yw1-f67.google.com with SMTP id e201-v6so4205733ywa.3
        for <linux-nfs@vger.kernel.org>; Thu, 04 Oct 2018 11:44:59 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.x: fix lock recovery during delegation recall
Date: Thu,  4 Oct 2018 14:45:00 -0400
Message-Id: <20181004184500.14403-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Running "./nfstest_delegation --runtest recall26" uncovers that
client doesn't recover the lock when we have an appending open,
where the initial open got a write delegation.

Instead of checking for the passed in open context against
the file lock's open context. Check that the state is the same.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/delegation.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 76d205d..07b8395 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -93,7 +93,7 @@ int nfs4_check_delegation(struct inode *inode, fmode_t flags)
 	return nfs4_do_check_delegation(inode, flags, false);
 }
 
-static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
+static int nfs_delegation_claim_locks(struct nfs4_state *state, const nfs4_stateid *stateid)
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
@@ -108,7 +108,7 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	spin_lock(&flctx->flc_lock);
 restart:
 	list_for_each_entry(fl, list, fl_list) {
-		if (nfs_file_open_context(fl->fl_file) != ctx)
+		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
 		spin_unlock(&flctx->flc_lock);
 		status = nfs4_lock_delegation_recall(fl, state, stateid);
@@ -156,7 +156,7 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 		err = nfs4_open_delegation_recall(ctx, state, stateid, type);
 		if (!err)
-			err = nfs_delegation_claim_locks(ctx, state, stateid);
+			err = nfs_delegation_claim_locks(state, stateid);
 		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			err = -EAGAIN;
 		mutex_unlock(&sp->so_delegreturn_mutex);
-- 
1.8.3.1
