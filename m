From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fixed getdevinfo() and dlm_ino_hash() to search for
	the correct disk name.
Date: Thu, 10 Jun 2010 13:31:22 -0400
Message-ID: <20100610173122.GB29529@fieldses.org>
References: <20100610133336.GB24596@fieldses.org> <20100610133555.GC24596@fieldses.org> <4C10F16D.1050408@panasas.com> <7D64BD28-8BE2-4047-B1B8-819FD64E147E@netapp.com> <1276181572.32649.6.camel@Munich>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Eric Anderle <eanderle@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab0FJRbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 13:31:25 -0400
In-Reply-To: <1276181572.32649.6.camel@Munich>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 10, 2010 at 10:52:52AM -0400, Eric Anderle wrote:
> What if we added a struct block_device member to dlm_device_list? That
> way we could look it up by major:minor numbers.

I don't know.

By the way:

> > >>> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> > >>> index 84caa6e..5a66a71 100644
> > >>> --- a/fs/nfsd/nfs4pnfsdlm.c
> > >>> +++ b/fs/nfsd/nfs4pnfsdlm.c
> > >>> @@ -268,10 +268,13 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct  
> > >>> super_block *sb,
> > >>> 	/*
> > >>> 	 * If the DS list has not been established, return -EINVAL
> > >>> 	 */
> > >>> -	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk- 
> > >>> >disk_name);
> > >>> +	/* Long enough to hold "/dev/" + disk name */
> > >>> +	char full_disk_name[6 + strlen(sb->s_bdev->bd_disk->disk_name)];
> > >>> +	sprintf(full_disk_name, "/dev/%s", sb->s_bdev->bd_disk- 
> > >>> >disk_name);
> > >>> +	dlm_pdev = nfsd4_find_pnfs_dlm_device(full_disk_name);
> > >>> 	if (!dlm_pdev) {
> > >>> 		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
> > >>> -			sb->s_bdev->bd_disk->disk_name);
> > >>> +			full_disk_name);
> > >>> 		return err;
> > >>> 	}
> > >>>
> > >>> @@ -364,7 +367,10 @@ static int dlm_ino_hash(struct inode *ino)
> > >>> 	/* If can't find the inode block device in the pnfs_dlm_deivce list
> > >>> 	 * then don't hand out a layout
> > >>> 	 */
> > >>> -	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk- 
> > >>> >disk_name);
> > >>> +	/* Long enough to hold "/dev/" + disk name */
> > >>> +	char full_disk_name[6 + strlen(ino->i_sb->s_bdev->bd_disk- 
> > >>> >disk_name)];
> > >>> +	sprintf(full_disk_name, "/dev/%s", ino->i_sb->s_bdev->bd_disk- 
> > >>> >disk_name);
> > >>> +	de = nfsd4_find_pnfs_dlm_device(full_disk_name);
> > >>> 	if (!de)
> > >>> 		return -1;
> > >>> 	hash_mask = de->num_ds - 1;

There's some duplicated code there; it should probably go into a common
function called from both places.

--b.
