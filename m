Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32853 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935016AbeCMPoI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:44:08 -0400
Received: by mail-io0-f193.google.com with SMTP id f1so651677iob.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:44:07 -0700 (PDT)
Subject: [PATCH 05/15] sunrpc: Simplify do_enqueue tracing
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:44:06 -0400
Message-ID: <20180313154406.21531.55391.stgit@klimt.1015granger.net>
In-Reply-To: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are three cases where svc_xprt_do_enqueue() returns without
waking an nfsd thread:

1. There is no work to do

2. The transport is already busy

3. There are no available nfsd threads

Only 3. is truly interesting. Move the trace point so it records
that there was work to do and either an nfsd thread was awoken, or
a free one could not found.

As an additional clean up, remove a redundant comment and a couple
of dprintk call sites.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc_xprt.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 71f4718..5fe150c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -382,25 +382,21 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 	int cpu;
 
 	if (!svc_xprt_has_something_to_do(xprt))
-		goto out;
+		return;
 
 	/* Mark transport as busy. It will remain in this state until
 	 * the provider calls svc_xprt_received. We update XPT_BUSY
 	 * atomically because it also guards against trying to enqueue
 	 * the transport twice.
 	 */
-	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
-		/* Don't enqueue transport while already enqueued */
-		dprintk("svc: transport %p busy, not enqueued\n", xprt);
-		goto out;
-	}
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
+		return;
 
 	cpu = get_cpu();
 	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
 
 	atomic_long_inc(&pool->sp_stats.packets);
 
-	dprintk("svc: transport %p put into queue\n", xprt);
 	spin_lock_bh(&pool->sp_lock);
 	list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
 	pool->sp_stats.sockets_queued++;
@@ -420,7 +416,6 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 out_unlock:
 	rcu_read_unlock();
 	put_cpu();
-out:
 	trace_svc_xprt_do_enqueue(xprt, rqstp);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_do_enqueue);

