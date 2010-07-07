From: andros@netapp.com
Subject: [PATCH 11/16] SQUASHME pnfs-submit: rename put_layout to put_layout_locked
Date: Wed,  7 Jul 2010 18:34:18 -0400
Message-ID: <1278542063-4009-12-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757545Ab0GGWea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:30 -0400
In-Reply-To: <1278542063-4009-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation for non-locked put_layout, follow naming convention.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1372ae1..aa16e5d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -336,7 +336,7 @@ grab_current_layout(struct nfs_inode *nfsi)
 }
 
 static inline void
-put_layout(struct pnfs_layout_type *lo)
+put_layout_locked(struct pnfs_layout_type *lo)
 {
 	BUG_ON_UNLOCKED_LO(lo);
 	BUG_ON(lo->refcount <= 0);
@@ -363,7 +363,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	if (range)
 		pnfs_free_layout(lo, range);
 	/* Matched in _pnfs_update_layout for layoutget */
-	put_layout(lo);
+	put_layout_locked(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
@@ -390,7 +390,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 				__func__, nfsi->layout->refcount);
 		WARN_ON(nfsi->layout->refcount != 1);
 
-		put_layout(lo);
+		put_layout_locked(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
@@ -412,7 +412,7 @@ destroy_lseg(struct kref *kref)
 
 	dprintk("--> %s\n", __func__);
 	/* Matched by get_layout in pnfs_insert_layout */
-	put_layout(lseg->layout);
+	put_layout_locked(lseg->layout);
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
@@ -684,7 +684,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
-		put_layout(lo);
+		put_layout_locked(lo);
 	}
 
 	dprintk("%s:Return\n", __func__);
@@ -961,7 +961,7 @@ nfs_lock_alloc_layout(struct inode *ino)
 		spin_unlock(&ino->i_lock);
 		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
 		spin_lock(&ino->i_lock);
-		put_layout(NFS_I(ino)->layout);
+		put_layout_locked(NFS_I(ino)->layout);
 	}
 	return NFS_I(ino)->layout;
 }
-- 
1.6.6

