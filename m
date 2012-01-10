Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44137 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab2AJOc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 09:32:57 -0500
Received: by mail-iy0-f174.google.com with SMTP id z25so965522iab.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2012 06:32:57 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH RESEND 7/9] pnfsblock: alloc short extent before submit bio
Date: Tue, 10 Jan 2012 22:30:33 +0800
Message-Id: <1326205835-2011-8-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
References: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As discussed earlier, it is better for block client to allocate memory for
tracking extents state before submitting bio. So the patch does it by allocating
a short_extent for every INVALID extent touched by write pagelist and for
every zeroing page we created, saving them in layout header. Then in end_io we
can just use them to create commit list items and avoid memory allocation there.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |   74 ++++++++++++++++++++++++++-------
 fs/nfs/blocklayout/blocklayout.h |    9 ++++-
 fs/nfs/blocklayout/extents.c     |   85 +++++++++++++++++++++++++++++---------
 3 files changed, 131 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7fc69c9..1dd2983 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -90,8 +90,9 @@ static int is_writable(struct pnfs_block_extent *be, sector_t isect)
  */
 struct parallel_io {
 	struct kref refcnt;
-	void (*pnfs_callback) (void *data);
+	void (*pnfs_callback) (void *data, int num_se);
 	void *data;
+	int bse_count;
 };
 
 static inline struct parallel_io *alloc_parallel(void *data)
@@ -102,6 +103,7 @@ static inline struct parallel_io *alloc_parallel(void *data)
 	if (rv) {
 		rv->data = data;
 		kref_init(&rv->refcnt);
+		rv->bse_count = 0;
 	}
 	return rv;
 }
@@ -116,7 +118,7 @@ static void destroy_parallel(struct kref *kref)
 	struct parallel_io *p = container_of(kref, struct parallel_io, refcnt);
 
 	dprintk("%s enter\n", __func__);
-	p->pnfs_callback(p->data);
+	p->pnfs_callback(p->data, p->bse_count);
 	kfree(p);
 }
 
@@ -211,7 +213,7 @@ static void bl_read_cleanup(struct work_struct *work)
 }
 
 static void
-bl_end_par_io_read(void *data)
+bl_end_par_io_read(void *data, int unused)
 {
 	struct nfs_read_data *rdata = data;
 
@@ -312,6 +314,7 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 {
 	sector_t isect, end;
 	struct pnfs_block_extent *be;
+	struct pnfs_block_short_extent *se;
 
 	dprintk("%s(%llu, %u)\n", __func__, offset, count);
 	if (count == 0)
@@ -324,8 +327,11 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 		be = bl_find_get_extent(bl, isect, NULL);
 		BUG_ON(!be); /* FIXME */
 		len = min(end, be->be_f_offset + be->be_length) - isect;
-		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
-			bl_mark_for_commit(be, isect, len); /* What if fails? */
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+			se = bl_pop_one_short_extent(be->be_inval);
+			BUG_ON(!se);
+			bl_mark_for_commit(be, isect, len, se);
+		}
 		isect += len;
 		bl_put_extent(be);
 	}
@@ -347,7 +353,8 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 		end_page_writeback(page);
 		page_cache_release(page);
 	} while (bvec >= bio->bi_io_vec);
-	if (!uptodate) {
+
+	if (unlikely(!uptodate)) {
 		if (!wdata->pnfs_error)
 			wdata->pnfs_error = -EIO;
 		pnfs_set_lo_fail(wdata->lseg);
@@ -356,7 +363,6 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 	put_parallel(par);
 }
 
-/* This is basically copied from mpage_end_io_read */
 static void bl_end_io_write(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
@@ -382,7 +388,7 @@ static void bl_write_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
-	if (!wdata->pnfs_error) {
+	if (likely(!wdata->pnfs_error)) {
 		/* Marks for LAYOUTCOMMIT */
 		mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
 				     wdata->args.offset, wdata->args.count);
@@ -391,10 +397,15 @@ static void bl_write_cleanup(struct work_struct *work)
 }
 
 /* Called when last of bios associated with a bl_write_pagelist call finishes */
-static void bl_end_par_io_write(void *data)
+static void bl_end_par_io_write(void *data, int num_se)
 {
 	struct nfs_write_data *wdata = data;
 
+	if (unlikely(wdata->pnfs_error)) {
+		bl_free_short_extents(&BLK_LSEG2EXT(wdata->lseg)->bl_inval,
+					num_se);
+	}
+
 	wdata->task.tk_status = wdata->pnfs_error;
 	wdata->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
@@ -547,7 +558,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	 */
 	par = alloc_parallel(wdata);
 	if (!par)
-		return PNFS_NOT_ATTEMPTED;
+		goto out_mds;
 	par->pnfs_callback = bl_end_par_io_write;
 	/* At this point, have to be more careful with error handling */
 
@@ -555,12 +566,15 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
 	if (!be || !is_writable(be, isect)) {
 		dprintk("%s no matching extents!\n", __func__);
-		wdata->pnfs_error = -EINVAL;
-		goto out;
+		goto out_mds;
 	}
 
 	/* First page inside INVALID extent */
 	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		if (likely(!bl_push_one_short_extent(be->be_inval)))
+			par->bse_count++;
+		else
+			goto out_mds;
 		temp = offset >> PAGE_CACHE_SHIFT;
 		npg_zero = do_div(temp, npg_per_block);
 		isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
@@ -598,6 +612,19 @@ fill_invalid_ext:
 				wdata->pnfs_error = ret;
 				goto out;
 			}
+			if (likely(!bl_push_one_short_extent(be->be_inval)))
+				par->bse_count++;
+			else {
+				end_page_writeback(page);
+				page_cache_release(page);
+				wdata->pnfs_error = -ENOMEM;
+				goto out;
+			}
+			/* FIXME: This should be done in bi_end_io */
+			mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+					     page->index << PAGE_CACHE_SHIFT,
+					     PAGE_CACHE_SIZE);
+
 			bio = bl_add_page_to_bio(bio, npg_zero, WRITE,
 						 isect, page, be,
 						 bl_end_io_write_zero, par);
@@ -606,10 +633,6 @@ fill_invalid_ext:
 				bio = NULL;
 				goto out;
 			}
