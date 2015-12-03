Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbbLCWIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Dec 2015 17:08:52 -0500
Date: Thu, 3 Dec 2015 17:08:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151203220850.GC19518@fieldses.org>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
 <565A7A14.4010902@gmail.com>
 <20151129084614.42fb1272@tlielax.poochiereds.net>
 <565BBB03.7020206@gmail.com>
 <20151130213420.GA31564@fieldses.org>
 <20151130193313.5bb10791@synchrony.poochiereds.net>
 <20151201115600.GA1557@lst.de>
 <20151201174800.407e2c40@synchrony.poochiereds.net>
 <20151202072504.GA15839@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151202072504.GA15839@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 02, 2015 at 08:25:04AM +0100, Christoph Hellwig wrote:
> On Tue, Dec 01, 2015 at 05:48:00PM -0500, Jeff Layton wrote:
> > > But for non-forgetful clients I wonder if returning 0 should be
> > > interpreted the same as NFS4ERR_DELAY?  Note that we still need to
> > > time out the client if it doesn't respond in time, so NFS4ERR_DELAY
> > > seems better than 0, but the standard doesn't really talk about
> > > return values other than NFS4ERR_NOMATCHING_LAYOUT.
> > 
> > My interpretation is somewhat different. To me, this is how we'd
> > interpret the response from the client (pseudocode):
> > 
> > NFS_OK:
> > 	/* Message received. I'll start returning these layouts soon. */
> > NFS4ERR_DELAY:
> > 	/* I'm too resource constrained to even process this simple
> >            request right now. Please ask me again in a bit. */
> > NFS4ERR_NOMATCHING_LAYOUT:
> > 	/* Huh? What layout? */
> > 
> > ...IMO, the spec is pretty clear that a successful response from the
> > client just means that it got the message that it should start
> > returning layouts. If it happens to return anything before the cb
> > response, then that's just luck/coincidence. The server shouldn't count
> > on that.
> 
> Ok, so for 0 we should re check if the layouts are still outstanding
> before sending the next recall.  But given that we have no client
> returning that or test cases I'd be tempted to treat OK like DELAY
> for now - if the client is properly implemented it will eventually
> return NFS4ERR_NOMATCHING_LAYOUT.  We can add a big comment on why
> we're doing that so that it's obvious.

OK, so if I understand right, the current code is letting the rpc state
machine drive the whole thing, and your proposal is that the rpc task
lasts until the client either responds NFS4ERR_NOMATCHING_LAYOUT or we
just run out of time.  (NOMATCHING_LAYOUT being the one response that
isn't either "try again" or "OK I'll get to it soon").

I understand why that would work, and that handling anything other than
the NOMATCHING_LAYOUT case is a lower priority for now, but this
approach worries me.

Is there a reason we can't do as in the delegation case, and track the
revocation timeout separately from the callback rpc?

--b.
