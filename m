Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab3BROaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 09:30:06 -0500
Date: Mon, 18 Feb 2013 09:30:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in
 reply cache stats
Message-ID: <20130218143002.GB22047@fieldses.org>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net>
 <1360958672-5692-1-git-send-email-jlayton@redhat.com>
 <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
 <20130215172058.29941a54@tlielax.poochiereds.net>
 <20130216133927.GA28824@fieldses.org>
 <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com>
 <20130217160056.GC11441@fieldses.org>
 <20130218092134.0b312c78@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130218092134.0b312c78@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 18, 2013 at 09:21:34AM -0500, Jeff Layton wrote:
> On Sun, 17 Feb 2013 11:00:56 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Sat, Feb 16, 2013 at 12:18:18PM -0500, Chuck Lever wrote:
> > > 
> > > On Feb 16, 2013, at 8:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > With a per-client maximum number of entries, sizing the hash tables
> > > > should be easier.
> > > When a server has only one client, should that client be allowed to
> > > maximize the use of a server's resources (eg, use all of the DRC
> > > resource the server has available)?
> > 
> > I've been assuming there's rapidly diminishing returns to caching a lot
> > of replies to a single client.  But that might not be true--I guess a
> > busy UDP client with a long retry timeout might benefit from a large
> > cache?
> > 
> 
> Yes, or one with a massively parallel workload and poor slot-table
> implementation that just sprays tons of requests at the server?

I believe we pin cache entries while the request is in progress and
timestamp and insert into the lru when when we send the reply--so the
parallelism doesn't matter so much, in the sense that we're not going to
for example get a big slow write operation evicted by a bunch of quick
concurrent getattrs.

What matters is: from the time we send a reply, to the time the client
retries, how many more requests does the client send?

> > > How about when a server has one active client and multiple quiescent
> > > clients?
> > 
> > I think there's a chance in that case that one of the quiescent clients
> > is experiencing a temporary network problem, in which case we may want
> > to preserve a few entries for them even if the active client's activity
> > would normally evict them.
> > 
> 
> Cache eviction policy is really orthogonal to how we organize it for
> efficient lookups. Currently, cache entries sit in a hash table for
> lookups, and on a LRU list for eviction.
> 
> We can certainly change either or both. I think the trick here is to
> nail down what semantics you want for the cache and then look at how
> best to organize it to achieve that.
> 
> OTOH, maybe we should see whether this is really a problem first before
> we go and try to fix anything.

Yeah.

--b.
