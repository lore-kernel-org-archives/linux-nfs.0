From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [4/7]
Date: Thu, 31 Oct 2002 21:21:21 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.37057.391023.315267@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Loj-0003cJ-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:21:25 -0800
To: Linus Torvalds <torvalds@transmeta.com>,
    NFS maillist <nfs@lists.sourceforge.net>,nfsv4-wg@citi.umich.edu
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


The RPCSEC_GSS user context defines a 'sequence number' in the AUTH header
fields in order to provide protection against replay attacks. This
number needs to lie within a given 'window', and is required to be updated
even when retransmitting dropped UDP requests.

In order to allow this update to occur we move the XDR 'encode' phase
so that it is done immediately before we write the data to the socket.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.44-01-rpc_msg/include/linux/sunrpc/xprt.h linux-2.5.44-02-rpc_encode/include/linux/sunrpc/xprt.h
--- linux-2.5.44-01-rpc_msg/include/linux/sunrpc/xprt.h	2002-10-08 21:37:46.000000000 -0400
+++ linux-2.5.44-02-rpc_encode/include/linux/sunrpc/xprt.h	2002-10-28 17:19:48.000000000 -0500
@@ -187,6 +187,7 @@
 					unsigned long);
 
 void			xprt_reserve(struct rpc_task *);
+int			xprt_prepare_transmit(struct rpc_task *);
 void			xprt_transmit(struct rpc_task *);
 void			xprt_receive(struct rpc_task *);
 int			xprt_adjust_timeout(struct rpc_timeout *);
diff -u --recursive --new-file linux-2.5.44-01-rpc_msg/net/sunrpc/clnt.c linux-2.5.44-02-rpc_encode/net/sunrpc/clnt.c
--- linux-2.5.44-01-rpc_msg/net/sunrpc/clnt.c	2002-10-28 17:05:26.000000000 -0500
+++ linux-2.5.44-02-rpc_encode/net/sunrpc/clnt.c	2002-10-28 18:37:27.000000000 -0500
@@ -487,7 +487,7 @@
 
 	dprintk("RPC: %4d call_allocate (status %d)\n", 
 				task->tk_pid, task->tk_status);
-	task->tk_action = call_encode;
+	task->tk_action = call_bind;
 	if (task->tk_buffer)
 		return;
 
@@ -527,8 +527,6 @@
 	dprintk("RPC: %4d call_encode (status %d)\n", 
 				task->tk_pid, task->tk_status);
 
-	task->tk_action = call_bind;
-
 	/* Default buffer setup */
 	bufsiz = rpcproc_bufsiz(clnt, task->tk_msg.rpc_proc)+RPC_SLACK_SPACE;
 	sndbuf->head[0].iov_base = (void *)task->tk_buffer;
