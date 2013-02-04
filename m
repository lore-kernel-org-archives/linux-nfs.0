Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40505 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178Ab3BDLBr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 06:01:47 -0500
Subject: [PATCH v2 1/6] NFS: use SUNRPC cache creation and destruction helper
	for DNS cache
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 04 Feb 2013 14:02:35 +0300
Message-ID: <20130204110235.11633.59600.stgit@localhost.localdomain>
In-Reply-To: <20130204105728.11633.53621.stgit@localhost.localdomain>
References: <20130204105728.11633.53621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This cache was the first containerized and doesn't use net-aware cache
creation and destruction helpers.
This is a cleanup patch which just makes code looks clearer and reduce amount
of lines of code.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/dns_resolve.c |   60 +++++++++++++++++++++-----------------------------
 1 files changed, 25 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index ca4b11e..5015447 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -351,48 +351,39 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name,
 }
 EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
+static struct cache_detail nfs_dns_resolve_template = {
+	.owner		= THIS_MODULE,
+	.hash_size	= NFS_DNS_HASHTBL_SIZE,
+	.name		= "dns_resolve",
+	.cache_put	= nfs_dns_ent_put,
+	.cache_upcall	= nfs_dns_upcall,
+	.cache_parse	= nfs_dns_parse,
+	.cache_show	= nfs_dns_show,
+	.match		= nfs_dns_match,
+	.init		= nfs_dns_ent_init,
+	.update		= nfs_dns_ent_update,
+	.alloc		= nfs_dns_ent_alloc,
+};
+
+
 int nfs_dns_resolver_cache_init(struct net *net)
 {
-	int err = -ENOMEM;
+	int err;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct cache_detail *cd;
-	struct cache_head **tbl;
 
-	cd = kzalloc(sizeof(struct cache_detail), GFP_KERNEL);
-	if (cd == NULL)
-		goto err_cd;
-
-	tbl = kzalloc(NFS_DNS_HASHTBL_SIZE * sizeof(struct cache_head *),
-			GFP_KERNEL);
-	if (tbl == NULL)
-		goto err_tbl;
-
-	cd->owner = THIS_MODULE,
-	cd->hash_size = NFS_DNS_HASHTBL_SIZE,
-	cd->hash_table = tbl,
-	cd->name = "dns_resolve",
-	cd->cache_put = nfs_dns_ent_put,
-	cd->cache_upcall = nfs_dns_upcall,
-	cd->cache_parse = nfs_dns_parse,
-	cd->cache_show = nfs_dns_show,
-	cd->match = nfs_dns_match,
-	cd->init = nfs_dns_ent_init,
-	cd->update = nfs_dns_ent_update,
-	cd->alloc = nfs_dns_ent_alloc,
-
-	nfs_cache_init(cd);
-	err = nfs_cache_register_net(net, cd);
+	nn->nfs_dns_resolve = cache_create_net(&nfs_dns_resolve_template, net);
+	if (IS_ERR(nn->nfs_dns_resolve))
+		return PTR_ERR(nn->nfs_dns_resolve);
+
+	nfs_cache_init(nn->nfs_dns_resolve);
+	err = nfs_cache_register_net(net, nn->nfs_dns_resolve);
 	if (err)
 		goto err_reg;
-	nn->nfs_dns_resolve = cd;
 	return 0;
 
 err_reg:
-	nfs_cache_destroy(cd);
-	kfree(cd->hash_table);
-err_tbl:
-	kfree(cd);
-err_cd:
+	nfs_cache_destroy(nn->nfs_dns_resolve);
+	cache_destroy_net(nn->nfs_dns_resolve, net);
 	return err;
 }
 
@@ -403,8 +394,7 @@ void nfs_dns_resolver_cache_destroy(struct net *net)
 
 	nfs_cache_unregister_net(net, cd);
 	nfs_cache_destroy(cd);
-	kfree(cd->hash_table);
-	kfree(cd);
+	cache_destroy_net(nn->nfs_dns_resolve, net);
 }
 
 static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,

