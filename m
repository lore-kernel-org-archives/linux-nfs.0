From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/UDP slow read, lost fragments
Date: 25 Sep 2003 16:31:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xu430p2.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>
	<20030925174426.B787@muppet.kendall.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2fZv-0006s1-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 16:31:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2fZr-0007Zu-KR
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 16:31:15 -0700
To: Brian Mancuso <bmancuso@akamai.com>
In-Reply-To: <20030925174426.B787@muppet.kendall.corp.akamai.com>
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

>>>>> " " == Brian Mancuso <bmancuso@akamai.com> writes:

     > This can be easily remedied however by TCP's technique of
     > inheriting backoff of RTO from previous transactions: create a
     > new variable somewhere in the clnt structure called, say,
     > cl_backoff; Each time an RPC transaction completes, store the
     > number of retransmits for that transaction (req->rq_nresend) in
     > cl_backoff; calculate RTO to be rpc_calc_rto() left shifted by
     > the number of retransmits for this transaction (initially 0)
     > plus clnt-> cl_backoff (the number of retransmits for the last
     > completed transaction).

Right... There is already a variable set aside for this task in the
RTT code in the form of "ntimeouts".

The following patch sets up a scheme of the form described by Brian,
in combination with another fix to lengthen the window of time during
which we accept updates to the RTO estimate (Karn's algorithm states
that the window closes once you retransmit, whereas our current
algorithm closes the window once a request times out).

Could people give it a try?

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.23-pre5/include/linux/sunrpc/timer.h linux-2.4.23-01-fix_retrans/include/linux/sunrpc/timer.h
--- linux-2.4.23-pre5/include/linux/sunrpc/timer.h	2003-09-19 13:15:31.000000000 -0700
+++ linux-2.4.23-01-fix_retrans/include/linux/sunrpc/timer.h	2003-09-25 16:25:02.000000000 -0700
@@ -23,14 +23,9 @@
 extern void rpc_update_rtt(struct rpc_rtt *rt, int timer, long m);
 extern long rpc_calc_rto(struct rpc_rtt *rt, int timer);
 
-static inline void rpc_inc_timeo(struct rpc_rtt *rt)
+static inline void rpc_set_timeo(struct rpc_rtt *rt, int ntimeo)
 {
-	atomic_inc(&rt->ntimeouts);
-}
-
-static inline void rpc_clear_timeo(struct rpc_rtt *rt)
-{
-	atomic_set(&rt->ntimeouts, 0);
+	atomic_set(&rt->ntimeouts, ntimeo);
 }
 
 static inline int rpc_ntimeo(struct rpc_rtt *rt)
diff -u --recursive --new-file linux-2.4.23-pre5/include/linux/sunrpc/xprt.h linux-2.4.23-01-fix_retrans/include/linux/sunrpc/xprt.h
--- linux-2.4.23-pre5/include/linux/sunrpc/xprt.h	2003-07-29 16:52:26.000000000 -0700
+++ linux-2.4.23-01-fix_retrans/include/linux/sunrpc/xprt.h	2003-09-19 13:15:31.000000000 -0700
@@ -115,7 +115,7 @@
 
 	long			rq_xtime;	/* when transmitted */
 	int			rq_ntimeo;
-	int			rq_nresend;
+	int			rq_ntrans;
 };
 #define rq_svec			rq_snd_buf.head
 #define rq_slen			rq_snd_buf.len
diff -u --recursive --new-file linux-2.4.23-pre5/net/sunrpc/xprt.c linux-2.4.23-01-fix_retrans/net/sunrpc/xprt.c
--- linux-2.4.23-pre5/net/sunrpc/xprt.c	2003-07-29 16:54:19.000000000 -0700
+++ linux-2.4.23-01-fix_retrans/net/sunrpc/xprt.c	2003-09-25 16:25:02.000000000 -0700
@@ -138,18 +138,21 @@
 static int
 __xprt_lock_write(struct rpc_xprt *xprt, struct rpc_task *task)
 {
+	struct rpc_rqst *req = task->tk_rqstp;
 	if (!xprt->snd_task) {
 		if (xprt->nocong || __xprt_get_cong(xprt, task)) {
 			xprt->snd_task = task;
-			if (task->tk_rqstp)
-				task->tk_rqstp->rq_bytes_sent = 0;
+			if (req) {
+				req->rq_bytes_sent = 0;
+				req->rq_ntrans++;
+			}
 		}
 	}
 	if (xprt->snd_task != task) {
 		dprintk("RPC: %4d TCP write queue full\n", task->tk_pid);
 		task->tk_timeout = 0;
 		task->tk_status = -EAGAIN;
-		if (task->tk_rqstp && task->tk_rqstp->rq_nresend)
+		if (req && req->rq_ntrans)
 			rpc_sleep_on(&xprt->resend, task, NULL, NULL);
 		else
 			rpc_sleep_on(&xprt->sending, task, NULL, NULL);
@@ -183,9 +186,12 @@
 			return;
 	}
 	if (xprt->nocong || __xprt_get_cong(xprt, task)) {
+		struct rpc_rqst *req = task->tk_rqstp;
 		xprt->snd_task = task;
-		if (task->tk_rqstp)
-			task->tk_rqstp->rq_bytes_sent = 0;
+		if (req) {
+			req->rq_bytes_sent = 0;
+			req->rq_ntrans++;
+		}
 	}
 }
 
@@ -592,12 +598,12 @@
 	if (!xprt->nocong) {
 		xprt_adjust_cwnd(xprt, copied);
 		__xprt_put_cong(xprt, req);
-	       	if (!req->rq_nresend) {
+	       	if (req->rq_ntrans == 1) {
 			int timer = rpcproc_timer(clnt, task->tk_msg.rpc_proc);
 			if (timer)
 				rpc_update_rtt(&clnt->cl_rtt, timer, (long)jiffies - req->rq_xtime);
 		}
-		rpc_clear_timeo(&clnt->cl_rtt);
+		rpc_set_timeo(&clnt->cl_rtt, req->rq_ntrans - 1);
 	}
 
 #ifdef RPC_PROFILE
@@ -1063,7 +1069,7 @@
 		goto out;
 
 	xprt_adjust_cwnd(req->rq_xprt, -ETIMEDOUT);
-	req->rq_nresend++;
+	__xprt_put_cong(xprt, req);
 
 	dprintk("RPC: %4d xprt_timer (%s request)\n",
 		task->tk_pid, req ? "pending" : "backlogged");
@@ -1219,6 +1225,7 @@
 	if (!xprt->nocong) {
 		task->tk_timeout = rpc_calc_rto(&clnt->cl_rtt,
 				rpcproc_timer(clnt, task->tk_msg.rpc_proc));
+		task->tk_timeout <<= rpc_ntimeo(&clnt->cl_rtt);
 		task->tk_timeout <<= clnt->cl_timeout.to_retries
 			- req->rq_timeout.to_retries;
 		if (task->tk_timeout > req->rq_timeout.to_maxval)



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
