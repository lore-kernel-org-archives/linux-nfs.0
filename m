From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] clean up RPC write_space() code
Date: Fri, 26 Jul 2002 22:09:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33885.4712820195$1027714592@news.gmane.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YBPe-0008FW-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 13:10:11 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Make the RPC write_space() algoritm use the standard socket flags
SOCK_ASYNC_NOSPACE and SOCK_NOSPACE instead of its own custom flag.

Cheers,
  Trond


diff -u --recursive --new-file linux/include/linux/sunrpc/xprt.h linux-2.5.28-rpc_wspace/include/linux/sunrpc/xprt.h
--- linux/include/linux/sunrpc/xprt.h	Thu Jul 18 23:43:08 2002
+++ linux-2.5.28-rpc_wspace/include/linux/sunrpc/xprt.h	Fri Jul 26 00:01:06 2002
@@ -178,12 +178,7 @@
 void			xprt_reconnect(struct rpc_task *);
 int			xprt_clear_backlog(struct rpc_xprt *);
 
-#define XPRT_WSPACE	0
-#define XPRT_CONNECT	1
-
-#define xprt_wspace(xp)			(test_bit(XPRT_WSPACE, &(xp)->sockstate))
-#define xprt_test_and_set_wspace(xp)	(test_and_set_bit(XPRT_WSPACE, &(xp)->sockstate))
-#define xprt_clear_wspace(xp)		(clear_bit(XPRT_WSPACE, &(xp)->sockstate))
+#define XPRT_CONNECT	0
 
 #define xprt_connected(xp)		(!(xp)->stream || test_bit(XPRT_CONNECT, &(xp)->sockstate))
 #define xprt_set_connected(xp)		(set_bit(XPRT_CONNECT, &(xp)->sockstate))
diff -u --recursive --new-file linux/net/sunrpc/xprt.c linux-2.5.28-rpc_wspace/net/sunrpc/xprt.c
--- linux/net/sunrpc/xprt.c	Wed Jul 24 00:20:48 2002
+++ linux-2.5.28-rpc_wspace/net/sunrpc/xprt.c	Fri Jul 26 00:01:06 2002
@@ -233,6 +233,7 @@
 	msg.msg_controllen = 0;
 
 	oldfs = get_fs(); set_fs(get_ds());
+	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 	result = sock_sendmsg(sock, &msg, slen);
 	set_fs(oldfs);
 
@@ -248,10 +249,7 @@
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED.
 		 */
-		break;
 	case -EAGAIN:
-		if (test_bit(SOCK_NOSPACE, &sock->flags))
-			result = -ENOMEM;
 		break;
 	case -ENOTCONN:
 	case -EPIPE:
@@ -965,19 +963,15 @@
 	if (!sock_writeable(sk))
 		return;
 
-	if (!xprt_test_and_set_wspace(xprt)) {
-		spin_lock_bh(&xprt->sock_lock);
-		if (xprt->snd_task && xprt->snd_task->tk_rpcwait == &xprt->pending)
-			rpc_wake_up_task(xprt->snd_task);
-		spin_unlock_bh(&xprt->sock_lock);
-	}
+	if (!test_and_clear_bit(SOCK_NOSPACE, &sock->flags))
+		return;
 
-	if (test_bit(SOCK_NOSPACE, &sock->flags)) {
-		if (sk->sleep && waitqueue_active(sk->sleep)) {
-			clear_bit(SOCK_NOSPACE, &sock->flags);
-			wake_up_interruptible(sk->sleep);
-		}
-	}
+	spin_lock_bh(&xprt->sock_lock);
+	if (xprt->snd_task && xprt->snd_task->tk_rpcwait == &xprt->pending)
+		rpc_wake_up_task(xprt->snd_task);
+	spin_unlock_bh(&xprt->sock_lock);
+	if (sk->sleep && waitqueue_active(sk->sleep))
+		wake_up_interruptible(sk->sleep);
 }
 
 /*
@@ -1083,7 +1077,6 @@
 	 * called xprt_sendmsg().
 	 */
 	while (1) {
-		xprt_clear_wspace(xprt);
 		req->rq_xtime = jiffies;
 		status = xprt_sendmsg(xprt, req);
 
@@ -1098,7 +1091,7 @@
 		} else {
 			if (status >= req->rq_slen)
 				goto out_receive;
-			status = -ENOMEM;
+			status = -EAGAIN;
 			break;
 		}
 
@@ -1121,16 +1114,17 @@
 	task->tk_status = status;
 
 	switch (status) {
-	case -ENOMEM:
-		/* Protect against (udp|tcp)_write_space */
-		spin_lock_bh(&xprt->sock_lock);
-		if (!xprt_wspace(xprt)) {
-			task->tk_timeout = req->rq_timeout.to_current;
-			rpc_sleep_on(&xprt->pending, task, NULL, NULL);
-		}
-		spin_unlock_bh(&xprt->sock_lock);
-		return;
 	case -EAGAIN:
+		if (test_bit(SOCK_ASYNC_NOSPACE, &xprt->sock->flags)) {
+			/* Protect against races with xprt_write_space */
+			spin_lock_bh(&xprt->sock_lock);
+			if (test_bit(SOCK_NOSPACE, &xprt->sock->flags)) {
+				task->tk_timeout = req->rq_timeout.to_current;
+				rpc_sleep_on(&xprt->pending, task, NULL, NULL);
+			}
+			spin_unlock_bh(&xprt->sock_lock);
+			return;
+		}
 		/* Keep holding the socket if it is blocked */
 		rpc_delay(task, HZ>>4);
 		return;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
