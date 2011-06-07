Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51044 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:27 -0400
Date: Tue, 7 Jun 2011 13:31:24 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 45/88] SQUASHME: pnfsblock: Implement release_inval_marks
Message-ID: <12097a1c787be91438d2afedde71a72f95a61665.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

Leaving it unimplemented will cause memory leak.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   11 ++++++++---
 fs/nfs/blocklayout/blocklayout.h |    6 ++++++
 fs/nfs/blocklayout/extents.c     |    6 ------
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index db008e6..b0ad836 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -541,10 +541,15 @@ release_extents(struct pnfs_block_layout *bl,
 	spin_unlock(&bl->bl_ext_lock);
 }
 
-/* STUB */
 static void
-release_inval_marks(void)
+release_inval_marks(struct pnfs_inval_markings *marks)
 {
+	struct pnfs_inval_tracking *pos, *temp;
+
+	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
+		list_del(&pos->it_link);
+		kfree(pos);
+	}
 	return;
 }
 
@@ -556,7 +561,7 @@ bl_free_layout(void *p)
 
 	dprintk("%s enter\n", __func__);
 	release_extents(bl, NULL);
-	release_inval_marks();
+	release_inval_marks(&bl->bl_inval);
 	kfree(bl);
 	return;
 }
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index ca36e61..45939e1 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -126,6 +126,12 @@ struct pnfs_inval_markings {
 	sector_t	im_block_size;	/* Server blocksize in sectors */
 };
 
+struct pnfs_inval_tracking {
+	struct list_head it_link;
+	int		 it_sector;
+	int		 it_tags;
+};
+
 /* sector_t fields are all in 512-byte sectors */
 struct pnfs_block_extent {
 	struct kref	be_refcnt;
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 4722899..cf5b3a3 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -40,12 +40,6 @@
 #define INTERNAL_EXISTS    MY_MAX_TAGS
 #define INTERNAL_MASK      ((1 << INTERNAL_EXISTS) - 1)
 
-struct pnfs_inval_tracking {
-	struct list_head it_link;
-	int		 it_sector;
-	int		 it_tags;
-};
-
 /* Returns largest t<=s s.t. t%base==0 */
 static inline sector_t normalize(sector_t s, int base)
 {
-- 
1.7.4.1

