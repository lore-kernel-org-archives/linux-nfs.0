Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46540 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1FHCGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:06:37 -0400
Received: by vxi39 with SMTP id 39so38367vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 19:06:36 -0700 (PDT)
Message-ID: <4DEED92F.9000204@panasas.com>
Date: Tue, 07 Jun 2011 22:06:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 86/88] SQUASHME: pnfs: blocklayout: port block layout
 code
References: <cover.1307464381.git.rees@umich.edu> <8fd0c11c1b29638501ee0942da7475213b4c24aa.1307464382.git.rees@umich.edu>
In-Reply-To: <8fd0c11c1b29638501ee0942da7475213b4c24aa.1307464382.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-07 13:35, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> Make minimal changes to let block layout driver work in current framework.
> 
> Signed-off-by: Tang Haiying <tang_haiying@emc.com>
> Signed-off-by: Zhang Jingwang <jingwang.zhang@emc.com>
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  drivers/md/dm-ioctl.c               |   24 --------
>  drivers/scsi/hosts.c                |    3 +-
>  fs/nfs/blocklayout/blocklayout.c    |  105 ++++++++++------------------------
>  fs/nfs/blocklayout/blocklayout.h    |    9 +--
>  fs/nfs/blocklayout/blocklayoutdev.c |   34 ++++++++----
>  fs/nfs/blocklayout/extents.c        |   14 +----
>  fs/nfs/nfs4proc.c                   |    1 -
>  fs/nfs/nfs4xdr.c                    |    3 +-
>  fs/nfs/pnfs.c                       |    8 ++-
>  fs/nfs/pnfs.h                       |    1 +
>  include/linux/nfs_fs_sb.h           |    1 +
>  11 files changed, 69 insertions(+), 134 deletions(-)
> 
> diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> index d0d417e..4cacdad 100644
> --- a/drivers/md/dm-ioctl.c
> +++ b/drivers/md/dm-ioctl.c
> @@ -713,12 +713,6 @@ static int dev_create(struct dm_ioctl *param, size_t param_size)
>  	return 0;
>  }
>  
> -int dm_dev_create(struct dm_ioctl *param)
> -{
> -	return dev_create(param, sizeof(*param));
> -}
> -EXPORT_SYMBOL(dm_dev_create);
> -
>  /*
>   * Always use UUID for lookups if it's present, otherwise use name or dev.
>   */
> @@ -814,12 +808,6 @@ static int dev_remove(struct dm_ioctl *param, size_t param_size)
>  	return 0;
>  }
>  
> -int dm_dev_remove(struct dm_ioctl *param)
> -{
> -	return dev_remove(param, sizeof(*param));
> -}
> -EXPORT_SYMBOL(dm_dev_remove);
> -
>  /*
>   * Check a string doesn't overrun the chunk of
>   * memory we copied from userland.
> @@ -1002,12 +990,6 @@ static int do_resume(struct dm_ioctl *param)
>  	return r;
>  }
>  
> -int dm_do_resume(struct dm_ioctl *param)
> -{
> -	return do_resume(param);
> -}
> -EXPORT_SYMBOL(dm_do_resume);
> -
>  /*
>   * Set or unset the suspension state of a device.
>   * If the device already is in the requested state we just return its status.
> @@ -1274,12 +1256,6 @@ out:
>  	return r;
>  }
>  
> -int dm_table_load(struct dm_ioctl *param, size_t param_size)
> -{
> -	return table_load(param, param_size);
> -}
> -EXPORT_SYMBOL(dm_table_load);
> -
>  static int table_clear(struct dm_ioctl *param, size_t param_size)
>  {
>  	struct hash_cell *hc;
> diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
> index 7d91903..4f7a582 100644
> --- a/drivers/scsi/hosts.c
> +++ b/drivers/scsi/hosts.c
> @@ -50,11 +50,10 @@ static void scsi_host_cls_release(struct device *dev)
>  	put_device(&class_to_shost(dev)->shost_gendev);
>  }
>  
> -struct class shost_class = {
> +static struct class shost_class = {
>  	.name		= "scsi_host",
>  	.dev_release	= scsi_host_cls_release,
>  };
> -EXPORT_SYMBOL(shost_class);
>  
>  /**
>   *	scsi_host_set_state - Take the given host through the host state model.
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 2583b87..d842ec8 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -97,14 +97,6 @@ dont_like_caller(struct nfs_page *req)
>  	}
>  }
>  
> -static enum pnfs_try_status
> -bl_commit(struct nfs_write_data *nfs_data,
> -	  int sync)
> -{
> -	dprintk("%s enter\n", __func__);
> -	return PNFS_NOT_ATTEMPTED;
> -}
> -
>  /* The data we are handed might be spread across several bios.  We need
>   * to track when the last one is finished.
>   */
> @@ -198,7 +190,7 @@ static void bl_read_cleanup(struct work_struct *work)
>  	dprintk("%s enter\n", __func__);
>  	task = container_of(work, struct rpc_task, u.tk_work);
>  	rdata = container_of(task, struct nfs_read_data, task);
> -	pnfs_read_done(rdata);
> +	pnfs_ld_read_done(rdata);
>  }
>  
>  static void
> @@ -219,8 +211,7 @@ static void bl_rpc_do_nothing(struct rpc_task *task, void *calldata)
>  }
>  
>  static enum pnfs_try_status
> -bl_read_pagelist(struct nfs_read_data *rdata,
> -		 unsigned nr_pages)
> +bl_read_pagelist(struct nfs_read_data *rdata)
>  {
>  	int i, hole;
>  	struct bio *bio = NULL;
> @@ -233,13 +224,13 @@ bl_read_pagelist(struct nfs_read_data *rdata,
>  	int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
>  
>  	dprintk("%s enter nr_pages %u offset %lld count %Zd\n", __func__,
> -	       nr_pages, f_offset, count);
> +	       rdata->npages, f_offset, count);
>  
>  	if (dont_like_caller(rdata->req)) {
>  		dprintk("%s dont_like_caller failed\n", __func__);
>  		goto use_mds;
>  	}
> -	if ((nr_pages == 1) && PagePnfsErr(rdata->req->wb_page)) {
> +	if ((rdata->npages == 1) && PagePnfsErr(rdata->req->wb_page)) {
>  		/* We want to fall back to mds in case of read_page
>  		 * after error on read_pages.
>  		 */
> @@ -249,21 +240,21 @@ bl_read_pagelist(struct nfs_read_data *rdata,
>  	par = alloc_parallel(rdata);
>  	if (!par)
>  		goto use_mds;
> -	par->call_ops = *rdata->pdata.call_ops;
> +	par->call_ops = *rdata->mds_ops;
>  	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
>  	par->pnfs_callback = bl_end_par_io_read;
>  	/* At this point, we can no longer jump to use_mds */
>  
>  	isect = (sector_t) (f_offset >> 9);
>  	/* Code assumes extents are page-aligned */
> -	for (i = pg_index; i < nr_pages; i++) {
> +	for (i = pg_index; i < rdata->npages; i++) {
>  		if (!extent_length) {
>  			/* We've used up the previous extent */
>  			put_extent(be);
>  			put_extent(cow_read);
>  			bio = bl_submit_bio(READ, bio);
>  			/* Get the next one */
> -			be = find_get_extent(BLK_LSEG2EXT(rdata->pdata.lseg),
> +			be = find_get_extent(BLK_LSEG2EXT(rdata->lseg),
>  					     isect, &cow_read);
>  			if (!be) {
>  				/* Error out this page */
> @@ -293,7 +284,7 @@ bl_read_pagelist(struct nfs_read_data *rdata,
>  			be_read = (hole && cow_read) ? cow_read : be;
>  			for (;;) {
>  				if (!bio) {
> -					bio = bio_alloc(GFP_NOIO, nr_pages - i);
> +					bio = bio_alloc(GFP_NOIO, rdata->npages - i);
>  					if (!bio) {
>  						/* Error out this page */
>  						bl_done_with_rpage(pages[i], 0);
> @@ -407,10 +398,10 @@ static void bl_write_cleanup(struct work_struct *work)
>  		/* BUG - this should be called after each bio, not after
>  		 * all finish, unless have some way of storing success/failure
>  		 */
> -		mark_extents_written(BLK_LSEG2EXT(wdata->pdata.lseg),
> +		mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
>  				     wdata->args.offset, wdata->args.count);
>  	}
> -	pnfs_writeback_done(wdata);
> +	pnfs_ld_write_done(wdata);
>  }
>  
>  /* Called when last of bios associated with a bl_write_pagelist call finishes */
> @@ -428,7 +419,6 @@ bl_end_par_io_write(void *data)
>  
>  static enum pnfs_try_status
>  bl_write_pagelist(struct nfs_write_data *wdata,
> -		  unsigned nr_pages,
>  		  int sync)
>  {
>  	int i;
> @@ -442,7 +432,7 @@ bl_write_pagelist(struct nfs_write_data *wdata,
>  	int pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
>  
>  	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
> -	if (!wdata->req->wb_lseg) {
> +	if (!wdata->lseg) {
>  		dprintk("%s no lseg, falling back to MDS\n", __func__);
>  		return PNFS_NOT_ATTEMPTED;
>  	}
> @@ -460,19 +450,19 @@ bl_write_pagelist(struct nfs_write_data *wdata,
>  	par = alloc_parallel(wdata);
>  	if (!par)
>  		return PNFS_NOT_ATTEMPTED;
> -	par->call_ops = *wdata->pdata.call_ops;
> +	par->call_ops = *wdata->mds_ops;
>  	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
>  	par->pnfs_callback = bl_end_par_io_write;
>  	/* At this point, have to be more careful with error handling */
>  
>  	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> 9);
> -	for (i = pg_index; i < nr_pages; i++) {
> +	for (i = pg_index; i < wdata->npages ; i++) {
>  		if (!extent_length) {
>  			/* We've used up the previous extent */
>  			put_extent(be);
>  			bio = bl_submit_bio(WRITE, bio);
>  			/* Get the next one */
> -			be = find_get_extent(BLK_LSEG2EXT(wdata->pdata.lseg),
> +			be = find_get_extent(BLK_LSEG2EXT(wdata->lseg),
>  					     isect, NULL);
>  			if (!be || !is_writable(be, isect)) {
>  				/* FIXME */
> @@ -484,7 +474,7 @@ bl_write_pagelist(struct nfs_write_data *wdata,
>  		}
>  		for (;;) {
>  			if (!bio) {
> -				bio = bio_alloc(GFP_NOIO, nr_pages - i);
> +				bio = bio_alloc(GFP_NOIO, wdata->npages - i);
>  				if (!bio) {
>  					/* Error out this page */
>  					/* FIXME */
> @@ -504,7 +494,12 @@ bl_write_pagelist(struct nfs_write_data *wdata,
>  		isect += PAGE_CACHE_SIZE >> 9;
>  		extent_length -= PAGE_CACHE_SIZE >> 9;
>  	}
> -	wdata->res.count = (isect << 9) - (offset & (long)PAGE_CACHE_MASK);
> +	wdata->res.count = (isect << 9) - (offset);
> +	if (count < wdata->res.count) {
> +		wdata->res.count = count;
> +	}
> +	/* pnfs_set_layoutcommit needs this */
> +	wdata->mds_offset = offset;
>  	put_extent(be);
>  	bl_submit_bio(WRITE, bio);
>  	put_parallel(par);
> @@ -557,18 +552,19 @@ bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
>  }
>  
>  static struct pnfs_layout_hdr *
> -bl_alloc_layout_hdr(struct inode *inode)
> +bl_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
>  {
>  	struct pnfs_block_layout	*bl;
>  
>  	dprintk("%s enter\n", __func__);
> -	bl = kzalloc(sizeof(*bl), GFP_KERNEL);
> +	bl = kzalloc(sizeof(*bl), gfp_flags);
>  	if (!bl)
>  		return NULL;
>  	spin_lock_init(&bl->bl_ext_lock);
>  	INIT_LIST_HEAD(&bl->bl_extents[0]);
>  	INIT_LIST_HEAD(&bl->bl_extents[1]);
>  	INIT_LIST_HEAD(&bl->bl_commit);
> +	INIT_LIST_HEAD(&bl->bl_committing);
>  	bl->bl_count = 0;
>  	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
>  	INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
> @@ -590,16 +586,16 @@ bl_free_lseg(struct pnfs_layout_segment *lseg)
>   */
>  static struct pnfs_layout_segment *
>  bl_alloc_lseg(struct pnfs_layout_hdr *lo,
> -	      struct nfs4_layoutget_res *lgr)
> +	      struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
>  {
>  	struct pnfs_layout_segment *lseg;
>  	int status;
>  
>  	dprintk("%s enter\n", __func__);
> -	lseg = kzalloc(sizeof(*lseg) + 0, GFP_KERNEL);
> +	lseg = kzalloc(sizeof(*lseg) + 0, gfp_flags);
>  	if (!lseg)
>  		return NULL;
> -	status = nfs4_blk_process_layoutget(lo, lgr);
> +	status = nfs4_blk_process_layoutget(lo, lgr, gfp_flags);
>  	if (status) {
>  		/* We don't want to call the full-blown bl_free_lseg,
>  		 * since on error extents were not touched.
> @@ -615,34 +611,6 @@ bl_alloc_lseg(struct pnfs_layout_hdr *lo,
>  	return lseg;
>  }
>  
> -static int
> -bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
> -		      struct nfs4_layoutcommit_args *arg)
> -{
> -	struct nfs_server *nfss = NFS_SERVER(lo->plh_inode);
> -	struct bl_layoutupdate_data *layoutupdate_data;
> -
> -	dprintk("%s enter\n", __func__);
> -	/* Need to ensure commit is block-size aligned */
> -	if (nfss->pnfs_blksize) {
> -		u64 mask = nfss->pnfs_blksize - 1;
> -		u64 offset = arg->range.offset & mask;
> -
> -		arg->range.offset -= offset;
> -		arg->range.length += offset + mask;
> -		arg->range.length &= ~mask;
> -	}
> -
> -	layoutupdate_data = kmalloc(sizeof(struct bl_layoutupdate_data),
> -					 GFP_KERNEL);
> -	if (unlikely(!layoutupdate_data))
> -		return -ENOMEM;
> -	INIT_LIST_HEAD(&layoutupdate_data->ranges);
> -	arg->layoutdriver_data = layoutupdate_data;
> -
> -	return 0;
> -}
> -
>  static void
>  bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
>  		       const struct nfs4_layoutcommit_args *arg)
> @@ -657,7 +625,6 @@ bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
>  {
>  	dprintk("%s enter\n", __func__);
>  	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args, lcdata->res.status);
> -	kfree(lcdata->args.layoutdriver_data);
>  }
>  
>  static void free_blk_mountid(struct block_mount_id *mid)
> @@ -1085,25 +1052,16 @@ bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
>  	fsdata->private = NULL;
>  }
>  
> -/* This is called by nfs_can_coalesce_requests via nfs_pageio_do_add_request.
> - * Should return False if there is a reason requests can not be coalesced,
> - * otherwise, should default to returning True.
> - */
> -static int
> +static bool
>  bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> -	   struct nfs_page *req)
> +		   struct nfs_page *req)
>  {
> -	dprintk("%s enter\n", __func__);
> -	if (pgio->pg_iswrite)
> -		return prev->wb_lseg == req->wb_lseg;
> -	else
> -		return 1;
> +	return pnfs_generic_pg_test(pgio, prev, req);
>  }
>  
>  static struct pnfs_layoutdriver_type blocklayout_type = {
>  	.id = LAYOUT_BLOCK_VOLUME,
>  	.name = "LAYOUT_BLOCK_VOLUME",
> -	.commit				= bl_commit,
>  	.read_pagelist			= bl_read_pagelist,
>  	.write_pagelist			= bl_write_pagelist,
>  	.write_begin			= bl_write_begin,
> @@ -1113,12 +1071,11 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>  	.free_layout_hdr		= bl_free_layout_hdr,
>  	.alloc_lseg			= bl_alloc_lseg,
>  	.free_lseg			= bl_free_lseg,
> -	.setup_layoutcommit		= bl_setup_layoutcommit,
>  	.encode_layoutcommit		= bl_encode_layoutcommit,
>  	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
>  	.set_layoutdriver		= bl_set_layoutdriver,
>  	.clear_layoutdriver		= bl_clear_layoutdriver,
> -	.pg_test			= bl_pg_test,
> +	.pg_test                        = bl_pg_test,

Why not just set pg_test to pnfs_generic_pg_test?

Benny

>  };
>  
>  static int __init nfs4blocklayout_init(void)
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index a8198ae..dd596d4 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -33,7 +33,6 @@
>  #define FS_NFS_NFS4BLOCKLAYOUT_H
>  
>  #include <linux/nfs_fs.h>
> -#include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
>  #include "../pnfs.h"
>  
>  #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
> @@ -43,11 +42,6 @@
>  #define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
>  #define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
>  
> -extern int dm_dev_create(struct dm_ioctl *param); /* from dm-ioctl.c */
> -extern int dm_dev_remove(struct dm_ioctl *param); /* from dm-ioctl.c */
> -extern int dm_do_resume(struct dm_ioctl *param);
> -extern int dm_table_load(struct dm_ioctl *param, size_t param_size);
> -
>  struct block_mount_id {
>  	spinlock_t			bm_lock;    /* protects list */
>  	struct list_head		bm_devlist; /* holds pnfs_block_dev */
> @@ -180,6 +174,7 @@ struct pnfs_block_layout {
>  	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
>  	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
>  	struct list_head	bl_commit;	/* Needs layout commit */
> +	struct list_head	bl_committing;	/* Layout committing */
>  	unsigned int		bl_count;	/* entries in bl_commit */
>  	sector_t		bl_blocksize;  /* Server blocksize in sectors */
>  };
> @@ -257,7 +252,7 @@ struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
>  					      struct pnfs_device *dev,
>  					      struct list_head *sdlist);
>  int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
> -			       struct nfs4_layoutget_res *lgr);
> +			       struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
>  int nfs4_blk_create_block_disk_list(struct list_head *);
>  void nfs4_blk_destroy_disk_list(struct list_head *);
>  /* blocklayoutdm.c */
> diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
> index 23469e3..a90eb6b 100644
> --- a/fs/nfs/blocklayout/blocklayoutdev.c
> +++ b/fs/nfs/blocklayout/blocklayoutdev.c
> @@ -231,14 +231,16 @@ static int verify_extent(struct pnfs_block_extent *be,
>  /* XDR decode pnfs_block_layout4 structure */
>  int
>  nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
> -			   struct nfs4_layoutget_res *lgr)
> +			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
>  {
>  	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
> -	uint32_t *p = (uint32_t *)lgr->layout.buf;
> -	uint32_t *end = (uint32_t *)((char *)lgr->layout.buf + lgr->layout.len);
>  	int i, status = -EIO;
>  	uint32_t count;
>  	struct pnfs_block_extent *be = NULL, *save;
> +	struct xdr_stream stream;
> +	struct xdr_buf buf;
> +	struct page *scratch;
> +	__be32 *p;
>  	uint64_t tmp; /* Used by READSECTOR */
>  	struct layout_verification lv = {
>  		.mode = lgr->range.iomode,
> @@ -246,14 +248,27 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  		.inval = lgr->range.offset >> 9,
>  		.cowread = lgr->range.offset >> 9,
>  	};
> -
>  	LIST_HEAD(extents);
>  
> -	BLK_READBUF(p, end, 4);
> +	dprintk("---> %s\n", __func__);
> +
> +	scratch = alloc_page(gfp_flags);
> +	if (!scratch)
> +		return -ENOMEM;
> +
> +	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages, lgr->layoutp->len);
> +	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
> +
> +	p = xdr_inline_decode(&stream, 4);
> +	if (unlikely(!p))
> +		goto out_err;
> +
>  	READ32(count);
>  
>  	dprintk("%s enter, number of extents %i\n", __func__, count);
> -	BLK_READBUF(p, end, (28 + NFS4_DEVICEID4_SIZE) * count);
> +	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
> +	if (unlikely(!p))
> +		goto out_err;
>  
>  	/* Decode individual extents, putting them in temporary
>  	 * staging area until whole layout is decoded to make error
> @@ -269,6 +284,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  		be->be_mdev = translate_devid(lo, &be->be_devid);
>  		if (!be->be_mdev)
>  			goto out_err;
> +
>  		/* The next three values are read in as bytes,
>  		 * but stored as 512-byte sector lengths
>  		 */
> @@ -284,11 +300,6 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  		}
>  		list_add_tail(&be->be_node, &extents);
>  	}
> -	if (p != end) {
> -		dprintk("%s Undecoded cruft at end of opaque\n", __func__);
> -		be = NULL;
> -		goto out_err;
> -	}
>  	if (lgr->range.offset + lgr->range.length != lv.start << 9) {
>  		dprintk("%s Final length mismatch\n", __func__);
>  		be = NULL;
> @@ -319,6 +330,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  	spin_unlock(&bl->bl_ext_lock);
>  	status = 0;
>   out:
> +	__free_page(scratch);
>  	dprintk("%s returns %i\n", __func__, status);
>  	return status;
>  
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> index 40dff82..08413ec 100644
> --- a/fs/nfs/blocklayout/extents.c
> +++ b/fs/nfs/blocklayout/extents.c
> @@ -232,7 +232,7 @@ _range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
>  			if ((pos->it_sector == end - tree->mtt_step_size) &&
>  			    (pos->it_tags & (1 << tag))) {
>  				expect = pos->it_sector - tree->mtt_step_size;
> -				if (expect < start)
> +				if (pos->it_sector < tree->mtt_step_size || expect < start)
>  					return 1;
>  				continue;
>  			} else {
> @@ -740,19 +740,12 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
>  			       struct xdr_stream *xdr,
>  			       const struct nfs4_layoutcommit_args *arg)
>  {
> -	sector_t start, end;
>  	struct pnfs_block_short_extent *lce, *save;
>  	unsigned int count = 0;
> -	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
> -	struct list_head *ranges = &bld->ranges;
> +	struct list_head *ranges = &bl->bl_committing;
>  	__be32 *p, *xdr_start;
>  
>  	dprintk("%s enter\n", __func__);
> -	start = arg->range.offset >> 9;
> -	end = start + (arg->range.length >> 9);
> -	dprintk("%s set start=%llu, end=%llu\n",
> -		__func__, (u64)start, (u64)end);
> -
>  	/* BUG - creation of bl_commit is buggy - need to wait for
>  	 * entire block to be marked WRITTEN before it can be added.
>  	 */
> @@ -925,11 +918,10 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
>  			      const struct nfs4_layoutcommit_args *arg,
>  			      int status)
>  {
> -	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
>  	struct pnfs_block_short_extent *lce, *save;
>  
>  	dprintk("%s status %d\n", __func__, status);
> -	list_for_each_entry_safe_reverse(lce, save, &bld->ranges, bse_node) {
> +	list_for_each_entry_safe_reverse(lce, save, &bl->bl_committing, bse_node) {
>  		if (likely(!status)) {
>  			u64 offset = lce->bse_f_offset;
>  			u64 end = offset + lce->bse_length;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index a693283..987260c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5788,7 +5788,6 @@ static int _nfs4_getdevicelist(struct nfs_server *server,
>  
>  	dprintk("--> %s\n", __func__);
>  	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
> -	put_rpccred(msg.rpc_cred);
>  	dprintk("<-- %s status=%d\n", __func__, status);
>  	return status;
>  }
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index e059dc8..73f18f4 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1963,7 +1963,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
>  	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
>  	/* Only whole file layouts */
>  	p = xdr_encode_hyper(p, 0); /* offset */
> -	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
> +	p = xdr_encode_hyper(p, args->lastbytewritten+1); /* length */
>  	*p++ = cpu_to_be32(0); /* reclaim */
>  	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
>  	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
> @@ -5467,7 +5467,6 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
>  	int status;
>  
>  	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
> -	res->status = status;
>  	if (status)
>  		return status;
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index c88a8ee..9920bff 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -898,8 +898,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
>  			ret = get_lseg(lseg);
>  			break;
>  		}
> -		if (cmp_layout(range, &lseg->pls_range) > 0)
> -			break;
>  	}
>  
>  	dprintk("%s:Return lseg %p ref %d\n",
> @@ -1252,6 +1250,7 @@ static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
>  		}
>  	}
>  	rv->pls_end_pos = max_pos;
> +	dprintk("%s: lseg %p end_pos %llu\n", __func__, rv, rv->pls_end_pos);
>  
>  	return rv;
>  }
> @@ -1261,6 +1260,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  {
>  	struct nfs_inode *nfsi = NFS_I(wdata->inode);
>  	loff_t end_pos = wdata->mds_offset + wdata->res.count;
> +	loff_t isize = i_size_read(wdata->inode);
>  	bool mark_as_dirty = false;
>  
>  	spin_lock(&nfsi->vfs_inode.i_lock);
> @@ -1274,9 +1274,13 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  		dprintk("%s: Set layoutcommit for inode %lu ",
>  			__func__, wdata->inode->i_ino);
>  	}
> +	if (end_pos > isize)
> +		end_pos = isize;
>  	if (end_pos > wdata->lseg->pls_end_pos)
>  		wdata->lseg->pls_end_pos = end_pos;
>  	spin_unlock(&nfsi->vfs_inode.i_lock);
> +	dprintk("%s: lseg %p end_pos %llu\n",
> +		__func__, wdata->lseg, wdata->lseg->pls_end_pos);
>  
>  	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
>  	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index b50cf3a..28d57c9 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -156,6 +156,7 @@ struct pnfs_device {
>  	unsigned int  layout_type;
>  	unsigned int  mincount;
>  	struct page **pages;
> +	void          *area;
>  	unsigned int  pgbase;
>  	unsigned int  pglen;
>  };
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 3d93ada..79cc4ca 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -143,6 +143,7 @@ struct nfs_server {
>  						   filesystem */
>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
>  	struct rpc_wait_queue	roc_rpcwaitq;
> +	void			*pnfs_ld_data; /* per mount point data */
>  	u32			pnfs_blksize; /* layout_blksize attr */
>  
>  	/* the following fields are protected by nfs_client->cl_lock */
