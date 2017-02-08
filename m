Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36790 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932072AbdBHQZJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:25:09 -0500
Received: by mail-it0-f67.google.com with SMTP id f200so16014933itf.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:25:09 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] SUNRPC: Allow changing of the TCP timeout parameters on the fly
Date: Wed,  8 Feb 2017 11:17:54 -0500
Message-Id: <20170208161755.3614-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170208161755.3614-3-trond.myklebust@primarydata.com>
References: <20170208161755.3614-1-trond.myklebust@primarydata.com>
 <20170208161755.3614-2-trond.myklebust@primarydata.com>
 <20170208161755.3614-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the NFSv4 server tells us the lease period, we usually want
to adjust down the timeout parameters on the TCP connection to
ensure that we don't miss lease renewals due to a faulty connection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h     |  4 ++++
 include/linux/sunrpc/xprtsock.h |  3 +++
 net/sunrpc/clnt.c               | 30 ++++++++++++++++++------
 net/sunrpc/xprtsock.c           | 51 +++++++++++++++++++++++++++++++++++++----
 4 files changed, 77 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a5da60b24d83..eab1c749e192 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -137,6 +137,9 @@ struct rpc_xprt_ops {
 	void		(*release_request)(struct rpc_task *task);
 	void		(*close)(struct rpc_xprt *xprt);
 	void		(*destroy)(struct rpc_xprt *xprt);
+	void		(*set_connect_timeout)(struct rpc_xprt *xprt,
+					unsigned long connect_timeout,
+					unsigned long reconnect_timeout);
 	void		(*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
 	int		(*enable_swap)(struct rpc_xprt *xprt);
 	void		(*disable_swap)(struct rpc_xprt *xprt);
@@ -221,6 +224,7 @@ struct rpc_xprt {
 	struct timer_list	timer;
 	unsigned long		last_used,
 				idle_timeout,
+				connect_timeout,
 				max_reconnect_timeout;
 
 	/*
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index bef3fb0abb8f..c9959d7e3579 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -55,6 +55,8 @@ struct sock_xprt {
 	size_t			rcvsize,
 				sndsize;
 
+	struct rpc_timeout	tcp_timeout;
+
 	/*
 	 * Saved socket callback addresses
 	 */
@@ -81,6 +83,7 @@ struct sock_xprt {
 
 #define XPRT_SOCK_CONNECTING	1U
 #define XPRT_SOCK_DATA_READY	(2)
+#define XPRT_SOCK_UPD_TIMEOUT	(3)
 
 #endif /* __KERNEL__ */
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2838a1fab460..b5bc0c589f6a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2684,6 +2684,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 {
 	struct rpc_xprt_switch *xps;
 	struct rpc_xprt *xprt;
+	unsigned long connect_timeout;
 	unsigned long reconnect_timeout;
 	unsigned char resvport;
 	int ret = 0;
@@ -2696,6 +2697,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 		return -EAGAIN;
 	}
 	resvport = xprt->resvport;
+	connect_timeout = xprt->connect_timeout;
 	reconnect_timeout = xprt->max_reconnect_timeout;
 	rcu_read_unlock();
 
@@ -2705,7 +2707,10 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 		goto out_put_switch;
 	}
 	xprt->resvport = resvport;
-	xprt->max_reconnect_timeout = reconnect_timeout;
+	if (xprt->ops->set_connect_timeout != NULL)
+		xprt->ops->set_connect_timeout(xprt,
+				connect_timeout,
+				reconnect_timeout);
 
 	rpc_xprt_switch_set_roundrobin(xps);
 	if (setup) {
@@ -2722,24 +2727,35 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_add_xprt);
 
+struct connect_timeout_data {
+	unsigned long connect_timeout;
+	unsigned long reconnect_timeout;
+};
+
 static int
-rpc_xprt_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
+rpc_xprt_set_connect_timeout(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt,
 		void *data)
 {
-	unsigned long timeout = *((unsigned long *)data);
+	struct connect_timeout_data *timeo = data;
 
-	if (timeout < xprt->max_reconnect_timeout)
-		xprt->max_reconnect_timeout = timeout;
+	if (xprt->ops->set_connect_timeout)
+		xprt->ops->set_connect_timeout(xprt,
+				timeo->connect_timeout,
+				timeo->reconnect_timeout);
 	return 0;
 }
 
 void
 rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt, unsigned long timeo)
 {
+	struct connect_timeout_data timeout = {
+		.connect_timeout = timeo,
+		.reconnect_timeout = timeo,
+	};
 	rpc_clnt_iterate_for_each_xprt(clnt,
-			rpc_xprt_cap_max_reconnect_timeout,
-			&timeo);
+			rpc_xprt_set_connect_timeout,
+			&timeout);
 }
 EXPORT_SYMBOL_GPL(rpc_cap_max_reconnect_timeout);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c8ac649a51cb..810e9b59be16 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -52,6 +52,8 @@
 #include "sunrpc.h"
 
 static void xs_close(struct rpc_xprt *xprt);
+static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
+		struct socket *sock);
 
 /*
  * xprtsock tunables
@@ -666,6 +668,9 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	if (task->tk_flags & RPC_TASK_SENT)
 		zerocopy = false;
 
+	if (test_bit(XPRT_SOCK_UPD_TIMEOUT, &transport->sock_state))
+		xs_tcp_set_socket_timeouts(xprt, transport->sock);
+
 	/* Continue transmitting the packet/record. We must be careful
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
@@ -2238,11 +2243,20 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
 		struct socket *sock)
 {
-	unsigned int keepidle = DIV_ROUND_UP(xprt->timeout->to_initval, HZ);
-	unsigned int keepcnt = xprt->timeout->to_retries + 1;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	unsigned int keepidle;
+	unsigned int keepcnt;
 	unsigned int opt_on = 1;
 	unsigned int timeo;
 
+	spin_lock_bh(&xprt->transport_lock);
+	keepidle = DIV_ROUND_UP(xprt->timeout->to_initval, HZ);
+	keepcnt = xprt->timeout->to_retries + 1;
+	timeo = jiffies_to_msecs(xprt->timeout->to_initval) *
+		(xprt->timeout->to_retries + 1);
+	clear_bit(XPRT_SOCK_UPD_TIMEOUT, &transport->sock_state);
+	spin_unlock_bh(&xprt->transport_lock);
+
 	/* TCP Keepalive options */
 	kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
 			(char *)&opt_on, sizeof(opt_on));
