Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35895 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbHEC37 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:29:59 -0400
Received: by ioeg141 with SMTP id g141so36088223ioe.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:29:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv4.1/pnfs: Remove redundant checks in pnfs_layoutgets_blocked()
Date: Tue,  4 Aug 2015 22:29:51 -0400
Message-Id: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are no valid layout segments, then we should already have
checked in pnfs_update_layout() whether or not this is the first
layoutget.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 70bf706b1090..aa95544123c5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -829,12 +829,10 @@ pnfs_layout_returning(const struct pnfs_layout_hdr *lo,
 /* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
 pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo,
-			struct pnfs_layout_range *range, int lget)
+			struct pnfs_layout_range *range)
 {
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		(list_empty(&lo->plh_segs) &&
-		 (atomic_read(&lo->plh_outstanding) > lget)) ||
 		pnfs_layout_returning(lo, range);
 }
 
@@ -847,7 +845,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, range, 1)) {
+	if (pnfs_layoutgets_blocked(lo, range)) {
 		status = -EAGAIN;
 	} else if (!nfs4_valid_open_stateid(open_state)) {
 		status = -EBADF;
@@ -1547,7 +1545,7 @@ lookup_again:
 		goto out_put_layout_hdr;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, &arg, 0))
+	if (pnfs_layoutgets_blocked(lo, &arg))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 	spin_unlock(&ino->i_lock);
@@ -1624,7 +1622,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget_reply;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, &lgp->args.range, 1)) {
+	if (pnfs_layoutgets_blocked(lo, &lgp->args.range)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
-- 
2.4.3

