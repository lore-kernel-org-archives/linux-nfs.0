Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760077Ab1CDUHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 15:07:07 -0500
Date: Fri, 4 Mar 2011 15:07:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [Security] [PATCH] nfs4: Ensure that ACL pages sent over NFS
 were not allocated from the slab
Message-ID: <20110304200703.GC21260@fieldses.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
 <20110304171320.GA19496@fieldses.org>
 <20110304184505.GB10083@hmsreliant.think-freely.org>
 <20110304193325.GB21260@fieldses.org>
 <AANLkTimpX6JPWyPgB6vcZ8TuQ5gj9aPcJ9OCK186n5Nk@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimpX6JPWyPgB6vcZ8TuQ5gj9aPcJ9OCK186n5Nk@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 04, 2011 at 11:48:23AM -0800, Linus Torvalds wrote:
> On Fri, Mar 4, 2011 at 11:33 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > So I assumed the slab allocator would hold a reference to the page like
> > any other user would, in which case the tcp code could take a second
> > reference of its own.
> 
> So the reason that wouldn't work is simple: the reference is obviously
> at a page level, but slab doles out allocations on its own level.
> 
> What does that mean? Imagine if the network layer takes a ref on the
> page, but then the original user does a "kfree()". The _page_ would
> stay around (we have a ref from it - but so does the slab allocator),
> but the thing is, the slab allocator will release and then re-use the
> slab entry.
>
> So the "hold a reference to the page" doesn't actually _help_. The
> problem isn't the page going away, it's the smaller slab-allocation
> being reused for something else - so the page-level ref would be
> useless.
> 
> So page-level references really only do work with page allocators.
> They don't know about the allocation patterns within a page that slab
> does.

Makes sense, thanks for the explanation.

Could it still make sense to hand off kmalloc'd memory to tcp_send_pages
if we know the kfree won't happen till after the data's sent?

OK, maybe in that case someone above the tcp layer just shouldn't be
assuming they can know when the tcp layer is done with the data.

In this case, we're not kfree()'ing until we've gotten an rpc reply
back.  But in theory perhaps there could be cases where the server's
gotten the data and we've seen the reply but the tcp layer still thinks
it needs to retransmit something?  I don't think we'd care if the data
was still correct in that case, but it could be an information leak if
nothing else.

--b.
