Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34005 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbdBHQqO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:46:14 -0500
Received: by mail-io0-f195.google.com with SMTP id c80so16406571iod.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:45:53 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4: Set the connection timeout to match the lease period
Date: Wed,  8 Feb 2017 11:17:55 -0500
Message-Id: <20170208161755.3614-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170208161755.3614-4-trond.myklebust@primarydata.com>
References: <20170208161755.3614-1-trond.myklebust@primarydata.com>
 <20170208161755.3614-2-trond.myklebust@primarydata.com>
 <20170208161755.3614-3-trond.myklebust@primarydata.com>
 <20170208161755.3614-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set the timeout for TCP connections to be 1 lease period to ensure
that we don't lose our lease due to a faulty TCP connection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4renewd.c         |  2 +-
 include/linux/sunrpc/clnt.h |  5 +++--
 net/sunrpc/clnt.c           | 10 ++++++----
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 82e77198d17e..1f8c2ae43a8d 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -153,7 +153,7 @@ void nfs4_set_lease_period(struct nfs_client *clp,
 	spin_unlock(&clp->cl_lock);
 
 	/* Cap maximum reconnect timeout at 1/2 lease period */
-	rpc_cap_max_reconnect_timeout(clp->cl_rpcclient, lease >> 1);
+	rpc_set_connect_timeout(clp->cl_rpcclient, lease, lease >> 1);
 }
 
 /*
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 33f216edb434..6095ecba0dde 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -201,8 +201,9 @@ int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
 				struct rpc_xprt *,
 				void *),
 			void *data);
-void		rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt,
-			unsigned long timeo);
+void		rpc_set_connect_timeout(struct rpc_clnt *clnt,
+			unsigned long connect_timeout,
+			unsigned long reconnect_timeout);
 
 int		rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *,
 			struct rpc_xprt_switch *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b5bc0c589f6a..52da3ce54bb5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2747,17 +2747,19 @@ rpc_xprt_set_connect_timeout(struct rpc_clnt *clnt,
 }
 
 void
-rpc_cap_max_reconnect_timeout(struct rpc_clnt *clnt, unsigned long timeo)
+rpc_set_connect_timeout(struct rpc_clnt *clnt,
+		unsigned long connect_timeout,
+		unsigned long reconnect_timeout)
 {
 	struct connect_timeout_data timeout = {
-		.connect_timeout = timeo,
-		.reconnect_timeout = timeo,
+		.connect_timeout = connect_timeout,
+		.reconnect_timeout = reconnect_timeout,
 	};
 	rpc_clnt_iterate_for_each_xprt(clnt,
 			rpc_xprt_set_connect_timeout,
 			&timeout);
 }
-EXPORT_SYMBOL_GPL(rpc_cap_max_reconnect_timeout);
+EXPORT_SYMBOL_GPL(rpc_set_connect_timeout);
 
 void rpc_clnt_xprt_switch_put(struct rpc_clnt *clnt)
 {
-- 
2.9.3

