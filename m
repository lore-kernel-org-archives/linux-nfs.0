From: Brian Mancuso <bmancuso@akamai.com>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Fri, 26 Sep 2003 17:07:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030926170759.H787@muppet.kendall.corp.akamai.com>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain> <20030925174426.B787@muppet.kendall.corp.akamai.com> <shs1xu430p2.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2ztb-0005Gi-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 14:12:59 -0700
Received: from [80.67.64.10] (helo=akamai.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2zta-0006ce-3y
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 14:12:58 -0700
Received: from akamai.com (vwall1.kendall.corp.akamai.com [172.17.4.33])
	by akamai.com (8.11.7+Sun/8.11.6) with ESMTP id h8QL82928636
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 17:08:02 -0400 (EDT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs1xu430p2.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, Sep 25, 2003 at 04:31:05PM -0700
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

On Thu, Sep 25, 2003 at 04:31:05PM -0700, Trond Myklebust wrote:
: 
: Right... There is already a variable set aside for this task in the
: RTT code in the form of "ntimeouts".
: 
: The following patch sets up a scheme of the form described by Brian,
: in combination with another fix to lengthen the window of time during
: which we accept updates to the RTO estimate (Karn's algorithm states
: that the window closes once you retransmit, whereas our current
: algorithm closes the window once a request times out).
: 
: Could people give it a try?
: 
: Cheers,
:   Trond

Hi Trond,

This patch is great! One thing though: there is one case with this
patch in which a request terminates but the client's ntimeouts value
is not updated: when a request exhausts its retries. I think future
requests should inherit the ntimeouts factor provided by timed-out
requests for their RTO calculations. Here is a patch (against
linux-2.4.23-pre5 with your patch) that implements this (you might
know of a cleaner way of doing this..):

--- clnt.c.1	Fri Sep 26 19:58:30 2003
+++ clnt.c	Fri Sep 26 20:00:38 2003
@@ -699,6 +699,7 @@ call_status(struct rpc_task *task)
 static void
 call_timeout(struct rpc_task *task)
 {
+	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_timeout *to = &task->tk_rqstp->rq_timeout;
 
@@ -707,6 +708,7 @@ call_timeout(struct rpc_task *task)
 		goto retry;
 	}
 	to->to_retries = clnt->cl_timeout.to_retries;
+	rpc_set_timeo(&clnt->cl_rtt, req->rq_ntrans - 1);
 
 	dprintk("RPC: %4d call_timeout (major)\n", task->tk_pid);
 	if (clnt->cl_softrtry) {

I tested your patch. Here is some documentation of my testing:

I added a printk to the code, mounted an NFS volume with a retrans=8
option, and did an ls on a directory with 100,000 entries in it. This
takes awhile, and leaves ample time for the system to develop a good
RTT estimate and for one to interfere with client/server connectivity
so as to induce retransmits with exponential backoff:

01  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 0, rto = 4
02  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 0, rto = 4
...
03  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 0, rto = 4
04  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 2, rto = 16
05  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 3, rto = 32
06  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 4, rto = 64
07  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 5, rto = 128
08  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 6, rto = 256
09  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 7, rto = 512
10  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 0, ntrans = 8, rto = 1024
11  nfs: server 172.18.192.11 not responding, timed out
12  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 8, ntrans = 0, rto = 1024
13  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 8, ntrans = 1, rto = 2048
14  DO_XPRT_TRANSMIT: rtt = 4, ntimeo = 8, ntrans = 2, rto = 4096

The numbers on the left are line numbers I manually inserted for
illustration; they were not produced by the printk. The '...'
indicates lots of lines, identical to the preceding, were removed.
There is one line per RTO calculation (i.e. per transmit). Lines 1-2
show RTO calculations for RPC transactions that saw no loss. 'rtt' is
the value returned by rpc_calc_rto(), and represents the estimated
round trip time plus a constant factor times its mean deviation.
'ntimeo' is the ntimeouts value in the client structure, set to the
number of transmits minus one for the last terminated (successful or
otherwise) request. 'ntrans' is effectively the number of retransmits
of the request in question. 'rto' is the calculated RTO:
rtt << ntimeo + ntrans.

The server was disconnected at (before) line 3. Lines 4-10 show the
client exponentially backing off RTO. Line 11 represents an exhaustion
of retransmit attempts and an EIO returned to the application, ls
(this is a soft mount). Lines 12-14 show RTO calculations for a new
request. Note that the ntimeo on line 12 inherited its value from the
ntrans value of the request that terminated on line 10 (this kernel
had my above modification).

Brian

: diff -u --recursive --new-file linux-2.4.23-pre5/include/linux/sunrpc/timer.h linux-2.4.23-01-fix_retrans/include/linux/sunrpc/timer.h
: --- linux-2.4.23-pre5/include/linux/sunrpc/timer.h	2003-09-19 13:15:31.000000000 -0700
: +++ linux-2.4.23-01-fix_retrans/include/linux/sunrpc/timer.h	2003-09-25 16:25:02.000000000 -0700
: @@ -23,14 +23,9 @@
:  extern void rpc_update_rtt(struct rpc_rtt *rt, int timer, long m);
:  extern long rpc_calc_rto(struct rpc_rtt *rt, int timer);
:  
: -static inline void rpc_inc_timeo(struct rpc_rtt *rt)
: +static inline void rpc_set_timeo(struct rpc_rtt *rt, int ntimeo)
:  {
: -	atomic_inc(&rt->ntimeouts);
: -}
: -
: -static inline void rpc_clear_timeo(struct rpc_rtt *rt)
: -{
: -	atomic_set(&rt->ntimeouts, 0);
: +	atomic_set(&rt->ntimeouts, ntimeo);
:  }
:  
:  static inline int rpc_ntimeo(struct rpc_rtt *rt)
: diff -u --recursive --new-file linux-2.4.23-pre5/include/linux/sunrpc/xprt.h linux-2.4.23-01-fix_retrans/include/linux/sunrpc/xprt.h
: --- linux-2.4.23-pre5/include/linux/sunrpc/xprt.h	2003-07-29 16:52:26.000000000 -0700
: +++ linux-2.4.23-01-fix_retrans/include/linux/sunrpc/xprt.h	2003-09-19 13:15:31.000000000 -0700
: @@ -115,7 +115,7 @@
:  
:  	long			rq_xtime;	/* when transmitted */
:  	int			rq_ntimeo;
: -	int			rq_nresend;
: +	int			rq_ntrans;
:  };
:  #define rq_svec			rq_snd_buf.head
:  #define rq_slen			rq_snd_buf.len
: diff -u --recursive --new-file linux-2.4.23-pre5/net/sunrpc/xprt.c linux-2.4.23-01-fix_retrans/net/sunrpc/xprt.c
: --- linux-2.4.23-pre5/net/sunrpc/xprt.c	2003-07-29 16:54:19.000000000 -0700
: +++ linux-2.4.23-01-fix_retrans/net/sunrpc/xprt.c	2003-09-25 16:25:02.000000000 -0700
: @@ -138,18 +138,21 @@
:  static int
:  __xprt_lock_write(struct rpc_xprt *xprt, struct rpc_task *task)
:  {
: +	struct rpc_rqst *req = task->tk_rqstp;
:  	if (!xprt->snd_task) {
:  		if (xprt->nocong || __xprt_get_cong(xprt, task)) {
:  			xprt->snd_task = task;
: -			if (task->tk_rqstp)
: -				task->tk_rqstp->rq_bytes_sent = 0;
: +			if (req) {
: +				req->rq_bytes_sent = 0;
: +				req->rq_ntrans++;
: +			}
:  		}
:  	}
:  	if (xprt->snd_task != task) {
:  		dprintk("RPC: %4d TCP write queue full\n", task->tk_pid);
:  		task->tk_timeout = 0;
:  		task->tk_status = -EAGAIN;
: -		if (task->tk_rqstp && task->tk_rqstp->rq_nresend)
: +		if (req && req->rq_ntrans)
:  			rpc_sleep_on(&xprt->resend, task, NULL, NULL);
:  		else
:  			rpc_sleep_on(&xprt->sending, task, NULL, NULL);
: @@ -183,9 +186,12 @@
:  			return;
:  	}
:  	if (xprt->nocong || __xprt_get_cong(xprt, task)) {
: +		struct rpc_rqst *req = task->tk_rqstp;
:  		xprt->snd_task = task;
: -		if (task->tk_rqstp)
: -			task->tk_rqstp->rq_bytes_sent = 0;
: +		if (req) {
: +			req->rq_bytes_sent = 0;
: +			req->rq_ntrans++;
: +		}
:  	}
:  }
:  
: @@ -592,12 +598,12 @@
:  	if (!xprt->nocong) {
:  		xprt_adjust_cwnd(xprt, copied);
:  		__xprt_put_cong(xprt, req);
: -	       	if (!req->rq_nresend) {
: +	       	if (req->rq_ntrans == 1) {
:  			int timer = rpcproc_timer(clnt, task->tk_msg.rpc_proc);
:  			if (timer)
:  				rpc_update_rtt(&clnt->cl_rtt, timer, (long)jiffies - req->rq_xtime);
:  		}
: -		rpc_clear_timeo(&clnt->cl_rtt);
: +		rpc_set_timeo(&clnt->cl_rtt, req->rq_ntrans - 1);
:  	}
:  
:  #ifdef RPC_PROFILE
: @@ -1063,7 +1069,7 @@
:  		goto out;
:  
:  	xprt_adjust_cwnd(req->rq_xprt, -ETIMEDOUT);
: -	req->rq_nresend++;
: +	__xprt_put_cong(xprt, req);
:  
:  	dprintk("RPC: %4d xprt_timer (%s request)\n",
:  		task->tk_pid, req ? "pending" : "backlogged");
: @@ -1219,6 +1225,7 @@
:  	if (!xprt->nocong) {
:  		task->tk_timeout = rpc_calc_rto(&clnt->cl_rtt,
:  				rpcproc_timer(clnt, task->tk_msg.rpc_proc));
: +		task->tk_timeout <<= rpc_ntimeo(&clnt->cl_rtt);
:  		task->tk_timeout <<= clnt->cl_timeout.to_retries
:  			- req->rq_timeout.to_retries;
:  		if (task->tk_timeout > req->rq_timeout.to_maxval)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
