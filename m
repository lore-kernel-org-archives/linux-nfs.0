From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 3/5] SQUASHME: pnfs-submit: move pnfs_layout_suspend back
 to nfs_inode
Date: Wed, 30 Jun 2010 18:56:26 +0300
Message-ID: <4C2B692A.4030300@panasas.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com> <1277829737-5465-2-git-send-email-andros@netapp.com> <1277829737-5465-3-git-send-email-andros@netapp.com> <1277829737-5465-4-git-send-email-andros@netapp.com> <4C2B5994.7010801@panasas.com> <6434639C-16CE-43F0-BFCD-1AC4152690B9@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: benny@panasas.com, linux-nfs@vger.kernel.org,
	Fred Isaman <iisaman@netapp.com>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9292 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755837Ab0F3P43 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 11:56:29 -0400
In-Reply-To: <6434639C-16CE-43F0-BFCD-1AC4152690B9@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/30/2010 06:13 PM, Andy Adamson wrote:
> 
> On Jun 30, 2010, at 10:49 AM, Boaz Harrosh wrote:
> 
>> On 06/29/2010 07:42 PM, andros@netapp.com wrote:
>>> From: Fred Isaman <iisaman@netapp.com>
>>>
>>> Prepare to embed struct pnfs_layout_tupe into layout driver private  
>>> structs
>>> and to make layout a pointer. Since a temp error on first LAYOUTGET
>>> erases the layout, the suspend timer needs to be moved.
>>>
>>
>> OK Fred, Andy. (I'm also referring to the 1/5 and 2/5 issues here)
>>
>> There is a total mess up. LAYOUTGET has nothing to do with layout
>> (.eg struct pnfs_layout_type) and the layout must not be deallocated
>> if there is any kind of error and/or if IO is actually to be done with
>> MDS or not. LAYOUTGET corresponds to layout_seg held on a list in  
>> layout.
>> The list might be empty and so it's flags and state.
> 
> pnfs_layout_type is the layout cache head structure which has no  

Why are you calling this "cache" head? Are you referring to the
segments list .ie layout->lo_layouts. For me it's a list head
why is it a cache ?

> business in nfsi unless there are layout segments populating it.
> 

This is where we disagree. You say layout is lo_layouts. I say
it is more, it is that plus the state and additional information.
An empty list is not a none-existent list. There are two states
here.

>>
>> Half of the problem was before and this here made it worse. The
>> life time of nfsi->layout should be the same as nfsi itself just
>> as it was before.
> 
> No, the nfs_inode exists with no regard to pnfs_layout_type (horrible  
> name).
> 

Yes

>>
>> Once the life_time of nfsi && nfsi->layout are unified then all your
>> problems go away because you are not checking for existence of nfsi
>> anywhere right? that's because there is no such problem.
> 
> No, the problems don't go away simply because you statically allocate  
> a cache head struct. We have problems with races and reference  
> counting that exist independently of how a structure is allocated.
> 
> We don't need to check for the existence of nfsi, The inode is  
> guaranteed to exist until nfs_destroy_inode is called by the VFS.
> 

And so if you restrict the life time of layout with nfsi your problem
will go away as well, no?

>>
>> Look at it this way. If a layout_driver is in the game it gets to
>> allocate it's own area in NFS_I. part of that area is for generic
>> pnfs.c use, i.e struct pnfs_layout_type, the rest is for private use.
>> once existing it is part of the NFS_I life up till death.
> 
> No. It should only exists when needed - just like nfsi->nfs_acl and  
> nfsi->delegation etc.
> 

It is the same problem with what we had with commit. We had it all over
the place and had races refcounting and shit for ever, until we simplified
it and moved it to the proper NFS checkpoint.

Here too we can just do much better and drop lots of accounting by saying:

  If this nfsi is eligible for pnfs_io and layouts. We allocate a layout
  governing structure for it. That will be freed at the end together with
  nfsi. These that never need it like directories links and so on will not
  have one.

  Now if that first layout_get() never gets through, well nu, we only used
  it to say "Don't have any".

Don't you think that is a much simpler model. Why should one shoot one's foot?

Boaz

>>
>> If it's not so it should be fixed, not some members leaking out
>> to generic structures.
>>
>> Boaz
>>
>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>> ---
>>> fs/nfs/inode.c         |    1 +
>>> fs/nfs/pnfs.c          |    8 ++++----
>>> include/linux/nfs_fs.h |    2 +-
>>> 3 files changed, 6 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 66d7be2..cb12d33 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -1420,6 +1420,7 @@ static void pnfs_init_once(struct nfs_inode  
>>> *nfsi)
>>> #ifdef CONFIG_NFS_V4_1
>>> 	init_waitqueue_head(&nfsi->lo_waitq);
>>> 	nfsi->pnfs_layout_state = 0;
>>> +	nfsi->pnfs_layout_suspend = 0;
>>> 	seqlock_init(&nfsi->layout.seqlock);
>>> 	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
>>> 	INIT_LIST_HEAD(&nfsi->layout.segs);
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index d05cb03..7f6ace2 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1105,12 +1105,12 @@ _pnfs_update_layout(struct inode *ino,
>>>
>>> 	/* if get layout already failed once goto out */
>>> 	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
>>> -		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
>>> -		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
>>> +		if (unlikely(nfsi->pnfs_layout_suspend &&
>>> +		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
>>> 			dprintk("%s: layout_get resumed\n", __func__);
>>> 			clear_bit(lo_fail_bit(iomode),
>>> 				  &nfsi->pnfs_layout_state);
>>> -			nfsi->layout.pnfs_layout_suspend = 0;
>>> +			nfsi->pnfs_layout_suspend = 0;
>>> 		} else
>>> 			goto out_put;
>>> 	}
>>> @@ -1224,7 +1224,7 @@ pnfs_get_layout_done(struct  
>>> nfs4_pnfs_layoutget *lgp, int rpc_status)
>>> 	}
>>>
>>> 	/* remember that get layout failed and suspend trying */
>>> -	nfsi->layout.pnfs_layout_suspend = suspend;
>>> +	nfsi->pnfs_layout_suspend = suspend;
>>> 	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
>>> 		&nfsi->pnfs_layout_state);
>>> 	dprintk("%s: layout_get suspended until %ld\n",
>>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>>> index e216e24..cebc958 100644
>>> --- a/include/linux/nfs_fs.h
>>> +++ b/include/linux/nfs_fs.h
>>> @@ -105,7 +105,6 @@ struct pnfs_layout_type {
>>> 	seqlock_t seqlock;		/* Protects the stateid */
>>> 	nfs4_stateid stateid;
>>> 	void *ld_data;			/* layout driver private data */
>>> -	time_t pnfs_layout_suspend;
>>> 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
>>> 	/* DH: These vars keep track of the maximum write range
>>> 	 * so the values can be used for layoutcommit.
>>> @@ -208,6 +207,7 @@ struct nfs_inode {
>>> 	#define NFS_INO_RW_LAYOUT_FAILED 1 /* rw LAYOUTGET failed stop  
>>> trying */
>>> 	#define NFS_INO_LAYOUT_ALLOC     2 /* bit lock for layout  
>>> allocation */
>>> 	#define NFS_INO_LAYOUTCOMMIT     3 /* LAYOUTCOMMIT needed */
>>> +	time_t pnfs_layout_suspend;
>>> #endif /* CONFIG_NFS_V4_1 */
>>> #endif /* CONFIG_NFS_V4*/
>>> #ifdef CONFIG_NFS_FSCACHE
>>
> 

