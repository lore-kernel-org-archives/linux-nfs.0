Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:15792 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757924AbcG0Sla (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2016 14:41:30 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@rhel7-2-ga-2.androsad.fake>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 6/8] SUNRPC add an RPC null call to test session trunking connection
Date: Wed, 27 Jul 2016 14:39:34 -0400
Message-ID: <1469644776-19491-7-git-send-email-andros@netapp.com>
In-Reply-To: <1469644776-19491-1-git-send-email-andros@netapp.com>
References: <1469644776-19491-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@rhel7-2-ga-2.androsad.fake>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h |  2 ++
 net/sunrpc/clnt.c           | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 99410bb..ebc83df 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -189,6 +189,8 @@ int 		rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 			struct rpc_xprt_switch *xps,
 			struct rpc_xprt *xprt,
 			void *dummy);
+int		rpc_clnt_test_xprt(struct rpc_clnt *clnt,
+			struct rpc_xprt *xprt);
 int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 			int (*setup)(struct rpc_clnt *,
 				struct rpc_xprt_switch *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 08f3e9e..425ff79 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2615,6 +2615,24 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
 
+int rpc_clnt_test_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
+{
+	struct rpc_cred *cred;
+	struct rpc_task *task;
+	int status;
+
+	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
+	task = rpc_call_null_helper(clnt, xprt, cred,
+				RPC_TASK_SOFT | RPC_TASK_SOFTCONN, NULL, NULL);
+	put_rpccred(cred);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = task->tk_status;
+	rpc_put_task(task);
+	return status;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_test_xprt);
+
 /**
  * rpc_clnt_add_xprt - Add a new transport to a rpc_clnt
  * @clnt: pointer to struct rpc_clnt
-- 
1.8.3.1

