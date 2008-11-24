From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 16:59:33 -0500
Message-ID: <DEE8B8E0-80E4-4D2E-A388-4FEF6AC6AA31@oracle.com>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net> <1225922196.16857.60.camel@heimdal.trondhjem.org> <20081124183836.GM17862@fieldses.org> <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com> <1227557730.7734.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51491 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbYKXV7z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2008 16:59:55 -0500
In-Reply-To: <1227557730.7734.39.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 24, 2008, at Nov 24, 2008, 3:15 PM, Trond Myklebust wrote:
> On Mon, 2008-11-24 at 14:35 -0500, Chuck Lever wrote:
>> Using hardware performance counters, we can determine how often the
>> TLB is accessed or changed during a typical nlm_host entry lookup.   
>> We
>> can also look at the average number of pages needed to store a large
>> number of nlm_host entries in the common kmalloc-512 SLAB versus the
>> optimum number of pages consumed if the entries were all in one SLAB.
>> As fewer pages are accessed per lookup, this means the CPU has to
>> handle fewer page translations.
>>
>> On big systems it's easy to see how creating and expiring nlm_host
>> entries might contend with other users of the kmalloc-512 SLAB.
>>
>> As we modify the nlm_host garbage collector, it will become somewhat
>> easier to release whole pages back to the page allocator when  
>> nlm_host
>> entries expire.  If the host entries are mixed with other items on a
>> SLAB cache page, it's harder to respond to memory pressure in this  
>> way.
>
> While that may have been true previously when the only memory  
> allocator
> in town was SLAB, the default allocator these days is SLUB, which
> automatically merges similar caches.
>
> 	ls -l /sys/kernel/slab
>
> IOW: It is very likely that your 'private' slab would get merged into
> the existing kmalloc-512 anyway.

You can set SLUB_NO_MERGE to control this behavior.

>> To truly assess the performance implications of this change, we need
>> to know how often the nlm_lookup_host() function is called by the
>> server.  The client uses it only during mount so it's probably not
>> consequential there.  The challenge here is that such improvements
>> would only reveal themselves on excessively busy servers that are
>> managing a large number of clients.  Not easy to replicate this
>> scenario in a lab setting.
>>
>> It's also useful to have a separate SLAB to enable debugging options
>> on that cache, like poisoning and extensive checking during
>> kmem_free(), without adversely impacting other areas of kernel
>> operation.  Additionally we can use /proc/slabinfo to watch host  
>> cache
>> statistics without adding any new kernel interfaces.  All of this  
>> will
>> be useful for testing possible changes to the server-side reference
>> counting and garbage collection logic.
>
> A developer could do this with a private patch at any time. This isn't
> something that we need in mainline.

> In addition, see the above comment about the SLUB allocator, and note
> that SLUB already allows you to set per-cache debugging for pretty  
> much
> any single cache in real time. That ability already extends to the
> kmalloc caches...

I won't argue here because I know you don't really care about  
facilities only developers will use.

>> The only argument I've heard against doing this is that creating
>> unique SLABs is only for items that are typically quickly reused,  
>> like
>> RPC buffers.  I don't find that a convincing reason not to SLAB-ify
>> the host cache.  Quickly reused items are certainly one reason to
>> create a unique SLAB, but there are several SLABs in the kernel that
>> manage items that are potentially long-lived: the buffer head,  
>> dentry,
>> and inode caches come to mind.
>
>> Additionally, on the server, the nlm_host entries can be turned  
>> around
>> pretty quickly on a busy server.  This can become more important if  
>> we
>> decide to implement, for example, an LRU "expired" list to help the
>> garbage collector make better choices about what host entries to  
>> toss.
>
> Needs to be done with _care_! The cost of throwing out an nlm_host
> prematurely is much higher than the cost of throwing out pretty much  
> all
> other objects, since it involves shutting down/restarting lock
> monitoring for each and every 512-byte sized region that you manage to
> reclaim.

An LRU to manage expired entries allows a less expensive way to  
identify nlm_host GC candidates.  Instead of reclaiming all entries  
older than a certain age, you can reclaim just a few on the end of the  
LRU list, as needed.  This actually reduces the impact of GC by  
retaining nlm_host cache entries longer, and by making GC overall a  
less expensive operation.

Right now the whole host table is walked twice and the nlm_files table  
is walked once every time we call nlm_gc_hosts().  That's every time  
we do an nlm_lookup_host(), which is every time the server gets common  
NLM requests.

In fact, since NSM state is now in a separate cache (the nsm_handles  
cache) we may find ways to separate unmonitoring from nlm_host GC so  
the server unmonitors clients less frequently.  The server actually  
doesn't want an SM_UNMON during normal shutdown anyway.  We should  
make SM_UNMON the exception rather than the rule on the server side, I  
think.

> See the credcache for how to do this, but note that on a busy server,
> the garbage collector is going to be called pretty often anyway. It is
> unlikely that an LRU list would help...

>> My feeling is that overall SLAB-ifying the host cache is only  
>> slightly
>> less useful than splitting it.  The host cache already works
>> adequately well for most typical NFS workloads.  I haven't seen  
>> anyone
>> asking whether there is a convincing performance case for splitting
>> the cache.
>>
>> If we are already in the vicinity, we should consider adding a unique
>> SLAB.  It's easy to do, and provides other minor benefits.  It will
>> certainly not make performance worse, adds little complexity, and
>> creates opportunities for other optimizations.
>
> Still not convinced...

SLUB makes the performance argument a little weaker, but I still don't  
see a problem with it.

I would, however, like to hear what kind of performance and code  
complexity improvements are expected from splitting the host cache.   
We would do better to reduce the impact of GC on the server, in my  
opinion.

The two-line logic in nlm_lookup_host() that re-orders the hash chain  
when an nlm_host entry is found is of little value on the client side,  
for example, since the client does nlm_host lookups so infrequently.

And because reordering takes a bunch of memory writes, it is usually  
more expensive than searching even 10 items on the chain (especially  
on SMP/NUMA).  It does the re-ordering unconditionally, even if the  
entry is already at the front of the chain!  So I wonder if it is  
really all that helpful on the server if the average hash chain length  
is four or five (if there are, say, ~100 clients to keep track of), or  
if the same entry is looked up repeatedly.

It might make better sense to remove those two lines, and then double  
the size of the hash table, thus halving the average length of the  
hash chains.  Or make it dynamically sized based on the size of the  
system's physical RAM.  The expense of walking a few more items on  
those hash chains is far outweighed by the current GC process anyway,  
and I can't see the server ever having to track more than 1000 or so  
nlm_host entries across 32 hash buckets.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
