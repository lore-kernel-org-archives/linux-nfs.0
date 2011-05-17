Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30820 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849Ab1EQPaF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 11:30:05 -0400
Subject: Re: [V2, 1/1] NFSv4.1: remove pnfs_layout_hdr from pnfs_destroy_all_layouts tmp_list
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4DD17D8A.8080605@nexenta.com>
Date: Tue, 17 May 2011 11:29:49 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <F18DBEA0-9225-4B16-BB43-010CBB2D0170@netapp.com>
References: <1305091198-27378-1-git-send-email-andros@netapp.com> <4DCF073B.1060400@nexenta.com> <3CF6346D-446F-43A7-BAF7-9A365E7386E3@netapp.com> <4DD17D8A.8080605@nexenta.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 16, 2011, at 3:39 PM, Vitaliy Gusev wrote:

> On 05/16/2011 09:44 PM, Andy Adamson wrote:
>> 
>> On May 14, 2011, at 6:50 PM, Vitaliy Gusev wrote:
>> 
>>> On 01/-10/-28163 10:59 PM, Andy Adamson wrote:
>>>> From: Andy Adamson<andros@netapp.com>
>>>> 
>>>> Prevents an infinite loop as list was never emptied.
>>>> 
>>>> Signed-off-by: Andy Adamson<andros@netapp.com>
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -383,6 +383,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>>>>  				plh_layouts);
>>>>  		dprintk("%s freeing layout for inode %lu\n", __func__,
>>>>  			lo->plh_inode->i_ino);
>>>> +		list_del_init(&lo->plh_layouts);
>>>>  		pnfs_destroy_layout(NFS_I(lo->plh_inode));
>>> 
>>> Shouldn't pnfs_destroy_layout() do it ?
>> 
>> pnfs_destroy_layout can't do it. The list is local to pnfs_destroy_all_layouts.
>> It's confusing because both pnfs_destroy_layout and pnfs_destroy_all_layouts have
> > a local tmp_list used for different purposes.
> 
> Yes purposes are different but "lo" is the same and list_del_init() in pnfs_free_lseg_list() see the same "lo" from pnfs_destroy_all_layouts.
> 
> 
> pnfs_destroy_layout(struct nfs_inode *nfsi):
> 
>      lo = nfsi->layout;
> 
>   >>> after that mark_matching_lsegs_invalid adds "lo" to tmplist_v2
> 
> 	
> pnfs_free_lseg_list(tmplist_v2):
> 
> 	lo = list_first_entry(free_me, struct pnfs_layout_segment,
> 			      pls_list)->pls_layout;
> 
>  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
>  Here is "lo" from pnfs_destroy_all_layouts.
> 
> 
> 	if (test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags)) {
> 		struct nfs_client *clp;
> 
> 		clp = NFS_SERVER(lo->plh_inode)->nfs_client;
> 		spin_lock(&clp->cl_lock);
> 		list_del_init(&lo->plh_layouts);
>      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>  Here is second deleting "lo" that was already deleted in pnfs_destroy_all_layouts.
> 
> So if all is ok, it will delete list twice.
> 
> I suppose, either current schema has to be changed or list_del_init() should be removed from pnfs_destoy_all_layouts with fixing mark_matching_lsegs_invalid and ref counter.

There is a lot more to do to recover from an MDS lease expiration, the only place pnfs_destroy_all_layouts is called from. Our current code does not go far enough. We need to stop using any layouts and deviceIDs (and data servers) obtained under the old clientid.

Thanks for your review. I'll post a solution and look forward to your comments

-->Andy

> 
> 
> ---
> Gusev Vitaliy

