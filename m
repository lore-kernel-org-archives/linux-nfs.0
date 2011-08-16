Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:55848 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab1HPVFu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 17:05:50 -0400
Message-ID: <4E4ADBA1.1000005@panasas.com>
Date: Tue, 16 Aug 2011 14:05:37 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: <benny@tonian.com>, <linux-nfs@vger.kernel.org>,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1313197450-4595-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 06:04 PM, Peng Tao wrote:
> pg_bsize is server->wsize/rsize by default. We would want to use the lseg length.
> 

Hi

What is the problem you are trying to solve with this patch?

>From what I understand the only place that actually cares about
pg_bsize is nfs_generic_pg_test() which is only used in MDS
read/write. In the pNFS RW, the LD and pnfs has it's own .pg_test()
check that should not concern with pg_bsize (Unless for pnfs-files
which does). So the idea is that pg_bsize is the maximum set by
MDS server in regard to IO through MDS. And it should not be changed
by client.

If it is not what you see then we should fix it. But should never
override MDS wsize/rsize.

> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
>  1 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 36648e1..9143e61 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -919,14 +919,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
>  	return 0;
>  }
>  
> +static void bl_pg_init_read(struct nfs_pageio_descriptor *pgio,
> +			    struct nfs_page *req)
> +{
> +	pnfs_generic_pg_init_read(pgio, req);
> +	if (pgio->pg_lseg)
> +		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
> +}
> +
> +static void bl_pg_init_write(struct nfs_pageio_descriptor *pgio,
> +			     struct nfs_page *req)
> +{
> +	pnfs_generic_pg_init_write(pgio, req);
> +	if (pgio->pg_lseg)
> +		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
> +}
> +
>  static const struct nfs_pageio_ops bl_pg_read_ops = {
> -	.pg_init = pnfs_generic_pg_init_read,
> +	.pg_init = bl_pg_init_read,
>  	.pg_test = pnfs_generic_pg_test,

I see here that you do not override .pg_test. This is your problem
look at objio_osd::objio_pg_test() it checks for similar boundaries
at the objects side. This is where you need to do these checks
for blocks as well.

>  	.pg_doio = pnfs_generic_pg_readpages,
>  };
>  
>  static const struct nfs_pageio_ops bl_pg_write_ops = {
> -	.pg_init = pnfs_generic_pg_init_write,
> +	.pg_init = bl_pg_init_write,
>  	.pg_test = pnfs_generic_pg_test,

Same here

>  	.pg_doio = pnfs_generic_pg_writepages,
>  };

Thanks
Boaz
