Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C46839449C
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:54:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048500; cv=none; b=GwQDs+nDzQAAdQfUS+ZoOvR741IgM/uNRYtXfp/vmhpQXQfKnuRuNAaQcVJYo1P9potiUdHl3+FbGpbB5+onoiozQ8jBLFzRu9m2Jut08XDMka55LifdtGWAbk7IsnvgfakVviNSUpp9ATEJQYPeESt9yEo8M0PXfqfHOKUa+RA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048500; c=relaxed/simple;
	bh=n9uOG22lQrxPzDJokP46c71XEofzd8SzwPCHZz1Ngk0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CmzeaQJJtXXLe9lTf2yolQxoRRLWrpRJlSBrZSHXYTxdtqXPS7nj8GZGYlMZkZlJnzgyBsEbYSGCrzx3LulLQoOQpAeoIlZYO5iWHjIOXsq4Nt7hqxS2LF5e4i9tISrv3U9nVVZWP7egpAFZL3P3hpaw/lgaVwCsnV8YFovIsoM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CFqyWT0W; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CFqyWT0W"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B12E41F00893;
	Thu, 10 Sep 2026 13:54:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048498;
	bh=2RXl3YyEIgLsJ33N4cCOZhcyn4MqZYghrKJGHtGTmVk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CFqyWT0W0YQPOOXd58s3175AImUHRq4e14kj1W+Ir7hdxG4zLpg0sszSLAZZfmY96
	 eiNhu+YR+WxxBnETiyqutMCFOv//u+ORf6jCdxj/r6HdiOkvjRZwmWdKfwyCIrgsj1
	 FDk6n8ndslo9ESwoaP8cJNEgVR/1XSDgbxoP6cVfGsHGEJ4uafHJB8Qs+7z56zEotp
	 xwclYjjbaoSJdKjgflMZGIs/+aYBNCo3XIamZEoZNgBc97ENsSY1iGZZ/hFvgjEvxM
	 wcd252fn1ot3XePMIbiQE73My324obrl2MHcXl6ihbUQGZZh3CmuPbH9agK9VViZj/
	 RXOGfTUzn2Alg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:41 -0400
Subject: [PATCH v3 01/12] SUNRPC: Assign a unique identifier to each
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-1-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=10392; i=cel@kernel.org;
 h=from:subject:message-id; bh=n9uOG22lQrxPzDJokP46c71XEofzd8SzwPCHZz1Ngk0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoravrYuJY4OJNabxFPTHPqo1yvaIQMNQ5pPuT
 zUoelF/+yyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2rwAKCRAzarMzb2Z/
 l2xrD/9nV25P/XoYt5kumjnQREV1j06SeDwDSG1F1y0GA7kByTNa9Z64DBxzqVpYWvCx7y8RusW
 71ZBWvX2UXTIRVhTWJjW55EEwokBx5firQXJ0EA465+GDL4eZdkFIxqD682UR77+KDY8gEhZCR8
 BwGhiAUHNRfQ0NJutWEaRXhMwE1RerTrkY2z32HN0w6FylE3JTGmidQEAN8pL4JW4i3/AzhzTwr
 iJ2FdZ4qk5NMx2boebpYnWaMZiQMyuNpQ2Va5r24E1giR6Z5WpH+SnGIUhd+tMce0/kRUMC2ObN
 qtV1ZZRrqHp51o55dzi3+e4U7HuQPc+RgIdj5W5Vc1fu4kD42JPeXm+7ptOe3F8eIR1LEGBYKfY
 wSvXeVoHmbEiol/OSuJ5+LvCoCqTcQLhQ5GZeh24lLM8wZbcR30DdJobv+JCrOLvU06ufAtRfhi
 tUs1UTHTMH6HBh3BySoRa4DI+J58ae4JCzwYwd3p/Uw2/SmSvtwoeeje9tUBsqLqgpheSu6zTSU
 Pd39LQ1QDbK40n8sxmjiKJ1XgXTQUufuGzJXymAZlro/c5dVONSweBS/FetjK/eEABAlHY7oAfv
 QkE+c2OsAzz8kGvsHzv3twhm0jjFFBYqGIWgvdW6BEap6g2l2gdpE23ruVy93AHC4HTml+lei7X
 VkGNJks+cFyKi5w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A consumer that associates state with a transport without holding a
reference cannot detect ABA collisions: once a transport is freed,
SLUB may hand out a new svc_xprt at the same address.

