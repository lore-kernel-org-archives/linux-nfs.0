Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from iamlegend.mr.itd.umich.edu ([141.211.14.68]:37283 "EHLO
	iamlegend.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753589Ab0FJO6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 10:58:51 -0400
Subject: Re: [PATCH] Fixed getdevinfo() and dlm_ino_hash() to search for
	the correct disk name.
From: Eric Anderle <eanderle@umich.edu>
Reply-To: eanderle@umich.edu
To: Andy Adamson <andros@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <7D64BD28-8BE2-4047-B1B8-819FD64E147E@netapp.com>
References: <20100610133336.GB24596@fieldses.org>
	 <20100610133555.GC24596@fieldses.org> <4C10F16D.1050408@panasas.com>
	 <7D64BD28-8BE2-4047-B1B8-819FD64E147E@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Jun 2010 10:52:52 -0400
Message-ID: <1276181572.32649.6.camel@Munich>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

What if we added a struct block_device member to dlm_device_list? That
way we could look it up by major:minor numbers.

On Thu, 2010-06-10 at 10:36 -0400, Andy Adamson wrote:
> On Jun 10, 2010, at 10:06 AM, Benny Halevy wrote:
> 
> > On Jun. 10, 2010, 16:35 +0300, "J. Bruce Fields"  
> > <bfields@fieldses.org> wrote:
> >> On Thu, Jun 10, 2010 at 09:33:37AM -0400, bfields wrote:
> >>> The patch "pnfsd: fix test in nfsd4_find_pnfs_dlm_device" was  
> >>> obviously
> >>> correct; before that patch, nfsd4_find_pnfs_dlm_device() returned  
> >>> the
> >>> first device which did *not* match, instead of the first device  
> >>> which
> >>> did.
> >>>
> >>> Other callers previous worked because they passed int the incorrect
> >>> name, and because we never had more than one element in the list, so
> >>> returning the first non-match would return the right thing.
> >>
> >> But then I don't know what point the "/dev/" is serving here.  May as
> >> well just change the interface so that what's passed in is just the  
> >> name
> >> ("sdc2" or whatever)--no use pretending this is some kind of path  
> >> name
> >> if it's not really.
> >>
> >> However, I don't know whether passing in the disk name is really a
> >> sensible way to refer to a filesystem in a user<->kernel api.
> >>
> >
> > up to you...  I think the whole scheme is currently GFS2 specific
> 
> No, it's DLM specific, with GFS2 being the only current user.
> 
> > and it assumes the device exists symmetrically on /dev/... on all
> > DSs.
> 
> No. This identifies the MDS exported DLM pNFS file system, and has  
> nothing to do with the local DS file system.
> 
> >
> 
> > The /dev prefix seems to be completely redundant.
> > It makes more sense to get rid of it in the user->kernel
> > API as passed down to nfsd4_set_pnfs_dlm_device() rather than
> > adding it here.
> 
> Sure.
> 
> >
> > Benny
> >
> >> --b.
> >>
> >>>
> >>> But now we need to fix those callers.
> >>>
> >>> From: Eric Anderle <eanderle@umich.edu>
> >>>
> >>> ---
> >>> fs/nfsd/nfs4pnfsdlm.c |   12 +++++++++---
> >>> 1 files changed, 9 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> >>> index 84caa6e..5a66a71 100644
> >>> --- a/fs/nfsd/nfs4pnfsdlm.c
> >>> +++ b/fs/nfsd/nfs4pnfsdlm.c
> >>> @@ -268,10 +268,13 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct  
> >>> super_block *sb,
> >>> 	/*
> >>> 	 * If the DS list has not been established, return -EINVAL
> >>> 	 */
> >>> -	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk- 
> >>> >disk_name);
> >>> +	/* Long enough to hold "/dev/" + disk name */
> >>> +	char full_disk_name[6 + strlen(sb->s_bdev->bd_disk->disk_name)];
> >>> +	sprintf(full_disk_name, "/dev/%s", sb->s_bdev->bd_disk- 
> >>> >disk_name);
> >>> +	dlm_pdev = nfsd4_find_pnfs_dlm_device(full_disk_name);
> >>> 	if (!dlm_pdev) {
> >>> 		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
> >>> -			sb->s_bdev->bd_disk->disk_name);
> >>> +			full_disk_name);
> >>> 		return err;
> >>> 	}
> >>>
> >>> @@ -364,7 +367,10 @@ static int dlm_ino_hash(struct inode *ino)
> >>> 	/* If can't find the inode block device in the pnfs_dlm_deivce list
> >>> 	 * then don't hand out a layout
> >>> 	 */
> >>> -	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk- 
> >>> >disk_name);
> >>> +	/* Long enough to hold "/dev/" + disk name */
> >>> +	char full_disk_name[6 + strlen(ino->i_sb->s_bdev->bd_disk- 
> >>> >disk_name)];
> >>> +	sprintf(full_disk_name, "/dev/%s", ino->i_sb->s_bdev->bd_disk- 
> >>> >disk_name);
> >>> +	de = nfsd4_find_pnfs_dlm_device(full_disk_name);
> >>> 	if (!de)
> >>> 		return -1;
> >>> 	hash_mask = de->num_ds - 1;
> >>> -- 
> >>> 1.7.0.4
> >>>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 

-- 
Eric Anderle <eanderle@umich.edu>
U-M Class of 2013

