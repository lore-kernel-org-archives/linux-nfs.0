Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26386 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671Ab1K2Qkf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:40:35 -0500
Message-ID: <1322584823.4174.15.camel@lade.trondhjem.org>
Subject: Re: [PATCH 4/4] pnfsblock: do ask for layout in pg_init
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Date: Tue, 29 Nov 2011 11:40:23 -0500
In-Reply-To: <1322887965-2938-5-git-send-email-bergwolf@gmail.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	 <1322887965-2938-5-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-12-02 at 20:52 -0800, Peng Tao wrote: 
> Asking for layout in pg_init will always make client ask for only 4KB
> layout in every layoutget. This way, client drops the IO size information
> that is meaningful for MDS in handing out layout.
> 
> In stead, if layout is not find in cache, do not send layoutget
> at once. Wait until before issuing IO in pnfs_do_multiple_reads/writes
> because that is where we know the real size of current IO. By telling the
> real IO size to MDS, MDS will have a better chance to give proper layout.

Why can't you just split pnfs_update_layout() into 2 sub-functions
instead of duplicating it in private block code?

Then call layoutget in your pg_doio() callback instead of adding a
redundant pnfs_update_layout to
pnfs_do_multiple_reads/pnfs_do_multiple_writes...


> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++++++++++++-
>  1 files changed, 52 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 48cfac3..fd585fe 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -39,6 +39,7 @@
>  #include <linux/prefetch.h>
>  
>  #include "blocklayout.h"
> +#include "../internal.h"
>  
>  #define NFSDBG_FACILITY	NFSDBG_PNFS_LD
>  
> @@ -990,14 +991,63 @@ bl_clear_layoutdriver(struct nfs_server *server)
>  	return 0;
>  }
>  
> +/* While RFC doesn't limit maximum size of layout, we better limit it ourself. */
> +#define PNFSBLK_MAXRSIZE (0x1<<22)
> +#define PNFSBLK_MAXWSIZE (0x1<<21)
> +static void
> +bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> +{
> +	struct inode *ino = pgio->pg_inode;
> +	struct pnfs_layout_hdr *lo;
> +
> +	BUG_ON(pgio->pg_lseg != NULL);
> +	spin_lock(&ino->i_lock);
> +	lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_KERNEL);

This has never been tested... It contains all sorts of bugs from
recursive attempts to take the ino->i_lock, to sleep-under-spinlock...

> +	if (!lo || test_bit(lo_fail_bit(IOMODE_READ), &lo->plh_flags)) {
> +		spin_unlock(&ino->i_lock);
> +		nfs_pageio_reset_read_mds(pgio);
> +		return;
> +	}
> +
> +	pgio->pg_bsize = PNFSBLK_MAXRSIZE;
> +	pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
> +						req_offset(req),
> +						req->wb_bytes,
> +						IOMODE_READ);
> +	spin_unlock(&ino->i_lock);
> +}
> +
> +static void
> +bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> +{
> +	struct inode *ino = pgio->pg_inode;
> +	struct pnfs_layout_hdr *lo;
> +
> +	BUG_ON(pgio->pg_lseg != NULL);
> +	spin_lock(&ino->i_lock);
> +	lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_NOFS);
> +	if (!lo || test_bit(lo_fail_bit(IOMODE_RW), &lo->plh_flags)) {
> +		spin_unlock(&ino->i_lock);
> +		nfs_pageio_reset_write_mds(pgio);
> +		return;
> +	}

Ditto...

> +
> +	pgio->pg_bsize = PNFSBLK_MAXWSIZE;
> +	pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
> +						req_offset(req),
> +						req->wb_bytes,
> +						IOMODE_RW);
> +	spin_unlock(&ino->i_lock);
> +}
> +
>  static const struct nfs_pageio_ops bl_pg_read_ops = {
> -	.pg_init = pnfs_generic_pg_init_read,
> +	.pg_init = bl_pg_init_read,
>  	.pg_test = pnfs_generic_pg_test,
>  	.pg_doio = pnfs_generic_pg_readpages,
>  };
>  
>  static const struct nfs_pageio_ops bl_pg_write_ops = {
> -	.pg_init = pnfs_generic_pg_init_write,
> +	.pg_init = bl_pg_init_write,
>  	.pg_test = pnfs_generic_pg_test,
>  	.pg_doio = pnfs_generic_pg_writepages,
>  };

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

