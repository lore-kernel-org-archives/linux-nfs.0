From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] refine RPC over TCP socket connect behavior
Date: Tue, 12 Nov 2002 18:06:29 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211121800460.3001-100000@spacewalker.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from spacewalker.citi.umich.edu ([141.211.133.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Bk7B-00079E-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 15:06:37 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

further refine TCP socket connect behavior in the RPC client.  this patch 
implements the following behavior changes:

+  the TCP connect timeout is now the same as the TCP retransmit timeout
   value, giving sysadmins a means to adjust the connect timeout for
   links with long RTTs.

+  if multiple RPC requests notice the TCP transport socket is
   disconnected, cause them all to wait at least RPC_REESTABLISH_TIMEOUT
   seconds before retrying to connect.  before, only one would wait, and
   the rest would retry immediately.

+  if an unrecognized error occurs when trying to establish a connection,
   just exit without retrying.

against 2.5.47.


diff -ruN 05-odirect2/include/linux/sunrpc/xprt.h 10-connect3/include/linux/sunrpc/xprt.h
--- 05-odirect2/include/linux/sunrpc/xprt.h	Sun Nov 10 22:28:27 2002
+++ 10-connect3/include/linux/sunrpc/xprt.h	Tue Nov 12 16:18:57 2002
@@ -45,13 +45,6 @@
 #define RPC_MAX_TCP_TIMEOUT	(600*HZ)
 
 /*
- * Wait duration for an RPC TCP connection to be established.  Solaris
- * NFS over TCP uses 60 seconds, for example, which is in line with how
- * long a server takes to reboot.
- */
-#define RPC_CONNECT_TIMEOUT	(60*HZ)
-
-/*
  * Delay an arbitrary number of seconds before attempting to reconnect
  * after an error.
  */
diff -ruN 05-odirect2/net/sunrpc/clnt.c 10-connect3/net/sunrpc/clnt.c
--- 05-odirect2/net/sunrpc/clnt.c	Sun Nov 10 22:28:10 2002
+++ 10-connect3/net/sunrpc/clnt.c	Tue Nov 12 16:19:25 2002
@@ -566,7 +566,7 @@
 
 	if (!clnt->cl_port) {
 		task->tk_action = call_connect;
-		task->tk_timeout = RPC_CONNECT_TIMEOUT;
+		task->tk_timeout = xprt->timeout.to_initval;
 		rpc_getport(task, clnt);
 	}
 }
diff -ruN 05-odirect2/net/sunrpc/xprt.c 10-connect3/net/sunrpc/xprt.c
--- 05-odirect2/net/sunrpc/xprt.c	Sun Nov 10 22:28:26 2002
+++ 10-connect3/net/sunrpc/xprt.c	Tue Nov 12 16:31:08 2002
@@ -461,7 +461,7 @@
 		if (inet->state != TCP_ESTABLISHED) {
 			dprintk("RPC: %4d  waiting for connection\n",
 					task->tk_pid);
-			task->tk_timeout = RPC_CONNECT_TIMEOUT;
+			task->tk_timeout = xprt->timeout.to_initval;
 			/* if the socket is already closing, delay briefly */
 			if ((1 << inet->state) & ~(TCPF_SYN_SENT|TCPF_SYN_RECV))
 				task->tk_timeout = RPC_REESTABLISH_TIMEOUT;
@@ -481,7 +481,7 @@
 		if (inet->state != TCP_ESTABLISHED) {
 			xprt_close(xprt);
 			task->tk_status = -EAGAIN;
-			goto out_write;
+			break;
 		}
 
 		/* Otherwise, the connection is already established. */
@@ -491,24 +491,14 @@
 	case -EPIPE:
 		xprt_close(xprt);
 		task->tk_status = -ENOTCONN;
-		goto out_write;
+		break;
 
 	default:
-		/* Report myriad other possible returns.  If this file
-		 * system is soft mounted, just error out, like Solaris.  */
+		/* Report myriad other possible returns, and exit. */
 		xprt_close(xprt);
-		if (task->tk_client->cl_softrtry) {
-			printk(KERN_WARNING
+		printk(KERN_WARNING
 			"RPC: error %d connecting to server %s, exiting\n",
 					-status, task->tk_client->cl_server);
-			task->tk_status = -EIO;
-		} else {
-			printk(KERN_WARNING
-			"RPC: error %d connecting to server %s\n",
-					-status, task->tk_client->cl_server);
-			rpc_delay(task, RPC_REESTABLISH_TIMEOUT);
-			task->tk_status = status;
-		}
 		break;
 	}
 
@@ -528,26 +518,37 @@
 	case 0:
 		dprintk("RPC: %4d xprt_conn_status: connection established\n",
 				task->tk_pid);
-		goto out;
+		xprt_release_write(xprt, task);
+		return;
 	case -ETIMEDOUT:
 		dprintk("RPC: %4d xprt_conn_status: timed out\n",
 				task->tk_pid);
-		/* prevent TCP from continuing to retry SYNs */
-		xprt_close(xprt);
+		task->tk_status = -EAGAIN;
+		if (task->tk_client->cl_softrtry)
+			task->tk_status = -EIO;
+		break;
+	case -ENOTCONN:
+		dprintk("RPC: %4d xprt_conn_status: no network path\n",
+				task->tk_pid);
+		if (!task->tk_client->cl_softrtry) {
+			rpc_delay(task, RPC_REESTABLISH_TIMEOUT);
+			task->tk_status = -EAGAIN;
+		} else
+			task->tk_status = -EIO;
 		break;
 	default:
-		printk(KERN_ERR "RPC: error %d connecting to server %s\n",
+		printk(KERN_WARNING
+			"RPC: error %d connecting to server %s, exiting\n",
 				-task->tk_status, task->tk_client->cl_server);
-		xprt_close(xprt);
-		rpc_delay(task, RPC_REESTABLISH_TIMEOUT);
 		break;
 	}
-	/* if soft mounted, cause this RPC to fail */
-	if (task->tk_client->cl_softrtry)
-		task->tk_status = -EIO;
+	/* prevent TCP from continuing to retry SYNs */
+	xprt_close(xprt);
 
- out:
-	xprt_release_write(xprt, task);
+	/* if we're retrying, hold the write lock to prevent other
+	 * requests from retrying the connect */
+	if (task->tk_status != -EAGAIN)
+		xprt_release_write(xprt, task);
 }
 
 /*



-------------------------------------------------------
This sf.net email is sponsored by: 
To learn the basics of securing your web site with SSL, 
click here to get a FREE TRIAL of a Thawte Server Certificate: 
http://www.gothawte.com/rd522.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
