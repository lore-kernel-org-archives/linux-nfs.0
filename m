From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Thu, 23 Oct 2008 23:57:59 -0700
Message-ID: <20081024065759.GA2401@zoy.org>
References: <20081023040231.GA13512@zoy.org> <1224776207.7625.7.camel@localhost> <20081023195231.GA2090@zoy.org> <1224803879.7625.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:39103 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbYJXG6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 02:58:03 -0400
In-Reply-To: <1224803879.7625.79.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2008 at 07:17:59PM -0400, Trond Myklebust wrote:
> > (I'm still concerned about the 3 second delay here...)
> Does this patch fix that delay?
> 
> SUNRPC: Fix the setting of xprt->reestablish_timeout when reconnecting

I applied this on top of the previous patch and it worked - but now I'm
not sure if you wanted to test this as an independant patch ???

I'm wondering how the code in xs_tcp_state_change() that sets
reestablish_timeout back to XS_TCP_INIT_REEST_TO managed to not cause trouble.


Can I propose a patch too ? mine looks quite similar to your second patch,
but with the reestablish_timeout logic hopefully simplified...



SUNRPC: Fix the setting of xprt->reestablish_timeout when reconnecting

The proposed logic works as follows:

* The reestablish_timeout is initially set to zero (no delay before the
  initial connection). It is also reset to zero upon establishing a
  successful TCP connection (no delay next time we try to reopen the
  connection, whether it got closed by the client or the server side).
  This fixes an issue where we would wait 5-minute after receiving an RST
  from the server rather than retrying immediately (bug 11154).

* xs_connect() delays the (re)connection by reestablish_timeout jiffies.
  reestablish_timeout for the *next* connection attempt is also
  updated to a nonzero value at that point (constant for UDP case,
  exponential backoff for TCP case). There used to be an issue where
  we would apply the exponential backoff even in the UDP case.

Signed-off-by: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
---

--- net/sunrpc/xprtsock.c.orig	2008-10-23 10:43:31.000000000 -0700
+++ net/sunrpc/xprtsock.c	2008-10-23 22:10:50.000000000 -0700
@@ -1134,6 +1134,7 @@
 			transport->tcp_flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
+			xprt->reestablish_timeout = 0;
 			xprt_wake_pending_tasks(xprt, 0);
 		}
 		spin_unlock_bh(&xprt->transport_lock);
@@ -1141,7 +1142,6 @@
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
 		xprt->connect_cookie++;
-		xprt->reestablish_timeout = 0;
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
@@ -1154,13 +1154,6 @@
 		xprt_force_disconnect(xprt);
 	case TCP_SYN_SENT:
 		xprt->connect_cookie++;
-	case TCP_CLOSING:
-		/*
-		 * If the server closed down the connection, make sure that
-		 * we back off before reconnecting
-		 */
-		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
-			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		break;
 	case TCP_LAST_ACK:
 		smp_mb__before_clear_bit();
@@ -1755,25 +1748,25 @@
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	unsigned long timeout;
 
 	if (xprt_test_and_set_connecting(xprt))
 		return;
 
-	if (transport->sock != NULL) {
-		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
-				"seconds\n",
-				xprt, xprt->reestablish_timeout / HZ);
-		queue_delayed_work(rpciod_workqueue,
-				   &transport->connect_worker,
-				   xprt->reestablish_timeout);
+	timeout = xprt->reestablish_timeout;
+	if (xprt->prot != IPPROTO_TCP)
+		xprt->reestablish_timeout = XS_UDP_REEST_TO;
+	else if (xprt->reestablish_timeout == 0)
+		xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	else {
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
-	} else {
-		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
-		queue_delayed_work(rpciod_workqueue,
-				   &transport->connect_worker, 0);
 	}
+	dprintk("RPC:       xs_connect delayed xprt %p for %lu seconds\n",
+		xprt, timeout / HZ);
+	queue_delayed_work(rpciod_workqueue, &transport->connect_worker,
+			   timeout);
 }
 
 static void xs_tcp_connect(struct rpc_task *task)
@@ -1935,7 +1928,7 @@
 
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
-	xprt->reestablish_timeout = XS_UDP_REEST_TO;
+	xprt->reestablish_timeout = 0;
 	xprt->idle_timeout = XS_IDLE_DISC_TO;
 
 	xprt->ops = &xs_udp_ops;
@@ -2003,7 +1996,7 @@
 
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_TCP_CONN_TO;
-	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->reestablish_timeout = 0;
 	xprt->idle_timeout = XS_IDLE_DISC_TO;
 
 	xprt->ops = &xs_tcp_ops;


Hope this helps,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
