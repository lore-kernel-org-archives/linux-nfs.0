From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 33/38] svc: Move the xprt independent code to the svc_xprt.c file
Date: Tue, 11 Dec 2007 17:33:07 -0600
Message-ID: <20071211233307.15718.90962.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35468 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757305AbXLKXdJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:33:09 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This functionally trivial patch moves all of the transport independent
functions from the svcsock.c file to the transport independent svc_xprt.c
file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |   27 +
 net/sunrpc/svc_xprt.c           |  726 +++++++++++++++++++++++++++++++++++
 net/sunrpc/svcsock.c            |  809 +--------------------------------------
 3 files changed, 776 insertions(+), 786 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index a1d324a..db8bcf5 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -72,9 +72,13 @@ int	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
+void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
+void	svc_close_xprt(struct svc_xprt *xprt);
+void	svc_delete_xprt(struct svc_xprt *xprt);
+int	svc_port_is_privileged(struct sockaddr *sin);
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
 	kref_get(&xprt->xpt_ref);
@@ -126,4 +130,27 @@ static inline unsigned short svc_xprt_remote_port(struct svc_xprt *xprt)
 	return svc_addr_port((struct sockaddr *)&xprt->xpt_remote);
 }
 
+static inline char *__svc_print_addr(struct sockaddr *addr,
+				     char *buf, size_t len)
+{
+	switch (addr->sa_family) {
+	case AF_INET:
+		snprintf(buf, len, "%u.%u.%u.%u, port=%u",
+			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
+			ntohs(((struct sockaddr_in *) addr)->sin_port));
+		break;
+
+	case AF_INET6:
+		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
+			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
+			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
+		break;
+
+	default:
+		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
+		break;
+	}
+	return buf;
+}
+
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 924df63..a477883 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -35,6 +35,18 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
+static int svc_deferred_recv(struct svc_rqst *rqstp);
+static struct cache_deferred_req *svc_defer(struct cache_req *req);
+static void svc_age_temp_xprts(unsigned long closure);
+
+/* apparently the "standard" is that clients close
+ * idle connections after 5 minutes, servers after
+ * 6 minutes
+ *   http://www.connectathon.org/talks96/nfstcp.pdf
+ */
+static int svc_conn_age_period = 6*60;
+
 /* List of registered transport classes */
 static DEFINE_SPINLOCK(svc_xprt_class_lock);
 static LIST_HEAD(svc_xprt_class_list);
@@ -191,3 +203,717 @@ void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_copy_addrs);
 
