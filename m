Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:3489 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933132AbcIAPqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 11:46:45 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 RESEND 09/12] SUNRPC: rpc_clnt_add_xprt setup function for NFS layer
Date: Thu, 1 Sep 2016 11:44:50 -0400
Message-ID: <1472744693-124241-10-git-send-email-andros@netapp.com>
In-Reply-To: <1472744693-124241-1-git-send-email-andros@netapp.com>
References: <1472744693-124241-1-git-send-email-andros@netapp.com>
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
index b932160..2087ab5 100644
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
@@ -196,6 +203,11 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 				void *),
 			void *data);
 
+int		rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *,
+			struct rpc_xprt_switch *,
+			struct rpc_xprt *,
+			void *);
+
 const char *rpc_proc_name(const struct rpc_task *task);
 
 void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 889ef94..c552eb2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2615,6 +2615,70 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
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

