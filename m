Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753768Ab2F0USJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 16:18:09 -0400
Date: Wed, 27 Jun 2012 16:18:07 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Harshula <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Message-ID: <20120627161807.7b6ec141@tlielax.poochiereds.net>
In-Reply-To: <1340825822.2398.10.camel@lade.trondhjem.org>
References: <1339764850.30233.11.camel@serendib>
	<20120615092103.15cc2b11@corrin.poochiereds.net>
	<1339795503.16363.9.camel@lade.trondhjem.org>
	<20120627115447.0fdf8c6e@corrin.poochiereds.net>
	<1340822635.2398.7.camel@lade.trondhjem.org>
	<20120627152814.4774048b@tlielax.poochiereds.net>
	<1340825822.2398.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 27 Jun 2012 19:37:03 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-06-27 at 15:28 -0400, Jeff Layton wrote:
> > On Wed, 27 Jun 2012 18:43:56 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > The reason why we close these sockets is that if the attempt at aborting
> > > the connection fails, then they typically end up in a TIME_WAIT state.
> > > 
> > 
> > I'm still trying to wade through the xprtsock.c socket handling code,
> > but it looks like we currently tear down the connection in 3 different
> > ways:
> > 
> > xs_close: which basically calls sock_release and gets rid of our
> > reference to an existing socket. Most of the places where we disconnect
> > the socket use this. After this, we end up with srcport == 0 which
> > makes it pick a new port.
> > 
> > xs_tcp_shutdown: which calls ->shutdown on it, but doesn't free
> > anything. This also preserves the existing srcport.
> > 
> > xs_abort_connection: calls kernel_connect to reconnect the socket to
> > AF_UNSPEC address (effectively disconnecting it?). This also preserves
> > the srcport. I guess we use this just before reconnecting when the
> > remote end drops the connection, since we don't need to be graceful
> > about tearing anything down at that point.
> > 
> > The last one actually does reuse the same socket, so my thinking was
> > that we could extend that scheme to the other cases. If we called
> > ->shutdown on it and then reconnected it to AF_UNSPEC, would that
> > "reset" it back to a usable state?
> 
> Not that I'm aware of. The problem is that most of this stuff is
> undocumented. For instance, the AF_UNSPEC reconnect is documented only
> for UDP connections. While Linux implements it for TCP too, there is no
> spec (that I'm aware of) that explains how that should work.
> 

...and fwiw, it looks like reconnecting a TCP socket to an AF_UNSPEC
address doesn't work from userland -- you get back EINVAL. I have to
wonder if xs_abort_connection actually works as expected...

> > If there really is no alternative to freeing the socket, then the only
> > real fix I can see is to set PF_MEMALLOC when we go to create it and
> > then reset it afterward. That's a pretty ugly fix though...
> 
> Agreed...
> 

That looks basically like what Mel is doing to work around the problem,
though he only does it for xprt's that are tagged as being swapped
over. We could just make that unconditional, but the "congested" flag
scheme sounds better.

-- 
Jeff Layton <jlayton@redhat.com>
