From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 07/14] SQUASHME pnfs_submit: change get_device_info
 parameter
Date: Mon, 12 Apr 2010 16:17:16 +0300
Message-ID: <4BC31D5C.5000903@panasas.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>	<1270756450-5570-2-git-send-email-andros@netapp.com>	<1270756450-5570-3-git-send-email-andros@netapp.com>	<1270756450-5570-4-git-send-email-andros@netapp.com>	<1270756450-5570-5-git-send-email-andros@netapp.com>	<1270756450-5570-6-git-send-email-andros@netapp.com>	<1270756450-5570-7-git-send-email-andros@netapp.com> <1270756450-5570-8-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59355 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0DLNRW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2010 09:17:22 -0400
Received: by bwz19 with SMTP id 19so3634bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2010 06:17:20 -0700 (PDT)
In-Reply-To: <1270756450-5570-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 08, 2010, 22:54 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> In preparation to use the generic deviceid cache.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c    |    2 +-
>  fs/nfs/nfs4filelayout.h    |    2 +-
>  fs/nfs/nfs4filelayoutdev.c |    9 ++++-----
>  3 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 20b3ae2..f222c3b 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -399,7 +399,7 @@ filelayout_check_layout(struct pnfs_layout_type *lo,
>  	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(PNFS_INODE(lo))->hlist,
>  					     &fl->dev_id);
>  	if (dsaddr == NULL) {
> -		dsaddr = get_device_info(FILE_MT(PNFS_INODE(lo)), &fl->dev_id);
> +		dsaddr = get_device_info(PNFS_INODE(lo), &fl->dev_id);
>  		if (dsaddr == NULL) {
>  			dprintk("%s NO device for dev_id %s\n",
>  				__func__, deviceid_fmt(&fl->dev_id));
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 04cca7e..560f7f6 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -109,6 +109,6 @@ struct nfs4_file_layout_dsaddr *
>  nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
>  			   struct pnfs_deviceid *dev_id);
>  struct nfs4_file_layout_dsaddr *
> -get_device_info(struct filelayout_mount_type *mt, struct pnfs_deviceid *dev_id);
> +get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id);
>  
>  #endif /* FS_NFS_NFS4FILELAYOUT_H */
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index db6817d..9844a9c 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -623,8 +623,7 @@ decode_and_add_device(struct filelayout_mount_type *mt, struct pnfs_device *dev)
>   * of available devices, and return it.
>   */
>  struct nfs4_file_layout_dsaddr *
> -get_device_info(struct filelayout_mount_type *mt,
> -		struct pnfs_deviceid *dev_id)
> +get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id)
>  {
>  	struct pnfs_device *pdev = NULL;
>  	int maxpages = NFS4_GETDEVINFO_MAXSIZE >> PAGE_SHIFT;
> @@ -632,7 +631,7 @@ get_device_info(struct filelayout_mount_type *mt,
>  	struct nfs4_file_layout_dsaddr *dsaddr = NULL;
>  	int rc, i, j, minpages = 1;
>  
> -	dprintk("%s mt %p\n", __func__, mt);
> +	dprintk("%s \n", __func__);

nit: checkpatch rightfully complains about the stray space character before the newline.
I'll just remove that upon committing, but there are other places
like that we need to clean up before submitting the final version...

Benny

>  	pdev = kzalloc(sizeof(struct pnfs_device), GFP_KERNEL);
>  	if (pdev == NULL)
>  		return NULL;
> @@ -664,7 +663,7 @@ retry_once:
>  	/* TODO: Update types when CB_NOTIFY_DEVICEID is available */
>  	pdev->dev_notify_types = 0;
>  
> -	rc = pnfs_callback_ops->nfs_getdeviceinfo(mt->fl_sb, pdev);
> +	rc = pnfs_callback_ops->nfs_getdeviceinfo(inode->i_sb, pdev);
>  	/* Retry once with the returned mincount if a page was too small */
>  	dprintk("%s getdevice info returns %d minpages %d\n", __func__, rc,
>  		minpages);
> @@ -682,7 +681,7 @@ retry_once:
>  	/* Found new device, need to decode it and then add it to the
>  	 * list of known devices for this mountpoint.
>  	 */
> -	dsaddr = decode_and_add_device(mt, pdev);
> +	dsaddr = decode_and_add_device(FILE_MT(inode), pdev);
>  out_free:
>  	if (minpages > 1 && pdev->area != NULL)
>  		vunmap(pdev->area);

