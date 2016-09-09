Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:60728 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753592AbcIINYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:18 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 06/12] SUNRPC rpc_clnt_xprt_switch_put
Date: Fri, 9 Sep 2016 09:22:23 -0400
Message-ID: <1473427349-13265-7-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
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
index 5c02b06..c12f86b 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -199,5 +199,7 @@ void		rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
 			unsigned long timeo);
 
 const char *rpc_proc_name(const struct rpc_task *task);
+
+void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4abc631..138f777 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2695,6 +2695,12 @@ rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt, unsigned long timeo)
 }
 EXPORT_SYMBOL_GPL(rpc_cap_max_reconnect_timeout);
 
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

