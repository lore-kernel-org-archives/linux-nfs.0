Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15876 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755208Ab1LNKpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:45:18 -0500
Subject: [PATCH 02/11] SUNRPC: use syctl path instead of dummy parent table
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:44:57 +0300
Message-ID: <20111214104457.3991.64507.stgit@localhost6.localdomain6>
In-Reply-To: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch. Parent sunrpc table is redundant. Syctl path can be
used instead.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/debug.h    |    4 ++++
 net/sunrpc/sysctl.c             |   25 ++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c |   11 +----------
 net/sunrpc/xprtsock.c           |   11 +----------
 4 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index c2786f2..b5e0c46 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -63,8 +63,12 @@ extern unsigned int		nlm_debug;
  * Sysctl interface for RPC debugging
  */
 #ifdef RPC_DEBUG
+
 void		rpc_register_sysctl(void);
 void		rpc_unregister_sysctl(void);
+
+struct ctl_table_header *register_sunrpc_sysctl(struct ctl_table *);
+
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index af7d339..64c0034 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -40,13 +40,25 @@ EXPORT_SYMBOL_GPL(nlm_debug);
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
-static ctl_table		sunrpc_table[];
+static ctl_table		debug_table[];
+
+struct ctl_path sunrpc_path[] = {
+	{ .procname = "sunrpc", },
+	{ },
+};
+
+struct ctl_table_header *register_sunrpc_sysctl(struct ctl_table *table)
+{
+	return register_sysctl_paths(sunrpc_path, table);
+
+}
+EXPORT_SYMBOL_GPL(register_sunrpc_sysctl);
 
 void
 rpc_register_sysctl(void)
 {
 	if (!sunrpc_table_header)
-		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+		sunrpc_table_header = register_sunrpc_sysctl(debug_table);
 }
 
 void
@@ -173,13 +185,4 @@ static ctl_table debug_table[] = {
 	{ }
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= debug_table
-	},
-	{ }
-};
-
 #endif
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b446e10..53a8622 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -137,15 +137,6 @@ static ctl_table xr_tunables_table[] = {
 	{ },
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= xr_tunables_table
-	},
-	{ },
-};
-
 #endif
 
 static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
@@ -771,7 +762,7 @@ static int __init xprt_rdma_init(void)
 
 #ifdef RPC_DEBUG
 	if (!sunrpc_table_header)
-		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+		sunrpc_table_header = register_sunrpc_sysctl(xr_tunables_table);
 #endif
 	return 0;
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..6f1be96 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -142,15 +142,6 @@ static ctl_table xs_tunables_table[] = {
 	{ },
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= xs_tunables_table
-	},
-	{ },
-};
-
 #endif
 
 /*
@@ -2887,7 +2878,7 @@ int init_socket_xprt(void)
 {
 #ifdef RPC_DEBUG
 	if (!sunrpc_table_header)
-		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+		sunrpc_table_header = register_sunrpc_sysctl(xs_tunables_table);
 #endif
 
 	xprt_register_transport(&xs_local_transport);

