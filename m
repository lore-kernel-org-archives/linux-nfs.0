From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 080/112] SUNRPC: Clean up the transport timeout
	initialisation
Date: Fri, 25 Jan 2008 11:37:52 -0500
Message-ID: <20080125163751.31887.13525.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbYAYQ7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:47 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdt2010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:46 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h     |    5 -----
 net/sunrpc/xprt.c               |   17 -----------------
 net/sunrpc/xprtrdma/transport.c |    7 ++++++-
 net/sunrpc/xprtsock.c           |   29 +++++++++++++++++++++--------
 4 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 2554cd2..a00d4a4 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -203,11 +203,6 @@ struct xprt_class {
 };
 
 /*
- * Transport operations used by ULPs
- */
-void			xprt_set_timeout(struct rpc_timeout *to, unsigned int retr, unsigned long incr);
-
-/*
  * Generic internal transport functions
  */
 struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e28c4b9..5f0a74a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -978,23 +978,6 @@ void xprt_release(struct rpc_task *task)
 }
 
 /**
- * xprt_set_timeout - set constant RPC timeout
- * @to: RPC timeout parameters to set up
- * @retr: number of retries
- * @incr: amount of increase after each retry
- *
- */
-void xprt_set_timeout(struct rpc_timeout *to, unsigned int retr, unsigned long incr)
-{
-	to->to_initval   =
-	to->to_increment = incr;
-	to->to_maxval    = to->to_initval + (incr * retr);
-	to->to_retries   = retr;
-	to->to_exponential = 0;
-}
-EXPORT_SYMBOL_GPL(xprt_set_timeout);
-
-/**
  * xprt_create_transport - create an RPC transport
  * @args: rpc transport creation arguments
  *
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 73033d8..39f1001 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -289,6 +289,11 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
 	module_put(THIS_MODULE);
 }
 
+static const struct rpc_timeout xprt_rdma_default_timeout = {
+	.to_initval = 60 * HZ,
+	.to_maxval = 60 * HZ,
+};
+
 /**
  * xprt_setup_rdma - Set up transport to use RDMA
  *
@@ -327,7 +332,7 @@ xprt_setup_rdma(struct xprt_create *args)
 	}
 
 	/* 60 second timeout, no retries */
-	xprt_set_timeout(&xprt->timeout, 0, 60UL * HZ);
+	memcpy(&xprt->timeout, &xprt_rdma_default_timeout, sizeof(xprt->timeout));
 	xprt->bind_timeout = (60U * HZ);
 	xprt->connect_timeout = (60U * HZ);
 	xprt->reestablish_timeout = (5U * HZ);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cf39060..6335101 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1891,6 +1891,13 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	return xprt;
 }
 
+static const struct rpc_timeout xs_udp_default_timeout = {
+	.to_initval = 5 * HZ,
+	.to_maxval = 30 * HZ,
+	.to_increment = 5 * HZ,
+	.to_retries = 5,
+};
+
 /**
  * xs_setup_udp - Set up transport to use a UDP socket
  * @args: rpc transport creation arguments
@@ -1901,6 +1908,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	const struct rpc_timeout *timeo = &xs_udp_default_timeout;
 
 	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -1919,10 +1927,9 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	xprt->ops = &xs_udp_ops;
 
-	if (args->timeout)
-		xprt->timeout = *args->timeout;
-	else
-		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
+	if (args->timeout != NULL)
+		timeo = args->timeout;
+	memcpy(&xprt->timeout, timeo, sizeof(xprt->timeout));
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -1957,6 +1964,12 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	return ERR_PTR(-EINVAL);
 }
 
+static const struct rpc_timeout xs_tcp_default_timeout = {
+	.to_initval = 60 * HZ,
+	.to_maxval = 60 * HZ,
+	.to_retries = 2,
+};
+
 /**
  * xs_setup_tcp - Set up transport to use a TCP socket
  * @args: rpc transport creation arguments
@@ -1967,6 +1980,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	const struct rpc_timeout *timeo = &xs_tcp_default_timeout;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -1984,10 +1998,9 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 	xprt->ops = &xs_tcp_ops;
 
-	if (args->timeout)
-		xprt->timeout = *args->timeout;
-	else
-		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
+	if (args->timeout != NULL)
+		timeo = args->timeout;
+	memcpy(&xprt->timeout, timeo, sizeof(xprt->timeout));
 
 	switch (addr->sa_family) {
 	case AF_INET:
