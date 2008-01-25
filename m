From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 005/112] SUNRPC: Fix a race in xs_tcp_state_change()
Date: Fri, 25 Jan 2008 11:37:24 -0500
Message-ID: <20080125163724.31887.81199.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14406 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755283AbYAYRAX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:23 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UW010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:21 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When scheduling the autoclose RPC call, we want to ensure that we don't
race against the test_bit() call in xprt_clear_locked().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |   20 ++++++++++++++++++++
 net/sunrpc/xprtsock.c       |    5 +----
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 30b17b3..6f524a9 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -246,6 +246,7 @@ struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect(struct rpc_xprt *xprt);
+void			xprt_force_disconnect(struct rpc_xprt *xprt);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index cd641c8..8575bf4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -570,6 +570,7 @@ static void xprt_autoclose(struct work_struct *work)
 
 	xprt_disconnect(xprt);
 	xprt->ops->close(xprt);
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt_release_write(xprt, NULL);
 }
 
@@ -588,6 +589,25 @@ void xprt_disconnect(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect);
 
+/**
+ * xprt_force_disconnect - force a transport to disconnect
+ * @xprt: transport to disconnect
+ *
+ */
+void xprt_force_disconnect(struct rpc_xprt *xprt)
+{
+	/* Don't race with the test_bit() in xprt_clear_locked() */
+	spin_lock_bh(&xprt->transport_lock);
+	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	/* Try to schedule an autoclose RPC call */
+	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
+		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	else if (xprt->snd_task != NULL)
+		rpc_wake_up_task(xprt->snd_task);
+	spin_unlock_bh(&xprt->transport_lock);
+}
+EXPORT_SYMBOL_GPL(xprt_force_disconnect);
+
 static void
 xprt_init_autodisconnect(unsigned long data)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2f630a5..29c5e6c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1118,10 +1118,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_SYN_RECV:
 		break;
 	case TCP_CLOSE_WAIT:
-		/* Try to schedule an autoclose RPC calls */
-		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
-		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-			queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		xprt_force_disconnect(xprt);
 	default:
 		xprt_disconnect(xprt);
 	}
