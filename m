Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5293 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485Ab3IZVpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/7] SUNRPC: Add RPC task and client level options to disable the resend timeout
Date: Thu, 26 Sep 2013 17:45:04 -0400
Message-ID: <1380231907-13733-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h  | 2 ++
 include/linux/sunrpc/sched.h | 1 +
 net/sunrpc/clnt.c            | 5 ++++-
 net/sunrpc/xprt.c            | 7 +++++++
 4 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6740801..943ee89 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -49,6 +49,7 @@ struct rpc_clnt {
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_discrtry : 1,/* disconnect before retry */
+				cl_noretranstimeo: 1,/* No retransmit timeouts */
 				cl_autobind : 1,/* use getport() */
 				cl_chatty   : 1;/* be verbose */
 
@@ -126,6 +127,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
 #define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
 #define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 8)
+#define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 096ee58..3a847de 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -122,6 +122,7 @@ struct rpc_task_setup {
 #define RPC_TASK_SENT		0x0800		/* message was sent */
 #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
 #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
+#define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa50e42..b585250 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -772,6 +772,8 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (clnt->cl_noretranstimeo)
+			task->tk_flags |= RPC_TASK_NO_RETRANS_TIMEOUT;
 		if (sk_memalloc_socks()) {
 			struct rpc_xprt *xprt;
 
@@ -1898,7 +1900,8 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
-		if (task->tk_client->cl_discrtry)
+		if (!(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT)
+		    && task->tk_client->cl_discrtry)
 			xprt_conditional_disconnect(req->rq_xprt,
 					req->rq_connect_cookie);
 		break;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c94f4a2..d992d7f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -867,6 +867,13 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 		task->tk_status = req->rq_reply_bytes_recvd;
 		goto out_unlock;
 	}
+	if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT)
+	    && xprt_connected(xprt)
+	    && req->rq_connect_cookie == xprt->connect_cookie) {
+		xprt->ops->set_retrans_timeout(task);
+		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		goto out_unlock;
+	}
 	if (!xprt->ops->reserve_xprt(xprt, task)) {
 		task->tk_status = -EAGAIN;
 		goto out_unlock;
-- 
1.8.3.1

