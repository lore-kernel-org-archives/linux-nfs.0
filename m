Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:12688 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932465Ab1JYKRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 06:17:21 -0400
Subject: [PATCH v6 8/8] SUNRPC: remove rpcbind clients destruction on module
	cleanup
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Tue, 25 Oct 2011 14:17:48 +0300
Message-ID: <20111025101746.12689.25295.stgit@localhost6.localdomain6>
In-Reply-To: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rpcbind clients destruction during SUNRPC module removing is obsolete since now
those clients are destroying during last RPC service shutdown.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c   |   12 ------------
 net/sunrpc/sunrpc_syms.c |    3 ---
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 088e4e2..c2054ae 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -1101,15 +1101,3 @@ static struct rpc_program rpcb_program = {
 	.version	= rpcb_version,
 	.stats		= &rpcb_stats,
 };
-
-/**
- * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
- *
- */
-void cleanup_rpcb_clnt(void)
-{
-	if (rpcb_local_clnt4)
-		rpc_shutdown_client(rpcb_local_clnt4);
-	if (rpcb_local_clnt)
-		rpc_shutdown_client(rpcb_local_clnt);
-}
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 9d08091..8ec9778 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -61,8 +61,6 @@ static struct pernet_operations sunrpc_net_ops = {
 
 extern struct cache_detail unix_gid_cache;
 
-extern void cleanup_rpcb_clnt(void);
-
 static int __init
 init_sunrpc(void)
 {
@@ -102,7 +100,6 @@ out:
 static void __exit
 cleanup_sunrpc(void)
 {
-	cleanup_rpcb_clnt();
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();

