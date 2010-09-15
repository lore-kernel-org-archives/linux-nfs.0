Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab0IONE4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:04:56 -0400
Message-ID: <4C90BBE9.6000105@parallels.com>
Date: Wed, 15 Sep 2010 16:28:25 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] sunrpc: The per-net skeleton
References: <4C90BADB.10700@parallels.com>
In-Reply-To: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Register empty per-net operations for the sunrpc layer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/sunrpc/netns.h       |   12 ++++++++++++
 net/sunrpc/sunrpc_syms.c |   31 ++++++++++++++++++++++++++++++-
 2 files changed, 42 insertions(+), 1 deletions(-)
 create mode 100644 net/sunrpc/netns.h

diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
new file mode 100644
index 0000000..b2d18af
--- /dev/null
+++ b/net/sunrpc/netns.h
@@ -0,0 +1,12 @@
+#ifndef __SUNRPC_NETNS_H__
+#define __SUNRPC_NETNS_H__
+
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+struct sunrpc_net {
+};
+
+extern int sunrpc_net_id;
+
+#endif
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index c0d0850..d552a6a 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -22,6 +22,26 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/xprtsock.h>
 
+#include "netns.h"
+
+int sunrpc_net_id;
+
+static __net_init int sunrpc_init_net(struct net *net)
+{
+	return 0;
+}
+
+static __net_exit void sunrpc_exit_net(struct net *net)
+{
+}
+
+static struct pernet_operations sunrpc_net_ops = {
+	.init = sunrpc_init_net,
+	.exit = sunrpc_exit_net,
+	.id = &sunrpc_net_id,
+	.size = sizeof(struct sunrpc_net),
+};
+
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
 extern void cleanup_rpcb_clnt(void);
@@ -38,18 +58,26 @@ init_sunrpc(void)
 	err = rpcauth_init_module();
 	if (err)
 		goto out3;
+
+	cache_initialize();
+
+	err = register_pernet_subsys(&sunrpc_net_ops);
+	if (err)
+		goto out4;
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
 #endif
 #ifdef CONFIG_PROC_FS
 	rpc_proc_init();
 #endif
-	cache_initialize();
 	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
 	return 0;
+
+out4:
+	unregister_pernet_subsys(&sunrpc_net_ops);
 out3:
 	rpc_destroy_mempool();
 out2:
@@ -69,6 +97,7 @@ cleanup_sunrpc(void)
 	rpc_destroy_mempool();
 	cache_unregister(&ip_map_cache);
 	cache_unregister(&unix_gid_cache);
+	unregister_pernet_subsys(&sunrpc_net_ops);
 #ifdef RPC_DEBUG
 	rpc_unregister_sysctl();
 #endif
-- 
1.5.5.6

