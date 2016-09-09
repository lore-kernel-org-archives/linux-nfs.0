Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:22517 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752385AbcIINY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:26 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 09/12] SUNRPC: rpc_clnt_add_xprt setup function for NFS layer
Date: Fri, 9 Sep 2016 09:22:26 -0400
Message-ID: <1473427349-13265-10-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use a setup function to call into the NFS layer to test an rpc_xprt
for session trunking so as to not leak the rpc_xprt_switch into
the nfs layer.

Search for the address in the rpc_xprt_switch first so as not to
put an unnecessary EXCHANGE_ID on the wire.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h | 12 +++++++++
 net/sunrpc/clnt.c           | 64 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 35cc539..85cc819 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -125,6 +125,13 @@ struct rpc_create_args {
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
+struct rpc_add_xprt_test {
+	int (*add_xprt_test)(struct rpc_clnt *,
+		struct rpc_xprt *,
+		void *calldata);
+	void *data;
+};
+
 /* Values for "flags" field */
 #define RPC_CLNT_CREATE_HARDRTRY	(1UL << 0)
 #define RPC_CLNT_CREATE_AUTOBIND	(1UL << 2)
@@ -198,6 +205,11 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 void		rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
 			unsigned long timeo);
 
+int		rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *,
+			struct rpc_xprt_switch *,
+			struct rpc_xprt *,
+			void *);
+
 const char *rpc_proc_name(const struct rpc_task *task);
 
 void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 282a5e7..913a283 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2614,6 +2614,70 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
 
 /**
+ * rpc_clnt_setup_test_and_add_xprt()
+ *
+ * This is an rpc_clnt_add_xprt setup() function which returns 1 so:
+ *   1) caller of the test function must dereference the rpc_xprt_switch
+ *   and the rpc_xprt.
+ *   2) test function must call rpc_xprt_switch_add_xprt, usually in
+ *   the rpc_call_done routine.
+ *
+ * Upon success (return of 1), the test function adds the new
+ * transport to the rpc_clnt xprt switch
+ *
+ * @clnt: struct rpc_clnt to get the new transport
+ * @xps:  the rpc_xprt_switch to hold the new transport
+ * @xprt: the rpc_xprt to test
+ * @data: a struct rpc_add_xprt_test pointer that holds the test function
+ *        and test function call data
+ */
+int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
+				     struct rpc_xprt_switch *xps,
+				     struct rpc_xprt *xprt,
+				     void *data)
+{
+	struct rpc_cred *cred;
+	struct rpc_task *task;
+	struct rpc_add_xprt_test *xtest = (struct rpc_add_xprt_test *)data;
+	int status = -EADDRINUSE;
+
+	xprt = xprt_get(xprt);
+	xprt_switch_get(xps);
+
+	if (rpc_xprt_switch_has_addr(xps, (struct sockaddr *)&xprt->addr))
+		goto out_err;
+
+	/* Test the connection */
+	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
+	task = rpc_call_null_helper(clnt, xprt, cred,
+				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+				    NULL, NULL);
+	put_rpccred(cred);
+	if (IS_ERR(task)) {
+		status = PTR_ERR(task);
+		goto out_err;
+	}
+	status = task->tk_status;
+	rpc_put_task(task);
+
+	if (status < 0)
+		goto out_err;
+
+	/* rpc_xprt_switch and rpc_xprt are deferrenced by add_xprt_test() */
+	xtest->add_xprt_test(clnt, xprt, xtest->data);
+
+	/* so that rpc_clnt_add_xprt does not call rpc_xprt_switch_add_xprt */
+	return 1;
+out_err:
+	xprt_put(xprt);
+	xprt_switch_put(xps);
+	pr_info("RPC:   rpc_clnt_test_xprt failed: %d addr %s not added\n",
+		status, xprt->address_strings[RPC_DISPLAY_ADDR]);
+	return status;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_setup_test_and_add_xprt);
+
+/**
  * rpc_clnt_add_xprt - Add a new transport to a rpc_clnt
  * @clnt: pointer to struct rpc_clnt
  * @xprtargs: pointer to struct xprt_create
-- 
1.8.3.1

