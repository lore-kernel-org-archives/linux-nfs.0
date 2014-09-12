Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36874 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbaILPVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2014 11:21:44 -0400
Date: Fri, 12 Sep 2014 11:21:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 5/7] nfsdcltrack: update schema to v2
Message-ID: <20140912152142.GB28915@fieldses.org>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
 <1410193821-25109-6-git-send-email-jlayton@primarydata.com>
 <20140911195547.GA21296@fieldses.org>
 <20140911162836.70056390@tlielax.poochiereds.net>
 <20140912093600.50dfa9bc@tlielax.poochiereds.net>
 <20140912102153.09d58de7@tlielax.poochiereds.net>
 <20140912143621.GA28915@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140912143621.GA28915@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2014 at 10:36:21AM -0400, J. Bruce Fields wrote:
> On Fri, Sep 12, 2014 at 10:21:53AM -0400, Jeff Layton wrote:
> > Grace period
> > eventually ends, and its record is purged from the DB.
> > 
> > Now we have a client that has reclaimed some files but that has no
> > record on stable storage.
> > 
> > One possibility is to prematurely expire v4.1+ clients that have not
> > sent a RECLAIM_COMPLETE when the grace period ends.
> > 
> > That seems problematic though -- what about clients that just happen to
> > do an EXCHANGE_ID just before the grace period is going to end, and
> > that get expired before they can issue their RECLAIM_COMPLETE. Will
> > that be a problem for them?
> 
> In that case a client will send a reclaim, get back a NO_GRACE error,
> mark the rest of its state as unrecoverable, send the RECLAIM_COMPLETE,
> and continue normally.  (To the extent it can--signalling affected
> processes or EIOing further attempts to use the unreclaimed state, or
> whatever.)

The one thing the server *could* do in this sort of case is extend the
grace period by a little--I seem to recall the spec giving some leeway
for this kind of thing.

So for example the server could have a heuristics like: extend the grace
period by another second each time we notice there's been an EXCHANGE_ID
or reclaim in the previous second, up to some maximum.  And I suppose it
could also delay the grace period until someone actually attempts a
non-reclaim open.

In isolation a single client slipping in the end like that sounds like a
freak event, but if there's a ton of state to reclaim perhaps it could
become more likely.

I don't think that's a priority, we might just want to make sure we know
how to do that in the future.

But now that I think about it I don't see the existing or proposed
nfsdcltrack stuff tying our hands in any way here.  It just gives the
kernel some extra information, and the kernel still has discretion about
when exactly it wants to end the grace period.

--b.
