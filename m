Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:62818 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036Ab1IJH3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Sep 2011 03:29:09 -0400
Received: by qwi4 with SMTP id 4so2410136qwi.1
        for <linux-nfs@vger.kernel.org>; Sat, 10 Sep 2011 00:29:08 -0700 (PDT)
Message-ID: <4E6B11BE.8080606@tonian.com>
Date: Sat, 10 Sep 2011 00:29:02 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] pnfsblock: fix return code confusion
References: <1315585988-20732-1-git-send-email-rees@umich.edu>
In-Reply-To: <1315585988-20732-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-09 09:33, Jim Rees wrote:
> Always return PTR_ERR, not NULL, from nfs4_blk_get_deviceinfo and
> nfs4_blk_decode_device.
> 
> Check for IS_ERR, not NULL, in bl_set_layoutdriver when calling
> nfs4_blk_get_deviceinfo.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>

merged. thanks!

Benny

> ---
>  fs/nfs/blocklayout/blocklayout.c    |   20 ++++++++++++--------
>  fs/nfs/blocklayout/blocklayoutdev.c |   13 ++++++++-----
>  2 files changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 9143e61..7debb55 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -794,7 +794,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
>  			struct nfs4_deviceid *d_id)
>  {
>  	struct pnfs_device *dev;
> -	struct pnfs_block_dev *rv = NULL;
> +	struct pnfs_block_dev *rv;
>  	u32 max_resp_sz;
>  	int max_pages;
>  	struct page **pages = NULL;
> @@ -812,18 +812,20 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
>  	dev = kmalloc(sizeof(*dev), GFP_NOFS);
>  	if (!dev) {
>  		dprintk("%s kmalloc failed\n", __func__);
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>  	}
>  
>  	pages = kzalloc(max_pages * sizeof(struct page *), GFP_NOFS);
>  	if (pages == NULL) {
>  		kfree(dev);
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>  	}
>  	for (i = 0; i < max_pages; i++) {
>  		pages[i] = alloc_page(GFP_NOFS);
> -		if (!pages[i])
> +		if (!pages[i]) {
> +			rv = ERR_PTR(-ENOMEM);
>  			goto out_free;
> +		}
>  	}
>  
>  	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
> @@ -836,8 +838,10 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
>  	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
>  	rc = nfs4_proc_getdeviceinfo(server, dev);
>  	dprintk("%s getdevice info returns %d\n", __func__, rc);
> -	if (rc)
> +	if (rc) {
> +		rv = ERR_PTR(rc);
>  		goto out_free;
> +	}
>  
>  	rv = nfs4_blk_decode_device(server, dev);
>   out_free:
> @@ -855,7 +859,7 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
>  	struct pnfs_devicelist *dlist = NULL;
>  	struct pnfs_block_dev *bdev;
>  	LIST_HEAD(block_disklist);
> -	int status = 0, i;
> +	int status, i;
>  
>  	dprintk("%s enter\n", __func__);
>  
> @@ -887,8 +891,8 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
>  		for (i = 0; i < dlist->num_devs; i++) {
>  			bdev = nfs4_blk_get_deviceinfo(server, fh,
>  						       &dlist->dev_id[i]);
> -			if (!bdev) {
> -				status = -ENODEV;
> +			if (IS_ERR(bdev)) {
> +				status = PTR_ERR(bdev);
>  				goto out_error;
>  			}
>  			spin_lock(&b_mt_id->bm_lock);
> diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
> index 46a2ce6..d08ba91 100644
> --- a/fs/nfs/blocklayout/blocklayoutdev.c
> +++ b/fs/nfs/blocklayout/blocklayoutdev.c
> @@ -109,7 +109,7 @@ struct pnfs_block_dev *
>  nfs4_blk_decode_device(struct nfs_server *server,
>  		       struct pnfs_device *dev)
>  {
> -	struct pnfs_block_dev *rv = NULL;
> +	struct pnfs_block_dev *rv;
>  	struct block_device *bd = NULL;
>  	struct rpc_pipe_msg msg;
>  	struct bl_msg_hdr bl_msg = {
> @@ -119,7 +119,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
>  	uint8_t *dataptr;
>  	DECLARE_WAITQUEUE(wq, current);
>  	struct bl_dev_msg *reply = &bl_mount_reply;
> -	int offset, len, i;
> +	int offset, len, i, rc;
>  
>  	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
>  	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
> @@ -146,8 +146,10 @@ nfs4_blk_decode_device(struct nfs_server *server,
>  
>  	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
>  	add_wait_queue(&bl_wq, &wq);
> -	if (rpc_queue_upcall(bl_device_pipe->d_inode, &msg) < 0) {
> +	rc = rpc_queue_upcall(bl_device_pipe->d_inode, &msg);
> +	if (rc < 0) {
>  		remove_wait_queue(&bl_wq, &wq);
> +		rv = ERR_PTR(rc);
>  		goto out;
>  	}
>  
> @@ -165,8 +167,9 @@ nfs4_blk_decode_device(struct nfs_server *server,
>  
>  	bd = nfs4_blkdev_get(MKDEV(reply->major, reply->minor));
>  	if (IS_ERR(bd)) {
> -		dprintk("%s failed to open device : %ld\n",
> -			__func__, PTR_ERR(bd));
> +		rc = PTR_ERR(bd);
> +		dprintk("%s failed to open device : %d\n", __func__, rc);
> +		rv = ERR_PTR(rc);
>  		goto out;
>  	}
>  
