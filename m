Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39341 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986Ab1EPRo2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 13:44:28 -0400
Subject: Re: [V2, 1/1] NFSv4.1: remove pnfs_layout_hdr from pnfs_destroy_all_layouts tmp_list
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4DCF073B.1060400@nexenta.com>
Date: Mon, 16 May 2011 13:44:26 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <3CF6346D-446F-43A7-BAF7-9A365E7386E3@netapp.com>
References: <1305091198-27378-1-git-send-email-andros@netapp.com> <4DCF073B.1060400@nexenta.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 14, 2011, at 6:50 PM, Vitaliy Gusev wrote:

> On 01/-10/-28163 10:59 PM, Andy Adamson wrote:
>> From: Andy Adamson<andros@netapp.com>
>> 
>> Prevents an infinite loop as list was never emptied.
>> 
>> Signed-off-by: Andy Adamson<andros@netapp.com>
>> +++ b/fs/nfs/pnfs.c
>> @@ -383,6 +383,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>>  				plh_layouts);
>>  		dprintk("%s freeing layout for inode %lu\n", __func__,
>>  			lo->plh_inode->i_ino);
>> +		list_del_init(&lo->plh_layouts);
>>  		pnfs_destroy_layout(NFS_I(lo->plh_inode));
> 
> Shouldn't pnfs_destroy_layout() do it ?

pnfs_destroy_layout can't do it. The list is local to pnfs_destroy_all_layouts.  It's confusing because both pnfs_destroy_layout and pnfs_destroy_all_layouts have a local tmp_list used for different purposes.

-->Andy


> 
> Really see:
> 
>  pnfs_destroy_layout(struct nfs_inode *nfsi)
>  {
>  	struct pnfs_layout_hdr *lo;
>  	LIST_HEAD(tmp_list);
> 
>  	spin_lock(&nfsi->vfs_inode.i_lock);
>  	lo = nfsi->layout;
>   ^^^^^^^^^^^^^^^^^^^^
> Here is our "lo".
> 
> 
>  	if (lo) {
>  		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
>  		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
>  	}
>  	spin_unlock(&nfsi->vfs_inode.i_lock);
>  	pnfs_free_lseg_list(&tmp_list);
>  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> It does cleanup and deletes lo from the list.

> 
> 
> I think really problem is more deeper. I investigated  debug messages:
> 
>   [  701.210784] put_lseg: lseg ffff88002cc36108 ref 5721 valid 1
>   [  701.463495] pnfs_destroy_all_layouts freeing layout for inode 9
>   [  701.465382] mark_matching_lsegs_invalid:Begin lo ffff880031b35ed8
>   [  701.467172] mark_matching_lsegs_invalid: freeing lseg ffff88002cc36108 iomode 2 offset 0 length 18446744073709551615
> 
> 
>   [701.470401] 701.470401] mark_lseg_invalid: lseg ffff88002cc36108 ref 5720
>   [  701.472071] mark_matching_lsegs_invalid:Return 1
>   [  701.473623] pnfs_destroy_all_layouts freeing layout for inode 9
>   [  701.475302] mark_matching_lsegs_invalid:Begin lo ffff880031b35ed8
>   [  701.476981] mark_matching_lsegs_invalid: freeing lseg ffff88002cc36108 iomode 2 offset 0 length 18446744073709551615
>   [  701.480549] mark_matching_lsegs_invalid:Return 1
> 
> 
>   [  701.482136] pnfs_destroy_all_layouts freeing layout for inode 9
>   [  701.483802] mark_matching_lsegs_invalid:Begin lo ffff880031b35ed8
>   [  701.485461] mark_matching_lsegs_invalid: freeing lseg ffff88002cc36108 iomode 2 offset 0 length 18446744073709551615
>   [  701.488598] mark_matching_lsegs_invalid:Return 1   ...
> 
> 
> "Return 1" shows that mark_lseg_invalid() didn't do anything, because at first call it mark segment as invalid.
> 
> Also you can see that segment ref counter for last put_lseg() is 5720. I suppose that leak of refconter is real reason of the inifinite loop.
> 
> 
> ---
> Thanks,
> Vitaliy Gusev

