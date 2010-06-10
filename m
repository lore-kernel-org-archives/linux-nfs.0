Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54676 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754040Ab0FJOTA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 10:19:00 -0400
Message-ID: <4C10F450.6070801@panasas.com>
Date: Thu, 10 Jun 2010 17:18:56 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, eanderle@umich.edu
Subject: Re: [PATCH] Fixed getdevinfo() and dlm_ino_hash() to search for	the
 correct disk name.
References: <20100610133336.GB24596@fieldses.org> <20100610133555.GC24596@fieldses.org> <4C10F16D.1050408@panasas.com>
In-Reply-To: <4C10F16D.1050408@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jun. 10, 2010, 17:06 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> On Jun. 10, 2010, 16:35 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> On Thu, Jun 10, 2010 at 09:33:37AM -0400, bfields wrote:
>>> The patch "pnfsd: fix test in nfsd4_find_pnfs_dlm_device" was obviously
>>> correct; before that patch, nfsd4_find_pnfs_dlm_device() returned the
>>> first device which did *not* match, instead of the first device which
>>> did.
>>>
>>> Other callers previous worked because they passed int the incorrect
>>> name, and because we never had more than one element in the list, so
>>> returning the first non-match would return the right thing.
>>
>> But then I don't know what point the "/dev/" is serving here.  May as
>> well just change the interface so that what's passed in is just the name
>> ("sdc2" or whatever)--no use pretending this is some kind of path name
>> if it's not really.
>>
>> However, I don't know whether passing in the disk name is really a
>> sensible way to refer to a filesystem in a user<->kernel api.
>>
> 
> up to you...  I think the whole scheme is currently GFS2 specific
> and it assumes the device exists symmetrically on /dev/... on all
> DSs.  The /dev prefix seems to be completely redundant.
> It makes more sense to get rid of it in the user->kernel
> API as passed down to nfsd4_set_pnfs_dlm_device() rather than
> adding it here.

A more through design could use the fs uuid rather than the device name
which is kinda volatile...

Benny

> 
> Benny
> 
>> --b.
>>
>>>
>>> But now we need to fix those callers.
>>>
>>> From: Eric Anderle <eanderle@umich.edu>
>>>
>>> ---
>>>  fs/nfsd/nfs4pnfsdlm.c |   12 +++++++++---
>>>  1 files changed, 9 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
>>> index 84caa6e..5a66a71 100644
>>> --- a/fs/nfsd/nfs4pnfsdlm.c
>>> +++ b/fs/nfsd/nfs4pnfsdlm.c
>>> @@ -268,10 +268,13 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
>>>  	/*
>>>  	 * If the DS list has not been established, return -EINVAL
>>>  	 */
>>> -	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk->disk_name);
>>> +	/* Long enough to hold "/dev/" + disk name */
>>> +	char full_disk_name[6 + strlen(sb->s_bdev->bd_disk->disk_name)];
>>> +	sprintf(full_disk_name, "/dev/%s", sb->s_bdev->bd_disk->disk_name);
>>> +	dlm_pdev = nfsd4_find_pnfs_dlm_device(full_disk_name);
>>>  	if (!dlm_pdev) {
>>>  		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
>>> -			sb->s_bdev->bd_disk->disk_name);
>>> +			full_disk_name);
>>>  		return err;
>>>  	}
>>>  
>>> @@ -364,7 +367,10 @@ static int dlm_ino_hash(struct inode *ino)
>>>  	/* If can't find the inode block device in the pnfs_dlm_deivce list
>>>  	 * then don't hand out a layout
>>>  	 */
>>> -	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
>>> +	/* Long enough to hold "/dev/" + disk name */
>>> +	char full_disk_name[6 + strlen(ino->i_sb->s_bdev->bd_disk->disk_name)];
>>> +	sprintf(full_disk_name, "/dev/%s", ino->i_sb->s_bdev->bd_disk->disk_name);
>>> +	de = nfsd4_find_pnfs_dlm_device(full_disk_name);
>>>  	if (!de)
>>>  		return -1;
>>>  	hash_mask = de->num_ds - 1;
>>> -- 
>>> 1.7.0.4
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
