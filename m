Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab1G0UKZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:10:25 -0400
Subject: Re: [PATCH v3 20/25] pnfsblock: bl_read_pagelist
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:09:57 -0400
In-Reply-To: <1311792048-12551-21-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-21-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311797397.25645.23.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> Note: When upper layer's read/write request cannot be fulfilled, the block
> layout driver shouldn't silently mark the page as error. It should do
> what can be done and  leave the rest to the upper layer. To do so, we
> should set rdata/wdata->res.count properly.
> 
> When upper layer re-send the read/write request to finish the rest
> part of the request, pgbase is the position where we should start at.
> 
> [pnfsblock: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED]
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> [pnfsblock: read path error handling]
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> [pnfsblock: handle errors when read or write pagelist.]
> Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
> [pnfs-block: use new read_pagelist api]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |  282 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 282 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index c63296d..6e90371 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -29,10 +29,12 @@
>   * of the software, even if it has been or is hereafter advised of the
>   * possibility of such damages.
>   */
> +
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/mount.h>
>  #include <linux/namei.h>
> +#include <linux/bio.h>		/* struct bio */
>  
>  #include "blocklayout.h"
>  
> @@ -45,9 +47,289 @@ MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
>  struct dentry *bl_device_pipe;
>  wait_queue_head_t bl_wq;
>  
> +static void print_page(struct page *page)
> +{
> +	dprintk("PRINTPAGE page %p\n", page);
> +	dprintk("	PagePrivate %d\n", PagePrivate(page));
> +	dprintk("	PageUptodate %d\n", PageUptodate(page));
> +	dprintk("	PageError %d\n", PageError(page));
> +	dprintk("	PageDirty %d\n", PageDirty(page));
> +	dprintk("	PageReferenced %d\n", PageReferenced(page));
> +	dprintk("	PageLocked %d\n", PageLocked(page));
> +	dprintk("	PageWriteback %d\n", PageWriteback(page));
> +	dprintk("	PageMappedToDisk %d\n", PageMappedToDisk(page));
> +	dprintk("\n");
> +}
> +
> +/* Given the be associated with isect, determine if page data needs to be
> + * initialized.
> + */
> +static int is_hole(struct pnfs_block_extent *be, sector_t isect)
> +{
> +	if (be->be_state == PNFS_BLOCK_NONE_DATA)
> +		return 1;
> +	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
> +		return 0;
> +	else
> +		return !is_sector_initialized(be->be_inval, isect);
> +}
> +
> +static int
> +dont_like_caller(struct nfs_page *req)
> +{
> +	if (atomic_read(&req->wb_complete)) {
> +		/* Called by _multi */
> +		return 1;
> +	} else {
> +		/* Called by _one */
> +		return 0;
> +	}
> +}

Why is this still needed? If everything was set up correctly in the
nfs_pageio_ops, then you should never get to bl_read_pagelist if you
don't like the block size. 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

