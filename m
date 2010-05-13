Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab0EMVI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:29 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCV021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:29 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/15] SUNRPC: Move the task->tk_bytes_sent and tk_rtt to struct rpc_rqst
Date: Thu, 13 May 2010 17:08:18 -0400
Message-Id: <1273784901-25599-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It seems strange to maintain stats for bytes_sent in one structure, and
bytes received in another. Try to assemble all the RPC request-related
stats in struct rpc_rqst

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h    |    4 +---
 include/linux/sunrpc/xprt.h     |    6 ++++--
 net/sunrpc/stats.c              |    4 ++--
 net/sunrpc/xprt.c               |    4 ++--
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtsock.c           |    4 ++--
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 76720d2..46ebef1 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -80,9 +80,7 @@ struct rpc_task {
 	} u;
 
 	unsigned short		tk_timeouts;	/* maj timeouts */
-	size_t			tk_bytes_sent;	/* total bytes sent */
-	ktime_t			tk_start,	/* RPC task init timestamp */
-				tk_rtt;		/* round-trip time */
+	ktime_t			tk_start;	/* RPC task init timestamp */
 
 	pid_t			tk_owner;	/* Process id for batching tasks */
 	unsigned char		tk_priority : 2;/* Task priority */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index f885186..b514703 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -66,8 +66,6 @@ struct rpc_rqst {
 	struct rpc_task *	rq_task;	/* RPC task data */
 	__be32			rq_xid;		/* request XID */
 	int			rq_cong;	/* has incremented xprt->cong */
-	int			rq_reply_bytes_recvd;	/* number of reply */
-							/* bytes received */
 	u32			rq_seqno;	/* gss seq no. used on req. */
 	int			rq_enc_pages_num;
 	struct page		**rq_enc_pages;	/* scratch pages for use by
@@ -78,12 +76,16 @@ struct rpc_rqst {
 	__u32 *			rq_buffer;	/* XDR encode buffer */
 	size_t			rq_callsize,
 				rq_rcvsize;
+	size_t			rq_xmit_bytes_sent;	/* total bytes sent */
+	size_t			rq_reply_bytes_recvd;	/* total reply bytes */
+							/* received */
 
 	struct xdr_buf		rq_private_buf;		/* The receive buffer
 							 * used in the softirq.
 							 */
 	unsigned long		rq_majortimeo;	/* major timeout alarm */
 	unsigned long		rq_timeout;	/* Current timeout value */
+	ktime_t			rq_rtt;		/* round-trip time */
 	unsigned int		rq_retries;	/* # of retries */
 	unsigned int		rq_connect_cookie;
 						/* A cookie used to track the
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index aacd95f..ea1046f 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -156,13 +156,13 @@ void rpc_count_iostats(struct rpc_task *task)
 	op_metrics->om_ntrans += req->rq_ntrans;
 	op_metrics->om_timeouts += task->tk_timeouts;
 
-	op_metrics->om_bytes_sent += task->tk_bytes_sent;
+	op_metrics->om_bytes_sent += req->rq_xmit_bytes_sent;
 	op_metrics->om_bytes_recv += req->rq_reply_bytes_recvd;
 
 	delta = ktime_sub(req->rq_xtime, task->tk_start);
 	op_metrics->om_queue = ktime_add(op_metrics->om_queue, delta);
 
-	op_metrics->om_rtt = ktime_add(op_metrics->om_rtt, task->tk_rtt);
+	op_metrics->om_rtt = ktime_add(op_metrics->om_rtt, req->rq_rtt);
 
 	delta = ktime_sub(ktime_get(), task->tk_start);
 	op_metrics->om_execute = ktime_add(op_metrics->om_execute, delta);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8986b1b..65fe2e4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -780,7 +780,7 @@ static void xprt_update_rtt(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_rtt *rtt = task->tk_client->cl_rtt;
 	unsigned timer = task->tk_msg.rpc_proc->p_timer;
-	long m = usecs_to_jiffies(ktime_to_us(task->tk_rtt));
+	long m = usecs_to_jiffies(ktime_to_us(req->rq_rtt));
 
 	if (timer) {
 		if (req->rq_ntrans == 1)
@@ -805,7 +805,7 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 			task->tk_pid, ntohl(req->rq_xid), copied);
 
 	xprt->stat.recvs++;
-	task->tk_rtt = ktime_sub(ktime_get(), req->rq_xtime);
+	req->rq_rtt = ktime_sub(ktime_get(), req->rq_xtime);
 	if (xprt->ops->timer != NULL)
 		xprt_update_rtt(task);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3f3b38c..a85e866 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -674,7 +674,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
 		goto drop_connection;
 
-	task->tk_bytes_sent += rqst->rq_snd_buf.len;
+	rqst->rq_xmit_bytes_sent += rqst->rq_snd_buf.len;
 	rqst->rq_bytes_sent = 0;
 	return 0;
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index beefa7a..02fc7f0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -528,7 +528,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 			xdr->len - req->rq_bytes_sent, status);
 
 	if (status >= 0) {
-		task->tk_bytes_sent += status;
+		req->rq_xmit_bytes_sent += status;
 		if (status >= req->rq_slen)
 			return 0;
 		/* Still some bytes left; set up for a retry later. */
@@ -624,7 +624,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		/* If we've sent the entire packet, immediately
 		 * reset the count of bytes sent. */
 		req->rq_bytes_sent += status;
-		task->tk_bytes_sent += status;
+		req->rq_xmit_bytes_sent += status;
 		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
 			req->rq_bytes_sent = 0;
 			return 0;
-- 
1.6.6.1

