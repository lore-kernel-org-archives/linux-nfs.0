Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663AbbLGQnl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:43:41 -0500
Date: Mon, 7 Dec 2015 11:43:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207164339.GF13288@fieldses.org>
References: <20151203220850.GC19518@fieldses.org>
 <20151204083803.GA2440@lst.de>
 <20151204155110.64a352dd@tlielax.poochiereds.net>
 <20151205120222.GA27009@lst.de>
 <20151205072409.46d66109@tlielax.poochiereds.net>
 <20151206080954.1fe7e5c9@tlielax.poochiereds.net>
 <20151207130932.GB30843@lst.de>
 <20151207082803.0b160bb6@tlielax.poochiereds.net>
 <20151207141701.GA1376@lst.de>
 <20151207111226.6e56f7ab@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151207111226.6e56f7ab@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2015 at 11:12:26AM -0500, Jeff Layton wrote:
> On Mon, 7 Dec 2015 15:17:01 +0100
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > On Mon, Dec 07, 2015 at 08:28:03AM -0500, Jeff Layton wrote:
> > > My understanding is that you need to increment the seqid when prior to
> > > sending the callback. The basic idea there is that you want to ensure
> > > that any LAYOUTGETs that were sent before the CB_LAYOUTRECALL get back
> > > an OLD_STATEID error. RFC5661, Section 12.5.3:
> > > 
> > >     After the layout stateid is established, the server increments by
> > >     one the value of the "seqid" in each subsequent LAYOUTGET and
> > >     LAYOUTRETURN response, and in each CB_LAYOUTRECALL request.
> > 
> > True.  Although I really don't see any way to make layoutrecall processing
> > race free that way.  I guess your patch to just drop the mutex is the
> > best we could do.
> > 
> > Note that it doesn't really matter for the current server, as we will
> > always recall the whole file, and thus leave no layout state for it on
> > the client.  But for finger grained recalls this could become a
> > problem.
> 
> 
> Just thinking out loud...
> 
> So we inc the seqid when sending the recall, and then the
> layoutreturn(s) will inc it again, so that should cover those cases.
> 
> Let's suppose that the client returns 0 for the CB though, but never
> actually returns the layouts. At that point I guess we need to revoke
> the whole stateid, similarly to how we revoke delegations that aren't
> returned.
> 
> The catch here is that the revocation timer is the same as the RPC
> timeout period. It doesn't seem like there ought to be any relationship
> there. It ought to be 1-2 lease periods, IIRC?

Currently it's retrying indefinitely, with a comment that it should cap
the number of retries somehow.  So we'd just do the arithmetic to pick a
number of retries that works.

I think current client behavior should prevent any of this being a
problem in practice?

But people who read the spec should have at least a fighting chance of
writing a working client.  I don't like the idea that somebody's going
to make a perfectly legal client change and suddenly the client will
fail.

As Christoph says we can end up in that situation just as easily by
writing more complicated code and not testing those cases.  And there's
probably some of that in the current sessions backchannel code.

Argh.  I guess I'll take a shot at some pynfs tests....

--b.
