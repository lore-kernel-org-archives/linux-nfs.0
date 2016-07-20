Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbcGTM2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2016 08:28:23 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfs/blocklayout: support RH/Fedora dm-mpath device
 nodes
Date: Wed, 20 Jul 2016 08:29:59 -0400
Message-ID: <41AD6662-7620-4ECB-AE94-D8B9FAC0317E@redhat.com>
In-Reply-To: <1467970890-11237-4-git-send-email-hch@lst.de>
References: <1467970890-11237-1-git-send-email-hch@lst.de>
 <1467970890-11237-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Christoph,

On 8 Jul 2016, at 5:41, Christoph Hellwig wrote:

> Instead of reusing the wwn-* names for multipath devices nodes RHEL 
> and
> Fedora introduce new dm-mpath-uuid-* nodes with a slightly different
> naming scheme.  Try these names first to ensure we always get a
> multipath-capable device if it exists.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/dev.c | 26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
> index ea70883..436bb30 100644
> --- a/fs/nfs/blocklayout/dev.c
> +++ b/fs/nfs/blocklayout/dev.c
> @@ -312,6 +312,28 @@ bl_open_udev_path(struct pnfs_block_volume *v)
>  	return bdev;
>  }
>
> +/*
> + * Try to open the RH/Fedora specific dm-mpath udev path for this 
> WWN, as the
> + * wwn- links will only point to the first discovered SCSI device 
> there.
> + */
> +static struct block_device *
> +bl_open_dm_mpath_udev_path(struct pnfs_block_volume *v)
> +{
> +	struct block_device *bdev;
> +	const char *devname;
> +
> +	devname = kasprintf(GFP_KERNEL,
> +			"/dev/disk/by-id/dm-uuid-mpath-%d%*phN",
> +			v->scsi.designator_type,
> +			v->scsi.designator_len, v->scsi.designator);
> +	if (!devname)
> +		return ERR_PTR(-ENOMEM);
> +
> +	bdev = blkdev_get_by_path(devname, FMODE_READ | FMODE_WRITE, NULL);
> +	kfree(devname);
> +	return bdev;
> +}
> +
>  static int
>  bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
>  		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
> @@ -323,7 +345,9 @@ bl_parse_scsi(struct nfs_server *server, struct 
> pnfs_block_dev *d,
>  	if (!bl_validate_designator(v))
>  		return -EINVAL;
>
> -	d->bdev = bl_open_udev_path(v);
> +	d->bdev = bl_open_dm_mpath_udev_path(v);
> +	if (IS_ERR(d->bdev))
> +		d->bdev = bl_open_udev_path(v);
>  	if (IS_ERR(d->bdev))
>  		return PTR_ERR(d->bdev);

Not a problem with this exact patch, but related..  If ->bdev isn't NULL 
in
the error path, won't we try to do bdev_put in bl_free_device()?  Should 
we
do something like:

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 436bb303d856..6d5e8428b074 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -33,7 +33,7 @@ bl_free_device(struct pnfs_block_dev *dev)
                                 pr_err("failed to unregister PR 
key.\n");
                 }

-               if (dev->bdev)
+               if (!IS_ERR_OR_NULL(dev->bdev))
                         blkdev_put(dev->bdev, FMODE_READ | 
FMODE_WRITE);
         }
  }

Ben
