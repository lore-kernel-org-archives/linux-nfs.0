From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 081/112] SUNRPC: Add support for per-client timeout values
Date: Fri, 25 Jan 2008 11:37:52 -0500
Message-ID: <20080125163752.31887.98043.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757018AbYAYRBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:01:25 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Zaf020525
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:06 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to be able to support setting the timeo and retrans parameters on
a per-mountpoint basis, we move the rpc_timeout structure into the
rpc_clnt.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h     |    4 +++-
 include/linux/sunrpc/xprt.h     |    3 +--
 net/sunrpc/clnt.c               |   12 +++++++++---
 net/sunrpc/xprt.c               |   11 ++++++-----
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtsock.c           |   11 ++---------
 6 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 4fc268a..51a3381 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -46,6 +46,7 @@ struct rpc_clnt {
 				cl_autobind : 1;/* use getport() */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
+	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
@@ -54,6 +55,7 @@ struct rpc_clnt {
 	struct dentry *		cl_dentry;	/* inode */
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
+	struct rpc_timeout	cl_timeout_default;
 	struct rpc_program *	cl_program;
 	char			cl_inline_name[32];
 };
@@ -99,7 +101,7 @@ struct rpc_create_args {
 	struct sockaddr		*address;
 	size_t			addrsize;
 	struct sockaddr		*saddress;
-	struct rpc_timeout	*timeout;
+	const struct rpc_timeout *timeout;
 	char			*servername;
 	struct rpc_program	*program;
 	u32			version;
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a00d4a4..c3364d8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -120,7 +120,7 @@ struct rpc_xprt {
 	struct kref		kref;		/* Reference count */
 	struct rpc_xprt_ops *	ops;		/* transport methods */
 
-	struct rpc_timeout	timeout;	/* timeout parms */
+	const struct rpc_timeout *timeout;	/* timeout parms */
 	struct sockaddr_storage	addr;		/* server address */
 	size_t			addrlen;	/* size of server address */
 	int			prot;		/* IP protocol */
@@ -191,7 +191,6 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
-	struct rpc_timeout *	timeout;	/* optional timeout parameters */
 };
 
 struct xprt_class {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6a6b96e..a3c00da 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -188,8 +188,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	if (!xprt_bound(clnt->cl_xprt))
 		clnt->cl_autobind = 1;
 
+	clnt->cl_timeout = xprt->timeout;
+	if (args->timeout != NULL) {
+		memcpy(&clnt->cl_timeout_default, args->timeout,
+				sizeof(clnt->cl_timeout_default));
+		clnt->cl_timeout = &clnt->cl_timeout_default;
+	}
+
 	clnt->cl_rtt = &clnt->cl_rtt_default;
-	rpc_init_rtt(&clnt->cl_rtt_default, xprt->timeout.to_initval);
+	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
 
 	kref_init(&clnt->cl_kref);
 
@@ -251,7 +258,6 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
-		.timeout = args->timeout
 	};
 	char servername[48];
 
@@ -348,7 +354,7 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new->cl_autobind = 0;
 	INIT_LIST_HEAD(&new->cl_tasks);
 	spin_lock_init(&new->cl_lock);
-	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_xprt->timeout.to_initval);
+	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_timeout->to_initval);
 	new->cl_metrics = rpc_alloc_iostats(clnt);
 	if (new->cl_metrics == NULL)
 		goto out_no_stats;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5f0a74a..3a7ba44 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -501,9 +501,10 @@ EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
 void xprt_set_retrans_timeout_rtt(struct rpc_task *task)
 {
 	int timer = task->tk_msg.rpc_proc->p_timer;
-	struct rpc_rtt *rtt = task->tk_client->cl_rtt;
+	struct rpc_clnt *clnt = task->tk_client;
+	struct rpc_rtt *rtt = clnt->cl_rtt;
 	struct rpc_rqst *req = task->tk_rqstp;
-	unsigned long max_timeout = req->rq_xprt->timeout.to_maxval;
+	unsigned long max_timeout = clnt->cl_timeout->to_maxval;
 
 	task->tk_timeout = rpc_calc_rto(rtt, timer);
 	task->tk_timeout <<= rpc_ntimeo(rtt, timer) + req->rq_retries;
@@ -514,7 +515,7 @@ EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_rtt);
 
 static void xprt_reset_majortimeo(struct rpc_rqst *req)
 {
-	struct rpc_timeout *to = &req->rq_xprt->timeout;
+	const struct rpc_timeout *to = req->rq_task->tk_client->cl_timeout;
 
 	req->rq_majortimeo = req->rq_timeout;
 	if (to->to_exponential)
@@ -534,7 +535,7 @@ static void xprt_reset_majortimeo(struct rpc_rqst *req)
 int xprt_adjust_timeout(struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
-	struct rpc_timeout *to = &xprt->timeout;
+	const struct rpc_timeout *to = req->rq_task->tk_client->cl_timeout;
 	int status = 0;
 
 	if (time_before(jiffies, req->rq_majortimeo)) {
@@ -928,7 +929,7 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 
-	req->rq_timeout = xprt->timeout.to_initval;
+	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 39f1001..d1389af 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -332,7 +332,7 @@ xprt_setup_rdma(struct xprt_create *args)
 	}
 
 	/* 60 second timeout, no retries */
-	memcpy(&xprt->timeout, &xprt_rdma_default_timeout, sizeof(xprt->timeout));
+	xprt->timeout = &xprt_rdma_default_timeout;
 	xprt->bind_timeout = (60U * HZ);
 	xprt->connect_timeout = (60U * HZ);
 	xprt->reestablish_timeout = (5U * HZ);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6335101..bb30510 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1908,7 +1908,6 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
-	const struct rpc_timeout *timeo = &xs_udp_default_timeout;
 
 	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -1927,9 +1926,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	xprt->ops = &xs_udp_ops;
 
-	if (args->timeout != NULL)
-		timeo = args->timeout;
-	memcpy(&xprt->timeout, timeo, sizeof(xprt->timeout));
+	xprt->timeout = &xs_udp_default_timeout;
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -1980,7 +1977,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
-	const struct rpc_timeout *timeo = &xs_tcp_default_timeout;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -1997,10 +1993,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->idle_timeout = XS_IDLE_DISC_TO;
 
 	xprt->ops = &xs_tcp_ops;
-
-	if (args->timeout != NULL)
-		timeo = args->timeout;
-	memcpy(&xprt->timeout, timeo, sizeof(xprt->timeout));
+	xprt->timeout = &xs_tcp_default_timeout;
 
 	switch (addr->sa_family) {
 	case AF_INET:
