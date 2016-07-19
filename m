Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:47370 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbcGSPVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 11:21:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] Fix NULL pointer dereference in bl_free_device().
To: Artem Savkov <asavkov@redhat.com>, <linux-nfs@vger.kernel.org>
References: <1468927851-2186-1-git-send-email-asavkov@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <trond.myklebust@primarydata.com>,
        <hch@lst.de>
Message-ID: <6cf8c0f8-37d9-cf60-8607-20b933d248ae@Netapp.com>
Date: Tue, 19 Jul 2016 09:57:39 -0400
MIME-Version: 1.0
In-Reply-To: <1468927851-2186-1-git-send-email-asavkov@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Artem,

On 07/19/2016 07:30 AM, Artem Savkov wrote:
> When bl_parse_deviceid() fails in bl_alloc_deviceid_node() on
> blkdev_get_by_*() step we get an pnfs_block_dev struct that is
> uninitialized except for bdev field which is set to whatever error
> blkdev_get_by_*() returns.  bl_free_device() then tries to call
> blkdev_put() if bdev is not 0 resulting in a wrong pointer dereference.
> 
> Fixing this by making sure bdev is not an error code in bl_free_device().
> 
> Signed-off-by: Artem Savkov <asavkov@redhat.com>
> ---
>  fs/nfs/blocklayout/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
> index 118252f..7db3af0 100644
> --- a/fs/nfs/blocklayout/dev.c
> +++ b/fs/nfs/blocklayout/dev.c
> @@ -33,7 +33,7 @@ bl_free_device(struct pnfs_block_dev *dev)
>  				pr_err("failed to unregister PR key.\n");
>  		}
>  
> -		if (dev->bdev)
> +		if (dev->bdev && !IS_ERR(dev->bdev))

This looks pretty straightforward, but can you use IS_ERR_OR_NULL() instead?  It accomplishes the same check with slightly cleaner code :)

Thanks,
Anna

>  			blkdev_put(dev->bdev, FMODE_READ | FMODE_WRITE);
>  	}
>  }
> 