+/**
+ * svc_print_addr - Format rq_addr field for printing
+ * @rqstp: svc_rqst struct containing address to print
+ * @buf: target buffer for formatted address
+ * @len: length of target buffer
+ *
+ */
+char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
+{
+	return __svc_print_addr(svc_addr(rqstp), buf, len);
+}
+EXPORT_SYMBOL_GPL(svc_print_addr);
+
+/*
+ * Queue up an idle server thread.  Must have pool->sp_lock held.
+ * Note: this is really a stack rather than a queue, so that we only
+ * use as many different threads as we need, and the rest don't pollute
+ * the cache.
+ */
+static void svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
+{
+	list_add(&rqstp->rq_list, &pool->sp_threads);
+}
+
+/*
+ * Dequeue an nfsd thread.  Must have pool->sp_lock held.
+ */
+static void svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
+{
+	list_del(&rqstp->rq_list);
+}
+
+/*
+ * Queue up a socket with data pending. If there are idle nfsd
+ * processes, wake 'em up.
+ *
+ */
+void svc_xprt_enqueue(struct svc_xprt *xprt)
+{
+	struct svc_serv	*serv = xprt->xpt_server;
+	struct svc_pool *pool;
+	struct svc_rqst	*rqstp;
+	int cpu;
+
+	if (!(xprt->xpt_flags &
+	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
+		return;
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
+		return;
+
+	cpu = get_cpu();
+	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
+	put_cpu();
+
+	spin_lock_bh(&pool->sp_lock);
+
+	if (!list_empty(&pool->sp_threads) &&
+	    !list_empty(&pool->sp_sockets))
+		printk(KERN_ERR
+		       "svc_xprt_enqueue: "
+		       "threads and transports both waiting??\n");
+
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
+		/* Don't enqueue dead sockets */
+		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
+		goto out_unlock;
+	}
+
+	/* Mark socket as busy. It will remain in this state until the
+	 * server has processed all pending data and put the socket back
+	 * on the idle list.  We update XPT_BUSY atomically because
+	 * it also guards against trying to enqueue the svc_sock twice.
+	 */
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
+		/* Don't enqueue socket while already enqueued */
+		dprintk("svc: transport %p busy, not enqueued\n", xprt);
+		goto out_unlock;
+	}
+	BUG_ON(xprt->xpt_pool != NULL);
+	xprt->xpt_pool = pool;
+
+	/* Handle pending connection */
+	if (test_bit(XPT_CONN, &xprt->xpt_flags))
+		goto process;
+
+	/* Handle close in-progress */
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
+		goto process;
+
+	/* Check if we have space to reply to a request */
+	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
+		/* Don't enqueue while not enough space for reply */
+		dprintk("svc: no write space, transport %p  not enqueued\n",
+			xprt);
+		xprt->xpt_pool = NULL;
+		clear_bit(XPT_BUSY, &xprt->xpt_flags);
+		goto out_unlock;
+	}
+
+ process:
+	if (!list_empty(&pool->sp_threads)) {
+		rqstp = list_entry(pool->sp_threads.next,
+				   struct svc_rqst,
+				   rq_list);
+		dprintk("svc: transport %p served by daemon %p\n",
+			xprt, rqstp);
+		svc_thread_dequeue(pool, rqstp);
+		if (rqstp->rq_xprt)
+			printk(KERN_ERR
+				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
+				rqstp, rqstp->rq_xprt);
+		rqstp->rq_xprt = xprt;
+		svc_xprt_get(xprt);
+		rqstp->rq_reserved = serv->sv_max_mesg;
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+		BUG_ON(xprt->xpt_pool != pool);
+		wake_up(&rqstp->rq_wait);
+	} else {
+		dprintk("svc: transport %p put into queue\n", xprt);
+		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
+		BUG_ON(xprt->xpt_pool != pool);
+	}
+
+out_unlock:
+	spin_unlock_bh(&pool->sp_lock);
+}
+EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
+
+/*
+ * Dequeue the first socket.  Must be called with the pool->sp_lock held.
+ */
+static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
+{
+	struct svc_xprt	*xprt;
+
+	if (list_empty(&pool->sp_sockets))
+		return NULL;
+
+	xprt = list_entry(pool->sp_sockets.next,
+			  struct svc_xprt, xpt_ready);
+	list_del_init(&xprt->xpt_ready);
+
+	dprintk("svc: transport %p dequeued, inuse=%d\n",
+		xprt, atomic_read(&xprt->xpt_ref.refcount));
+
+	return xprt;
+}
+
+/*
+ * Having read something from a socket, check whether it
+ * needs to be re-enqueued.
+ * Note: XPT_DATA only gets cleared when a read-attempt finds
+ * no (or insufficient) data.
+ */
+void svc_xprt_received(struct svc_xprt *xprt)
+{
+	xprt->xpt_pool = NULL;
+	clear_bit(XPT_BUSY, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
+}
+EXPORT_SYMBOL_GPL(svc_xprt_received);
+
+/**
+ * svc_reserve - change the space reserved for the reply to a request.
+ * @rqstp:  The request in question
+ * @space: new max space to reserve
+ *
+ * Each request reserves some space on the output queue of the socket
+ * to make sure the reply fits.  This function reduces that reserved
+ * space to be the amount of space used already, plus @space.
+ *
+ */
+void svc_reserve(struct svc_rqst *rqstp, int space)
+{
+	space += rqstp->rq_res.head[0].iov_len;
+
+	if (space < rqstp->rq_reserved) {
+		struct svc_xprt *xprt = rqstp->rq_xprt;
+		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
+		rqstp->rq_reserved = space;
+
+		svc_xprt_enqueue(xprt);
+	}
+}
+
+static void svc_xprt_release(struct svc_rqst *rqstp)
+{
+	struct svc_xprt	*xprt = rqstp->rq_xprt;
+
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
+
+	svc_free_res_pages(rqstp);
+	rqstp->rq_res.page_len = 0;
+	rqstp->rq_res.page_base = 0;
+
+	/* Reset response buffer and release
+	 * the reservation.
+	 * But first, check that enough space was reserved
+	 * for the reply, otherwise we have a bug!
+	 */
+	if ((rqstp->rq_res.len) >  rqstp->rq_reserved)
+		printk(KERN_ERR "RPC request reserved %d but used %d\n",
+		       rqstp->rq_reserved,
+		       rqstp->rq_res.len);
+
+	rqstp->rq_res.head[0].iov_len = 0;
+	svc_reserve(rqstp, 0);
+	rqstp->rq_xprt = NULL;
+
+	svc_xprt_put(xprt);
+}
+
+/*
+ * External function to wake up a server waiting for data
+ * This really only makes sense for services like lockd
+ * which have exactly one thread anyway.
+ */
+void svc_wake_up(struct svc_serv *serv)
+{
+	struct svc_rqst	*rqstp;
+	unsigned int i;
+	struct svc_pool *pool;
+
+	for (i = 0; i < serv->sv_nrpools; i++) {
+		pool = &serv->sv_pools[i];
+
+		spin_lock_bh(&pool->sp_lock);
+		if (!list_empty(&pool->sp_threads)) {
+			rqstp = list_entry(pool->sp_threads.next,
+					   struct svc_rqst,
+					   rq_list);
+			dprintk("svc: daemon %p woken up.\n", rqstp);
+			/*
+			svc_thread_dequeue(pool, rqstp);
+			rqstp->rq_xprt = NULL;
+			 */
+			wake_up(&rqstp->rq_wait);
+		}
+		spin_unlock_bh(&pool->sp_lock);
+	}
+}
+
+int svc_port_is_privileged(struct sockaddr *sin)
+{
+	switch (sin->sa_family) {
+	case AF_INET:
+		return ntohs(((struct sockaddr_in *)sin)->sin_port)
+			< PROT_SOCK;
+	case AF_INET6:
+		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
+			< PROT_SOCK;
+	default:
+		return 0;
+	}
+}
+
+/*
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
+	char	buf[RPC_MAX_ADDRBUFLEN];
+
+	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
+		struct svc_xprt *xprt = NULL;
+		spin_lock_bh(&serv->sv_lock);
+		if (!list_empty(&serv->sv_tempsocks)) {
+			if (net_ratelimit()) {
+				/* Try to help the admin */
+				printk(KERN_NOTICE "%s: too many open  "
+					"connections, consider increasing the "
+					"number of nfsd threads\n",
+				       serv->sv_name);
+				printk(KERN_NOTICE
+				       "%s: last connection from %s\n",
+				       serv->sv_name, buf);
+			}
+			/*
+			 * Always select the oldest connection. It's not fair,
+			 * but so is life
+			 */
+			xprt = list_entry(serv->sv_tempsocks.prev,
+					  struct svc_xprt,
+					  xpt_list);
+			set_bit(XPT_CLOSE, &xprt->xpt_flags);
+			svc_xprt_get(xprt);
+		}
+		spin_unlock_bh(&serv->sv_lock);
+
+		if (xprt) {
+			svc_xprt_enqueue(xprt);
+			svc_xprt_put(xprt);
+		}
+	}
+}
+
+/*
+ * Receive the next request on any socket.  This code is carefully
+ * organised not to touch any cachelines in the shared svc_serv
+ * structure, only cachelines in the local svc_pool.
+ */
+int svc_recv(struct svc_rqst *rqstp, long timeout)
+{
+	struct svc_xprt		*xprt = NULL;
+	struct svc_serv		*serv = rqstp->rq_server;
+	struct svc_pool		*pool = rqstp->rq_pool;
+	int			len, i;
+	int			pages;
+	struct xdr_buf		*arg;
+	DECLARE_WAITQUEUE(wait, current);
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
+
+	/* now allocate needed pages.  If we get a failure, sleep briefly */
+	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
+	for (i = 0; i < pages ; i++)
+		while (rqstp->rq_pages[i] == NULL) {
+			struct page *p = alloc_page(GFP_KERNEL);
+			if (!p) {
+				int jiffies = msecs_to_jiffies(500);
+				schedule_timeout_uninterruptible(jiffies);
+			}
+			rqstp->rq_pages[i] = p;
+		}
+	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
+	BUG_ON(pages >= RPCSVC_MAXPAGES);
+
+	/* Make arg->head point to first page and arg->pages point to rest */
+	arg = &rqstp->rq_arg;
+	arg->head[0].iov_base = page_address(rqstp->rq_pages[0]);
+	arg->head[0].iov_len = PAGE_SIZE;
+	arg->pages = rqstp->rq_pages + 1;
+	arg->page_base = 0;
+	/* save at least one page for response */
+	arg->page_len = (pages-2)*PAGE_SIZE;
+	arg->len = (pages-1)*PAGE_SIZE;
+	arg->tail[0].iov_len = 0;
+
+	try_to_freeze();
+	cond_resched();
+	if (signalled())
+		return -EINTR;
+
+	spin_lock_bh(&pool->sp_lock);
+	xprt = svc_xprt_dequeue(pool);
+	if (xprt) {
+		rqstp->rq_xprt = xprt;
+		svc_xprt_get(xprt);
+		rqstp->rq_reserved = serv->sv_max_mesg;
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+	} else {
+		/* No data pending. Go to sleep */
+		svc_thread_enqueue(pool, rqstp);
+
+		/*
+		 * We have to be able to interrupt this wait
+		 * to bring down the daemons ...
+		 */
+		set_current_state(TASK_INTERRUPTIBLE);
+		add_wait_queue(&rqstp->rq_wait, &wait);
+		spin_unlock_bh(&pool->sp_lock);
+
+		schedule_timeout(timeout);
+
+		try_to_freeze();
+
+		spin_lock_bh(&pool->sp_lock);
+		remove_wait_queue(&rqstp->rq_wait, &wait);
+
+		xprt = rqstp->rq_xprt;
+		if (!xprt) {
+			svc_thread_dequeue(pool, rqstp);
+			spin_unlock_bh(&pool->sp_lock);
+			dprintk("svc: server %p, no data yet\n", rqstp);
+			return signalled()? -EINTR : -EAGAIN;
+		}
+	}
+	spin_unlock_bh(&pool->sp_lock);
+
+	len = 0;
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+		struct svc_xprt *newxpt;
+		newxpt = xprt->xpt_ops->xpo_accept(xprt);
+		if (newxpt) {
+			/*
+			 * We know this module_get will succeed because the
+			 * listener holds a reference too
+			 */
+			__module_get(newxpt->xpt_class->xcl_owner);
+			svc_check_conn_limits(xprt->xpt_server);
+			spin_lock_bh(&serv->sv_lock);
+			set_bit(XPT_TEMP, &newxpt->xpt_flags);
+			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
+			serv->sv_tmpcnt++;
+			if (serv->sv_temptimer.function == NULL) {
+				/* setup timer to age temp sockets */
+				setup_timer(&serv->sv_temptimer,
+					    svc_age_temp_xprts,
+					    (unsigned long)serv);
+				mod_timer(&serv->sv_temptimer,
+					  jiffies + svc_conn_age_period * HZ);
+			}
+			spin_unlock_bh(&serv->sv_lock);
+			svc_xprt_received(newxpt);
+		}
+		svc_xprt_received(xprt);
+	} else {
+		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
+			rqstp, pool->sp_id, xprt,
+			atomic_read(&xprt->xpt_ref.refcount));
+		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
+		if (rqstp->rq_deferred) {
+			svc_xprt_received(xprt);
+			len = svc_deferred_recv(rqstp);
+		} else
+			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
+
+	/* No data, incomplete (TCP) read, or accept() */
+	if (len == 0 || len == -EAGAIN) {
+		rqstp->rq_res.len = 0;
+		svc_xprt_release(rqstp);
+		return -EAGAIN;
+	}
+	clear_bit(XPT_OLD, &xprt->xpt_flags);
+
+	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
+	rqstp->rq_chandle.defer = svc_defer;
+
+	if (serv->sv_stats)
+		serv->sv_stats->netcnt++;
+	return len;
+}
+
+/*
+ * Drop request
+ */
+void svc_drop(struct svc_rqst *rqstp)
+{
+	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
+	svc_xprt_release(rqstp);
+}
+
+/*
+ * Return reply to client.
+ */
+int svc_send(struct svc_rqst *rqstp)
+{
+	struct svc_xprt	*xprt;
+	int		len;
+	struct xdr_buf	*xb;
+
+	xprt = rqstp->rq_xprt;
+	if (!xprt)
+		return -EFAULT;
+
+	/* release the receive skb before sending the reply */
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
+
+	/* calculate over-all length */
+	xb = &rqstp->rq_res;
+	xb->len = xb->head[0].iov_len +
+		xb->page_len +
+		xb->tail[0].iov_len;
+
+	/* Grab mutex to serialize outgoing data. */
+	mutex_lock(&xprt->xpt_mutex);
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
+		len = -ENOTCONN;
+	else
+		len = xprt->xpt_ops->xpo_sendto(rqstp);
+	mutex_unlock(&xprt->xpt_mutex);
+	svc_xprt_release(rqstp);
+
+	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
+		return 0;
+	return len;
+}
+
+/*
+ * Timer function to close old temporary sockets, using
+ * a mark-and-sweep algorithm.
+ */
+static void svc_age_temp_xprts(unsigned long closure)
+{
+	struct svc_serv *serv = (struct svc_serv *)closure;
+	struct svc_xprt *xprt;
+	struct list_head *le, *next;
+	LIST_HEAD(to_be_aged);
+
+	dprintk("svc_age_temp_xprts\n");
+
+	if (!spin_trylock_bh(&serv->sv_lock)) {
+		/* busy, try again 1 sec later */
+		dprintk("svc_age_temp_xprts: busy\n");
+		mod_timer(&serv->sv_temptimer, jiffies + HZ);
+		return;
+	}
+
+	list_for_each_safe(le, next, &serv->sv_tempsocks) {
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
+
+		/* First time through, just mark it OLD. Second time
+		 * through, close it. */
+		if (!test_and_set_bit(XPT_OLD, &xprt->xpt_flags))
+			continue;
+		if (atomic_read(&xprt->xpt_ref.refcount) > 1
+		    || test_bit(XPT_BUSY, &xprt->xpt_flags))
+			continue;
+		svc_xprt_get(xprt);
+		list_move(le, &to_be_aged);
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		set_bit(XPT_DETACHED, &xprt->xpt_flags);
+	}
+	spin_unlock_bh(&serv->sv_lock);
+
+	while (!list_empty(&to_be_aged)) {
+		le = to_be_aged.next;
+		/* fiddling the xpt_list node is safe 'cos we're XPT_DETACHED */
+		list_del_init(le);
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
+
+		dprintk("queuing xprt %p for closing\n", xprt);
+
+		/* a thread will dequeue and close it soon */
+		svc_xprt_enqueue(xprt);
+		svc_xprt_put(xprt);
+	}
+
+	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
+}
+
+/*
+ * Remove a dead transport
+ */
+void svc_delete_xprt(struct svc_xprt *xprt)
+{
+	struct svc_serv	*serv = xprt->xpt_server;
+
+	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
+	xprt->xpt_ops->xpo_detach(xprt);
+
+	spin_lock_bh(&serv->sv_lock);
+	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
+		list_del_init(&xprt->xpt_list);
+	/*
+	 * We used to delete the transport from whichever list
+	 * it's sk_xprt.xpt_ready node was on, but we don't actually
+	 * need to.  This is because the only time we're called
+	 * while still attached to a queue, the queue itself
+	 * is about to be destroyed (in svc_destroy).
+	 */
+	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
+		BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
+		svc_xprt_put(xprt);
+		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
+			serv->sv_tmpcnt--;
+	}
+	spin_unlock_bh(&serv->sv_lock);
+}
+
+void svc_close_xprt(struct svc_xprt *xprt)
+{
+	set_bit(XPT_CLOSE, &xprt->xpt_flags);
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
+		/* someone else will have to effect the close */
+		return;
+
+	svc_xprt_get(xprt);
+	svc_delete_xprt(xprt);
+	clear_bit(XPT_BUSY, &xprt->xpt_flags);
+	svc_xprt_put(xprt);
+}
+
+void svc_close_all(struct list_head *xprt_list)
+{
+	struct svc_xprt *xprt;
+	struct svc_xprt *tmp;
+
+	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		if (test_bit(XPT_BUSY, &xprt->xpt_flags)) {
+			/* Waiting to be processed, but no threads left,
+			 * So just remove it from the waiting list
+			 */
+			list_del_init(&xprt->xpt_ready);
+			clear_bit(XPT_BUSY, &xprt->xpt_flags);
+		}
+		svc_close_xprt(xprt);
+	}
+}
+
+/*
+ * Handle defer and revisit of requests
+ */
+
+static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
+{
+	struct svc_deferred_req *dr =
+		container_of(dreq, struct svc_deferred_req, handle);
+	struct svc_xprt *xprt = dr->xprt;
+
+	if (too_many) {
+		svc_xprt_put(xprt);
+		kfree(dr);
+		return;
+	}
+	dprintk("revisit queued\n");
+	dr->xprt = NULL;
+	spin_lock(&xprt->xpt_lock);
+	list_add(&dr->handle.recent, &xprt->xpt_deferred);
+	spin_unlock(&xprt->xpt_lock);
+	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
+	svc_xprt_put(xprt);
+}
+
+static struct cache_deferred_req *svc_defer(struct cache_req *req)
+{
+	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
+	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
+	struct svc_deferred_req *dr;
+
+	if (rqstp->rq_arg.page_len)
+		return NULL; /* if more than a page, give up FIXME */
+	if (rqstp->rq_deferred) {
+		dr = rqstp->rq_deferred;
+		rqstp->rq_deferred = NULL;
+	} else {
+		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+		/* FIXME maybe discard if size too large */
+		dr = kmalloc(size, GFP_KERNEL);
+		if (dr == NULL)
+			return NULL;
+
+		dr->handle.owner = rqstp->rq_server;
+		dr->prot = rqstp->rq_prot;
+		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
+		dr->addrlen = rqstp->rq_addrlen;
+		dr->daddr = rqstp->rq_daddr;
+		dr->argslen = rqstp->rq_arg.len >> 2;
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip,
+		       dr->argslen<<2);
+	}
+	svc_xprt_get(rqstp->rq_xprt);
+	dr->xprt = rqstp->rq_xprt;
+
+	dr->handle.revisit = svc_revisit;
+	return &dr->handle;
+}
+
+/*
+ * recv data from a deferred request into an active one
+ */
+static int svc_deferred_recv(struct svc_rqst *rqstp)
+{
+	struct svc_deferred_req *dr = rqstp->rq_deferred;
+
+	rqstp->rq_arg.head[0].iov_base = dr->args;
+	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
+	rqstp->rq_arg.page_len = 0;
+	rqstp->rq_arg.len = dr->argslen<<2;
+	rqstp->rq_prot        = dr->prot;
+	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
+	rqstp->rq_addrlen     = dr->addrlen;
+	rqstp->rq_daddr       = dr->daddr;
+	rqstp->rq_respages    = rqstp->rq_pages;
+	return dr->argslen<<2;
+}
+
+
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
+{
+	struct svc_deferred_req *dr = NULL;
+
+	if (!test_bit(XPT_DEFERRED, &xprt->xpt_flags))
+		return NULL;
+	spin_lock(&xprt->xpt_lock);
+	clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	if (!list_empty(&xprt->xpt_deferred)) {
+		dr = list_entry(xprt->xpt_deferred.next,
+				struct svc_deferred_req,
+				handle.recent);
+		list_del_init(&dr->handle.recent);
+		set_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	}
+	spin_unlock(&xprt->xpt_lock);
+	return dr;
+}
+
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8578936..0ab68f1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -51,7 +51,7 @@
 /* SMP locking strategy:
  *
  *	svc_pool->sp_lock protects most of the fields of that pool.
- * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
+ *	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
  *	BKL protects svc_serv->sv_nrthread.
  *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
@@ -81,33 +81,20 @@
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int *errp, int flags);
-static void		svc_delete_xprt(struct svc_xprt *xprt);
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
-static void		svc_close_xprt(struct svc_xprt *xprt);
 static void		svc_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
-static int svc_deferred_recv(struct svc_rqst *rqstp);
-static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct sockaddr *, int, int);
-static void svc_age_temp_xprts(unsigned long closure);
-
-/* apparently the "standard" is that clients close
- * idle connections after 5 minutes, servers after
- * 6 minutes
- *   http://www.connectathon.org/talks96/nfstcp.pdf
- */
-static int svc_conn_age_period = 6*60;
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key svc_key[2];
 static struct lock_class_key svc_slock_key[2];
 
