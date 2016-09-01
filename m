Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:3489 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933132AbcIAPqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 11:46:44 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 RESEND 07/12] SUNRPC rpc_clnt_xprt_switch_add_xprt
Date: Thu, 1 Sep 2016 11:44:48 -0400
Message-ID: <1472744693-124241-8-git-send-email-andros@netapp.com>
In-Reply-To: <1472744693-124241-1-git-send-email-andros@netapp.com>
References: <1472744693-124241-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Give the NFS layer access to the rpc_xprt_switch_add_xprt function

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 net/sunrpc/clnt.c           | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6005095..28cbc81 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -199,5 +199,6 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 const char *rpc_proc_name(const struct rpc_task *task);
 
 void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
+void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *, struct rpc_xprt *);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 83ab914..35df635 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2678,6 +2678,13 @@ void rpc_clnt_xprt_switch_put(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_put);
 
+void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
+{
+	rpc_xprt_switch_add_xprt(rcu_dereference(clnt->cl_xpi.xpi_xpswitch),
+				 xprt);
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_add_xprt);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
-- 
1.8.3.1

