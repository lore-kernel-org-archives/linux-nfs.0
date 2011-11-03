Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34412 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381Ab1KCVUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 17:20:38 -0400
Date: Thu, 3 Nov 2011 17:20:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111103212036.GB27393@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
 <20111101202715.GB1891@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7BC5@SACMVEXC2-PRD.hq.netapp.com>
 <20111101204325.522c35b3@corrin.poochiereds.net>
 <20111102012315.GA5532@fieldses.org>
 <20111102070742.5354d83c@tlielax.poochiereds.net>
 <20111102144657.GD7721@fieldses.org>
 <20111102115453.7e81168f@corrin.poochiereds.net>
 <20111103204449.GA27393@fieldses.org>
 <1320354185.18396.124.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320354185.18396.124.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 03, 2011 at 05:03:05PM -0400, Trond Myklebust wrote:
> On Thu, 2011-11-03 at 16:44 -0400, J. Bruce Fields wrote: 
> > I'm feeling dense.
> > 
> > On Wed, Nov 02, 2011 at 11:54:53AM -0400, Jeff Layton wrote:
> > > Yes, I think it is different. When we truncate the file to 0 then we
> > > don't care if another write races in.
> > 
> > 	Client 1		Client 2
> > 	--------		--------
> > 
> > 	setattr size to 0
> > 				write to file
> > 	get change attribute
> > 
> > If we decide not to invalidate the cache here, then we miss Client 2's
> > write.  The same is true if we set the size to something other than 0.
> 
> ?????????
> How can we "decide not to invalidate the cache here"? the call to
> nfs_vmtruncate() will _always_ call truncate_pagecache().
> The only case where we don't call nfs_vmtruncate() is if the client has
> already determined that the file size was zero, and optimised away the
> setattr call altogether.

Sorry, I'm probably using the wrong language.

I'm using the word "cache" to refer not to the page cache, but more
generally to the client's idea of the file state.  Thus if the client,
after the above operation, is left believing the file has size 0, I
wouldn't say it has invalidated its cache, I'd say it's cached the fact
that the file has size zero....

Does what I said make sense, given that?

> > There's a second possible race when Client 2's write comes before the
> > setattr, and it's true that that race doesn't matter in the size-0 case
> > and does in the other.
> > 
> > But if we were doing a write instead of a setattr, we'd ignore that
> > second race.
> > 
> > And I don't understand why something like ftruncate should be treated
> > differently from write.  In either case we're modifying a file while
> > holding a write open, and I'd expect us to assume in both cases that
> > nobody else is doing the same.
> 
> When did we move to the topic of multiple clients, and why do you think
> it is relevant?

We're seeing the client decide that it can no longer trust its idea of
the file, presumably because it no longer believes it safe to assume
that nobody else has modified it.

--b.
