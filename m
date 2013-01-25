Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39572 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab3AYUfX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 15:35:23 -0500
Date: Fri, 25 Jan 2013 15:35:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ben Myers <bpm@sgi.com>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
        Jim Rees <rees@umich.edu>
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125203521.GE29596@fieldses.org>
References: <20130125192935.GA32470@sgi.com>
 <20130125202107.GD29596@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125202107.GD29596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 25, 2013 at 03:21:07PM -0500, J. Bruce Fields wrote:
> 
> > On Fri, Jan 25, 2013 at 01:29:35PM -0600, Ben Myers wrote:
> > > Hey Bruce & Jim & Olga,
> > > 
> > > On Fri, Jan 25, 2013 at 02:16:20PM -0500, Jim Rees wrote:
> > > > J. Bruce Fields wrote:
> > > > 
> > > >   On Thu, Jan 24, 2013 at 06:59:30PM -0600, Ben Myers wrote:
> > > >   > At 1020 threads the send buffer size wraps and becomes negative causing
> > > >   > the nfs server to grind to a halt.  Rather than setting bufsize based
> > > >   > upon the number of nfsd threads, make the buffer sizes tuneable via
> > > >   > module parameters.
> > > >   > 
> > > >   > Set the buffer sizes in terms of the number of rpcs you want to fit into
> > > >   > the buffer.
> > > >   
> > > >   From private communication, my understanding is that the original
> > > >   problem here was due to memory pressure forcing the tcp send buffer size
> > > >   below the size required to hold a single rpc.
> > > 
> > > Years ago I did see wrapping of the buffer size when tcp was used with many
> > > threads.  Today's problem is timeouts on a cluster with a heavy read
> > > workload... and I seem to remember seeing that the send buffer size was too
> > > small.
> > > 
> > > >   In which case the important variable here is lock_bufsize, as that's
> > > >   what prevents the buffer size from going too low.
> > > 
> > > I tested removing the lock of bufsize and did hit the timeouts, so the overflow
> > > is starting to look less relevant.  I will test your minimal overflow fix to
> > > see if this is the case.
> > 
> > The minimal overflow fix did not resolve the timeouts.
> 
> OK, thanks, that's expected.
> 
> > I will test with this to see if it resolves the timeouts:
> 
> And I'd expect that to do the job--but at the expense of some tcp
> bandwidth.  So you end up needing your other module parameters to get
> the performance back.

Also, what do you see happening on the server in the problem case--are
threads blocking in svc_send, or are they dropping replies?

--b.

> 
> --b.
> 
> > 
> > ---
> >  net/sunrpc/svcsock.c |    7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > Index: b/net/sunrpc/svcsock.c
> > ===================================================================
> > --- a/net/sunrpc/svcsock.c	2013-01-25 13:48:05.000000000 -0600
> > +++ b/net/sunrpc/svcsock.c	2013-01-25 13:49:42.000000000 -0600
> > @@ -435,6 +435,13 @@ static void svc_sock_setbufsize(struct s
> >  	lock_sock(sock->sk);
> >  	sock->sk->sk_sndbuf = snd * 2;
> >  	sock->sk->sk_rcvbuf = rcv * 2;
> > +
> > +	/*
> > +	 * The socket buffer can be resized by the networking code
> > +	 * unless you specify that this is not to be done.
> > +	 */
> > +	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
> > +
> >  	sock->sk->sk_write_space(sock->sk);
> >  	release_sock(sock->sk);
> >  #endif
> > 
> > Thanks,
> > Ben
