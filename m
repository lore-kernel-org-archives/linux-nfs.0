From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] RPC over UDP congestion control updates [3/8]
Date: Tue, 16 Jul 2002 19:59:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15668.24304.638646.86068@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UWbf-0005b8-00
	for <nfs@lists.sourceforge.net>; Tue, 16 Jul 2002 10:59:27 -0700
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


Improve the response to timeouts. As requests time out, we delay
timing out the remaining requests (in fact we follow exponential
backoff). This is done because we assume either that the round trip
time has been underestimated, or that the network/server is congested,
and we need to back off the resending of new requests.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.25-rtt2/include/linux/sunrpc/xprt.h linux-2.5.25-rtt3/include/linux/sunrpc/xprt.h
--- linux-2.5.25-rtt2/include/linux/sunrpc/xprt.h	Tue Jul 16 11:43:08 2002
+++ linux-2.5.25-rtt3/include/linux/sunrpc/xprt.h	Tue Jul 16 15:28:49 2002
@@ -99,6 +99,7 @@
 	u32			rq_bytes_sent;	/* Bytes we have sent */
 
 	long			rq_xtime;	/* when transmitted */
+	int			rq_ntimeo;
 	int			rq_nresend;
 };
 #define rq_svec			rq_snd_buf.head
diff -u --recursive --new-file linux-2.5.25-rtt2/net/sunrpc/xprt.c linux-2.5.25-rtt3/net/sunrpc/xprt.c
--- linux-2.5.25-rtt2/net/sunrpc/xprt.c	Tue Jul 16 11:47:29 2002
+++ linux-2.5.25-rtt3/net/sunrpc/xprt.c	Tue Jul 16 15:28:49 2002
@@ -77,6 +77,8 @@
 # define RPCDBG_FACILITY	RPCDBG_XPRT
 #endif
 
+#define XPRT_MAX_BACKOFF	(8)
+
 /*
  * Local functions
  */
@@ -932,6 +934,21 @@
 }
 
 /*
+ * Exponential backoff for UDP retries
+ */
+static inline int
+xprt_expbackoff(struct rpc_task *task, struct rpc_rqst *req)
+{
+	int backoff;
+
+	req->rq_ntimeo++;
+	backoff = min(rpc_ntimeo(&task->tk_client->cl_rtt), XPRT_MAX_BACKOFF);
+	if (req->rq_ntimeo < (1 << backoff))
+		return 1;
+	return 0;
+}
+
+/*
  * RPC receive timeout handler.
  */
 static void
@@ -943,9 +960,16 @@
 	spin_lock(&xprt->sock_lock);
 	if (req->rq_received)
 		goto out;
+
+	if (!xprt->nocong) {
+		if (xprt_expbackoff(task, req)) {
+			rpc_add_timer(task, xprt_timer);
+			goto out_unlock;
+		}
+		rpc_inc_timeo(&task->tk_client->cl_rtt);
+		xprt_adjust_cwnd(req->rq_xprt, -ETIMEDOUT);
+	}
 	req->rq_nresend++;
-	rpc_inc_timeo(&task->tk_client->cl_rtt);
-	xprt_adjust_cwnd(xprt, -ETIMEDOUT);
 
 	dprintk("RPC: %4d xprt_timer (%s request)\n",
 		task->tk_pid, req ? "pending" : "backlogged");
@@ -954,6 +978,7 @@
 out:
 	task->tk_timeout = 0;
 	rpc_wake_up_task(task);
+out_unlock:
 	spin_unlock(&xprt->sock_lock);
 }
 
@@ -1076,16 +1101,9 @@
 	dprintk("RPC: %4d xmit complete\n", task->tk_pid);
 	/* Set the task's receive timeout value */
 	if (!xprt->nocong) {
-		int backoff;
 		task->tk_timeout = rpc_calc_rto(&clnt->cl_rtt,
 				rpcproc_timer(clnt, task->tk_msg.rpc_proc));
-		/* If we are retransmitting, increment the timeout counter */
-		backoff = req->rq_nresend;
-		if (backoff) {
-			if (backoff > 7)
-				backoff = 7;
-			task->tk_timeout <<= backoff;
-		}
+		req->rq_ntimeo = 0;
 		if (task->tk_timeout > req->rq_timeout.to_maxval)
 			task->tk_timeout = req->rq_timeout.to_maxval;
 	} else


-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
