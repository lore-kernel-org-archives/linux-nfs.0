Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:49513 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932716AbaHYOgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 10:36:13 -0400
Message-ID: <53FB49D9.1060803@Netapp.com>
Date: Mon, 25 Aug 2014 10:36:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 16/19] pnfs/blocklayout: rewrite extent tracking
References: <pnfs block layout driver fixes V2> <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-17-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-17-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/21/2014 12:09 PM, Christoph Hellwig wrote:
> Currently the block layout driver tracks extents in three separate
> data structures:
>
>  - the two list of pnfs_block_extent structures returned by the server
>  - the list of sectors that were in invalid state but have been written to
>  - a list of pnfs_block_short_extent structures for LAYOUTCOMMIT
>
> All of these share the property that they are not only highly inefficient
> data structures, but also that operations on them are even more inefficient
> than nessecary.
>
> In addition there are various implementation defects like:
>
>  - using an int to track sectors, causing corruption for large offsets
>  - incorrect normalization of page or block granularity ranges
>  - insufficient error handling
>  - incorrect synchronization as extents can be modified while they are in
>    use
>
> This patch replace all three data with a single unified rbtree structure
> tracking all extents, as well as their in-memory state, although we still
> need to instance for read-only and read-write extent due to the arcane
> client side COW feature in the block layouts spec.
>
> To fix the problem of extent possibly being modified while in use we make
> sure to return a copy of the extent for use in the write path - the
> extent can only be invalidated by a layout recall or return which has
> to wait until the I/O operations finished due to refcounts on the layout
> segment.
>
> The new extent tree work similar to the schemes used by block based
> filesystems like XFS or ext4.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/Makefile         |   3 +-
>  fs/nfs/blocklayout/blocklayout.c    | 258 +++-------
>  fs/nfs/blocklayout/blocklayout.h    | 112 +----
>  fs/nfs/blocklayout/blocklayoutdev.c |  35 +-
>  fs/nfs/blocklayout/extent_tree.c    | 545 ++++++++++++++++++++++
>  fs/nfs/blocklayout/extents.c        | 908 ------------------------------------
>  6 files changed, 649 insertions(+), 1212 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/extent_tree.c
>  delete mode 100644 fs/nfs/blocklayout/extents.c
Whoa, I like the amount of code you manage to remove in this patch!  However, there is a lot going on here.  Any way this patch could be split into incremental changes?  (it's okay to say "no"!)

Anna
>
> diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
> index d581550..3fa5ec7 100644
> --- a/fs/nfs/blocklayout/Makefile
> +++ b/fs/nfs/blocklayout/Makefile
> @@ -2,4 +2,5 @@
>  # Makefile for the pNFS block layout driver kernel module
>  #
>  obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
> -blocklayoutdriver-objs := blocklayout.o extents.o blocklayoutdev.o blocklayoutdm.o
> +blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o blocklayoutdm.o \
> +	extent_tree.o
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 92be984..42b6f9c 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -49,26 +49,16 @@ MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
>  MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
>  
> -/* Given the be associated with isect, determine if page data needs to be
> - * initialized.
> - */
> -static int is_hole(struct pnfs_block_extent *be, sector_t isect)
> -{
> -	if (be->be_state == PNFS_BLOCK_NONE_DATA)
> -		return 1;
> -	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
> -		return 0;
> -	else
> -		return !bl_is_sector_init(be->be_inval, isect);
> -}
> -
> -/* Given the be associated with isect, determine if page data can be
> - * written to disk.
> - */
> -static int is_writable(struct pnfs_block_extent *be, sector_t isect)
> +static bool is_hole(struct pnfs_block_extent *be)
>  {
> -	return (be->be_state == PNFS_BLOCK_READWRITE_DATA ||
> -		be->be_state == PNFS_BLOCK_INVALID_DATA);
> +	switch (be->be_state) {
> +	case PNFS_BLOCK_NONE_DATA:
> +		return true;
> +	case PNFS_BLOCK_INVALID_DATA:
> +		return be->be_tag ? false : true;
> +	default:
> +		return false;
> +	}
>  }
>  
>  /* The data we are handed might be spread across several bios.  We need
> @@ -76,9 +66,8 @@ static int is_writable(struct pnfs_block_extent *be, sector_t isect)
>   */
>  struct parallel_io {
>  	struct kref refcnt;
> -	void (*pnfs_callback) (void *data, int num_se);
> +	void (*pnfs_callback) (void *data);
>  	void *data;
> -	int bse_count;
>  };
>  
>  static inline struct parallel_io *alloc_parallel(void *data)
> @@ -89,7 +78,6 @@ static inline struct parallel_io *alloc_parallel(void *data)
>  	if (rv) {
>  		rv->data = data;
>  		kref_init(&rv->refcnt);
> -		rv->bse_count = 0;
>  	}
>  	return rv;
>  }
> @@ -104,7 +92,7 @@ static void destroy_parallel(struct kref *kref)
>  	struct parallel_io *p = container_of(kref, struct parallel_io, refcnt);
>  
>  	dprintk("%s enter\n", __func__);
> -	p->pnfs_callback(p->data, p->bse_count);
> +	p->pnfs_callback(p->data);
>  	kfree(p);
>  }
>  
> @@ -200,7 +188,7 @@ static void bl_read_cleanup(struct work_struct *work)
>  }
>  
>  static void
> -bl_end_par_io_read(void *data, int unused)
> +bl_end_par_io_read(void *data)
>  {
>  	struct nfs_pgio_header *hdr = data;
>  
> @@ -210,56 +198,46 @@ bl_end_par_io_read(void *data, int unused)
>  }
>  
>  static enum pnfs_try_status
> -bl_read_pagelist(struct nfs_pgio_header *hdr)
> +bl_read_pagelist(struct nfs_pgio_header *header)
>  {
> -	struct nfs_pgio_header *header = hdr;
> -	int i, hole;
> +	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
>  	struct bio *bio = NULL;
> -	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
> +	struct pnfs_block_extent be;
>  	sector_t isect, extent_length = 0;
>  	struct parallel_io *par;
> -	loff_t f_offset = hdr->args.offset;
> -	size_t bytes_left = hdr->args.count;
> +	loff_t f_offset = header->args.offset;
> +	size_t bytes_left = header->args.count;
>  	unsigned int pg_offset, pg_len;
> -	struct page **pages = hdr->args.pages;
> -	int pg_index = hdr->args.pgbase >> PAGE_CACHE_SHIFT;
> +	struct page **pages = header->args.pages;
> +	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
>  	const bool is_dio = (header->dreq != NULL);
>  	struct blk_plug plug;
> +	int i;
>  
>  	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
> -		hdr->page_array.npages, f_offset,
> -		(unsigned int)hdr->args.count);
> +		header->page_array.npages, f_offset,
> +		(unsigned int)header->args.count);
>  
> -	par = alloc_parallel(hdr);
> +	par = alloc_parallel(header);
>  	if (!par)
> -		goto use_mds;
> +		return PNFS_NOT_ATTEMPTED;
>  	par->pnfs_callback = bl_end_par_io_read;
> -	/* At this point, we can no longer jump to use_mds */
>  
>  	blk_start_plug(&plug);
>  
>  	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
>  	/* Code assumes extents are page-aligned */
> -	for (i = pg_index; i < hdr->page_array.npages; i++) {
> +	for (i = pg_index; i < header->page_array.npages; i++) {
>  		if (extent_length <= 0) {
>  			/* We've used up the previous extent */
> -			bl_put_extent(be);
> -			bl_put_extent(cow_read);
>  			bio = bl_submit_bio(READ, bio);
> +
>  			/* Get the next one */
> -			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
> -					     isect, &cow_read);
> -			if (!be) {
> +			if (!ext_tree_lookup(bl, isect, &be, false)) {
>  				header->pnfs_error = -EIO;
>  				goto out;
>  			}
> -			extent_length = be->be_length -
> -				(isect - be->be_f_offset);
> -			if (cow_read) {
> -				sector_t cow_length = cow_read->be_length -
> -					(isect - cow_read->be_f_offset);
> -				extent_length = min(extent_length, cow_length);
> -			}
> +			extent_length = be.be_length - (isect - be.be_f_offset);
>  		}
>  
>  		pg_offset = f_offset & ~PAGE_CACHE_MASK;
> @@ -278,20 +256,16 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>  			pg_len = PAGE_CACHE_SIZE;
>  		}
>  
> -		hole = is_hole(be, isect);
> -		if (hole && !cow_read) {
> +		if (is_hole(&be)) {
>  			bio = bl_submit_bio(READ, bio);
>  			/* Fill hole w/ zeroes w/o accessing device */
>  			dprintk("%s Zeroing page for hole\n", __func__);
>  			zero_user_segment(pages[i], pg_offset, pg_len);
>  		} else {
> -			struct pnfs_block_extent *be_read;
> -
> -			be_read = (hole && cow_read) ? cow_read : be;
>  			bio = do_add_page_to_bio(bio,
> -						 hdr->page_array.npages - i,
> +						 header->page_array.npages - i,
>  						 READ,
> -						 isect, pages[i], be_read,
> +						 isect, pages[i], &be,
>  						 bl_end_io_read, par,
>  						 pg_offset, pg_len);
>  			if (IS_ERR(bio)) {
> @@ -304,50 +278,16 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>  		extent_length -= (pg_len >> SECTOR_SHIFT);
>  	}
>  	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
> -		hdr->res.eof = 1;
> -		hdr->res.count = header->inode->i_size - hdr->args.offset;
> +		header->res.eof = 1;
> +		header->res.count = header->inode->i_size - header->args.offset;
>  	} else {
> -		hdr->res.count = (isect << SECTOR_SHIFT) - hdr->args.offset;
> +		header->res.count = (isect << SECTOR_SHIFT) - header->args.offset;
>  	}
>  out:
> -	bl_put_extent(be);
> -	bl_put_extent(cow_read);
>  	bl_submit_bio(READ, bio);
>  	blk_finish_plug(&plug);
>  	put_parallel(par);
>  	return PNFS_ATTEMPTED;
> -
> - use_mds:
> -	dprintk("Giving up and using normal NFS\n");
> -	return PNFS_NOT_ATTEMPTED;
> -}
> -
> -static void mark_extents_written(struct pnfs_block_layout *bl,
> -				 __u64 offset, __u32 count)
> -{
> -	sector_t isect, end;
> -	struct pnfs_block_extent *be;
> -	struct pnfs_block_short_extent *se;
> -
> -	dprintk("%s(%llu, %u)\n", __func__, offset, count);
> -	if (count == 0)
> -		return;
> -	isect = (offset & (long)(PAGE_CACHE_MASK)) >> SECTOR_SHIFT;
> -	end = (offset + count + PAGE_CACHE_SIZE - 1) & (long)(PAGE_CACHE_MASK);
> -	end >>= SECTOR_SHIFT;
> -	while (isect < end) {
> -		sector_t len;
> -		be = bl_find_get_extent(bl, isect, NULL);
> -		BUG_ON(!be); /* FIXME */
> -		len = min(end, be->be_f_offset + be->be_length) - isect;
> -		if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> -			se = bl_pop_one_short_extent(be->be_inval);
> -			BUG_ON(!se);
> -			bl_mark_for_commit(be, isect, len, se);
> -		}
> -		isect += len;
> -		bl_put_extent(be);
> -	}
>  }
>  
>  static void bl_end_io_write(struct bio *bio, int err)
> @@ -370,29 +310,30 @@ static void bl_end_io_write(struct bio *bio, int err)
>   */
>  static void bl_write_cleanup(struct work_struct *work)
>  {
> -	struct rpc_task *task;
> -	struct nfs_pgio_header *hdr;
> +	struct rpc_task *task = container_of(work, struct rpc_task, u.tk_work);
> +	struct nfs_pgio_header *hdr =
> +			container_of(task, struct nfs_pgio_header, task);
> +
>  	dprintk("%s enter\n", __func__);
> -	task = container_of(work, struct rpc_task, u.tk_work);
> -	hdr = container_of(task, struct nfs_pgio_header, task);
> +
>  	if (likely(!hdr->pnfs_error)) {
> -		/* Marks for LAYOUTCOMMIT */
> -		mark_extents_written(BLK_LSEG2EXT(hdr->lseg),
> -				     hdr->args.offset, hdr->args.count);
> +		struct pnfs_block_layout *bl = BLK_LSEG2EXT(hdr->lseg);
> +		u64 start = hdr->args.offset & (loff_t)PAGE_CACHE_MASK;
> +		u64 end = (hdr->args.offset + hdr->args.count +
> +			PAGE_CACHE_SIZE - 1) & (loff_t)PAGE_CACHE_MASK;
> +
> +		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
> +					(end - start) >> SECTOR_SHIFT);
>  	}
> +
>  	pnfs_ld_write_done(hdr);
>  }
>  
>  /* Called when last of bios associated with a bl_write_pagelist call finishes */
> -static void bl_end_par_io_write(void *data, int num_se)
> +static void bl_end_par_io_write(void *data)
>  {
>  	struct nfs_pgio_header *hdr = data;
>  
> -	if (unlikely(hdr->pnfs_error)) {
> -		bl_free_short_extents(&BLK_LSEG2EXT(hdr->lseg)->bl_inval,
> -					num_se);
> -	}
> -
>  	hdr->task.tk_status = hdr->pnfs_error;
>  	hdr->verf.committed = NFS_FILE_SYNC;
>  	INIT_WORK(&hdr->task.u.tk_work, bl_write_cleanup);
> @@ -402,9 +343,9 @@ static void bl_end_par_io_write(void *data, int num_se)
>  static enum pnfs_try_status
>  bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  {
> -	int i, ret;
> +	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
>  	struct bio *bio = NULL;
> -	struct pnfs_block_extent *be = NULL;
> +	struct pnfs_block_extent be;
>  	sector_t isect, extent_length = 0;
>  	struct parallel_io *par = NULL;
>  	loff_t offset = header->args.offset;
> @@ -412,6 +353,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  	struct page **pages = header->args.pages;
>  	int pg_index = pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
>  	struct blk_plug plug;
> +	int i;
>  
>  	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
>  
> @@ -421,9 +363,8 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  	 */
>  	par = alloc_parallel(header);
>  	if (!par)
> -		goto out_mds;
> +		return PNFS_NOT_ATTEMPTED;
>  	par->pnfs_callback = bl_end_par_io_write;
> -	/* At this point, have to be more careful with error handling */
>  
>  	blk_start_plug(&plug);
>  
> @@ -434,44 +375,18 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  	for (i = pg_index; i < header->page_array.npages; i++) {
>  		if (extent_length <= 0) {
>  			/* We've used up the previous extent */
> -			bl_put_extent(be);
>  			bio = bl_submit_bio(WRITE, bio);
>  			/* Get the next one */
> -			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
> -					     isect, NULL);
> -			if (!be || !is_writable(be, isect)) {
> +			if (!ext_tree_lookup(bl, isect, &be, true)) {
>  				header->pnfs_error = -EINVAL;
>  				goto out;
>  			}
> -			if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
> -				if (likely(!bl_push_one_short_extent(
> -								be->be_inval)))
> -					par->bse_count++;
> -				else {
> -					header->pnfs_error = -ENOMEM;
> -					goto out;
> -				}
> -			}
> -			extent_length = be->be_length -
> -			    (isect - be->be_f_offset);
> -		}
>  
> -		BUG_ON(offset & ~PAGE_CACHE_MASK);
> -
> -		if (be->be_state == PNFS_BLOCK_INVALID_DATA &&
> -		    !bl_is_sector_init(be->be_inval, isect)) {
> -			ret = bl_mark_sectors_init(be->be_inval, isect,
> -						       PAGE_CACHE_SECTORS);
> -			if (unlikely(ret)) {
> -				dprintk("%s bl_mark_sectors_init fail %d\n",
> -					__func__, ret);
> -				header->pnfs_error = ret;
> -				goto out;
> -			}
> +			extent_length = be.be_length - (isect - be.be_f_offset);
>  		}
>  
>  		bio = do_add_page_to_bio(bio, header->page_array.npages - i,
> -					 WRITE, isect, pages[i], be,
> +					 WRITE, isect, pages[i], &be,
>  					 bl_end_io_write, par,
>  					 0, PAGE_CACHE_SIZE);
>  		if (IS_ERR(bio)) {
> @@ -487,60 +402,22 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  
>  	header->res.count = header->args.count;
>  out:
> -	bl_put_extent(be);
>  	bl_submit_bio(WRITE, bio);
>  	blk_finish_plug(&plug);
>  	put_parallel(par);
>  	return PNFS_ATTEMPTED;
> -out_mds:
> -	return PNFS_NOT_ATTEMPTED;
> -}
> -
> -/* FIXME - range ignored */
> -static void
> -release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
> -{
> -	int i;
> -	struct pnfs_block_extent *be;
> -
> -	spin_lock(&bl->bl_ext_lock);
> -	for (i = 0; i < EXTENT_LISTS; i++) {
> -		while (!list_empty(&bl->bl_extents[i])) {
> -			be = list_first_entry(&bl->bl_extents[i],
> -					      struct pnfs_block_extent,
> -					      be_node);
> -			list_del(&be->be_node);
> -			bl_put_extent(be);
> -		}
> -	}
> -	spin_unlock(&bl->bl_ext_lock);
> -}
> -
> -static void
> -release_inval_marks(struct pnfs_inval_markings *marks)
> -{
> -	struct pnfs_inval_tracking *pos, *temp;
> -	struct pnfs_block_short_extent *se, *stemp;
> -
> -	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
> -		list_del(&pos->it_link);
> -		kfree(pos);
> -	}
> -
> -	list_for_each_entry_safe(se, stemp, &marks->im_extents, bse_node) {
> -		list_del(&se->bse_node);
> -		kfree(se);
> -	}
> -	return;
>  }
>  
>  static void bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
>  {
>  	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
> +	int err;
>  
>  	dprintk("%s enter\n", __func__);
> -	release_extents(bl, NULL);
> -	release_inval_marks(&bl->bl_inval);
> +
> +	err = ext_tree_remove(bl, true, 0, LLONG_MAX);
> +	WARN_ON(err);
> +
>  	kfree(bl);
>  }
>  
> @@ -553,14 +430,11 @@ static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
>  	bl = kzalloc(sizeof(*bl), gfp_flags);
>  	if (!bl)
>  		return NULL;
> +
> +	bl->bl_ext_rw = RB_ROOT;
> +	bl->bl_ext_ro = RB_ROOT;
>  	spin_lock_init(&bl->bl_ext_lock);
> -	INIT_LIST_HEAD(&bl->bl_extents[0]);
> -	INIT_LIST_HEAD(&bl->bl_extents[1]);
> -	INIT_LIST_HEAD(&bl->bl_commit);
> -	INIT_LIST_HEAD(&bl->bl_committing);
> -	bl->bl_count = 0;
> -	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> SECTOR_SHIFT;
> -	BL_INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
> +	
>  	return &bl->bl_layout;
>  }
>  
> @@ -600,7 +474,7 @@ bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
>  		       const struct nfs4_layoutcommit_args *arg)
>  {
>  	dprintk("%s enter\n", __func__);
> -	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
> +	ext_tree_encode_commit(BLK_LO2EXT(lo), xdr);
>  }
>  
>  static void
> @@ -609,7 +483,7 @@ bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
>  	struct pnfs_layout_hdr *lo = NFS_I(lcdata->args.inode)->layout;
>  
>  	dprintk("%s enter\n", __func__);
> -	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args, lcdata->res.status);
> +	ext_tree_mark_committed(BLK_LO2EXT(lo), lcdata->res.status);
>  }
>  
>  static void free_blk_mountid(struct block_mount_id *mid)
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 9838fb0..b4f66d8 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -63,82 +63,28 @@ enum exstate4 {
>  	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
>  };
>  
> -#define MY_MAX_TAGS (15) /* tag bitnums used must be less than this */
> -
> -struct my_tree {
> -	sector_t		mtt_step_size;	/* Internal sector alignment */
> -	struct list_head	mtt_stub; /* Should be a radix tree */
> -};
> -
> -struct pnfs_inval_markings {
> -	spinlock_t	im_lock;
> -	struct my_tree	im_tree;	/* Sectors that need LAYOUTCOMMIT */
> -	sector_t	im_block_size;	/* Server blocksize in sectors */
> -	struct list_head im_extents;	/* Short extents for INVAL->RW conversion */
> -};
> -
> -struct pnfs_inval_tracking {
> -	struct list_head it_link;
> -	int		 it_sector;
> -	int		 it_tags;
> -};
> -
>  /* sector_t fields are all in 512-byte sectors */
>  struct pnfs_block_extent {
> -	struct kref	be_refcnt;
> -	struct list_head be_node;	/* link into lseg list */
> -	struct nfs4_deviceid be_devid;  /* FIXME: could use device cache instead */
> +	union {
> +		struct rb_node	be_node;
> +		struct list_head be_list;
> +	};
> +	struct nfs4_deviceid be_devid;	/* FIXME: could use device cache instead */
>  	struct block_device *be_mdev;
>  	sector_t	be_f_offset;	/* the starting offset in the file */
>  	sector_t	be_length;	/* the size of the extent */
>  	sector_t	be_v_offset;	/* the starting offset in the volume */
>  	enum exstate4	be_state;	/* the state of this extent */
> -	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
> -};
> -
> -/* Shortened extent used by LAYOUTCOMMIT */
> -struct pnfs_block_short_extent {
> -	struct list_head bse_node;
> -	struct nfs4_deviceid bse_devid;
> -	struct block_device *bse_mdev;
> -	sector_t	bse_f_offset;	/* the starting offset in the file */
> -	sector_t	bse_length;	/* the size of the extent */
> +#define EXTENT_WRITTEN		1
> +#define EXTENT_COMMITTING	2
> +	unsigned int	be_tag;
>  };
>  
> -static inline void
> -BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
> -{
> -	spin_lock_init(&marks->im_lock);
> -	INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
> -	INIT_LIST_HEAD(&marks->im_extents);
> -	marks->im_block_size = blocksize;
> -	marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
> -					   blocksize);
> -}
> -
> -enum extentclass4 {
> -	RW_EXTENT       = 0, /* READWRTE and INVAL */
> -	RO_EXTENT       = 1, /* READ and NONE */
> -	EXTENT_LISTS    = 2,
> -};
> -
> -static inline int bl_choose_list(enum exstate4 state)
> -{
> -	if (state == PNFS_BLOCK_READ_DATA || state == PNFS_BLOCK_NONE_DATA)
> -		return RO_EXTENT;
> -	else
> -		return RW_EXTENT;
> -}
> -
>  struct pnfs_block_layout {
> -	struct pnfs_layout_hdr bl_layout;
> -	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
> +	struct pnfs_layout_hdr	bl_layout;
> +	struct rb_root		bl_ext_rw;
> +	struct rb_root		bl_ext_ro;
>  	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
> -	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
> -	struct list_head	bl_commit;	/* Needs layout commit */
> -	struct list_head	bl_committing;	/* Layout committing */
> -	unsigned int		bl_count;	/* entries in bl_commit */
> -	sector_t		bl_blocksize;  /* Server blocksize in sectors */
>  };
>  
>  #define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->plh_inode)->pnfs_ld_data))
> @@ -183,29 +129,17 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  /* blocklayoutdm.c */
>  void bl_free_block_dev(struct pnfs_block_dev *bdev);
>  
> -/* extents.c */
> -struct pnfs_block_extent *
> -bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
> -		struct pnfs_block_extent **cow_read);
> -int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
> -			     sector_t offset, sector_t length);
> -void bl_put_extent(struct pnfs_block_extent *be);
> -struct pnfs_block_extent *bl_alloc_extent(void);
> -int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect);
> -int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
> -				   struct xdr_stream *xdr,
> -				   const struct nfs4_layoutcommit_args *arg);
> -void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
> -				   const struct nfs4_layoutcommit_args *arg,
> -				   int status);
> -int bl_add_merge_extent(struct pnfs_block_layout *bl,
> -			 struct pnfs_block_extent *new);
> -int bl_mark_for_commit(struct pnfs_block_extent *be,
> -			sector_t offset, sector_t length,
> -			struct pnfs_block_short_extent *new);
> -int bl_push_one_short_extent(struct pnfs_inval_markings *marks);
> -struct pnfs_block_short_extent *
> -bl_pop_one_short_extent(struct pnfs_inval_markings *marks);
> -void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free);
> +/* extent_tree.c */
> +int ext_tree_insert(struct pnfs_block_layout *bl,
> +		struct pnfs_block_extent *new);
> +int ext_tree_remove(struct pnfs_block_layout *bl, bool rw, sector_t start,
> +		sector_t end);
> +int ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
> +		sector_t len);
> +bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
> +		struct pnfs_block_extent *ret, bool rw);
> +int ext_tree_encode_commit(struct pnfs_block_layout *bl,
> +		struct xdr_stream *xdr);
> +void ext_tree_mark_committed(struct pnfs_block_layout *bl, int status);
>  
>  #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
> diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
> index 63f77925..cd71b5e 100644
> --- a/fs/nfs/blocklayout/blocklayoutdev.c
> +++ b/fs/nfs/blocklayout/blocklayoutdev.c
> @@ -309,7 +309,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  	 * recovery easier.
>  	 */
>  	for (i = 0; i < count; i++) {
> -		be = bl_alloc_extent();
> +		be = kzalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
>  		if (!be) {
>  			status = -ENOMEM;
>  			goto out_err;
> @@ -330,13 +330,11 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  		if (decode_sector_number(&p, &be->be_v_offset) < 0)
>  			goto out_err;
>  		be->be_state = be32_to_cpup(p++);
> -		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
> -			be->be_inval = &bl->bl_inval;
>  		if (verify_extent(be, &lv)) {
>  			dprintk("%s verify failed\n", __func__);
>  			goto out_err;
>  		}
> -		list_add_tail(&be->be_node, &extents);
> +		list_add_tail(&be->be_list, &extents);
>  	}
>  	if (lgr->range.offset + lgr->range.length !=
>  			lv.start << SECTOR_SHIFT) {
> @@ -352,21 +350,13 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  	/* Extents decoded properly, now try to merge them in to
>  	 * existing layout extents.
>  	 */
> -	spin_lock(&bl->bl_ext_lock);
> -	list_for_each_entry_safe(be, save, &extents, be_node) {
> -		list_del(&be->be_node);
> -		status = bl_add_merge_extent(bl, be);
> -		if (status) {
> -			spin_unlock(&bl->bl_ext_lock);
> -			/* This is a fairly catastrophic error, as the
> -			 * entire layout extent lists are now corrupted.
> -			 * We should have some way to distinguish this.
> -			 */
> -			be = NULL;
> -			goto out_err;
> -		}
> +	list_for_each_entry_safe(be, save, &extents, be_list) {
> +		list_del(&be->be_list);
> +
> +		status = ext_tree_insert(bl, be);
> +		if (status)
> +			goto out_free_list;
>  	}
> -	spin_unlock(&bl->bl_ext_lock);
>  	status = 0;
>   out:
>  	__free_page(scratch);
> @@ -374,12 +364,13 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  	return status;
>  
>   out_err:
> -	bl_put_extent(be);
> +	kfree(be);
> + out_free_list:
>  	while (!list_empty(&extents)) {
>  		be = list_first_entry(&extents, struct pnfs_block_extent,
> -				      be_node);
> -		list_del(&be->be_node);
> -		bl_put_extent(be);
> +				      be_list);
> +		list_del(&be->be_list);
> +		kfree(be);
>  	}
>  	goto out;
>  }
> diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
> new file mode 100644
> index 0000000..c7dacfa
> --- /dev/null
> +++ b/fs/nfs/blocklayout/extent_tree.c
> @@ -0,0 +1,545 @@
> +/*
> + * Copyright (c) 2014 Christoph Hellwig.
> + */
> +
> +#include "blocklayout.h"
> +
> +static inline struct pnfs_block_extent *
> +ext_node(struct rb_node *node)
> +{
> +	return rb_entry(node, struct pnfs_block_extent, be_node);
> +}
> +
> +static struct pnfs_block_extent *
> +ext_tree_first(struct rb_root *root)
> +{
> +	struct rb_node *node = rb_first(root);
> +	return node ? ext_node(node) : NULL;
> +}
> +
> +static struct pnfs_block_extent *
> +ext_tree_prev(struct pnfs_block_extent *be)
> +{
> +	struct rb_node *node = rb_prev(&be->be_node);
> +	return node ? ext_node(node) : NULL;
> +}
> +
> +static struct pnfs_block_extent *
> +ext_tree_next(struct pnfs_block_extent *be)
> +{
> +	struct rb_node *node = rb_next(&be->be_node);
> +	return node ? ext_node(node) : NULL;
> +}
> +
> +static inline sector_t
> +ext_f_end(struct pnfs_block_extent *be)
> +{
> +	return be->be_f_offset + be->be_length;
> +}
> +
> +static struct pnfs_block_extent *
> +__ext_tree_search(struct rb_root *root, sector_t start)
> +{
> +	struct rb_node *node = root->rb_node;
> +	struct pnfs_block_extent *be = NULL;
> +
> +	while (node) {
> +		be = ext_node(node);
> +		if (start < be->be_f_offset)
> +			node = node->rb_left;
> +		else if (start >= ext_f_end(be))
> +			node = node->rb_right;
> +		else
> +			return be;
> +	}
> +
> +	if (be) {
> +		if (start < be->be_f_offset)
> +			return be;
> +
> +		if (start >= ext_f_end(be))
> +			return ext_tree_next(be);
> +	}
> +
> +	return NULL;
> +}
> +
> +static bool
> +ext_can_merge(struct pnfs_block_extent *be1, struct pnfs_block_extent *be2)
> +{
> +	if (be1->be_state != be2->be_state)
> +		return false;
> +	if (be1->be_mdev != be2->be_mdev)
> +		return false;
> +
> +	if (be1->be_f_offset + be1->be_length != be2->be_f_offset)
> +		return false;
> +
> +	if (be1->be_state != PNFS_BLOCK_NONE_DATA &&
> +	    (be1->be_v_offset + be1->be_length != be2->be_v_offset))
> +		return false;
> +
> +	if (be1->be_state == PNFS_BLOCK_INVALID_DATA &&
> +	    be1->be_tag != be2->be_tag)
> +		return false;
> +
> +	return true;
> +}
> +
> +static struct pnfs_block_extent *
> +ext_try_to_merge_left(struct rb_root *root, struct pnfs_block_extent *be)
> +{
> +	struct pnfs_block_extent *left = ext_tree_prev(be);
> +
> +	if (left && ext_can_merge(left, be)) {
> +		left->be_length += be->be_length;
> +		rb_erase(&be->be_node, root);
> +		kfree(be);
> +		return left;
> +	}
> +
> +	return be;
> +}
> +
> +static struct pnfs_block_extent *
> +ext_try_to_merge_right(struct rb_root *root, struct pnfs_block_extent *be)
> +{
> +	struct pnfs_block_extent *right = ext_tree_next(be);
> +
> +	if (right && ext_can_merge(be, right)) {
> +		be->be_length += right->be_length;
> +		rb_erase(&right->be_node, root);
> +		kfree(right);
> +	}
> +
> +	return be;
> +}
> +
> +static void
> +__ext_tree_insert(struct rb_root *root,
> +		struct pnfs_block_extent *new, bool merge_ok)
> +{
> +	struct rb_node **p = &root->rb_node, *parent = NULL;
> +	struct pnfs_block_extent *be;
> +
> +	while (*p) {
> +		parent = *p;
> +		be = ext_node(parent);
> +
> +		if (new->be_f_offset < be->be_f_offset) {
> +			if (merge_ok && ext_can_merge(new, be)) {
> +				be->be_f_offset = new->be_f_offset;
> +				if (be->be_state != PNFS_BLOCK_NONE_DATA)
> +					be->be_v_offset = new->be_v_offset;
> +				be->be_length += new->be_length;
> +				be = ext_try_to_merge_left(root, be);
> +				kfree(new);
> +				return;
> +			}
> +			p = &(*p)->rb_left;
> +		} else if (new->be_f_offset >= ext_f_end(be)) {
> +			if (merge_ok && ext_can_merge(be, new)) {
> +				be->be_length += new->be_length;
> +				be = ext_try_to_merge_right(root, be);
> +				kfree(new);
> +				return;
> +			}
> +			p = &(*p)->rb_right;
> +		} else {
> +			BUG();
> +		}
> +	}
> +
> +	rb_link_node(&new->be_node, parent, p);
> +	rb_insert_color(&new->be_node, root);
> +}
> +
> +static int
> +__ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
> +{
> +	struct pnfs_block_extent *be;
> +	sector_t len1 = 0, len2 = 0;
> +	sector_t orig_f_offset;
> +	sector_t orig_v_offset;
> +	sector_t orig_len;
> +
> +	be = __ext_tree_search(root, start);
> +	if (!be)
> +		return 0;
> +	if (be->be_f_offset >= end)
> +		return 0;
> +
> +	orig_f_offset = be->be_f_offset;
> +	orig_v_offset = be->be_v_offset;
> +	orig_len = be->be_length;
> +
> +	if (start > be->be_f_offset)
> +		len1 = start - be->be_f_offset;
> +	if (ext_f_end(be) > end)
> +		len2 = ext_f_end(be) - end;
> +
> +	if (len2 > 0) {
> +		if (len1 > 0) {
> +			struct pnfs_block_extent *new;
> +
> +			new = kzalloc(sizeof(*new), GFP_ATOMIC);
> +			if (!new)
> +				return -ENOMEM;
> +
> +			be->be_length = len1;
> +
> +			new->be_f_offset = end;
> +			if (be->be_state != PNFS_BLOCK_NONE_DATA) {
> +				new->be_v_offset =
> +					orig_v_offset + orig_len - len2;
> +			}
> +			new->be_length = len2;
> +			new->be_state = be->be_state;
> +			new->be_tag = be->be_tag;
> +			new->be_mdev = be->be_mdev;
> +			memcpy(&new->be_devid, &be->be_devid,
> +				sizeof(struct nfs4_deviceid));
> +
> +			__ext_tree_insert(root, new, true);
> +		} else {
> +			be->be_f_offset = end;
> +			if (be->be_state != PNFS_BLOCK_NONE_DATA) {
> +				be->be_v_offset =
> +					orig_v_offset + orig_len - len2;
> +			}
> +			be->be_length = len2;
> +		}
> +	} else {
> +		if (len1 > 0) {
> +			be->be_length = len1;
> +			be = ext_tree_next(be);
> +		}
> +
> +		while (be && ext_f_end(be) <= end) {
> +			struct pnfs_block_extent *next = ext_tree_next(be);
> +
> +			rb_erase(&be->be_node, root);
> +			kfree(be);
> +			be = next;
> +		}
> +
> +		if (be && be->be_f_offset < end) {
> +			len1 = ext_f_end(be) - end;
> +			be->be_f_offset = end;
> +			if (be->be_state != PNFS_BLOCK_NONE_DATA)
> +				be->be_v_offset += be->be_length - len1;
> +			be->be_length = len1;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +int
> +ext_tree_insert(struct pnfs_block_layout *bl, struct pnfs_block_extent *new)
> +{
> +	struct pnfs_block_extent *be;
> +	struct rb_root *root;
> +	int err = 0;
> +
> +	switch (new->be_state) {
> +	case PNFS_BLOCK_READWRITE_DATA:
> +	case PNFS_BLOCK_INVALID_DATA:
> +		root = &bl->bl_ext_rw;
> +		break;
> +	case PNFS_BLOCK_READ_DATA:
> +	case PNFS_BLOCK_NONE_DATA:
> +		root = &bl->bl_ext_ro;
> +		break;
> +	default:
> +		dprintk("invalid extent type\n");
> +		return -EINVAL;
> +	}
> +
> +	spin_lock(&bl->bl_ext_lock);
> +retry:
> +	be = __ext_tree_search(root, new->be_f_offset);
> +	if (!be || be->be_f_offset >= ext_f_end(new)) {
> +		__ext_tree_insert(root, new, true);
> +	} else if (new->be_f_offset >= be->be_f_offset) {
> +		if (ext_f_end(new) <= ext_f_end(be)) {
> +			kfree(new);
> +		} else {
> +			sector_t new_len = ext_f_end(new) - ext_f_end(be);
> +			sector_t diff = new->be_length - new_len;
> +
> +			new->be_f_offset += diff;
> +			new->be_v_offset += diff;
> +			new->be_length = new_len;
> +			goto retry;
> +		}
> +	} else if (ext_f_end(new) <= ext_f_end(be)) {
> +		new->be_length = be->be_f_offset - new->be_f_offset;
> +		__ext_tree_insert(root, new, true);
> +	} else {
> +		struct pnfs_block_extent *split;
> +		sector_t new_len = ext_f_end(new) - ext_f_end(be);
> +		sector_t diff = new->be_length - new_len;
> +
> +		split = kmemdup(new, sizeof(*new), GFP_ATOMIC);
> +		if (!split) {
> +			err = -EINVAL;
> +			goto out;
> +		}
> +
> +		split->be_length = be->be_f_offset - split->be_f_offset;
> +		__ext_tree_insert(root, split, true);
> +
> +		new->be_f_offset += diff;
> +		new->be_v_offset += diff;
> +		new->be_length = new_len;
> +		goto retry;
> +	}
> +out:
> +	spin_unlock(&bl->bl_ext_lock);
> +	return err;
> +}
> +
> +static bool
> +__ext_tree_lookup(struct rb_root *root, sector_t isect,
> +		struct pnfs_block_extent *ret)
> +{
> +	struct rb_node *node;
> +	struct pnfs_block_extent *be;
> +
> +	node = root->rb_node;
> +	while (node) {
> +		be = ext_node(node);
> +		if (isect < be->be_f_offset)
> +			node = node->rb_left;
> +		else if (isect >= ext_f_end(be))
> +			node = node->rb_right;
> +		else {
> +			*ret = *be;
> +			return true;
> +		}
> +	}
> +
> +	return false;
> +}
> +
> +bool
> +ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
> +	    struct pnfs_block_extent *ret, bool rw)
> +{
> +	bool found = false;
> +
> +	spin_lock(&bl->bl_ext_lock);
> +	if (!rw)
> +		found = __ext_tree_lookup(&bl->bl_ext_ro, isect, ret);
> +	if (!found)
> +		found = __ext_tree_lookup(&bl->bl_ext_rw, isect, ret);
> +	spin_unlock(&bl->bl_ext_lock);
> +
> +	return found;
> +}
> +
> +int ext_tree_remove(struct pnfs_block_layout *bl, bool rw,
> +		sector_t start, sector_t end)
> +{
> +	int err, err2;
> +
> +	spin_lock(&bl->bl_ext_lock);
> +	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
> +	if (rw) {
> +		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end);
> +		if (!err)
> +			err = err2;
> +	}
> +	spin_unlock(&bl->bl_ext_lock);
> +
> +	return err;
> +}
> +
> +static int
> +ext_tree_split(struct rb_root *root, struct pnfs_block_extent *be,
> +		sector_t split)
> +{
> +	struct pnfs_block_extent *new;
> +	sector_t orig_len = be->be_length;
> +
> +	dprintk("%s: need split for 0x%lx:0x%lx at 0x%lx\n",
> +		__func__, be->be_f_offset, ext_f_end(be), split);
> +
> +	new = kzalloc(sizeof(*new), GFP_ATOMIC);
> +	if (!new)
> +		return -ENOMEM;
> +
> +	be->be_length = split - be->be_f_offset;
> +
> +	new->be_f_offset = split;
> +	if (be->be_state != PNFS_BLOCK_NONE_DATA)
> +		new->be_v_offset = be->be_v_offset + be->be_length;
> +	new->be_length = orig_len - be->be_length;
> +	new->be_state = be->be_state;
> +	new->be_tag = be->be_tag;
> +
> +	new->be_mdev = be->be_mdev;
> +	memcpy(&new->be_devid, &be->be_devid, sizeof(struct nfs4_deviceid));
> +
> +	dprintk("%s: got 0x%lx:0x%lx!\n",
> +		__func__, be->be_f_offset, ext_f_end(be));
> +	dprintk("%s: got 0x%lx:0x%lx!\n",
> +		__func__, new->be_f_offset, ext_f_end(new));
> +
> +	__ext_tree_insert(root, new, false);
> +	return 0;
> +}
> +
> +int
> +ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
> +		sector_t len)
> +{
> +	struct rb_root *root = &bl->bl_ext_rw;
> +	sector_t end = start + len;
> +	struct pnfs_block_extent *be;
> +	int err = 0;
> +
> +	spin_lock(&bl->bl_ext_lock);
> +	/*
> +	 * First remove all COW extents or holes from written to range.
> +	 */
> +	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
> +	if (err)
> +		goto out;
> +
> +	/*
> +	 * Then mark all invalid extents in the range as written to.
> +	 */
> +	for (be = __ext_tree_search(root, start); be; be = ext_tree_next(be)) {
> +		if (be->be_f_offset >= end)
> +			break;
> +
> +		if (be->be_state != PNFS_BLOCK_INVALID_DATA || be->be_tag)
> +			continue;
> +
> +		if (be->be_f_offset < start) {
> +			struct pnfs_block_extent *left = ext_tree_prev(be);
> +
> +			if (left && ext_can_merge(left, be)) {
> +				sector_t diff = start - be->be_f_offset;
> +
> +				left->be_length += diff;
> +
> +				be->be_f_offset += diff;
> +				be->be_v_offset += diff;
> +				be->be_length -= diff;
> +			} else {
> +				err = ext_tree_split(root, be, start);
> +				if (err)
> +					goto out;
> +			}
> +		}
> +
> +		if (ext_f_end(be) > end) {
> +			struct pnfs_block_extent *right = ext_tree_next(be);
> +
> +			if (right && ext_can_merge(be, right)) {
> +				sector_t diff = end - be->be_f_offset;
> +
> +				be->be_length -= diff;
> +
> +				right->be_f_offset -= diff;
> +				right->be_v_offset -= diff;
> +				right->be_length += diff;
> +			} else {
> +				err = ext_tree_split(root, be, end);
> +				if (err)
> +					goto out;
> +			}
> +		}
> +
> +		if (be->be_f_offset >= start && ext_f_end(be) <= end) {
> +			be->be_tag = EXTENT_WRITTEN;
> +			be = ext_try_to_merge_left(root, be);
> +			be = ext_try_to_merge_right(root, be);
> +		}
> +	}
> +out:
> +	spin_unlock(&bl->bl_ext_lock);
> +	return err;
> +}
> +
> +int
> +ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
> +{
> +	struct pnfs_block_extent *be;
> +	unsigned int count = 0;
> +	__be32 *p, *xdr_start;
> +	int ret = 0;
> +
> +	dprintk("%s enter\n", __func__);
> +
> +	xdr_start = xdr_reserve_space(xdr, 8);
> +	if (!xdr_start)
> +		return -ENOSPC;
> +
> +	spin_lock(&bl->bl_ext_lock);
> +	for (be = ext_tree_first(&bl->bl_ext_rw); be; be = ext_tree_next(be)) {
> +		if (be->be_state != PNFS_BLOCK_INVALID_DATA ||
> +		    be->be_tag != EXTENT_WRITTEN)
> +			continue;
> +
> +		p = xdr_reserve_space(xdr, 7 * sizeof(__be32) +
> +					NFS4_DEVICEID4_SIZE);
> +		if (!p) {
> +			printk("%s: out of space for extent list\n", __func__);
> +			ret = -ENOSPC;
> +			break;
> +		}
> +
> +		p = xdr_encode_opaque_fixed(p, be->be_devid.data,
> +				NFS4_DEVICEID4_SIZE);
> +		p = xdr_encode_hyper(p, be->be_f_offset << SECTOR_SHIFT);
> +		p = xdr_encode_hyper(p, be->be_length << SECTOR_SHIFT);
> +		p = xdr_encode_hyper(p, 0LL);
> +		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
> +
> +		be->be_tag = EXTENT_COMMITTING;
> +		count++;
> +	}
> +	spin_unlock(&bl->bl_ext_lock);
> +
> +	xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
> +	xdr_start[1] = cpu_to_be32(count);
> +
> +	dprintk("%s found %i ranges\n", __func__, count);
> +	return ret;
> +}
> +
> +void
> +ext_tree_mark_committed(struct pnfs_block_layout *bl, int status)
> +{
> +	struct rb_root *root = &bl->bl_ext_rw;
> +	struct pnfs_block_extent *be;
> +
> +	dprintk("%s status %d\n", __func__, status);
> +
> +	spin_lock(&bl->bl_ext_lock);
> +	for (be = ext_tree_first(root); be; be = ext_tree_next(be)) {
> +		if (be->be_state != PNFS_BLOCK_INVALID_DATA ||
> +		    be->be_tag != EXTENT_COMMITTING)
> +			continue;
> +
> +		if (status) {
> +			/*
> +			 * Mark as written and try again.
> +			 *
> +			 * XXX: some real error handling here wouldn't hurt..
> +			 */
> +			be->be_tag = EXTENT_WRITTEN;
> +		} else {
> +			be->be_state = PNFS_BLOCK_READWRITE_DATA;
> +			be->be_tag = 0;
> +		}
> +
> +		be = ext_try_to_merge_left(root, be);
> +		be = ext_try_to_merge_right(root, be);
> +	}
> +	spin_unlock(&bl->bl_ext_lock);
> +}
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> deleted file mode 100644
> index 4d01614..0000000
> --- a/fs/nfs/blocklayout/extents.c
> +++ /dev/null
> @@ -1,908 +0,0 @@
> -/*
> - *  linux/fs/nfs/blocklayout/blocklayout.h
> - *
> - *  Module for the NFSv4.1 pNFS block layout driver.
> - *
> - *  Copyright (c) 2006 The Regents of the University of Michigan.
> - *  All rights reserved.
> - *
> - *  Andy Adamson <andros@citi.umich.edu>
> - *  Fred Isaman <iisaman@umich.edu>
> - *
> - * permission is granted to use, copy, create derivative works and
> - * redistribute this software and such derivative works for any purpose,
> - * so long as the name of the university of michigan is not used in
> - * any advertising or publicity pertaining to the use or distribution
> - * of this software without specific, written prior authorization.  if
> - * the above copyright notice or any other identification of the
> - * university of michigan is included in any copy of any portion of
> - * this software, then the disclaimer below must also be included.
> - *
> - * this software is provided as is, without representation from the
> - * university of michigan as to its fitness for any purpose, and without
> - * warranty by the university of michigan of any kind, either express
> - * or implied, including without limitation the implied warranties of
> - * merchantability and fitness for a particular purpose.  the regents
> - * of the university of michigan shall not be liable for any damages,
> - * including special, indirect, incidental, or consequential damages,
> - * with respect to any claim arising out or in connection with the use
> - * of the software, even if it has been or is hereafter advised of the
> - * possibility of such damages.
> - */
> -
> -#include "blocklayout.h"
> -#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
> -
> -/* Bit numbers */
> -#define EXTENT_INITIALIZED 0
> -#define EXTENT_WRITTEN     1
> -#define EXTENT_IN_COMMIT   2
> -#define INTERNAL_EXISTS    MY_MAX_TAGS
> -#define INTERNAL_MASK      ((1 << INTERNAL_EXISTS) - 1)
> -
> -/* Returns largest t<=s s.t. t%base==0 */
> -static inline sector_t normalize(sector_t s, int base)
> -{
> -	sector_t tmp = s; /* Since do_div modifies its argument */
> -	return s - sector_div(tmp, base);
> -}
> -
> -static inline sector_t normalize_up(sector_t s, int base)
> -{
> -	return normalize(s + base - 1, base);
> -}
> -
> -/* Complete stub using list while determine API wanted */
> -
> -/* Returns tags, or negative */
> -static int32_t _find_entry(struct my_tree *tree, u64 s)
> -{
> -	struct pnfs_inval_tracking *pos;
> -
> -	dprintk("%s(%llu) enter\n", __func__, s);
> -	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
> -		if (pos->it_sector > s)
> -			continue;
> -		else if (pos->it_sector == s)
> -			return pos->it_tags & INTERNAL_MASK;
> -		else
> -			break;
> -	}
> -	return -ENOENT;
> -}
> -
> -static inline
> -int _has_tag(struct my_tree *tree, u64 s, int32_t tag)
> -{
> -	int32_t tags;
> -
> -	dprintk("%s(%llu, %i) enter\n", __func__, s, tag);
> -	s = normalize(s, tree->mtt_step_size);
> -	tags = _find_entry(tree, s);
> -	if ((tags < 0) || !(tags & (1 << tag)))
> -		return 0;
> -	else
> -		return 1;
> -}
> -
> -/* Creates entry with tag, or if entry already exists, unions tag to it.
> - * If storage is not NULL, newly created entry will use it.
> - * Returns number of entries added, or negative on error.
> - */
> -static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
> -		      struct pnfs_inval_tracking *storage)
> -{
> -	int found = 0;
> -	struct pnfs_inval_tracking *pos;
> -
> -	dprintk("%s(%llu, %i, %p) enter\n", __func__, s, tag, storage);
> -	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
> -		if (pos->it_sector > s)
> -			continue;
> -		else if (pos->it_sector == s) {
> -			found = 1;
> -			break;
> -		} else
> -			break;
> -	}
> -	if (found) {
> -		pos->it_tags |= (1 << tag);
> -		return 0;
> -	} else {
> -		struct pnfs_inval_tracking *new;
> -		new = storage;
> -		new->it_sector = s;
> -		new->it_tags = (1 << tag);
> -		list_add(&new->it_link, &pos->it_link);
> -		return 1;
> -	}
> -}
> -
> -/* XXXX Really want option to not create */
> -/* Over range, unions tag with existing entries, else creates entry with tag */
> -static int _set_range(struct my_tree *tree, int32_t tag, u64 s, u64 length)
> -{
> -	u64 i;
> -
> -	dprintk("%s(%i, %llu, %llu) enter\n", __func__, tag, s, length);
> -	for (i = normalize(s, tree->mtt_step_size); i < s + length;
> -	     i += tree->mtt_step_size)
> -		if (_add_entry(tree, i, tag, NULL))
> -			return -ENOMEM;
> -	return 0;
> -}
> -
> -/* Ensure that future operations on given range of tree will not malloc */
> -static int _preload_range(struct pnfs_inval_markings *marks,
> -		u64 offset, u64 length)
> -{
> -	u64 start, end, s;
> -	int count, i, used = 0, status = -ENOMEM;
> -	struct pnfs_inval_tracking **storage;
> -	struct my_tree  *tree = &marks->im_tree;
> -
> -	dprintk("%s(%llu, %llu) enter\n", __func__, offset, length);
> -	start = normalize(offset, tree->mtt_step_size);
> -	end = normalize_up(offset + length, tree->mtt_step_size);
> -	count = (int)(end - start) / (int)tree->mtt_step_size;
> -
> -	/* Pre-malloc what memory we might need */
> -	storage = kcalloc(count, sizeof(*storage), GFP_NOFS);
> -	if (!storage)
> -		return -ENOMEM;
> -	for (i = 0; i < count; i++) {
> -		storage[i] = kmalloc(sizeof(struct pnfs_inval_tracking),
> -				     GFP_NOFS);
> -		if (!storage[i])
> -			goto out_cleanup;
> -	}
> -
> -	spin_lock_bh(&marks->im_lock);
> -	for (s = start; s < end; s += tree->mtt_step_size)
> -		used += _add_entry(tree, s, INTERNAL_EXISTS, storage[used]);
> -	spin_unlock_bh(&marks->im_lock);
> -
> -	status = 0;
> -
> - out_cleanup:
> -	for (i = used; i < count; i++) {
> -		if (!storage[i])
> -			break;
> -		kfree(storage[i]);
> -	}
> -	kfree(storage);
> -	return status;
> -}
> -
> -/* We are relying on page lock to serialize this */
> -int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect)
> -{
> -	int rv;
> -
> -	spin_lock_bh(&marks->im_lock);
> -	rv = _has_tag(&marks->im_tree, isect, EXTENT_INITIALIZED);
> -	spin_unlock_bh(&marks->im_lock);
> -	return rv;
> -}
> -
> -/* Assume start, end already sector aligned */
> -static int
> -_range_has_tag(struct my_tree *tree, u64 start, u64 end, int32_t tag)
> -{
> -	struct pnfs_inval_tracking *pos;
> -	u64 expect = 0;
> -
> -	dprintk("%s(%llu, %llu, %i) enter\n", __func__, start, end, tag);
> -	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
> -		if (pos->it_sector >= end)
> -			continue;
> -		if (!expect) {
> -			if ((pos->it_sector == end - tree->mtt_step_size) &&
> -			    (pos->it_tags & (1 << tag))) {
> -				expect = pos->it_sector - tree->mtt_step_size;
> -				if (pos->it_sector < tree->mtt_step_size || expect < start)
> -					return 1;
> -				continue;
> -			} else {
> -				return 0;
> -			}
> -		}
> -		if (pos->it_sector != expect || !(pos->it_tags & (1 << tag)))
> -			return 0;
> -		expect -= tree->mtt_step_size;
> -		if (expect < start)
> -			return 1;
> -	}
> -	return 0;
> -}
> -
> -static int is_range_written(struct pnfs_inval_markings *marks,
> -			    sector_t start, sector_t end)
> -{
> -	int rv;
> -
> -	spin_lock_bh(&marks->im_lock);
> -	rv = _range_has_tag(&marks->im_tree, start, end, EXTENT_WRITTEN);
> -	spin_unlock_bh(&marks->im_lock);
> -	return rv;
> -}
> -
> -/* Marks sectors in [offest, offset_length) as having been initialized.
> - * All lengths are step-aligned, where step is min(pagesize, blocksize).
> - * Currently assumes offset is page-aligned
> - */
> -int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
> -			     sector_t offset, sector_t length)
> -{
> -	sector_t start, end;
> -
> -	dprintk("%s(offset=%llu,len=%llu) enter\n",
> -		__func__, (u64)offset, (u64)length);
> -
> -	start = normalize(offset, marks->im_block_size);
> -	end = normalize_up(offset + length, marks->im_block_size);
> -	if (_preload_range(marks, start, end - start))
> -		goto outerr;
> -
> -	spin_lock_bh(&marks->im_lock);
> -	if (_set_range(&marks->im_tree, EXTENT_INITIALIZED, offset, length))
> -		goto out_unlock;
> -	spin_unlock_bh(&marks->im_lock);
> -
> -	return 0;
> -
> -out_unlock:
> -	spin_unlock_bh(&marks->im_lock);
> -outerr:
> -	return -ENOMEM;
> -}
> -
> -/* Marks sectors in [offest, offset+length) as having been written to disk.
> - * All lengths should be block aligned.
> - */
> -static int mark_written_sectors(struct pnfs_inval_markings *marks,
> -				sector_t offset, sector_t length)
> -{
> -	int status;
> -
> -	dprintk("%s(offset=%llu,len=%llu) enter\n", __func__,
> -		(u64)offset, (u64)length);
> -	spin_lock_bh(&marks->im_lock);
> -	status = _set_range(&marks->im_tree, EXTENT_WRITTEN, offset, length);
> -	spin_unlock_bh(&marks->im_lock);
> -	return status;
> -}
> -
> -static void print_short_extent(struct pnfs_block_short_extent *be)
> -{
> -	dprintk("PRINT SHORT EXTENT extent %p\n", be);
> -	if (be) {
> -		dprintk("        be_f_offset %llu\n", (u64)be->bse_f_offset);
> -		dprintk("        be_length   %llu\n", (u64)be->bse_length);
> -	}
> -}
> -
> -static void print_clist(struct list_head *list, unsigned int count)
> -{
> -	struct pnfs_block_short_extent *be;
> -	unsigned int i = 0;
> -
> -	ifdebug(FACILITY) {
> -		printk(KERN_DEBUG "****************\n");
> -		printk(KERN_DEBUG "Extent list looks like:\n");
> -		list_for_each_entry(be, list, bse_node) {
> -			i++;
> -			print_short_extent(be);
> -		}
> -		if (i != count)
> -			printk(KERN_DEBUG "\n\nExpected %u entries\n\n\n", count);
> -		printk(KERN_DEBUG "****************\n");
> -	}
> -}
> -
> -/* Note: In theory, we should do more checking that devid's match between
> - * old and new, but if they don't, the lists are too corrupt to salvage anyway.
> - */
> -/* Note this is very similar to bl_add_merge_extent */
> -static void add_to_commitlist(struct pnfs_block_layout *bl,
> -			      struct pnfs_block_short_extent *new)
> -{
> -	struct list_head *clist = &bl->bl_commit;
> -	struct pnfs_block_short_extent *old, *save;
> -	sector_t end = new->bse_f_offset + new->bse_length;
> -
> -	dprintk("%s enter\n", __func__);
> -	print_short_extent(new);
> -	print_clist(clist, bl->bl_count);
> -	bl->bl_count++;
> -	/* Scan for proper place to insert, extending new to the left
> -	 * as much as possible.
> -	 */
> -	list_for_each_entry_safe(old, save, clist, bse_node) {
> -		if (new->bse_f_offset < old->bse_f_offset)
> -			break;
> -		if (end <= old->bse_f_offset + old->bse_length) {
> -			/* Range is already in list */
> -			bl->bl_count--;
> -			kfree(new);
> -			return;
> -		} else if (new->bse_f_offset <=
> -				old->bse_f_offset + old->bse_length) {
> -			/* new overlaps or abuts existing be */
> -			if (new->bse_mdev == old->bse_mdev) {
> -				/* extend new to fully replace old */
> -				new->bse_length += new->bse_f_offset -
> -						old->bse_f_offset;
> -				new->bse_f_offset = old->bse_f_offset;
> -				list_del(&old->bse_node);
> -				bl->bl_count--;
> -				kfree(old);
> -			}
> -		}
> -	}
> -	/* Note that if we never hit the above break, old will not point to a
> -	 * valid extent.  However, in that case &old->bse_node==list.
> -	 */
> -	list_add_tail(&new->bse_node, &old->bse_node);
> -	/* Scan forward for overlaps.  If we find any, extend new and
> -	 * remove the overlapped extent.
> -	 */
> -	old = list_prepare_entry(new, clist, bse_node);
> -	list_for_each_entry_safe_continue(old, save, clist, bse_node) {
> -		if (end < old->bse_f_offset)
> -			break;
> -		/* new overlaps or abuts old */
> -		if (new->bse_mdev == old->bse_mdev) {
> -			if (end < old->bse_f_offset + old->bse_length) {
> -				/* extend new to fully cover old */
> -				end = old->bse_f_offset + old->bse_length;
> -				new->bse_length = end - new->bse_f_offset;
> -			}
> -			list_del(&old->bse_node);
> -			bl->bl_count--;
> -			kfree(old);
> -		}
> -	}
> -	dprintk("%s: after merging\n", __func__);
> -	print_clist(clist, bl->bl_count);
> -}
> -
> -/* Note the range described by offset, length is guaranteed to be contained
> - * within be.
> - * new will be freed, either by this function or add_to_commitlist if they
> - * decide not to use it, or after LAYOUTCOMMIT uses it in the commitlist.
> - */
> -int bl_mark_for_commit(struct pnfs_block_extent *be,
> -		    sector_t offset, sector_t length,
> -		    struct pnfs_block_short_extent *new)
> -{
> -	sector_t new_end, end = offset + length;
> -	struct pnfs_block_layout *bl = container_of(be->be_inval,
> -						    struct pnfs_block_layout,
> -						    bl_inval);
> -
> -	mark_written_sectors(be->be_inval, offset, length);
> -	/* We want to add the range to commit list, but it must be
> -	 * block-normalized, and verified that the normalized range has
> -	 * been entirely written to disk.
> -	 */
> -	new->bse_f_offset = offset;
> -	offset = normalize(offset, bl->bl_blocksize);
> -	if (offset < new->bse_f_offset) {
> -		if (is_range_written(be->be_inval, offset, new->bse_f_offset))
> -			new->bse_f_offset = offset;
> -		else
> -			new->bse_f_offset = offset + bl->bl_blocksize;
> -	}
> -	new_end = normalize_up(end, bl->bl_blocksize);
> -	if (end < new_end) {
> -		if (is_range_written(be->be_inval, end, new_end))
> -			end = new_end;
> -		else
> -			end = new_end - bl->bl_blocksize;
> -	}
> -	if (end <= new->bse_f_offset) {
> -		kfree(new);
> -		return 0;
> -	}
> -	new->bse_length = end - new->bse_f_offset;
> -	new->bse_devid = be->be_devid;
> -	new->bse_mdev = be->be_mdev;
> -
> -	spin_lock(&bl->bl_ext_lock);
> -	add_to_commitlist(bl, new);
> -	spin_unlock(&bl->bl_ext_lock);
> -	return 0;
> -}
> -
> -static void print_bl_extent(struct pnfs_block_extent *be)
> -{
> -	dprintk("PRINT EXTENT extent %p\n", be);
> -	if (be) {
> -		dprintk("        be_f_offset %llu\n", (u64)be->be_f_offset);
> -		dprintk("        be_length   %llu\n", (u64)be->be_length);
> -		dprintk("        be_v_offset %llu\n", (u64)be->be_v_offset);
> -		dprintk("        be_state    %d\n", be->be_state);
> -	}
> -}
> -
> -static void
> -destroy_extent(struct kref *kref)
> -{
> -	struct pnfs_block_extent *be;
> -
> -	be = container_of(kref, struct pnfs_block_extent, be_refcnt);
> -	dprintk("%s be=%p\n", __func__, be);
> -	kfree(be);
> -}
> -
> -void
> -bl_put_extent(struct pnfs_block_extent *be)
> -{
> -	if (be) {
> -		dprintk("%s enter %p (%i)\n", __func__, be,
> -			atomic_read(&be->be_refcnt.refcount));
> -		kref_put(&be->be_refcnt, destroy_extent);
> -	}
> -}
> -
> -struct pnfs_block_extent *bl_alloc_extent(void)
> -{
> -	struct pnfs_block_extent *be;
> -
> -	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
> -	if (!be)
> -		return NULL;
> -	INIT_LIST_HEAD(&be->be_node);
> -	kref_init(&be->be_refcnt);
> -	be->be_inval = NULL;
> -	return be;
> -}
> -
> -static void print_elist(struct list_head *list)
> -{
> -	struct pnfs_block_extent *be;
> -	dprintk("****************\n");
> -	dprintk("Extent list looks like:\n");
> -	list_for_each_entry(be, list, be_node) {
> -		print_bl_extent(be);
> -	}
> -	dprintk("****************\n");
> -}
> -
> -static inline int
> -extents_consistent(struct pnfs_block_extent *old, struct pnfs_block_extent *new)
> -{
> -	/* Note this assumes new->be_f_offset >= old->be_f_offset */
> -	return (new->be_state == old->be_state) &&
> -		((new->be_state == PNFS_BLOCK_NONE_DATA) ||
> -		 ((new->be_v_offset - old->be_v_offset ==
> -		   new->be_f_offset - old->be_f_offset) &&
> -		  new->be_mdev == old->be_mdev));
> -}
> -
> -/* Adds new to appropriate list in bl, modifying new and removing existing
> - * extents as appropriate to deal with overlaps.
> - *
> - * See bl_find_get_extent for list constraints.
> - *
> - * Refcount on new is already set.  If end up not using it, or error out,
> - * need to put the reference.
> - *
> - * bl->bl_ext_lock is held by caller.
> - */
> -int
> -bl_add_merge_extent(struct pnfs_block_layout *bl,
> -		     struct pnfs_block_extent *new)
> -{
> -	struct pnfs_block_extent *be, *tmp;
> -	sector_t end = new->be_f_offset + new->be_length;
> -	struct list_head *list;
> -
> -	dprintk("%s enter with be=%p\n", __func__, new);
> -	print_bl_extent(new);
> -	list = &bl->bl_extents[bl_choose_list(new->be_state)];
> -	print_elist(list);
> -
> -	/* Scan for proper place to insert, extending new to the left
> -	 * as much as possible.
> -	 */
> -	list_for_each_entry_safe_reverse(be, tmp, list, be_node) {
> -		if (new->be_f_offset >= be->be_f_offset + be->be_length)
> -			break;
> -		if (new->be_f_offset >= be->be_f_offset) {
> -			if (end <= be->be_f_offset + be->be_length) {
> -				/* new is a subset of existing be*/
> -				if (extents_consistent(be, new)) {
> -					dprintk("%s: new is subset, ignoring\n",
> -						__func__);
> -					bl_put_extent(new);
> -					return 0;
> -				} else {
> -					goto out_err;
> -				}
> -			} else {
> -				/* |<--   be   -->|
> -				 *          |<--   new   -->| */
> -				if (extents_consistent(be, new)) {
> -					/* extend new to fully replace be */
> -					new->be_length += new->be_f_offset -
> -						be->be_f_offset;
> -					new->be_f_offset = be->be_f_offset;
> -					new->be_v_offset = be->be_v_offset;
> -					dprintk("%s: removing %p\n", __func__, be);
> -					list_del(&be->be_node);
> -					bl_put_extent(be);
> -				} else {
> -					goto out_err;
> -				}
> -			}
> -		} else if (end >= be->be_f_offset + be->be_length) {
> -			/* new extent overlap existing be */
> -			if (extents_consistent(be, new)) {
> -				/* extend new to fully replace be */
> -				dprintk("%s: removing %p\n", __func__, be);
> -				list_del(&be->be_node);
> -				bl_put_extent(be);
> -			} else {
> -				goto out_err;
> -			}
> -		} else if (end > be->be_f_offset) {
> -			/*           |<--   be   -->|
> -			 *|<--   new   -->| */
> -			if (extents_consistent(new, be)) {
> -				/* extend new to fully replace be */
> -				new->be_length += be->be_f_offset + be->be_length -
> -					new->be_f_offset - new->be_length;
> -				dprintk("%s: removing %p\n", __func__, be);
> -				list_del(&be->be_node);
> -				bl_put_extent(be);
> -			} else {
> -				goto out_err;
> -			}
> -		}
> -	}
> -	/* Note that if we never hit the above break, be will not point to a
> -	 * valid extent.  However, in that case &be->be_node==list.
> -	 */
> -	list_add(&new->be_node, &be->be_node);
> -	dprintk("%s: inserting new\n", __func__);
> -	print_elist(list);
> -	/* FIXME - The per-list consistency checks have all been done,
> -	 * should now check cross-list consistency.
> -	 */
> -	return 0;
> -
> - out_err:
> -	bl_put_extent(new);
> -	return -EIO;
> -}
> -
> -/* Returns extent, or NULL.  If a second READ extent exists, it is returned
> - * in cow_read, if given.
> - *
> - * The extents are kept in two seperate ordered lists, one for READ and NONE,
> - * one for READWRITE and INVALID.  Within each list, we assume:
> - * 1. Extents are ordered by file offset.
> - * 2. For any given isect, there is at most one extents that matches.
> - */
> -struct pnfs_block_extent *
> -bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
> -	    struct pnfs_block_extent **cow_read)
> -{
> -	struct pnfs_block_extent *be, *cow, *ret;
> -	int i;
> -
> -	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
> -	cow = ret = NULL;
> -	spin_lock(&bl->bl_ext_lock);
> -	for (i = 0; i < EXTENT_LISTS; i++) {
> -		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
> -			if (isect >= be->be_f_offset + be->be_length)
> -				break;
> -			if (isect >= be->be_f_offset) {
> -				/* We have found an extent */
> -				dprintk("%s Get %p (%i)\n", __func__, be,
> -					atomic_read(&be->be_refcnt.refcount));
> -				kref_get(&be->be_refcnt);
> -				if (!ret)
> -					ret = be;
> -				else if (be->be_state != PNFS_BLOCK_READ_DATA)
> -					bl_put_extent(be);
> -				else
> -					cow = be;
> -				break;
> -			}
> -		}
> -		if (ret &&
> -		    (!cow_read || ret->be_state != PNFS_BLOCK_INVALID_DATA))
> -			break;
> -	}
> -	spin_unlock(&bl->bl_ext_lock);
> -	if (cow_read)
> -		*cow_read = cow;
> -	print_bl_extent(ret);
> -	return ret;
> -}
> -
> -/* Similar to bl_find_get_extent, but called with lock held, and ignores cow */
> -static struct pnfs_block_extent *
> -bl_find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
> -{
> -	struct pnfs_block_extent *be, *ret = NULL;
> -	int i;
> -
> -	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
> -	for (i = 0; i < EXTENT_LISTS; i++) {
> -		if (ret)
> -			break;
> -		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
> -			if (isect >= be->be_f_offset + be->be_length)
> -				break;
> -			if (isect >= be->be_f_offset) {
> -				/* We have found an extent */
> -				dprintk("%s Get %p (%i)\n", __func__, be,
> -					atomic_read(&be->be_refcnt.refcount));
> -				kref_get(&be->be_refcnt);
> -				ret = be;
> -				break;
> -			}
> -		}
> -	}
> -	print_bl_extent(ret);
> -	return ret;
> -}
> -
> -int
> -encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
> -			       struct xdr_stream *xdr,
> -			       const struct nfs4_layoutcommit_args *arg)
> -{
> -	struct pnfs_block_short_extent *lce, *save;
> -	unsigned int count = 0;
> -	__be32 *p, *xdr_start;
> -
> -	dprintk("%s enter\n", __func__);
> -	/* BUG - creation of bl_commit is buggy - need to wait for
> -	 * entire block to be marked WRITTEN before it can be added.
> -	 */
> -	spin_lock(&bl->bl_ext_lock);
> -	/* Want to adjust for possible truncate */
> -	/* We now want to adjust argument range */
> -
> -	/* XDR encode the ranges found */
> -	xdr_start = xdr_reserve_space(xdr, 8);
> -	if (!xdr_start)
> -		goto out;
> -	list_for_each_entry_safe(lce, save, &bl->bl_commit, bse_node) {
> -		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
> -		if (!p)
> -			break;
> -		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
> -		p = xdr_encode_hyper(p, lce->bse_f_offset << SECTOR_SHIFT);
> -		p = xdr_encode_hyper(p, lce->bse_length << SECTOR_SHIFT);
> -		p = xdr_encode_hyper(p, 0LL);
> -		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
> -		list_move_tail(&lce->bse_node, &bl->bl_committing);
> -		bl->bl_count--;
> -		count++;
> -	}
> -	xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
> -	xdr_start[1] = cpu_to_be32(count);
> -out:
> -	spin_unlock(&bl->bl_ext_lock);
> -	dprintk("%s found %i ranges\n", __func__, count);
> -	return 0;
> -}
> -
> -/* Helper function to set_to_rw that initialize a new extent */
> -static void
> -_prep_new_extent(struct pnfs_block_extent *new,
> -		 struct pnfs_block_extent *orig,
> -		 sector_t offset, sector_t length, int state)
> -{
> -	kref_init(&new->be_refcnt);
> -	/* don't need to INIT_LIST_HEAD(&new->be_node) */
> -	memcpy(&new->be_devid, &orig->be_devid, sizeof(struct nfs4_deviceid));
> -	new->be_mdev = orig->be_mdev;
> -	new->be_f_offset = offset;
> -	new->be_length = length;
> -	new->be_v_offset = orig->be_v_offset - orig->be_f_offset + offset;
> -	new->be_state = state;
> -	new->be_inval = orig->be_inval;
> -}
> -
> -/* Tries to merge be with extent in front of it in list.
> - * Frees storage if not used.
> - */
> -static struct pnfs_block_extent *
> -_front_merge(struct pnfs_block_extent *be, struct list_head *head,
> -	     struct pnfs_block_extent *storage)
> -{
> -	struct pnfs_block_extent *prev;
> -
> -	if (!storage)
> -		goto no_merge;
> -	if (&be->be_node == head || be->be_node.prev == head)
> -		goto no_merge;
> -	prev = list_entry(be->be_node.prev, struct pnfs_block_extent, be_node);
> -	if ((prev->be_f_offset + prev->be_length != be->be_f_offset) ||
> -	    !extents_consistent(prev, be))
> -		goto no_merge;
> -	_prep_new_extent(storage, prev, prev->be_f_offset,
> -			 prev->be_length + be->be_length, prev->be_state);
> -	list_replace(&prev->be_node, &storage->be_node);
> -	bl_put_extent(prev);
> -	list_del(&be->be_node);
> -	bl_put_extent(be);
> -	return storage;
> -
> - no_merge:
> -	kfree(storage);
> -	return be;
> -}
> -
> -static u64
> -set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
> -{
> -	u64 rv = offset + length;
> -	struct pnfs_block_extent *be, *e1, *e2, *e3, *new, *old;
> -	struct pnfs_block_extent *children[3];
> -	struct pnfs_block_extent *merge1 = NULL, *merge2 = NULL;
> -	int i = 0, j;
> -
> -	dprintk("%s(%llu, %llu)\n", __func__, offset, length);
> -	/* Create storage for up to three new extents e1, e2, e3 */
> -	e1 = kmalloc(sizeof(*e1), GFP_ATOMIC);
> -	e2 = kmalloc(sizeof(*e2), GFP_ATOMIC);
> -	e3 = kmalloc(sizeof(*e3), GFP_ATOMIC);
> -	/* BUG - we are ignoring any failure */
> -	if (!e1 || !e2 || !e3)
> -		goto out_nosplit;
> -
> -	spin_lock(&bl->bl_ext_lock);
> -	be = bl_find_get_extent_locked(bl, offset);
> -	rv = be->be_f_offset + be->be_length;
> -	if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
> -		spin_unlock(&bl->bl_ext_lock);
> -		goto out_nosplit;
> -	}
> -	/* Add e* to children, bumping e*'s krefs */
> -	if (be->be_f_offset != offset) {
> -		_prep_new_extent(e1, be, be->be_f_offset,
> -				 offset - be->be_f_offset,
> -				 PNFS_BLOCK_INVALID_DATA);
> -		children[i++] = e1;
> -		print_bl_extent(e1);
> -	} else
> -		merge1 = e1;
> -	_prep_new_extent(e2, be, offset,
> -			 min(length, be->be_f_offset + be->be_length - offset),
> -			 PNFS_BLOCK_READWRITE_DATA);
> -	children[i++] = e2;
> -	print_bl_extent(e2);
> -	if (offset + length < be->be_f_offset + be->be_length) {
> -		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
> -				 be->be_f_offset + be->be_length -
> -				 offset - length,
> -				 PNFS_BLOCK_INVALID_DATA);
> -		children[i++] = e3;
> -		print_bl_extent(e3);
> -	} else
> -		merge2 = e3;
> -
> -	/* Remove be from list, and insert the e* */
> -	/* We don't get refs on e*, since this list is the base reference
> -	 * set when init'ed.
> -	 */
> -	if (i < 3)
> -		children[i] = NULL;
> -	new = children[0];
> -	list_replace(&be->be_node, &new->be_node);
> -	bl_put_extent(be);
> -	new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge1);
> -	for (j = 1; j < i; j++) {
> -		old = new;
> -		new = children[j];
> -		list_add(&new->be_node, &old->be_node);
> -	}
> -	if (merge2) {
> -		/* This is a HACK, should just create a _back_merge function */
> -		new = list_entry(new->be_node.next,
> -				 struct pnfs_block_extent, be_node);
> -		new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge2);
> -	}
> -	spin_unlock(&bl->bl_ext_lock);
> -
> -	/* Since we removed the base reference above, be is now scheduled for
> -	 * destruction.
> -	 */
> -	bl_put_extent(be);
> -	dprintk("%s returns %llu after split\n", __func__, rv);
> -	return rv;
> -
> - out_nosplit:
> -	kfree(e1);
> -	kfree(e2);
> -	kfree(e3);
> -	dprintk("%s returns %llu without splitting\n", __func__, rv);
> -	return rv;
> -}
> -
> -void
> -clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
> -			      const struct nfs4_layoutcommit_args *arg,
> -			      int status)
> -{
> -	struct pnfs_block_short_extent *lce, *save;
> -
> -	dprintk("%s status %d\n", __func__, status);
> -	list_for_each_entry_safe(lce, save, &bl->bl_committing, bse_node) {
> -		if (likely(!status)) {
> -			u64 offset = lce->bse_f_offset;
> -			u64 end = offset + lce->bse_length;
> -
> -			do {
> -				offset = set_to_rw(bl, offset, end - offset);
> -			} while (offset < end);
> -			list_del(&lce->bse_node);
> -
> -			kfree(lce);
> -		} else {
> -			list_del(&lce->bse_node);
> -			spin_lock(&bl->bl_ext_lock);
> -			add_to_commitlist(bl, lce);
> -			spin_unlock(&bl->bl_ext_lock);
> -		}
> -	}
> -}
> -
> -int bl_push_one_short_extent(struct pnfs_inval_markings *marks)
> -{
> -	struct pnfs_block_short_extent *new;
> -
> -	new = kmalloc(sizeof(*new), GFP_NOFS);
> -	if (unlikely(!new))
> -		return -ENOMEM;
> -
> -	spin_lock_bh(&marks->im_lock);
> -	list_add(&new->bse_node, &marks->im_extents);
> -	spin_unlock_bh(&marks->im_lock);
> -
> -	return 0;
> -}
> -
> -struct pnfs_block_short_extent *
> -bl_pop_one_short_extent(struct pnfs_inval_markings *marks)
> -{
> -	struct pnfs_block_short_extent *rv = NULL;
> -
> -	spin_lock_bh(&marks->im_lock);
> -	if (!list_empty(&marks->im_extents)) {
> -		rv = list_entry((&marks->im_extents)->next,
> -				struct pnfs_block_short_extent, bse_node);
> -		list_del_init(&rv->bse_node);
> -	}
> -	spin_unlock_bh(&marks->im_lock);
> -
> -	return rv;
> -}
> -
> -void bl_free_short_extents(struct pnfs_inval_markings *marks, int num_to_free)
> -{
> -	struct pnfs_block_short_extent *se = NULL, *tmp;
> -
> -	if (num_to_free <= 0)
> -		return;
> -
> -	spin_lock(&marks->im_lock);
> -	list_for_each_entry_safe(se, tmp, &marks->im_extents, bse_node) {
> -		list_del(&se->bse_node);
> -		kfree(se);
> -		if (--num_to_free == 0)
> -			break;
> -	}
> -	spin_unlock(&marks->im_lock);
> -
> -	BUG_ON(num_to_free > 0);
> -}

