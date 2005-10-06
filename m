From: Alexander Jolk <alexj@buf.com>
Subject: NFS-UDP performance in 2.6.x [patch included]
Date: Thu, 06 Oct 2005 17:56:53 +0200
Message-ID: <43454945.1020601@buf.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020703010807060707070000"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENY7D-00038y-5m
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 08:57:03 -0700
Received: from mail.buf.fr ([195.68.52.65])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ENY7B-0001Ny-Lw
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 08:57:03 -0700
Received: from buf.com (taf.buf.fr [192.2.0.229])
	by mail.buf.fr (8.12.3/8.12.3/Debian-7.1) with ESMTP id j96Fukdf023059
	for <nfs@lists.sourceforge.net>; Thu, 6 Oct 2005 17:56:46 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------020703010807060707070000
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi everybody,

Just like a few other people over the last year, I've observed that NFS 
over UDP with a 2.6 client is a lot slower than it used to be in 2.4.x 
times.  Previous discussions as for instance 
http://www.ussg.iu.edu/hypermail/linux/kernel/0405.3/0866.html, have 
concluded that this is due to mixed Gigabit/100Mbit networks.  I've 
successfully traced the crucial change to a change between kernel 2.4.22 
and 2.4.23.  On an identical Red Hat 7.3 machine, I get five to ten 
times slower performance on 2.4.23 than on 2.4.22.

I have isolated part of the patch, applied it by hand to 2.6.8 sources, 
and compiled a working 2.6.8 kernel that has eight to ten times higher 
performance on a simple NFS read operation than one without my patch. 
The patch is included for comment.  (I'm only just subscribing to the 
list, so please CC: me on replies.)

Note that the patch is against Debian's kernel-source-2.6.8 package 
which does not contain pristine sources; as far as I can tell, the 
relevant code in Debian is not different from mainstream kernel though.

I would like some feedback whether someone is aware of this problem.  I 
don't understand what the code change in 2.4.23 was supposed to achieve; 
I'm essentially backing out that change and have not observed any 
difference apart from a 8x speedup.  What should I be looking for?

Alex

-- 
Alexander Jolk         /         BUF Compagnie
tel +33-1 42 68 18 28 /  fax +33-1 42 68 18 29

--------------020703010807060707070000
Content-Type: text/plain;
 name="patch-BUF-nfs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-BUF-nfs"

diff -Nru kernel-source-2.6.8/include/linux/sunrpc/timer.h kernel-source-2.6.8-patched-nfs/include/linux/sunrpc/timer.h
--- kernel-source-2.6.8/include/linux/sunrpc/timer.h	2004-08-14 07:37:14.000000000 +0200
+++ kernel-source-2.6.8-patched-nfs/include/linux/sunrpc/timer.h	2005-10-05 21:18:00.000000000 +0200
@@ -15,7 +15,7 @@
 	unsigned long timeo;	/* default timeout value */
 	unsigned long srtt[5];	/* smoothed round trip time << 3 */
 	unsigned long sdrtt[5];	/* smoothed medium deviation of RTT */
-	int ntimeouts[5];	/* Number of timeouts for the last request */
+	atomic_t  ntimeouts;	/* Global count of the number of timeouts */
 };
 
 
@@ -23,27 +23,19 @@
 extern void rpc_update_rtt(struct rpc_rtt *rt, unsigned timer, long m);
 extern unsigned long rpc_calc_rto(struct rpc_rtt *rt, unsigned timer);
 
-static inline void rpc_set_timeo(struct rpc_rtt *rt, int timer, int ntimeo)
+static inline void rpc_inc_timeo(struct rpc_rtt *rt)
 {
-	int *t;
-	if (!timer)
-		return;
-	t = &rt->ntimeouts[timer-1];
-	if (ntimeo < *t) {
-		if (*t > 0)
-			(*t)--;
-	} else {
-		if (ntimeo > 8)
-			ntimeo = 8;
-		*t = ntimeo;
-	}
+	atomic_inc(&rt->ntimeouts);
 }
 
-static inline int rpc_ntimeo(struct rpc_rtt *rt, int timer)
+static inline void rpc_clear_timeo(struct rpc_rtt *rt)
 {
-	if (!timer)
-		return 0;
-	return rt->ntimeouts[timer-1];
+	atomic_set(&rt->ntimeouts, 0);
+}
+
+static inline int rpc_ntimeo(struct rpc_rtt *rt)
+{
+	return atomic_read(&rt->ntimeouts);
 }
 
 #endif /* _LINUX_SUNRPC_TIMER_H */
