From: Stuart Sheldon <stu-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
Subject: Re: Possible NFS bug in 2.6.34...
Date: Sun, 23 May 2010 10:20:27 -0700
Message-ID: <4BF963DB.1090908@actusa.net>
References: <4BF72D34.60701@actusa.net>	 <1274544580.4860.73.camel@heimdal.trondhjem.org>	 <4BF803F2.2010506@actusa.net> <1274546973.4860.78.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Stuart Sheldon <stu-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:56634 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab0EWRUe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 May 2010 13:20:34 -0400
In-Reply-To: <1274546973.4860.78.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Trond Myklebust wrote:
> On Sat, 2010-05-22 at 09:18 -0700, Stuart Sheldon wrote: 
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA256
>>
>> On 05/22/2010 09:09 AM, Trond Myklebust wrote:
>>> Do you see any more NFS traffic to the server when the above hang
>>> occurs? I'm wondering if we don't need something like the following
>>> patch.
>>>
>>> Cheers
>>>   Trond 
>>> --------------------------------------------------------------------------------
>>> From 0b574497e05f62fd49cfe26f1b97e3669525446c Mon Sep 17 00:00:00 2001
>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Date: Sat, 22 May 2010 11:49:19 -0400
>>> Subject: [PATCH] NFS: Ensure that we mark the inode as dirty if we exit early from commit
>>>
>>> If we exit from nfs_commit_inode() without ensuring that the COMMIT rpc
>>> call has been completed, we must re-mark the inode as dirty. Otherwise,
>>> future calls to sync_inode() with the WB_SYNC_ALL flag set will fail to
>>> ensure that the data is on the disk.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Cc: stable@kernel.org
>>> ---
>>>  fs/nfs/write.c |   13 +++++++++++--
>>>  1 files changed, 11 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>> index 3aea3ca..b8a6d7a 100644
>>> --- a/fs/nfs/write.c
>>> +++ b/fs/nfs/write.c
>>> @@ -1386,7 +1386,7 @@ static int nfs_commit_inode(struct inode *inode, int how)
>>>  	int res = 0;
>>>  
>>>  	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
>>> -		goto out;
>>> +		goto out_mark_dirty;
>>>  	spin_lock(&inode->i_lock);
>>>  	res = nfs_scan_commit(inode, &head, 0, 0);
>>>  	spin_unlock(&inode->i_lock);
>>> @@ -1398,9 +1398,18 @@ static int nfs_commit_inode(struct inode *inode, int how)
>>>  			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
>>>  					nfs_wait_bit_killable,
>>>  					TASK_KILLABLE);
>>> +		else
>>> +			goto out_mark_dirty;
>>>  	} else
>>>  		nfs_commit_clear_lock(NFS_I(inode));
>>> -out:
>>> +	return res;
>>> +	/* Note: If we exit without ensuring that the commit is complete,
>>> +	 * we must mark the inode as dirty. Otherwise, future calls to
>>> +	 * sync_inode() with the WB_SYNC_ALL flag set will fail to ensure
>>> +	 * that the data is on the disk.
>>> +	 */
>>> +out_mark_dirty:
>>> +	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>>>  	return res;
>>>  }
>>>  
>> Trond,
>>
>> When it occurred, it continues to throw those errors in the log, and all
>> access to the NFS mount stalled until I hard reset the client system.
>>
>> Do you want me to apply the patch and see if I can recreate the condition?
> 
> Yes, please do. Could you also apply the following debugging patch on
> top of the above one, and see if the WARN_ON() triggers when both
> patches are applied?
> 
> Cheers
>   Trond 
> ------------------------------------------------------------------------------------------------
> From 9883e35957468987f4338525c1d800d637bc05b7 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sat, 22 May 2010 10:46:41 -0400
> Subject: [PATCH 2/2] NFS: debugging code for nfs_wb_page()
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/write.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b8a6d7a..0558fab 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1519,12 +1519,21 @@ int nfs_wb_page(struct inode *inode, struct page *page)
>  	int ret;
>  
>  	while(PagePrivate(page)) {
> +		unsigned dirty;
> +		int syncing;
> +
>  		wait_on_page_writeback(page);
>  		if (clear_page_dirty_for_io(page)) {
>  			ret = nfs_writepage_locked(page, &wbc);
>  			if (ret < 0)
>  				goto out_error;
> +			continue;
>  		}
> +
> +		dirty = inode->i_state & I_DIRTY;
> +		syncing = inode->i_state & I_SYNC;
> +		WARN_ON(!syncing && !dirty && PagePrivate(page));
> +
>  		ret = sync_inode(inode, &wbc);
>  		if (ret < 0)
>  			goto out_error;

The problem seems to be fixed with this, but I'm not seeing / don't know
where to find the 'WARN_ON' messages. If they are suppose to be in the
syslog, then there weren't any.

I'm rolling back to the unpatched kernel to verify that I can still
reproduce the problem natively.

Will follow up on Monday.

Stu


- --
If you took all the girls I knew When I was single And brought
them all together for one night I know theyd never match My sweet
imagination And everything looks worse in black and white
               -- Paul Simon - "Kodachrome Lyrics"
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAEBCAAGBQJL+WPYAAoJEFKVLITDJSGSU0sP/jdJt9NiliGFJ0IB3I4Pt6o/
aHI5wzWWG8Uxzn5UXBumEp79hWXZ8D79kLZ4L8zh9/9hpi8rbExz1ci9IJmjU1LW
qWQVDqmv36uKX9YUzmj8d4505G0Czf9BkU6vsOy4elZ4pAy/Q9EXKFVS5mtirO7u
9FeYJebvbhvdICJTaLDbryugpxWYV6P6bGVglowdbqVWBnKo5QXevWnm6s3Lc1Jd
girpqkQ2f4NddfeW1TbITtBr0bEPYuhK4s4XMdWiYIHNIaRSBJDF5Hlues8LWxu2
++4xz1G7n/K59hRBRX+giBGaSXXl/GSGib87RfwSCrg5qEytNbSRKQX0WuFFxARS
tTbU+zwDpUF7SSvYJZGDh2EEPr2QNfOVCCxVmf1Oe4JAs0OJku1z1ReKpr+CoZg2
lgIFl59bPBNjMcx8GNynnJgTW1IMXWsM8UpTpiAfwTpffXaW3YEH2V855Px9Mkqt
ONuvCll3CWEbwdmisWqvqRAix7oHNh4VMnDOTfb1eYf5ytw5mLfxZaznXhwL8FjE
pUvHZG4TRMUENjucs38dvwx4Vx63DEdxMSK5C0GpdsI16xh0hMKa3ohWaVtSgwIE
Emf1HU2G0vdxl+zMI1IyerNp1T+oxu1rr7eOYWzl3HO8bQc+9ua7yCntpni/c7Dz
Ge8hUPZTZAVmFRRy9zBO
=2+R2
-----END PGP SIGNATURE-----
