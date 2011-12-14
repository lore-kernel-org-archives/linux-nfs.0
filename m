Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34118 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753673Ab1LNKpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:45:22 -0500
Subject: [PATCH 03/11] SUNRPC: sysctl root for debug table introduced
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:45:05 +0300
Message-ID: <20111214104505.3991.45390.stgit@localhost6.localdomain6>
In-Reply-To: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sysctl root is required for handliong sysctl dentries per network namespace
context. IOW, it's "lookup" method will be used to find per-net sysctl's set in
further patches.
Also this patch modifies sysctl registering helpers to make them use new sysctl
root.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/sysctl.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 64c0034..f6e7da2 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -39,6 +39,9 @@ EXPORT_SYMBOL_GPL(nlm_debug);
 
 #ifdef RPC_DEBUG
 
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+
 static struct ctl_table_header *sunrpc_table_header;
 static ctl_table		debug_table[];
 
@@ -47,18 +50,24 @@ struct ctl_path sunrpc_path[] = {
 	{ },
 };
 
+static struct ctl_table_root sunrpc_debug_root = {
+};
+
 struct ctl_table_header *register_sunrpc_sysctl(struct ctl_table *table)
 {
-	return register_sysctl_paths(sunrpc_path, table);
-
+	return __register_sysctl_paths(&sunrpc_debug_root, current->nsproxy,
+				       sunrpc_path, table);
 }
 EXPORT_SYMBOL_GPL(register_sunrpc_sysctl);
 
 void
 rpc_register_sysctl(void)
 {
-	if (!sunrpc_table_header)
+	if (!sunrpc_table_header) {
+		setup_sysctl_set(&sunrpc_debug_root.default_set, NULL, NULL);
+		register_sysctl_root(&sunrpc_debug_root);
 		sunrpc_table_header = register_sunrpc_sysctl(debug_table);
+	}
 }
 
 void
@@ -66,6 +75,7 @@ rpc_unregister_sysctl(void)
 {
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
+		unregister_sysctl_root(&sunrpc_debug_root);
 		sunrpc_table_header = NULL;
 	}
 }