-			/* FIXME: This should be done in bi_end_io */
-			mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
-					     page->index << PAGE_CACHE_SHIFT,
-					     PAGE_CACHE_SIZE);
 next_page:
 			isect += PAGE_CACHE_SECTORS;
 			extent_length -= PAGE_CACHE_SECTORS;
@@ -633,6 +656,15 @@ next_page:
 				wdata->pnfs_error = -EINVAL;
 				goto out;
 			}
+			if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+				if (likely(!bl_push_one_short_extent(
+								be->be_inval)))
+					par->bse_count++;
+				else {
+					wdata->pnfs_error = -ENOMEM;
+					goto out;
+				}
+			}
 			extent_length = be->be_length -
 			    (isect - be->be_f_offset);
 		}
@@ -680,6 +712,10 @@ out:
 	bl_submit_bio(WRITE, bio);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
+out_mds:
+	bl_put_extent(be);
+	kfree(par);
+	return PNFS_NOT_ATTEMPTED;
 }
 
 /* FIXME - range ignored */
@@ -706,11 +742,17 @@ static void
 release_inval_marks(struct pnfs_inval_markings *marks)
 {
 	struct pnfs_inval_tracking *pos, *temp;
+	struct pnfs_block_short_extent *se, *stemp;
 
 	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
 		list_del(&pos->it_link);
 		kfree(pos);
 	}
+
+	list_for_each_entry_safe(se, stemp, &marks->im_extents, bse_node) {
+		list_del(&se->bse_node);
+		kfree(se);
+	}
 	return;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 60728ac..e31a2df 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -70,6 +70,7 @@ struct pnfs_inval_markings {
 	spinlock_t	im_lock;
 	struct my_tree	im_tree;	/* Sectors that need LAYOUTCOMMIT */
 	sector_t	im_block_size;	/* Server blocksize in sectors */
+	struct list_head im_extents;	/* Short extents for INVAL->RW conversion */
 };
 
 struct pnfs_inval_tracking {
@@ -105,6 +106,7 @@ BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
 	spin_lock_init(&marks->im_lock);
 	INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
+	INIT_LIST_HEAD(&marks->im_extents);
 	marks->im_block_size = blocksize;
 	marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
 					   blocksize);
@@ -199,6 +201,11 @@ void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 int bl_mark_for_commit(struct pnfs_block_extent *be,
-			sector_t offset, sector_t length);
+			sector_t offset, sector_t length,
+			struct pnfs_block_short_extent *new);
+int bl_push_one_short_extent(struct pnfs_inval_markings *marks);
+struct pnfs_block_short_extent *
+bl_pop_one_short_extent(struct pnfs_inval_markings *marks);
+void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free);
 
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index d0f52ed..1abac09 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -157,10 +157,10 @@ static int _preload_range(struct pnfs_inval_markings *marks,
 			goto out_cleanup;
 	}
 
-	spin_lock(&marks->im_lock);
+	spin_lock_bh(&marks->im_lock);
 	for (s = start; s < end; s += tree->mtt_step_size)
 		used += _add_entry(tree, s, INTERNAL_EXISTS, storage[used]);
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 
 	status = 0;
 
