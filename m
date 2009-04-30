From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 10/39] nfs41: Add backchannel processing support to RPC state machine
Date: Fri,  1 May 2009 02:20:43 +0300
Message-ID: <1241133643-622-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2816 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756022AbZD3XUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:54 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Adds rpc_run_bc_task() which is called by the NFS callback service to
process backchannel requests.  It performs similar work to rpc_run_task()
though "schedules" the backchannel task to be executed starting at the
call_trasmit state in the RPC state machine.

It also introduces some miscellaneous updates to the argument validation,
call_transmit, and transport cleanup functions to take into account
that there are now forechannel and backchannel tasks.

Backchannel requests do not carry an RPC message structure, since the
payload has already been XDR encoded using the existing NFSv4 callback
mechanism.

Introduce a new transmit state for the client to reply on to backchannel
requests.  This new state simply reserves the transport and issues the
reply.  In case of a connection related error, disconnects the transport and
drops the reply.  It requires the forechannel to re-establish the connection
and the server to retransmit the request, as stated in NFSv4.1 section
2.9.2 "Client and Server Transport Behavior".

Note: There is no need to loop attempting to reserve the transport.  If EAGAIN
is returned by xprt_prepare_transmit(), return with tk_status == 0,
setting tk_action to call_bc_transmit.  rpc_execute() will invoke it again
after the task is taken off the sleep queue.

