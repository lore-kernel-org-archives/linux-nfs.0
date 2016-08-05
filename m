Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34419 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbcHFXqs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 19:46:48 -0400
Received: by mail-io0-f196.google.com with SMTP id i199so4368148ioi.1
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 16:46:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFSv4: Cap the transport reconnection timer at 1/2 lease period
Date: Fri,  5 Aug 2016 19:37:35 -0400
Message-Id: <1470440255-8612-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1470440255-8612-3-git-send-email-trond.myklebust@primarydata.com>
References: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
 <1470440255-8612-2-git-send-email-trond.myklebust@primarydata.com>
 <1470440255-8612-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want to miss a lease period renewal due to the TCP connection
failing to reconnect in a timely fashion. To ensure this doesn't happen,
cap the reconnection timer so that we retry the connection attempt
at least every 1/2 lease period.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4renewd.c         |  3 +++
 include/linux/sunrpc/clnt.h |  2 ++
 net/sunrpc/clnt.c           | 21 +++++++++++++++++++++
 3 files changed, 26 insertions(+)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 062029ab344a..82e77198d17e 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -151,6 +151,9 @@ void nfs4_set_lease_period(struct nfs_client *clp,
 	clp->cl_lease_time = lease;
 	clp->cl_last_renewal = lastrenewed;
 	spin_unlock(&clp->cl_lock);
+
+	/* Cap maximum reconnect timeout at 1/2 lease period */
+	rpc_cap_max_reconnect_timeout(clp->cl_rpcclient, lease >> 1);
 }
 
 /*
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b6810c92b8bb..5c02b0691587 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -195,6 +195,8 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 				struct rpc_xprt *,
 				void *),
 			void *data);
+void		rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
+			unsigned long timeo);
 
 const char *rpc_proc_name(const struct rpc_task *task);
 #endif /* __KERNEL__ */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index faac5472d14d..7f79fb7dc6a0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2676,6 +2676,27 @@ out_put_switch:
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_add_xprt);
 
+static int
+rpc_xprt_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		void *data)
+{
+	unsigned long timeout = *((unsigned long *)data);
+
+	if (timeout < xprt->max_reconnect_timeout)
+		xprt->max_reconnect_timeout = timeout;
+	return 0;
+}
+
+void
+rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt, unsigned long timeo)
+{
+	rpc_clnt_iterate_for_each_xprt(clnt,
+			rpc_xprt_cap_max_reconnect_timeout,
+			&timeo);
+}
+EXPORT_SYMBOL_GPL(rpc_cap_max_reconnect_timeout);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
-- 
2.7.4

