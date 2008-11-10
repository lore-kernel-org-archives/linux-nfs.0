From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 67/85] nfs41: sunrpc: provide functions to create and destroy a svc_xprt for backchannel use
Date: Mon, 10 Nov 2008 22:30:11 +0200
Message-ID: <1226349011-9467-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60039 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbYKJUaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:30:17 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For nfs41 callbacks we need an svc_xprt to process requests coming up the
backchannel socket as rpc_rqst's that are transformed into svc_rqst's that
need a rq_xprt to be processed.

The svc_{udp,tcp}_create methods are too heavy for this job as svc_create_socket
creates an actual socket to listen on while for nfs41 we're "reusing" the
fore channel's socket.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svcsock.h |    2 ++
 net/sunrpc/svcsock.c           |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 483e103..6bb1ec4 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -42,6 +42,8 @@ int		svc_sock_names(char *buf, struct svc_serv *serv, char *toclose);
 int		svc_addsock(struct svc_serv *serv, int fd, char *name_return);
 void		svc_init_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
+struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
+void		svc_sock_destroy(struct svc_xprt *);
 
 /*
  * svc_makesock socket characteristics
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 95293f5..c2b6fa4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1298,3 +1298,42 @@ static void svc_sock_free(struct svc_xprt *xprt)
 		sock_release(svsk->sk_sock);
 	kfree(svsk);
 }
+
+/*
+ * Create a svc_xprt.
+ *
+ * For internal use only (e.g. nfsv4.1 backchannel).
+ * Callers should typically use the xpo_create() method.
+ */
+struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot)
+{
+	struct svc_sock *svsk;
+	struct svc_xprt *xprt = NULL;
+
+	dprintk("svc: %s\n", __func__);
+	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
+	if (!svsk)
+		goto out;
+
+	xprt = &svsk->sk_xprt;
+	if (prot == IPPROTO_TCP)
+		svc_xprt_init(&svc_tcp_class, xprt, serv);
+	else if (prot == IPPROTO_UDP)
+		svc_xprt_init(&svc_udp_class, xprt, serv);
+	else
+		BUG();
+out:
+	dprintk("svc: %s return %p\n", __func__, xprt);
+	return xprt;
+}
+EXPORT_SYMBOL_GPL(svc_sock_create);
+
+/*
+ * Destroy a svc_sock.
+ */
+void svc_sock_destroy(struct svc_xprt *xprt)
+{
+	if (xprt)
+		kfree(container_of(xprt, struct svc_sock, sk_xprt));
+}
+EXPORT_SYMBOL_GPL(svc_sock_destroy);
-- 
1.6.0.2

