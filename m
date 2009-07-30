From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] SUNRPC: reset TCP reconnect exponential back-off on
 successful connection.
Date: Thu, 30 Jul 2009 16:28:06 +1000
Message-ID: <19057.15734.77463.302829@notabene.brown>
References: <19040.11777.346898.322780@notabene.brown>
	<1248217664.5034.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40919 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbZG3G1y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2009 02:27:54 -0400
In-Reply-To: message from Trond Myklebust on Tuesday July 21
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday July 21, trond.myklebust@fys.uio.no wrote:
> On Fri, 2009-07-17 at 17:53 +1000, Neil Brown wrote:
> > Hi.
> >  A customer of ours has been testing NFS failover and has been
> >  experiencing unexpected delays before the client starts writing
> >  again.   It turns out there are a number of issues here, some client
> >  and some server.
> > 
> >  This patch fixes two client issues, one that causes the failover time
> >  to double on each migration (or each time the NFS server is stopped
> >  and restarted), and one that causes the client to spam the server
> >  with SYN requests until it accepts the connection (I have a trace
> >  showing over 100 SYN requests, each followed by a RST,ACK reply, in
> >  the space for 300 milliseconds).
> > 
> >  I am able to simulate the first failure and have tested that the
> >  patch fixes it.  I have not managed to simulate the second failure,
> >  but I think that fix is clearly safe.
> > 
> >  I'm not sure that the patch fits the original definition for -stable,
> >  but it seems to fit the current practice and I would appreciate if
> >  (assuming the patch passes review) it could be submitted for -stable.
> > 
> > Thanks,
> > NeilBrown
> > 
> > 
> > 
> > The sunrpc/TCP transport has an exponential back-off for reconnection,
> > starting at 3 seconds and with a maximum of 300 seconds.  On every
> > connection attempt the timeout is doubled.
> > It is only reset when the client deliberately closes the connection.
> > If the server closes the connection but a subsequent reconnect
> > succeeds, the timeout remains elevated.
> > 
> > This means that if the server resets the connection several times, as
> > can happen with server migration in a clustered environment, each
> > reconnect takes longer than the previous one - unnecessarily so.
> > 
> > This patch resets the timeout on a successful connection so that every
> > time the server resets the connection we start with a basic 3 second
> > timeout.
> 
> I seem to remember a situation (was it with NetApp filers?) where the
> server would accept the connection, but then immediately abort it
> because the services weren't all finished booting.
> 
> IMO, the rule should therefore be that if a server aborts the
> connection, we should assume it is in some sort of trouble, and be
> careful when reconnecting.
> 
> Now, that said, if the server has been operating fine for several
> minutes before aborting the connection, we could definitely be a bit
> more aggressive about the reconnection timeout. Could we rather do that?

Yes, I agree that somehow measuring the time that the connection was
up for would be good.  The following patch tries to do that but I'm
not entirely happy with it and I've spent too long for today getting
confused by this code.  I'll try to get back to it in a few days, but
any suggests for improvements would be very welcome.

> 
> > There is also the possibility for the reverse problem.  When the
> > client closes the connection it sets the timeout to 0 (so that a
> > reconnect - when required - is instant).  When 0 is doubled it remains
> > at 0, so if the server refused the reconnect, the client will try
> > again instantly and indefinitely.  To avoid this we ensure that after
> > doubling the timeout it is at least the minimum.
> 
> Is this true? AFAICS, we always ensure xprt->reestablish_timeout is
> non-zero when we enter TCP_SYN_SENT.

You would think so.  But I seem to have evidence to the contrary...
So I turned on some debugging to see what states gets reported
in xs_tcp_state_change.
When stopping and restarting the server I usually only see
states 7 and 1.  i.e. TCP_CLOSE and TCP_ESTABLISHED.
In a very few cases I have seen 8 and 9 (CLOSE_WAIT, LAST_ACK) before
7.  So it seems that we cannot rely on seeing every state.