-static inline void svc_reclassify_socket(struct socket *sock)
+static void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	BUG_ON(sock_owned_by_user(sk));
@@ -131,67 +118,11 @@ static inline void svc_reclassify_socket(struct socket *sock)
 	}
 }
 #else
-static inline void svc_reclassify_socket(struct socket *sock)
+static void svc_reclassify_socket(struct socket *sock)
 {
 }
 #endif
 
-static char *__svc_print_addr(struct sockaddr *addr, char *buf, size_t len)
-{
-	switch (addr->sa_family) {
-	case AF_INET:
-		snprintf(buf, len, "%u.%u.%u.%u, port=%u",
-			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
-			ntohs(((struct sockaddr_in *) addr)->sin_port));
-		break;
-
-	case AF_INET6:
-		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
-			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
-			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
-		break;
-
-	default:
-		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
-		break;
-	}
-	return buf;
-}
-
-/**
- * svc_print_addr - Format rq_addr field for printing
- * @rqstp: svc_rqst struct containing address to print
- * @buf: target buffer for formatted address
- * @len: length of target buffer
- *
- */
-char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
-{
-	return __svc_print_addr(svc_addr(rqstp), buf, len);
-}
-EXPORT_SYMBOL_GPL(svc_print_addr);
-
-/*
- * Queue up an idle server thread.  Must have pool->sp_lock held.
- * Note: this is really a stack rather than a queue, so that we only
- * use as many different threads as we need, and the rest don't pollute
- * the cache.
- */
-static inline void
-svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
-{
-	list_add(&rqstp->rq_list, &pool->sp_threads);
-}
-
-/*
- * Dequeue an nfsd thread.  Must have pool->sp_lock held.
- */
-static inline void
-svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
-{
-	list_del(&rqstp->rq_list);
-}
-
 /*
  * Release an skbuff after use
  */
