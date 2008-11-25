From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 20:48:20 -0500
Message-ID: <B61B380F-A803-4CC4-BA3C-0D7C7A485C01@oracle.com>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net> <1225922196.16857.60.camel@heimdal.trondhjem.org> <20081124183836.GM17862@fieldses.org> <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com> <1227557730.7734.39.camel@heimdal.trondhjem.org> <DEE8B8E0-80E4-4D2E-A388-4FEF6AC6AA31@oracle.com> <1227572626.7734.182.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:52697 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYKYBsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2008 20:48:41 -0500
In-Reply-To: <1227572626.7734.182.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 24, 2008, at Nov 24, 2008, 7:23 PM, Trond Myklebust wrote:
> On Mon, 2008-11-24 at 16:59 -0500, Chuck Lever wrote:
>> On Nov 24, 2008, at Nov 24, 2008, 3:15 PM, Trond Myklebust wrote:
>>> On Mon, 2008-11-24 at 14:35 -0500, Chuck Lever wrote:
>>>> Using hardware performance counters, we can determine how often the
>>>> TLB is accessed or changed during a typical nlm_host entry lookup.
>>>> We
>>>> can also look at the average number of pages needed to store a  
>>>> large
>>>> number of nlm_host entries in the common kmalloc-512 SLAB versus  
>>>> the
>>>> optimum number of pages consumed if the entries were all in one  
>>>> SLAB.
>>>> As fewer pages are accessed per lookup, this means the CPU has to
>>>> handle fewer page translations.
>>>>
>>>> On big systems it's easy to see how creating and expiring nlm_host
>>>> entries might contend with other users of the kmalloc-512 SLAB.
>>>>
>>>> As we modify the nlm_host garbage collector, it will become  
>>>> somewhat
>>>> easier to release whole pages back to the page allocator when
>>>> nlm_host
>>>> entries expire.  If the host entries are mixed with other items  
>>>> on a
>>>> SLAB cache page, it's harder to respond to memory pressure in this
>>>> way.
>>>
>>> While that may have been true previously when the only memory
>>> allocator
>>> in town was SLAB, the default allocator these days is SLUB, which
>>> automatically merges similar caches.
>>>
>>> 	ls -l /sys/kernel/slab
>>>
>>> IOW: It is very likely that your 'private' slab would get merged  
>>> into
>>> the existing kmalloc-512 anyway.
>>
>> You can set SLUB_NO_MERGE to control this behavior.
>
> Sure you can, but you would have to justify that too.
>
> Your main argument for doing it appears to be that you want to improve
> the ability to shrink the cache, however so far this is just an
> assertion.

On average we visit fewer pages during GC and host lookup if the  
nlm_host entries are clustered on fewer pages.  That also reduces the  
physical memory footprint of the nlm_host cache.  To me that is more  
important than being able to shrink the cache.

> You have yet to show that the existing kmalloc-512 cache is
> more difficult to shrink than a private nlm_host cache. Replacing an
> allocation scheme involving random types of structs with one involving
> only nlm_host structs, doesn't prove that the memory fragmentation
> situation will improve.

I don't think I ever made that strong an argument.  Placing the  
nlm_host entries in a single cache may enable us to allow cache  
shrinking under memory pressure sometime down the road, but it is not  
the only thing that that needs to be done to shrink the cache.

> BTW: Speaking of conserving memory, can you please tell me exactly  
> _why_
> we're going through the trouble of caching printable versions of
> host->h_addr, and host->h_srcaddr, when the only consumers are a  
> couple
> of dprintk() statements?

Yes, I agree it is resource-intensive.  We've added extra buffers for  
this in the RPC client and server, so I'm just following the same  
style here.  It eliminates the need to allocate the buffers on the  
stack and make an extra function call that is not needed if debugging  
messages are turned off.

I decided to keep these for now because we are in the middle of  
introducing new functionality, so it's still useful to provide verbose  
debugging.  Make it work first, then make it work fast.

We also decided a while back that we should not display IPv4 addresses  
as IPv6 addresses on systems that don't have IPv6.  This was to allow  
distributions and admins to cut over as they needed to.  It's less  
confusing.

This should change in upcoming kernels because netdev is discussing  
the addition of a %pI4 and a %pI6 format to print addresses via  
printk.  If they've done this right, we can clean all of this up and  
remove the buffers at that point.  It may be as soon as 2.6.29.

