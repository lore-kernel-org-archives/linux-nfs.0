Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33460 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcGNW7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 18:59:08 -0400
Received: by mail-it0-f67.google.com with SMTP id d65so310408ith.0
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2016 15:59:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pNFS: Fix LAYOUTGET handling of NFS4ERR_BAD_STATEID and NFS4ERR_EXPIRED
Date: Thu, 14 Jul 2016 18:58:35 -0400
Message-Id: <1468537115-65826-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1468537115-65826-3-git-send-email-trond.myklebust@primarydata.com>
References: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
 <1468537115-65826-2-git-send-email-trond.myklebust@primarydata.com>
 <1468537115-65826-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to recover the open stateid if there is no layout stateid
and/or the stateid argument matches an open stateid.
Otherwise throw out the existing layout and recover from scratch, as
the layout stateid is bad.

Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
Cc: stable@vger.kernel.org # 4.7
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee8efe0a5202..a1a3b4c9a563 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7886,6 +7886,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	struct pnfs_layout_hdr *lo;
 	int nfs4err = task->tk_status;
 	int err, status = 0;
+	LIST_HEAD(head);
 
 	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
 
@@ -7930,30 +7931,25 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	case -NFS4ERR_BAD_STATEID:
 		exception->timeout = 0;
 		spin_lock(&inode->i_lock);
-		if (nfs4_stateid_match(&lgp->args.stateid,
+		lo = NFS_I(inode)->layout;
+		/* If the open stateid was bad, then recover it. */
+		if (!lo || test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		    nfs4_stateid_match_other(&lgp->args.stateid,
 					&lgp->args.ctx->state->stateid)) {
 			spin_unlock(&inode->i_lock);
-			/* If the open stateid was bad, then recover it. */
 			exception->state = lgp->args.ctx->state;
 			break;
 		}
-		lo = NFS_I(inode)->layout;
-		if (lo && !test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
-		    nfs4_stateid_match_other(&lgp->args.stateid, &lo->plh_stateid)) {
-			LIST_HEAD(head);
-
-			/*
-			 * Mark the bad layout state as invalid, then retry
-			 * with the current stateid.
-			 */
-			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
-			spin_unlock(&inode->i_lock);
-			pnfs_free_lseg_list(&head);
-			status = -EAGAIN;
-			goto out;
-		} else
-			spin_unlock(&inode->i_lock);
+
+		/*
+		 * Mark the bad layout state as invalid, then retry
+		 */
+		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+		pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
+		spin_unlock(&inode->i_lock);
+		pnfs_free_lseg_list(&head);
+		status = -EAGAIN;
+		goto out;
 	}
 
 	err = nfs4_handle_exception(server, nfs4err, exception);
-- 
2.7.4

