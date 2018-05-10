Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:24613 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbeEJVM4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 17:12:56 -0400
Date: Thu, 10 May 2018 21:12:50 +0000
From: Vallish Vaidyeshwara <vallish@amazon.com>
To: Trond Myklebust <trondmy@hammerspace.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jsstraus@amazon.com" <jsstraus@amazon.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 2/2] SUNRPC: Reconnect with new port on server initiated
 connection termination
Message-ID: <20180510211250.GA50901@amazon.com>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
 <1525932774-98736-3-git-send-email-vallish@amazon.com>
 <aa092f62079986ec164863f33873b278f69f79a9.camel@hammerspace.com>
 <20180510162202.GA24317@amazon.com>
 <08366f6b15fd26aa2523dc9375bffd0cb3955940.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <08366f6b15fd26aa2523dc9375bffd0cb3955940.camel@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 05:26:12PM +0000, Trond Myklebust wrote:
> On Thu, 2018-05-10 at 16:22 +0000, Vallish Vaidyeshwara wrote:
> > On Thu, May 10, 2018 at 03:25:14PM +0000, Trond Myklebust wrote:
> > > On Thu, 2018-05-10 at 06:12 +0000, Vallish Vaidyeshwara wrote:
> > > > Server initiated socket close can corrupt connection state
> > > > tracking
> > > > table in conjunction with other network middle boxes. In
> > > > situations
> > > > like these, client connection hangs till connection state
> > > > tracking
> > > > table entries age out and get purged. Client reconnection with a
> > > > new
> > > > port in such a situation will avoid connection hang.
> > > > 
> > > > Reviewed-by: Jacob Strauss <jsstraus@amazon.com>
> > > > Reviewed-by: Alakesh Haloi <alakeshh@amazon.com>
> > > > Signed-off-by: Vallish Vaidyeshwara <vallish@amazon.com>
> > > > ---
> > > >  net/sunrpc/xprtsock.c | 5 +++++
> > > >  1 file changed, 5 insertions(+)
> > > > 
> > > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > > > index 5bf75b3..d293c8d 100644
> > > > --- a/net/sunrpc/xprtsock.c
> > > > +++ b/net/sunrpc/xprtsock.c
> > > > @@ -1629,6 +1629,8 @@ static void xs_tcp_state_change(struct sock
> > > > *sk)
> > > >  		/* The server initiated a shutdown of the socket
> > > > */
> > > >  		xprt->connect_cookie++;
> > > >  		clear_bit(XPRT_CONNECTED, &xprt->state);
> > > > +		/* Server sent FIN, reconnect with a new port */
> > > > +		transport->srcport = 0;
> > > >  		xs_tcp_force_close(xprt);
> > > >  		/* fall through */
> > > >  	case TCP_CLOSING:
> > > > @@ -1650,6 +1652,9 @@ static void xs_tcp_state_change(struct sock
> > > > *sk)
> > > >  					&transport->sock_state))
> > > >  			xprt_clear_connecting(xprt);
> > > >  		clear_bit(XPRT_CLOSING, &xprt->state);
> > > > +		/* Server sent RST, reconnect with a new port */
> > > > +		if (sk->sk_err == ECONNRESET)
> > > > +			transport->srcport = 0;
> > > >  		if (sk->sk_err)
> > > >  			xprt_wake_pending_tasks(xprt, -sk-
> > > > >sk_err);
> > > >  		/* Trigger the socket release */
> > > 
> > > NACK. This will utterly break NFSv2, NFSv3 and NFSv4.0 duplicate
> > > replay
> > > cache semantics. 
> > > 
> > > Cheers
> > >   Trond
> > > -- 
> > > Trond Myklebust
> > > Linux NFS client maintainer, Hammerspace
> > > trond.myklebust@hammerspace.com
> > 
> > Hello Trond,
> > 
> > The first patch in this series is actually helping restore DRC
> > behavior in
> > cases like network partition where packets are dropped:
> > [PATCH 1/2] SUNRPC: Need to reuse non-reserved port for reconnect
> > Patch 1 starts reusing port in all cases.
> > 
> > The second patch is still not breaking DRC semantics, to quote from
> > source
> > code:
> > 
> > <code snip>
> >   /**
> >    * xs_close - close a socket
> >    * @xprt: transport
> >    *
> >    * This is used when all requests are complete; ie, no DRC state
> > remains
> >    * on the server we want to save.
> >    *
> >    * The caller _must_ be holding XPRT_LOCKED in order to avoid
> > issues with
> >    * xs_reset_transport() zeroing the socket from underneath a
> > writer.
> >    */
> >   static void xs_close(struct rpc_xprt *xprt)
> > <code snip>
> > 
> > If the server has closed a connection, then no DRC state remains on
> > the server
> > we want to use.
> > 
> > The second patch is exploiting this semantics and using a new port in
> > following
> > 2 cases:
> > a) RST from server implies the connection was torn down & no useful
> > DRC exists
> > on server
> > b) FIN from server implies that server is shutting down the
> > connection as part
> > of close and no DRC state remains
> > 
> > Please let me know if I have missed something obvious, I definitely
> > do not want
> > to break DRC as that is not the intention of this patch series. Is
> > there a
> > situation where server can close a connection and still keep DRC?
> > 
> 
> The DRC does not exist for the benefit of the server, but for the
> benefit of the client. It is there to ensure that if the client replays
> the request, then it gets the exact same reply as it should have
> received when the first request was sent. Bearing that in mind:
> 
>    1. What guarantees that all servers behave correctly w.r.t. ensuring
>       that they have sent all replies to any outstanding RPC call before
>       shutting down the connection. I'm not sure that even the Linux
>       server does that.
>    2. How would a server even know whether or not the client may need to
>       replay a request?
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

Hello Trond,

Thanks for the explanation, I was kind of misled by code comments in
xs_close.I will probably submit a different patch to clean up these code
comments which can mislead others as well.

Regards,
-Vallish
