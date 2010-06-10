Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47610 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759011Ab0FJNf6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 09:35:58 -0400
Date: Thu, 10 Jun 2010 09:35:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, eanderle@umich.edu
Subject: Re: [PATCH] Fixed getdevinfo() and dlm_ino_hash() to search for
	the correct disk name.
Message-ID: <20100610133555.GC24596@fieldses.org>
References: <20100610133336.GB24596@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100610133336.GB24596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 10, 2010 at 09:33:37AM -0400, bfields wrote:
> The patch "pnfsd: fix test in nfsd4_find_pnfs_dlm_device" was obviously
> correct; before that patch, nfsd4_find_pnfs_dlm_device() returned the
> first device which did *not* match, instead of the first device which
> did.
> 
> Other callers previous worked because they passed int the incorrect
> name, and because we never had more than one element in the list, so
> returning the first non-match would return the right thing.

But then I don't know what point the "/dev/" is serving here.  May as
well just change the interface so that what's passed in is just the name
("sdc2" or whatever)--no use pretending this is some kind of path name
if it's not really.

However, I don't know whether passing in the disk name is really a
sensible way to refer to a filesystem in a user<->kernel api.

--b.

> 
> But now we need to fix those callers.
> 
> From: Eric Anderle <eanderle@umich.edu>
> 
> ---
>  fs/nfsd/nfs4pnfsdlm.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 84caa6e..5a66a71 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -268,10 +268,13 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
>  	/*
>  	 * If the DS list has not been established, return -EINVAL
>  	 */
> -	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk->disk_name);
> +	/* Long enough to hold "/dev/" + disk name */
> +	char full_disk_name[6 + strlen(sb->s_bdev->bd_disk->disk_name)];
> +	sprintf(full_disk_name, "/dev/%s", sb->s_bdev->bd_disk->disk_name);
> +	dlm_pdev = nfsd4_find_pnfs_dlm_device(full_disk_name);
>  	if (!dlm_pdev) {
>  		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
> -			sb->s_bdev->bd_disk->disk_name);
> +			full_disk_name);
>  		return err;
>  	}
>  
> @@ -364,7 +367,10 @@ static int dlm_ino_hash(struct inode *ino)
>  	/* If can't find the inode block device in the pnfs_dlm_deivce list
>  	 * then don't hand out a layout
>  	 */
> -	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
> +	/* Long enough to hold "/dev/" + disk name */
> +	char full_disk_name[6 + strlen(ino->i_sb->s_bdev->bd_disk->disk_name)];
> +	sprintf(full_disk_name, "/dev/%s", ino->i_sb->s_bdev->bd_disk->disk_name);
> +	de = nfsd4_find_pnfs_dlm_device(full_disk_name);
>  	if (!de)
>  		return -1;
>  	hash_mask = de->num_ds - 1;
> -- 
> 1.7.0.4
> 
