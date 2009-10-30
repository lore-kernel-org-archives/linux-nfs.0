From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] sunrpc: replace large table of slots with mempool
Date: Fri, 30 Oct 2009 18:05:22 -0400
Message-ID: <63DCA512-3BC1-4983-9396-6C32BE9F3F39@oracle.com>
References: <19178.32618.958277.726234@notabene.brown> <1256932398.15679.0.camel@heimdal.trondhjem.org> <4f145776da1d0765ddc46cdb4be28b76.squirrel@neil.brown.name>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Martin Wilck <martin.wilck@ts.fujitsu.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:39971 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757447AbZJ3WGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Oct 2009 18:06:48 -0400
In-Reply-To: <4f145776da1d0765ddc46cdb4be28b76.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 30, 2009, at 5:58 PM, NeilBrown wrote:
> On Sat, October 31, 2009 6:53 am, Trond Myklebust wrote:
>> On Fri, 2009-10-30 at 16:53 +1100, Neil Brown wrote:
>>> From: Martin Wilck <martin.wilck@ts.fujitsu.com>
>>> Date: Fri, 30 Oct 2009 16:35:19 +1100
>>>
>>> If {udp,tcp}_slot_table_entries exceeds 111 (on x86-64),
>>> the allocated slot table exceeds 32K and so requires an
>>> order-4 allocation.
>>> As 4 exceeds PAGE_ALLOC_COSTLY_ORDER (==3), these are more
>>> likely to fail, so the chance of a mount failing due to low or
>>> fragmented memory goes up significantly.
>>>
>>> This is particularly a problem for autofs which can try a mount
>>> at any time and does not retry in the face of failure.
>>>
>>> There is no really need for the slots to be allocated in a single
>>> slab of memory.  Using a kmemcache, particularly when fronted by
>>> a mempool to allow allocation to usually succeed in atomic context,
>>> avoid the need for a large allocation, and also reduces memory waste
>>> in cases where not all of the slots are required.
>>>
>>> This patch replaces the single  kmalloc per client with a mempool
>>> shared among all clients.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.de>
>>> ---
>>>
>>> The only thing that I'm not completely confident about in this patch
>>> is
>>>   #define RPC_RQST_POOLSIZE	(128)
>>> simply because it is an arbitrary number.  This allocations will  
>>> only
>>> come from this pool when a GFP_ATOMIC alloc fails, so memory has to
>>> be tight.  Allowing a further 128 requests which might serve to
>>> free up memory is probably enough.
>>>
>>> If/when the swap-over-nfs gets upstream it will need to handle this
>>> memory pool as well ofcourse.
>>
>> How about getting rid of the memory pool, then doing a mixture of  
>> what
>> we have now supplemented with dynamic allocation?
>>
>> IOW: preallocate, say, 4 slots per xprt_sock and then the rest via
>> kmalloc().
>> We might also consider freeing up the preallocated slots too when the
>> socket gets closed due to the inactivity timer kicking in...
>
> I think I would still recommend using mempools as they are a well  
> tested
> and understood concept.
> I think the key difference that you are proposing is that instead of
> a single mempool with 256 slots preallocated, we have a separate  
> mempool
> for each client with 4 slots preallocated.

That would also address my concern about tying all the transports into  
a single contention point.

> I think that would be a good change.  The 'struct mempool_s' isn't  
> very
> large, only about 8 pointers, so havng them per-client is not a big  
> cost.
>
>> Once we have dynamically allocated slots, we might also want to get  
>> rid
>> of the 128 slot limit on /proc/sys/sunrpc/tcp_slot_table_entries.  
>> I've
>> been hearing complaints from people with large memory + 10GigE
>> systems...
>
> Yes, that upper limit of 128 would become fairly pointless and could
> be removed.

I seem to recall that we kept the 16 slot default setting, and limited  
the maximum to 128, because Trond saw some bad performance in some  
common scenarios for TCP with larger slot tables.  Out of curiosity,  
did anyone ever figure out what that was?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



