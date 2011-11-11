Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:20641 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab1KKCGM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 21:06:12 -0500
From: <tao.peng@emc.com>
To: <bjschuma@netapp.com>, <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <bhalevy@tonian.com>
Date: Thu, 10 Nov 2011 21:05:32 -0500
Subject: RE: [PATCH-v2 7/7] pnfsblock: alloc short extent before submit bio
Message-ID: <F19688880B763E40B28B2B462677FBF805DD054CAA@MX09A.corp.emc.com>
References: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
 <1320938728-3715-8-git-send-email-bergwolf@gmail.com>
 <4EBBFF3F.8000509@netapp.com>
In-Reply-To: <4EBBFF3F.8000509@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Bryan,

> -----Original Message-----
> From: Bryan Schumaker [mailto:bjschuma@netapp.com]
> Sent: Friday, November 11, 2011 12:44 AM
> To: Peng Tao
> Cc: linux-nfs@vger.kernel.org; Trond.Myklebust@netapp.com; bhalevy@tonian.com;
> Peng, Tao
> Subject: Re: [PATCH-v2 7/7] pnfsblock: alloc short extent before submit bio
>
> On 11/10/2011 10:25 AM, Peng Tao wrote:
> > As discussed earlier, it is better for block client to allocate memory for
> > tracking extents state before submitting bio. So the patch does it by allocating
> > a short_extent for every INVALID extent touched by write pagelist and for
> > every zeroing page we created, saving them in layout header. Then in end_io we
> > can just use them to create commit list items and avoid memory allocation there.
> >
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/blocklayout/blocklayout.c |   74
> +++++++++++++++++++++++++++++--------
> >  fs/nfs/blocklayout/blocklayout.h |    9 ++++-
> >  fs/nfs/blocklayout/extents.c     |   62 +++++++++++++++++++++++++++-----
> >  3 files changed, 119 insertions(+), 26 deletions(-)
> >
> > diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> > index 3eaea2b..3fdfb29 100644
> > --- a/fs/nfs/blocklayout/blocklayout.c
> > +++ b/fs/nfs/blocklayout/blocklayout.c
> > @@ -90,8 +90,9 @@ static int is_writable(struct pnfs_block_extent *be, sector_t
> isect)
> >   */
> >  struct parallel_io {
> >     struct kref refcnt;
> > -   void (*pnfs_callback) (void *data);
> > +   void (*pnfs_callback) (void *data, int num_se);
> >     void *data;
> > +   int bse_count;
> >  };
> >
> >  static inline struct parallel_io *alloc_parallel(void *data)
> > @@ -102,6 +103,7 @@ static inline struct parallel_io *alloc_parallel(void *data)
> >     if (rv) {
> >             rv->data = data;
> >             kref_init(&rv->refcnt);
> > +           rv->bse_count = 0;
> >     }
> >     return rv;
> >  }
> > @@ -116,7 +118,7 @@ static void destroy_parallel(struct kref *kref)
> >     struct parallel_io *p = container_of(kref, struct parallel_io, refcnt);
> >
> >     dprintk("%s enter\n", __func__);
> > -   p->pnfs_callback(p->data);
> > +   p->pnfs_callback(p->data, p->bse_count);
> >     kfree(p);
> >  }
> >
> > @@ -211,7 +213,7 @@ static void bl_read_cleanup(struct work_struct *work)
> >  }
> >
> >  static void
> > -bl_end_par_io_read(void *data)
> > +bl_end_par_io_read(void *data, int unused)
> >  {
> >     struct nfs_read_data *rdata = data;
> >
> > @@ -312,6 +314,7 @@ static void mark_extents_written(struct pnfs_block_layout
> *bl,
> >  {
> >     sector_t isect, end;
> >     struct pnfs_block_extent *be;
> > +   struct pnfs_block_short_extent *se;
> >
> >     dprintk("%s(%llu, %u)\n", __func__, offset, count);
> >     if (count == 0)
> > @@ -324,8 +327,11 @@ static void mark_extents_written(struct
> pnfs_block_layout *bl,
> >             be = bl_find_get_extent(bl, isect, NULL);
> >             BUG_ON(!be); /* FIXME */
> >             len = min(end, be->be_f_offset + be->be_length) - isect;
> > -           if (be->be_state == PNFS_BLOCK_INVALID_DATA)
> > -                   bl_mark_for_commit(be, isect, len); /* What if fails? */
> > +           if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +                   se = bl_pop_one_short_extent(be->be_inval);
> > +                   BUG_ON(!se);
> > +                   bl_mark_for_commit(be, isect, len, se);
> > +           }
> >             isect += len;
> >             bl_put_extent(be);
> >     }
> > @@ -347,7 +353,8 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
> >             end_page_writeback(page);
> >             page_cache_release(page);
> >     } while (bvec >= bio->bi_io_vec);
> > -   if (!uptodate) {
> > +
> > +   if (unlikely(!uptodate)) {
> >             if (!wdata->pnfs_error)
> >                     wdata->pnfs_error = -EIO;
> >             pnfs_set_lo_fail(wdata->lseg);
> > @@ -356,7 +363,6 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
> >     put_parallel(par);
> >  }
> >
> > -/* This is basically copied from mpage_end_io_read */
> >  static void bl_end_io_write(struct bio *bio, int err)
> >  {
> >     struct parallel_io *par = bio->bi_private;
> > @@ -382,7 +388,7 @@ static void bl_write_cleanup(struct work_struct *work)
> >     dprintk("%s enter\n", __func__);
> >     task = container_of(work, struct rpc_task, u.tk_work);
> >     wdata = container_of(task, struct nfs_write_data, task);
> > -   if (!wdata->pnfs_error) {
> > +   if (likely(!wdata->pnfs_error)) {
> >             /* Marks for LAYOUTCOMMIT */
> >             mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
> >                                  wdata->args.offset, wdata->args.count);
> > @@ -391,10 +397,15 @@ static void bl_write_cleanup(struct work_struct *work)
> >  }
> >
> >  /* Called when last of bios associated with a bl_write_pagelist call finishes */
> > -static void bl_end_par_io_write(void *data)
> > +static void bl_end_par_io_write(void *data, int num_se)
> >  {
> >     struct nfs_write_data *wdata = data;
> >
> > +   if (unlikely(wdata->pnfs_error)) {
> > +           bl_free_short_extents(&BLK_LSEG2EXT(wdata->lseg)->bl_inval,
> > +                                   num_se);
> > +   }
> > +
> >     wdata->task.tk_status = wdata->pnfs_error;
> >     wdata->verf.committed = NFS_FILE_SYNC;
> >     INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
> > @@ -547,7 +558,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
> >      */
> >     par = alloc_parallel(wdata);
> >     if (!par)
> > -           return PNFS_NOT_ATTEMPTED;
> > +           goto out_mds;
> >     par->pnfs_callback = bl_end_par_io_write;
> >     /* At this point, have to be more careful with error handling */
> >
> > @@ -555,12 +566,15 @@ bl_write_pagelist(struct nfs_write_data *wdata, int
> sync)
> >     be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
> >     if (!be || !is_writable(be, isect)) {
> >             dprintk("%s no matching extents!\n", __func__);
> > -           wdata->pnfs_error = -EINVAL;
> > -           goto out;
> > +           goto out_mds;
> >     }
> >
> >     /* First page inside INVALID extent */
> >     if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +           if (likely(!bl_push_one_short_extent(be->be_inval)))
> > +                   par->bse_count++;
> > +           else
> > +                   goto out_mds;
> >             temp = offset >> PAGE_CACHE_SHIFT;
> >             npg_zero = do_div(temp, npg_per_block);
> >             isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
> > @@ -598,6 +612,19 @@ fill_invalid_ext:
> >                             wdata->pnfs_error = ret;
> >                             goto out;
> >                     }
> > +                   if (likely(!bl_push_one_short_extent(be->be_inval)))
> > +                           par->bse_count++;
> > +                   else {
> > +                           end_page_writeback(page);
> > +                           page_cache_release(page);
> > +                           wdata->pnfs_error = -ENOMEM;
> > +                           goto out;
> > +                   }
> > +                   /* FIXME: This should be done in bi_end_io */
> > +                   mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
> > +                                        page->index << PAGE_CACHE_SHIFT,
> > +                                        PAGE_CACHE_SIZE);
> > +
> >                     bio = bl_add_page_to_bio(bio, npg_zero, WRITE,
> >                                              isect, page, be,
> >                                              bl_end_io_write_zero, par);
> > @@ -606,10 +633,6 @@ fill_invalid_ext:
> >                             bio = NULL;
> >                             goto out;
> >                     }
> > -                   /* FIXME: This should be done in bi_end_io */
> > -                   mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
> > -                                        page->index << PAGE_CACHE_SHIFT,
> > -                                        PAGE_CACHE_SIZE);
> >  next_page:
> >                     isect += PAGE_CACHE_SECTORS;
> >                     extent_length -= PAGE_CACHE_SECTORS;
> > @@ -633,6 +656,15 @@ next_page:
> >                             wdata->pnfs_error = -EINVAL;
> >                             goto out;
> >                     }
> > +                   if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +                           if (likely(!bl_push_one_short_extent(
> > +                                                           be->be_inval)))
> > +                                   par->bse_count++;
> > +                           else {
> > +                                   wdata->pnfs_error = -ENOMEM;
> > +                                   goto out;
> > +                           }
> > +                   }
> >                     extent_length = be->be_length -
> >                         (isect - be->be_f_offset);
> >             }
> > @@ -680,6 +712,10 @@ out:
> >     bl_submit_bio(WRITE, bio);
> >     put_parallel(par);
> >     return PNFS_ATTEMPTED;
> > +out_mds:
> > +   bl_put_extent(be);
> > +   kfree(par);
> > +   return PNFS_NOT_ATTEMPTED;
> >  }
> >
> >  /* FIXME - range ignored */
> > @@ -706,11 +742,17 @@ static void
> >  release_inval_marks(struct pnfs_inval_markings *marks)
> >  {
> >     struct pnfs_inval_tracking *pos, *temp;
> > +   struct pnfs_block_short_extent *se, *stemp;
> >
> >     list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
> >             list_del(&pos->it_link);
> >             kfree(pos);
> >     }
> > +
> > +   list_for_each_entry_safe(se, stemp, &marks->im_extents, bse_node) {
> > +           list_del(&se->bse_node);
> > +           kfree(se);
> > +   }
> >     return;
> >  }
> >
> > diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> > index 60728ac..e31a2df 100644
> > --- a/fs/nfs/blocklayout/blocklayout.h
> > +++ b/fs/nfs/blocklayout/blocklayout.h
> > @@ -70,6 +70,7 @@ struct pnfs_inval_markings {
> >     spinlock_t      im_lock;
> >     struct my_tree  im_tree;        /* Sectors that need LAYOUTCOMMIT */
> >     sector_t        im_block_size;  /* Server blocksize in sectors */
> > +   struct list_head im_extents;    /* Short extents for INVAL->RW conversion */
> >  };
> >
> >  struct pnfs_inval_tracking {
> > @@ -105,6 +106,7 @@ BL_INIT_INVAL_MARKS(struct pnfs_inval_markings
> *marks, sector_t blocksize)
> >  {
> >     spin_lock_init(&marks->im_lock);
> >     INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
> > +   INIT_LIST_HEAD(&marks->im_extents);
> >     marks->im_block_size = blocksize;
> >     marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
> >                                        blocksize);
> > @@ -199,6 +201,11 @@ void clean_pnfs_block_layoutupdate(struct
> pnfs_block_layout *bl,
> >  int bl_add_merge_extent(struct pnfs_block_layout *bl,
> >                      struct pnfs_block_extent *new);
> >  int bl_mark_for_commit(struct pnfs_block_extent *be,
> > -                   sector_t offset, sector_t length);
> > +                   sector_t offset, sector_t length,
> > +                   struct pnfs_block_short_extent *new);
> > +int bl_push_one_short_extent(struct pnfs_inval_markings *marks);
> > +struct pnfs_block_short_extent *
> > +bl_pop_one_short_extent(struct pnfs_inval_markings *marks);
> > +void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free);
> >
> >  #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
> > diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> > index d0f52ed..db66e68 100644
> > --- a/fs/nfs/blocklayout/extents.c
> > +++ b/fs/nfs/blocklayout/extents.c
> > @@ -369,20 +369,18 @@ static void add_to_commitlist(struct pnfs_block_layout
> *bl,
> >
> >  /* Note the range described by offset, length is guaranteed to be contained
> >   * within be.
> > + * new will be freed, either by this function or add_to_commitlist if they
> > + * decide not to use it, or after LAYOUTCOMMIT uses it in the commitlist.
> >   */
> >  int bl_mark_for_commit(struct pnfs_block_extent *be,
> > -               sector_t offset, sector_t length)
> > +               sector_t offset, sector_t length,
> > +               struct pnfs_block_short_extent *new)
> >  {
> >     sector_t new_end, end = offset + length;
> > -   struct pnfs_block_short_extent *new;
> >     struct pnfs_block_layout *bl = container_of(be->be_inval,
> >                                                 struct pnfs_block_layout,
> >                                                 bl_inval);
> >
> > -   new = kmalloc(sizeof(*new), GFP_NOFS);
> > -   if (!new)
> > -           return -ENOMEM;
> > -
> >     mark_written_sectors(be->be_inval, offset, length);
> >     /* We want to add the range to commit list, but it must be
> >      * block-normalized, and verified that the normalized range has
> > @@ -412,9 +410,6 @@ int bl_mark_for_commit(struct pnfs_block_extent *be,
> >     new->bse_mdev = be->be_mdev;
> >
> >     spin_lock(&bl->bl_ext_lock);
> > -   /* new will be freed, either by add_to_commitlist if it decides not
> > -    * to use it, or after LAYOUTCOMMIT uses it in the commitlist.
> > -    */
> >     add_to_commitlist(bl, new);
> >     spin_unlock(&bl->bl_ext_lock);
> >     return 0;
> > @@ -862,3 +857,52 @@ clean_pnfs_block_layoutupdate(struct
> pnfs_block_layout *bl,
> >             }
> >     }
> >  }
> > +
> > +int bl_push_one_short_extent(struct pnfs_inval_markings *marks)
> > +{
> > +   struct pnfs_block_short_extent *new;
> > +
> > +   new = kmalloc(sizeof(*new), GFP_NOFS);
> > +   if (unlikely(!new))
> > +           return -ENOMEM;
> > +
> > +   spin_lock(&marks->im_lock);
> > +   list_add(&new->bse_node, &marks->im_extents);
> > +   spin_unlock(&marks->im_lock);
> > +
> > +   return 0;
> > +}
> > +
> > +struct pnfs_block_short_extent *
> > +bl_pop_one_short_extent(struct pnfs_inval_markings *marks)
> > +{
> > +   struct pnfs_block_short_extent *rv = NULL;
> > +
> > +   spin_lock(&marks->im_lock);
> > +   if (!list_empty(&marks->im_extents)) {
> > +           rv = list_entry((&marks->im_extents)->next,
> > +                           struct pnfs_block_short_extent, bse_node);
> > +           list_del_init(&rv->bse_node);
> > +   }
> > +   spin_unlock(&marks->im_lock);
> > +
> > +   return rv;
> > +}
> > +
> > +void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free)
> > +{
> > +   struct pnfs_block_short_extent *se = NULL, *tmp;
> > +
> > +   BUG_ON(num_to_free <= 0);
>
> Why is it a bug if num_to_free is <= 0?  Couldn't you do:
>
> if (num_to_free <= 0)
>       return;
>
> instead?
It used to be a sanity check but was changed to BUG_ON in the second version.
Yeah, after giving it a second thought, I think it necessary to keep the sanity check. There are cases that num_to_free can be zero. E.g., a write_pagelist touches no INVALID extents, and one bio fails with disk failure. Then we will come to calling bl_free_short_extents() with num_to_free == 0. So the BUG_ON is really a bug itself... I will change it back to a normal sanity check.

Thanks,
Tao

>From d4f49b042411da140c95559895c57a00a1920fdd Mon Sep 17 00:00:00 2001
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 10 Nov 2011 03:57:00 -0500
Subject: [PATCH 7/7] pnfsblock: alloc short extent before submit bio

As discussed earlier, it is better for block client to allocate memory for
tracking extents state before submitting bio. So the patch does it by allocating
a short_extent for every INVALID extent touched by write pagelist and for
every zeroing page we created, saving them in layout header. Then in end_io we
can just use them to create commit list items and avoid memory allocation there.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   74 +++++++++++++++++++++++++++++--------
 fs/nfs/blocklayout/blocklayout.h |    9 ++++-
 fs/nfs/blocklayout/extents.c     |   63 +++++++++++++++++++++++++++-----
 3 files changed, 120 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7fc69c9..1dd2983 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -90,8 +90,9 @@ static int is_writable(struct pnfs_block_extent *be, sector_t isect)
  */
 struct parallel_io {
        struct kref refcnt;
-       void (*pnfs_callback) (void *data);
+       void (*pnfs_callback) (void *data, int num_se);
        void *data;
+       int bse_count;
 };

 static inline struct parallel_io *alloc_parallel(void *data)
@@ -102,6 +103,7 @@ static inline struct parallel_io *alloc_parallel(void *data)
        if (rv) {
                rv->data = data;
                kref_init(&rv->refcnt);
+               rv->bse_count = 0;
        }
        return rv;
 }
@@ -116,7 +118,7 @@ static void destroy_parallel(struct kref *kref)
        struct parallel_io *p = container_of(kref, struct parallel_io, refcnt);

        dprintk("%s enter\n", __func__);
-       p->pnfs_callback(p->data);
+       p->pnfs_callback(p->data, p->bse_count);
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
+       struct pnfs_block_short_extent *se;

        dprintk("%s(%llu, %u)\n", __func__, offset, count);
        if (count == 0)
@@ -324,8 +327,11 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
                be = bl_find_get_extent(bl, isect, NULL);
                BUG_ON(!be); /* FIXME */
                len = min(end, be->be_f_offset + be->be_length) - isect;
-               if (be->be_state == PNFS_BLOCK_INVALID_DATA)
-                       bl_mark_for_commit(be, isect, len); /* What if fails? */
+               if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+                       se = bl_pop_one_short_extent(be->be_inval);
+                       BUG_ON(!se);
+                       bl_mark_for_commit(be, isect, len, se);
+               }
                isect += len;
                bl_put_extent(be);
        }
@@ -347,7 +353,8 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
                end_page_writeback(page);
                page_cache_release(page);
        } while (bvec >= bio->bi_io_vec);
-       if (!uptodate) {
+
+       if (unlikely(!uptodate)) {
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
-       if (!wdata->pnfs_error) {
+       if (likely(!wdata->pnfs_error)) {
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

+       if (unlikely(wdata->pnfs_error)) {
+               bl_free_short_extents(&BLK_LSEG2EXT(wdata->lseg)->bl_inval,
+                                       num_se);
+       }
+
        wdata->task.tk_status = wdata->pnfs_error;
        wdata->verf.committed = NFS_FILE_SYNC;
        INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
@@ -547,7 +558,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
         */
        par = alloc_parallel(wdata);
        if (!par)
-               return PNFS_NOT_ATTEMPTED;
+               goto out_mds;
        par->pnfs_callback = bl_end_par_io_write;
        /* At this point, have to be more careful with error handling */

@@ -555,12 +566,15 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
        be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
        if (!be || !is_writable(be, isect)) {
                dprintk("%s no matching extents!\n", __func__);
-               wdata->pnfs_error = -EINVAL;
-               goto out;
+               goto out_mds;
        }

        /* First page inside INVALID extent */
        if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+               if (likely(!bl_push_one_short_extent(be->be_inval)))
+                       par->bse_count++;
+               else
+                       goto out_mds;
                temp = offset >> PAGE_CACHE_SHIFT;
                npg_zero = do_div(temp, npg_per_block);
                isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
@@ -598,6 +612,19 @@ fill_invalid_ext:
                                wdata->pnfs_error = ret;
                                goto out;
                        }
+                       if (likely(!bl_push_one_short_extent(be->be_inval)))
+                               par->bse_count++;
+                       else {
+                               end_page_writeback(page);
+                               page_cache_release(page);
+                               wdata->pnfs_error = -ENOMEM;
+                               goto out;
+                       }
+                       /* FIXME: This should be done in bi_end_io */
+                       mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+                                            page->index << PAGE_CACHE_SHIFT,
+                                            PAGE_CACHE_SIZE);
+
                        bio = bl_add_page_to_bio(bio, npg_zero, WRITE,
                                                 isect, page, be,
                                                 bl_end_io_write_zero, par);
@@ -606,10 +633,6 @@ fill_invalid_ext:
                                bio = NULL;
                                goto out;
                        }
-                       /* FIXME: This should be done in bi_end_io */
-                       mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
-                                            page->index << PAGE_CACHE_SHIFT,
-                                            PAGE_CACHE_SIZE);
 next_page:
                        isect += PAGE_CACHE_SECTORS;
                        extent_length -= PAGE_CACHE_SECTORS;
@@ -633,6 +656,15 @@ next_page:
                                wdata->pnfs_error = -EINVAL;
                                goto out;
                        }
+                       if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+                               if (likely(!bl_push_one_short_extent(
+                                                               be->be_inval)))
+                                       par->bse_count++;
+                               else {
+                                       wdata->pnfs_error = -ENOMEM;
+                                       goto out;
+                               }
+                       }
                        extent_length = be->be_length -
                            (isect - be->be_f_offset);
                }
@@ -680,6 +712,10 @@ out:
        bl_submit_bio(WRITE, bio);
        put_parallel(par);
        return PNFS_ATTEMPTED;
+out_mds:
+       bl_put_extent(be);
+       kfree(par);
+       return PNFS_NOT_ATTEMPTED;
 }

 /* FIXME - range ignored */
@@ -706,11 +742,17 @@ static void
 release_inval_marks(struct pnfs_inval_markings *marks)
 {
        struct pnfs_inval_tracking *pos, *temp;
+       struct pnfs_block_short_extent *se, *stemp;

        list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
                list_del(&pos->it_link);
                kfree(pos);
        }
+
+       list_for_each_entry_safe(se, stemp, &marks->im_extents, bse_node) {
+               list_del(&se->bse_node);
+               kfree(se);
+       }
        return;
 }

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 60728ac..e31a2df 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -70,6 +70,7 @@ struct pnfs_inval_markings {
        spinlock_t      im_lock;
        struct my_tree  im_tree;        /* Sectors that need LAYOUTCOMMIT */
        sector_t        im_block_size;  /* Server blocksize in sectors */
+       struct list_head im_extents;    /* Short extents for INVAL->RW conversion */
 };

 struct pnfs_inval_tracking {
@@ -105,6 +106,7 @@ BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
        spin_lock_init(&marks->im_lock);
        INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
+       INIT_LIST_HEAD(&marks->im_extents);
        marks->im_block_size = blocksize;
        marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
                                           blocksize);
