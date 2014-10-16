Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:57339 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaJPTjx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:39:53 -0400
Received: by mail-ig0-f169.google.com with SMTP id uq10so1668001igb.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:39:53 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id m7sm14808984igj.18.2014.10.16.12.39.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:39:52 -0700 (PDT)
Subject: [PATCH v1 12/16] SUNRPC: Add rpc_xprt_is_bidirectional()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:39:52 -0400
Message-ID: <20141016193952.13414.82769.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow upper layers to determine if a particular rpc_clnt is prepared
to provide a backchannel RPC service.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h |    1 +
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |   24 ++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       |    3 +++
 4 files changed, 29 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 70736b9..644c751 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -171,6 +171,7 @@ int		rpc_protocol(struct rpc_clnt *);
 struct net *	rpc_net_ns(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
 unsigned long	rpc_get_timeout(struct rpc_clnt *clnt);
+bool		rpc_xprt_is_bidirectional(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 632685c..4dea441 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -218,6 +218,7 @@ struct rpc_xprt {
 						 * items */
 	struct list_head	bc_pa_list;	/* List of preallocated
 						 * backchannel rpc_rqst's */
+	bool			bc_supported;
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 	struct list_head	recv;
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5e817d6..1793341 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1347,6 +1347,30 @@ unsigned long rpc_get_timeout(struct rpc_clnt *clnt)
 EXPORT_SYMBOL_GPL(rpc_get_timeout);
 
 /**
+ * rpc_xprt_is_bidirectional
+ * @clnt: RPC clnt to query
+ *
+ * Returns true if underlying transport supports backchannel service.
+ */
+#ifdef CONFIG_SUNRPC_BACKCHANNEL
+bool rpc_xprt_is_bidirectional(struct rpc_clnt *clnt)
+{
+	bool ret;
+
+	rcu_read_lock();
+	ret = rcu_dereference(clnt->cl_xprt)->bc_supported;
+	rcu_read_unlock();
+	return ret;
+}
+#else
+bool rpc_xprt_is_bidirectional(struct rpc_clnt *clnt)
+{
+	return false;
+}
+#endif
+EXPORT_SYMBOL_GPL(rpc_xprt_is_bidirectional);
+
+/**
  * rpc_force_rebind - force transport to check that remote port is unchanged
  * @clnt: client to rebind
  *
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b4aca48..e2e15a9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2864,6 +2864,9 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 	xprt->ops = &xs_tcp_ops;
 	xprt->timeout = &xs_tcp_default_timeout;
+#ifdef CONFIG_SUNRPC_BACKCHANNEL
+	xprt->bc_supported = true;
+#endif
 
 	switch (addr->sa_family) {
 	case AF_INET:

