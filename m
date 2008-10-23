From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Thu, 23 Oct 2008 19:17:59 -0400
Message-ID: <1224803879.7625.79.camel@localhost>
References: <20081023040231.GA13512@zoy.org>
	 <1224776207.7625.7.camel@localhost>  <20081023195231.GA2090@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40586 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080AbYJWXSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 19:18:04 -0400
In-Reply-To: <20081023195231.GA2090-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-23 at 12:52 -0700, Michel Lespinasse wrote:
> Hi,
> 
> On Thu, Oct 23, 2008 at 11:36:47AM -0400, Trond Myklebust wrote:
> > Does the appended patch make a difference?
> > 
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date: Thu, 23 Oct 2008 11:33:59 -0400
> > SUNRPC: Respond promptly to server TCP resets
> 
> I applied it over a 2.6.27.3 base, suspended the client for 40 minutes
> and resumed it, logging what happens from the server side. The resume
> went like this:
> 
> 12:38:53.692785 IP client.329262748 > server.nfs: 100 getattr [|nfs]
> 12:38:53.699885 arp who-has client tell server
> 12:38:54.123793 IP client.329262748 > server.nfs: 100 getattr [|nfs]
> 12:38:54.695888 arp who-has client tell server
> 12:38:54.696011 arp reply client is-at 00:19:d1:54:0e:39 (oui Unknown)
> 12:38:54.696020 IP server.nfs > client.882: R 2944642919:2944642919(0) win 0
> 12:38:54.696024 IP server.nfs > client.882: R 2944642919:2944642919(0) win 0
> 
> (I'm still concerned about the 3 second delay here...)
> 
> 12:38:57.695956 IP client.2 > server.nfs: 0 null

Does this patch fix that delay?

Cheers
  Trond

-------------------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 23 Oct 2008 19:14:55 -0400
SUNRPC: Fix the setting of xprt->reestablish_timeout when reconnecting

If the server aborts an established connection, then we should retry
connecting immediately. Since xprt->reestablish_timeout is not reset unless
we go through a TCP_FIN_WAIT1 state, we may end waiting.
The fix is to reset xprt->reestablish_timeout in TCP_ESTABLISHED, and then
rely on the fact that we set it to non-zero values in all other cases when
the server closes the connection.

Also fix a race between xs_connect() and xs_tcp_state_change(). The
value of xprt->reestablish_timeout should be updated before we actually
attempt the connection.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0a50361..ac2aa52 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1144,6 +1144,8 @@ static void xs_tcp_state_change(struct sock *sk)
 			struct sock_xprt *transport = container_of(xprt,
 					struct sock_xprt, xprt);
 
+			xprt->reestablish_timeout = 0;
+
 			/* Reset TCP record info */
 			transport->tcp_offset = 0;
 			transport->tcp_reclen = 0;
@@ -1158,7 +1160,6 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
 		xprt->connect_cookie++;
-		xprt->reestablish_timeout = 0;
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
@@ -1793,6 +1794,7 @@ static void xs_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	unsigned long timeout;
 
 	if (xprt_test_and_set_connecting(xprt))
 		return;
@@ -1801,12 +1803,12 @@ static void xs_connect(struct rpc_task *task)
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-		queue_delayed_work(rpciod_workqueue,
-				   &transport->connect_worker,
-				   xprt->reestablish_timeout);
+		timeout = xprt->reestablish_timeout;
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker, timeout);
 	} else {
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 		queue_delayed_work(rpciod_workqueue,


