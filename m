Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:49583 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab1IWFVz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 01:21:55 -0400
Message-ID: <4E7C1766.1080501@panasas.com>
Date: Fri, 23 Sep 2011 08:21:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 06/10] pnfsblock: init pg_bsize properly
References: <1316742617-14766-1-git-send-email-rees@umich.edu> <1316742617-14766-7-git-send-email-rees@umich.edu>
In-Reply-To: <1316742617-14766-7-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/23/2011 04:50 AM, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> pg_bsize is server->wsize/rsize by default. We would want to use the lseg
> length.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>

If you want to get lazy about this patch and take the easy way out.
The least you can do is supply the same fix to that other place
that has the same bug.

This is not nice. You have identified a deficiency in the generic
layer, You know that objects would have the same bug, (because I told you)
and you just don't care. I have spent plenty of times slaving over
blocks code when changing or fixing generic layer. (And Benny even more
then me)

And when you will actually send a patch that does exactly the same in
two places, which access only generic members, you might see that it
might be better to fix it in a single place at the generic layer.

NACK. I'm ok with getting lazy like below, but only if you also
add the same code to objio_osd.c

Sigh
Boaz

> ---
>  fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
>  1 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 2167ba2..f5a7fa6 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -923,14 +923,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
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
>  	.pg_doio = pnfs_generic_pg_readpages,
>  };
>  
>  static const struct nfs_pageio_ops bl_pg_write_ops = {
> -	.pg_init = pnfs_generic_pg_init_write,
> +	.pg_init = bl_pg_init_write,
>  	.pg_test = pnfs_generic_pg_test,
>  	.pg_doio = pnfs_generic_pg_writepages,
>  };