diff -Nru kernel-source-2.6.8/include/linux/sunrpc/xprt.h kernel-source-2.6.8-patched-nfs/include/linux/sunrpc/xprt.h
--- kernel-source-2.6.8/include/linux/sunrpc/xprt.h	2004-08-14 07:37:37.000000000 +0200
+++ kernel-source-2.6.8-patched-nfs/include/linux/sunrpc/xprt.h	2005-10-05 20:52:39.000000000 +0200
@@ -116,7 +116,7 @@
 	u32			rq_bytes_sent;	/* Bytes we have sent */
 
 	unsigned long		rq_xtime;	/* when transmitted */
-	int			rq_ntrans;
+	int			rq_nresend;
 };
 #define rq_svec			rq_snd_buf.head
 #define rq_slen			rq_snd_buf.len
diff -Nru kernel-source-2.6.8/net/sunrpc/timer.c kernel-source-2.6.8-patched-nfs/net/sunrpc/timer.c
--- kernel-source-2.6.8/net/sunrpc/timer.c	2004-08-14 07:37:40.000000000 +0200
+++ kernel-source-2.6.8-patched-nfs/net/sunrpc/timer.c	2005-10-05 20:55:31.000000000 +0200
@@ -24,7 +24,7 @@
 
 #define RPC_RTO_MAX (60*HZ)
 #define RPC_RTO_INIT (HZ/5)
-#define RPC_RTO_MIN (HZ/10)
+#define RPC_RTO_MIN (2)
 
 void
 rpc_init_rtt(struct rpc_rtt *rt, unsigned long timeo)
@@ -39,7 +39,7 @@
 	for (i = 0; i < 5; i++) {
 		rt->srtt[i] = init;
 		rt->sdrtt[i] = RPC_RTO_INIT;
-		rt->ntimeouts[i] = 0;
+		atomic_set(&rt->ntimeouts, 0);
 	}
 }
 
diff -Nru kernel-source-2.6.8/net/sunrpc/xprt.c kernel-source-2.6.8-patched-nfs/net/sunrpc/xprt.c
--- kernel-source-2.6.8/net/sunrpc/xprt.c	2004-08-14 07:37:26.000000000 +0200
+++ kernel-source-2.6.8-patched-nfs/net/sunrpc/xprt.c	2005-10-05 21:54:17.000000000 +0200
@@ -151,7 +151,6 @@
 		xprt->snd_task = task;
 		if (req) {
 			req->rq_bytes_sent = 0;
-			req->rq_ntrans++;
 		}
 		return 1;
 	}
@@ -162,7 +161,7 @@
 	dprintk("RPC: %4d failed to lock socket %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req && req->rq_ntrans)
+	if (req && req->rq_nresend)
 		rpc_sleep_on(&xprt->resend, task, NULL, NULL);
 	else
 		rpc_sleep_on(&xprt->sending, task, NULL, NULL);
@@ -201,7 +200,6 @@
 		xprt->snd_task = task;
 		if (req) {
 			req->rq_bytes_sent = 0;
-			req->rq_ntrans++;
 		}
 		return;
 	}
@@ -644,10 +642,10 @@
 		xprt_adjust_cwnd(xprt, copied);
 		__xprt_put_cong(xprt, req);
 		if (timer) {
-			if (req->rq_ntrans == 1)
+			if (!req->rq_nresend)
 				rpc_update_rtt(clnt->cl_rtt, timer,
 						(long)jiffies - req->rq_xtime);
-			rpc_set_timeo(clnt->cl_rtt, timer, req->rq_ntrans - 1);
+			rpc_clear_timeo(clnt->cl_rtt);
 		}
 	}
 
@@ -1120,7 +1118,7 @@
 		goto out;
 
 	xprt_adjust_cwnd(req->rq_xprt, -ETIMEDOUT);
-	__xprt_put_cong(xprt, req);
+	req->rq_nresend++;
 
 	dprintk("RPC: %4d xprt_timer (%s request)\n",
 		task->tk_pid, req ? "pending" : "backlogged");
@@ -1279,7 +1277,8 @@
 	if (!xprt->nocong) {
 		int timer = task->tk_msg.rpc_proc->p_timer;
 		task->tk_timeout = rpc_calc_rto(clnt->cl_rtt, timer);
-		task->tk_timeout <<= rpc_ntimeo(clnt->cl_rtt, timer) + req->rq_retries;
+		/* FIXME AJ last patch? */
+		task->tk_timeout <<= rpc_ntimeo(clnt->cl_rtt) + req->rq_retries;
 		if (task->tk_timeout > xprt->timeout.to_maxval || task->tk_timeout == 0)
 			task->tk_timeout = xprt->timeout.to_maxval;
 	} else

--------------020703010807060707070000--



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
