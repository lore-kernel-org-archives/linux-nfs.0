From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Fri, 5 Sep 2003 12:57:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16216.49290.95790.771582@charged.uio.no>
References: <200308231404.34087.hpj@urpla.net>
	<200308262328.09975.hpj@urpla.net>
	<200308271250.09723.hpj@urpla.net>
	<200309051305.43484.hpj@urpla.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vJuI-0007sS-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 09:57:58 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19vJuH-0005T7-1T
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 09:57:57 -0700
To: Hans-Peter Jansen <hpj@urpla.net>
In-Reply-To: <200309051305.43484.hpj@urpla.net>
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

>>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:

     > While betatesting the current kernel of upcoming SuSE 9.0
     > (2.4.21-59), prepared for diskless in my 8.2 env. yesterday, it
     > doesn't show this problem, too. It's a heavily tweaked 2.4.21
     > with many .22 fixes included. It happens for me with
     > 2.4.22-pre10, so it smells like some changes in (late) 2.4.22
     > triggers it.


Hmm... Most of those changes were only supposed to affect the TCP
performance. Do you see the problem with 2.4.22-pre9? If so, what
about 2.4.22-pre3?

Also, does the following patch make any difference? It should tweak
the RTT timer updates slightly.

Cheers,
  Trond


diff -u --recursive --new-file linux-2.4.22-rc3/include/linux/sunrpc/xprt.h linux-2.4.22-00-resends/include/linux/sunrpc/xprt.h
--- linux-2.4.22-rc3/include/linux/sunrpc/xprt.h	2003-08-23 14:39:24.000000000 -0400
+++ linux-2.4.22-00-resends/include/linux/sunrpc/xprt.h	2003-09-05 10:52:00.000000000 -0400
@@ -115,7 +115,7 @@
 
 	long			rq_xtime;	/* when transmitted */
 	int			rq_ntimeo;
-	int			rq_nresend;
+	int			rq_ntrans;
 };
 #define rq_svec			rq_snd_buf.head
 #define rq_slen			rq_snd_buf.len
diff -u --recursive --new-file linux-2.4.22-rc3/net/sunrpc/xprt.c linux-2.4.22-00-resends/net/sunrpc/xprt.c
--- linux-2.4.22-rc3/net/sunrpc/xprt.c	2003-07-29 19:54:19.000000000 -0400
+++ linux-2.4.22-00-resends/net/sunrpc/xprt.c	2003-09-05 10:56:43.000000000 -0400
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
 
@@ -592,7 +598,7 @@
 	if (!xprt->nocong) {
 		xprt_adjust_cwnd(xprt, copied);
 		__xprt_put_cong(xprt, req);
-	       	if (!req->rq_nresend) {
+	       	if (req->rq_trans == 1) {
 			int timer = rpcproc_timer(clnt, task->tk_msg.rpc_proc);
 			if (timer)
 				rpc_update_rtt(&clnt->cl_rtt, timer, (long)jiffies - req->rq_xtime);
@@ -1063,7 +1069,7 @@
 		goto out;
 
 	xprt_adjust_cwnd(req->rq_xprt, -ETIMEDOUT);
-	req->rq_nresend++;
+	__xprt_put_cong(xprt, req);
 
 	dprintk("RPC: %4d xprt_timer (%s request)\n",
 		task->tk_pid, req ? "pending" : "backlogged");


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
