Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FEE0348C4C
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933886; cv=none; b=UXKBQHq1RACYdo/5Mbsyu6wVmQi0dA5+ynP/+SILaBqxAHDYri4EVN//1gdSKszGv94shO0Zk9XSXRDpPbeMerFapSckla2vraWt314egmpfLwtsPLwkh0r94urwJbR8H1lK074gWQxh+BqOoQrJNG9v55I1CLrDFjRUXunZ90A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933886; c=relaxed/simple;
	bh=ltUgoS8cP9U9bjof7LwUKKw2ZUuWylZFdmnqlAsx37Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WRMbtxCGz+FzyaoA6UMtaC+PqkYSp7gPPwFUoi0CecGkR4ObaCCgPPL4ukYjCIesLEgK9OXSRzJ2WSwEisSyJWV2BlnyF8GSeTetkl38Mq1H10FDR6EOh+mAyK+VcVkHNGf+nRE1ITqQn92DVrre+wIxc3m/8llVMujkz9Z1tgY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VjNfKGtO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VjNfKGtO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F10F1F00A3F;
	Fri, 28 Aug 2026 16:18:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933884;
	bh=WImTz6yCsiZHWgudOLUPR0aFLXxjOA0EAF2DjEX4ABA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VjNfKGtONtIVPZRAAoRNxRP+RZ3RLhNT0obkPdtKD/G7ixuJp6JTGoYj5XhaP2vDS
	 TbOsr9GO4Kqkpi1jQrDvpM4hdAR9XkpMvG1j15nW+PMcPmapZKJ34EayioCVWp0Cmx
	 iCGkIwmHm/4rrYjw4O6hZpaEeoQpIwEzefZUAVu4jngYajFqHRqtoC4TDOivFxV/B2
	 YD0d3+4h/nj0+RS6A5CCcbAgeZHftSOct3rjTPKU3wrZqjkghkLlPNyUtgVXDToTqb
	 7LqpnGebtOhA9yAvcY2/t60DvS9O3xcxBbGpfX618WSSMs9OnpdxyhXxia2Z187Rab
	 1nrd7wqe5wvAg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:53 -0400
Subject: [PATCH v2 1/7] SUNRPC: Assign a unique identifier to each svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-1-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=11446; i=cel@kernel.org;
 h=from:subject:message-id; bh=ltUgoS8cP9U9bjof7LwUKKw2ZUuWylZFdmnqlAsx37Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS68aSNahOF1UKxy5/Nf3YoWNJxXexqSjo1A
 462ZTRouWmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0ugAKCRAzarMzb2Z/
 l7odD/4h5qZPiuK5+2yNjPNTztdOUMdqTd31+idJ5anrmO7bS9+2mNcb15IDUu8o0abrYgsEj29
 TG0moSR+bQBCxmL3/oxHblrArsQa6fyiXvyfKMO2NOvf7wWl8NhKNNpNGu7ojzQf9ZEcKFrOoZ4
 QaJEresEBvmFcgR4nhUqUEG0PNywIcCxQ+FBAyp5DkRPoksGLqbaNSu+sPUsLb3M23sm+G61OQs
 8y326Bp5nsnTDCE9dQGqWw4tesKlEh/4god1o3NPL1CPvFdjKo70SzgAh+h0j3G8B1mx65UXEL0
 r/zQaqT8ELoHJx/XCHlL4Xbml6vChaGQvbzpND1G0oDX9OgN9RnaALgkSPgebgq1bbBgUbDfPjh
 znOwQPn1XKNtiwk9QhotJEiL3Uhbzi61JYf8U9YQBmMlUgPVYdDJVMnBa+hlRXTlim3MCSjfqn4
 RQn11XE6CTz4JeTnc1y/NTuaTLFZWX581vWYaf3qc3lnpGqO3vm9FuWoBmgReGlNobIeRNJPUsL
 N6VF0mICo1RknPbt/GEreiKVEC4CpqS6rDyi/nHma7L5QN807ivY7qrMMefesaZvDlOfWRyKym4
 4cCNeWbSCioQ1LzRW3F7L+0uxbk99iUP0rcpv7Ncek4W8UqGtg3DWgSiBP06bSJ57Mv+anaG/DI
 JQqw7vp1qePkp+A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A consumer that associates state with a transport without holding a
reference cannot detect ABA collisions: once a transport is freed,
SLUB may hand out a new svc_xprt at the same address.

Allocate a per-netns identifier for each transport in svc_xprt_init()
from a cyclic IDR, which delays reuse of an identifier after its
transport is freed. svc_xprt_init() now returns a boolean, and its
callers unwind when allocation fails. The NFSD duplicate reply cache
is the first consumer.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h          |  3 +-
 include/trace/events/sunrpc.h            |  8 ++++--
 net/sunrpc/netns.h                       |  4 +++
 net/sunrpc/sunrpc_syms.c                 |  3 ++
 net/sunrpc/svc_xprt.c                    | 47 ++++++++++++++++++++++++++++----
 net/sunrpc/svcsock.c                     | 40 +++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  5 +++-
 7 files changed, 89 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index da2a2531e110..88d73da5f46f 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -53,6 +53,7 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	const struct svc_xprt_ops *xpt_ops;
 	struct kref		xpt_ref;
+	unsigned int		xpt_id;
 	ktime_t			xpt_qtime;
 	struct list_head	xpt_list;
 	struct lwq_node		xpt_ready;
@@ -159,7 +160,7 @@ static inline bool svc_xprt_is_dead(const struct svc_xprt *xprt)
 
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
index 4efb5f28d881..53432d759ae8 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -2,6 +2,7 @@
 #ifndef __SUNRPC_NETNS_H__
 #define __SUNRPC_NETNS_H__
 
+#include <linux/idr.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -34,6 +35,9 @@ struct sunrpc_net {
 	atomic_t pipe_users;
 	struct proc_dir_entry *use_gssp_proc;
 	struct proc_dir_entry *gss_krb5_enctypes;
+
+	struct idr	svc_xprt_ids;
+	spinlock_t	svc_xprt_ids_lock;
 };
 
 extern unsigned int sunrpc_net_id;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 1a3884a0376a..d9ddf5b716cc 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -58,6 +58,8 @@ static __net_init int sunrpc_init_net(struct net *net)
 	spin_lock_init(&sn->rpc_client_lock);
 	spin_lock_init(&sn->rpcb_clnt_lock);
 	mutex_init(&sn->gssp_lock);
+	idr_init(&sn->svc_xprt_ids);
+	spin_lock_init(&sn->svc_xprt_ids_lock);
 	return 0;
 
 err_pipefs:
@@ -74,6 +76,7 @@ static __net_exit void sunrpc_exit_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
+	idr_destroy(&sn->svc_xprt_ids);
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb..ca10ef965443 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -21,6 +21,8 @@
 #include <linux/netdevice.h>
 #include <trace/events/sunrpc.h>
 
+#include "netns.h"
+
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
@@ -167,7 +169,12 @@ static void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
+	struct sunrpc_net *sn = net_generic(xprt->xpt_net, sunrpc_net_id);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+
+	spin_lock(&sn->svc_xprt_ids_lock);
+	idr_remove(&sn->svc_xprt_ids, xprt->xpt_id);
+	spin_unlock(&sn->svc_xprt_ids_lock);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_cred(xprt->xpt_cred);
@@ -188,13 +195,31 @@ void svc_xprt_put(struct svc_xprt *xprt)
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
+ * value is reused once @xprt is freed.
+ *
+ * On failure, the caller has only to free @xprt's containing structure.
+ *
+ * Context: Process context. May sleep. Takes and releases the
+ *          per-net svc_xprt_ids_lock.
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
+	int id;
+
 	memset(xprt, 0, sizeof(*xprt));
 	xprt->xpt_class = xcl;
 	xprt->xpt_ops = xcl->xcl_ops;
@@ -206,8 +231,20 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
-	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
+	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_KERNEL);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+
+	idr_preload(GFP_KERNEL);
+	spin_lock(&sn->svc_xprt_ids_lock);
+	id = idr_alloc_cyclic(&sn->svc_xprt_ids, xprt, 1, 0, GFP_NOWAIT);
+	spin_unlock(&sn->svc_xprt_ids_lock);
+	idr_preload_end();
+	if (id < 0) {
+		put_net_track(xprt->xpt_net, &xprt->ns_tracker);
+		return false;
+	}
+	xprt->xpt_id = id;
+	return true;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ef7ac080fcd3..840bec53e1ee 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -802,10 +802,11 @@ static struct svc_xprt_class svc_udp_class = {
 	.xcl_ident = XPRT_TRANSPORT_UDP,
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
@@ -832,6 +833,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	default:
 		BUG();
 	}
+	return true;
 }
 
 /*
@@ -1475,12 +1477,13 @@ void svc_cleanup_xprt_sock(void)
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
@@ -1511,6 +1514,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 			svc_xprt_deferred_close(&svsk->sk_xprt);
 		}
 	}
+	return true;
 }
 
 void svc_sock_update_bufs(struct svc_serv *serv)
@@ -1553,6 +1557,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
 	int		sendpages;
 	unsigned long	pages;
+	int		err;
 
 	sendpages = svc_sock_sendpages(serv, sock, flags);
 	if (sendpages < 0)
@@ -1576,8 +1581,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	inet = sock->sk;
 
 	if (pmap_register) {
-		int err;
-
 		err = svc_register(serv, sock_net(sock->sk), inet->sk_family,
 				     inet->sk_protocol,
 				     ntohs(inet_sk(inet)->inet_sport));
@@ -1602,13 +1605,26 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
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
+	/* Port zero asks rpcbind to UNSET the registration made above. */
+	if (pmap_register)
+		svc_register(serv, sock_net(sock->sk), inet->sk_family,
+			     inet->sk_protocol, 0);
+	inet->sk_user_data = NULL;
+	kfree(svsk->sk_bvec);
+	kfree(svsk);
+	return ERR_PTR(-ENOMEM);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 093371f9d245..fabdfd891a41 100644
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