Allocate a per-netns identifier for each transport in svc_xprt_init()
with xa_alloc_cyclic(), which delays reuse of an identifier after its
transport is freed. svc_xprt_init() now returns a boolean, and its
callers unwind when allocation fails. The NFSD duplicate reply cache
is the first consumer.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h          |  3 ++-
 include/trace/events/sunrpc.h            |  8 +++++--
 net/sunrpc/netns.h                       |  4 ++++
 net/sunrpc/sunrpc_syms.c                 |  2 ++
 net/sunrpc/svc_xprt.c                    | 39 ++++++++++++++++++++++++++++----
 net/sunrpc/svcsock.c                     | 33 +++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  5 +++-
 7 files changed, 75 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 2af222f3ea2c..c62f789e2900 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -56,6 +56,7 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	const struct svc_xprt_ops *xpt_ops;
 	struct kref		xpt_ref;
+	unsigned int		xpt_id;
 	ktime_t			xpt_qtime;
 	struct list_head	xpt_list;
 	struct lwq_node		xpt_ready;
@@ -162,7 +163,7 @@ static inline bool svc_xprt_is_dead(const struct svc_xprt *xprt)
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
-void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
+bool	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_xprt_create_from_sa(struct svc_serv *serv, const char *xprt_name,
 				struct net *net, struct sockaddr *sap,
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880d..180346e520ff 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1986,7 +1986,8 @@ TRACE_EVENT(svc_xprt_create_err,
 		__sockaddr(server, (x)->xpt_locallen) \
 		__sockaddr(client, (x)->xpt_remotelen) \
 		__field(unsigned long, flags) \
-		__field(unsigned int, netns_ino)
+		__field(unsigned int, netns_ino) \
+		__field(unsigned int, xpt_id)
 
 #define SVC_XPRT_ENDPOINT_ASSIGNMENTS(x) \
 		do { \
@@ -1996,13 +1997,15 @@ TRACE_EVENT(svc_xprt_create_err,
 					  (x)->xpt_remotelen); \
 			__entry->flags = (x)->xpt_flags; \
 			__entry->netns_ino = (x)->xpt_net->ns.inum; \
+			__entry->xpt_id = (x)->xpt_id; \
 		} while (0)
 
 #define SVC_XPRT_ENDPOINT_FORMAT \
-		"server=%pISpc client=%pISpc flags=%s"
+		"server=%pISpc client=%pISpc xpt_id=%u flags=%s"
 
 #define SVC_XPRT_ENDPOINT_VARARGS \
 		__get_sockaddr(server), __get_sockaddr(client), \
+		__entry->xpt_id, \
 		show_svc_xprt_flags(__entry->flags)
 
 TRACE_EVENT(svc_xprt_enqueue,
@@ -2024,6 +2027,7 @@ TRACE_EVENT(svc_xprt_enqueue,
 				  xprt->xpt_remotelen);
 		__entry->flags = flags;
 		__entry->netns_ino = xprt->xpt_net->ns.inum;
+		__entry->xpt_id = xprt->xpt_id;
 	),
 
 	TP_printk(SVC_XPRT_ENDPOINT_FORMAT, SVC_XPRT_ENDPOINT_VARARGS)
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 4efb5f28d881..9523d860be27 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -2,6 +2,7 @@
 #ifndef __SUNRPC_NETNS_H__
 #define __SUNRPC_NETNS_H__
 
+#include <linux/xarray.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -34,6 +35,9 @@ struct sunrpc_net {
 	atomic_t pipe_users;
 	struct proc_dir_entry *use_gssp_proc;
 	struct proc_dir_entry *gss_krb5_enctypes;
+
+	struct xarray	svc_xprt_ids;
+	u32		svc_xprt_id_next;
 };
 
 extern unsigned int sunrpc_net_id;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 1a3884a0376a..355404d541d4 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -58,6 +58,7 @@ static __net_init int sunrpc_init_net(struct net *net)
 	spin_lock_init(&sn->rpc_client_lock);
 	spin_lock_init(&sn->rpcb_clnt_lock);
 	mutex_init(&sn->gssp_lock);
+	xa_init_flags(&sn->svc_xprt_ids, XA_FLAGS_ALLOC1);
 	return 0;
 
 err_pipefs:
@@ -74,6 +75,7 @@ static __net_exit void sunrpc_exit_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
+	xa_destroy(&sn->svc_xprt_ids);
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d5634dd6d6cc..7e8ef4832421 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -21,6 +21,8 @@
 #include <linux/netdevice.h>
 #include <trace/events/sunrpc.h>
 
+#include "netns.h"
+
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
@@ -169,7 +171,10 @@ static void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
+	struct sunrpc_net *sn = net_generic(xprt->xpt_net, sunrpc_net_id);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+
+	xa_erase(&sn->svc_xprt_ids, xprt->xpt_id);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_cred(xprt->xpt_cred);
@@ -190,13 +195,28 @@ void svc_xprt_put(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_put);
 
-/*
- * Called by transport drivers to initialize the transport independent
- * portion of the transport instance.
+/**
+ * svc_xprt_init - initialize transport-independent portion of a transport
+ * @net: network namespace in which the transport operates
+ * @xcl: transport class providing operations and metadata
+ * @xprt: svc_xprt to initialize
+ * @serv: RPC service that owns this transport
+ *
+ * Assigns @xprt->xpt_id, unique among the transports live in @net. The
+ * id value can be reused once @xprt is freed.
+ *
+ * Context: Process context. May sleep.
+ *
+ * Return:
+ *   %true: initialization succeeded
+ *   %false: initialization failed
  */
-void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
+bool svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 		   struct svc_xprt *xprt, struct svc_serv *serv)
 {
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	u32 id;
+
 	memset(xprt, 0, sizeof(*xprt));
 	xprt->xpt_class = xcl;
 	xprt->xpt_ops = xcl->xcl_ops;
@@ -208,8 +228,17 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
-	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
+	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_KERNEL);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+
+	if (xa_alloc_cyclic(&sn->svc_xprt_ids, &id, xprt,
+			    XA_LIMIT(1, UINT_MAX), &sn->svc_xprt_id_next,
+			    GFP_KERNEL) < 0) {
+		put_net_track(xprt->xpt_net, &xprt->ns_tracker);
+		return false;
+	}
+	xprt->xpt_id = id;
+	return true;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e5459d504b6a..625aebbbc6b3 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -803,10 +803,11 @@ static struct svc_xprt_class svc_udp_class = {
 	.xcl_flags = SVC_XPRT_FLAG_WSPACE_RESERVE,
 };
 