@@ -199,6 +201,11 @@ void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
                         struct pnfs_block_extent *new);
 int bl_mark_for_commit(struct pnfs_block_extent *be,
-                       sector_t offset, sector_t length);
+                       sector_t offset, sector_t length,
+                       struct pnfs_block_short_extent *new);
+int bl_push_one_short_extent(struct pnfs_inval_markings *marks);
+struct pnfs_block_short_extent *
+bl_pop_one_short_extent(struct pnfs_inval_markings *marks);
+void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free);

 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index d0f52ed..6ce5a8d 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -369,20 +369,18 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,

 /* Note the range described by offset, length is guaranteed to be contained
  * within be.
+ * new will be freed, either by this function or add_to_commitlist if they
+ * decide not to use it, or after LAYOUTCOMMIT uses it in the commitlist.
  */
 int bl_mark_for_commit(struct pnfs_block_extent *be,
-                   sector_t offset, sector_t length)
+                   sector_t offset, sector_t length,
+                   struct pnfs_block_short_extent *new)
 {
        sector_t new_end, end = offset + length;
-       struct pnfs_block_short_extent *new;
        struct pnfs_block_layout *bl = container_of(be->be_inval,
                                                    struct pnfs_block_layout,
                                                    bl_inval);

-       new = kmalloc(sizeof(*new), GFP_NOFS);
-       if (!new)
-               return -ENOMEM;
-
        mark_written_sectors(be->be_inval, offset, length);
        /* We want to add the range to commit list, but it must be
         * block-normalized, and verified that the normalized range has
@@ -412,9 +410,6 @@ int bl_mark_for_commit(struct pnfs_block_extent *be,
        new->bse_mdev = be->be_mdev;

        spin_lock(&bl->bl_ext_lock);
-       /* new will be freed, either by add_to_commitlist if it decides not
-        * to use it, or after LAYOUTCOMMIT uses it in the commitlist.
-        */
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
+       struct pnfs_block_short_extent *new;
+
+       new = kmalloc(sizeof(*new), GFP_NOFS);
+       if (unlikely(!new))
+               return -ENOMEM;
+
+       spin_lock(&marks->im_lock);
+       list_add(&new->bse_node, &marks->im_extents);
+       spin_unlock(&marks->im_lock);
+
+       return 0;
+}
+
+struct pnfs_block_short_extent *
+bl_pop_one_short_extent(struct pnfs_inval_markings *marks)
+{
+       struct pnfs_block_short_extent *rv = NULL;
+
+       spin_lock(&marks->im_lock);
+       if (!list_empty(&marks->im_extents)) {
+               rv = list_entry((&marks->im_extents)->next,
+                               struct pnfs_block_short_extent, bse_node);
+               list_del_init(&rv->bse_node);
+       }
+       spin_unlock(&marks->im_lock);
+
+       return rv;
+}
+
+void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free)
+{
+       struct pnfs_block_short_extent *se = NULL, *tmp;
+
+       if (num_to_free <= 0)
+               return;
+
+       spin_lock(&marks->im_lock);
+       list_for_each_entry_safe(se, tmp, &marks->im_extents, bse_node) {
+               list_del(&se->bse_node);
+               kfree(se);
+               if (--num_to_free == 0)
+                       break;
+       }
+       spin_unlock(&marks->im_lock);
+
+       BUG_ON(num_to_free > 0);
+}
--
1.7.4.2

