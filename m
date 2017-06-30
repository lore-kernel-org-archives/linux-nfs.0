Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:31 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 09/14] SUNRPC: add AF_VSOCK backchannel support
Date: Fri, 30 Jun 2017 14:23:47 +0100
Message-Id: <20170630132352.32133-10-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c  | 27 +++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c | 25 +++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 394e7a2..0c09f3f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1236,14 +1236,41 @@ static struct svc_xprt_class svc_tcp_bc_class = {
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+static void svc_bc_vsock_sock_detach(struct svc_xprt *xprt)
+{
+}
+
+static struct svc_xprt_ops svc_vsock_bc_ops = {
+	.xpo_create = svc_bc_create_socket,
+	.xpo_detach = svc_bc_vsock_sock_detach,
+	.xpo_free = svc_bc_sock_free,
+	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_secure_port = svc_sock_secure_port,
+};
+
+static struct svc_xprt_class svc_vsock_bc_class = {
+	.xcl_name = "vsock-bc",
+	.xcl_owner = THIS_MODULE,
+	.xcl_ops = &svc_vsock_bc_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD,
+};
+#endif /* CONFIG_SUNRPC_XPRT_VSOCK */
+
 static void svc_init_bc_xprt_sock(void)
 {
 	svc_reg_xprt_class(&svc_tcp_bc_class);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	svc_reg_xprt_class(&svc_vsock_bc_class);
+#endif
 }
 
 static void svc_cleanup_bc_xprt_sock(void)
 {
 	svc_unreg_xprt_class(&svc_tcp_bc_class);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	svc_unreg_xprt_class(&svc_vsock_bc_class);
+#endif
 }
 #else /* CONFIG_SUNRPC_BACKCHANNEL */
 static void svc_init_bc_xprt_sock(void)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cc343b91..ccadb3a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1430,6 +1430,24 @@ static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 {
 	return PAGE_SIZE;
 }
+
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+static int xs_vsock_bc_up(struct svc_serv *serv, struct net *net)
+{
+	int ret;
+
+	ret = svc_create_xprt(serv, "vsock-bc", net, AF_VSOCK, 0,
+			      SVC_SOCK_ANONYMOUS);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static size_t xs_vsock_bc_maxpayload(struct rpc_xprt *xprt)
+{
+	return PAGE_SIZE;
+}
+#endif /* !CONFIG_SUNRPC_XPRT_VSOCK */
 #else
 static inline int _xs_stream_read_data(struct rpc_xprt *xprt,
 				       struct xdr_skb_reader *desc)
@@ -3494,6 +3512,13 @@ static struct rpc_xprt_ops xs_vsock_ops = {
 	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_vsock_print_stats,
+#ifdef CONFIG_SUNRPC_BACKCHANNEL
+	.bc_setup		= xprt_setup_bc,
+	.bc_up			= xs_vsock_bc_up,
+	.bc_maxpayload		= xs_vsock_bc_maxpayload,
+	.bc_free_rqst		= xprt_free_bc_rqst,
+	.bc_destroy		= xprt_destroy_bc,
+#endif
 };
 
 static const struct rpc_timeout xs_vsock_default_timeout = {
-- 
2.9.4

