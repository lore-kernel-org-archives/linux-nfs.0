From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] RPC over UDP congestion control updates [2/8]
Date: Tue, 16 Jul 2002 19:59:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15668.24293.430863.661143@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UWbU-0005a4-00
	for <nfs@lists.sourceforge.net>; Tue, 16 Jul 2002 10:59:17 -0700
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


Implement a count of the number of timeouts that have occured since
we last recorded a successful reply from the server.
For the moment this information is merely used in order to improve the
estimate of whether or not the server is down. It will be used in
patch 3/8 in order to improve the timeout backoff algorithm.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.25-rtt1/include/linux/sunrpc/timer.h linux-2.5.25-rtt2/include/linux/sunrpc/timer.h
--- linux-2.5.25-rtt1/include/linux/sunrpc/timer.h	Tue Jul 16 11:43:08 2002
+++ linux-2.5.25-rtt2/include/linux/sunrpc/timer.h	Tue Jul 16 11:47:28 2002
@@ -9,10 +9,13 @@
 #ifndef _LINUX_SUNRPC_TIMER_H
 #define _LINUX_SUNRPC_TIMER_H
 
+#include <asm/atomic.h>
+
 struct rpc_rtt {
 	long timeo;		/* default timeout value */
 	long srtt[5];		/* smoothed round trip time << 3 */
 	long sdrtt[5];		/* soothed medium deviation of RTT */
+	atomic_t  ntimeouts;	/* Global count of the number of timeouts */
 };
 
 
@@ -20,4 +23,19 @@
 extern void rpc_update_rtt(struct rpc_rtt *rt, int timer, long m);
 extern long rpc_calc_rto(struct rpc_rtt *rt, int timer);
 
+static inline void rpc_inc_timeo(struct rpc_rtt *rt)
+{
+	atomic_inc(&rt->ntimeouts);
+}
+
+static inline void rpc_clear_timeo(struct rpc_rtt *rt)
+{
+	atomic_set(&rt->ntimeouts, 0);
+}
+
+static inline int rpc_ntimeo(struct rpc_rtt *rt)
+{
+	return atomic_read(&rt->ntimeouts);
+}
+
 #endif /* _LINUX_SUNRPC_TIMER_H */
diff -u --recursive --new-file linux-2.5.25-rtt1/net/sunrpc/clnt.c linux-2.5.25-rtt2/net/sunrpc/clnt.c
--- linux-2.5.25-rtt1/net/sunrpc/clnt.c	Tue Jul 16 11:43:08 2002
+++ linux-2.5.25-rtt2/net/sunrpc/clnt.c	Tue Jul 16 11:47:28 2002
@@ -671,7 +671,7 @@
 		rpc_exit(task, -EIO);
 		return;
 	}
-	if (clnt->cl_chatty && !(task->tk_flags & RPC_CALL_MAJORSEEN)) {
+	if (clnt->cl_chatty && !(task->tk_flags & RPC_CALL_MAJORSEEN) && rpc_ntimeo(&clnt->cl_rtt) > 7) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
 		if (req)
 			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
diff -u --recursive --new-file linux-2.5.25-rtt1/net/sunrpc/timer.c linux-2.5.25-rtt2/net/sunrpc/timer.c
--- linux-2.5.25-rtt1/net/sunrpc/timer.c	Tue Jul 16 11:43:08 2002
+++ linux-2.5.25-rtt2/net/sunrpc/timer.c	Tue Jul 16 11:47:29 2002
@@ -22,6 +22,7 @@
 		rt->srtt[i] = t;
 		rt->sdrtt[i] = RPC_RTO_INIT;
 	}
+	atomic_set(&rt->ntimeouts, 0);
 }
 
 void
diff -u --recursive --new-file linux-2.5.25-rtt1/net/sunrpc/xprt.c linux-2.5.25-rtt2/net/sunrpc/xprt.c
--- linux-2.5.25-rtt1/net/sunrpc/xprt.c	Tue Jul 16 11:43:08 2002
+++ linux-2.5.25-rtt2/net/sunrpc/xprt.c	Tue Jul 16 11:47:29 2002
@@ -493,6 +493,8 @@
 			int timer = rpcproc_timer(clnt, task->tk_msg.rpc_proc);
 			if (timer)
 				rpc_update_rtt(&clnt->cl_rtt, timer, (long)jiffies - req->rq_xtime);
+		}
+		rpc_clear_timeo(&clnt->cl_rtt);
 	}
 
 #ifdef RPC_PROFILE
@@ -942,6 +944,7 @@
 	if (req->rq_received)
 		goto out;
 	req->rq_nresend++;
+	rpc_inc_timeo(&task->tk_client->cl_rtt);
 	xprt_adjust_cwnd(xprt, -ETIMEDOUT);
 
 	dprintk("RPC: %4d xprt_timer (%s request)\n",


-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
