From: "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH] sunrpc: replace large table of slots with mempool
Date: Sat, 31 Oct 2009 08:51:29 +1100
Message-ID: <bab6d1956e06e41d618c78588a7bc51d.squirrel@neil.brown.name>
References: <19178.32618.958277.726234@notabene.brown>
    <285206C1-0C8E-4B5A-82FA-EE699BE60507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond Myklebust" <trond.myklebust@netapp.com>,
	linux-nfs@vger.kernel.org,
	"Martin Wilck" <martin.wilck@ts.fujitsu.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50481 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932077AbZJ3Vvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2009 17:51:31 -0400
In-Reply-To: <285206C1-0C8E-4B5A-82FA-EE699BE60507@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, October 31, 2009 6:25 am, Chuck Lever wrote:
> On Oct 30, 2009, at 1:53 AM, Neil Brown wrote:
>> From: Martin Wilck <martin.wilck@ts.fujitsu.com>
>> Date: Fri, 30 Oct 2009 16:35:19 +1100
>>
>> If {udp,tcp}_slot_table_entries exceeds 111 (on x86-64),
>> the allocated slot table exceeds 32K and so requires an
>> order-4 allocation.
>> As 4 exceeds PAGE_ALLOC_COSTLY_ORDER (==3), these are more
>> likely to fail, so the chance of a mount failing due to low or
>> fragmented memory goes up significantly.
>>
>> This is particularly a problem for autofs which can try a mount
>> at any time and does not retry in the face of failure.
>
> (aye, and that could be addressed too, separately)
>
>> There is no really need for the slots to be allocated in a single
>> slab of memory.  Using a kmemcache, particularly when fronted by
>> a mempool to allow allocation to usually succeed in atomic context,
>> avoid the need for a large allocation, and also reduces memory waste
>> in cases where not all of the slots are required.
>>
>> This patch replaces the single  kmalloc per client with a mempool
>> shared among all clients.
>
> I've thought getting rid of the slot tables was a good idea for many
> years.
>
> One concern I have, though, is that this shared mempool would be a
> contention point for all RPC transports; especially bothersome on SMP/
> NUMA?

mempools don't fall back on the preallocated memory unless a new
allocation fails.
So the normal case will be a simple calls to kmem_cache_alloc which
scales quite well on SMP/NUMA.  When memory gets tight is the only
time when the mempool can become a contention point, and those times
are supposed to be very transient.

(I used the think it very odd that mempools used the preallocated memory
last rather than first, but then Nick Piggin explained the NUMA issues
and it all became much clearer).

NeilBrown