@@ -214,217 +145,6 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 	}
 }
 
-/*
- * Queue up a socket with data pending. If there are idle nfsd
- * processes, wake 'em up.
- *
- */
-void svc_xprt_enqueue(struct svc_xprt *xprt)
-{
-	struct svc_serv	*serv = xprt->xpt_server;
-	struct svc_pool *pool;
-	struct svc_rqst	*rqstp;
-	int cpu;
-
-	if (!(xprt->xpt_flags &
-	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
-		return;
-	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
-		return;
-
-	cpu = get_cpu();
-	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
-	put_cpu();
-
-	spin_lock_bh(&pool->sp_lock);
-
-	if (!list_empty(&pool->sp_threads) &&
-	    !list_empty(&pool->sp_sockets))
-		printk(KERN_ERR
-		       "svc_xprt_enqueue: "
-		       "threads and transports both waiting??\n");
-
-	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
-		/* Don't enqueue dead sockets */
-		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
-		goto out_unlock;
-	}
-
-	/* Mark socket as busy. It will remain in this state until the
-	 * server has processed all pending data and put the socket back
-	 * on the idle list.  We update XPT_BUSY atomically because
-	 * it also guards against trying to enqueue the svc_sock twice.
-	 */
-	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
-		/* Don't enqueue socket while already enqueued */
-		dprintk("svc: transport %p busy, not enqueued\n", xprt);
-		goto out_unlock;
-	}
-	BUG_ON(xprt->xpt_pool != NULL);
-	xprt->xpt_pool = pool;
-
-	/* Handle pending connection */
-	if (test_bit(XPT_CONN, &xprt->xpt_flags))
-		goto process;
-
-	/* Handle close in-progress */
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
-		goto process;
-
-	/* Check if we have space to reply to a request */
-	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
-		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: no write space, transport %p  not enqueued\n",
-			xprt);
-		xprt->xpt_pool = NULL;
-		clear_bit(XPT_BUSY, &xprt->xpt_flags);
-		goto out_unlock;
-	}
-
- process:
-	if (!list_empty(&pool->sp_threads)) {
-		rqstp = list_entry(pool->sp_threads.next,
-				   struct svc_rqst,
-				   rq_list);
-		dprintk("svc: transport %p served by daemon %p\n",
-			xprt, rqstp);
-		svc_thread_dequeue(pool, rqstp);
-		if (rqstp->rq_xprt)
-			printk(KERN_ERR
-				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
-				rqstp, rqstp->rq_xprt);
-		rqstp->rq_xprt = xprt;
-		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
-		BUG_ON(xprt->xpt_pool != pool);
-		wake_up(&rqstp->rq_wait);
-	} else {
-		dprintk("svc: transport %p put into queue\n", xprt);
-		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
-		BUG_ON(xprt->xpt_pool != pool);
-	}
-
-out_unlock:
-	spin_unlock_bh(&pool->sp_lock);
-}
-EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
-
-/*
- * Dequeue the first socket.  Must be called with the pool->sp_lock held.
- */
-static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
-{
-	struct svc_xprt	*xprt;
-
-	if (list_empty(&pool->sp_sockets))
-		return NULL;
-
-	xprt = list_entry(pool->sp_sockets.next,
-			  struct svc_xprt, xpt_ready);
-	list_del_init(&xprt->xpt_ready);
-
-	dprintk("svc: transport %p dequeued, inuse=%d\n",
-		xprt, atomic_read(&xprt->xpt_ref.refcount));
-
-	return xprt;
-}
-
-/*
- * Having read something from a socket, check whether it
- * needs to be re-enqueued.
- * Note: XPT_DATA only gets cleared when a read-attempt finds
- * no (or insufficient) data.
- */
-void svc_xprt_received(struct svc_xprt *xprt)
-{
-	xprt->xpt_pool = NULL;
-	clear_bit(XPT_BUSY, &xprt->xpt_flags);
-	svc_xprt_enqueue(xprt);
-}
-EXPORT_SYMBOL_GPL(svc_xprt_received);
-
-/**
- * svc_reserve - change the space reserved for the reply to a request.
- * @rqstp:  The request in question
- * @space: new max space to reserve
- *
- * Each request reserves some space on the output queue of the socket
- * to make sure the reply fits.  This function reduces that reserved
- * space to be the amount of space used already, plus @space.
- *
- */
-void svc_reserve(struct svc_rqst *rqstp, int space)
-{
-	space += rqstp->rq_res.head[0].iov_len;
-
-	if (space < rqstp->rq_reserved) {
-		struct svc_xprt *xprt = rqstp->rq_xprt;
-		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
-		rqstp->rq_reserved = space;
-
-		svc_xprt_enqueue(xprt);
-	}
-}
-
-static void svc_xprt_release(struct svc_rqst *rqstp)
-{
-	struct svc_xprt	*xprt = rqstp->rq_xprt;
-
-	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
-
-	svc_free_res_pages(rqstp);
-	rqstp->rq_res.page_len = 0;
-	rqstp->rq_res.page_base = 0;
-
-	/* Reset response buffer and release
-	 * the reservation.
-	 * But first, check that enough space was reserved
-	 * for the reply, otherwise we have a bug!
-	 */
-	if ((rqstp->rq_res.len) >  rqstp->rq_reserved)
-		printk(KERN_ERR "RPC request reserved %d but used %d\n",
-		       rqstp->rq_reserved,
-		       rqstp->rq_res.len);
-
-	rqstp->rq_res.head[0].iov_len = 0;
-	svc_reserve(rqstp, 0);
-	rqstp->rq_xprt = NULL;
-
-	svc_xprt_put(xprt);
-}
-
-/*
- * External function to wake up a server waiting for data
- * This really only makes sense for services like lockd
- * which have exactly one thread anyway.
- */
-void
-svc_wake_up(struct svc_serv *serv)
-{
-	struct svc_rqst	*rqstp;
-	unsigned int i;
-	struct svc_pool *pool;
-
-	for (i = 0; i < serv->sv_nrpools; i++) {
-		pool = &serv->sv_pools[i];
-
-		spin_lock_bh(&pool->sp_lock);
-		if (!list_empty(&pool->sp_threads)) {
-			rqstp = list_entry(pool->sp_threads.next,
-					   struct svc_rqst,
-					   rq_list);
-			dprintk("svc: daemon %p woken up.\n", rqstp);
-			/*
-			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_xprt = NULL;
-			 */
-			wake_up(&rqstp->rq_wait);
-		}
-		spin_unlock_bh(&pool->sp_lock);
-	}
-}
-
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
 	struct in6_pktinfo pkti6;
