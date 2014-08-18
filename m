Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52117 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbaHRGYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 02:24:46 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 18 Aug 2014 16:22:54 +1000
Subject: [PATCH 1/2] SUNRPC: track when a client connection is routed to the
 local host.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140818062254.1449.26590.stgit@notabene.brown>
In-Reply-To: <20140818061727.1449.89101.stgit@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
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
 net/sunrpc/xprtsock.c       |    9 +++++++++
 4 files changed, 36 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 70736b98c721..cd79b2a28ceb 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -175,6 +175,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
+int		rpc_is_foreign(struct rpc_clnt *);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index fcbfe8783243..6a9dffcb9d3f 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -357,6 +357,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
+#define XPRT_LOCAL		(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 488ddeed9363..1559d03e468e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1117,6 +1117,31 @@ const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
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
index 43cd89eacfab..70942643e88c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -643,6 +643,11 @@ static int xs_udp_send_request(struct rpc_task *task)
 			xdr->len - req->rq_bytes_sent, status);
 
 	if (status >= 0) {
+		if (sock_is_loopback(transport->sock->sk))
+			set_bit(XPRT_LOCAL, &xprt->state);
+		else
+			clear_bit(XPRT_LOCAL, &xprt->state);
+
 		req->rq_xmit_bytes_sent += status;
 		if (status >= req->rq_slen)
 			return 0;
@@ -1550,6 +1555,10 @@ static void xs_tcp_state_change(struct sock *sk)
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
+		if (sock_is_loopback(sk))
+			set_bit(XPRT_LOCAL, &xprt->state);
+		else
+			clear_bit(XPRT_LOCAL, &xprt->state);
 		spin_unlock(&xprt->transport_lock);
 		break;
 	case TCP_FIN_WAIT1:


