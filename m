From: andros@netapp.com
Subject: [PATCH 06/16] SQUASHME pnfs-submit; fix pnfs_update_layout reference counting
Date: Wed,  7 Jul 2010 18:34:13 -0400
Message-ID: <1278542063-4009-7-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755675Ab0GGWe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:26 -0400
In-Reply-To: <1278542063-4009-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only take a reference on the layout if layoutget is to be called.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 92b7772..7219d2b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -362,6 +362,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
+	/* Matched in _pnfs_update_layout for layoutget */
 	put_layout(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
@@ -1063,7 +1064,7 @@ _pnfs_update_layout(struct inode *ino,
 			put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
-		goto out_put;
+		goto out_unlock;
 	}
 
 	if (lseg) {
@@ -1074,7 +1075,7 @@ _pnfs_update_layout(struct inode *ino,
 			arg.offset,
 			arg.iomode);
 
-		goto out_put;
+		goto out_unlock;
 	}
 
 	/* if get layout already failed once goto out */
@@ -1086,10 +1087,11 @@ _pnfs_update_layout(struct inode *ino,
 				  &nfsi->layout->pnfs_layout_state);
 			nfsi->pnfs_layout_suspend = 0;
 		} else
-			goto out_put;
+			goto out_unlock;
 	}
 
-	/* Lose lock, but not reference, match this with pnfs_layout_release */
+	/* Reference the layout for layoutget matched in pnfs_layout_release */
+	get_layout(lo);
 	spin_unlock(&ino->i_lock);
 
 	send_layoutget(ino, ctx, &arg, lsegpp, lo);
@@ -1097,10 +1099,9 @@ out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->pnfs_layout_state, lseg);
 	return;
-out_put:
+out_unlock:
 	if (lsegpp)
 		*lsegpp = lseg;
-	put_layout(lo);
 	spin_unlock(&ino->i_lock);
 	goto out;
 }
-- 
1.6.6