-static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
+static bool svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
-	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_udp_class,
-		      &svsk->sk_xprt, serv);
+	if (!svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_udp_class,
+			   &svsk->sk_xprt, serv))
+		return false;
 	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	svsk->sk_sk->sk_data_ready = svc_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
@@ -833,6 +834,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	default:
 		BUG();
 	}
+	return true;
 }
 
 /*
@@ -1476,12 +1478,13 @@ void svc_cleanup_xprt_sock(void)
 	svc_unreg_xprt_class(&svc_udp_class);
 }
 
-static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
+static bool svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
 	struct sock	*sk = svsk->sk_sk;
 
-	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
-		      &svsk->sk_xprt, serv);
+	if (!svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
+			   &svsk->sk_xprt, serv))
+		return false;
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
@@ -1512,6 +1515,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 			svc_xprt_deferred_close(&svsk->sk_xprt);
 		}
 	}
+	return true;
 }
 
 void svc_sock_update_bufs(struct svc_serv *serv)
@@ -1603,13 +1607,22 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	inet->sk_user_data = svsk;
 
 	/* Initialize the socket */
-	if (sock->type == SOCK_DGRAM)
-		svc_udp_init(svsk, serv);
-	else
-		svc_tcp_init(svsk, serv);
+	if (sock->type == SOCK_DGRAM) {
+		if (!svc_udp_init(svsk, serv))
+			goto out_free;
+	} else {
+		if (!svc_tcp_init(svsk, serv))
+			goto out_free;
+	}
 
 	trace_svcsock_new(svsk, sock);
 	return svsk;
+
+out_free:
+	inet->sk_user_data = NULL;
+	kfree(svsk->sk_bvec);
+	kfree(svsk);
+	return ERR_PTR(-ENOMEM);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f949601b2144..610df78f9176 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -189,7 +189,10 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	if (!cma_xprt)
 		return NULL;
 
-	svc_xprt_init(net, &svc_rdma_class, &cma_xprt->sc_xprt, serv);
+	if (!svc_xprt_init(net, &svc_rdma_class, &cma_xprt->sc_xprt, serv)) {
+		kfree(cma_xprt);
+		return NULL;
+	}
 	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);

-- 
2.55.0

