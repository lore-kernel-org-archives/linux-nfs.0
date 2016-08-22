Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35588 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbcHVSLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Aug 2016 14:11:18 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH v3] pnfs/blocklayout: update last_write_offset atomically with extents
Date: Mon, 22 Aug 2016 14:11:16 -0400
Message-Id: <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
In-Reply-To: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change from v2:

Since writes can arrive out of order, only take lwb values larger than what
was recorded since the last write and clear lwb after encoding.

Change from v1:

Instead of moving the i_lock protected region around, store last written
byte for block layouts on struct pnfs_block_layout and use that when
encoding LAYOUTCOMMIT.

8<------------------------------------------------------------------------

Block/SCSI layout write completion may add committable extents to the
extent tree before updating the layout's last-written byte under the inode
lock.  If a sync happens before this value is updated, then
prepare_layoutcommit may find and encode these extents which would produce
a LAYOUTCOMMIT request whose encoded extents are larger than the request's
loca_length.

Fix this by using a last-written byte value that is updated atomically with
the extent tree so that commitable extents always match.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c |  2 +-
 fs/nfs/blocklayout/blocklayout.h |  3 ++-
 fs/nfs/blocklayout/extent_tree.c | 10 +++++++---
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 17a42e4eb872..25cdd559831c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -344,7 +344,7 @@ static void bl_write_cleanup(struct work_struct *work)
 			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
 
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
-					(end - start) >> SECTOR_SHIFT);
+					(end - start) >> SECTOR_SHIFT, end);
 	}
 
 	pnfs_ld_write_done(hdr);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 18e6fd0b9506..efc007f00742 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -141,6 +141,7 @@ struct pnfs_block_layout {
 	struct rb_root		bl_ext_ro;
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
 	bool			bl_scsi_layout;
+	u64			bl_lwb;
 };
 
 static inline struct pnfs_block_layout *
@@ -182,7 +183,7 @@ int ext_tree_insert(struct pnfs_block_layout *bl,
 int ext_tree_remove(struct pnfs_block_layout *bl, bool rw, sector_t start,
 		sector_t end);
 int ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
-		sector_t len);
+		sector_t len, u64 lwb);
 bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
 		struct pnfs_block_extent *ret, bool rw);
 int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 992bcb19c11e..c85fbfd2d0d9 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -402,7 +402,7 @@ ext_tree_split(struct rb_root *root, struct pnfs_block_extent *be,
 
 int
 ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
-		sector_t len)
+		sector_t len, u64 lwb)
 {
 	struct rb_root *root = &bl->bl_ext_rw;
 	sector_t end = start + len;
@@ -471,6 +471,8 @@ ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
 		}
 	}
 out:
+	if (bl->bl_lwb < lwb)
+		bl->bl_lwb = lwb;
 	spin_unlock(&bl->bl_ext_lock);
 
 	__ext_put_deviceids(&tmp);
@@ -518,7 +520,7 @@ static __be32 *encode_scsi_range(struct pnfs_block_extent *be, __be32 *p)
 }
 
 static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
-		size_t buffer_size, size_t *count)
+		size_t buffer_size, size_t *count, __u64 *lastbyte)
 {
 	struct pnfs_block_extent *be;
 	int ret = 0;
@@ -542,6 +544,8 @@ static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 			p = encode_block_extent(be, p);
 		be->be_tag = EXTENT_COMMITTING;
 	}
+	*lastbyte = bl->bl_lwb - 1;
+	bl->bl_lwb = 0;
 	spin_unlock(&bl->bl_ext_lock);
 
 	return ret;
@@ -564,7 +568,7 @@ ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg)
 	arg->layoutupdate_pages = &arg->layoutupdate_page;
 
 retry:
-	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
+	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count, &arg->lastbytewritten);
 	if (unlikely(ret)) {
 		ext_tree_free_commitdata(arg, buffer_size);
 
-- 
2.5.5

