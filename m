Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40905 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab0IWDXJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 23:23:09 -0400
Date: Thu, 23 Sep 2010 13:23:02 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/7] sunrpc/cache: allow thread manager more control of
 whether threads can wait for upcalls
Message-ID: <20100923132302.3b15fde1@notabene>
In-Reply-To: <20100922183622.GD26903@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
	<20100922025507.31745.30398.stgit@localhost.localdomain>
	<20100922183622.GD26903@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 22 Sep 2010 14:36:22 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Sep 22, 2010 at 12:55:07PM +1000, NeilBrown wrote:
> > Rather than blindly setting a timeout based on a course idea of
> > busy-ness, allow the 'cache' to call into the 'rqstp' manager to
> > request permission to wait for an upcall, and how long to wait for.
> > 
> > This allows the thread manager to know how many threads are waiting
> > and reduce the permitted timeout when there are a large number.
> > 
> > The same code can check if waiting makes any sense (which it doesn't
> > on single-threaded services) or if deferral is allowed (which it isn't
> > e.g. for NFSv4).
> > 
> > The current heuristic is to allow a long wait (30 sec) if fewer than
> > 1/2 the threads are waiting, and to allow no wait at all if there are
> > more than 1/2 already waiting.
> > 
> > This provides better guaranties that slow responses to upcalls will
> > not block too many threads for too long.
> 
> I suppose you're probably looking for comments on the idea rather than
> the particular choice of heuristic, but:  wasn't one of the motivations
> that a cache flush in the midst of heavy write traffic could cause long
> delays due to writes being dropped?
> 
> That seems like a case where most threads may handling rpc's, but
> waiting is still preferable to dropping.
> 

All comments are welcome - thanks.

Yes, the heuristic needs careful thought.

Currently a high level of traffic after a cache flush (and with slow mountd)
will cause the first 300 requests to get deferred and subsequent requests to
either be dropped or to cause old requests to be dropped.

With the proposed code, the '300' becomes 'half the number of nfsd threads'.
This is smaller by default (bad) but configurable (good).

I think making it configurable is much more important than having it large by
default.  But maybe 3/4 would be better than 1/2.

I keep thinking that it would be really nice to have a dynamic thread pool,
but I'm that sure that would do more than just move the problem...

Another approach we could take (which only really works for tcp) is to count
the number of waiting requests against each connection (rqstp) and if a
single connection has "more than it's fair share" we stop accepting requests
on that connection, while still allowing new requests on connections where
there are fewer waiting requests.... sounds a bit complex though.

There is probably a really nice solution and I just cannot see it (maybe the
solution is just to ignore the 'problem' and allow any request to wait as
long as it likes).

Thanks,
NeilBrown
