Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:22517 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754666AbcIINYU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:20 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 08/12] SUNRPC search xprt switch for sockaddr
Date: Fri, 9 Sep 2016 09:22:25 -0400
Message-ID: <1473427349-13265-9-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h          |  2 ++
 include/linux/sunrpc/xprtmultipath.h |  2 ++
 net/sunrpc/clnt.c                    | 15 +++++++++++++++
 net/sunrpc/xprtmultipath.c           | 24 +++++++++++++++++++++++-
 4 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b069d6e..35cc539 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -202,5 +202,7 @@ const char *rpc_proc_name(const struct rpc_task *task);
 
 void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
 void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *, struct rpc_xprt *);
+bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
+			const struct sockaddr *sap);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/xprtmultipath.h b/include/linux/sunrpc/xprtmultipath.h
index 5a9acff..507418c 100644
--- a/include/linux/sunrpc/xprtmultipath.h
+++ b/include/linux/sunrpc/xprtmultipath.h
@@ -66,4 +66,6 @@ extern struct rpc_xprt *xprt_iter_xprt(struct rpc_xprt_iter *xpi);
 extern struct rpc_xprt *xprt_iter_get_xprt(struct rpc_xprt_iter *xpi);
 extern struct rpc_xprt *xprt_iter_get_next(struct rpc_xprt_iter *xpi);
 
+extern bool rpc_xprt_switch_has_addr(struct rpc_xprt_switch *xps,
+		const struct sockaddr *sap);
 #endif
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6db0d00..282a5e7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2708,6 +2708,21 @@ void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_add_xprt);
 
+bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
+				   const struct sockaddr *sap)
+{
+	struct rpc_xprt_switch *xps;
+	bool ret;
+
+	xps = rcu_dereference(clnt->cl_xpi.xpi_xpswitch);
+
+	rcu_read_lock();
+	ret = rpc_xprt_switch_has_addr(xps, sap);
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_has_addr);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 66c9d63..ae92a9e 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -15,6 +15,7 @@
 #include <asm/cmpxchg.h>
 #include <linux/spinlock.h>
 #include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/xprtmultipath.h>
 
 typedef struct rpc_xprt *(*xprt_switch_find_xprt_t)(struct list_head *head,
@@ -49,7 +50,8 @@ void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
 	if (xprt == NULL)
 		return;
 	spin_lock(&xps->xps_lock);
-	if (xps->xps_net == xprt->xprt_net || xps->xps_net == NULL)
+	if ((xps->xps_net == xprt->xprt_net || xps->xps_net == NULL) &&
+	    !rpc_xprt_switch_has_addr(xps, (struct sockaddr *)&xprt->addr))
 		xprt_switch_add_xprt_locked(xps, xprt);
 	spin_unlock(&xps->xps_lock);
 }
@@ -232,6 +234,26 @@ struct rpc_xprt *xprt_iter_current_entry(struct rpc_xprt_iter *xpi)
 	return xprt_switch_find_current_entry(head, xpi->xpi_cursor);
 }
 
+bool rpc_xprt_switch_has_addr(struct rpc_xprt_switch *xps,
+			      const struct sockaddr *sap)
+{
+	struct list_head *head;
+	struct rpc_xprt *pos;
+
+	if (xps == NULL || sap == NULL)
+		return false;
+
+	head = &xps->xps_xprt_list;
+	list_for_each_entry_rcu(pos, head, xprt_switch) {
+		if (rpc_cmp_addr_port(sap, (struct sockaddr *)&pos->addr)) {
+			pr_info("RPC:   addr %s already in xprt switch\n",
+				pos->address_strings[RPC_DISPLAY_ADDR]);
+			return true;
+		}
+	}
+	return false;
+}
+
 static
 struct rpc_xprt *xprt_switch_find_next_entry(struct list_head *head,
 		const struct rpc_xprt *cur)
-- 
1.8.3.1

