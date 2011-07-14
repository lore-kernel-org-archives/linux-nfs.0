Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:17203 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab1GNFIq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 01:08:46 -0400
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>
CC: <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>, <rees@umich.edu>
Date: Thu, 14 Jul 2011 01:05:07 -0400
Subject: RE: [PATCH 1/6] SQUASHME: pnfs-block: Remove write_begin/end hooks
Message-ID: <F19688880B763E40B28B2B462677FBF805BEFF0D64@MX09A.corp.emc.com>
References: <cover.1310055433.git.rees@umich.edu>
 <ce801968be38153f6d75dfe227eb03631eee1baa.1310055433.git.rees@umich.edu>
 <4E1D950D.4030404@tonian.com>
In-Reply-To: <4E1D950D.4030404@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

Thanks a lot for your comments.

Cheers,
-Bergwolf

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Wednesday, July 13, 2011 8:52 PM
> To: Jim Rees; Peng, Tao
> Cc: linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH 1/6] SQUASHME: pnfs-block: Remove write_begin/end hooks
>
> Hi, sorry for my late response.
> I like the direction this is going!
> However I have a few comments inline below.
>
> In general, combining cosmetic changes or cleanups with
> the real functionality makes the patch really hard to review.
>
> Please separate the patches so that each one is boiled down to the
> minimum to make it self-sufficient, even if that ends up
> with more patches to review,  (see Documentation/SubmittingPatches)
After squashing, this patch will only be rewriting bl_write_pagelist.