@@ -466,8 +186,7 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 /*
  * Generic sendto routine
  */
-static int
-svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
+static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
 	struct svc_sock	*svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
@@ -571,8 +290,7 @@ static int one_sock_name(char *buf, struct svc_sock *svsk)
 	return len;
 }
 
-int
-svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
+int svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 {
 	struct svc_sock *svsk, *closesk = NULL;
 	int len = 0;
@@ -602,8 +320,7 @@ EXPORT_SYMBOL(svc_sock_names);
 /*
  * Check input queue length
  */
-static int
-svc_recv_available(struct svc_sock *svsk)
+static int svc_recv_available(struct svc_sock *svsk)
 {
 	struct socket	*sock = svsk->sk_sock;
 	int		avail, err;
@@ -616,8 +333,8 @@ svc_recv_available(struct svc_sock *svsk)
 /*
  * Generic recvfrom routine.
  */
-static int
-svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
+static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
+			int buflen)
 {
 	struct svc_sock *svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
@@ -637,8 +354,8 @@ svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 /*
  * Set socket snd and rcv buffer lengths
  */
-static inline void
-svc_sock_setbufsize(struct socket *sock, unsigned int snd, unsigned int rcv)
+static void svc_sock_setbufsize(struct socket *sock,
+				unsigned int snd, unsigned int rcv)
 {
 #if 0
 	mm_segment_t	oldfs;
@@ -663,8 +380,7 @@ svc_sock_setbufsize(struct socket *sock, unsigned int snd, unsigned int rcv)
 /*
  * INET callback when data has been received on the socket.
  */
-static void
-svc_udp_data_ready(struct sock *sk, int count)
+static void svc_udp_data_ready(struct sock *sk, int count)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
@@ -682,8 +398,7 @@ svc_udp_data_ready(struct sock *sk, int count)
 /*
  * INET callback when space is newly available on the socket.
  */
-static void
-svc_write_space(struct sock *sk)
+static void svc_write_space(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)(sk->sk_user_data);
 
@@ -729,8 +444,7 @@ static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 /*
  * Receive a datagram from a UDP socket.
  */
-static int
-svc_udp_recvfrom(struct svc_rqst *rqstp)
+static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
@@ -850,8 +564,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	return len;
 }
 
-static int
-svc_udp_sendto(struct svc_rqst *rqstp)
+static int svc_udp_sendto(struct svc_rqst *rqstp)
 {
 	int		error;
 
@@ -950,8 +663,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
  * A data_ready event on a listening socket means there's a connection
  * pending. Do not use state_change as a substitute for it.
  */
-static void
-svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
+static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
@@ -983,8 +695,7 @@ svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 /*
  * A state change on a connected socket means it's dying or dead.
  */
-static void
-svc_tcp_state_change(struct sock *sk)
+static void svc_tcp_state_change(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
@@ -1001,8 +712,7 @@ svc_tcp_state_change(struct sock *sk)
 		wake_up_interruptible_all(sk->sk_sleep);
 }
 
-static void
-svc_tcp_data_ready(struct sock *sk, int count)
+static void svc_tcp_data_ready(struct sock *sk, int count)
 {
 	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
 
@@ -1016,20 +726,6 @@ svc_tcp_data_ready(struct sock *sk, int count)
 		wake_up_interruptible(sk->sk_sleep);
 }
 
-static inline int svc_port_is_privileged(struct sockaddr *sin)
-{
-	switch (sin->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *)sin)->sin_port)
-			< PROT_SOCK;
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
-			< PROT_SOCK;
-	default:
-		return 0;
-	}
-}
-
 /*
  * Accept a TCP connection
  */
@@ -1112,8 +808,7 @@ failed:
 /*
  * Receive data from a TCP socket.
  */
-static int
-svc_tcp_recvfrom(struct svc_rqst *rqstp)
+static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
@@ -1266,8 +961,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 /*
  * Send out data on TCP socket.
  */
-static int
-svc_tcp_sendto(struct svc_rqst *rqstp)
+static int svc_tcp_sendto(struct svc_rqst *rqstp)
 {
 	struct xdr_buf	*xbufp = &rqstp->rq_res;
 	int sent;
@@ -1285,7 +979,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
-		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
+		printk(KERN_NOTICE
+		       "rpc-srv/tcp: %s: %s %d when sending %d bytes - "
+		       "shutting down socket\n",
 		       rqstp->rq_xprt->xpt_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
@@ -1407,8 +1103,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	}
 }
 
-void
-svc_sock_update_bufs(struct svc_serv *serv)
+void svc_sock_update_bufs(struct svc_serv *serv)
 {
 	/*
 	 * The number of server threads has changed. Update
@@ -1431,307 +1126,6 @@ svc_sock_update_bufs(struct svc_serv *serv)
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
-	char	buf[RPC_MAX_ADDRBUFLEN];
-
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
-		struct svc_xprt *xprt = NULL;
-		spin_lock_bh(&serv->sv_lock);
-		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_ratelimit()) {
-				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open  "
-					"connections, consider increasing the "
-					"number of nfsd threads\n",
-				       serv->sv_name);
-				printk(KERN_NOTICE
-				       "%s: last connection from %s\n",
-				       serv->sv_name, buf);
-			}
-			/*
-			 * Always select the oldest connection. It's not fair,
-			 * but so is life
-			 */
-			xprt = list_entry(serv->sv_tempsocks.prev,
-					  struct svc_xprt,
-					  xpt_list);
-			set_bit(XPT_CLOSE, &xprt->xpt_flags);
-			svc_xprt_get(xprt);
-		}
-		spin_unlock_bh(&serv->sv_lock);
-
-		if (xprt) {
-			svc_xprt_enqueue(xprt);
-			svc_xprt_put(xprt);
-		}
-	}
-}
-
-/*
- * Receive the next request on any socket.  This code is carefully
- * organised not to touch any cachelines in the shared svc_serv
- * structure, only cachelines in the local svc_pool.
- */
-int
-svc_recv(struct svc_rqst *rqstp, long timeout)
-{
-	struct svc_xprt		*xprt = NULL;
-	struct svc_serv		*serv = rqstp->rq_server;
-	struct svc_pool		*pool = rqstp->rq_pool;
-	int			len, i;
-	int			pages;
-	struct xdr_buf		*arg;
-	DECLARE_WAITQUEUE(wait, current);
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
-
-
-	/* now allocate needed pages.  If we get a failure, sleep briefly */
-	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
-	for (i=0; i < pages ; i++)
-		while (rqstp->rq_pages[i] == NULL) {
-			struct page *p = alloc_page(GFP_KERNEL);
-			if (!p)
-				schedule_timeout_uninterruptible(msecs_to_jiffies(500));
-			rqstp->rq_pages[i] = p;
-		}
-	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
-	BUG_ON(pages >= RPCSVC_MAXPAGES);
-
-	/* Make arg->head point to first page and arg->pages point to rest */
-	arg = &rqstp->rq_arg;
-	arg->head[0].iov_base = page_address(rqstp->rq_pages[0]);
-	arg->head[0].iov_len = PAGE_SIZE;
-	arg->pages = rqstp->rq_pages + 1;
-	arg->page_base = 0;
-	/* save at least one page for response */
-	arg->page_len = (pages-2)*PAGE_SIZE;
-	arg->len = (pages-1)*PAGE_SIZE;
-	arg->tail[0].iov_len = 0;
-
-	try_to_freeze();
-	cond_resched();
-	if (signalled())
-		return -EINTR;
-
-	spin_lock_bh(&pool->sp_lock);
-	xprt = svc_xprt_dequeue(pool);
-	if (xprt) {
-		rqstp->rq_xprt = xprt;
-		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
-	} else {
-		/* No data pending. Go to sleep */
-		svc_thread_enqueue(pool, rqstp);
-
-		/*
-		 * We have to be able to interrupt this wait
-		 * to bring down the daemons ...
-		 */
-		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue(&rqstp->rq_wait, &wait);
-		spin_unlock_bh(&pool->sp_lock);
-
-		schedule_timeout(timeout);
-
-		try_to_freeze();
-
-		spin_lock_bh(&pool->sp_lock);
-		remove_wait_queue(&rqstp->rq_wait, &wait);
-
-		xprt = rqstp->rq_xprt;
-		if (!xprt) {
-			svc_thread_dequeue(pool, rqstp);
-			spin_unlock_bh(&pool->sp_lock);
-			dprintk("svc: server %p, no data yet\n", rqstp);
-			return signalled()? -EINTR : -EAGAIN;
-		}
-	}
-	spin_unlock_bh(&pool->sp_lock);
-
-	len = 0;
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
-		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(xprt);
-	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
-		struct svc_xprt *newxpt;
-		newxpt = xprt->xpt_ops->xpo_accept(xprt);
-		if (newxpt) {
-			/*
-			 * We know this module_get will succeed because the
-			 * listener holds a reference too
-			 */
-			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(xprt->xpt_server);
-			spin_lock_bh(&serv->sv_lock);
-			set_bit(XPT_TEMP, &newxpt->xpt_flags);
-			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
-			serv->sv_tmpcnt++;
-			if (serv->sv_temptimer.function == NULL) {
-				/* setup timer to age temp sockets */
-				setup_timer(&serv->sv_temptimer,
-					    svc_age_temp_xprts,
-					    (unsigned long)serv);
-				mod_timer(&serv->sv_temptimer,
-					  jiffies + svc_conn_age_period * HZ);
-			}
-			spin_unlock_bh(&serv->sv_lock);
-			svc_xprt_received(newxpt);
-		}
-		svc_xprt_received(xprt);
-	} else {
-		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
-			rqstp, pool->sp_id, xprt,
-			atomic_read(&xprt->xpt_ref.refcount));
-		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
-		if (rqstp->rq_deferred) {
-			svc_xprt_received(xprt);
-			len = svc_deferred_recv(rqstp);
-		} else
-			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
-		dprintk("svc: got len=%d\n", len);
-	}
-
-	/* No data, incomplete (TCP) read, or accept() */
-	if (len == 0 || len == -EAGAIN) {
-		rqstp->rq_res.len = 0;
-		svc_xprt_release(rqstp);
-		return -EAGAIN;
-	}
-	clear_bit(XPT_OLD, &xprt->xpt_flags);
-
-	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
-	rqstp->rq_chandle.defer = svc_defer;
-
-	if (serv->sv_stats)
-		serv->sv_stats->netcnt++;
-	return len;
-}
-
-/*
- * Drop request
- */
-void
-svc_drop(struct svc_rqst *rqstp)
-{
-	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
-	svc_xprt_release(rqstp);
-}
-
-/*
- * Return reply to client.
- */
-int
-svc_send(struct svc_rqst *rqstp)
-{
-	struct svc_xprt	*xprt;
-	int		len;
-	struct xdr_buf	*xb;
-
-	xprt = rqstp->rq_xprt;
-	if (!xprt)
-		return -EFAULT;
-
-	/* release the receive skb before sending the reply */
-	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
-
-	/* calculate over-all length */
-	xb = & rqstp->rq_res;
-	xb->len = xb->head[0].iov_len +
-		xb->page_len +
-		xb->tail[0].iov_len;
-
-	/* Grab mutex to serialize outgoing data. */
-	mutex_lock(&xprt->xpt_mutex);
-	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
-		len = -ENOTCONN;
-	else
-		len = xprt->xpt_ops->xpo_sendto(rqstp);
-	mutex_unlock(&xprt->xpt_mutex);
-	svc_xprt_release(rqstp);
-
-	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
-		return 0;
-	return len;
-}
-
-/*
- * Timer function to close old temporary sockets, using
- * a mark-and-sweep algorithm.
- */
-static void svc_age_temp_xprts(unsigned long closure)
-{
-	struct svc_serv *serv = (struct svc_serv *)closure;
-	struct svc_xprt *xprt;
-	struct list_head *le, *next;
-	LIST_HEAD(to_be_aged);
-
-	dprintk("svc_age_temp_xprts\n");
-
-	if (!spin_trylock_bh(&serv->sv_lock)) {
-		/* busy, try again 1 sec later */
-		dprintk("svc_age_temp_xprts: busy\n");
-		mod_timer(&serv->sv_temptimer, jiffies + HZ);
-		return;
-	}
-
-	list_for_each_safe(le, next, &serv->sv_tempsocks) {
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
-
-		/* First time through, just mark it OLD. Second time
-		 * through, close it. */
-		if (!test_and_set_bit(XPT_OLD, &xprt->xpt_flags))
-			continue;
-		if (atomic_read(&xprt->xpt_ref.refcount) > 1
-		    || test_bit(XPT_BUSY, &xprt->xpt_flags))
-			continue;
-		svc_xprt_get(xprt);
-		list_move(le, &to_be_aged);
-		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		set_bit(XPT_DETACHED, &xprt->xpt_flags);
-	}
-	spin_unlock_bh(&serv->sv_lock);
-
-	while (!list_empty(&to_be_aged)) {
-		le = to_be_aged.next;
-		/* fiddling the xpt_list node is safe 'cos we're XPT_DETACHED */
-		list_del_init(le);
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
-
-		dprintk("queuing xprt %p for closing\n", xprt);
-
-		/* a thread will dequeue and close it soon */
-		svc_xprt_enqueue(xprt);
-		svc_xprt_put(xprt);
-	}
-
-	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
-}
-
-/*
  * Initialize socket for RPC use and create svc_sock struct
  * XXX: May want to setsockopt SO_SNDBUF and SO_RCVBUF.
  */
@@ -1917,160 +1311,3 @@ static void svc_sock_free(struct svc_xprt *xprt)
 		sock_release(svsk->sk_sock);
 	kfree(svsk);
 }
-
-/*
- * Remove a dead transport
- */
-static void svc_delete_xprt(struct svc_xprt *xprt)
-{
-	struct svc_serv	*serv = xprt->xpt_server;
-
-	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
-	xprt->xpt_ops->xpo_detach(xprt);
-
-	spin_lock_bh(&serv->sv_lock);
-	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
-		list_del_init(&xprt->xpt_list);
-	/*
-	 * We used to delete the transport from whichever list
-	 * it's sk_xprt.xpt_ready node was on, but we don't actually
-	 * need to.  This is because the only time we're called
-	 * while still attached to a queue, the queue itself
-	 * is about to be destroyed (in svc_destroy).
-	 */
-	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
-		BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
-		svc_xprt_put(xprt);
-		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
-			serv->sv_tmpcnt--;
-	}
-	spin_unlock_bh(&serv->sv_lock);
-}
-
-static void svc_close_xprt(struct svc_xprt *xprt)
-{
-	set_bit(XPT_CLOSE, &xprt->xpt_flags);
-	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
-		/* someone else will have to effect the close */
-		return;
-
-	svc_xprt_get(xprt);
-	svc_delete_xprt(xprt);
-	clear_bit(XPT_BUSY, &xprt->xpt_flags);
-	svc_xprt_put(xprt);
-}
-
-void svc_close_all(struct list_head *xprt_list)
-{
-	struct svc_xprt *xprt;
-	struct svc_xprt *tmp;
-
-	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
-		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		if (test_bit(XPT_BUSY, &xprt->xpt_flags)) {
-			/* Waiting to be processed, but no threads left,
-			 * So just remove it from the waiting list
-			 */
-			list_del_init(&xprt->xpt_ready);
-			clear_bit(XPT_BUSY, &xprt->xpt_flags);
-		}
-		svc_close_xprt(xprt);
-	}
-}
-
-/*
- * Handle defer and revisit of requests
- */
-
-static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
-{
-	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
-	struct svc_xprt *xprt = dr->xprt;
-
-	if (too_many) {
-		svc_xprt_put(xprt);
-		kfree(dr);
-		return;
-	}
-	dprintk("revisit queued\n");
-	dr->xprt = NULL;
-	spin_lock(&xprt->xpt_lock);
-	list_add(&dr->handle.recent, &xprt->xpt_deferred);
-	spin_unlock(&xprt->xpt_lock);
-	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
-	svc_xprt_enqueue(xprt);
-	svc_xprt_put(xprt);
-}
-
-static struct cache_deferred_req *
-svc_defer(struct cache_req *req)
-{
-	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
-	struct svc_deferred_req *dr;
-
-	if (rqstp->rq_arg.page_len)
-		return NULL; /* if more than a page, give up FIXME */
-	if (rqstp->rq_deferred) {
-		dr = rqstp->rq_deferred;
-		rqstp->rq_deferred = NULL;
-	} else {
-		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
-		/* FIXME maybe discard if size too large */
-		dr = kmalloc(size, GFP_KERNEL);
-		if (dr == NULL)
-			return NULL;
-
-		dr->handle.owner = rqstp->rq_server;
-		dr->prot = rqstp->rq_prot;
-		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
-		dr->addrlen = rqstp->rq_addrlen;
-		dr->daddr = rqstp->rq_daddr;
-		dr->argslen = rqstp->rq_arg.len >> 2;
-		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
-	}
-	svc_xprt_get(rqstp->rq_xprt);
-	dr->xprt = rqstp->rq_xprt;
-
-	dr->handle.revisit = svc_revisit;
-	return &dr->handle;
-}
-
-/*
- * recv data from a deferred request into an active one
- */
-static int svc_deferred_recv(struct svc_rqst *rqstp)
-{
-	struct svc_deferred_req *dr = rqstp->rq_deferred;
-
-	rqstp->rq_arg.head[0].iov_base = dr->args;
-	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
-	rqstp->rq_arg.page_len = 0;
-	rqstp->rq_arg.len = dr->argslen<<2;
-	rqstp->rq_prot        = dr->prot;
-	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
-	rqstp->rq_addrlen     = dr->addrlen;
-	rqstp->rq_daddr       = dr->daddr;
-	rqstp->rq_respages    = rqstp->rq_pages;
-	return dr->argslen<<2;
-}
-
-
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
-{
-	struct svc_deferred_req *dr = NULL;
-
-	if (!test_bit(XPT_DEFERRED, &xprt->xpt_flags))
-		return NULL;
-	spin_lock(&xprt->xpt_lock);
-	clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
-	if (!list_empty(&xprt->xpt_deferred)) {
-		dr = list_entry(xprt->xpt_deferred.next,
-				struct svc_deferred_req,
-				handle.recent);
-		list_del_init(&dr->handle.recent);
-		set_bit(XPT_DEFERRED, &xprt->xpt_flags);
-	}
-	spin_unlock(&xprt->xpt_lock);
-	return dr;
-}
