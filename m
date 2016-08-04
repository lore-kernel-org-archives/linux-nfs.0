Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34165 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933543AbcHDNBt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2016 09:01:49 -0400
Received: by mail-io0-f196.google.com with SMTP id g86so21673767ioj.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Aug 2016 06:01:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Fix reconnection timeouts
Date: Thu,  4 Aug 2016 09:00:59 -0400
Message-Id: <1470315660-37206-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the connect attempt fails and backs off, we should start the clock
at the last connection attempt, not time at which we queue up the
reconnect job.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c6b1d48c4319..5eebf48cffa0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2173,6 +2173,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
+
+	xprt->stat.connect_start = jiffies;
 }
 
 static void xs_udp_setup_socket(struct work_struct *work)
@@ -2373,6 +2375,16 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
+static unsigned long xs_reconnect_delay(const struct rpc_xprt *xprt)
+{
+	unsigned long start, now = jiffies;
+
+	start = xprt->stat.connect_start + xprt->reestablish_timeout;
+	if (time_after(start, now))
+		return start - now;
+	return 0;
+}
+
 /**
  * xs_connect - connect a socket to a remote endpoint
  * @xprt: pointer to transport structure
@@ -2390,6 +2402,7 @@ out:
 static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	unsigned long delay = 0;
 
 	WARN_ON_ONCE(!xprt_lock_connect(xprt, task, transport));
 
@@ -2401,19 +2414,19 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		/* Start by resetting any existing state */
 		xs_reset_transport(transport);
 
-		queue_delayed_work(xprtiod_workqueue,
-				   &transport->connect_worker,
-				   xprt->reestablish_timeout);
+		delay = xs_reconnect_delay(xprt);
+
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
-	} else {
+	} else
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
-		queue_delayed_work(xprtiod_workqueue,
-				   &transport->connect_worker, 0);
-	}
+
+	queue_delayed_work(xprtiod_workqueue,
+			&transport->connect_worker,
+			delay);
 }
 
 /**
-- 
2.7.4

