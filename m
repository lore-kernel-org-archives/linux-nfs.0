Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54319 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab2HLSao (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Aug 2012 14:30:44 -0400
Message-ID: <5027F63F.8070107@panasas.com>
Date: Sun, 12 Aug 2012 21:30:23 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH RFC 2/3] NFS41: send real write size in layoutget
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com> <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/08/2012 05:03 AM, Peng Tao wrote:

> From: Peng Tao <tao.peng@emc.com>
> 
> For bufferred write, scan dirty pages to find out longest continuous
> dirty pages. In this case, also allow layout driver to specify a
> maximum layoutget size which is useful to avoid busy scanning dirty pages
> for block layout client.
> 
> For direct write, just use dreq->bytes_left.
> 
> Signed-off-by: Peng Tao <tao.peng@emc.com>
> ---
>  fs/nfs/direct.c   |    7 ++++++
>  fs/nfs/internal.h |    1 +
>  fs/nfs/pnfs.c     |   58 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 64 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index c39f775..c1899dd 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -46,6 +46,7 @@
>  #include <linux/kref.h>
>  #include <linux/slab.h>
>  #include <linux/task_io_accounting_ops.h>
> +#include <linux/module.h>
>  
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
> @@ -191,6 +192,12 @@ static void nfs_direct_req_release(struct nfs_direct_req *dreq)
>  	kref_put(&dreq->kref, nfs_direct_req_free);
>  }
>  
> +ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq)
> +{
> +	return dreq->bytes_left;
> +}
> +EXPORT_SYMBOL_GPL(nfs_dreq_bytes_left);
> +
>  /*
>   * Collects and returns the final error value/byte-count.
>   */
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 31fdb03..e68d329 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -464,6 +464,7 @@ static inline void nfs_inode_dio_wait(struct inode *inode)
>  {
>  	inode_dio_wait(inode);
>  }
> +extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
>  


Why is this an EXPORT_SYMBOL_GPL at .c file. Why not just an inline
here ?

>  /* nfs4proc.c */
>  extern void __nfs4_read_done_cb(struct nfs_read_data *);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 2e00fea..e61a373 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -29,6 +29,7 @@
>  
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
> +#include <linux/pagevec.h>
>  #include <linux/module.h>
>  #include "internal.h"
>  #include "pnfs.h"
> @@ -1172,19 +1173,72 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
>  }
>  EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
>  
> +/*
> + * Return the number of contiguous bytes in dirty pages for a given inode
> + * starting at page frame idx.
> + */
> +static u64 pnfs_num_dirty_bytes(struct inode *inode, pgoff_t idx)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	pgoff_t	index;
> +	struct pagevec pvec;
> +	pgoff_t num = 1; /* self */
> +	int i, done = 0;
> +
> +	pagevec_init(&pvec, 0);
> +	idx++; /* self */
> +	while (!done) {
> +		index = idx;
> +		pagevec_lookup_tag(&pvec, mapping, &index,
> +				   PAGECACHE_TAG_DIRTY, (pgoff_t)PAGEVEC_SIZE);
> +		if (pagevec_count(&pvec) == 0)
> +			break;
> +
> +		for (i = 0; i < pagevec_count(&pvec); i++) {
> +			struct page *page = pvec.pages[i];
> +
> +			lock_page(page);
> +			if (unlikely(page->mapping != mapping) ||
> +			    !PageDirty(page) ||
> +			    PageWriteback(page) ||
> +			    page->index != idx) {
> +				done = 1;
> +				unlock_page(page);
> +				break;
> +			}
> +			unlock_page(page);
> +			if (done)
> +				break;
> +			idx++;
> +			num++;
> +		}
> +		pagevec_release(&pvec);
> +	}
> +	return num << PAGE_CACHE_SHIFT;
> +}
> +


Same as what Trond said. radix_tree_next_hole() should be nicer. We need never
do any locking this is just an hint, and not a transaction guaranty. Best first
guess approximation is all we need.

Also you might want to optimize for the most common case of a linear write from
zero. This you can do by comparing i_size / PAGE_SIZE and the number of dirty
pages, if they are the same you know there are no holes, and need not scan.

>  void
> -pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> +pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
> +			   struct nfs_page *req)


Nothing changed here, please don't do this

>  {
> +	u64 wb_size;
> +
>  	BUG_ON(pgio->pg_lseg != NULL);
>  
>  	if (req->wb_offset != req->wb_pgbase) {
>  		nfs_pageio_reset_write_mds(pgio);
>  		return;
>  	}
> +
> +	if (pgio->pg_dreq == NULL)
> +		wb_size = pnfs_num_dirty_bytes(pgio->pg_inode, req->wb_index);
> +	else
> +		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
> +
>  	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>  					   req->wb_context,
>  					   req_offset(req),
> -					   req->wb_bytes,
> +					   wb_size?:req->wb_bytes,


wb_size is always set above in the if() or else. No need to check here.

>  					   IOMODE_RW,
>  					   GFP_NOFS);
>  	/* If no lseg, fall back to write through mds */



But No!

much much better then last time, thank you for working on this
but it is not optimum for objects and files
(when "files" supports segments)

For blocks, Yes radix_tree_next_hole() is the perfect fit. But for
objects (and files) it is i_size_read(). The objects/files server usually
determines it's topology according to file-size. And it does not have any
bigger resources because of holes or no holes. (The files example I think of
is CEPH)

So for objects the wasting factor is the actual i_size extending as a cause
of layout_get, and not the number of pages served. So for us the gain is if
client, that has a much newer information about i_size, sends it on first
layout_get. Though extending file size only once on first layout_get and
not on every layout_get.

So the small change I want is:

+enum pnfs_layout_get_strategy {
+	PLGS_USE_ISIZE,
+	PLGS_SEARCH_FIRST_HOLE,
+	PLGS_ALL_FILE,
+};

-pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req,
+			    enum pnfs_layout_get_strategy plgs)


 ...

+	if (pgio->pg_dreq == NULL) {
+		switch (plgs) {
+		case PLGS_SEARCH_FIRST_HOLE: 
+			wb_size = pnfs_num_dirty_bytes(pgio->pg_inode, req->wb_index);
+			break;
+		case PLGS_USE_ISIZE:
+			wb_size = i_size_read() - req_offset(req);
+			break;
+		case PLGS_ALL_FILE:
+			wb_size = NFS4_MAX_UINT64;
+			break;
+		default:
+			WARN_ON(1);
+			wb_size = PAGE_SIZE;
+	}
+	else
+		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);

The call to pnfs_generic_pg_init_write is always made by the LD's .pg_init
and each LD should pass the proper pnfs_layout_get_strategy flag.

But yes, this is much more like it. Thanks again, nice progress.

Thanks
Boaz
