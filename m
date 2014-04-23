Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52752 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997AbaDWDst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2014 23:48:49 -0400
From: NeilBrown <neilb@suse.de>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 Apr 2014 12:40:58 +1000
Subject: [PATCH 4/5] SUNRPC: track when a client connection is routed to the
 local host.
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-ID: <20140423024058.4725.7703.stgit@notabene.brown>
In-Reply-To: <20140423022441.4725.89693.stgit@notabene.brown>
References: <20140423022441.4725.89693.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If requests are being sent to the local host, then NFS will
need to take care to avoid deadlocks.

So keep track when accepting a connection or sending a UDP request
and set a flag in the svc_xprt when the peer connected to is local.

The interface rpc_is_foreign() is provided to check is a given client
is connected to a foreign server.  When it returns zero it is either
not connected or connected to a local server and in either case
greater care is needed.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/clnt.h |    1 +
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |   25 +++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       |   17 +++++++++++++++++
 4 files changed, 44 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8af2804bab16..5d626cc5ab01 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -173,6 +173,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
+int		rpc_is_foreign(struct rpc_clnt *);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8097b9df6773..318ee37bc358 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -340,6 +340,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
+#define XPRT_LOCAL		(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada973434..454cea69b373 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1109,6 +1109,31 @@ const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
 
+/**
+ * rpc_is_foreign - report is rpc client was recently connected to
+ *                  remote host
+ * @clnt: RPC client structure
+ *
+ * If the client is not connected, or connected to the local host
+ * (any IP address), then return 0.  Only return non-zero if the
+ * most recent state was a connection to a remote host.
+ * For UDP the client always appears to be connected, and the
+ * remoteness of the host is of the destination of the last transmission.
+ */
+int rpc_is_foreign(struct rpc_clnt *clnt)
+{
+	struct rpc_xprt *xprt;
+	int conn_foreign;
+
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
+	conn_foreign = (xprt && xprt_connected(xprt)
+			&& !test_bit(XPRT_LOCAL, &xprt->state));
+	rcu_read_unlock();
+	return conn_foreign;
+}
+EXPORT_SYMBOL_GPL(rpc_is_foreign);
+
 static const struct sockaddr_in rpc_inaddr_loopback = {
 	.sin_family		= AF_INET,
 	.sin_addr.s_addr	= htonl(INADDR_ANY),
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0addefca8e77..74796cf37d5b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -642,6 +642,15 @@ static int xs_udp_send_request(struct rpc_task *task)
 			xdr->len - req->rq_bytes_sent, status);
 
 	if (status >= 0) {
+		struct dst_entry *dst;
+		rcu_read_lock();
+		dst = rcu_dereference(transport->sock->sk->sk_dst_cache);
+		if (dst && dst->dev && (dst->dev->features & NETIF_F_LOOPBACK))
+			set_bit(XPRT_LOCAL, &xprt->state);
+		else
+			clear_bit(XPRT_LOCAL, &xprt->state);
+		rcu_read_unlock();
+
 		req->rq_xmit_bytes_sent += status;
 		if (status >= req->rq_slen)
 			return 0;
@@ -1527,6 +1536,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 static void xs_tcp_state_change(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
+	struct dst_entry *dst;
 
 	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt = xprt_from_sock(sk)))
@@ -1556,6 +1566,13 @@ static void xs_tcp_state_change(struct sock *sk)
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
+		rcu_read_lock();
+		dst = rcu_dereference(sk->sk_dst_cache);
+		if (dst && dst->dev && (dst->dev->features & NETIF_F_LOOPBACK))
+			set_bit(XPRT_LOCAL, &xprt->state);
+		else
+			clear_bit(XPRT_LOCAL, &xprt->state);
+		rcu_read_unlock();
 		spin_unlock(&xprt->transport_lock);
 		break;
 	case TCP_FIN_WAIT1:


