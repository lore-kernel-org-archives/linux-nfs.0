From: Olaf Kirch <okir@suse.de>
Subject: 2.6.5-rc3 xprt_connect changes?
Date: Thu, 1 Apr 2004 16:47:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040401144740.GH20772@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FkmkrVfFsRoUs1wW"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B93Ts-0007HL-Am
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 06:47:44 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B93Tr-0004NP-K6
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 06:47:44 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 8ADE13C334E
	for <nfs@lists.sourceforge.net>; Thu,  1 Apr 2004 16:47:40 +0200 (CEST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

I have a problem with the xprt_connect changes introduced
in 2.6.5-rc1. They break pmap_register, it always returns
with EIO now.

It seems the problem is this:

 -	xprt_connect puts the task on the pending queue
 -	xprt_socket_connect calls xprt_close, which in turn
 	calls xprt_disconnect, which wakes up all tasks on
	the pending list with ENOTCONN

For transports with "soft" semantics (this includes the portmap client),
this will always cause it to fail with EIO.

For "hard" transports, it seems that after some delay (set in
xprt_connect_status) we come back to call_connect_status, which
notices the ENOTCONN status. It sets the function pointer to
call_connect. If xprt_connected() evaluates to true when we get
there (which is always the case for UDP, and which is true for
TCP igf the SYNACK has arrived in the meanwhile), the call to
xprt_connect() succeeds, and we can continue.

The attached, untested patch should hopefully fix this. I still need
to test this.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sunrpc-xprt-connfix

--- linux-2.6.4/net/sunrpc/xprt.c.connfix	2004-04-01 15:57:50.000000000 +0200
+++ linux-2.6.4/net/sunrpc/xprt.c	2004-04-01 16:46:19.000000000 +0200
@@ -82,7 +82,7 @@
  */
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
 static inline void	do_xprt_reserve(struct rpc_task *);
-static void	xprt_disconnect(struct rpc_xprt *);
+static void	xprt_disconnect(struct rpc_xprt *, int);
 static void	xprt_connect_status(struct rpc_task *task);
 static struct rpc_xprt * xprt_setup(int proto, struct sockaddr_in *ap,
 						struct rpc_timeout *to);
@@ -387,7 +387,7 @@
  * Close down a transport socket
  */
 static void
-xprt_close(struct rpc_xprt *xprt)
+xprt_close(struct rpc_xprt *xprt, int reconnecting)
 {
 	struct socket	*sock;
 	struct sock	*sk;
@@ -407,7 +407,7 @@
 	}
 	write_unlock_bh(&sk->sk_callback_lock);
 
-	xprt_disconnect(xprt);
+	xprt_disconnect(xprt, reconnecting);
 
 	if (sock)
 		sock_release(sock);
@@ -418,7 +418,7 @@
 {
 	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
 
-	xprt_close(xprt);
+	xprt_close(xprt, 0);
 	xprt_release_write(xprt, NULL);
 }
 
@@ -426,12 +426,13 @@
  * Mark a transport as disconnected
  */
 static void
-xprt_disconnect(struct rpc_xprt *xprt)
+xprt_disconnect(struct rpc_xprt *xprt, int reconnecting)
 {
 	dprintk("RPC:      disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->sock_lock);
 	xprt_clear_connected(xprt);
-	rpc_wake_up_status(&xprt->pending, -ENOTCONN);
+	if (!reconnecting)
+		rpc_wake_up_status(&xprt->pending, -ENOTCONN);
 	spin_unlock_bh(&xprt->sock_lock);
 }
 
@@ -471,8 +472,10 @@
 
 	/*
 	 * Start by resetting any existing state
+	 * Close any sockets, but sshhh: don't wake up the tasks
+	 * on the pending queue.
 	 */
-	xprt_close(xprt);
+	xprt_close(xprt, 1);
 	sock = xprt_create_socket(xprt, xprt->prot, xprt->resvport);
 	if (sock == NULL) {
 		/* couldn't create socket or bind to reserved port;
@@ -830,7 +833,7 @@
 	/* Sanity check of the record length */
 	if (xprt->tcp_reclen < 4) {
 		printk(KERN_ERR "RPC: Invalid TCP record fragment length\n");
-		xprt_disconnect(xprt);
+		xprt_disconnect(xprt, 0);
 	}
 	dprintk("RPC:      reading TCP record fragment of length %d\n",
 			xprt->tcp_reclen);
@@ -1046,7 +1049,7 @@
 					NIPQUAD(xprt->addr.sin_addr.s_addr),
 					xprt_connected(xprt)? "closed" : "refused");
 		}
-		xprt_disconnect(xprt);
+		xprt_disconnect(xprt, 0);
 		break;
 	}
  out:
@@ -1258,7 +1261,7 @@
 		return;
 	default:
 		if (xprt->stream)
-			xprt_disconnect(xprt);
+			xprt_disconnect(xprt, 0);
 	}
 	xprt_release_write(xprt, task);
 	return;
@@ -1657,7 +1660,7 @@
 {
 	dprintk("RPC:      destroying transport %p\n", xprt);
 	xprt_shutdown(xprt);
-	xprt_close(xprt);
+	xprt_close(xprt, 0);
 	kfree(xprt->slot);
 	kfree(xprt);
 

--FkmkrVfFsRoUs1wW--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
