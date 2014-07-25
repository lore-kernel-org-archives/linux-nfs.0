Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:46301 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaGYD7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jul 2014 23:59:23 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so3167284iec.16
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jul 2014 20:59:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: Reduce contention in svc_xprt_enqueue()
Date: Thu, 24 Jul 2014 23:59:31 -0400
Message-Id: <1406260773-16231-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that all calls to svc_xprt_enqueue() except svc_xprt_received()
check the value of XPT_BUSY, before attempting to grab spinlocks etc.
This is to avoid situations such as the following "perf" trace,
which shows heavy contention on the pool spinlock:

    54.15%            nfsd  [kernel.kallsyms]        [k] _raw_spin_lock_bh
                      |
                      --- _raw_spin_lock_bh
                         |
                         |--71.43%-- svc_xprt_enqueue
                         |          |
                         |          |--50.31%-- svc_reserve
                         |          |
                         |          |--31.35%-- svc_xprt_received
                         |          |
                         |          |--18.34%-- svc_tcp_data_ready
...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b4737fbdec13..54a761fa6351 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -23,6 +23,7 @@ static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static void svc_age_temp_xprts(unsigned long closure);
 static void svc_delete_xprt(struct svc_xprt *xprt);
+static void svc_xprt_do_enqueue(struct svc_xprt *xprt);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -222,11 +223,12 @@ static void svc_xprt_received(struct svc_xprt *xprt)
 	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
 		return;
 	/* As soon as we clear busy, the xprt could be closed and
-	 * 'put', so we need a reference to call svc_xprt_enqueue with:
+	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
 	 */
 	svc_xprt_get(xprt);
+	smp_mb__before_clear_bit();
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
-	svc_xprt_enqueue(xprt);
+	svc_xprt_do_enqueue(xprt);
 	svc_xprt_put(xprt);
 }
 
@@ -335,12 +337,7 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 	return false;
 }
 
-/*
- * Queue up a transport with data pending. If there are idle nfsd
- * processes, wake 'em up.
- *
- */
-void svc_xprt_enqueue(struct svc_xprt *xprt)
+static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 {
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
@@ -398,6 +395,18 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 out_unlock:
 	spin_unlock_bh(&pool->sp_lock);
 }
+
+/*
+ * Queue up a transport with data pending. If there are idle nfsd
+ * processes, wake 'em up.
+ *
+ */
+void svc_xprt_enqueue(struct svc_xprt *xprt)
+{
+	if (test_bit(XPT_BUSY, &xprt->xpt_flags))
+		return;
+	svc_xprt_do_enqueue(xprt);
+}
 EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 
 /*
-- 
1.9.3

