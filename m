Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbcGUM3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 08:29:15 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Artem Savkov" <asavkov@redhat.com>
Cc: "Christoph Hellwig" <hch@lst.de>,
        "Anna Schumaker" <Anna.Schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        trond.myklebust@primarydata.com
Subject: Re: [PATCH v3] Fix NULL pointer dereference in bl_free_device().
Date: Thu, 21 Jul 2016 08:30:52 -0400
Message-ID: <C1E3B80C-FF09-4611-A6BE-6A0576987F5B@redhat.com>
In-Reply-To: <1469100724-11039-1-git-send-email-asavkov@redhat.com>
References: <20160721080910.GA20363@lst.de>
 <1469100724-11039-1-git-send-email-asavkov@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 Jul 2016, at 7:32, Artem Savkov wrote:

> When bl_parse_deviceid() fails in bl_alloc_deviceid_node() on
> blkdev_get_by_*() step we get an pnfs_block_dev struct that is
> uninitialized except for bdev field which is set to whatever error
> blkdev_get_by_*() returns.  bl_free_device() then tries to call
> blkdev_put() if bdev is not 0 resulting in a wrong pointer 
> dereference.
>
> Fixing this by setting bdev in struct pnfs_block_dev only if we didn't
> get an error from blkdev_get_by_*().
>
> Signed-off-by: Artem Savkov <asavkov@redhat.com>

Looks good to me.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

> ---
>  fs/nfs/blocklayout/dev.c | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
> index 118252f..a69ef4e 100644
> --- a/fs/nfs/blocklayout/dev.c
> +++ b/fs/nfs/blocklayout/dev.c
> @@ -235,18 +235,20 @@ bl_parse_simple(struct nfs_server *server, 
> struct pnfs_block_dev *d,
>  		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
>  {
>  	struct pnfs_block_volume *v = &volumes[idx];
> +	struct block_device *bdev;
>  	dev_t dev;
>
>  	dev = bl_resolve_deviceid(server, v, gfp_mask);
>  	if (!dev)
>  		return -EIO;
>
> -	d->bdev = blkdev_get_by_dev(dev, FMODE_READ | FMODE_WRITE, NULL);
> -	if (IS_ERR(d->bdev)) {
> +	bdev = blkdev_get_by_dev(dev, FMODE_READ | FMODE_WRITE, NULL);
> +	if (IS_ERR(bdev)) {
>  		printk(KERN_WARNING "pNFS: failed to open device %d:%d (%ld)\n",
> -			MAJOR(dev), MINOR(dev), PTR_ERR(d->bdev));
> -		return PTR_ERR(d->bdev);
> +			MAJOR(dev), MINOR(dev), PTR_ERR(bdev));
> +		return PTR_ERR(bdev);
>  	}
> +	d->bdev = bdev;
>
>
>  	d->len = i_size_read(d->bdev->bd_inode);
> @@ -350,17 +352,19 @@ bl_parse_scsi(struct nfs_server *server, struct 
> pnfs_block_dev *d,
>  		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
>  {
>  	struct pnfs_block_volume *v = &volumes[idx];
> +	struct block_device *bdev;
>  	const struct pr_ops *ops;
>  	int error;
>
>  	if (!bl_validate_designator(v))
>  		return -EINVAL;
>
> -	d->bdev = bl_open_dm_mpath_udev_path(v);
> -	if (IS_ERR(d->bdev))
> -		d->bdev = bl_open_udev_path(v);
> -	if (IS_ERR(d->bdev))
> -		return PTR_ERR(d->bdev);
> +	bdev = bl_open_dm_mpath_udev_path(v);
> +	if (IS_ERR(bdev))
> +		bdev = bl_open_udev_path(v);
> +	if (IS_ERR(bdev))
> +		return PTR_ERR(bdev);
> +	d->bdev = bdev;
>
>  	d->len = i_size_read(d->bdev->bd_inode);
>  	d->map = bl_map_simple;
> -- 
> 2.5.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