@@ -628,16 +626,23 @@
 static void
 call_transmit(struct rpc_task *task)
 {
-	struct rpc_clnt	*clnt = task->tk_client;
-
 	dprintk("RPC: %4d call_transmit (status %d)\n", 
 				task->tk_pid, task->tk_status);
 
 	task->tk_action = call_status;
 	if (task->tk_status < 0)
 		return;
+	task->tk_status = xprt_prepare_transmit(task);
+	if (task->tk_status < 0)
+		return;
+	/* Encode here so that rpcsec_gss can use correct sequence number. */
+	call_encode(task);
+	if (task->tk_status < 0)
+		return;
 	xprt_transmit(task);
-	if (!task->tk_msg.xdr_decode && task->tk_status >= 0) {
+	if (task->tk_status < 0)
+		return;
+	if (!task->tk_msg.xdr_decode) {
 		task->tk_action = NULL;
 		rpc_wake_up_task(task);
 	}
@@ -777,7 +782,7 @@
 		if (RPC_IS_SETUID(task) && task->tk_suid_retry) {
 			dprintk("RPC: %4d retry squashed uid\n", task->tk_pid);
 			task->tk_flags ^= RPC_CALL_REALUID;
-			task->tk_action = call_encode;
+			task->tk_action = call_bind;
 			task->tk_suid_retry--;
 			return;
 		}
@@ -883,7 +888,7 @@
 			task->tk_garb_retry--;
 			dprintk("RPC: %4d call_verify: retry garbled creds\n",
 							task->tk_pid);
-			task->tk_action = call_encode;
+			task->tk_action = call_bind;
 			return NULL;
 		case RPC_AUTH_TOOWEAK:
 			printk(KERN_NOTICE "call_verify: server requires stronger "
@@ -918,7 +923,7 @@
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
 		dprintk(KERN_WARNING "RPC: garbage, retrying %4d\n", task->tk_pid);
-		task->tk_action = call_encode;
+		task->tk_action = call_bind;
 		return NULL;
 	}
 	printk(KERN_WARNING "RPC: garbage, exit EIO\n");
diff -u --recursive --new-file linux-2.5.44-01-rpc_msg/net/sunrpc/xprt.c linux-2.5.44-02-rpc_encode/net/sunrpc/xprt.c
--- linux-2.5.44-01-rpc_msg/net/sunrpc/xprt.c	2002-10-08 07:06:15.000000000 -0400
+++ linux-2.5.44-02-rpc_encode/net/sunrpc/xprt.c	2002-10-28 17:29:21.000000000 -0500
@@ -83,7 +83,6 @@
  * Local functions
  */
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
-static void	do_xprt_transmit(struct rpc_task *);
 static inline void	do_xprt_reserve(struct rpc_task *);
 static void	xprt_disconnect(struct rpc_xprt *);
 static void	xprt_conn_status(struct rpc_task *task);
@@ -1090,51 +1089,40 @@
  * Place the actual RPC call.
  * We have to copy the iovec because sendmsg fiddles with its contents.
  */
-void
-xprt_transmit(struct rpc_task *task)
+int
+xprt_prepare_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
+	int err = 0;
 
-	dprintk("RPC: %4d xprt_transmit(%x)\n", task->tk_pid, 
-				*(u32 *)(req->rq_svec[0].iov_base));
+	dprintk("RPC: %4d xprt_prepare_transmit\n", task->tk_pid);
 
 	if (xprt->shutdown)
-		task->tk_status = -EIO;
+		return -EIO;
 
 	if (!xprt_connected(xprt))
-		task->tk_status = -ENOTCONN;
-
-	if (task->tk_status < 0)
-		return;
+		return -ENOTCONN;
 
 	if (task->tk_rpcwait)
 		rpc_remove_wait_queue(task);
 
-	/* set up everything as needed. */
-	/* Write the record marker */
-	if (xprt->stream) {
-		u32	*marker = req->rq_svec[0].iov_base;
-
-		*marker = htonl(0x80000000|(req->rq_slen-sizeof(*marker)));
-	}
-
 	spin_lock_bh(&xprt->sock_lock);
 	if (!__xprt_lock_write(xprt, task)) {
-		spin_unlock_bh(&xprt->sock_lock);
-		return;
+		err = -EAGAIN;
+		goto out_unlock;
 	}
 	if (list_empty(&req->rq_list)) {
 		list_add_tail(&req->rq_list, &xprt->recv);
 		req->rq_received = 0;
 	}
+out_unlock:
 	spin_unlock_bh(&xprt->sock_lock);
-
-	do_xprt_transmit(task);
+	return err;
 }
 
-static void
-do_xprt_transmit(struct rpc_task *task)
+void
+xprt_transmit(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
@@ -1142,6 +1130,16 @@
 	int status, retry = 0;
 
 
+	dprintk("RPC: %4d xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
+
+	/* set up everything as needed. */
+	/* Write the record marker */
+	if (xprt->stream) {
+		u32	*marker = req->rq_svec[0].iov_base;
+
+		*marker = htonl(0x80000000|(req->rq_slen-sizeof(*marker)));
+	}
+
 	/* Continue transmitting the packet/record. We must be careful
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called xprt_sendmsg().


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
