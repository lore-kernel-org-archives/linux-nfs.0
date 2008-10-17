From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more
 reasonable value
Date: Fri, 17 Oct 2008 18:10:57 -0400
Message-ID: <20081017181057.2b15b458@tleilax.poochiereds.net>
References: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
	<1224267970-15769-2-git-send-email-jlayton@redhat.com>
	<20081017211833.GF14960@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57206 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbYJQWL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 18:11:29 -0400
In-Reply-To: <20081017211833.GF14960@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2008 17:18:33 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Oct 17, 2008 at 02:26:10PM -0400, Jeff Layton wrote:
> > The default method for calculating the number of connections allowed
> > per RPC service arbitrarily limits single-threaded services to 80
> > connections. This is too low for services like lockd and artificially
> > limits the number of TCP clients that it can support.
> > 
> > Have lockd set a default sv_maxconn value to RLIMIT_NOFILE for the
> > lockd thread (usually this will be 1024). Also add a module parameter
> > to allow an admin to set this to an arbitrary value at module load
> > time.
> 
> I guess this is OK.
> 
> As long as we're picking a number out of thin air, I'd rather we make
> that obvious, instead of making it look like we made some kind of
> sophisticated choice that the poor reader will feel obliged to
> understand.
> 
> So I'd be for a default that's just a constant, until someone has a
> better idea.
> 

I'm OK with that too. I just used this since Neil suggested it. I have
no idea what a reasonable value should really be. I suppose this should
probably be set to the maximum number of clients we expect to support
(assuming 1 connection to lockd from each client).

1024 seems like a decent enough place to start. Big enough to allow for
a lot of clients, but not so big that the host will bog down if we hit
that number of connections.

> What would actually happen if we allowed too many connections?  What
> would fail first?  Is there some way to detect that situation and use
> that to drop connections?
> 

I'm not clear on this either. Here's my naive take (could be very 
wrong):

My best guess is that we'll end up in a situation where lockd (or
whatever service) eats up a bunch of CPU time trying to service
all of the requests.

I suppose that "legitimate" sockets will stall out since they may not
be getting serviced in a timely manner. Their buffers will be full, so
the TCP layer will shrink the window down to 0.

I could be way off base here though...

As far as detecting that, I'm not sure. Maybe we could somehow look
at how many sockets are waiting for their buffers to be cleared. It may
take a long time for that to happen though, a modern CPU can probably
handle a lot of sockets before it ends up in the weeds.

-- 
Jeff Layton <jlayton@redhat.com>
