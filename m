Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47185 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1BUWab (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:30:31 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/9] pnfs: return bool status from nfs4_asynch_forget_layouts
Date: Mon, 21 Feb 2011 14:30:27 -0800
Message-Id: <1298327427-8306-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

return true if segments were marked invalid

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   10 ++++++++--
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index beebc85..7507054 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -475,7 +475,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 			mark_lseg_invalid(lseg, tmp_list);
 			rv = true;
 		}
-	dprintk("%s:Return\n", __func__);
+	dprintk("%s:Return %d\n", __func__, rv);
 	return rv;
 }
 
@@ -640,20 +640,26 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	return lseg;
 }
 
-void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
+bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
 				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list)
 {
+	bool rv = false;
 	struct pnfs_layout_segment *lseg, *tmp;
 
 	assert_spin_locked(&lo->inode->i_lock);
+	dprintk("%s\n", __func__);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
 			lseg->pls_notify_mask |= (1 << notify_bit);
 			atomic_inc(notify_count);
 			mark_lseg_invalid(lseg, tmp_list);
+			rv = true;
 		}
+
+	dprintk("%s:Return %d\n", __func__, rv);
+	return rv;
 }
 
 /* Return true if there is layout based io in progress in the given range.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1ee59c2..11c6ee4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -298,7 +298,7 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
-void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
+bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
 				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
-- 
1.7.3.4

