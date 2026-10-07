Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC1404E80AD
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403185; cv=none; b=M5GI4d33eoGqs2yyWBVpOkfPQ+V+QsH8tbLCrROuFJ7fJh01JVcaWjdQ1vSRBjlXPC9WZp7OAbnm2VijOucH3qUBV3qo0IRjZ/QTwlmb9u0wWOPgiPxDAjnm36VPTLQfEWBXpS6HAPST9WbgXf5DBgWzSjWXtMlFdgH2HJ7MyEQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403185; c=relaxed/simple;
	bh=dwk/FAjCABSWpOAo8LnbYVWYfehDVJTFd6XM3Xv9Vu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hDhCu+jQzVQM/PV9koD4MzpodPe7FEshoyk+cjFPocbYZSQuKZ2PUVhfv5Iq6cU5xCJIgQuVG70bY1mp9Fn5kMuB1t2D81Cluz5I5+RSMoacjhjbwIdo5qhRlHk+TO4wcgz2e+KljRnsL+nr3kveh8xWlc8Fc+hNGJkZ9T4WHLo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OLby2Xup; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OLby2Xup"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-49ddddefadbso873986fac.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403178; x=1792007978; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jXKHHsRrK8smWfzZM+GG6t6c/jG2BrnOcw2ElUJkoTM=;
        b=OLby2XupmMCGpPTCDFL2eEirUwB+Nz9lfUZfanq9f7Nc9Xk5hOVO2W+it1SttJ6BAM
         1Z8qHNTOYuL5U2yjY9SCcen4on684sMDGKGJZGusN4wBIVdhR5mPB1guiG1CF9YTTR2w
         AZx+8NsQO8BhbO3/ofkRuCdPjOrUeas/9RT8wBQzQ/L5MkFJBUubxyOuNrReDSzzjbDk
         ymhdFykFxf7KCFVXCIDtHnsBGE4io3Vda7IpzMz+6+p2+NJdlayMEzIRVOSFw2v2T3ff
         7LBs6FIi2+tC+vd3r4nGDvy2g/7pzoCPemZSod6CJ39kR7Lx72JBzxevc1QL9YlC6Cz4
         CSQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403178; x=1792007978;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jXKHHsRrK8smWfzZM+GG6t6c/jG2BrnOcw2ElUJkoTM=;
        b=ltgZrFrBzm7LuZgPypO8j+eZdUuofiIfTgX3EY+llolvIUvdYM6HgnSOSdYjKYThBT
         5W8Uc21FYN0jdIUMmuuGVOKXDQCL9pGbZZPsXfYNEMrFdBNek2LQFtqIfuG73vf2CVl5
         EuoJpY3aa7e06BzAqWcmLHDvpxgbzJzqkBWcaXI69bP0PaTQxxhjUUK/QqKTjA3G5ZKV
         ghUcm4A0FfclpYrVTfyTCm0OV5OeGkFGEwc6iu6uPeT2+g9iUn++dDR7MyLjUuiOgeHB
         WW5gidew+vuWSH8CfdMiWjRGvgS0lwcBDrj6G6Op+WFdUfL80epZ+iU8GNBTSwRcQe+y
         BpPA==
X-Gm-Message-State: AFq9FYIwtBwdvzwJLrXo3iyFiM2gXCznVKh/dv+fUMT8/omPEqujojEb
	tF+VW4u4q0A/ygDZmMHL47FxWnDUxC4yG6uXa9lyasLmFB1ZsZA+UcjnlRqxe02ZPC0=
X-Gm-Gg: AYBFou0ygQncavaBabi/Qo1FmovCDOEkexdBIay4t5yPMKs2z+TDqhTNfCvWLNvim4C
	1Cb/uD1xxX/bST18eS2DqNL91EPdBzmA9fXWu8IfL8MS0lqojVa76aM2M36ZflpWPLyZ761tQBE
	dK56KgLOClc0pxG2+dJJLnpm28vC2d+VtSzjL1uTk5IjI5P2Ys7b1/YGN1fcIe9EBoGGOTjhHNG
	LpqOwbWh8KhSB5JxQ4Gd5Oyzm++UPHTDA6NBP8P3jdSMjRUC+dMs5FiLWeVn57I+BJsKdt0DUBN
	f5Bcke3ypN9OX2sxcTgK+RTYCa3IYuUt6N6QxlbWisSzwF+ro2591bxYx4mYrZCqaahu9t8C1wq
	+6qc9rj0+L91BQWBRKaLcWnhAcWAqhUcmwW3GLFnFoTDgX91kduWbbCF4ovO8UiXLf0OuHrMFRD
	sy3JQ5tT7qDQWRl9WadUyHWsVnkfjO/fhZ/peIUeHD/uKg79OEU1mTiYqo/9w38vG5U1raeh9xh
	XIeC+o3HBcSrYXMpeY6pHCtoqBJix6S5G9FlduZNg==
