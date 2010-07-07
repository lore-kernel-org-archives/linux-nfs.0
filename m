From: andros@netapp.com
Subject: [PATCH 13/16] SQUASHME pnfs-submit: reference layout for layoutreturn
Date: Wed,  7 Jul 2010 18:34:20 -0400
Message-ID: <1278542063-4009-14-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
 <1278542063-4009-8-git-send-email-andros@netapp.com>
 <1278542063-4009-9-git-send-email-andros@netapp.com>
 <1278542063-4009-10-git-send-email-andros@netapp.com>
 <1278542063-4009-11-git-send-email-andros@netapp.com>
 <1278542063-4009-12-git-send-email-andros@netapp.com>
 <1278542063-4009-13-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757545Ab0GGWec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:32 -0400
In-Reply-To: <1278542063-4009-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d42c5da..040f9e0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -371,7 +371,10 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
-	/* Matched in _pnfs_update_layout for layoutget */
+	/*
+	 * Matched in _pnfs_update_layout for layoutget
+	 * and by get_layout in _pnfs_return_layout for layoutreturn
+	 */
 	put_layout_locked(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
@@ -776,9 +779,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	if (type == RETURN_FILE) {
 		spin_lock(&ino->i_lock);
-		lo = grab_current_layout(nfsi);
+		lo = nfsi->layout;
 		if (lo && !has_layout_to_return(lo, &arg)) {
-			put_layout(lo);
 			lo = NULL;
 		}
 		if (!lo) {
@@ -787,18 +789,15 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			goto out;
 		}
 
-		/* unlock w/o put rebalanced by eventual call to
-		 * pnfs_layout_release
-		 */
+		/* Reference for layoutreturn matched in pnfs_layout_release */
+		get_layout(lo);
+
 		spin_unlock(&ino->i_lock);
 
 		if (pnfs_return_layout_barrier(nfsi, &arg)) {
 			if (stateid) { /* callback */
 				status = -EAGAIN;
-				spin_lock(&ino->i_lock);
-				put_layout(lo);
-				spin_unlock(&ino->i_lock);
-				goto out;
+				goto out_put;
 			}
 			dprintk("%s: waiting\n", __func__);
 			wait_event(nfsi->lo_waitq,
@@ -809,7 +808,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			if (stateid && !wait) { /* callback */
 				dprintk("%s: layoutcommit pending\n", __func__);
 				status = -EAGAIN;
-				goto out;
+				goto out_put;
 			}
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
@@ -828,6 +827,9 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
+out_put:
+	put_layout(ino);
+	goto out;
 }
 
 void
-- 
1.6.6

