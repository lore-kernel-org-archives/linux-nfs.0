From: Olaf Kirch <okir@suse.de>
Subject: Race condition in xprt_disconnect
Date: Fri, 2 Apr 2004 10:32:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040402083236.GE11477@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9K6R-0005Km-Gp
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 00:32:39 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B9K6Q-0005ad-Vg
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 00:32:39 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id E493A3C8659
	for <nfs@lists.sourceforge.net>; Fri,  2 Apr 2004 10:32:36 +0200 (CEST)
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


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

it seems bad things can happen if two RPC processes call xprt_disconnect
at the same time. I have two bug reports of ppc machines oopsing
somewhere deep in some SELinux functions because inode->i_security
is NULL. inode->i_security is allocated when the inode is created,
and cleared when the inode is destroyed.

The stack looks something like 
xprt_disconnect->sock_release->...->selinux_foofah

The only way I can see this happening is if sock_release is called twice,
and indeed we do not seem to protect against this. Please take a look
at the attached patch. It should prevent these oopses, but I'm not
entirely sure it's safe.

Thanks,
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sunrpc-disconnect-race

--- linux-2.6.4/net/sunrpc/xprt.c.fix	2004-04-01 18:51:50.000000000 +0200
+++ linux-2.6.4/net/sunrpc/xprt.c	2004-04-01 18:51:03.000000000 +0200
@@ -87,7 +87,7 @@
 static struct rpc_xprt * xprt_setup(int proto, struct sockaddr_in *ap,
 						struct rpc_timeout *to);
 static struct socket *xprt_create_socket(struct rpc_xprt *, int, int);
-static void	xprt_bind_socket(struct rpc_xprt *, struct socket *);
+static int	xprt_bind_socket(struct rpc_xprt *, struct socket *);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
 #ifdef RPC_DEBUG_DATA
@@ -389,26 +389,33 @@
 static void
 xprt_close(struct rpc_xprt *xprt, int reconnecting)
 {
-	struct socket	*sock = xprt->sock;
-	struct sock	*sk = xprt->inet;
-
-	if (!sk)
-		return;
-
-	write_lock_bh(&sk->sk_callback_lock);
+	struct socket	*sock;
+	struct sock	*sk;
+	
+	spin_lock_bh(&xprt->sock_lock);
+	if ((sk = xprt->inet) != NULL)
+		sock_hold(sk);
 	xprt->inet = NULL;
+
+	sock = xprt->sock;
 	xprt->sock = NULL;
+	spin_unlock_bh(&xprt->sock_lock);
 
-	sk->sk_user_data    = NULL;
-	sk->sk_data_ready   = xprt->old_data_ready;
-	sk->sk_state_change = xprt->old_state_change;
-	sk->sk_write_space  = xprt->old_write_space;
-	write_unlock_bh(&sk->sk_callback_lock);
+	if (sk != NULL) {
+		write_lock_bh(&sk->sk_callback_lock);
+		sk->sk_user_data    = NULL;
+		sk->sk_data_ready   = xprt->old_data_ready;
+		sk->sk_state_change = xprt->old_state_change;
+		sk->sk_write_space  = xprt->old_write_space;
+		sk->sk_no_check	 = 0;
+		write_unlock_bh(&sk->sk_callback_lock);
+		sock_put(sk);
+	}
 
 	xprt_disconnect(xprt, reconnecting);
-	sk->sk_no_check	 = 0;
 
-	sock_release(sock);
+	if (sock)
+		sock_release(sock);
 }
 
 static void
@@ -481,7 +488,10 @@
 		goto out_err;
 		return;
 	}
-	xprt_bind_socket(xprt, sock);
+	if (xprt_bind_socket(xprt, sock) < 0) {
+		sock_release(sock);
+		goto out_err;
+	}
 	xprt_sock_setbufsize(xprt);
 
 	if (!xprt->stream)
@@ -1520,13 +1530,17 @@
 	return err;
 }
 
-static void
+static int
 xprt_bind_socket(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock	*sk = sock->sk;
+	int		error = -EBUSY;
 
+	/* Can it happen that xprt->inet is non-null when we
+	 * get here? If so we should indicate an error so
+	 * that the caller can drop the newly created socket */
 	if (xprt->inet)
-		return;
+		goto out;
 
 	write_lock_bh(&sk->sk_callback_lock);
 	sk->sk_user_data = xprt;
@@ -1545,13 +1559,19 @@
 		xprt_clear_connected(xprt);
 	}
 	sk->sk_write_space = xprt_write_space;
+	write_unlock_bh(&sk->sk_callback_lock);
 
 	/* Reset to new socket */
-	xprt->sock = sock;
-	xprt->inet = sk;
-	write_unlock_bh(&sk->sk_callback_lock);
+	spin_lock_bh(&xprt->sock_lock);
+	if (xprt->inet == NULL) {
+		xprt->sock = sock;
+		xprt->inet = sk;
+		error = 0;
+	}
+	spin_unlock_bh(&xprt->sock_lock);
 
-	return;
+out:
+	return error;
 }
 
 /*

--MGYHOYXEY6WxJCY8--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
