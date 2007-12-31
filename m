From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 16/40] svc: Change sk_inuse to a kref
Date: Sun, 30 Dec 2007 21:07:46 -0600
Message-ID: <20071231030746.8430.61861.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41520 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbXLaDHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:47 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Change the atomic_t reference count to a kref and move it to the 
transport indepenent svc_xprt structure. Change the reference count
wrapper names to be generic.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    8 ++
 include/linux/sunrpc/svcsock.h  |    1 
 net/sunrpc/svc_xprt.c           |   16 +++++
 net/sunrpc/svcsock.c            |  138 ++++++++++++++++++---------------------
 4 files changed, 87 insertions(+), 76 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 986a5a0..6374805 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@
 #define SUNRPC_SVC_XPRT_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/module.h>
 
 struct svc_xprt_ops {
 	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
@@ -34,11 +35,18 @@ struct svc_xprt_class {
 struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	struct svc_xprt_ops	*xpt_ops;
+	struct kref		xpt_ref;
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
+void	svc_xprt_put(struct svc_xprt *xprt);
+
+static inline void svc_xprt_get(struct svc_xprt *xprt)
+{
+	kref_get(&xprt->xpt_ref);
+}
 
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 3181d9d..ba07d50 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -24,7 +24,6 @@ struct svc_sock {
 
 	struct svc_pool *	sk_pool;	/* current pool iff queued */
 	struct svc_serv *	sk_server;	/* service for this socket */
-	atomic_t		sk_inuse;	/* use count */
 	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 6ff5ca7..31853bf 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -70,6 +70,21 @@ void svc_unreg_xprt_class(struct svc_xprt_class *xcl)
 }
 EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
 
+static void svc_xprt_free(struct kref *kref)
+{
+	struct svc_xprt *xprt =
+		container_of(kref, struct svc_xprt, xpt_ref);
+	struct module *owner = xprt->xpt_class->xcl_owner;
+	xprt->xpt_ops->xpo_free(xprt);
+	module_put(owner);
+}
+
+void svc_xprt_put(struct svc_xprt *xprt)
+{
+	kref_put(&xprt->xpt_ref, svc_xprt_free);
+}
+EXPORT_SYMBOL_GPL(svc_xprt_put);
+
 /*
  * Called by transport drivers to initialize the transport independent
  * portion of the transport instance.
@@ -79,6 +94,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
 	memset(xprt, 0, sizeof(*xprt));
 	xprt->xpt_class = xcl;
 	xprt->xpt_ops = xcl->xcl_ops;
+	kref_init(&xprt->xpt_ref);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e6bb1b0..db589d1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -66,8 +66,8 @@
  *		after a clear, the socket must be read/accepted
  *		 if this succeeds, it must be set again.
  *	SK_CLOSE can set at any time. It is never cleared.
- *      sk_inuse contains a bias of '1' until SK_DEAD is set.
- *             so when sk_inuse hits zero, we know the socket is dead
+ *      xpt_ref contains a bias of '1' until SK_DEAD is set.
+ *             so when xprt_ref hits zero, we know the transport is dead
  *             and no-one is using it.
  *      SK_DEAD can only be set while SK_BUSY is held which ensures
  *             no other thread will be using the socket or will try to
@@ -285,7 +285,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		BUG_ON(svsk->sk_pool != pool);
@@ -316,7 +316,7 @@ svc_sock_dequeue(struct svc_pool *pool)
 	list_del_init(&svsk->sk_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
-		svsk->sk_sk, atomic_read(&svsk->sk_inuse));
+		svsk->sk_sk, atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
 
 	return svsk;
 }
@@ -359,19 +359,6 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 	}
 }
 
-/*
- * Release a socket after use.
- */
-static inline void
-svc_sock_put(struct svc_sock *svsk)
-{
-	if (atomic_dec_and_test(&svsk->sk_inuse)) {
-		BUG_ON(!test_bit(SK_DEAD, &svsk->sk_flags));
-		module_put(svsk->sk_xprt.xpt_class->xcl_owner);
-		svsk->sk_xprt.xpt_ops->xpo_free(&svsk->sk_xprt);
-	}
-}
-
 static void
 svc_sock_release(struct svc_rqst *rqstp)
 {
@@ -398,7 +385,7 @@ svc_sock_release(struct svc_rqst *rqstp)
 	svc_reserve(rqstp, 0);
 	rqstp->rq_sock = NULL;
 
-	svc_sock_put(svsk);
+	svc_xprt_put(&svsk->sk_xprt);
 }
 
 /*
@@ -1128,50 +1115,6 @@ failed:
 }
 
 /*
- * Make sure that we don't have too many active connections.  If we
- * have, something must be dropped.
- *
- * There's no point in trying to do random drop here for DoS
- * prevention. The NFS clients does 1 reconnect in 15 seconds. An
- * attacker can easily beat that.
- *
- * The only somewhat efficient mechanism would be if drop old
- * connections from the same IP first. But right now we don't even
- * record the client IP in svc_sock.
- */
-static void svc_check_conn_limits(struct svc_serv *serv)
-{
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
-		struct svc_sock *svsk = NULL;
-		spin_lock_bh(&serv->sv_lock);
-		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_ratelimit()) {
-				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open TCP "
-				       "sockets, consider increasing the "
-				       "number of nfsd threads\n",
-				       serv->sv_name);
-			}
-			/*
-			 * Always select the oldest socket. It's not fair,
-			 * but so is life
-			 */
-			svsk = list_entry(serv->sv_tempsocks.prev,
-					  struct svc_sock,
-					  sk_list);
-			set_bit(SK_CLOSE, &svsk->sk_flags);
-			atomic_inc(&svsk->sk_inuse);
-		}
-		spin_unlock_bh(&serv->sv_lock);
-
-		if (svsk) {
-			svc_sock_enqueue(svsk);
-			svc_sock_put(svsk);
-		}
-	}
-}
-
-/*
  * Receive data from a TCP socket.
  */
 static int
@@ -1497,6 +1440,50 @@ svc_sock_update_bufs(struct svc_serv *serv)
 }
 
 /*
+ * Make sure that we don't have too many active connections.  If we
+ * have, something must be dropped.
+ *
+ * There's no point in trying to do random drop here for DoS
+ * prevention. The NFS clients does 1 reconnect in 15 seconds. An
+ * attacker can easily beat that.
+ *
+ * The only somewhat efficient mechanism would be if drop old
+ * connections from the same IP first. But right now we don't even
+ * record the client IP in svc_sock.
+ */
+static void svc_check_conn_limits(struct svc_serv *serv)
+{
+	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
+		struct svc_sock *svsk = NULL;
+		spin_lock_bh(&serv->sv_lock);
+		if (!list_empty(&serv->sv_tempsocks)) {
+			if (net_ratelimit()) {
+				/* Try to help the admin */
+				printk(KERN_NOTICE "%s: too many open TCP "
+				       "sockets, consider increasing the "
+				       "number of nfsd threads\n",
+				       serv->sv_name);
+			}
+			/*
+			 * Always select the oldest socket. It's not fair,
+			 * but so is life
+			 */
+			svsk = list_entry(serv->sv_tempsocks.prev,
+					  struct svc_sock,
+					  sk_list);
+			set_bit(SK_CLOSE, &svsk->sk_flags);
+			svc_xprt_get(&svsk->sk_xprt);
+		}
+		spin_unlock_bh(&serv->sv_lock);
+
+		if (svsk) {
+			svc_sock_enqueue(svsk);
+			svc_xprt_put(&svsk->sk_xprt);
+		}
+	}
+}
+
+/*
  * Receive the next request on any socket.  This code is carefully
  * organised not to touch any cachelines in the shared svc_serv
  * structure, only cachelines in the local svc_pool.
@@ -1556,7 +1543,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_lock_bh(&pool->sp_lock);
 	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
@@ -1605,7 +1592,8 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+			rqstp, pool->sp_id, svsk,
+			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
 		len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
@@ -1702,9 +1690,10 @@ svc_age_temp_sockets(unsigned long closure)
 
 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
 			continue;
-		if (atomic_read(&svsk->sk_inuse) > 1 || test_bit(SK_BUSY, &svsk->sk_flags))
+		if (atomic_read(&svsk->sk_xprt.xpt_ref.refcount) > 1
+		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
-		atomic_inc(&svsk->sk_inuse);
+		svc_xprt_get(&svsk->sk_xprt);
 		list_move(le, &to_be_aged);
 		set_bit(SK_CLOSE, &svsk->sk_flags);
 		set_bit(SK_DETACHED, &svsk->sk_flags);
@@ -1722,7 +1711,7 @@ svc_age_temp_sockets(unsigned long closure)
 
 		/* a thread will dequeue and close it soon */
 		svc_sock_enqueue(svsk);
-		svc_sock_put(svsk);
+		svc_xprt_put(&svsk->sk_xprt);
 	}
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
@@ -1767,7 +1756,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_server = serv;
-	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
@@ -1953,10 +1941,10 @@ svc_delete_socket(struct svc_sock *svsk)
 	 * is about to be destroyed (in svc_destroy).
 	 */
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
-		BUG_ON(atomic_read(&svsk->sk_inuse)<2);
-		atomic_dec(&svsk->sk_inuse);
+		BUG_ON(atomic_read(&svsk->sk_xprt.xpt_ref.refcount) < 2);
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
+		svc_xprt_put(&svsk->sk_xprt);
 	}
 
 	spin_unlock_bh(&serv->sv_lock);
@@ -1969,10 +1957,10 @@ static void svc_close_socket(struct svc_sock *svsk)
 		/* someone else will have to effect the close */
 		return;
 
-	atomic_inc(&svsk->sk_inuse);
+	svc_xprt_get(&svsk->sk_xprt);
 	svc_delete_socket(svsk);
 	clear_bit(SK_BUSY, &svsk->sk_flags);
-	svc_sock_put(svsk);
+	svc_xprt_put(&svsk->sk_xprt);
 }
 
 void svc_force_close_socket(struct svc_sock *svsk)
@@ -1998,7 +1986,7 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	struct svc_sock *svsk;
 
 	if (too_many) {
-		svc_sock_put(dr->svsk);
+		svc_xprt_put(&dr->svsk->sk_xprt);
 		kfree(dr);
 		return;
 	}
@@ -2010,7 +1998,7 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	spin_unlock(&svsk->sk_lock);
 	set_bit(SK_DEFERRED, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
-	svc_sock_put(svsk);
+	svc_xprt_put(&svsk->sk_xprt);
 }
 
 static struct cache_deferred_req *
@@ -2040,7 +2028,7 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	atomic_inc(&rqstp->rq_sock->sk_inuse);
+	svc_xprt_get(rqstp->rq_xprt);
 	dr->svsk = rqstp->rq_sock;
 
 	dr->handle.revisit = svc_revisit;
