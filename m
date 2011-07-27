Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46000 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607Ab1G0UPN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:15:13 -0400
Subject: Re: [PATCH v3 23/25] pnfsblock: use pageio_ops api
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:15:12 -0400
In-Reply-To: <1311792048-12551-24-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-24-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311797712.25645.27.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Benny Halevy <bhalevy@panasas.com>
> 
> [pnfsblock: use pnfs_generic_pg_init_read/write]
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 22de05c..502d384 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -762,6 +762,18 @@ bl_clear_layoutdriver(struct nfs_server *server)
>  	return 0;
>  }
>  
> +static const struct nfs_pageio_ops bl_pg_read_ops = {
> +	.pg_init = pnfs_generic_pg_init_read,
> +	.pg_test = pnfs_generic_pg_test,
> +	.pg_doio = pnfs_generic_pg_readpages,
> +};
> +
> +static const struct nfs_pageio_ops bl_pg_write_ops = {
> +	.pg_init = pnfs_generic_pg_init_write,
> +	.pg_test = pnfs_generic_pg_test,
> +	.pg_doio = pnfs_generic_pg_writepages,
> +};
> +
>  static struct pnfs_layoutdriver_type blocklayout_type = {
>  	.id				= LAYOUT_BLOCK_VOLUME,
>  	.name				= "LAYOUT_BLOCK_VOLUME",
> @@ -775,6 +787,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>  	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
>  	.set_layoutdriver		= bl_set_layoutdriver,
>  	.clear_layoutdriver		= bl_clear_layoutdriver,
> +	.pg_read_ops			= &bl_pg_read_ops,
> +	.pg_write_ops			= &bl_pg_write_ops,
>  };
>  
How did this work previously?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

