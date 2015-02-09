Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:49852 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933726AbbBIWsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:20 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so19962449igb.3
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:20 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/15] SUNRPC: Add helpers to prevent socket create from racing
Date: Mon,  9 Feb 2015 17:48:01 -0500
Message-Id: <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The socket lock is currently held by the task that is requesting the
connection be established. While that is efficient in the case where
the connection happens quickly, it is racy in the case where it doesn't.
What we really want is for the connect helper to be able to block access
to the socket while it is being set up.

This patch does so by arranging to transfer the socket lock from the
task that is requesting the connect attempt, and then releasing that
lock once everything is done.
This scheme also gives us automatic protection against collisions with
the RPC close code, so we can kill the cancel_delayed_work_sync()
call in xs_close().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h |  3 +++
 net/sunrpc/xprt.c           | 37 +++++++++++++++++++++++++++++++++----
 net/sunrpc/xprtsock.c       |  7 +++++--
 3 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 9d27ac45b909..2926e618dbc6 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -347,6 +347,9 @@ void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
+bool			xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
+void			xprt_unlock_connect(struct rpc_xprt *, void *);
+
 /*
  * Reserved bit positions in xprt->state
  */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ebbefad21a37..ff3574df8344 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -690,6 +690,37 @@ out_abort:
 	spin_unlock(&xprt->transport_lock);
 }
 
+bool xprt_lock_connect(struct rpc_xprt *xprt,
+		struct rpc_task *task,
+		void *cookie)
+{
+	bool ret = false;
+
+	spin_lock_bh(&xprt->transport_lock);
+	if (!test_bit(XPRT_LOCKED, &xprt->state))
+		goto out;
+	if (xprt->snd_task != task)
+		goto out;
+	xprt->snd_task = cookie;
+	ret = true;
+out:
+	spin_unlock_bh(&xprt->transport_lock);
+	return ret;
+}
+
+void xprt_unlock_connect(struct rpc_xprt *xprt, void *cookie)
+{
+	spin_lock_bh(&xprt->transport_lock);
+	if (xprt->snd_task != cookie)
+		goto out;
+	if (!test_bit(XPRT_LOCKED, &xprt->state))
+		goto out;
+	xprt->snd_task =NULL;
+	xprt->ops->release_xprt(xprt, NULL);
+out:
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
 /**
  * xprt_connect - schedule a transport connect operation
  * @task: RPC task that is requesting the connect
@@ -712,9 +743,7 @@ void xprt_connect(struct rpc_task *task)
 	if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state))
 		xprt->ops->close(xprt);
 
-	if (xprt_connected(xprt))
-		xprt_release_write(xprt, task);
-	else {
+	if (!xprt_connected(xprt)) {
 		task->tk_rqstp->rq_bytes_sent = 0;
 		task->tk_timeout = task->tk_rqstp->rq_timeout;
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
@@ -726,6 +755,7 @@ void xprt_connect(struct rpc_task *task)
 		xprt->stat.connect_start = jiffies;
 		xprt->ops->connect(xprt, task);
 	}
+	xprt_release_write(xprt, task);
 }
 
 static void xprt_connect_status(struct rpc_task *task)
@@ -758,7 +788,6 @@ static void xprt_connect_status(struct rpc_task *task)
 		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
 				"server %s\n", task->tk_pid, -task->tk_status,
 				xprt->servername);
-		xprt_release_write(xprt, task);
 		task->tk_status = -EIO;
 	}
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0fa7ed93dc20..e57d8ed2c4d8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -852,8 +852,6 @@ static void xs_close(struct rpc_xprt *xprt)
 
 	dprintk("RPC:       xs_close xprt %p\n", xprt);
 
-	cancel_delayed_work_sync(&transport->connect_worker);
-
 	xs_reset_transport(transport);
 	xprt->reestablish_timeout = 0;
 
@@ -2101,6 +2099,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
+	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
 }
@@ -2286,6 +2285,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
+		xprt_unlock_connect(xprt, transport);
 		xprt_clear_connecting(xprt);
 		return;
 	case -EINVAL:
@@ -2303,6 +2303,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 out_eagain:
 	status = -EAGAIN;
 out:
+	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
 }
@@ -2325,6 +2326,8 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
+	WARN_ON_ONCE(!xprt_lock_connect(xprt, task, transport));
+
 	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
-- 
2.1.0

