From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Thu, 23 Oct 2008 11:36:47 -0400
Message-ID: <1224776207.7625.7.camel@localhost>
References: <20081023040231.GA13512@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47185 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbYJWPgw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 11:36:52 -0400
In-Reply-To: <20081023040231.GA13512-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-22 at 21:02 -0700, Michel Lespinasse wrote:
> I sent this out to LKML earlier but was told this would be a better list.
> This has been mentionned in bugzilla already, but I'd like to draw attention
> before it gets too late for 2.6.28 (or is it already too late ???)
> 
> The following is a common cause of 5-minute NFS hangs here:
> 
> * Client has TCP connections to the NFS server, goes to S3 sleep for few hours.
> * TCP connections die on the server side.
>   (not 100% sure why, do they use some kind of keepalive ???)
> * Client resumes from S3.
> * Client sends NFS requests down its TCP connections, gets back RST packet.
> * [Client hangs for exactly 300 seconds here]
> * Client establishes new TCP connections to the NFS server,
>   and recovers from the hang.
> 
> A tcpdump trace is attached at the end of bugzilla bug 11154:
> http://bugzilla.kernel.org/show_bug.cgi?id=11154
> 
> Should the client immediately try to reconnect when its existing connection
> receives an RST packet ? (the 5 minute delay would make sense to me if
> RST was received in reply to a SYN, but I'm not sure about it in the case
> of an existing open TCP connection).
> 
> If the 5 minute delay after an RST is necessary, could the client avoid it
> by explicitly closing/reopening its connections using suspend/resume hooks ?
> 
> (I can not work around the issue locally by mounting/unmounting my NFS
> shares around the suspend/resume because rootfs also on NFS...)
> 
> This NFS setup was working fine in 2.6.24. There has been issues with
> 2.6.25 and 2.6.26, but I did not confirm if they are the same bug.
> 2.6.25 usualy recovers after some variable delay and 2.6.26 usualy
> does not recover. Bugs 11154 and 11061 have more details about this,
> also Ian Campbell has been tracking an NFS issue under load that
> appeared at around the same time.
> 
> Hope this helps,

Does the appended patch make a difference?

Cheers
  Trond
--------------------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 23 Oct 2008 11:33:59 -0400
SUNRPC: Respond promptly to server TCP resets

If the server sends us an RST error while we're in the TCP_ESTABLISHED
state, then that will not result in a state change, and so the RPC client
ends up hanging forever (see
http://bugzilla.kernel.org/show_bug.cgi?id=11154)

We can intercept the reset by setting up an sk->sk_error_report callback,
which will then allow us to initiate a proper shutdown and retry...

We also make sure that if the send request receives an ECONNRESET, then we
shutdown too...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   58 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9a288d5..0a50361 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -249,6 +249,7 @@ struct sock_xprt {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
 };
 
 /*
@@ -698,8 +699,9 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
-	case -ECONNREFUSED:
 	case -ECONNRESET:
+		xs_tcp_shutdown(xprt);
+	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EPIPE:
 		status = -ENOTCONN;
@@ -742,6 +744,22 @@ out_release:
 	xprt_release_xprt(xprt, task);
 }
 
+static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
+{
+	transport->old_data_ready = sk->sk_data_ready;
+	transport->old_state_change = sk->sk_state_change;
+	transport->old_write_space = sk->sk_write_space;
+	transport->old_error_report = sk->sk_error_report;
+}
+
+static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *sk)
+{
+	sk->sk_data_ready = transport->old_data_ready;
+	sk->sk_state_change = transport->old_state_change;
+	sk->sk_write_space = transport->old_write_space;
+	sk->sk_error_report = transport->old_error_report;
+}
+
 /**
  * xs_close - close a socket
  * @xprt: transport
@@ -765,9 +783,8 @@ static void xs_close(struct rpc_xprt *xprt)
 	transport->sock = NULL;
 
 	sk->sk_user_data = NULL;
-	sk->sk_data_ready = transport->old_data_ready;
-	sk->sk_state_change = transport->old_state_change;
-	sk->sk_write_space = transport->old_write_space;
+
+	xs_restore_old_callbacks(transport, sk);
 	write_unlock_bh(&sk->sk_callback_lock);
 
 	sk->sk_no_check = 0;
@@ -1180,6 +1197,28 @@ static void xs_tcp_state_change(struct sock *sk)
 }
 
 /**
+ * xs_tcp_error_report - callback mainly for catching RST events
+ * @sk: socket
+ */
+static void xs_tcp_error_report(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_err != ECONNRESET || sk->sk_state != TCP_ESTABLISHED)
+		goto out;
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	dprintk("RPC:       %s client %p...\n"
+			"RPC:       error %d\n",
+			__func__, xprt, sk->sk_err);
+
+	xprt_force_disconnect(xprt);
+out:
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/**
  * xs_udp_write_space - callback invoked when socket buffer space
  *                             becomes available
  * @sk: socket whose state has changed
@@ -1454,10 +1493,9 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 		write_lock_bh(&sk->sk_callback_lock);
 
+		xs_save_old_callbacks(transport, sk);
+
 		sk->sk_user_data = xprt;
-		transport->old_data_ready = sk->sk_data_ready;
-		transport->old_state_change = sk->sk_state_change;
-		transport->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_no_check = UDP_CSUM_NORCV;
@@ -1589,13 +1627,13 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 		write_lock_bh(&sk->sk_callback_lock);
 
+		xs_save_old_callbacks(transport, sk);
+
 		sk->sk_user_data = xprt;
-		transport->old_data_ready = sk->sk_data_ready;
-		transport->old_state_change = sk->sk_state_change;
-		transport->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
+		sk->sk_error_report = xs_tcp_error_report;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		/* socket options */


