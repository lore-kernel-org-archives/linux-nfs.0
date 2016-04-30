Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33983 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcD3OWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 10:22:36 -0400
Date: Sat, 30 Apr 2016 15:22:32 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160430142232.GA25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
 <1461501975.5219.40.camel@poochiereds.net>
 <20160424191835.GL25498@ZenIV.linux.org.uk>
 <20160429075812.GY25498@ZenIV.linux.org.uk>
 <1462022142.10011.19.camel@poochiereds.net>
 <1462022576.10011.22.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1462022576.10011.22.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 30, 2016 at 09:22:56AM -0400, Jeff Layton wrote:
> ...but looks like same problem:
> 
> (gdb) list *(__kmalloc_track_caller+0x96)
> 0xffffffff811f9a06 is in __kmalloc_track_caller (mm/slub.c:245).
> 240      *                      Core slab cache functions
> 241      *******************************************************************/
> 242
> 243     static inline void *get_freepointer(struct kmem_cache *s, void *object)
> 244     {
> 245             return *(void **)(object + s->offset);
> 246     }
> 247
> 248     static void prefetch_freepointer(const struct kmem_cache *s, void *object)
> 249     {

Joy...  Does that happen without the last commit as well?  I realize that
memory corruption could well have been introduced earlier and changes in
the last commit had only increased the odds, but...
