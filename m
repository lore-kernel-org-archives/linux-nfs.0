From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 15:15:30 -0500
Message-ID: <1227557730.7734.39.camel@heimdal.trondhjem.org>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
	 <1225922196.16857.60.camel@heimdal.trondhjem.org>
	 <20081124183836.GM17862@fieldses.org>
	 <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48447 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbYKXUPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 15:15:39 -0500
In-Reply-To: <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-24 at 14:35 -0500, Chuck Lever wrote:
> Using hardware performance counters, we can determine how often the  
> TLB is accessed or changed during a typical nlm_host entry lookup.  We  
> can also look at the average number of pages needed to store a large  
> number of nlm_host entries in the common kmalloc-512 SLAB versus the  
> optimum number of pages consumed if the entries were all in one SLAB.   
> As fewer pages are accessed per lookup, this means the CPU has to  
> handle fewer page translations.
> 
> On big systems it's easy to see how creating and expiring nlm_host  
> entries might contend with other users of the kmalloc-512 SLAB.
> 
> As we modify the nlm_host garbage collector, it will become somewhat  
> easier to release whole pages back to the page allocator when nlm_host  
> entries expire.  If the host entries are mixed with other items on a  
> SLAB cache page, it's harder to respond to memory pressure in this way.

While that may have been true previously when the only memory allocator
in town was SLAB, the default allocator these days is SLUB, which
automatically merges similar caches.

	ls -l /sys/kernel/slab

IOW: It is very likely that your 'private' slab would get merged into
the existing kmalloc-512 anyway.

> To truly assess the performance implications of this change, we need  
> to know how often the nlm_lookup_host() function is called by the  
> server.  The client uses it only during mount so it's probably not  
> consequential there.  The challenge here is that such improvements  
> would only reveal themselves on excessively busy servers that are  
> managing a large number of clients.  Not easy to replicate this  
> scenario in a lab setting.
> 
> It's also useful to have a separate SLAB to enable debugging options  
> on that cache, like poisoning and extensive checking during  
> kmem_free(), without adversely impacting other areas of kernel  
> operation.  Additionally we can use /proc/slabinfo to watch host cache  
> statistics without adding any new kernel interfaces.  All of this will  
> be useful for testing possible changes to the server-side reference  
> counting and garbage collection logic.

A developer could do this with a private patch at any time. This isn't
something that we need in mainline.

In addition, see the above comment about the SLUB allocator, and note
that SLUB already allows you to set per-cache debugging for pretty much
any single cache in real time. That ability already extends to the
kmalloc caches...

> The only argument I've heard against doing this is that creating  
> unique SLABs is only for items that are typically quickly reused, like  
> RPC buffers.  I don't find that a convincing reason not to SLAB-ify  
> the host cache.  Quickly reused items are certainly one reason to  
> create a unique SLAB, but there are several SLABs in the kernel that  
> manage items that are potentially long-lived: the buffer head, dentry,  
> and inode caches come to mind.

> Additionally, on the server, the nlm_host entries can be turned around  
> pretty quickly on a busy server.  This can become more important if we  
> decide to implement, for example, an LRU "expired" list to help the  
> garbage collector make better choices about what host entries to toss.

Needs to be done with _care_! The cost of throwing out an nlm_host
prematurely is much higher than the cost of throwing out pretty much all
other objects, since it involves shutting down/restarting lock
monitoring for each and every 512-byte sized region that you manage to
reclaim.
See the credcache for how to do this, but note that on a busy server,
the garbage collector is going to be called pretty often anyway. It is
unlikely that an LRU list would help...

> My feeling is that overall SLAB-ifying the host cache is only slightly  
> less useful than splitting it.  The host cache already works  
> adequately well for most typical NFS workloads.  I haven't seen anyone  
> asking whether there is a convincing performance case for splitting  
> the cache.
> 
> If we are already in the vicinity, we should consider adding a unique  
> SLAB.  It's easy to do, and provides other minor benefits.  It will  
> certainly not make performance worse, adds little complexity, and  
> creates opportunities for other optimizations.

Still not convinced...

  Trond