We need to preserve a buffer for the presentation address because  
sometimes that is used as the mon_name.  See upcoming patches.  But  
likewise, we may be able to use %pI4 and %pI6 for this, too, as long  
as the new formatter handles scope IDs correctly.  Like the h_name and  
sm_name fields which point to the same string, we can collapse these  
together to save some memory.

We can additionally construct unique nlm_host structures for the  
client and the server (or do a union thingie).  The client doesn't  
need the h_srcaddr or h_srcaddr_buf fields, for instance, and that  
would save nearly 200 bytes by itself.  But the client does need  
several serialization fields that are not used on the server.

>>>> The only argument I've heard against doing this is that creating
>>>> unique SLABs is only for items that are typically quickly reused,
>>>> like
>>>> RPC buffers.  I don't find that a convincing reason not to SLAB-ify
>>>> the host cache.  Quickly reused items are certainly one reason to
>>>> create a unique SLAB, but there are several SLABs in the kernel  
>>>> that
>>>> manage items that are potentially long-lived: the buffer head,
>>>> dentry,
>>>> and inode caches come to mind.
>>>
>>>> Additionally, on the server, the nlm_host entries can be turned
>>>> around
>>>> pretty quickly on a busy server.  This can become more important if
>>>> we
>>>> decide to implement, for example, an LRU "expired" list to help the
>>>> garbage collector make better choices about what host entries to
>>>> toss.
>>>
>>> Needs to be done with _care_! The cost of throwing out an nlm_host
>>> prematurely is much higher than the cost of throwing out pretty much
>>> all
>>> other objects, since it involves shutting down/restarting lock
>>> monitoring for each and every 512-byte sized region that you  
>>> manage to
>>> reclaim.
>>
>> An LRU to manage expired entries allows a less expensive way to
>> identify nlm_host GC candidates.  Instead of reclaiming all entries
>> older than a certain age, you can reclaim just a few on the end of  
>> the
>> LRU list, as needed.  This actually reduces the impact of GC by
>> retaining nlm_host cache entries longer, and by making GC overall a
>> less expensive operation.
>>
>> Right now the whole host table is walked twice and the nlm_files  
>> table
>> is walked once every time we call nlm_gc_hosts().  That's every time
>> we do an nlm_lookup_host(), which is every time the server gets  
>> common
>> NLM requests.
>
> Only for servers that call nlm_lookup_host() very infrequently. To see
> what happens in all other cases, please grep for 'next_gc'...
>
> In any case, would it really be better to have to do that every time
> you're allocating memory while in a low memory situation?
>
> Fixing the problem of walking the entire host table in nlm_gc_hosts()
> needs to be done by other means. For starters, we need to get rid of
> that awful mark/release scheme. Then we could rather move all truly
> unreferenced nlm_host structures onto a list of unused hosts that is
> sorted by expiration date/LRU (in this case they should be the same
> afaics) for the benefit of the garbage collector.

That's the point.  We agree.

>> In fact, since NSM state is now in a separate cache (the nsm_handles
>> cache) we may find ways to separate unmonitoring from nlm_host GC so
>> the server unmonitors clients less frequently.  The server actually
>> doesn't want an SM_UNMON during normal shutdown anyway.  We should
>> make SM_UNMON the exception rather than the rule on the server  
>> side, I
>> think.

To clarify:  "The server doesn't want _to_ _send_ an SM_UNMON during  
normal shutdown"

> Without SM_UNMON, the server will waste time trying to send reboot
> notifications to clients that may not even be alive. That again slows
> down the boot process...

The SM_NOTIFY calls are done asynchronously in the background.

The slowdown occurs because bumping the NSM state requires a sync(2)  
to pickle the new state in /var/lib/nfs/statd/state.  This generally  
results in a lot of disk writes because sync(2) flushes the whole file  
system, and /var also contains the kernel log, which is pretty busy  
during boot up.

> The only case where we _shouldn't_ send an SM_UNMON is if we're  
> calling
> nlmsvc_invalidate_all(),  nlmsvc_unlock_all_by_sb() and
> nlmsvc_unlock_all_by_ip() (although I'm not too sure about the latter
> two cases - it depends on what the userland expectations are).

There may be more cases where the server doesn't send an SM_UNMON than  
there are cases where it does, so inverting this logic may give us  
some code complexity benefits.  I'm still experimenting.

On the client-side, I don't think we need GC at all.  The client holds  
a reference to the nlm_host as long as the file system is mounted.  It  
can simply release the nlm_host and nsm_handle when it unmounts the  
server.  When the last nlm_host that refers to an nsm_handle goes  
away, the client sends an SM_UNMON to the server and the nsm_handle  
goes away.  Done.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
