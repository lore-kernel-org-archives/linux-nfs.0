Received: from mail-oo2-f37.google.com (mail-oo2-f37.google.com [74.125.231.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 067CE4DAF85
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 16:42:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.165
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790959381; cv=none; b=LgB1en8tadBHLj6ETIYz3D9VJujeW6gr9P/X5ug8hO6O292niZfwnwQufk4oW4gYnIY2jhHGJOeTHVtxS4Q3ekWSeF8+Gj3nij73sN6QqpehRs3zZOe0urlcf3TxtwgslHzvnctumt5CiBWAkQOUbS4uuM5MGFTrjiTTQPCgZ/M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790959381; c=relaxed/simple;
	bh=6KuhV94KcruuQ+YN7LOd/7n092BKddspFP9t/mnB9w8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EPNBCfjFrsfAO8JqM1v+PiRB2ZlCjgbZK/9J5/gDCP22UHqef0qmE2Im/VZmNqI7r7zW0lzuA+KZnWi1eyH27cg6St4OzHe6IKsdiPAcEoVviztRhOKHSlGJuH0bEEZiuTcU3xH8f+Yvp5mL9JfORXtduvQ2adxgG0Up8J7Wz30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OfBWkjM0; arc=none smtp.client-ip=74.125.231.165
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OfBWkjM0"
Received: by mail-oo2-f37.google.com with SMTP id 46e09a7af769-8137b129131so70204a34.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 09:42:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790959379; x=1791564179; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NlkyTWl8resmehTHg6aEAUF3Vge/TVlQuteQDu446js=;
        b=OfBWkjM0ZvOJvuuJEyzlVuolGyxmvS6xGxemppV8MvF3oSxsdreQhnCLJuklxTFLH6
         fAs8yK6pUWSDIfATmOQWKcLpKHC9dlzFIe8OYivGl1Zx1pY3O+1ggde7acwiGfhCg0YG
         RsYMtI7EEF3C1KRIImOnUDDOIV5eqf6fqAgB70uEE7WQHZ0Re+5HoWLew8nCNG8pLPAV
         qPnObck0qDHP9z6qEKmW4hDu80xFLyikxET7/CRzvQky4gcSf8fDuXUWbZnqwN8Twl3M
         NstpEhf0iAf0QBkbDKYBtwP45PHsKBc+es3FqzjCDzHOTf8B8cjY6qVu0pSEw0u8ecNL
         NUfA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790959379; x=1791564179;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NlkyTWl8resmehTHg6aEAUF3Vge/TVlQuteQDu446js=;
        b=ZaRZ5fPPsHdtXBxhc8kKoQhb66yM9YtjjW6h8oZsZZnI0WIBVPGWOniF1AnfdgAEez
         pqqLojTDs9BtGrca5eZt4DwWH075ToNBq7o2krJb77kokyfI13eCjw+njtTSkJw65OqL
         Eo695CwgbtsgfZgPWll9fl2MYDzWzl4JRowjy/3ZFJEOvAn8u5F02SEJv7Bz4lB9L5ze
         DTAVnqOhRmMjNYzYy0MGM6PBJZ5A8JUHD/CLVNKB/3VfekIF/OpTSkkxP0RLEbnVgyHi
         nYQvJe3I6IqiE7wt3cfB5Owmwg9EdfcnxfUu1gRk1LisYRCHpxy/CKf3e8pj8Iz3RZS8
         7dkQ==
X-Gm-Message-State: AFuF++n+8XEhd7fqX1jvwXmq2uKQPM/nTJoLXJs/p7sGFE/XjeHCz9y2
	M5PPjNDM7K/8/V1qEAeV4rmsdftPHmkq7ipyWS4lQSLDp/bMh6zsoDob46+39PJ1CU4=
X-Gm-Gg: AYBFou06Z17Km00RI2U+PXlRVI2gBEFgd1tZIrrFsoP/2w5ale1N948hjL4EbXnIejo
	5iqHEEfEaCpcFUZG5GIJoBt4Y8m5sqc6wOiZ1RCrKwiy9WABxCQ5EYg8EvOknDVrUTSCpXDXoKl
	3njCGZLldMXdH4SSc9wDCcw0DTfYtyA06APInA8xaquozs8LiQJNgD3OvzTqkYA8U4IX4culGr3
	U854OnsFnallBL7HgLzqSrkWFL2KQK0LlrgqBBwChX3r3+lgKdKBqgGlPM79ubpKr1MwtPjTJfS
	oR6KDBnLqeKALdVipg7eHmeBO6qcsrELrDl0SEcPVrdgFi8yQc9aoaFBTIvZeCUfHuU2UPhK1kd
	ymdY7y1TRJFGXRCQdK2wio4zZB0wP/YTGox3xkbTMLiICagJK/hPylCfQSjt1F1E2l0xZQS339J
	muHZbXlBElE/vP6LXyPKXFp0/j3Q+YCmXlvMnmp4g659Y1YPXc90LDYZ105xCPvQtxHJ9RyTtDx
	rKFePDdv30EdhO3sDBKIOeuddPoqfXhXnNIz3fVL+Jt
X-Received: by 2002:a05:6820:1a05:b0:6b6:87cf:d1dc with SMTP id 006d021491bc7-6df32da21bcmr2363823eaf.24.1790959378525;
        Fri, 02 Oct 2026 09:42:58 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8227a66c6dfsm3238524a34.23.2026.10.02.09.42.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 09:42:58 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>
Subject: [PATCH RFC 1/2] SUNRPC: track service clients by peer address
Date: Fri,  2 Oct 2026 12:42:54 -0400
Message-ID: <dc5f43ea406deffd0074904f2fbc9b554fa69d2f.1790953694.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1790953694.git.bcodding@hammerspace.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A pool dispatches its ready transports in FIFO order, one RPC per turn,
so a peer's share of the service grows with the number of connections
it holds: a client with K connections is served K times as often as a
client with one.  Dispatching per peer instead needs the service to know
which transports belong to the same peer.

Add struct svc_client, one per peer address and network namespace of a
service, found through a small hash table under a spinlock.  The table
is touched only when a connection is accepted and when a client's last
transport is freed; dispatch will follow the transport's xpt_client
pointer, which is set before the transport can be enqueued (it is still
XPT_BUSY from svc_xprt_init()) and is kept alive by the transport's
reference.  Each client carries a per-pool lwq of its ready transports
and a node for the pool's queue of clients, unused as yet.

Listeners, UDP sockets, and accepted transports for which no client can
be allocated are bound to the service's anonymous client.

Dispatch is unchanged by this patch.

Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h      | 32 +++++++++++
 include/linux/sunrpc/svc_xprt.h |  1 +
 net/sunrpc/svc.c                | 34 ++++++++++++
 net/sunrpc/svc_xprt.c           | 97 +++++++++++++++++++++++++++++++++
 4 files changed, 164 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index bdff8ccb92c7..496fd33da96f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -58,6 +58,33 @@ enum {
 	SP_TASK_STARTING,	/* Task has started but not added to idle yet */
 };
 
+/*
+ * One peer of a service: the transports from one address in one network
+ * namespace.  Ready transports are queued per client and per pool, and a
+ * pool dispatches round-robin across its queued clients, so a peer's share
+ * of the service does not grow with its connection count.
+ */
+struct svc_client_pool {
+	struct lwq		cp_xprts;	/* ready transports */
+	struct lwq_node		cp_ready;	/* link in svc_pool.sp_clients */
+	unsigned long		cp_flags;
+	struct svc_client	*cp_client;
+};
+
+enum {
+	SVC_CP_QUEUED,	/* on sp_clients, or held by the thread that took it */
+};
+
+struct svc_client {
+	struct hlist_node	cl_hash;
+	refcount_t		cl_ref;
+	struct net		*cl_net;
+	struct sockaddr_storage	cl_addr;	/* peer address; port ignored */
+	struct svc_client_pool	cl_pool[];	/* one per pool */
+};
+
+#define SVC_CLIENT_HASH_BITS	8
+
 
 struct svc_rqst;
 
@@ -94,6 +121,10 @@ struct svc_serv {
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	int			(*sv_threadfn)(void *data);
 
+	spinlock_t		sv_client_lock;	/* protects sv_client_hash */
+	struct hlist_head	sv_client_hash[1 << SVC_CLIENT_HASH_BITS];
+	struct svc_client	*sv_anon_client; /* transports without a peer */
+
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct lwq		sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -500,6 +531,7 @@ void		   svc_reserve(struct svc_rqst *rqstp, int space);
 void		   svc_pool_wake_idle_thread(struct svc_pool *pool);
 struct svc_pool   *svc_pool_for_cpu(struct svc_serv *serv);
 unsigned int	   svc_serv_nrpools(const struct svc_serv *serv);
+struct svc_client *svc_client_alloc(unsigned int nrpools, gfp_t gfp);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 const char *	   svc_proc_name(const struct svc_rqst *rqstp);
 int		   svc_encode_result_payload(struct svc_rqst *rqstp,
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 7176c42f19d7..ee4dd0d3647c 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,6 +63,7 @@ struct svc_xprt {
 	unsigned long		xpt_flags;
 
 	struct svc_serv		*xpt_server;	/* service for transport */
+	struct svc_client	*xpt_client;	/* peer this transport belongs to */
 	atomic_t		xpt_reserved;	/* outq space rsvd, UDP only */
 	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 0a2c040ad096..cb2b7caaa627 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -387,6 +387,30 @@ static void svc_pool_destroy_counters(struct svc_pool *pool)
 	percpu_counter_destroy(&pool->sp_threads_woken);
 }
 
+/**
+ * svc_client_alloc - allocate a service client
+ * @nrpools: number of thread pools in the service
+ * @gfp: allocation flags
+ *
+ * Return: the client, holding one reference, or %NULL.
+ */
+struct svc_client *svc_client_alloc(unsigned int nrpools, gfp_t gfp)
+{
+	struct svc_client *cl;
+	unsigned int i;
+
+	cl = kzalloc(struct_size(cl, cl_pool, nrpools), gfp);
+	if (!cl)
+		return NULL;
+	refcount_set(&cl->cl_ref, 1);
+	INIT_HLIST_NODE(&cl->cl_hash);
+	for (i = 0; i < nrpools; i++) {
+		lwq_init(&cl->cl_pool[i].cp_xprts);
+		cl->cl_pool[i].cp_client = cl;
+	}
+	return cl;
+}
+
 /*
  * Create an RPC service
  */
@@ -432,8 +456,16 @@ __svc_create(struct svc_program *prog, int nprogs, struct svc_stat *stats,
 
 	__svc_init_bc(serv);
 
+	spin_lock_init(&serv->sv_client_lock);
+	serv->sv_anon_client = svc_client_alloc(npools, GFP_KERNEL);
+	if (!serv->sv_anon_client) {
+		kfree(serv);
+		return NULL;
+	}
+
 	serv->sv_pools = kzalloc_objs(struct svc_pool, npools);
 	if (!serv->sv_pools) {
+		kfree(serv->sv_anon_client);
 		kfree(serv);
 		return NULL;
 	}
@@ -459,6 +491,7 @@ __svc_create(struct svc_program *prog, int nprogs, struct svc_stat *stats,
 	while (i--)
 		svc_pool_destroy_counters(&serv->sv_pools[i]);
 	kfree(serv->sv_pools);
+	kfree(serv->sv_anon_client);
 	kfree(serv);
 	return NULL;
 }
@@ -545,6 +578,7 @@ svc_destroy(struct svc_serv **servp)
 	if (serv->sv_is_pooled)
 		svc_pool_map_put();
 
+	kfree(serv->sv_anon_client);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c891532fb1f6..51753aeeb0ba 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -9,8 +9,11 @@
 #include <linux/sched/mm.h>
 #include <linux/errno.h>
 #include <linux/freezer.h>
+#include <linux/hash.h>
 #include <linux/slab.h>
 #include <net/sock.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
@@ -167,6 +170,96 @@ void svc_xprt_deferred_close(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_deferred_close);
 
+static unsigned int svc_client_hash(const struct sockaddr *sa,
+				    const struct net *net)
+{
+	u32 h = hash_ptr(net, 32);
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		h = __ipv4_addr_hash(((const struct sockaddr_in *)sa)->sin_addr.s_addr, h);
+		break;
+	case AF_INET6:
+		h = __ipv6_addr_jhash(&((const struct sockaddr_in6 *)sa)->sin6_addr, h);
+		break;
+	}
+	return hash_32(h, SVC_CLIENT_HASH_BITS);
+}
+
+static struct svc_client *svc_client_get(struct svc_client *cl)
+{
+	refcount_inc(&cl->cl_ref);
+	return cl;
+}
+
+static void svc_client_put(struct svc_serv *serv, struct svc_client *cl)
+{
+	if (!refcount_dec_and_test(&cl->cl_ref))
+		return;
+	spin_lock_bh(&serv->sv_client_lock);
+	hlist_del(&cl->cl_hash);
+	spin_unlock_bh(&serv->sv_client_lock);
+	kfree(cl);
+}
+
+/* Caller holds sv_client_lock. */
+static struct svc_client *svc_client_find(struct hlist_head *head,
+					  const struct net *net,
+					  const struct sockaddr *sa)
+{
+	struct svc_client *cl;
+
+	hlist_for_each_entry(cl, head, cl_hash)
+		if (cl->cl_net == net &&
+		    rpc_cmp_addr((struct sockaddr *)&cl->cl_addr, sa) &&
+		    refcount_inc_not_zero(&cl->cl_ref))
+			return cl;
+	return NULL;
+}
+
+/*
+ * Bind @xprt to the client for its peer address.  Runs once per accepted
+ * transport, in process context, while the transport is still XPT_BUSY
+ * from svc_xprt_init(), so no enqueue can see the pointer change.  A
+ * transport without a usable peer address, or one for which no client can
+ * be allocated, stays on the service's anonymous client.
+ */
+static void svc_client_bind(struct svc_serv *serv, struct svc_xprt *xprt)
+{
+	struct sockaddr *sa = (struct sockaddr *)&xprt->xpt_remote;
+	struct svc_client *cl, *new = NULL;
+	struct net *net = xprt->xpt_net;
+	struct hlist_head *head;
+
+	if (sa->sa_family != AF_INET && sa->sa_family != AF_INET6)
+		return;
+	head = &serv->sv_client_hash[svc_client_hash(sa, net)];
+
+	spin_lock_bh(&serv->sv_client_lock);
+	cl = svc_client_find(head, net, sa);
+	spin_unlock_bh(&serv->sv_client_lock);
+	if (!cl) {
+		new = svc_client_alloc(svc_serv_nrpools(serv), GFP_KERNEL);
+		if (!new)
+			return;
+		new->cl_net = net;
+		memcpy(&new->cl_addr, sa, xprt->xpt_remotelen);
+
+		spin_lock_bh(&serv->sv_client_lock);
+		cl = svc_client_find(head, net, sa);
+		if (!cl) {
+			hlist_add_head(&new->cl_hash, head);
+			cl = new;
+			new = NULL;
+		}
+		spin_unlock_bh(&serv->sv_client_lock);
+		kfree(new);
+	}
+
+	svc_client_put(serv, xprt->xpt_client);
+	xprt->xpt_client = cl;
+}
+
 static void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
@@ -176,6 +269,7 @@ static void svc_xprt_free(struct kref *kref)
 	trace_svc_xprt_free(xprt);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
+	svc_client_put(xprt->xpt_server, xprt->xpt_client);
 	put_cred(xprt->xpt_cred);
 	put_net_track(xprt->xpt_net, &xprt->ns_tracker);
 	/* See comment on corresponding get in xs_setup_bc_tcp(): */
@@ -213,6 +307,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	xprt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xprt->xpt_ref);
 	xprt->xpt_server = serv;
+	xprt->xpt_client = svc_client_get(serv->sv_anon_client);
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
 	INIT_LIST_HEAD(&xprt->xpt_users);
@@ -836,6 +931,8 @@ static bool svc_thread_wait_for_work(struct svc_rqst *rqstp, long timeo)
 
 static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
 {
+	svc_client_bind(serv, newxpt);
+
 	spin_lock_bh(&serv->sv_lock);
 	set_bit(XPT_TEMP, &newxpt->xpt_flags);
 	list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
-- 
2.53.0