@@ -179,9 +179,9 @@ int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect)
 {
 	int rv;
 
-	spin_lock(&marks->im_lock);
+	spin_lock_bh(&marks->im_lock);
 	rv = _has_tag(&marks->im_tree, isect, EXTENT_INITIALIZED);
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 	return rv;
 }
 
@@ -221,9 +221,9 @@ static int is_range_written(struct pnfs_inval_markings *marks,
 {
 	int rv;
 
-	spin_lock(&marks->im_lock);
+	spin_lock_bh(&marks->im_lock);
 	rv = _range_has_tag(&marks->im_tree, start, end, EXTENT_WRITTEN);
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 	return rv;
 }
 
@@ -244,15 +244,15 @@ int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
 	if (_preload_range(marks, start, end - start))
 		goto outerr;
 
-	spin_lock(&marks->im_lock);
+	spin_lock_bh(&marks->im_lock);
 	if (_set_range(&marks->im_tree, EXTENT_INITIALIZED, offset, length))
 		goto out_unlock;
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 
 	return 0;
 
 out_unlock:
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 outerr:
 	return -ENOMEM;
 }
@@ -267,9 +267,9 @@ static int mark_written_sectors(struct pnfs_inval_markings *marks,
 
 	dprintk("%s(offset=%llu,len=%llu) enter\n", __func__,
 		(u64)offset, (u64)length);
-	spin_lock(&marks->im_lock);
+	spin_lock_bh(&marks->im_lock);
 	status = _set_range(&marks->im_tree, EXTENT_WRITTEN, offset, length);
-	spin_unlock(&marks->im_lock);
+	spin_unlock_bh(&marks->im_lock);
 	return status;
 }
 
@@ -369,20 +369,18 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,
 
 /* Note the range described by offset, length is guaranteed to be contained
  * within be.
+ * new will be freed, either by this function or add_to_commitlist if they
+ * decide not to use it, or after LAYOUTCOMMIT uses it in the commitlist.
  */
 int bl_mark_for_commit(struct pnfs_block_extent *be,
-		    sector_t offset, sector_t length)
+		    sector_t offset, sector_t length,
+		    struct pnfs_block_short_extent *new)
 {
 	sector_t new_end, end = offset + length;
-	struct pnfs_block_short_extent *new;
 	struct pnfs_block_layout *bl = container_of(be->be_inval,
 						    struct pnfs_block_layout,
 						    bl_inval);
 
-	new = kmalloc(sizeof(*new), GFP_NOFS);
-	if (!new)
-		return -ENOMEM;
-
 	mark_written_sectors(be->be_inval, offset, length);
 	/* We want to add the range to commit list, but it must be
 	 * block-normalized, and verified that the normalized range has
@@ -412,9 +410,6 @@ int bl_mark_for_commit(struct pnfs_block_extent *be,
 	new->bse_mdev = be->be_mdev;
 
 	spin_lock(&bl->bl_ext_lock);
-	/* new will be freed, either by add_to_commitlist if it decides not
-	 * to use it, or after LAYOUTCOMMIT uses it in the commitlist.
-	 */
 	add_to_commitlist(bl, new);
 	spin_unlock(&bl->bl_ext_lock);
 	return 0;
@@ -862,3 +857,53 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		}
 	}
 }
+
+int bl_push_one_short_extent(struct pnfs_inval_markings *marks)
+{
+	struct pnfs_block_short_extent *new;
+
+	new = kmalloc(sizeof(*new), GFP_NOFS);
+	if (unlikely(!new))
+		return -ENOMEM;
+
+	spin_lock_bh(&marks->im_lock);
+	list_add(&new->bse_node, &marks->im_extents);
+	spin_unlock_bh(&marks->im_lock);
+
+	return 0;
+}
+
+struct pnfs_block_short_extent *
+bl_pop_one_short_extent(struct pnfs_inval_markings *marks)
+{
+	struct pnfs_block_short_extent *rv = NULL;
+
+	spin_lock_bh(&marks->im_lock);
+	if (!list_empty(&marks->im_extents)) {
+		rv = list_entry((&marks->im_extents)->next,
+				struct pnfs_block_short_extent, bse_node);
+		list_del_init(&rv->bse_node);
+	}
+	spin_unlock_bh(&marks->im_lock);
+
+	return rv;
+}
+
+void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free)
+{
+	struct pnfs_block_short_extent *se = NULL, *tmp;
+
+	if (num_to_free <= 0)
+		return;
+
+	spin_lock(&marks->im_lock);
+	list_for_each_entry_safe(se, tmp, &marks->im_extents, bse_node) {
+		list_del(&se->bse_node);
+		kfree(se);
+		if (--num_to_free == 0)
+			break;
+	}
+	spin_unlock(&marks->im_lock);
+
+	BUG_ON(num_to_free > 0);
+}
-- 
1.7.1.262.g5ef3d

