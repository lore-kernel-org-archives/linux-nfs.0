From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] Return failure from bl_initialize_mountpoint if we can't
 get the device for the disk list.
Date: Wed, 03 Nov 2010 17:49:22 +0200
Message-ID: <4CD18482.7090809@panasas.com>
References: <20101101174001.GA6731@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
	peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:39136 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754073Ab0KCPt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 11:49:27 -0400
In-Reply-To: <20101101174001.GA6731-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-01 19:40, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>

Merged in pnfs-all-2.6.37-rc1-2010-11-03 (function renamed to bl_set_layoutdriver)
and in pnfs-all-2.6.36-2010-11-03.

Thanks!

Benny

> ---
>  fs/nfs/blocklayout/blocklayout.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 57a7f04..b3ab4cb 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -677,7 +677,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
>  	}
>  }
>  
> -/* This is mostly copied form the filelayout's get_device_info function.
> +/* This is mostly copied from the filelayout's get_device_info function.
>   * It seems much of this should be at the generic pnfs level.
>   */
>  static struct pnfs_block_dev *
> @@ -796,8 +796,10 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
>  			bdev = nfs4_blk_get_deviceinfo(server, fh,
>  						     &dlist->dev_id[i],
>  						     &block_disklist);
> -			if (!bdev)
> +			if (!bdev) {
> +				status = -ENODEV;
>  				goto out_error;
> +			}
>  			spin_lock(&b_mt_id->bm_lock);
>  			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
>  			spin_unlock(&b_mt_id->bm_lock);