Something else I have found that is strange:
  When the ->connect_worker timer (set in xs_connect at 15:15:13 in
  log below) fires (15:15:16) it initiates a connection (worker
  connecting...) which reports EINPROGRESS (115) and then immediately
  xs_tcp_send_request get -EAGAIN and xs_connect gets called again
  (even though a connection is in progress).  So the timer is set for
  another 2N seconds.
  The connection then completes and NFS traffic resumes.  But this timer
  is still running.....

Jul 30 15:15:13 dell kernel: RPC:       xs_connect delayed xprt ffff8800768af000 for 3 seconds
Jul 30 15:15:16 dell kernel: RPC:       disconnecting xprt ffff8800768af000 to reuse port
Jul 30 15:15:16 dell kernel: RPC:       xs_error_report client ffff8800768af000...
Jul 30 15:15:16 dell kernel: RPC:       error 0
Jul 30 15:15:16 dell kernel: RPC:       worker connecting xprt ffff8800768af000 to address: addr=192.168.1.3 port=0 proto=tcp
Jul 30 15:15:16 dell kernel: RPC:       ffff8800768af000 connect status 115 connected 0 sock state 2
Jul 30 15:15:16 dell kernel: RPC:       xs_tcp_send_request(262276) = -11
Jul 30 15:15:16 dell kernel: RPC:  6184 xmit incomplete (262276 left of 262276)
Jul 30 15:15:16 dell kernel: RPC:       xs_connect delayed xprt ffff8800768af000 for 6 seconds
Jul 30 15:15:16 dell kernel: RPC:       xs_tcp_state_change client ffff8800768af000...
Jul 30 15:15:16 dell kernel: RPC:       state 1 conn 0 dead 0 zapped 1


  When the timer fires it will try to re-establish the connection, but
  as far as I can tell that ends up as a no-op as the connection is
  already running.
  However....
  If the server has been inactive for a while and the
  reestablish_timeout has got fairly high, say 96 seconds, when the
  server comes back, then this timer will be hanging around for quite
  a while.  If the server restarts during this 96 seconds, xs_connect
  will be called to re-establish the connection but will find that
  xprt_test_and_set_connecting returns true, so it won't do anything.
  We have to wait for that 96 seconds to fully time out before it
  retries.

  This feels rather clumsy to me.  Maybe the timer should be deleted
  once the connection is successful?  Or something ....

Anyway, here is my current patch which improves things but should cope
better with a server which accepts and immediately drops the
connection.

Thanks for any insights...

NeilBrown


diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1175d58..02599d2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -162,6 +162,7 @@ struct rpc_xprt {
 	unsigned long		connect_timeout,
 				bind_timeout,
 				reestablish_timeout;
+	unsigned long		last_connect;
 	unsigned int		connect_cookie;	/* A cookie that gets bumped
 						   every time the transport
 						   is reconnected */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..2889b92 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1391,6 +1391,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
 		spin_lock_bh(&xprt->transport_lock);
+		xprt->last_connect = jiffies;
 		if (!xprt_test_and_set_connected(xprt)) {
 			struct sock_xprt *transport = container_of(xprt,
 					struct sock_xprt, xprt);
@@ -1438,6 +1439,11 @@ static void xs_tcp_state_change(struct sock *sk)
 		smp_mb__after_clear_bit();
 		break;
 	case TCP_CLOSE:
+		if (time_before(xprt->last_connect,
+				jiffies - XS_TCP_INIT_REEST_TO))
+			/* has been connected for long enough */
+			xprt->reestablish_timeout = 0;
+		xprt->last_connect = jiffies + XS_TCP_MAX_REEST_TO;
 		xs_tcp_cancel_linger_timeout(xprt);
 		xs_sock_mark_closed(xprt);
 	}
@@ -2090,6 +2096,8 @@ static void xs_connect(struct rpc_task *task)
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
