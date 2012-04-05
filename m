Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18118 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab2DERFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Apr 2012 13:05:22 -0400
Subject: [PATCH] SUNRPC: register PipeFS file system after pernet sybsystem
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davej@redhat.com,
        davem@davemloft.net, devel@openvz.org
Date: Thu, 05 Apr 2012 21:04:37 +0400
Message-ID: <20120405170405.15055.85431.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PipeFS superblock creation routine relays on SUNRPC pernet data presense, which
is created on register_pernet_subsys() call in SUNRPC module init function.
Registering of PipeFS filesystem prior to registering of per-net subsystem
leads to races (mount of PipeFS can dereference uninitialized data).

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/sunrpc_syms.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 8adfc88..3d6498a 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -75,20 +75,21 @@ static struct pernet_operations sunrpc_net_ops = {
 static int __init
 init_sunrpc(void)
 {
-	int err = register_rpc_pipefs();
+	int err = rpc_init_mempool();
 	if (err)
 		goto out;
-	err = rpc_init_mempool();
-	if (err)
-		goto out2;
 	err = rpcauth_init_module();
 	if (err)
-		goto out3;
+		goto out2;
 
 	cache_initialize();
 
 	err = register_pernet_subsys(&sunrpc_net_ops);
 	if (err)
+		goto out3;
+
+	err = register_rpc_pipefs();
+	if (err)
 		goto out4;
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
@@ -98,11 +99,11 @@ init_sunrpc(void)
 	return 0;
 
 out4:
-	rpcauth_remove_module();
+	unregister_pernet_subsys(&sunrpc_net_ops);
 out3:
-	rpc_destroy_mempool();
+	rpcauth_remove_module();
 out2:
-	unregister_rpc_pipefs();
+	rpc_destroy_mempool();
 out:
 	return err;
 }

