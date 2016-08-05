Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33672 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbcHGAmw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 20:42:52 -0400
Received: by mail-io0-f194.google.com with SMTP id y195so26622945iod.0
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 17:42:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: Limit the reconnect backoff timer to the max RPC message timeout
Date: Fri,  5 Aug 2016 19:37:33 -0400
Message-Id: <1470440255-8612-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
References: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and ensure that we propagate it to new transports on the same
client.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h |  3 ++-
 net/sunrpc/clnt.c           |  3 +++
 net/sunrpc/xprtsock.c       | 18 ++++++++++++------
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 5e3e1b63dbb3..a16070dd03ee 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -218,7 +218,8 @@ struct rpc_xprt {
 	struct work_struct	task_cleanup;
 	struct timer_list	timer;
 	unsigned long		last_used,
-				idle_timeout;
+				idle_timeout,
+				max_reconnect_timeout;
 
 	/*
 	 * Send stuff
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cb49898a5a58..faac5472d14d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2638,6 +2638,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 {
 	struct rpc_xprt_switch *xps;
 	struct rpc_xprt *xprt;
+	unsigned long reconnect_timeout;
 	unsigned char resvport;
 	int ret = 0;
 
@@ -2649,6 +2650,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 		return -EAGAIN;
 	}
 	resvport = xprt->resvport;
+	reconnect_timeout = xprt->max_reconnect_timeout;
 	rcu_read_unlock();
 
 	xprt = xprt_create_transport(xprtargs);
@@ -2657,6 +2659,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 		goto out_put_switch;
 	}
 	xprt->resvport = resvport;
+	xprt->max_reconnect_timeout = reconnect_timeout;
 
 	rpc_xprt_switch_set_roundrobin(xps);
 	if (setup) {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 04b0c4190dd7..8ede3bc52481 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -177,7 +177,6 @@ static struct ctl_table sunrpc_table[] = {
  * increase over time if the server is down or not responding.
  */
 #define XS_TCP_INIT_REEST_TO	(3U * HZ)
-#define XS_TCP_MAX_REEST_TO	(5U * 60 * HZ)
 
 /*
  * TCP idle timeout; client drops the transport socket if it is idle
@@ -2396,6 +2395,15 @@ static unsigned long xs_reconnect_delay(const struct rpc_xprt *xprt)
 	return 0;
 }
 
+static void xs_reconnect_backoff(struct rpc_xprt *xprt)
+{
+	xprt->reestablish_timeout <<= 1;
+	if (xprt->reestablish_timeout > xprt->max_reconnect_timeout)
+		xprt->reestablish_timeout = xprt->max_reconnect_timeout;
+	if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+		xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+}
+
 /**
  * xs_connect - connect a socket to a remote endpoint
  * @xprt: pointer to transport structure
@@ -2426,12 +2434,8 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		xs_reset_transport(transport);
 
 		delay = xs_reconnect_delay(xprt);
+		xs_reconnect_backoff(xprt);
 
-		xprt->reestablish_timeout <<= 1;
-		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
-			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
-			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 
@@ -2989,6 +2993,8 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->ops = &xs_tcp_ops;
 	xprt->timeout = &xs_tcp_default_timeout;
 
+	xprt->max_reconnect_timeout = xprt->timeout->to_maxval;
+
 	INIT_WORK(&transport->recv_worker, xs_tcp_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_setup_socket);
 
-- 
2.7.4

