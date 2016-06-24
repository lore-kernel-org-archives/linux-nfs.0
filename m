Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32985 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFXO43 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:29 -0400
Received: by mail-io0-f196.google.com with SMTP id t74so15637665ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] SUNRPC: Add a server side per-connection limit
Date: Fri, 24 Jun 2016 10:55:50 -0400
Message-Id: <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the user to limit the number of requests serviced through a single
connection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 Documentation/kernel-parameters.txt |  6 ++++++
 include/linux/sunrpc/svc.h          |  1 +
 include/linux/sunrpc/svc_xprt.h     |  1 +
 net/sunrpc/svc_xprt.c               | 39 ++++++++++++++++++++++++++++++++++---
 4 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 82b42c958d1c..48ba6d2e670a 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3832,6 +3832,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			using these two parameters to set the minimum and
 			maximum port values.
 
+	sunrpc.svc_rpc_per_connection_limit=
+			[NFS,SUNRPC]
+			Limit the number of requests that the server will
+			process in parallel from a single connection.
+			The default value is 0 (no limit).
+
 	sunrpc.pool_mode=
 			[NFS]
 			Control how the NFS server code allocates CPUs to
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7ca44fb5b675..7321ae933867 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -268,6 +268,7 @@ struct svc_rqst {
 						 * cache pages */
 #define	RQ_VICTIM	(5)			/* about to be shut down */
 #define	RQ_BUSY		(6)			/* request is busy */
+#define	RQ_DATA		(7)			/* request has data */
 	unsigned long		rq_flags;	/* flags field */
 
 	void *			rq_argp;	/* decoded arguments */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b7dabc4baafd..555c004de51e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -69,6 +69,7 @@ struct svc_xprt {
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
+	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
 	spinlock_t		xpt_lock;	/* protects sk_deferred
 						 * and xpt_auth_cache */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index eccc61237ca9..cd26d0d9e41f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -21,6 +21,10 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+static unsigned int svc_rpc_per_connection_limit __read_mostly;
+module_param(svc_rpc_per_connection_limit, uint, 0644);
+
+
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
@@ -327,12 +331,41 @@ char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
 }
 EXPORT_SYMBOL_GPL(svc_print_addr);
 
+static bool svc_xprt_slots_in_range(struct svc_xprt *xprt)
+{
+	unsigned int limit = svc_rpc_per_connection_limit;
+	int nrqsts = atomic_read(&xprt->xpt_nr_rqsts);
+
+	return limit == 0 || (nrqsts >= 0 && nrqsts < limit);
+}
+
+static bool svc_xprt_reserve_slot(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+{
+	if (!test_bit(RQ_DATA, &rqstp->rq_flags)) {
+		if (!svc_xprt_slots_in_range(xprt))
+			return false;
+		atomic_inc(&xprt->xpt_nr_rqsts);
+		set_bit(RQ_DATA, &rqstp->rq_flags);
+	}
+	return true;
+}
+
+static void svc_xprt_release_slot(struct svc_rqst *rqstp)
+{
+	struct svc_xprt	*xprt = rqstp->rq_xprt;
+	if (test_and_clear_bit(RQ_DATA, &rqstp->rq_flags)) {
+		atomic_dec(&xprt->xpt_nr_rqsts);
+		svc_xprt_enqueue(xprt);
+	}
+}
+
 static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
 	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
-		if (xprt->xpt_ops->xpo_has_wspace(xprt))
+		if (xprt->xpt_ops->xpo_has_wspace(xprt) &&
+		    svc_xprt_slots_in_range(xprt))
 			return true;
 		trace_svc_xprt_no_write_space(xprt);
 		return false;
@@ -514,8 +547,8 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
 
 	rqstp->rq_res.head[0].iov_len = 0;
 	svc_reserve(rqstp, 0);
+	svc_xprt_release_slot(rqstp);
 	rqstp->rq_xprt = NULL;
-
 	svc_xprt_put(xprt);
 }
 
@@ -783,7 +816,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 			svc_add_new_temp_xprt(serv, newxpt);
 		else
 			module_put(xprt->xpt_class->xcl_owner);
-	} else {
+	} else if (svc_xprt_reserve_slot(rqstp, xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, rqstp->rq_pool->sp_id, xprt,
-- 
2.7.4

