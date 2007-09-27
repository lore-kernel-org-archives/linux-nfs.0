From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 14/33] svc: Change sk_inuse to a kref
Date: Thu, 27 Sep 2007 00:02:04 -0500
Message-ID: <20070927050203.12677.741.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVl-0005gQ-CC
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:05 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVp-0001oj-B6
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:10 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Change the atomic_t reference count to a kref and move it to the 
transport indepenent svc_xprt structure. Change the reference count
wrapper names to be generic.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    7 +++++
 include/linux/sunrpc/svcsock.h  |    1 -
 net/sunrpc/svc_xprt.c           |   17 ++++++++++++
 net/sunrpc/svcsock.c            |   54 +++++++++++++++------------------------
 4 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 6a34bb4..c9196bc 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@ #ifndef SUNRPC_SVC_XPRT_H
 #define SUNRPC_SVC_XPRT_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/module.h>
 
 struct svc_xprt_ops {
 	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
@@ -35,11 +36,17 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	struct svc_xprt_ops	xpt_ops;
 	u32			xpt_max_payload;
+	struct kref		xpt_ref;
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 int	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
+void	svc_xprt_put(struct svc_xprt *xprt);
+
+static inline void svc_xprt_get(struct svc_xprt *xprt) {
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
index fab0ce3..9a9670f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -82,6 +82,22 @@ int svc_unreg_xprt_class(struct svc_xprt
 }
 EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
 
+static inline void svc_xprt_free(struct kref *kref)
+{
+	struct svc_xprt *xprt =
+		container_of(kref, struct svc_xprt, xpt_ref);
+	struct module *owner = xprt->xpt_class->xcl_owner;
+	BUG_ON(atomic_read(&kref->refcount));
+	xprt->xpt_ops.xpo_free(xprt);
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
@@ -91,6 +107,7 @@ void svc_xprt_init(struct svc_xprt_class
 	xpt->xpt_class = xcl;
 	xpt->xpt_ops = *xcl->xcl_ops;
 	xpt->xpt_max_payload = xcl->xcl_max_payload;
+	kref_init(&xpt->xpt_ref);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f6a6e57..a92b000 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -65,8 +65,8 @@ #include <linux/sunrpc/stats.h>
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
@@ -301,7 +301,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		BUG_ON(svsk->sk_pool != pool);
@@ -332,7 +332,7 @@ svc_sock_dequeue(struct svc_pool *pool)
 	list_del_init(&svsk->sk_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
-		svsk->sk_sk, atomic_read(&svsk->sk_inuse));
+		svsk->sk_sk, atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
 
 	return svsk;
 }
@@ -375,19 +375,6 @@ void svc_reserve(struct svc_rqst *rqstp,
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
-		svsk->sk_xprt.xpt_ops.xpo_free(&svsk->sk_xprt);
-	}
-}
-
 static void
 svc_sock_release(struct svc_rqst *rqstp)
 {
@@ -414,7 +401,7 @@ svc_sock_release(struct svc_rqst *rqstp)
 	svc_reserve(rqstp, 0);
 	rqstp->rq_sock = NULL;
 
-	svc_sock_put(svsk);
+	svc_xprt_put(&svsk->sk_xprt);
 }
 
 /*
@@ -1506,13 +1493,13 @@ svc_check_conn_limits(struct svc_serv *s
 					  struct svc_sock,
 					  sk_list);
 			set_bit(SK_CLOSE, &svsk->sk_flags);
-			atomic_inc(&svsk->sk_inuse);
+			svc_xprt_get(&svsk->sk_xprt);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
 		if (svsk) {
 			svc_sock_enqueue(svsk);
-			svc_sock_put(svsk);
+			svc_xprt_put(&svsk->sk_xprt);
 		}
 	}
 }
@@ -1577,7 +1564,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_lock_bh(&pool->sp_lock);
 	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
@@ -1626,7 +1613,8 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+			rqstp, pool->sp_id, svsk, 
+			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
 		len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
@@ -1723,9 +1711,10 @@ svc_age_temp_sockets(unsigned long closu
 
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
@@ -1743,7 +1732,7 @@ svc_age_temp_sockets(unsigned long closu
 
 		/* a thread will dequeue and close it soon */
 		svc_sock_enqueue(svsk);
-		svc_sock_put(svsk);
+		svc_xprt_put(&svsk->sk_xprt);
 	}
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
@@ -1788,7 +1777,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_server = serv;
-	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
@@ -1977,8 +1965,8 @@ svc_delete_socket(struct svc_sock *svsk)
 	 * is about to be destroyed (in svc_destroy).
 	 */
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
-		BUG_ON(atomic_read(&svsk->sk_inuse)<2);
-		atomic_dec(&svsk->sk_inuse);
+		BUG_ON(atomic_read(&svsk->sk_xprt.xpt_ref.refcount)<2);
+		svc_xprt_put(&svsk->sk_xprt);
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
 	}
@@ -1993,10 +1981,10 @@ static void svc_close_socket(struct svc_
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
@@ -2022,7 +2010,7 @@ static void svc_revisit(struct cache_def
 	struct svc_sock *svsk;
 
 	if (too_many) {
-		svc_sock_put(dr->svsk);
+		svc_xprt_put(&dr->svsk->sk_xprt);
 		kfree(dr);
 		return;
 	}
@@ -2034,7 +2022,7 @@ static void svc_revisit(struct cache_def
 	spin_unlock(&svsk->sk_lock);
 	set_bit(SK_DEFERRED, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
-	svc_sock_put(svsk);
+	svc_xprt_put(&svsk->sk_xprt);
 }
 
 static struct cache_deferred_req *
@@ -2064,7 +2052,7 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	atomic_inc(&rqstp->rq_sock->sk_inuse);
+	svc_xprt_get(rqstp->rq_xprt);
 	dr->svsk = rqstp->rq_sock;
 
 	dr->handle.revisit = svc_revisit;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
