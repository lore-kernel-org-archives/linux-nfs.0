From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] pnfsd: fix dlm device naming
Date: Sat, 12 Jun 2010 23:42:16 +0300
Message-ID: <4C13F128.5040602@panasas.com>
References: <1276274734-4996-1-git-send-email-andros@netapp.com> <1276274734-4996-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18982 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752222Ab0FLUmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jun 2010 16:42:19 -0400
In-Reply-To: <1276274734-4996-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

merged under pnfs-all-2.6.35-rc2-2010-06-12

Thanks!

Benny

On Jun. 11, 2010, 19:45 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4pnfsdlm.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 1cf1b69..ae46126 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -47,12 +47,15 @@ struct dlm_device_entry {
>  };
>  
>  static struct dlm_device_entry *
> -nfsd4_find_pnfs_dlm_device(char *disk_name)
> +_nfsd4_find_pnfs_dlm_device(char *disk_name)
>  {
>  	struct dlm_device_entry *dlm_pdev;
>  
> +	dprintk("--> %s  disk name %s\n", __func__, disk_name);
>  	spin_lock(&dlm_device_list_lock);
>  	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
> +		dprintk("%s Look for dlm_pdev %s\n", __func__,
> +			dlm_pdev->disk_name);
>  		if (!memcmp(dlm_pdev->disk_name, disk_name, strlen(disk_name))) {
>  			spin_unlock(&dlm_device_list_lock);
>  			return dlm_pdev;
> @@ -62,6 +65,14 @@ nfsd4_find_pnfs_dlm_device(char *disk_name)
>  	return NULL;
>  }
>  
> +static struct dlm_device_entry *
> +nfsd4_find_pnfs_dlm_device(struct super_block *sb) {
> +	char dname[BDEVNAME_SIZE];
> +
> +	bdevname(sb->s_bdev, dname);
> +	return _nfsd4_find_pnfs_dlm_device(dname);
> +}
> +
>  ssize_t
>  nfsd4_get_pnfs_dlm_device_list(char *buf, ssize_t buflen)
>  {
> @@ -150,7 +161,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
>  	dprintk("%s disk_name %s num_ds %d ds_list %s\n", __func__,
>  		new->disk_name, new->num_ds, new->ds_list);
>  
> -	found = nfsd4_find_pnfs_dlm_device(new->disk_name);
> +	found = _nfsd4_find_pnfs_dlm_device(new->disk_name);
>  	if (found) {
>  		/* FIXME: should compare found->ds_list with new->ds_list
>  		 * and if it is different, kick off a CB_NOTIFY change
> @@ -243,7 +254,7 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
>  	/*
>  	 * If the DS list has not been established, return -EINVAL
>  	 */
> -	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk->disk_name);
> +	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb);
>  	if (!dlm_pdev) {
>  		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
>  			sb->s_bdev->bd_disk->disk_name);
> @@ -339,7 +350,7 @@ static int dlm_ino_hash(struct inode *ino)
>  	/* If can't find the inode block device in the pnfs_dlm_deivce list
>  	 * then don't hand out a layout
>  	 */
> -	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
> +	de = nfsd4_find_pnfs_dlm_device(ino->i_sb);
>  	if (!de)
>  		return -1;
>  	hash_mask = de->num_ds - 1;
