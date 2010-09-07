Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3741 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244Ab0IGUdU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 16:33:20 -0400
Subject: Re: [PATCH 03/03] sunrpc: scale hashtable cache size with memory
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1283889138.12858.236.camel@laptop>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183149.GC26607@xs4all.net>
	 <1283886139.2788.72.camel@heimdal.trondhjem.org>
	 <1283889138.12858.236.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 16:32:02 -0400
Message-ID: <1283891522.2788.89.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-07 at 21:52 +0200, Miquel van Smoorenburg wrote:
> On Tue, 2010-09-07 at 15:02 -0400, Trond Myklebust wrote:
> > On Sun, 2010-08-22 at 20:31 +0200, Miquel van Smoorenburg wrote:
> > > Set the number of entries of the authcache to 4096 on servers
> > > with 4G of memory or more. Because kmallocing more than a few K
> > > is frowned upon, change the allocator from kmalloc to __get_free_pages.
> > > Since the minimum allocation size of __get_free_pages is 1 page,
> > > set the number of entries in the authcache to PAGE_SIZE / (entry_size)
> > > on servers with < 4G of memory so that exactly one page is used.
> > 
> > I'm not really understanding why this is an improvement. kmalloc() will
> > use pretty much the same mechanism when allocating a slab that is >
> > PAGE_SIZE, so why should we duplicate that in the RPC layer?
> 
> Oh, I must have been reading old information then. Can't find it
> anymore, but what I read was something like "if you need more than a few
> pages, use __get_free_pages() instead of kmalloc". Probably out of date.
> 
> Anyway, I can change that if you like. So, what about the general idea
> of having 16 hashtable entries on systems < 1 GB of (low!) memory, (say)
> 512 entries for systems with 1GB .. 4 GB and 4096 slots for systems with
> >= 4 GB ? The sizes of these tables are dwarfed by the ones for
> dentry/inode/IP/TCP anyways. Or we could just not bother and let people
> use the module parameter.

I'm not convinced there is a strong link between the amount of available
memory, and the number of different credentials a system needs to
support. Generally, systems that have lots of users will tend to have
lots of memory, but the reverse is not necessarily true...

> The *real* problem we are papering over with this is a different one, by
> the way. I have looked into it, but haven't had time to finish it.
> 
> The problem is that the hashtable chains are growing too large with
> old/unused entries. We should find a way to limit the length of those
> chains in an LRU way.
> 
> We can't however since the access cache in fs/nfs/dir.c holds a
> reference to almost all authcache entries. The thing is, 99% of those
> access cache entries will be stale anyway, but those are never cleaned
> up until they are used.

There is nothing stopping you from setting up a hard limit on the number
of access cache entries. Most of the code is already there in order to
support the access cache shrinker.

Ditto for the auth cache itself...

> And then ofcourse there is some sort of duplication of information
> between the auth_unix and auth_generic caches, but I've forgotten the
> details.

At some point, I'd like to get rid of both the auth_unix and
auth_generic caches and replace them with 'struct cred'. Unfortunately,
there is nothing in the current cred code that tries to merge creds with
identical information, which makes them hard to use for the access cache
and NFSv4 open state caches.

Cheers
  Trond
