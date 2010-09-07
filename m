Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr12.xs4all.nl ([194.109.24.32]:2705 "EHLO
	smtp-vbr12.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab0IGTwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 15:52:41 -0400
Subject: Re: [PATCH 03/03] sunrpc: scale hashtable cache size with memory
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1283886139.2788.72.camel@heimdal.trondhjem.org>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183149.GC26607@xs4all.net>
	 <1283886139.2788.72.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 07 Sep 2010 21:52:18 +0200
Message-ID: <1283889138.12858.236.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-07 at 15:02 -0400, Trond Myklebust wrote:
> On Sun, 2010-08-22 at 20:31 +0200, Miquel van Smoorenburg wrote:
> > Set the number of entries of the authcache to 4096 on servers
> > with 4G of memory or more. Because kmallocing more than a few K
> > is frowned upon, change the allocator from kmalloc to __get_free_pages.
> > Since the minimum allocation size of __get_free_pages is 1 page,
> > set the number of entries in the authcache to PAGE_SIZE / (entry_size)
> > on servers with < 4G of memory so that exactly one page is used.
> 
> I'm not really understanding why this is an improvement. kmalloc() will
> use pretty much the same mechanism when allocating a slab that is >
> PAGE_SIZE, so why should we duplicate that in the RPC layer?

Oh, I must have been reading old information then. Can't find it
anymore, but what I read was something like "if you need more than a few
pages, use __get_free_pages() instead of kmalloc". Probably out of date.

Anyway, I can change that if you like. So, what about the general idea
of having 16 hashtable entries on systems < 1 GB of (low!) memory, (say)
512 entries for systems with 1GB .. 4 GB and 4096 slots for systems with
>= 4 GB ? The sizes of these tables are dwarfed by the ones for
dentry/inode/IP/TCP anyways. Or we could just not bother and let people
use the module parameter.

The *real* problem we are papering over with this is a different one, by
the way. I have looked into it, but haven't had time to finish it.

The problem is that the hashtable chains are growing too large with
old/unused entries. We should find a way to limit the length of those
chains in an LRU way.

We can't however since the access cache in fs/nfs/dir.c holds a
reference to almost all authcache entries. The thing is, 99% of those
access cache entries will be stale anyway, but those are never cleaned
up until they are used.

And then ofcourse there is some sort of duplication of information
between the auth_unix and auth_generic caches, but I've forgotten the
details.

Thanks,

Mike.

