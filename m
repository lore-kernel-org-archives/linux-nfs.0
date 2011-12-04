Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:49:05 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:49:04 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/13] pnfsd-block: change blr_lock to mutex
Date: Sun,  4 Dec 2011 15:48:58 +0200
Message-Id: <1323006538-13675-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

We're allocating memory while holding blr_lock
via bl_layoutget -> layout_cache_fill_from -> bll_alloc

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 15d2604..5f20b90 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -68,7 +68,7 @@
 	u64			blr_orig_size,
 				blr_commit_size,
 				blr_ext_size;
-	spinlock_t		blr_lock;	// Protects blr_layouts
+	struct mutex		blr_lock;	// Protects blr_layouts
 } bl_layout_rec_t;
 
 static struct list_head layout_hash;
@@ -401,7 +401,7 @@ enum nfsstat4
 	}
 	BUG_ON(!r);
 	
-	spin_lock(&r->blr_lock);
+	mutex_lock(&r->blr_lock);
 	
 	if (layout_cache_fill_from(r, &bl_possible, &res->lg_seg)) {
 		/*
@@ -443,7 +443,7 @@ enum nfsstat4
 		}
 	}
 
-	spin_unlock(&r->blr_lock);
+	mutex_unlock(&r->blr_lock);
 	if (unlikely(nfserr)) {
 		if (del_on_error == True)
 			layout_inode_del(i);
@@ -541,9 +541,9 @@ enum nfsstat4
 	
 	r = layout_inode_find(i);
 	if (r) {
-		spin_lock(&r->blr_lock);
+		mutex_lock(&r->blr_lock);
 		layout_cache_del(r, &args->lr_seg);
-		spin_unlock(&r->blr_lock);
+		mutex_unlock(&r->blr_lock);
 		dprintk("    ext_size %Lu, i_size %Lu, orig_size %Lu\n",
 		    r->blr_ext_size, i->i_size, r->blr_orig_size);
 	}
@@ -591,7 +591,7 @@ enum nfsstat4
 restart:
 	r = layout_inode_find(inode);
 	if (r && len && !r->blr_recalled) {
-		spin_lock(&r->blr_lock);
+		mutex_lock(&r->blr_lock);
 		list_for_each_entry(b, &r->blr_layouts, bll_list) {
 			if (!r->blr_recalled && !b->bll_recalled &&
 			    (offset >= b->bll_foff) && (offset < BLL_F_END(b))) {
@@ -624,14 +624,14 @@ enum nfsstat4
 				 * the lock. The request will come in on the
 				 * same thread which will cause a deadlock.
 				 */
-				spin_unlock(&r->blr_lock);
+				mutex_unlock(&r->blr_lock);
 				_nfsd_layout_recall_cb(sb, inode, &lr, with_nfs4_state_lock);
 				adj = MIN(b->bll_len - (offset - b->bll_foff),
 				    len);
 				offset += adj;
 				len -= adj;
 				if (!len) {
-					spin_lock(&r->blr_lock);
+					mutex_lock(&r->blr_lock);
 					break;
 				}
 				/*
@@ -642,7 +642,7 @@ enum nfsstat4
 				goto restart;
 			}
 		}
-		spin_unlock(&r->blr_lock);
+		mutex_unlock(&r->blr_lock);
 	}
 	
 	dprintk("<-- %s\n", __func__);
@@ -1451,7 +1451,7 @@ struct list_head *
 	r->blr_ext_size	= 0;
 	r->blr_recalled	= 0;
 	INIT_LIST_HEAD(&r->blr_layouts);
-	spin_lock_init(&r->blr_lock);
+	mutex_init(&r->blr_lock);
 	spin_lock(&layout_hashtbl_lock);
 	list_add_tail(&r->blr_hash, &layout_hash);
 	spin_unlock(&layout_hashtbl_lock);
@@ -1500,13 +1500,12 @@ struct list_head *
 	spin_lock(&layout_hashtbl_lock);
 	r = __layout_inode_find(i);
 	if (r) {
-		spin_lock(&r->blr_lock);
+		/* FIXME: cannot acquire mutex while holding a spin lock
+		 * need kref?
+		 */
 		if (list_empty(&r->blr_layouts)) {
 			list_del(&r->blr_hash);
-			spin_unlock(&r->blr_lock);
 			kfree(r);
-		} else {
-			spin_unlock(&r->blr_lock);
 		}
 	} else {
 		dprintk("%s: failed to find inode [0x%x:%lu] in table for delete\n",
-- 
1.7.6

