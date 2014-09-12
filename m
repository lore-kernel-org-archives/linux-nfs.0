Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333AbaILOgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2014 10:36:23 -0400
Date: Fri, 12 Sep 2014 10:36:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 5/7] nfsdcltrack: update schema to v2
Message-ID: <20140912143621.GA28915@fieldses.org>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
 <1410193821-25109-6-git-send-email-jlayton@primarydata.com>
 <20140911195547.GA21296@fieldses.org>
 <20140911162836.70056390@tlielax.poochiereds.net>
 <20140912093600.50dfa9bc@tlielax.poochiereds.net>
 <20140912102153.09d58de7@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140912102153.09d58de7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2014 at 10:21:53AM -0400, Jeff Layton wrote:
> On Fri, 12 Sep 2014 09:36:00 -0400
> Jeff Layton <jlayton@primarydata.com> wrote:
> 
> > On Thu, 11 Sep 2014 16:28:36 -0400
> > Jeff Layton <jeff.layton@primarydata.com> wrote:
> > 
> > > On Thu, 11 Sep 2014 15:55:47 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Mon, Sep 08, 2014 at 12:30:19PM -0400, Jeff Layton wrote:
> > > > > From: Jeff Layton <jlayton@poochiereds.net>
> > > > > 
> > > > > In order to allow knfsd's lock manager to lift its grace period early,
> > > > > we need to figure out whether all clients have finished reclaiming
> > > > > their state not. Unfortunately, the current code doesn't allow us to
> > > > > ascertain this. All we track for each client is a timestamp that tells
> > > > > us when the last "check" or "create" operation came in.
> > > > > 
> > > > > We need to track the two timestamps separately. Add a new
> > > > > "reclaim_complete" column to the database that tells us when the last
> > > > > "create" operation came in. For now, we just insert "0" in that column
> > > > > but a later patch will make it so that we insert a real timestamp for
> > > > > v4.1+ client records.
> > > > 
> > > > If I understand correctly, then nfsdcltrack has a bug here: we shouldn't
> > > > be counting a 4.1 client as allowed to reclaim on the next boot until we
> > > > get the RECLAIM_COMPLETE, but nfsdcltrack is allowing a 4.1 client to
> > > > reclaim if all we got the previous boot was a reclaim open (a "check"
> > > > operation).
> > > > 
> > > > --b.
> > > > 
> > > 
> > > Yeah, I guess so, with a bit of a clarification I think...
> > > 
> > > We don't want to allow a v4.1 client to reclaim if it didn't send a
> > > RECLAIM_COMPLETE prior to the last reboot *and* the grace period ended
> > > prior to the last reboot.
> > > 
> > > IOW, in the case where the reboot occurs before the grace period ends,
> > > we don't want to clean out the and deny reclaims. FWIW, the legacy
> > > client tracker got this very wrong -- if you did a couple of rapid
> > > reboots in succession you couldn't reclaim once everything was back up.
> > > 
> > > I'll have to ponder how best to fix that. Given that the logic required
> > > is quite different between v4.0 and v4.1 clients, we may have to add yet
> > > another column to the DB to track what sort of client this is.
> > > 
> > 
> > This new requirement complicates things quite a bit. I'll have to
> > respin both patchsets.
> > 
> > I think we can fix this by ensuring that we clean out any v4.1+ clients
> > that have not done a "create" since the start of the grace period
> > during a "grace_done" upcall. For v4.0 clients, we can't do that of
> > course since a v4.0 client may reclaim opens but never do a new one
> > (and so may never send a "create" at all).
> > 
> > That means that we'll need also to send something in the "check" upcall
> > that indicates the client's minorversion. The good news is that we
> > won't need a new column in the DB since the only timestamp that matters
> > for v4.1+ clients is the "create" time. We can just avoid setting the
> > time field for v4.1+ clients on the "check" upcall.
> > 
> > Now that we need to send info about the minorversion in a "check", I
> > may go back to sending an actual minorversion in the upcall's
> > environment vars. It doesn't make sense to me to send a boolean about
> > RECLAIM_COMPLETE when the client hasn't actually sent one.
> > 
> > I'll get started on reworking this but I have no idea on an ETA just
> > yet. Hopefully I can have something that works by next week sometime.
> >  
> 
> This is actually a much larger can of worms than it originally looks.
> Consider this:
> 
> Server reboots and v4.1+ client reclaims a few records but never sends
> a RECLAIM_COMPLETE (client bug or maybe some bad timing?).

The client must send a RECLAIM_COMPLETE.  It's not permitted to do any
regular opens, for example, till it does.

So either the client is buggy (too bad), or it's lost touch with the
server (in which case it will eventually expire normally).

I don't see any work to do here.

> Grace period
> eventually ends, and its record is purged from the DB.
> 
> Now we have a client that has reclaimed some files but that has no
> record on stable storage.
> 
> One possibility is to prematurely expire v4.1+ clients that have not
> sent a RECLAIM_COMPLETE when the grace period ends.
> 
> That seems problematic though -- what about clients that just happen to
> do an EXCHANGE_ID just before the grace period is going to end, and
> that get expired before they can issue their RECLAIM_COMPLETE. Will
> that be a problem for them?

In that case a client will send a reclaim, get back a NO_GRACE error,
mark the rest of its state as unrecoverable, send the RECLAIM_COMPLETE,
and continue normally.  (To the extent it can--signalling affected
processes or EIOing further attempts to use the unreclaimed state, or
whatever.)

--b.
