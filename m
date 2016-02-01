Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37965 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbcBAEl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:29 -0500
Received: by mail-ig0-f179.google.com with SMTP id mw1so25144401igb.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:28 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 12/13] SUNRPC: Allow addition of new transports to a struct rpc_clnt
Date: Sun, 31 Jan 2016 23:40:29 -0500
Message-Id: <1454301630-17358-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454301630-17358-12-git-send-email-trond.myklebust@primarydata.com>
References: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-2-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-3-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-4-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-5-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-7-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-8-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-9-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-10-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-11-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a function to allow creation and addition of a new transport
to an existing rpc_clnt

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h |  11 ++++
 net/sunrpc/clnt.c           | 133 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 142 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index d6510f64a361..9a7ddbaf116e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -186,6 +186,17 @@ int 		rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 			int (*fn)(struct rpc_clnt *, struct rpc_xprt *, void *),
 			void *data);
 
+int 		rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
+			struct rpc_xprt_switch *xps,
+			struct rpc_xprt *xprt,
+			void *dummy);
+int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
+			int (*setup)(struct rpc_clnt *,
+				struct rpc_xprt_switch *,
+				struct rpc_xprt *,
+				void *),
+			void *data);
+
 const char *rpc_proc_name(const struct rpc_task *task);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3a4c00e683bd..f1a4ba8ac103 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2490,7 +2490,10 @@ static int rpc_ping(struct rpc_clnt *clnt)
 	return err;
 }
 
-struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags)
+static
+struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt, struct rpc_cred *cred, int flags,
+		const struct rpc_call_ops *ops, void *data)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &rpcproc_null,
@@ -2498,14 +2501,140 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
+		.rpc_xprt = xprt,
 		.rpc_message = &msg,
-		.callback_ops = &rpc_default_ops,
+		.callback_ops = (ops != NULL) ? ops : &rpc_default_ops,
+		.callback_data = data,
 		.flags = flags,
 	};
+
 	return rpc_run_task(&task_setup_data);
 }
+
+struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags)
+{
+	return rpc_call_null_helper(clnt, NULL, cred, flags, NULL, NULL);
+}
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
+struct rpc_cb_add_xprt_calldata {
+	struct rpc_xprt_switch *xps;
+	struct rpc_xprt *xprt;
+};
+
+static void rpc_cb_add_xprt_done(struct rpc_task *task, void *calldata)
+{
+	struct rpc_cb_add_xprt_calldata *data = calldata;
+
+	if (task->tk_status == 0)
+		rpc_xprt_switch_add_xprt(data->xps, data->xprt);
+}
+
+static void rpc_cb_add_xprt_release(void *calldata)
+{
+	struct rpc_cb_add_xprt_calldata *data = calldata;
+
+	xprt_put(data->xprt);
+	xprt_switch_put(data->xps);
+	kfree(data);
+}
+
+const static struct rpc_call_ops rpc_cb_add_xprt_call_ops = {
+	.rpc_call_done = rpc_cb_add_xprt_done,
+	.rpc_release = rpc_cb_add_xprt_release,
+};
+
+/**
+ * rpc_clnt_test_and_add_xprt - Test and add a new transport to a rpc_clnt
+ * @clnt - pointer to struct rpc_clnt
+ * @xps - pointer to struct rpc_xprt_switch,
+ * @xprt - pointer struct rpc_xprt
+ * @dummy
+ */
+int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
+		struct rpc_xprt_switch *xps, struct rpc_xprt *xprt,
+		void *dummy)
+{
+	struct rpc_cb_add_xprt_calldata *data;
+	struct rpc_cred *cred;
+	struct rpc_task *task;
+
+	data = kmalloc(sizeof(*data), GFP_NOFS);
+	if (!data)
+		return -ENOMEM;
+	data->xps = xprt_switch_get(xps);
+	data->xprt = xprt_get(xprt);
+
+	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
+	task = rpc_call_null_helper(clnt, xprt, cred,
+			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
+			&rpc_cb_add_xprt_call_ops, data);
+	put_rpccred(cred);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 1;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
+
+/**
+ * rpc_clnt_add_xprt - Add a new transport to a rpc_clnt
+ * @clnt - pointer to struct rpc_clnt
+ * @args - pointer to struct xprt_create
+ * @setup - callback to test and/or set up the connection
+ * @data - pointer to setup function data
+ *
+ * Creates a new transport using the parameters set in args and
+ * adds it to clnt.
+ * If ping is set, then test that connectivity succeeds before
+ * adding the new transport.
+ *
+ */
+int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
+		struct xprt_create *xprtargs,
+		int (*setup)(struct rpc_clnt *,
+			struct rpc_xprt_switch *,
+			struct rpc_xprt *,
+			void *),
+		void *data)
+{
+	struct rpc_xprt_switch *xps;
+	struct rpc_xprt *xprt;
+	unsigned char resvport;
+	int ret = 0;
+
+	rcu_read_lock();
+	xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
+	xprt = xprt_iter_xprt(&clnt->cl_xpi);
+	if (xps == NULL || xprt == NULL) {
+		rcu_read_unlock();
+		return -EAGAIN;
+	}
+	resvport = xprt->resvport;
+	rcu_read_unlock();
+
+	xprt = xprt_create_transport(xprtargs);
+	if (IS_ERR(xprt)) {
+		ret = PTR_ERR(xprt);
+		goto out_put_switch;
+	}
+	xprt->resvport = resvport;
+
+	rpc_xprt_switch_set_roundrobin(xps);
+	if (setup) {
+		ret = setup(clnt, xps, xprt, data);
+		if (ret != 0)
+			goto out_put_xprt;
+	}
+	rpc_xprt_switch_add_xprt(xps, xprt);
+out_put_xprt:
+	xprt_put(xprt);
+out_put_switch:
+	xprt_switch_put(xps);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_add_xprt);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
-- 
2.5.0

