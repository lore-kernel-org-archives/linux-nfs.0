Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46810 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758511Ab2HUU5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/14] svcrpc: break up svc_recv
Date: Tue, 21 Aug 2012 16:57:30 -0400
Message-Id: <1345582652-18476-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Matter of taste, I suppose, but svc_recv breaks up naturally into:

	allocate pages and setup arg
	dequeue (wait for, if necessary) next socket
	do something with that socket

And I find it easier to read when it doesn't go on for pages and pages.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |  103 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 67 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 295e6ed..6ebc9a9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -568,33 +568,12 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 	}
 }
 
-/*
- * Receive the next request on any transport.  This code is carefully
- * organised not to touch any cachelines in the shared svc_serv
- * structure, only cachelines in the local svc_pool.
- */
-int svc_recv(struct svc_rqst *rqstp, long timeout)
+int svc_alloc_arg(struct svc_rqst *rqstp)
 {
-	struct svc_xprt		*xprt = NULL;
-	struct svc_serv		*serv = rqstp->rq_server;
-	struct svc_pool		*pool = rqstp->rq_pool;
-	int			len, i;
-	int			pages;
-	struct xdr_buf		*arg;
-	DECLARE_WAITQUEUE(wait, current);
-	long			time_left;
-
-	dprintk("svc: server %p waiting for data (to = %ld)\n",
-		rqstp, timeout);
-
-	if (rqstp->rq_xprt)
-		printk(KERN_ERR
-			"svc_recv: service %p, transport not NULL!\n",
-			 rqstp);
-	if (waitqueue_active(&rqstp->rq_wait))
-		printk(KERN_ERR
-			"svc_recv: service %p, wait queue active!\n",
-			 rqstp);
+	struct svc_serv *serv = rqstp->rq_server;
+	struct xdr_buf *arg;
+	int pages;
+	int i;
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
 	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
@@ -624,11 +603,15 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	arg->page_len = (pages-2)*PAGE_SIZE;
 	arg->len = (pages-1)*PAGE_SIZE;
 	arg->tail[0].iov_len = 0;
+	return 0;
+}
 
-	try_to_freeze();
-	cond_resched();
-	if (signalled() || kthread_should_stop())
-		return -EINTR;
+struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
+{
+	struct svc_xprt *xprt;
+	struct svc_pool		*pool = rqstp->rq_pool;
+	DECLARE_WAITQUEUE(wait, current);
+	long			time_left;
 
 	/* Normally we will wait up to 5 seconds for any required
 	 * cache information to be provided.
@@ -666,7 +649,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		if (kthread_should_stop()) {
 			set_current_state(TASK_RUNNING);
 			spin_unlock_bh(&pool->sp_lock);
-			return -EINTR;
+			return ERR_PTR(-EINTR);
 		}
 
 		add_wait_queue(&rqstp->rq_wait, &wait);
@@ -687,19 +670,25 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			spin_unlock_bh(&pool->sp_lock);
 			dprintk("svc: server %p, no data yet\n", rqstp);
 			if (signalled() || kthread_should_stop())
-				return -EINTR;
+				return ERR_PTR(-EINTR);
 			else
-				return -EAGAIN;
+				return ERR_PTR(-EAGAIN);
 		}
 	}
 	spin_unlock_bh(&pool->sp_lock);
+	return xprt;
+}
+
+static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+{
+	struct svc_serv *serv = rqstp->rq_server;
+	int len = 0;
 
-	len = 0;
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_xprt(xprt);
 		/* Leave XPT_BUSY set on the dead xprt: */
-		goto out;
+		return 0;
 	}
 	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
@@ -727,8 +716,9 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
+		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
-			rqstp, pool->sp_id, xprt,
+			rqstp, rqstp->rq_pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred)
@@ -739,7 +729,48 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	}
+	/* clear XPT_BUSY: */
 	svc_xprt_received(xprt);
+	return len;
+}
+
+/*
+ * Receive the next request on any transport.  This code is carefully
+ * organised not to touch any cachelines in the shared svc_serv
+ * structure, only cachelines in the local svc_pool.
+ */
+int svc_recv(struct svc_rqst *rqstp, long timeout)
+{
+	struct svc_xprt		*xprt = NULL;
+	struct svc_serv		*serv = rqstp->rq_server;
+	int			len, err;
+
+	dprintk("svc: server %p waiting for data (to = %ld)\n",
+		rqstp, timeout);
+
+	if (rqstp->rq_xprt)
+		printk(KERN_ERR
+			"svc_recv: service %p, transport not NULL!\n",
+			 rqstp);
+	if (waitqueue_active(&rqstp->rq_wait))
+		printk(KERN_ERR
+			"svc_recv: service %p, wait queue active!\n",
+			 rqstp);
+
+	err = svc_alloc_arg(rqstp);
+	if (err)
+		return err;
+
+	try_to_freeze();
+	cond_resched();
+	if (signalled() || kthread_should_stop())
+		return -EINTR;
+
+	xprt = svc_get_next_xprt(rqstp, timeout);
+	if (IS_ERR(xprt))
+		return PTR_ERR(xprt);
+
+	len = svc_handle_xprt(rqstp, xprt);
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len <= 0)
-- 
1.7.9.5

