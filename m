Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47867 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaIKOQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 10:16:59 -0400
Message-ID: <5411AED8.4020204@Netapp.com>
Date: Thu, 11 Sep 2014 10:16:56 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] pnfs/blocklayout: allocate separate pages for the
 layoutcommit payload
References: <1410395791-2385-1-git-send-email-hch@lst.de> <1410395791-2385-4-git-send-email-hch@lst.de>
In-Reply-To: <1410395791-2385-4-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/10/2014 08:36 PM, Christoph Hellwig wrote:
> Instead of overflowing the XDR send buffer with our extent list allocate
> pages and pre-encode the layoutupdate payload into them.  We optimistically
> allocate a single page use alloc_page and only switch to vmalloc when we
> have more extents outstanding.  Currently there is only a single testcase
> (xfstests generic/113) which can reproduce large enough extent lists for
> this to occur.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c |  15 ++----
>  fs/nfs/blocklayout/blocklayout.h |   8 ++--
>  fs/nfs/blocklayout/extent_tree.c | 100 +++++++++++++++++++++++++++++++--------
>  3 files changed, 90 insertions(+), 33 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 25ba9e0..900eb09 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -500,21 +500,16 @@ bl_return_range(struct pnfs_layout_hdr *lo,
>  	err = ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
>  }
>  
> -static void
> -bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
> -		       const struct nfs4_layoutcommit_args *arg)
> +static int
> +bl_prepare_layoutcommit(struct nfs4_layoutcommit_args *arg)
>  {
> -	dprintk("%s enter\n", __func__);
> -	ext_tree_encode_commit(BLK_LO2EXT(lo), xdr);
> +	return ext_tree_prepare_commit(arg);
>  }
>  
>  static void
>  bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
>  {
> -	struct pnfs_layout_hdr *lo = NFS_I(lcdata->args.inode)->layout;
> -
> -	dprintk("%s enter\n", __func__);
> -	ext_tree_mark_committed(BLK_LO2EXT(lo), lcdata->res.status);
> +	ext_tree_mark_committed(&lcdata->args, lcdata->res.status);
>  }
>  
>  static int
> @@ -670,7 +665,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>  	.alloc_lseg			= bl_alloc_lseg,
>  	.free_lseg			= bl_free_lseg,
>  	.return_range			= bl_return_range,
> -	.encode_layoutcommit		= bl_encode_layoutcommit,
> +	.prepare_layoutcommit		= bl_prepare_layoutcommit,
>  	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
>  	.set_layoutdriver		= bl_set_layoutdriver,
>  	.alloc_deviceid_node		= bl_alloc_deviceid_node,
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 19fae5e..9757f3e 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -72,6 +72,9 @@ struct pnfs_block_extent {
>  	unsigned int	be_tag;
>  };
>  
> +/* on the wire size of the extent */
> +#define BL_EXTENT_SIZE	(7 * sizeof(__be32) + NFS4_DEVICEID4_SIZE)
> +
>  struct pnfs_block_layout {
>  	struct pnfs_layout_hdr	bl_layout;
>  	struct rb_root		bl_ext_rw;
> @@ -129,8 +132,7 @@ int ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
>  		sector_t len);
>  bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
>  		struct pnfs_block_extent *ret, bool rw);
> -int ext_tree_encode_commit(struct pnfs_block_layout *bl,
> -		struct xdr_stream *xdr);
> -void ext_tree_mark_committed(struct pnfs_block_layout *bl, int status);
> +int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
> +void ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status);
>  
>  #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
> diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
> index 43e891b..2a2c261 100644
> --- a/fs/nfs/blocklayout/extent_tree.c
> +++ b/fs/nfs/blocklayout/extent_tree.c
> @@ -462,19 +462,25 @@ out:
>  	return err;
>  }
>  
> -int
> -ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
> +static void ext_tree_free_commitdata(struct nfs4_layoutcommit_args *arg,
> +		size_t buffer_size)
>  {
> -	struct pnfs_block_extent *be;
> -	unsigned int count = 0;
> -	__be32 *p, *xdr_start;
> -	int ret = 0;
> +	if (arg->layoutupdate_pages != &arg->layoutupdate_page) {
> +		int nr_pages = DIV_ROUND_UP(buffer_size, PAGE_SIZE), i;
>  
> -	dprintk("%s enter\n", __func__);
> +		for (i = 0; i < nr_pages; i++)
> +			put_page(arg->layoutupdate_pages[i]);
> +		kfree(arg->layoutupdate_pages);
> +	} else {
> +		put_page(arg->layoutupdate_page);
> +	}
> +}
>  
> -	xdr_start = xdr_reserve_space(xdr, 8);
> -	if (!xdr_start)
> -		return -ENOSPC;
> +static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
> +		size_t buffer_size, size_t *count)
> +{
> +	struct pnfs_block_extent *be;
> +	int ret = 0;
>  
>  	spin_lock(&bl->bl_ext_lock);
>  	for (be = ext_tree_first(&bl->bl_ext_rw); be; be = ext_tree_next(be)) {
> @@ -482,12 +488,11 @@ ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
>  		    be->be_tag != EXTENT_WRITTEN)
>  			continue;
>  
> -		p = xdr_reserve_space(xdr, 7 * sizeof(__be32) +
> -					NFS4_DEVICEID4_SIZE);
> -		if (!p) {
> -			printk("%s: out of space for extent list\n", __func__);
> +		(*count)++;
> +		if (*count * BL_EXTENT_SIZE > buffer_size) {
> +			/* keep counting.. */
>  			ret = -ENOSPC;
> -			break;
> +			continue;
>  		}
>  
>  		p = xdr_encode_opaque_fixed(p, be->be_device->deviceid.data,
> @@ -498,25 +503,80 @@ ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
>  		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
>  
>  		be->be_tag = EXTENT_COMMITTING;
> -		count++;
>  	}
>  	spin_unlock(&bl->bl_ext_lock);
>  
> -	xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
> -	xdr_start[1] = cpu_to_be32(count);
> +	return ret;
> +}
> +
> +int
> +ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg)
> +{
> +	struct pnfs_block_layout *bl = BLK_LO2EXT(NFS_I(arg->inode)->layout);
> +	size_t count = 0, buffer_size = PAGE_SIZE;
> +	__be32 *start_p;
> +	int ret;
> +
> +	dprintk("%s enter\n", __func__);
> +
> +	arg->layoutupdate_page = alloc_page(GFP_NOFS);
> +	if (!arg->layoutupdate_page)
> +		return -ENOMEM;
> +	start_p = page_address(arg->layoutupdate_page);
> +	arg->layoutupdate_pages = &arg->layoutupdate_page;
> +
> +retry:
> +	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
> +	if (unlikely(ret)) {
> +		ext_tree_free_commitdata(arg, buffer_size);
> +
> +		buffer_size = sizeof(__be32) + BL_EXTENT_SIZE * count;
> +		count = 0;
> +
> +		arg->layoutupdate_pages =
> +			kcalloc(DIV_ROUND_UP(buffer_size, PAGE_SIZE),
> +				sizeof(struct page *), GFP_NOFS);

I don't think I've seen kcalloc() before.  What does it do?

> +		if (!arg->layoutupdate_pages)
> +			return -ENOMEM;
> +
> +		start_p = __vmalloc(buffer_size, GFP_NOFS, PAGE_KERNEL);
> +		if (!start_p) {
> +			kfree(arg->layoutupdate_pages);
> +			return -ENOMEM;
> +		}
> +
> +		goto retry;
> +	}
> +
> +	*start_p = cpu_to_be32(count);
> +	arg->layoutupdate_len = sizeof(__be32) + BL_EXTENT_SIZE * count;
> +
> +	if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
> +		__be32 *p = start_p;
> +		int i = 0;
> +
> +		for (p = start_p;
> +		     p < start_p + arg->layoutupdate_len;
> +		     p += PAGE_SIZE) {
> +			arg->layoutupdate_pages[i++] = vmalloc_to_page(p);
> +		}
> +	}
>  
>  	dprintk("%s found %i ranges\n", __func__, count);

I'm getting this:

fs/nfs/blocklayout/extent_tree.c: In function ‘ext_tree_prepare_commit’:
fs/nfs/blocklayout/extent_tree.c:565:2: warning: format ‘%i’ expects argument of type ‘int’, but argument 3 has type ‘size_t’ [-Wformat=]
  dprintk("%s found %i ranges\n", __func__, count);

Anna
> -	return ret;
> +	return 0;
>  }
>  
>  void
> -ext_tree_mark_committed(struct pnfs_block_layout *bl, int status)
> +ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status)
>  {
> +	struct pnfs_block_layout *bl = BLK_LO2EXT(NFS_I(arg->inode)->layout);
>  	struct rb_root *root = &bl->bl_ext_rw;
>  	struct pnfs_block_extent *be;
>  
>  	dprintk("%s status %d\n", __func__, status);
>  
> +	ext_tree_free_commitdata(arg, arg->layoutupdate_len);
> +
>  	spin_lock(&bl->bl_ext_lock);
>  	for (be = ext_tree_first(root); be; be = ext_tree_next(be)) {
>  		if (be->be_state != PNFS_BLOCK_INVALID_DATA ||

