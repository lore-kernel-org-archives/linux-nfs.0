Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40379 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478Ab3BDLBq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 06:01:46 -0500
Subject: [PATCH v2 2/6] NFS; simlify and clean cache library
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 04 Feb 2013 14:02:40 +0300
Message-ID: <20130204110240.11633.89082.stgit@localhost.localdomain>
In-Reply-To: <20130204105728.11633.53621.stgit@localhost.localdomain>
References: <20130204105728.11633.53621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch.
Such helpers like nfs_cache_init() and nfs_cache_destroy() are redundant,
because they are just a wrappers around sunrpc_init_cache_detail() and
sunrpc_destroy_cache_detail() respectively.
So let's remove them completely and move corresponding logic to
nfs_cache_register_net() and nfs_cache_unregister_net() respectively (since
they are called together anyway).

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/cache_lib.c   |   12 +++---------
 fs/nfs/cache_lib.h   |    2 --
 fs/nfs/dns_resolve.c |    6 +-----
 3 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 862a2f1..5f7b053 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -128,10 +128,13 @@ int nfs_cache_register_net(struct net *net, struct cache_detail *cd)
 	struct super_block *pipefs_sb;
 	int ret = 0;
 
+	sunrpc_init_cache_detail(cd);
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
 		ret = nfs_cache_register_sb(pipefs_sb, cd);
 		rpc_put_sb_net(net);
+		if (ret)
+			sunrpc_destroy_cache_detail(cd);
 	}
 	return ret;
 }
@@ -151,14 +154,5 @@ void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd)
 		nfs_cache_unregister_sb(pipefs_sb, cd);
 		rpc_put_sb_net(net);
 	}
-}
-
-void nfs_cache_init(struct cache_detail *cd)
-{
-	sunrpc_init_cache_detail(cd);
-}
-
-void nfs_cache_destroy(struct cache_detail *cd)
-{
 	sunrpc_destroy_cache_detail(cd);
 }
diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
index 317db95..4116d2c 100644
--- a/fs/nfs/cache_lib.h
+++ b/fs/nfs/cache_lib.h
@@ -23,8 +23,6 @@ extern struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void);
 extern void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq);
 extern int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq);
 
-extern void nfs_cache_init(struct cache_detail *cd);
-extern void nfs_cache_destroy(struct cache_detail *cd);
 extern int nfs_cache_register_net(struct net *net, struct cache_detail *cd);
 extern void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd);
 extern int nfs_cache_register_sb(struct super_block *sb,
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 5015447..499834b 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -375,14 +375,12 @@ int nfs_dns_resolver_cache_init(struct net *net)
 	if (IS_ERR(nn->nfs_dns_resolve))
 		return PTR_ERR(nn->nfs_dns_resolve);
 
-	nfs_cache_init(nn->nfs_dns_resolve);
 	err = nfs_cache_register_net(net, nn->nfs_dns_resolve);
 	if (err)
 		goto err_reg;
 	return 0;
 
 err_reg:
-	nfs_cache_destroy(nn->nfs_dns_resolve);
 	cache_destroy_net(nn->nfs_dns_resolve, net);
 	return err;
 }
@@ -390,10 +388,8 @@ err_reg:
 void nfs_dns_resolver_cache_destroy(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct cache_detail *cd = nn->nfs_dns_resolve;
 
-	nfs_cache_unregister_net(net, cd);
-	nfs_cache_destroy(cd);
+	nfs_cache_unregister_net(net, nn->nfs_dns_resolve);
 	cache_destroy_net(nn->nfs_dns_resolve, net);
 }
 

