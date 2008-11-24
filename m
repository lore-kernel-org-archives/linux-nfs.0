From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 14:35:55 -0500
Message-ID: <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net> <1225922196.16857.60.camel@heimdal.trondhjem.org> <20081124183836.GM17862@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59664 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbYKXTgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2008 14:36:15 -0500
In-Reply-To: <20081124183836.GM17862@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 24, 2008, at Nov 24, 2008, 1:38 PM, J. Bruce Fields wrote:
> On Wed, Nov 05, 2008 at 04:56:36PM -0500, Trond Myklebust wrote:
>> On Wed, 2008-11-05 at 16:51 -0500, Chuck Lever wrote:
>>> Here's a set of patches to change the NLM host cache to use a slab.
>>
>> OK, I'll bite. Why would we care about slabifying the NLM host cache?
>
> There's some argument on the 5th patch:
>
> 	"Now that we have a couple of large text buffers in the nlm_host
> 	struct, the nlm_host cache should use a slab to reduce memory
> 	utilization and fragmentation on systems that manage a large
> 	number of NLM peers.
>
> 	"We keep these hardware cache-aligned to speed up the linked
> 	list search in nlm_lookup_host().
>
> 	"The overhead of creating a fresh nlm_host entry is also reduced
> 	using SLAB's init_once callback instead of using kzalloc()."
>
> Chuck, is there any hope of quantifying those improvements?

Using hardware performance counters, we can determine how often the  
TLB is accessed or changed during a typical nlm_host entry lookup.  We  
can also look at the average number of pages needed to store a large  
number of nlm_host entries in the common kmalloc-512 SLAB versus the  
optimum number of pages consumed if the entries were all in one SLAB.   
As fewer pages are accessed per lookup, this means the CPU has to  
handle fewer page translations.

On big systems it's easy to see how creating and expiring nlm_host  
entries might contend with other users of the kmalloc-512 SLAB.

As we modify the nlm_host garbage collector, it will become somewhat  
easier to release whole pages back to the page allocator when nlm_host  
entries expire.  If the host entries are mixed with other items on a  
SLAB cache page, it's harder to respond to memory pressure in this way.

To truly assess the performance implications of this change, we need  
to know how often the nlm_lookup_host() function is called by the  
server.  The client uses it only during mount so it's probably not  
consequential there.  The challenge here is that such improvements  
would only reveal themselves on excessively busy servers that are  
managing a large number of clients.  Not easy to replicate this  
scenario in a lab setting.

It's also useful to have a separate SLAB to enable debugging options  
on that cache, like poisoning and extensive checking during  
kmem_free(), without adversely impacting other areas of kernel  
operation.  Additionally we can use /proc/slabinfo to watch host cache  
statistics without adding any new kernel interfaces.  All of this will  
be useful for testing possible changes to the server-side reference  
counting and garbage collection logic.

The only argument I've heard against doing this is that creating  
unique SLABs is only for items that are typically quickly reused, like  
RPC buffers.  I don't find that a convincing reason not to SLAB-ify  
the host cache.  Quickly reused items are certainly one reason to  
create a unique SLAB, but there are several SLABs in the kernel that  
manage items that are potentially long-lived: the buffer head, dentry,  
and inode caches come to mind.

Additionally, on the server, the nlm_host entries can be turned around  
pretty quickly on a busy server.  This can become more important if we  
decide to implement, for example, an LRU "expired" list to help the  
garbage collector make better choices about what host entries to toss.

My feeling is that overall SLAB-ifying the host cache is only slightly  
less useful than splitting it.  The host cache already works  
adequately well for most typical NFS workloads.  I haven't seen anyone  
asking whether there is a convincing performance case for splitting  
the cache.

If we are already in the vicinity, we should consider adding a unique  
SLAB.  It's easy to do, and provides other minor benefits.  It will  
certainly not make performance worse, adds little complexity, and  
creates opportunities for other optimizations.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
