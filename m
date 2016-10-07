Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752385AbcJGKGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:06:51 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2 09/10] SUNRPC: add AF_VSOCK backchannel support
Date: Fri,  7 Oct 2016 11:01:53 +0100
Message-Id: <1475834514-4058-10-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c  | 27 +++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c | 25 +++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7c14028..857c38e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1204,14 +1204,41 @@ static struct svc_xprt_class svc_tcp_bc_class = {
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
index c61a0ed..27df0e2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1416,6 +1416,24 @@ static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
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
@@ -3424,6 +3442,13 @@ static struct rpc_xprt_ops xs_vsock_ops = {
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
2.7.4

