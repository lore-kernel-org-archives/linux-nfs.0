Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:46695 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab1GUTen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 15:34:43 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 15/25] pnfsblock: bl_find_get_extent
Date: Thu, 21 Jul 2011 15:34:15 -0400
Message-Id: <1311276865-29484-16-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-1-git-send-email-rees@umich.edu>
References: <1311276865-29484-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred <iisaman@citi.umich.edu>

Implement bl_find_get_extent(), one of the core extent manipulation
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
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.h |    3 ++
 fs/nfs/blocklayout/extents.c     |   47 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index ed6253e..05f2e54 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -153,6 +153,9 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 void free_block_dev(struct pnfs_block_dev *bdev);
 
 /* extents.c */
+struct pnfs_block_extent *
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+		struct pnfs_block_extent **cow_read);
 void bl_put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index d76bb43..086ce36 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -201,3 +201,50 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 	bl_put_extent(new);
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
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+	    struct pnfs_block_extent **cow_read)
+{
+	struct pnfs_block_extent *be, *cow, *ret;
+	int i;
+
+	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	cow = ret = NULL;
+	spin_lock(&bl->bl_ext_lock);
+	for (i = 0; i < EXTENT_LISTS; i++) {
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
+					bl_put_extent(be);
+				else
+					cow = be;
+				break;
+			}
+		}
+		if (ret &&
+		    (!cow_read || ret->be_state != PNFS_BLOCK_INVALID_DATA))
+			break;
+	}
+	spin_unlock(&bl->bl_ext_lock);
+	if (cow_read)
+		*cow_read = cow;
+	print_bl_extent(ret);
+	return ret;
+}
-- 
1.7.4.1

