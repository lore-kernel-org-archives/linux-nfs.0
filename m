Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:25988 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905AbcHOSwv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2016 14:52:51 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 06/12] SUNRPC rpc_clnt_xprt_switch_put
Date: Mon, 15 Aug 2016 14:50:42 -0400
Message-ID: <1471287048-27007-7-git-send-email-andros@netapp.com>
In-Reply-To: <1471287048-27007-1-git-send-email-andros@netapp.com>
References: <1471287048-27007-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Give the NFS layer access to the xprt_switch_put function

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h | 2 ++
 net/sunrpc/clnt.c           | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b6810c9..6005095 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -197,5 +197,7 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 			void *data);
 
 const char *rpc_proc_name(const struct rpc_task *task);
+
+void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 163b8f4..83ab914 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2672,6 +2672,12 @@ out_put_switch:
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_add_xprt);
 
+void rpc_clnt_xprt_switch_put(struct rpc_clnt *clnt)
+{
+	xprt_switch_put(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_put);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
-- 
1.8.3.1

