Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60772 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1FLXoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:39 -0400
Message-Id: <aa30701c41cb8ced39020e79e5a3060280211ec4.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:37 -0400
Subject: [PATCH 20/34] pnfsblock: find_get_extent
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred <iisaman@citi.umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Implement find_get_extent(), one of the core extent manipulation
routines.

[pnfsblock: Lookup list entry of layouts and tags in reverse order]
Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

pnfsblock: fix print format warnings for sector_t and size_t

gcc spews warnings about these on x86_64, e.g.:
fs/nfs/blocklayout/blocklayout.c:74: warning: format ‘%Lu’ expects type ‘long long unsigned int’, but argument 2 has type ‘sector_t’
fs/nfs/blocklayout/blocklayout.c:388: warning: format ‘%d’ expects type ‘int’, but argument 5 has type ‘size_t’

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h |    3 ++
 fs/nfs/blocklayout/extents.c     |   47 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 293f009..06aa36a 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -219,6 +219,9 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 /* blocklayoutdm.c */
 void free_block_dev(struct pnfs_block_dev *bdev);
 /* extents.c */
+struct pnfs_block_extent *
+find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+		struct pnfs_block_extent **cow_read);
 void put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 26c263f..f0b3f13 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -201,3 +201,50 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 	put_extent(new);
 	return -EIO;
 }
+
+/* Returns extent, or NULL.  If a second READ extent exists, it is returned
+ * in cow_read, if given.
+ *
+ * The extents are kept in two seperate ordered lists, one for READ and NONE,
+ * one for READWRITE and INVALID.  Within each list, we assume:
+ * 1. Extents are ordered by file offset.
+ * 2. For any given isect, there is at most one extents that matches.
+ */
+struct pnfs_block_extent *
+find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+	    struct pnfs_block_extent **cow_read)
+{
+	struct pnfs_block_extent *be, *cow, *ret;
+	int i;
+
+	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	cow = ret = NULL;
+	spin_lock(&bl->bl_ext_lock);
+	for (i = 0; i < EXTENT_LISTS; i++) {
+		if (ret &&
+		    (!cow_read || ret->be_state != PNFS_BLOCK_INVALID_DATA))
+			break;
+		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
+			if (isect >= be->be_f_offset + be->be_length)
+				break;
+			if (isect >= be->be_f_offset) {
+				/* We have found an extent */
+				dprintk("%s Get %p (%i)\n", __func__, be,
+					atomic_read(&be->be_refcnt.refcount));
+				kref_get(&be->be_refcnt);
+				if (!ret)
+					ret = be;
+				else if (be->be_state != PNFS_BLOCK_READ_DATA)
+					put_extent(be);
+				else
+					cow = be;
+				break;
+			}
+		}
+	}
+	spin_unlock(&bl->bl_ext_lock);
+	if (cow_read)
+		*cow_read = cow;
+	print_bl_extent(ret);
+	return ret;
+}
-- 
1.7.4.1

