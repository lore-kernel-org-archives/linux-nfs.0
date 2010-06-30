From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 3/5] SQUASHME: pnfs-submit: move pnfs_layout_suspend back
 to nfs_inode
Date: Wed, 30 Jun 2010 20:17:48 +0300
Message-ID: <4C2B7C3C.20408@panasas.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com> <1277829737-5465-2-git-send-email-andros@netapp.com> <1277829737-5465-3-git-send-email-andros@netapp.com> <1277829737-5465-4-git-send-email-andros@netapp.com> <4C2B5994.7010801@panasas.com> <6434639C-16CE-43F0-BFCD-1AC4152690B9@netapp.com> <4C2B692A.4030300@panasas.com> <85483B53-9B0E-416E-A346-47FEED313F14@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	"linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>,
	Fred Isaman <iisaman@netapp.com>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41667 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754791Ab0F3RRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 13:17:52 -0400
In-Reply-To: <85483B53-9B0E-416E-A346-47FEED313F14@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/30/2010 07:38 PM, Andy Adamson wrote:
> 
> On Jun 30, 2010, at 11:56 AM, Boaz Harrosh wrote:
> 
>> On 06/30/2010 06:13 PM, Andy Adamson wrote:
>>>
>>> On Jun 30, 2010, at 10:49 AM, Boaz Harrosh wrote:
>>>
>>>> On 06/29/2010 07:42 PM, andros@netapp.com wrote:
>>>>> From: Fred Isaman <iisaman@netapp.com>
>>>>>
>>>>> Prepare to embed struct pnfs_layout_tupe into layout driver private
>>>>> structs
>>>>> and to make layout a pointer. Since a temp error on first LAYOUTGET
>>>>> erases the layout, the suspend timer needs to be moved.
>>>>>
>>>>
>>>> OK Fred, Andy. (I'm also referring to the 1/5 and 2/5 issues here)
>>>>
>>>> There is a total mess up. LAYOUTGET has nothing to do with layout
>>>> (.eg struct pnfs_layout_type) and the layout must not be deallocated
>>>> if there is any kind of error and/or if IO is actually to be done  
>>>> with
>>>> MDS or not. LAYOUTGET corresponds to layout_seg held on a list in
>>>> layout.
>>>> The list might be empty and so it's flags and state.
>>>
>>> pnfs_layout_type is the layout cache head structure which has no
> 
> Hi Boaz
> 
>>
>> Why are you calling this "cache" head? Are you referring to the
>> segments list .ie layout->lo_layouts. For me it's a list head
>> why is it a cache ?
> 
> It's a cache of layout segments implemented as a list. We may at some  
> point use a b-tree - whatever.
> 

First of all It's not my day. layout->lo_layouts is that client list
head which keeps the global list of nfsi's that have layouts.

So we are talking about pnfs_layout_type->segs (Why don't you fix me ;-))

cache for me is a bag-of-objects that is kept around for later use even
though I was done with it. Well it might be that. We could theoretically
call layout_get for every IO and immediately return it after commit, so
we keep it until close or destroy, so it's a cache. (I never looked at
it this way. I always look at it as a file's state. now I'm open, now I'm
active IO...)

OK got you

>>
>>> business in nfsi unless there are layout segments populating it.
>>>
>>
>> This is where we disagree. You say layout is lo_layouts. I say
>> it is more, it is that plus the state and additional information.
>> An empty list is not a none-existent list. There are two states
>> here.
> 
> The pnfs_layout_state is in the nfsi.  For file layout, there is no  
> need for pnfs_layout_type when there are no layout segments.
> 

There is in the generic layer. The before-layout-get state and the
after-layout-return state. The layout-segments "potential" is part
of the game. see your own patches. why did you have to leak some of
these layout members to outside?

> What does the object layout driver need in pnfs_layout_type (and/or in  
> private data) when there are no layout segments?
> 

Nothing

>>
>>>>
>>>> Half of the problem was before and this here made it worse. The
>>>> life time of nfsi->layout should be the same as nfsi itself just
>>>> as it was before.
>>>
>>> No, the nfs_inode exists with no regard to pnfs_layout_type (horrible
>>> name).
>>>
>>
>> Yes
>>
>>>>
>>>> Once the life_time of nfsi && nfsi->layout are unified then all your
>>>> problems go away because you are not checking for existence of nfsi
>>>> anywhere right? that's because there is no such problem.
>>>
>>> No, the problems don't go away simply because you statically allocate
>>> a cache head struct. We have problems with races and reference
>>> counting that exist independently of how a structure is allocated.
>>>
>>> We don't need to check for the existence of nfsi, The inode is
>>> guaranteed to exist until nfs_destroy_inode is called by the VFS.
>>>
>>
>> And so if you restrict the life time of layout with nfsi your problem
>> will go away as well, no?
> 
>>
>>>>
>>>> Look at it this way. If a layout_driver is in the game it gets to
>>>> allocate it's own area in NFS_I. part of that area is for generic
>>>> pnfs.c use, i.e struct pnfs_layout_type, the rest is for private  
>>>> use.
>>>> once existing it is part of the NFS_I life up till death.
>>>
>>> No. It should only exists when needed - just like nfsi->nfs_acl and
>>> nfsi->delegation etc.
>>>
>>
>> It is the same problem with what we had with commit. We had it all  
>> over
>> the place and had races refcounting and shit for ever, until we  
>> simplified
>> it and moved it to the proper NFS checkpoint.
>>
>> Here too we can just do much better and drop lots of accounting by  
>> saying:
>>
>>  If this nfsi is eligible for pnfs_io and layouts. We allocate a  
>> layout
>>  governing structure for it. That will be freed at the end together  
>> with
>>  nfsi. These that never need it like directories links and so on  
>> will not
>>  have one.
> 
> What accounting are you removing with your scheme? If at  
> nfs_destroy_inode you have LAYOUTRETURNS (or any LAYOUTXXX) on the  
> wire, you have to wait until they are resolved. Exactly the same  
> accounting as with my patch - which by the way, did not change any  
> refcounting so I'm confused as to your complaint. Note that prior to  
> my patches, pnfs_layout_type->lo_data was freed at the last reference!  
> All I did was include the pnfs_layout_type because just like the  
> lo_data, it is no longer needed.
> 

Yes the pnfs_layout_type->lo_data was half used as a state variable.
We don't have to do that. We can just keep it around up until nfsi
destructor. This one is surly properly ref-counted, right. So we can
just drop our private ref-counting.

>>
>>  Now if that first layout_get() never gets through, well nu, we only  
>> used
>>  it to say "Don't have any".
> 
> A NULL nfsi->layout and/or a state in nfsi->pnfs_layout_state can  
> indicate "don't have any layout segments in the cache".
> 
> If pNFS is never used,  why have the pnfs_layout_type? Should  
> NFSv3/4.0/4.1 mounts have all these extra fields in the inode (which  
> is a precious resource)?
> 

What? I thought it is understood that these patches was to remove that,
sure, and I agree.
For all modes other then pnfs+regular-rw-files this structure pointer is NULL.
For pnfs-IO-potential files this structure is allocated, together with all
it's members and glory.

so:
* nfsi->layout == NULL - This file will not need pnfs (v234 other)
* nfsi->layout->segs == EMPTY - Before layout_get or after layout_return
* nfsi->layout->XXX - other layout state global to any segments.

>>
>> Don't you think that is a much simpler model. Why should one shoot  
>> one's foot?
> 
> No, I don't think it's any simpler. Allocating the structure when it's  
> needed and freeing it when it's not is the normal way to do this -  
> just like delegations.
> 

I don't know about delegations. Just here. What I'm saying is lets collapse
some of the extra stuff, by using existing life-time rules.

You know what, it looks like this is a big jump for you right now. Leave it
like that. Lets run and stabilize this stage. I will put it on my todo list
to try and sanitize it farther before we submit.

> I do agree that we need to review the refcounting.
> 
> -->Andy
> 
>>

Thanks, this all is moving in the right directions, eventually we will
get there.

Boaz
