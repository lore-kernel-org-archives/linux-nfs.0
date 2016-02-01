Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33253 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcBAElZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:25 -0500
Received: by mail-io0-f169.google.com with SMTP id f81so144117182iof.0
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 09/13] SUNRPC: Add a helper to apply a function to all the rpc_clnt's transports
Date: Sun, 31 Jan 2016 23:40:26 -0500
Message-Id: <1454301630-17358-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454301630-17358-9-git-send-email-trond.myklebust@primarydata.com>
References: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-2-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-3-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-4-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-5-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-7-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-8-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper for tasks that require us to apply a function to all the
transports in an rpc_clnt.
An example of a usecase would be BIND_CONN_TO_SESSION, where we want
to send one RPC call down each transport.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h |  4 ++++
 net/sunrpc/clnt.c           | 49 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 1713e41d65ae..d6510f64a361 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -182,6 +182,10 @@ size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
+int 		rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
+			int (*fn)(struct rpc_clnt *, struct rpc_xprt *, void *),
+			void *data);
+
 const char *rpc_proc_name(const struct rpc_task *task);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8e46fa5a2ab1..56b9c1419765 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -736,6 +736,55 @@ out_revert:
 }
 EXPORT_SYMBOL_GPL(rpc_switch_client_transport);
 
+static
+int rpc_clnt_xprt_iter_init(struct rpc_clnt *clnt, struct rpc_xprt_iter *xpi)
+{
+	struct rpc_xprt_switch *xps;
+
+	rcu_read_lock();
+	xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
+	rcu_read_unlock();
+	if (xps == NULL)
+		return -EAGAIN;
+	xprt_iter_init_listall(xpi, xps);
+	xprt_switch_put(xps);
+	return 0;
+}
+
+/**
+ * rpc_clnt_iterate_for_each_xprt - Apply a function to all transports
+ * @clnt - pointer to client
+ * @fn - function to apply
+ * @data - void pointer to function data
+ *
+ * Iterates through the list of RPC transports currently attached to the
+ * client and applies the function fn(clnt, xprt, data).
+ *
+ * On error, the iteration stops, and the function returns the error value.
+ */
+int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
+		int (*fn)(struct rpc_clnt *, struct rpc_xprt *, void *),
+		void *data)
+{
+	struct rpc_xprt_iter xpi;
+	int ret;
+
+	ret = rpc_clnt_xprt_iter_init(clnt, &xpi);
+	for (;;) {
+		struct rpc_xprt *xprt = xprt_iter_get_next(&xpi);
+
+		if (!xprt)
+			break;
+		ret = fn(clnt, xprt, data);
+		xprt_put(xprt);
+		if (ret < 0)
+			break;
+	}
+	xprt_iter_destroy(&xpi);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?
-- 
2.5.0