X-Received: by 2002:a05:6870:96a2:b0:465:80d5:621c with SMTP id 586e51a60fabf-4a258ed7ffemr3020534fac.0.1791403178051;
        Wed, 07 Oct 2026 12:59:38 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 1/9] SUNRPC: track service clients by class
Date: Wed,  7 Oct 2026 15:59:26 -0400
Message-ID: <1b7d26a4b014a8ca535e08f6fcd009a72ddc2758.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

A pool dispatches its ready transports in FIFO order, one RPC per turn,
so a peer's share of the service grows with the number of connections
it holds: a client with K connections is served K times as often as a
client with one.  Dispatching per client instead needs the service to
know which transports belong together, and which transports belong
together is a question for the administrator, not the kernel: one site
wants every host served alike, another wants a set of bulk movers to
share one turn among them.

Add struct svc_client, one per class of transports in a network
namespace of a service, or one per peer address within a class, found
through a small hash table under a spinlock.  The class of an accepted
transport comes from svc_classify(), which for now returns
SVC_CLASS_NONE, so every transport stays on the service's anonymous
client; a later patch lets an administrator's BPF program supply it.
The table is touched only when a connection is accepted and when a
client's last transport is freed; dispatch will follow the transport's
xpt_client pointer, which is set before the transport can be enqueued
(it is still XPT_BUSY from svc_xprt_init()) and is kept alive by the
transport's reference.  Each client carries a per-pool lwq of its ready
transports and a node for the pool's queue of clients, unused as yet.

Listeners, UDP sockets, transports of no class, and accepted transports
for which no client can be allocated are bound to the anonymous client.

Dispatch is unchanged by this patch.

Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h      |  43 +++++++++++++
 include/linux/sunrpc/svc_xprt.h |   8 +++
 net/sunrpc/svc.c                |  34 ++++++++++
 net/sunrpc/svc_xprt.c           | 108 ++++++++++++++++++++++++++++++++
 4 files changed, 193 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index dfadea50e0c6..e45f4fdea20b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -58,6 +58,44 @@ enum {
 	SP_TASK_STARTING,	/* Task has started but not added to idle yet */
 };
 
+/*
+ * A group of transports that share turns at the service: those of one
+ * class in one network namespace, or of one peer address within a class.
+ * Ready transports are queued per client and per pool, and a pool
+ * dispatches round-robin across its queued clients, so a client's share
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
+	u32			cl_class;
+	struct sockaddr_storage	cl_addr;	/* with SVC_CLASS_PER_ADDR; port ignored */
+	struct svc_client_pool	cl_pool[];	/* one per pool */
+};
+
+#define SVC_CLIENT_HASH_BITS	8
+
+/*
+ * Classes returned by svc_classify().  SVC_CLASS_NONE leaves the transport
+ * on the service's anonymous client; any other value names a client shared
+ * by every transport of that class, or, with SVC_CLASS_PER_ADDR set, one
+ * client per peer address within the class.
+ */
+#define SVC_CLASS_NONE		0
+#define SVC_CLASS_PER_ADDR	BIT_U32(31)
+
 
 struct svc_rqst;
 
@@ -96,6 +134,10 @@ struct svc_serv {
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	int			(*sv_threadfn)(void *data);
 
+	spinlock_t		sv_client_lock;	/* protects sv_client_hash */
+	struct hlist_head	sv_client_hash[1 << SVC_CLIENT_HASH_BITS];
+	struct svc_client	*sv_anon_client; /* transports without a peer */
+
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct lwq		sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -503,6 +545,7 @@ void		   svc_reserve(struct svc_rqst *rqstp, int space);
 void		   svc_pool_wake_idle_thread(struct svc_pool *pool);
 struct svc_pool   *svc_pool_for_cpu(struct svc_serv *serv);
 unsigned int	   svc_serv_nrpools(const struct svc_serv *serv);
+struct svc_client *svc_client_alloc(unsigned int nrpools, gfp_t gfp);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 const char *	   svc_proc_name(const struct svc_rqst *rqstp);
 int		   svc_encode_result_payload(struct svc_rqst *rqstp,
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 7176c42f19d7..d4f6dd5c8db3 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,6 +63,7 @@ struct svc_xprt {
 	unsigned long		xpt_flags;
 
 	struct svc_serv		*xpt_server;	/* service for transport */
+	struct svc_client	*xpt_client;	/* peer this transport belongs to */
 	atomic_t		xpt_reserved;	/* outq space rsvd, UDP only */
 	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
@@ -177,6 +178,13 @@ int	svc_xprt_create(struct svc_serv *serv, const char *xprt_name,
 void	svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 			     bool unregister);
 void	svc_xprt_received(struct svc_xprt *xprt);
+
+/* The class of an accepted transport; SVC_CLASS_* in svc.h. */
+static inline u32 svc_classify(const struct svc_xprt *xprt)
+{
+	return SVC_CLASS_NONE;
+}
+
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
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
index 9858dfcb846a..c7da55335506 100644
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
@@ -167,6 +170,107 @@ void svc_xprt_deferred_close(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_deferred_close);
 
+static unsigned int svc_client_hash(const struct net *net, u32 class,
+				    const struct sockaddr *sa)
+{
+	u32 h = hash_ptr(net, 32) ^ class;
+
+	if (class & SVC_CLASS_PER_ADDR) {
+		switch (sa->sa_family) {
+		case AF_INET:
+			h = __ipv4_addr_hash(((const struct sockaddr_in *)sa)->sin_addr.s_addr, h);
+			break;
+		case AF_INET6:
+			h = __ipv6_addr_jhash(&((const struct sockaddr_in6 *)sa)->sin6_addr, h);
+			break;
+		}
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
+					  const struct net *net, u32 class,
+					  const struct sockaddr *sa)
+{
+	struct svc_client *cl;
+
+	hlist_for_each_entry(cl, head, cl_hash)
+		if (cl->cl_net == net && cl->cl_class == class &&
+		    (!(class & SVC_CLASS_PER_ADDR) ||
+		     rpc_cmp_addr((struct sockaddr *)&cl->cl_addr, sa)) &&
+		    refcount_inc_not_zero(&cl->cl_ref))
+			return cl;
+	return NULL;
+}
+
+/*
+ * Bind @xprt to the client for its class.  Runs once per accepted
+ * transport, in process context, while the transport is still XPT_BUSY
+ * from svc_xprt_init(), so no enqueue can see the pointer change.  A
+ * transport of no class, one keyed by an address that is not IP, or one
+ * for which no client can be allocated, stays on the service's anonymous
+ * client.
+ */
+static void svc_client_bind(struct svc_serv *serv, struct svc_xprt *xprt)
+{
+	struct sockaddr *sa = (struct sockaddr *)&xprt->xpt_remote;
+	struct svc_client *cl, *new = NULL;
+	struct net *net = xprt->xpt_net;
+	struct hlist_head *head;
+	u32 class;
+
+	class = svc_classify(xprt);
+	if (class == SVC_CLASS_NONE)
+		return;
+	if ((class & SVC_CLASS_PER_ADDR) &&
+	    sa->sa_family != AF_INET && sa->sa_family != AF_INET6)
+		return;
+	head = &serv->sv_client_hash[svc_client_hash(net, class, sa)];
+
+	spin_lock_bh(&serv->sv_client_lock);
+	cl = svc_client_find(head, net, class, sa);
+	spin_unlock_bh(&serv->sv_client_lock);
+	if (!cl) {
+		new = svc_client_alloc(svc_serv_nrpools(serv), GFP_KERNEL);
+		if (!new)
+			return;
+		new->cl_net = net;
+		new->cl_class = class;
+		if (class & SVC_CLASS_PER_ADDR)
+			memcpy(&new->cl_addr, sa, xprt->xpt_remotelen);
+
+		spin_lock_bh(&serv->sv_client_lock);
+		cl = svc_client_find(head, net, class, sa);
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
@@ -176,6 +280,7 @@ static void svc_xprt_free(struct kref *kref)
 	trace_svc_xprt_free(xprt);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
+	svc_client_put(xprt->xpt_server, xprt->xpt_client);
 	put_cred(xprt->xpt_cred);
 	put_net_track(xprt->xpt_net, &xprt->ns_tracker);
 	/* See comment on corresponding get in xs_setup_bc_tcp(): */
@@ -213,6 +318,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	xprt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xprt->xpt_ref);
 	xprt->xpt_server = serv;
+	xprt->xpt_client = svc_client_get(serv->sv_anon_client);
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
 	INIT_LIST_HEAD(&xprt->xpt_users);
@@ -836,6 +942,8 @@ static bool svc_thread_wait_for_work(struct svc_rqst *rqstp, long timeo)
 
 static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
 {
+	svc_client_bind(serv, newxpt);
+
 	spin_lock_bh(&serv->sv_lock);
 	set_bit(XPT_TEMP, &newxpt->xpt_flags);
 	list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
-- 
2.53.0

