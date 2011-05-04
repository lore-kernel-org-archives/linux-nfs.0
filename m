Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54030 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab1EDQCg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 12:02:36 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <505415C4-0383-4A8D-BD6B-D85F3CB5E7EB@netapp.com>
Date: Wed, 4 May 2011 12:01:57 -0400
Cc: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <85C0EB32-BBF6-4224-AC6B-A24B7D5C06B1@oracle.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com> <1304386808-2733-2-git-send-email-andros@netapp.com> <20110503202023.699435f4@corrin.poochiereds.net> <1304469890.26184.16.camel@lade.trondhjem.org> <20110504111825.6f26f75a@notabene.brown> <1304473563.26184.28.camel@lade.trondhjem.org> <20110504120726.347df3fc@notabene.brown> <20110504075410.5e59c6b4@tlielax.poochiereds.net> <0424D640-C315-449B-847A-59105BBADBCE@netapp.com> <20110504111853.7150915a@tlielax.poochiereds.net> <505415C4-0383-4A8D-BD6B-D85F3CB5E7EB@netapp.com>
To: Andy Adamson <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 4, 2011, at 11:52 AM, Andy Adamson wrote:

> 
> On May 4, 2011, at 11:18 AM, Jeff Layton wrote:
> 
>> On Wed, 4 May 2011 10:54:57 -0400
>> Andy Adamson <andros@netapp.com> wrote:
>> 
>>> 
>>> On May 4, 2011, at 7:54 AM, Jeff Layton wrote:
>>> 
>>>> On Wed, 4 May 2011 12:07:26 +1000
>>>> NeilBrown <neilb@suse.de> wrote:
>>>> 
>>>>> On Tue, 03 May 2011 21:46:03 -0400 Trond Myklebust
>>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>> 
>>>>>> On Wed, 2011-05-04 at 11:18 +1000, NeilBrown wrote:
>>>>>>> For rpc slots, I doubt you need mempools at all.
>>>>>>> Mempools are only needed if failure is not an option and you would rather
>>>>>>> wait, but you cannot wait for regular writeback because you are on the
>>>>>>> writeback path.  So you use a mempool which waits for a previous request to
>>>>>>> complete.  I don't think that describes rpc slots at all.
>>>>>>> For rpc slots, you can afford to wait when setting up the transport, as you
>>>>>>> are not on the writeout path yet, and later you can always cope with failure.
>>>>>>> So just use kmalloc.
>>>>>> 
>>>>>> Errr.... No. By the time you get to allocating an RPC slot, you may be
>>>>>> bang smack in the middle of the writeout path.
>>>>>> 
>>>>>> The scenario would be that something triggers a writeback (kswapd,
>>>>>> direct reclaim,...) which triggers an RPC call, which requires you to
>>>>>> allocate at least one rpc slot before you can put the write on the wire.
>>>>>> 
>>>>>> I agree with your assertion that we only need one successful slot
>>>>>> allocation in order to make overall forward progress, but we definitely
>>>>>> do need that one...
>>>>>> 
>>>>> 
>>>>> Probably I misunderstood the code, but I thought that there was a base set of
>>>>> slots preallocated.  Eventually one of those will become free won't it?
>>>>> 
>>>>> Looking at the code again, it only ever returns entries to the mempool when
>>>>> it is about to destroy the xprt.  That makes no sense.  If you are using a
>>>>> mempool, then you allocate when you need to use space, and free it as soon as
>>>>> you have finished with it, so the next request can get a turn.
>>>>> 
>>>> 
>>>> That was sort of my point, though I didn't articulate it very well.
>>>> 
>>>> I don't think we want to keep this "static" set of rqsts and the
>>>> mempool. It seems like that's somewhat redundant and more complex than
>>>> is warranted. The question is...which should we keep?
>>>> 
>>>> I think it sort of depends on what the intended model is. If we want to
>>>> allocate out of the "guaranteed" pool first and only when that's
>>>> exhausted fall back to doing dynamic allocations, then we probably want
>>>> to keep the static list of entries.
>>>> 
>>>> If we want to allocate dynamically most of the time and only dip into
>>>> the "guaranteed" pool when that can't be satisfied, then basing all of
>>>> this around mempools might make more sense.
>>> 
>>> Thanks for the review - I've learned a lot about mempools from this discussion.
>>> 
>>> I've noticed that a lot of the time, (at least for TCP) rpc_slots are allocated and not used.
>>> The default slot entries value is a guess. This is why I like the idea of dynamically allocating most 
>>> of the time, and only dipping into the guaranteed pool when the dynamic allocation
>>> can't be satisfied. e.g. get rid of the static set of slots.
>>> Does this design require two mempools, one for dynamic allocation and a guaranteed one being small and "in reserve"?
>>> 
>> 
>> No, a single mempool would give you that. Just declare the mempool with
>> the amount of "emergency" slots you want, and then allocate directly
>> from it and then free them back to the mempool. Most of the time (as
>> Neil points out) you'll get them allocated from the slabcache. It'll
>> it'll only dip into the reserved set when those can't be allocated.
> 
> Cool.
> 
>> 
>> The other thing you have to determine is whether you want this
>> guaranteed number of slots to be per-xprt or global. Today, it's
>> per-xprt. Making it global might mean less wasted memory overall, but I
>> could forsee situations where a hung mount could starve other mounts of
>> slots.
>> 
>> Figuring that out might help guide the overall design here...
>> 
>>> For UDP and RDMA, the default # of slot entries can turn into an upper bound.
>>> For TCP, the default # of slot entries would have no meaning WRT upper bound, as the upper bound is determined
>>> by the TCP window size.
>>> 
>> 
>> Maybe rather than having this dynamic_slot_alloc operation that's only
>> conditionally called, it would cleaner to abstract out the slot
>> allocator altogether.
>> 
>> UDP and RDMA could use the same routine and just allocate out of a
>> fixed set of preallocated slots (sort of like how they do today), and
>> TCP could use this new scheme.
> 
> We need rpc_slots (UDP/RDMA/TCP/....) to be freed back to the mempool in xprt_free_slot.
> If we allocate the set # of rpc_slots, place them on the xprt->free list, and they don't get used,
> then they won't be freed until the xprt is destroyed.

The reason to keep slots around and on a local free list is that full-out memory allocation is heavy weight.  I keep thinking of the talk Willy gave at LSF about how much scalability was affected in the SCSI I/O path by simple memory allocation operations.  Is using a SLAB or SLUB as fast as what we have today?

> I was thinking of using the same allocator for UDP/RDMA/TCP. With all transports, start off with a 
> minimal # of pre-allocated slots (6? 4? 2?) and for UDP/RDMA trigger a dynamic allocation in xprt_alloc_slot
> when there are no slots available and the # slots allocated is less than the default # slot entries for that transport.
> 
> -->Andy
> 
>> -- 
>> Jeff Layton <jlayton@redhat.com>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