@@ -2254,12 +2268,38 @@ static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
 			(char *)&keepcnt, sizeof(keepcnt));
 
 	/* TCP user timeout (see RFC5482) */
-	timeo = jiffies_to_msecs(xprt->timeout->to_initval) *
-		(xprt->timeout->to_retries + 1);
 	kernel_setsockopt(sock, SOL_TCP, TCP_USER_TIMEOUT,
 			(char *)&timeo, sizeof(timeo));
 }
 
+static void xs_tcp_set_connect_timeout(struct rpc_xprt *xprt,
+		unsigned long connect_timeout,
+		unsigned long reconnect_timeout)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct rpc_timeout to;
+	unsigned long initval;
+
+	spin_lock_bh(&xprt->transport_lock);
+	if (reconnect_timeout < xprt->max_reconnect_timeout)
+		xprt->max_reconnect_timeout = reconnect_timeout;
+	if (connect_timeout < xprt->connect_timeout) {
+		memcpy(&to, xprt->timeout, sizeof(to));
+		initval = DIV_ROUND_UP(connect_timeout, to.to_retries + 1);
+		/* Arbitrary lower limit */
+		if (initval <  XS_TCP_INIT_REEST_TO << 1)
+			initval = XS_TCP_INIT_REEST_TO << 1;
+		to.to_initval = initval;
+		to.to_maxval = initval;
+		memcpy(&transport->tcp_timeout, &to,
+				sizeof(transport->tcp_timeout));
+		xprt->timeout = &transport->tcp_timeout;
+		xprt->connect_timeout = connect_timeout;
+	}
+	set_bit(XPRT_SOCK_UPD_TIMEOUT, &transport->sock_state);
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
 static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -2728,6 +2768,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
+	.set_connect_timeout	= xs_tcp_set_connect_timeout,
 	.print_stats		= xs_tcp_print_stats,
 	.enable_swap		= xs_enable_swap,
 	.disable_swap		= xs_disable_swap,
@@ -3014,6 +3055,8 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->timeout = &xs_tcp_default_timeout;
 
 	xprt->max_reconnect_timeout = xprt->timeout->to_maxval;
+	xprt->connect_timeout = xprt->timeout->to_initval *
+		(xprt->timeout->to_retries + 1);
 
 	INIT_WORK(&transport->recv_worker, xs_tcp_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_setup_socket);
-- 
2.9.3