[nfs41: rpc_run_bc_task() need not be exported outside RPC module]
[nfs41: New call_bc_transmit RPC state]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Backchannel: No need to loop in call_bc_transmit()]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/sched.h |    2 +
 include/linux/sunrpc/xprt.h  |   12 ++++
 net/sunrpc/clnt.c            |  117 +++++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/stats.c           |    6 ++-
 net/sunrpc/sunrpc.h          |   35 +++++++++++++
 net/sunrpc/xprt.c            |   36 +++++++++++--
 6 files changed, 199 insertions(+), 9 deletions(-)
 create mode 100644 net/sunrpc/sunrpc.h

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 1773768..4010977 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -210,6 +210,8 @@ struct rpc_wait_queue {
  */
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
+struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
+				const struct rpc_call_ops *ops);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6b37724..1531abe 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -215,6 +215,18 @@ struct rpc_xprt {
 						/* buffer in use */
 #endif /* CONFIG_NFS_V4_1 */
 
+#if defined(CONFIG_NFS_V4_1)
+static inline int bc_prealloc(struct rpc_rqst *req)
+{
+	return test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
+}
+#else
+static inline int bc_prealloc(struct rpc_rqst *req)
+{
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 struct xprt_create {
 	int			ident;		/* XPRT_TRANSPORT identifier */
 	struct sockaddr *	srcaddr;	/* optional local address */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76d7d46..349b4d6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -36,7 +36,9 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
+#include <linux/sunrpc/bc_xprt.h>
 
+#include "sunrpc.h"
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_CALL
@@ -63,6 +65,9 @@ static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
 static void	call_transmit(struct rpc_task *task);
+#if defined(CONFIG_NFS_V4_1)
+static void	call_bc_transmit(struct rpc_task *task);
+#endif /* CONFIG_NFS_V4_1 */
 static void	call_status(struct rpc_task *task);
 static void	call_transmit_status(struct rpc_task *task);
 static void	call_refresh(struct rpc_task *task);
@@ -613,6 +618,50 @@ rpc_call_async(struct rpc_clnt *clnt, const struct rpc_message *msg, int flags,
 }
 EXPORT_SYMBOL_GPL(rpc_call_async);
 
+#if defined(CONFIG_NFS_V4_1)
+/**
+ * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
+ * rpc_execute against it
+ * @ops: RPC call ops
+ */
+struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
+					const struct rpc_call_ops *tk_ops)
+{
+	struct rpc_task *task;
+	struct xdr_buf *xbufp = &req->rq_snd_buf;
+	struct rpc_task_setup task_setup_data = {
+		.callback_ops = tk_ops,
+	};
+
+	dprintk("RPC: rpc_run_bc_task req= %p\n", req);
+	/*
+	 * Create an rpc_task to send the data
+	 */
+	task = rpc_new_task(&task_setup_data);
+	if (!task) {
+		xprt_free_bc_request(req);
+		goto out;
+	}
+	task->tk_rqstp = req;
+
+	/*
+	 * Set up the xdr_buf length.
+	 * This also indicates that the buffer is XDR encoded already.
+	 */
+	xbufp->len = xbufp->head[0].iov_len + xbufp->page_len +
+			xbufp->tail[0].iov_len;
+
+	task->tk_action = call_bc_transmit;
+	atomic_inc(&task->tk_count);
+	BUG_ON(atomic_read(&task->tk_count) != 2);
+	rpc_execute(task);
+
+out:
+	dprintk("RPC: rpc_run_bc_task: task= %p\n", task);
+	return task;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 void
 rpc_call_start(struct rpc_task *task)
 {
@@ -1098,7 +1147,7 @@ call_transmit(struct rpc_task *task)
 	 * in order to allow access to the socket to other RPC requests.
 	 */
 	call_transmit_status(task);
-	if (task->tk_msg.rpc_proc->p_decode != NULL)
+	if (rpc_reply_expected(task))
 		return;
 	task->tk_action = rpc_exit_task;
 	rpc_wake_up_queued_task(&task->tk_xprt->pending, task);
@@ -1133,6 +1182,72 @@ call_transmit_status(struct rpc_task *task)
 	}
 }
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * 5b.	Send the backchannel RPC reply.  On error, drop the reply.  In
+ * addition, disconnect on connectivity errors.
+ */
+static void
+call_bc_transmit(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	BUG_ON(task->tk_status != 0);
+	task->tk_status = xprt_prepare_transmit(task);
+	if (task->tk_status == -EAGAIN) {
+		/*
+		 * Could not reserve the transport. Try again after the
+		 * transport is released.
+		 */
+		task->tk_status = 0;
+		task->tk_action = call_bc_transmit;
+		return;
+	}
+
+	task->tk_action = rpc_exit_task;
+	if (task->tk_status < 0) {
+		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
+			"error: %d\n", task->tk_status);
+		return;
+	}
+
+	xprt_transmit(task);
+	xprt_end_transmit(task);
+	dprint_status(task);
+	switch (task->tk_status) {
+	case 0:
+		/* Success */
+		break;
+	case -EHOSTDOWN:
+	case -EHOSTUNREACH:
+	case -ENETUNREACH:
+	case -ETIMEDOUT:
+		/*
+		 * Problem reaching the server.  Disconnect and let the
+		 * forechannel reestablish the connection.  The server will
+		 * have to retransmit the backchannel request and we'll
+		 * reprocess it.  Since these ops are idempotent, there's no
+		 * need to cache our reply at this time.
+		 */
+		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
+			"error: %d\n", task->tk_status);
+		xprt_conditional_disconnect(task->tk_xprt,
+			req->rq_connect_cookie);
+		break;
+	default:
+		/*
+		 * We were unable to reply and will have to drop the
+		 * request.  The server should reconnect and retransmit.
+		 */
+		BUG_ON(task->tk_status == -EAGAIN);
+		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
+			"error: %d\n", task->tk_status);
+		break;
+	}
+	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * 6.	Sort out the RPC call status
  */
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 1ef6e46..a0e3d97 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -141,12 +141,14 @@ EXPORT_SYMBOL_GPL(rpc_free_iostats);
 void rpc_count_iostats(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_iostats *stats = task->tk_client->cl_metrics;
+	struct rpc_iostats *stats;
 	struct rpc_iostats *op_metrics;
 	long rtt, execute, queue;
 
-	if (!stats || !req)
+	if (!task->tk_client || task->tk_client->cl_metrics || !req)
 		return;
+
+	stats = task->tk_client->cl_metrics;
 	op_metrics = &stats[task->tk_msg.rpc_proc->p_statidx];
 
 	op_metrics->om_ops++;
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
new file mode 100644
index 0000000..b462de4
--- /dev/null
+++ b/net/sunrpc/sunrpc.h
@@ -0,0 +1,35 @@
+/******************************************************************************
+
+(c) 2008 Network Appliance, Inc.  All Rights Reserved.
+
+Network Appliance provides this source code under the GPL v2 License.
+The GPL v2 license is available at
+http://opensource.org/licenses/gpl-license.php.
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+******************************************************************************/
+
+/*
+ * Functions and macros used internally by RPC
+ */
+
+#ifndef _NET_SUNRPC_SUNRPC_H
+#define _NET_SUNRPC_SUNRPC_H
+
+#define rpc_reply_expected(task) \
+	(((task)->tk_msg.rpc_proc != NULL) && \
+	((task)->tk_msg.rpc_proc->p_decode != NULL))
+
+#endif /* _NET_SUNRPC_SUNRPC_H */
+
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index bbaec23..df65d15 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -12,8 +12,9 @@
  *  -	Next, the caller puts together the RPC message, stuffs it into
  *	the request struct, and calls xprt_transmit().
  *  -	xprt_transmit sends the message and installs the caller on the
- *	transport's wait list. At the same time, it installs a timer that
- *	is run after the packet's timeout has expired.
+ *	transport's wait list. At the same time, if a reply is expected,
+ *	it installs a timer that is run after the packet's timeout has
+ *	expired.
  *  -	When a packet arrives, the data_ready handler walks the list of
  *	pending requests for that transport. If a matching XID is found, the
  *	caller is woken up, and the timer removed.
@@ -46,6 +47,8 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
 
+#include "sunrpc.h"
+
 /*
  * Local variables
  */
@@ -875,7 +878,10 @@ void xprt_transmit(struct rpc_task *task)
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
 	if (!req->rq_received) {
-		if (list_empty(&req->rq_list)) {
+		if (list_empty(&req->rq_list) && rpc_reply_expected(task)) {
+			/*
+			 * Add to the list only if we're expecting a reply
+			 */
 			spin_lock_bh(&xprt->transport_lock);
 			/* Update the softirq receive buffer */
 			memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
@@ -910,8 +916,13 @@ void xprt_transmit(struct rpc_task *task)
 	/* Don't race with disconnect */
 	if (!xprt_connected(xprt))
 		task->tk_status = -ENOTCONN;
-	else if (!req->rq_received)
+	else if (!req->rq_received && rpc_reply_expected(task)) {
+		/*
+		 * Sleep on the pending queue since
+		 * we're expecting a reply.
+		 */
 		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
@@ -984,11 +995,15 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
  */
 void xprt_release(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt = task->tk_xprt;
+	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
+	int prealloc;
 
+	BUG_ON(atomic_read(&task->tk_count) < 0);
 	if (!(req = task->tk_rqstp))
 		return;
+	prealloc = bc_prealloc(req);	/* Preallocated backchannel request? */
+	xprt = req->rq_xprt;
 	rpc_count_iostats(task);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
@@ -1001,10 +1016,19 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
-	xprt->ops->buf_free(req->rq_buffer);
+	if (!bc_prealloc(req))
+		xprt->ops->buf_free(req->rq_buffer);
 	task->tk_rqstp = NULL;
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);
+
+	/*
+	 * Early exit if this is a backchannel preallocated request.
+	 * There is no need to have it added to the RPC slot list.
+	 */
+	if (prealloc)
+		return;
+
 	memset(req, 0, sizeof(*req));	/* mark unused */
 
 	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
-- 
1.6.2.1