>
> more inline...
>
> On 2011-07-07 19:26, Jim Rees wrote:
> > From: Peng Tao <bergwolf@gmail.com>
> >
> > Do not call pnfs_update_layout at write_begin, and rewrite bl_write_pagelist
> > to handle EOF there.
> >
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/blocklayout/blocklayout.c |  652 ++++++++++++++++++--------------------
> >  fs/nfs/file.c                    |   26 +--
> >  fs/nfs/pnfs.c                    |   41 ---
> >  fs/nfs/pnfs.h                    |  115 -------
> >  fs/nfs/write.c                   |   12 +-
> >  include/linux/nfs_fs.h           |    3 +-
> >  6 files changed, 321 insertions(+), 528 deletions(-)
> >
> > diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> > index 8531fd7..331d687 100644
> > --- a/fs/nfs/blocklayout/blocklayout.c
> > +++ b/fs/nfs/blocklayout/blocklayout.c
> > @@ -32,8 +32,8 @@
> >  #include <linux/module.h>
> >  #include <linux/init.h>
> >
> > -#include <linux/buffer_head.h> /* various write calls */
> > -#include <linux/bio.h> /* struct bio */
> > +#include <linux/buffer_head.h>     /* various write calls */
> > +#include <linux/bio.h>             /* struct bio */
> >  #include <linux/vmalloc.h>
> >  #include "blocklayout.h"
> >
> > @@ -75,16 +75,11 @@ static int is_hole(struct pnfs_block_extent *be, sector_t
> isect)
> >   */
> >  static int is_writable(struct pnfs_block_extent *be, sector_t isect)
> >  {
> > -   if (be->be_state == PNFS_BLOCK_READWRITE_DATA)
> > -           return 1;
> > -   else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
> > -           return 0;
> > -   else
> > -           return is_sector_initialized(be->be_inval, isect);
> > +   return (be->be_state == PNFS_BLOCK_READWRITE_DATA ||
> > +           be->be_state == PNFS_BLOCK_INVALID_DATA);
> >  }
> >
> > -static int
> > -dont_like_caller(struct nfs_page *req)
> > +static int dont_like_caller(struct nfs_page *req)
> >  {
> >     if (atomic_read(&req->wb_complete)) {
> >             /* Called by _multi */
> > @@ -109,7 +104,7 @@ static inline struct parallel_io *alloc_parallel(void *data)
> >  {
> >     struct parallel_io *rv;
> >
> > -   rv  = kmalloc(sizeof(*rv), GFP_KERNEL);
> > +   rv = kmalloc(sizeof(*rv), GFP_KERNEL);
> >     if (rv) {
> >             rv->data = data;
> >             kref_init(&rv->refcnt);
> > @@ -136,21 +131,19 @@ static inline void put_parallel(struct parallel_io *p)
> >     kref_put(&p->refcnt, destroy_parallel);
> >  }
> >
> > -static struct bio *
> > -bl_submit_bio(int rw, struct bio *bio)
> > +static struct bio *bl_submit_bio(int rw, struct bio *bio)
> >  {
> >     if (bio) {
> >             get_parallel(bio->bi_private);
> >             dprintk("%s submitting %s bio %u@%llu\n", __func__,
> >                     rw == READ ? "read" : "write",
> > -                   bio->bi_size, (u64)bio->bi_sector);
> > +                   bio->bi_size, (u64) bio->bi_sector);
>
> Do you even support or want to support 32 bit bi_sectors?
> If not, you could just add BUILD_BUG_ON(sizeof(sector_t) != 8);
> Otherwise, typecasting to (unsigned long long) would be more portable.
Will change it to (unsigned long long). Thanks.

>
> >             submit_bio(rw, bio);
> >     }
> >     return NULL;
>
> What's the point of always returning NULL?
It intends to submit bio and let caller re-allocate it. The logic is similar to mpage_bio_submit().

>
> >  }
> >
> > -static inline void
> > -bl_done_with_rpage(struct page *page, const int ok)
> > +static inline void bl_done_with_rpage(struct page *page, const int ok)
> >  {
> >     if (ok) {
> >             ClearPagePnfsErr(page);
> > @@ -191,8 +184,7 @@ static void bl_read_cleanup(struct work_struct *work)
> >     pnfs_ld_read_done(rdata);
> >  }
> >
> > -static void
> > -bl_end_par_io_read(void *data)
> > +static void bl_end_par_io_read(void *data)
> >  {
> >     struct nfs_read_data *rdata = data;
> >
> > @@ -208,8 +200,7 @@ static void bl_rpc_do_nothing(struct rpc_task *task, void
> *calldata)
> >     return;
> >  }
> >
> > -static enum pnfs_try_status
> > -bl_read_pagelist(struct nfs_read_data *rdata)
> > +static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
> >  {
> >     int i, hole;
> >     struct bio *bio = NULL;
> > @@ -222,7 +213,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
> >     int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
> >
> >     dprintk("%s enter nr_pages %u offset %lld count %Zd\n", __func__,
> > -          rdata->npages, f_offset, count);
> > +           rdata->npages, f_offset, count);
> >
> >     if (dont_like_caller(rdata->req)) {
> >             dprintk("%s dont_like_caller failed\n", __func__);
> > @@ -260,10 +251,10 @@ bl_read_pagelist(struct nfs_read_data *rdata)
> >                             break;
> >                     }
> >                     extent_length = be->be_length -
> > -                           (isect - be->be_f_offset);
> > +                       (isect - be->be_f_offset);
> >                     if (cow_read) {
> >                             sector_t cow_length = cow_read->be_length -
> > -                                   (isect - cow_read->be_f_offset);
> > +                               (isect - cow_read->be_f_offset);
> >                             extent_length = min(extent_length, cow_length);
> >                     }
> >             }
> > @@ -282,15 +273,17 @@ bl_read_pagelist(struct nfs_read_data *rdata)
> >                     be_read = (hole && cow_read) ? cow_read : be;
> >                     for (;;) {
> >                             if (!bio) {
> > -                                   bio = bio_alloc(GFP_NOIO, rdata->npages - i);
> > +                                   bio =
> > +                                       bio_alloc(GFP_NOIO,
> > +                                                 rdata->npages - i);
> >                                     if (!bio) {
> >                                             /* Error out this page */
> >                                             bl_done_with_rpage(pages[i], 0);
> >                                             break;
> >                                     }
> >                                     bio->bi_sector = isect -
> > -                                           be_read->be_f_offset +
> > -                                           be_read->be_v_offset;
> > +                                       be_read->be_f_offset +
> > +                                       be_read->be_v_offset;
> >                                     bio->bi_bdev = be_read->be_mdev;
> >                                     bio->bi_end_io = bl_end_io_read;
> >                                     bio->bi_private = par;
> > @@ -315,7 +308,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
> >     put_parallel(par);
> >     return PNFS_ATTEMPTED;
> >
> > - use_mds:
> > +use_mds:
> >     dprintk("Giving up and using normal NFS\n");
> >     return PNFS_NOT_ATTEMPTED;
> >  }
> > @@ -335,18 +328,16 @@ static void mark_extents_written(struct
> pnfs_block_layout *bl,
> >     while (isect < end) {
> >             sector_t len;
> >             be = find_get_extent(bl, isect, NULL);
> > -           BUG_ON(!be); /* FIXME */
> > +           BUG_ON(!be);    /* FIXME */
> >             len = min(end, be->be_f_offset + be->be_length) - isect;
> >             if (be->be_state == PNFS_BLOCK_INVALID_DATA)
> > -                   mark_for_commit(be, isect, len); /* What if fails? */
> > +                   mark_for_commit(be, isect, len);        /* What if fails? */
> >             isect += len;
> >             put_extent(be);
> >     }
> >  }
> >
> > -/* STUB - this needs thought */
> > -static inline void
> > -bl_done_with_wpage(struct page *page, const int ok)
> > +static inline void bl_done_with_wpage(struct page *page, const int ok)
> >  {
> >     if (!ok) {
> >             SetPageError(page);
> > @@ -360,15 +351,37 @@ bl_done_with_wpage(struct page *page, const int ok)
> >                     spin_unlock(&inode->i_lock);
> >             }
> >     }
> > -   /* end_page_writeback called in rpc_release.  Should be done here. */
> >  }
> >
> > -/* This is basically copied from mpage_end_io_read */
> > +static void bl_end_io_write_zero(struct bio *bio, int err)
> > +{
> > +   struct parallel_io *par = bio->bi_private;
> > +   const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
> > +   struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
> > +   struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
> > +
> > +   do {
> > +           struct page *page = bvec->bv_page;
> > +
> > +           if (--bvec >= bio->bi_io_vec)
> > +                   prefetchw(&bvec->bv_page->flags);
> > +           bl_done_with_wpage(page, uptodate);
> > +           /* This is the zeroing page we added */
> > +           end_page_writeback(page);
> > +           page_cache_release(page);
> > +   } while (bvec >= bio->bi_io_vec);
> > +   if (!uptodate && !wdata->pnfs_error)
> > +           wdata->pnfs_error = -EIO;
> > +   bio_put(bio);
> > +   put_parallel(par);
> > +}
> > +
> >  static void bl_end_io_write(struct bio *bio, int err)
> >  {
> > -   void *data = bio->bi_private;
> > +   struct parallel_io *par = bio->bi_private;
> >     const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
> >     struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
> > +   struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
> >
> >     do {
> >             struct page *page = bvec->bv_page;
> > @@ -377,8 +390,10 @@ static void bl_end_io_write(struct bio *bio, int err)
> >                     prefetchw(&bvec->bv_page->flags);
> >             bl_done_with_wpage(page, uptodate);
> >     } while (bvec >= bio->bi_io_vec);
> > +   if (!uptodate && !wdata->pnfs_error)
> > +           wdata->pnfs_error = -EIO;
> >     bio_put(bio);
> > -   put_parallel(data);
> > +   put_parallel(par);
> >  }
> >
> >  /* Function scheduled for call during bl_end_par_io_write,
> > @@ -391,7 +406,7 @@ static void bl_write_cleanup(struct work_struct *work)
> >     dprintk("%s enter\n", __func__);
> >     task = container_of(work, struct rpc_task, u.tk_work);
> >     wdata = container_of(task, struct nfs_write_data, task);
> > -   if (!wdata->task.tk_status) {
> > +   if (!wdata->pnfs_error) {
> >             /* Marks for LAYOUTCOMMIT */
> >             /* BUG - this should be called after each bio, not after
> >              * all finish, unless have some way of storing success/failure
> > @@ -403,8 +418,7 @@ static void bl_write_cleanup(struct work_struct *work)
> >  }
> >
> >  /* Called when last of bios associated with a bl_write_pagelist call finishes */
> > -static void
> > -bl_end_par_io_write(void *data)
> > +static void bl_end_par_io_write(void *data)
> >  {
> >     struct nfs_write_data *wdata = data;
> >
> > @@ -415,19 +429,118 @@ bl_end_par_io_write(void *data)
> >     schedule_work(&wdata->task.u.tk_work);
> >  }
> >
> > +/* STUB - mark intersection of layout and page as bad, so is not
> > + * used again.
> > + */
> > +static void mark_bad_read(void)
> > +{
> > +   return;
> > +}
> > +
> > +/* Copied from buffer.c */
>
> NAK.  If this code needs to be shared internally you should make it
> public, declare it properly in linux/buffer_head.h, and EXPORT_SYMBOL_GPL it
This will be removed as expained bellow.

>
> > +static void __end_buffer_read_notouch(struct buffer_head *bh, int uptodate)
> > +{
> > +   if (uptodate) {
> > +           set_buffer_uptodate(bh);
> > +   } else {
> > +           /* This happens, due to failed READA attempts. */
> > +           clear_buffer_uptodate(bh);
> > +   }
> > +   unlock_buffer(bh);
> > +}
> > +
> > +/* Copied from buffer.c */
>
> This should be turned into a static inline helper in buffer_head.h since it
> just an alias for __end_buffer_read_notouch, but anyway, why do _you_
> need it here?
After looking into it more closely, I think we can just remove all the end_buffer_read_xxx functions here and call bh_submit_read() in init_page_for_write(). I will make the change. Thanks.

>
> > +static void end_buffer_read_nobh(struct buffer_head *bh, int uptodate)
> > +{
> > +   __end_buffer_read_notouch(bh, uptodate);
> > +}
> > +
> > +/*
> > + * map_block:  map a requested I/0 block (isect) into an offset in the LVM
> > + * meta block_device
>
> What's a "meta block_device"?
We can remove the *meta* if you don't like the name.

>
> > + */
> > +static void
> > +map_block(sector_t isect, struct pnfs_block_extent *be, struct buffer_head *bh)
>
> I'd put the output parameter, bh, first, followed by the input parameters.
Will do that. Thanks.

>
> > +{
> > +   dprintk("%s enter be=%p\n", __func__, be);
> > +bl_end_io_write_zero
> > +   set_buffer_mapped(bh);
> > +   bh->b_bdev = be->be_mdev;
> > +   bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
> > +       (be->be_mdev->bd_inode->i_blkbits - 9);
>
> Please use SECTOR_SHIFT from <linux/device-mapper.h> rather than '9'.
Will do that. Thanks.

>
> > +
> > +   dprintk("%s isect %ld, bh->b_blocknr %ld, using bsize %Zd\n",
> > +           __func__, (long)isect, (long)bh->b_blocknr, bh->b_size);
> > +   return;
> > +}
> > +
> > +/* Given an unmapped page, zero it (or read in page for COW),
> > + */
>
> Why is the (or read ...) in parenthesis?
> It's of exactly the same importance as the zeroing part of this function.
> Also, single line comments can have the closing "*/" on the same line.
Will change it. Thanks.

>
> > +static int
> > +init_page_for_write(struct page *page, struct pnfs_block_extent *cow_read)
> > +{
> > +   struct buffer_head *bh = NULL;
> > +   int ret = 0;
> > +   sector_t isect;
> > +
> > +   dprintk("%s enter, %p\n", __func__, page);
> > +   BUG_ON(PageUptodate(page));
> > +   /* not COW, zero and return */
>
> This comment is not needed.  The code is straight forward as it is.
Will remove it.

>
> > +   if (!cow_read) {
> > +           zero_user_segment(page, 0, PAGE_SIZE);
> > +           SetPageUptodate(page);
> > +           goto cleanup;
> > +   }
> > +
> > +   /* COW, readin page */
>
> This one can be removed too, unless you have something
> non-trivial to document.
Will remove it.

>
> > +   bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
> > +   if (!bh) {
> > +           ret = -ENOMEM;
> > +           goto cleanup;
> > +   }
> > +
> > +   isect = (sector_t) page->index << (PAGE_CACHE_SHIFT - 9);
>
> ditto SECTOR_SHIFT
> I see you use  (PAGE_CACHE_SHIFT - 9) in other places too so
> even better,
> #define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
Agreed, will do it.

>
> Also, no space after the type cast (not sure why this is not in
> Documentation/CodingStyle)
>
> > +   map_block(isect, cow_read, bh);
> > +   lock_buffer(bh);
> > +   bh->b_end_io = end_buffer_read_nobh;
> > +   submit_bh(READ, bh);
> > +   dprintk("%s: Waiting for buffer read\n", __func__);
> > +   wait_on_buffer(bh);
> > +   if (!buffer_uptodate(bh)) {
> > +           ret = -EIO;
> > +           goto cleanup;
> > +   }
> > +   SetPageUptodate(page);
> > +   SetPageMappedToDisk(page);
> > +
> > +cleanup:
> > +   put_extent(cow_read);
> > +   if (bh)
> > +           free_buffer_head(bh);
> > +   if (ret) {
> > +           /* Need to mark layout with bad read...should now
> > +            * just use nfs4 for reads and writes.
> > +            */
> > +           mark_bad_read();
> > +   }
> > +   return ret;
> > +}
> > +
> >  static enum pnfs_try_status
> > -bl_write_pagelist(struct nfs_write_data *wdata,
> > -             int sync)
> > +bl_write_pagelist(struct nfs_write_data *wdata, int sync)
> >  {
> > -   int i;
> > +   int i, ret, npg_zero, pg_index, last = 0;
> >     struct bio *bio = NULL;
> > -   struct pnfs_block_extent *be = NULL;
> > -   sector_t isect, extent_length = 0;
> > +   struct pnfs_block_extent *be = NULL, *cow_read = NULL;
> > +   sector_t isect, last_isect = 0, extent_length = 0;
> >     struct parallel_io *par;
> >     loff_t offset = wdata->args.offset;
> >     size_t count = wdata->args.count;
> >     struct page **pages = wdata->args.pages;
> > -   int pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
> > +   struct page *page;
> > +   pgoff_t index;
> > +   int npg_per_block =
> > +       NFS_SERVER(wdata->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
> >
> >     dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
> >     if (!wdata->lseg) {
> > @@ -439,11 +552,8 @@ bl_write_pagelist(struct nfs_write_data *wdata,
> >             return PNFS_NOT_ATTEMPTED;
> >     }
> >     /* At this point, wdata->pages is a (sequential) list of nfs_pages.
> > -    * We want to write each, and if there is an error remove it from
> > -    * list and call
> > -    * nfs_retry_request(req) to have it redone using nfs.
> > -    * QUEST? Do as block or per req?  Think have to do per block
> > -    * as part of end_bio
> > +    * We want to write each, and if there is an error set pnfs_error
> > +    * to have it redone using nfs.
> >      */
> >     par = alloc_parallel(wdata);
> >     if (!par)
> > @@ -454,7 +564,106 @@ bl_write_pagelist(struct nfs_write_data *wdata,
> >     /* At this point, have to be more careful with error handling */
> >
> >     isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> 9);
> > -   for (i = pg_index; i < wdata->npages ; i++) {
> > +   be = find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
> > +   if (!be || !is_writable(be, isect)) {
> > +           dprintk("%s no matching extents!\n", __func__);
> > +           wdata->pnfs_error = -EINVAL;
> > +           goto out;
> > +   }
> > +
> > +   /* First page inside INVALID extent */
> > +   if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +           npg_zero = (offset >> PAGE_CACHE_SHIFT) % npg_per_block;
> > +           isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
> > +                                (long)PAGE_CACHE_MASK) >> 9);
>
> ditto SECTOR_SHIFT.
>
> > +           extent_length = be->be_length - (isect - be->be_f_offset);
> > +
> > +fill_invalid_ext:
> > +           dprintk("%s need to zero %d pages\n", __func__, npg_zero);
> > +           while (npg_zero) {
>
> a for loop seems more appropriate here
OK. Will change it.

>
> > +                   /* page ref released in bl_end_io_write_zero */
> > +                   index = isect >> (PAGE_CACHE_SHIFT - 9);
>
> ditto PAGE_CACHE_SECTOR_SHIFT
>
> > +                   dprintk("%s zero %dth page: index %lu isect %lu\n",
> > +                           __func__, npg_zero, index, isect);
> > +                   page =
> > +                       find_or_create_page(wdata->inode->i_mapping, index,
> > +                                           GFP_NOFS);
> > +                   if (!page) {
> > +                           dprintk("%s oom\n", __func__);
> > +                           wdata->pnfs_error = -ENOMEM;
> > +                           goto out;
> > +                   }
> > +
> > +                   /* PageDirty: Other will write this out
> > +                    * PageWriteback: Other is writing this out
> > +                    * PageUptodate && sector_initialized: already written out
> > +                    */
> > +                   if (PageDirty(page) || PageWriteback(page) ||
> > +                       (PageUptodate(page) &&
> > +                        is_sector_initialized(be->be_inval, isect))) {
> > +                           dprintk
> > +                               ("page %lu is uptodate %d dirty %d writeback %d\n",
> > +                                page->index, PageUptodate(page),
> > +                                PageDirty(page), PageWriteback(page));
> > +                           unlock_page(page);
> > +                           page_cache_release(page);
> > +                           npg_zero--;
> > +                           isect += PAGE_CACHE_SIZE >> 9;
> > +                           extent_length -= PAGE_CACHE_SIZE >> 9;
>
> #define SECTORS_PER_PAGE (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
>
> (should this be done in the iteration leg of the for statement
> or at a label just before the end of the loop?)
Will add goto a lable to the end of the loop. Thanks.

>
> > +                           continue;
> > +                   }
> > +                   if (!PageUptodate(page) && cow_read) {
> > +                           /* New page, readin or zero it */
> > +                           init_page_for_write(page, cow_read);
> > +                   }
> > +                   set_page_writeback(page);
> > +                   unlock_page(page);
> > +
> > +                   ret = mark_initialized_sectors(be->be_inval, isect,
> > +                                                  PAGE_CACHE_SECTORS,
> > +                                                  NULL);
> > +                   if (unlikely(ret)) {
> > +                           dprintk("%s mark_initialized_sectors fail %d\n",
> > +                                   __func__, ret);
>
> what about end_page_writeback(page)?
Nice catch. Will add it here. Thanks.

>
> > +                           page_cache_release(page);
> > +                           wdata->pnfs_error = ret;
> > +                           goto out;
> > +                   }
> > +                   for (;;) {
>
> Doing an infinite loop here seems like a bad idea.
>
> My understanding is that eventually you want to submit bios for all npg_zero
> pages.
>
> Each time you go through this section you add one page,
> possibly allocating a bio if this is the first time, or if you previously
> submitted the bio (and set bio to NULL, which shouldn't be a side
> effect of bl_submit_bio, but rather it should be clearly spelled out
> by its callers)
The idea is that when current bio is full, we submit and re-allocate it. And then add the page to it.

>
> > +                           if (!bio) {
> > +                                   bio = bio_alloc(GFP_NOIO, npg_zero--);
>
> The post-decrement of npg_zero is non intuitive since bio_alloc
> allocates npg_zero iovecs and the decrement logically belongs to the
> bio_add_page below.
I'll move npg_zero-- to the end of the loop so that is where we've done with current page.

>
> > +                                   if (unlikely(!bio)) {
> > +                                           end_page_writeback(page);
> > +                                           page_cache_release(page);
> > +                                           wdata->pnfs_error = -ENOMEM;
> > +                                           goto out;
>
> this calls for a common error path handling path.
The out path is the error handling path. My concern is that if we take care of page_writeback and release in error handling path, we will have two more goto lable. But the error only happens in two places as well. So it may not worth the code jump.

>
> > +                                   }
> > +                                   bio->bi_sector =
> > +                                       isect - be->be_f_offset +
> > +                                       be->be_v_offset;
> > +                                   bio->bi_bdev = be->be_mdev;
> > +                                   bio->bi_end_io = bl_end_io_write_zero;
> > +                                   bio->bi_private = par;
> > +                           }
> > +                           if (bio_add_page(bio, page, PAGE_CACHE_SIZE, 0))
> > +                                   break;
> > +                           bio = bl_submit_bio(WRITE, bio);
>
> so if bio_add_page fails, you want to submit the current bio, allocate
> a new one and bio_add_page to the new one.  but if it fails the second time
> you absolutely don't want to submit the one you've just allocated but rather
> you want to pass the error on.
According to the comments of bio_add_page:
        The target block device must allow bio's up to PAGE_SIZE,
        so it is always possible to add a single page to an empty bio.
I think if we allocate a new bio and call bio_add_page, it will always succeed. Or am I misunderstanding it?

And the same allocate/submit looping forever exists in generic code as well. Please see do_mpage_readpage and __mpage_writepage for example.

>
> I think it'd be better to move the contents of this loop into a couple functions
> that will do the additive iteration. something along these lines:
Nice example. I will add these. Thank you very much!

>
> static struct bio *bl_alloc_init_bio(int npg, struct pnfs_block_extent *be, void
> (*end_io)(struct bio *, int err), struct parallel_io *par)
> {
>       struct bio *bio;
>
>       bio = bio_alloc(GFP_NOIO, npg);
>       if (!bio)
>               return NULL;
>
>       bio->bi_sector = isect - be->be_f_offset + be->be_v_offset;
>       bio->bi_bdev = be->be_mdev;
>       bio->bi_end_io = end_io;
>       bio->bi_private = par;
>       return bio;
> }
>
> static struct bio *bl_add_page_to_bio(struct bio *bio, int npg, struct page *page,
> struct pnfs_block_extent *be, void (*end_io)(struct bio *, int err), struct parallel_io
> *par)
> {
>       int retried = 0;
>
> retry:
>       if (!bio) {
>               bio = bl_alloc_init_bio(npg, be, end_io, par);
>               if (!bio)
>                       return PTR_ERR(-ENOMEM);
>       }
>       if (!bl_add_page(bio, page, PAGE_CACHE_SIZE, 0)) {
>               if (!retried++) {
>                       bl_submit_bio(bio);
>                       bio = NULL;
>                       goto retry;
>               }
>               bio_free(bio);
>               return ERR_PTR(-EIO);
>       }
>       return bio;
> }
>
> and the caller should decrement npg_zero or handle the error
> with respect to the page and wdata->pnfs_error.
>
> > +                   }
> > +                   /* FIXME: This should be done in bi_end_io */
> > +                   mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
> > +                                        page->index << PAGE_CACHE_SHIFT,
> > +                                        PAGE_CACHE_SIZE);
> > +                   isect += PAGE_CACHE_SIZE >> 9;
> > +                   extent_length -= PAGE_CACHE_SIZE >> 9;
>
> common iteration path, see comment above
>
> > +           }
> > +           if (last)
> > +                   goto write_done;
> > +   }
> > +   bio = bl_submit_bio(WRITE, bio);
> > +
> > +   /* Middle pages */
>
> this whole function is way too long.
> Is it possible to refactor out the different parts of it
> into their own static functions?
Will do it.

>
> > +   pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
> > +   for (i = pg_index; i < wdata->npages; i++) {
> >             if (!extent_length) {
> >                     /* We've used up the previous extent */
> >                     put_extent(be);
> > @@ -463,24 +672,32 @@ bl_write_pagelist(struct nfs_write_data *wdata,
> >                     be = find_get_extent(BLK_LSEG2EXT(wdata->lseg),
> >                                          isect, NULL);
> >                     if (!be || !is_writable(be, isect)) {
> > -                           /* FIXME */
> > -                           bl_done_with_wpage(pages[i], 0);
> > -                           break;
> > +                           wdata->pnfs_error = -EINVAL;
> > +                           goto out;
> >                     }
> >                     extent_length = be->be_length -
> > -                           (isect - be->be_f_offset);
> > +                       (isect - be->be_f_offset);
> > +           }
> > +           if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +                   ret = mark_initialized_sectors(be->be_inval, isect,
> > +                                                  PAGE_CACHE_SECTORS,
> > +                                                  NULL);
> > +                   if (unlikely(ret)) {
> > +                           dprintk("%s mark_initialized_sectors fail %d\n",
> > +                                   __func__, ret);
> > +                           wdata->pnfs_error = ret;
> > +                           goto out;
> > +                   }
> >             }
> >             for (;;) {
>
> ditto.
>
> can we use the same code structure as I suggested above
> also here and in bl_read_pagelist?
Yes, I will change it. Thanks.

>
> >                     if (!bio) {
> >                             bio = bio_alloc(GFP_NOIO, wdata->npages - i);
> >                             if (!bio) {
> > -                                   /* Error out this page */
> > -                                   /* FIXME */
> > -                                   bl_done_with_wpage(pages[i], 0);
> > -                                   break;
> > +                                   wdata->pnfs_error = -ENOMEM;
> > +                                   goto out;
> >                             }
> >                             bio->bi_sector = isect - be->be_f_offset +
> > -                                   be->be_v_offset;
> > +                               be->be_v_offset;
> >                             bio->bi_bdev = be->be_mdev;
> >                             bio->bi_end_io = bl_end_io_write;
> >                             bio->bi_private = par;
> > @@ -490,11 +707,27 @@ bl_write_pagelist(struct nfs_write_data *wdata,
> >                     bio = bl_submit_bio(WRITE, bio);
> >             }
> >             isect += PAGE_CACHE_SIZE >> 9;
> > +           last_isect = isect;
> >             extent_length -= PAGE_CACHE_SIZE >> 9;
> >     }
> > -   wdata->res.count = (isect << 9) - (offset);
> > -   if (count < wdata->res.count)
> > +
> > +   /* Last page inside INVALID extent */
> > +   if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > +           bio = bl_submit_bio(WRITE, bio);
> > +           npg_zero = npg_per_block -
> > +               (last_isect >> (PAGE_CACHE_SHIFT - 9)) % npg_per_block;
> > +           if (npg_zero < npg_per_block) {
> > +                   last = 1;
> > +                   goto fill_invalid_ext;
> > +           }
> > +   }
> > +
> > +write_done:
> > +   wdata->res.count = (last_isect << 9) - (offset);
> > +   if (count < wdata->res.count) {
> >             wdata->res.count = count;
> > +   }
> > +out:
> >     put_extent(be);
> >     bl_submit_bio(WRITE, bio);
> >     put_parallel(par);
> > @@ -521,8 +754,7 @@ release_extents(struct pnfs_block_layout *bl, struct
> pnfs_layout_range *range)
> >     spin_unlock(&bl->bl_ext_lock);
> >  }
> >
> > -static void
> > -release_inval_marks(struct pnfs_inval_markings *marks)
> > +static void release_inval_marks(struct pnfs_inval_markings *marks)
> >  {
> >     struct pnfs_inval_tracking *pos, *temp;
> >
> > @@ -615,7 +847,8 @@ bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
> >                     struct nfs4_layoutcommit_data *lcdata)
> >  {
> >     dprintk("%s enter\n", __func__);
> > -   clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args,
> lcdata->res.status);
> > +   clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args,
> > +                                 lcdata->res.status);
> >  }
> >
> >  static void free_blk_mountid(struct block_mount_id *mid)
> > @@ -625,8 +858,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
> >             spin_lock(&mid->bm_lock);
> >             while (!list_empty(&mid->bm_devlist)) {
> >                     dev = list_first_entry(&mid->bm_devlist,
> > -                                          struct pnfs_block_dev,
> > -                                          bm_node);
> > +                                          struct pnfs_block_dev, bm_node);
> >                     list_del(&dev->bm_node);
> >                     free_block_dev(dev);
> >             }
> > @@ -638,10 +870,11 @@ static void free_blk_mountid(struct block_mount_id
> *mid)
> >  /* This is mostly copied from the filelayout's get_device_info function.
> >   * It seems much of this should be at the generic pnfs level.
> >   */
> > -static struct pnfs_block_dev *
> > -nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
> > -                   struct nfs4_deviceid *d_id,
> > -                   struct list_head *sdlist)
> > +static struct pnfs_block_dev *nfs4_blk_get_deviceinfo(struct nfs_server *server,
> > +                                                 const struct nfs_fh *fh,
> > +                                                 struct nfs4_deviceid
> > +                                                 *d_id,
> > +                                                 struct list_head *sdlist)
> >  {
> >     struct pnfs_device *dev;
> >     struct pnfs_block_dev *rv = NULL;
> > @@ -695,7 +928,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const
> struct nfs_fh *fh,
> >             goto out_free;
> >
> >     rv = nfs4_blk_decode_device(server, dev, sdlist);
> > - out_free:
> > +out_free:
> >     if (dev->area != NULL)
> >             vunmap(dev->area);
> >     for (i = 0; i < max_pages; i++)
> > @@ -748,8 +981,8 @@ bl_set_layoutdriver(struct nfs_server *server, const struct
> nfs_fh *fh)
> >              */
> >             for (i = 0; i < dlist->num_devs; i++) {
> >                     bdev = nfs4_blk_get_deviceinfo(server, fh,
> > -                                                &dlist->dev_id[i],
> > -                                                &block_disklist);
> > +                                                  &dlist->dev_id[i],
> > +                                                  &block_disklist);
> >                     if (!bdev) {
> >                             status = -ENODEV;
> >                             goto out_error;
> > @@ -762,18 +995,17 @@ bl_set_layoutdriver(struct nfs_server *server, const
> struct nfs_fh *fh)
> >     dprintk("%s SUCCESS\n", __func__);
> >     server->pnfs_ld_data = b_mt_id;
> >
> > - out_return:
> > +out_return:
> >     kfree(dlist);
> >     return status;
> >
> > - out_error:
> > +out_error:
> >     free_blk_mountid(b_mt_id);
> >     kfree(mtype);
> >     goto out_return;
> >  }
> >
> > -static int
> > -bl_clear_layoutdriver(struct nfs_server *server)
> > +static int bl_clear_layoutdriver(struct nfs_server *server)
> >  {
> >     struct block_mount_id *b_mt_id = server->pnfs_ld_data;
> >
> > @@ -783,268 +1015,14 @@ bl_clear_layoutdriver(struct nfs_server *server)
> >     return 0;
> >  }
> >
> > -/* STUB - mark intersection of layout and page as bad, so is not
> > - * used again.
> > - */
> > -static void mark_bad_read(void)
> > -{
> > -   return;
> > -}
> > -
> > -/* Copied from buffer.c */
> > -static void __end_buffer_read_notouch(struct buffer_head *bh, int uptodate)
> > -{
> > -   if (uptodate) {
> > -           set_buffer_uptodate(bh);
> > -   } else {
> > -           /* This happens, due to failed READA attempts. */
> > -           clear_buffer_uptodate(bh);
> > -   }
> > -   unlock_buffer(bh);
> > -}
> > -
> > -/* Copied from buffer.c */
> > -static void end_buffer_read_nobh(struct buffer_head *bh, int uptodate)
> > -{
> > -   __end_buffer_read_notouch(bh, uptodate);
> > -}
> > -
> > -/*
> > - * map_block:  map a requested I/0 block (isect) into an offset in the LVM
> > - * meta block_device
> > - */
> > -static void
> > -map_block(sector_t isect, struct pnfs_block_extent *be, struct buffer_head *bh)
> > -{
> > -   dprintk("%s enter be=%p\n", __func__, be);
> > -
> > -   set_buffer_mapped(bh);
> > -   bh->b_bdev = be->be_mdev;
> > -   bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
> > -           (be->be_mdev->bd_inode->i_blkbits - 9);
> > -
> > -   dprintk("%s isect %ld, bh->b_blocknr %ld, using bsize %Zd\n",
> > -                           __func__, (long)isect,
> > -                           (long)bh->b_blocknr,
> > -                           bh->b_size);
> > -   return;
> > -}
> > -
> > -/* Given an unmapped page, zero it (or read in page for COW),
> > - * and set appropriate flags/markings, but it is safe to not initialize
> > - * the range given in [from, to).
> > - */
> > -/* This is loosely based on nobh_write_begin */
> > -static int
> > -init_page_for_write(struct pnfs_block_layout *bl, struct page *page,
> > -               unsigned from, unsigned to, sector_t **pages_to_mark)
> > -{
> > -   struct buffer_head *bh;
> > -   int inval, ret = -EIO;
> > -   struct pnfs_block_extent *be = NULL, *cow_read = NULL;
> > -   sector_t isect;
> > -
> > -   dprintk("%s enter, %p\n", __func__, page);
> > -   bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
> > -   if (!bh) {
> > -           ret = -ENOMEM;
> > -           goto cleanup;
> > -   }
> > -
> > -   isect = (sector_t)page->index << (PAGE_CACHE_SHIFT - 9);
> > -   be = find_get_extent(bl, isect, &cow_read);
> > -   if (!be)
> > -           goto cleanup;
> > -   inval = is_hole(be, isect);
> > -   dprintk("%s inval=%i, from=%u, to=%u\n", __func__, inval, from, to);
> > -   if (inval) {
> > -           if (be->be_state == PNFS_BLOCK_NONE_DATA) {
> > -                   dprintk("%s PANIC - got NONE_DATA extent %p\n",
> > -                           __func__, be);
> > -                   goto cleanup;
> > -           }
> > -           map_block(isect, be, bh);
> > -           unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
> > -   }
> > -   if (PageUptodate(page)) {
> > -           /* Do nothing */
> > -   } else if (inval & !cow_read) {
> > -           zero_user_segments(page, 0, from, to, PAGE_CACHE_SIZE);
> > -   } else if (0 < from || PAGE_CACHE_SIZE > to) {
> > -           struct pnfs_block_extent *read_extent;
> > -
> > -           read_extent = (inval && cow_read) ? cow_read : be;
> > -           map_block(isect, read_extent, bh);
> > -           lock_buffer(bh);
> > -           bh->b_end_io = end_buffer_read_nobh;
> > -           submit_bh(READ, bh);
> > -           dprintk("%s: Waiting for buffer read\n", __func__);
> > -           /* XXX Don't really want to hold layout lock here */
> > -           wait_on_buffer(bh);
> > -           if (!buffer_uptodate(bh))
> > -                   goto cleanup;
> > -   }
> > -   if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> > -           /* There is a BUG here if is a short copy after write_begin,
> > -            * but I think this is a generic fs bug.  The problem is that
> > -            * we have marked the page as initialized, but it is possible
> > -            * that the section not copied may never get copied.
> > -            */
> > -           ret = mark_initialized_sectors(be->be_inval, isect,
> > -                                          PAGE_CACHE_SECTORS,
> > -                                          pages_to_mark);
> > -           /* Want to preallocate mem so above can't fail */
> > -           if (ret)
> > -                   goto cleanup;
> > -   }
> > -   SetPageMappedToDisk(page);
> > -   ret = 0;
> > -
> > -cleanup:
> > -   free_buffer_head(bh);
> > -   put_extent(be);
> > -   put_extent(cow_read);
> > -   if (ret) {
> > -           /* Need to mark layout with bad read...should now
> > -            * just use nfs4 for reads and writes.
> > -            */
> > -           mark_bad_read();
> > -   }
> > -   return ret;
> > -}
> > -
> > -static int
> > -bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
> > -          unsigned count, struct pnfs_fsdata *fsdata)
> > -{
> > -   unsigned from, to;
> > -   int ret;
> > -   sector_t *pages_to_mark = NULL;
> > -   struct pnfs_block_layout *bl = BLK_LSEG2EXT(lseg);
> > -
> > -   dprintk("%s enter, %u@%lld\n", __func__, count, pos);
> > -   print_page(page);
> > -   /* The following code assumes blocksize >= PAGE_CACHE_SIZE */
> > -   if (bl->bl_blocksize < (PAGE_CACHE_SIZE >> 9)) {
> > -           dprintk("%s Can't handle blocksize %llu\n", __func__,
> > -                   (u64)bl->bl_blocksize);
> > -           put_lseg(fsdata->lseg);
> > -           fsdata->lseg = NULL;
> > -           return 0;
> > -   }
> > -   if (PageMappedToDisk(page)) {
> > -           /* Basically, this is a flag that says we have
> > -            * successfully called write_begin already on this page.
> > -            */
> > -           /* NOTE - there are cache consistency issues here.
> > -            * For example, what if the layout is recalled, then regained?
> > -            * If the file is closed and reopened, will the page flags
> > -            * be reset?  If not, we'll have to use layout info instead of
> > -            * the page flag.
> > -            */
> > -           return 0;
> > -   }
> > -   from = pos & (PAGE_CACHE_SIZE - 1);
> > -   to = from + count;
> > -   ret = init_page_for_write(bl, page, from, to, &pages_to_mark);
> > -   if (ret) {
> > -           dprintk("%s init page failed with %i", __func__, ret);
> > -           /* Revert back to plain NFS and just continue on with
> > -            * write.  This assumes there is no request attached, which
> > -            * should be true if we get here.
> > -            */
> > -           BUG_ON(PagePrivate(page));
> > -           put_lseg(fsdata->lseg);
> > -           fsdata->lseg = NULL;
> > -           kfree(pages_to_mark);
> > -           ret = 0;
> > -   } else {
> > -           fsdata->private = pages_to_mark;
> > -   }
> > -   return ret;
> > -}
> > -
> > -/* CAREFUL - what happens if copied < count??? */
> > -static int
> > -bl_write_end(struct inode *inode, struct page *page, loff_t pos,
> > -        unsigned count, unsigned copied, struct pnfs_layout_segment *lseg)
> > -{
> > -   dprintk("%s enter, %u@%lld, lseg=%p\n", __func__, count, pos, lseg);
> > -   print_page(page);
> > -   if (lseg)
> > -           SetPageUptodate(page);
> > -   return 0;
> > -}
> > -
> > -/* Return any memory allocated to fsdata->private, and take advantage
> > - * of no page locks to mark pages noted in write_begin as needing
> > - * initialization.
> > - */
> > -static void
> > -bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
> > -{
> > -   struct page *page;
> > -   pgoff_t index;
> > -   sector_t *pos;
> > -   struct address_space *mapping = filp->f_mapping;
> > -   struct pnfs_fsdata *fake_data;
> > -   struct pnfs_layout_segment *lseg;
> > -
> > -   if (!fsdata)
> > -           return;
> > -   lseg = fsdata->lseg;
> > -   if (!lseg)
> > -           return;
> > -   pos = fsdata->private;
> > -   if (!pos)
> > -           return;
> > -   dprintk("%s enter with pos=%llu\n", __func__, (u64)(*pos));
> > -   for (; *pos != ~0; pos++) {
> > -           index = *pos >> (PAGE_CACHE_SHIFT - 9);
> > -           /* XXX How do we properly deal with failures here??? */
> > -           page = grab_cache_page_write_begin(mapping, index, 0);
> > -           if (!page) {
> > -                   printk(KERN_ERR "%s BUG BUG BUG NoMem\n", __func__);
> > -                   continue;
> > -           }
> > -           dprintk("%s: Examining block page\n", __func__);
> > -           print_page(page);
> > -           if (!PageMappedToDisk(page)) {
> > -                   /* XXX How do we properly deal with failures here??? */
> > -                   dprintk("%s Marking block page\n", __func__);
> > -                   init_page_for_write(BLK_LSEG2EXT(fsdata->lseg), page,
> > -                                       PAGE_CACHE_SIZE, PAGE_CACHE_SIZE,
> > -                                       NULL);
> > -                   print_page(page);
> > -                   fake_data = kzalloc(sizeof(*fake_data), GFP_KERNEL);
> > -                   if (!fake_data) {
> > -                           printk(KERN_ERR "%s BUG BUG BUG NoMem\n",
> > -                                  __func__);
> > -                           unlock_page(page);
> > -                           continue;
> > -                   }
> > -                   get_lseg(lseg);
> > -                   fake_data->lseg = lseg;
> > -                   fake_data->bypass_eof = 1;
> > -                   mapping->a_ops->write_end(filp, mapping,
> > -                                             index << PAGE_CACHE_SHIFT,
> > -                                             PAGE_CACHE_SIZE,
> > -                                             PAGE_CACHE_SIZE,
> > -                                             page, fake_data);
> > -                   /* Note fake_data is freed by nfs_write_end */
> > -           } else
> > -                   unlock_page(page);
> > -   }
> > -   kfree(fsdata->private);
> > -   fsdata->private = NULL;
> > -}
> > -
> >  static const struct nfs_pageio_ops bl_pg_read_ops = {
> > +   .pg_init = pnfs_generic_pg_init_read,
> >     .pg_test = pnfs_generic_pg_test,
> >     .pg_doio = nfs_generic_pg_readpages,
> >  };
> >
> >  static const struct nfs_pageio_ops bl_pg_write_ops = {
> > +   .pg_init = pnfs_generic_pg_init_write,
> >     .pg_test = pnfs_generic_pg_test,
> >     .pg_doio = nfs_generic_pg_writepages,
> >  };
> > @@ -1054,9 +1032,6 @@ static struct pnfs_layoutdriver_type blocklayout_type =
> {
> >     .name = "LAYOUT_BLOCK_VOLUME",
> >     .read_pagelist                  = bl_read_pagelist,
> >     .write_pagelist                 = bl_write_pagelist,
> > -   .write_begin                    = bl_write_begin,
> > -   .write_end                      = bl_write_end,
> > -   .write_end_cleanup              = bl_write_end_cleanup,
> >     .alloc_layout_hdr               = bl_alloc_layout_hdr,
> >     .free_layout_hdr                = bl_free_layout_hdr,
> >     .alloc_lseg                     = bl_alloc_lseg,
> > @@ -1083,8 +1058,7 @@ static int __init nfs4blocklayout_init(void)
> >
> >  static void __exit nfs4blocklayout_exit(void)
> >  {
> > -   dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
> > -          __func__);
> > +   dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n", __func__);
> >
> >     pnfs_unregister_layoutdriver(&blocklayout_type);
> >     bl_pipe_exit();
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 1768762..2f093ed 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -384,15 +384,12 @@ static int nfs_write_begin(struct file *file, struct
> address_space *mapping,
> >     pgoff_t index = pos >> PAGE_CACHE_SHIFT;
> >     struct page *page;
> >     int once_thru = 0;
> > -   struct pnfs_layout_segment *lseg;
> >
> >     dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
> >             file->f_path.dentry->d_parent->d_name.name,
> >             file->f_path.dentry->d_name.name,
> >             mapping->host->i_ino, len, (long long) pos);
> > -   lseg = pnfs_update_layout(mapping->host,
> > -                             nfs_file_open_context(file),
> > -                             pos, len, IOMODE_RW, GFP_NOFS);
> > +
> >  start:
> >     /*
> >      * Prevent starvation issues if someone is doing a consistency
> > @@ -412,9 +409,6 @@ start:
> >     if (ret) {
> >             unlock_page(page);
> >             page_cache_release(page);
> > -           *pagep = NULL;
> > -           *fsdata = NULL;
> > -           goto out;
> >     } else if (!once_thru &&
> >                nfs_want_read_modify_write(file, page, pos, len)) {
> >             once_thru = 1;
> > @@ -423,12 +417,6 @@ start:
> >             if (!ret)
> >                     goto start;
> >     }
> > -   ret = pnfs_write_begin(file, page, pos, len, lseg, fsdata);
> > - out:
> > -   if (ret) {
> > -           put_lseg(lseg);
> > -           *fsdata = NULL;
> > -   }
> >     return ret;
> >  }
> >
> > @@ -438,7 +426,6 @@ static int nfs_write_end(struct file *file, struct
> address_space *mapping,
> >  {
> >     unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
> >     int status;
> > -   struct pnfs_layout_segment *lseg;
> >
> >     dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
> >             file->f_path.dentry->d_parent->d_name.name,
> > @@ -465,17 +452,10 @@ static int nfs_write_end(struct file *file, struct
> address_space *mapping,
> >                     zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
> >     }
> >
> > -   lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
> > -   status = pnfs_write_end(file, page, pos, len, copied, lseg);
> > -   if (status)
> > -           goto out;
> > -   status = nfs_updatepage(file, page, offset, copied, lseg, fsdata);
> > +   status = nfs_updatepage(file, page, offset, copied);
> >
> > -out:
> >     unlock_page(page);
> >     page_cache_release(page);
> > -   pnfs_write_end_cleanup(file, fsdata);
> > -   put_lseg(lseg);
> >
> >     if (status < 0)
> >             return status;
> > @@ -597,7 +577,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct
> *vma, struct vm_fault *vmf)
> >
> >     ret = VM_FAULT_LOCKED;
> >     if (nfs_flush_incompatible(filp, page) == 0 &&
> > -       nfs_updatepage(filp, page, 0, pagelen, NULL, NULL) == 0)
> > +       nfs_updatepage(filp, page, 0, pagelen) == 0)
> >             goto out;
> >
> >     ret = VM_FAULT_SIGBUS;
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 42979e5..1fdc8f7 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -1223,41 +1223,6 @@ pnfs_try_to_write_data(struct nfs_write_data
> *wdata,
> >  }
> >
> >  /*
> > - * This gives the layout driver an opportunity to read in page "around"
> > - * the data to be written.  It returns 0 on success, otherwise an error code
> > - * which will either be passed up to user, or ignored if
> > - * some previous part of write succeeded.
> > - * Note the range [pos, pos+len-1] is entirely within the page.
> > - */
> > -int _pnfs_write_begin(struct inode *inode, struct page *page,
> > -                 loff_t pos, unsigned len,
> > -                 struct pnfs_layout_segment *lseg,
> > -                 struct pnfs_fsdata **fsdata)
> > -{
> > -   struct pnfs_fsdata *data;
> > -   int status = 0;
> > -
> > -   dprintk("--> %s: pos=%llu len=%u\n",
> > -           __func__, (unsigned long long)pos, len);
> > -   data = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
> > -   if (!data) {
> > -           status = -ENOMEM;
> > -           goto out;
> > -   }
> > -   data->lseg = lseg; /* refcount passed into data to be managed there */
> > -   status = NFS_SERVER(inode)->pnfs_curr_ld->write_begin(
> > -                                           lseg, page, pos, len, data);
> > -   if (status) {
> > -           kfree(data);
> > -           data = NULL;
> > -   }
> > -out:
> > -   *fsdata = data;
> > -   dprintk("<-- %s: status=%d\n", __func__, status);
> > -   return status;
> > -}
> > -
> > -/*
> >   * Called by non rpc-based layout drivers
> >   */
> >  int
> > @@ -1373,12 +1338,6 @@ void pnfs_cleanup_layoutcommit(struct inode *inode,
> >                                                      data);
> >  }
> >
> > -void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
> > -{
> > -   /* lseg refcounting handled directly in nfs_write_end */
> > -   kfree(fsdata);
> > -}
> > -
> >  /*
> >   * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
> >   * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
> > diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> > index 6f7fa9f..a0c856c 100644
> > --- a/fs/nfs/pnfs.h
> > +++ b/fs/nfs/pnfs.h
> > @@ -54,12 +54,6 @@ enum pnfs_try_status {
> >     PNFS_NOT_ATTEMPTED = 1,
> >  };
> >
> > -struct pnfs_fsdata {
> > -   struct pnfs_layout_segment *lseg;
> > -   int bypass_eof;
> > -   void *private;
> > -};
> > -
> >  #ifdef CONFIG_NFS_V4_1
> >
> >  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
> > @@ -113,14 +107,6 @@ struct pnfs_layoutdriver_type {
> >      */
> >     enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
> >     enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int
> how);
> > -   int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
> > -                       loff_t pos, unsigned count,
> > -                       struct pnfs_fsdata *fsdata);
> > -   int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
> > -                    unsigned count, unsigned copied,
> > -                    struct pnfs_layout_segment *lseg);
> > -   void (*write_end_cleanup)(struct file *filp,
> > -                             struct pnfs_fsdata *fsdata);
> >
> >     void (*free_deviceid_node) (struct nfs4_deviceid_node *);
> >
> > @@ -196,7 +182,6 @@ enum pnfs_try_status pnfs_try_to_read_data(struct
> nfs_read_data *,
> >  void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page
> *);
> >  void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page
> *);
> >  bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page
> *prev, struct nfs_page *req);
> > -void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
> >  int pnfs_layout_process(struct nfs4_layoutget *lgp);
> >  void pnfs_free_lseg_list(struct list_head *tmp_list);
> >  void pnfs_destroy_layout(struct nfs_inode *);
> > @@ -208,10 +193,6 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
> >  int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
> >                               struct pnfs_layout_hdr *lo,
> >                               struct nfs4_state *open_state);
> > -int _pnfs_write_begin(struct inode *inode, struct page *page,
> > -                 loff_t pos, unsigned len,
> > -                 struct pnfs_layout_segment *lseg,
> > -                 struct pnfs_fsdata **fsdata);
> >  int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
> >                             struct list_head *tmp_list,
> >                             struct pnfs_layout_range *recall_range);
> > @@ -329,13 +310,6 @@ static inline void pnfs_clear_request_commit(struct
> nfs_page *req)
> >             put_lseg(req->wb_commit_lseg);
> >  }
> >
> > -static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
> > -                          struct pnfs_fsdata *fsdata)
> > -{
> > -   return !fsdata  || ((struct pnfs_layout_segment *)fsdata == lseg) ||
> > -           !fsdata->bypass_eof;
> > -}
> > -
> >  /* Should the pNFS client commit and return the layout upon a setattr */
> >  static inline bool
> >  pnfs_ld_layoutret_on_setattr(struct inode *inode)
> > @@ -346,49 +320,6 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
> >             PNFS_LAYOUTRET_ON_SETATTR;
> >  }
> >
> > -static inline int pnfs_write_begin(struct file *filp, struct page *page,
> > -                              loff_t pos, unsigned len,
> > -                              struct pnfs_layout_segment *lseg,
> > -                              void **fsdata)
> > -{
> > -   struct inode *inode = filp->f_dentry->d_inode;
> > -   struct nfs_server *nfss = NFS_SERVER(inode);
> > -   int status = 0;
> > -
> > -   *fsdata = lseg;
> > -   if (lseg && nfss->pnfs_curr_ld->write_begin)
> > -           status = _pnfs_write_begin(inode, page, pos, len, lseg,
> > -                                      (struct pnfs_fsdata **) fsdata);
> > -   return status;
> > -}
> > -
> > -/* CAREFUL - what happens if copied < len??? */
> > -static inline int pnfs_write_end(struct file *filp, struct page *page,
> > -                            loff_t pos, unsigned len, unsigned copied,
> > -                            struct pnfs_layout_segment *lseg)
> > -{
> > -   struct inode *inode = filp->f_dentry->d_inode;
> > -   struct nfs_server *nfss = NFS_SERVER(inode);
> > -
> > -   if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_end)
> > -           return nfss->pnfs_curr_ld->write_end(inode, page, pos, len,
> > -                                                copied, lseg);
> > -   else
> > -           return 0;
> > -}
> > -
> > -static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
> > -{
> > -   struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
> > -
> > -   if (fsdata && nfss->pnfs_curr_ld) {
> > -           if (nfss->pnfs_curr_ld->write_end_cleanup)
> > -                   nfss->pnfs_curr_ld->write_end_cleanup(filp, fsdata);
> > -           if (nfss->pnfs_curr_ld->write_begin)
> > -                   pnfs_free_fsdata(fsdata);
> > -   }
> > -}
> > -
> >  static inline int pnfs_return_layout(struct inode *ino)
> >  {
> >     struct nfs_inode *nfsi = NFS_I(ino);
> > @@ -400,19 +331,6 @@ static inline int pnfs_return_layout(struct inode *ino)
> >     return 0;
> >  }
> >
> > -static inline struct pnfs_layout_segment *
> > -nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
> > -{
> > -   if (fsdata) {
> > -           struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
> > -
> > -           if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_begin)
> > -                   return ((struct pnfs_fsdata *) fsdata)->lseg;
> > -           return (struct pnfs_layout_segment *)fsdata;
> > -   }
> > -   return NULL;
> > -}
> > -
> >  #else  /* CONFIG_NFS_V4_1 */
> >
> >  static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> > @@ -433,12 +351,6 @@ static inline void put_lseg(struct pnfs_layout_segment
> *lseg)
> >  {
> >  }
> >
> > -static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
> > -                          struct pnfs_fsdata *fsdata)
> > -{
> > -   return 1;
> > -}
> > -
> >  static inline enum pnfs_try_status
> >  pnfs_try_to_read_data(struct nfs_read_data *data,
> >                   const struct rpc_call_ops *call_ops)
> > @@ -458,26 +370,6 @@ static inline int pnfs_return_layout(struct inode *ino)
> >     return 0;
> >  }
> >
> > -static inline int pnfs_write_begin(struct file *filp, struct page *page,
> > -                              loff_t pos, unsigned len,
> > -                              struct pnfs_layout_segment *lseg,
> > -                              void **fsdata)
> > -{
> > -   *fsdata = NULL;
> > -   return 0;
> > -}
> > -
> > -static inline int pnfs_write_end(struct file *filp, struct page *page,
> > -                            loff_t pos, unsigned len, unsigned copied,
> > -                            struct pnfs_layout_segment *lseg)
> > -{
> > -   return 0;
> > -}
> > -
> > -static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
> > -{
> > -}
> > -
> >  static inline bool
> >  pnfs_ld_layoutret_on_setattr(struct inode *inode)
> >  {
> > @@ -554,13 +446,6 @@ static inline int pnfs_layoutcommit_inode(struct inode
> *inode, bool sync)
> >  static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
> >  {
> >  }
> > -
> > -static inline struct pnfs_layout_segment *
> > -nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
> > -{
> > -   return NULL;
> > -}
> > -
> >  #endif /* CONFIG_NFS_V4_1 */
> >
> >  #endif /* FS_NFS_PNFS_H */
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 1185262..574ec0e 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -673,9 +673,7 @@ out:
> >  }
> >
> >  static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
> > -           unsigned int offset, unsigned int count,
> > -           struct pnfs_layout_segment *lseg, void *fsdata)
> > -
> > +           unsigned int offset, unsigned int count)
> >  {
> >     struct nfs_page *req;
> >
> > @@ -683,8 +681,7 @@ static int nfs_writepage_setup(struct nfs_open_context
> *ctx, struct page *page,
> >     if (IS_ERR(req))
> >             return PTR_ERR(req);
> >     /* Update file length */
> > -   if (pnfs_grow_ok(lseg, fsdata))
> > -           nfs_grow_file(page, offset, count);
> > +   nfs_grow_file(page, offset, count);
> >     nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
> >     nfs_mark_request_dirty(req);
> >     nfs_clear_page_tag_locked(req);
> > @@ -737,8 +734,7 @@ static int nfs_write_pageuptodate(struct page *page,
> struct inode *inode)
> >   * things with a page scheduled for an RPC call (e.g. invalidate it).
> >   */
> >  int nfs_updatepage(struct file *file, struct page *page,
> > -           unsigned int offset, unsigned int count,
> > -           struct pnfs_layout_segment *lseg, void *fsdata)
> > +           unsigned int offset, unsigned int count)
> >  {
> >     struct nfs_open_context *ctx = nfs_file_open_context(file);
> >     struct inode    *inode = page->mapping->host;
> > @@ -763,7 +759,7 @@ int nfs_updatepage(struct file *file, struct page *page,
> >             offset = 0;
> >     }
> >
> > -   status = nfs_writepage_setup(ctx, page, offset, count, lseg, fsdata);
> > +   status = nfs_writepage_setup(ctx, page, offset, count);
> >     if (status < 0)
> >             nfs_set_pageerror(page);
> >
> > diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> > index e459379..fcc7f41 100644
> > --- a/include/linux/nfs_fs.h
> > +++ b/include/linux/nfs_fs.h
> > @@ -510,8 +510,7 @@ extern int  nfs_congestion_kb;
> >  extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
> >  extern int  nfs_writepages(struct address_space *, struct writeback_control *);
> >  extern int  nfs_flush_incompatible(struct file *file, struct page *page);
> > -extern int nfs_updatepage(struct file *, struct page *, unsigned int,
> > -                     unsigned int, struct pnfs_layout_segment *, void *);
> > +extern int nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
> >  extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
> >
> >  /*

