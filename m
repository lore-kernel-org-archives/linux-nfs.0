Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6625 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdKHFzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 00:55:33 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 1/4] nfsd: remove net pointer from debug messages
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <4c16eedb-7122-da42-a5fb-0ae2defdfffc@virtuozzo.com>
Date: Wed, 8 Nov 2017 08:55:22 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Publishing of net pointer is not safe,
replace it in debug meesages by net->ns.inum

[  119.989161] nfsd: initializing export module (net: f00001e7).
[  171.767188] NFSD: starting 90-second grace period (net f00001e7)
[  322.185240] nfsd: shutting down export module (net: f00001e7).
[  322.186062] nfsd: export shutdown complete (net: f00001e7).

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfsd/export.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 46b48db..f9e7dd5 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1230,7 +1230,7 @@ nfsd_export_init(struct net *net)
 	int rv;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	dprintk("nfsd: initializing export module (net: %p).\n", net);
+	dprintk("nfsd: initializing export module (net: %x).\n", net->ns.inum);
 
 	nn->svc_export_cache = cache_create_net(&svc_export_cache_template, net);
 	if (IS_ERR(nn->svc_export_cache))
@@ -1278,7 +1278,7 @@ nfsd_export_shutdown(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	dprintk("nfsd: shutting down export module (net: %p).\n", net);
+	dprintk("nfsd: shutting down export module (net: %x).\n", net->ns.inum);
 
 	cache_unregister_net(nn->svc_expkey_cache, net);
 	cache_unregister_net(nn->svc_export_cache, net);
@@ -1286,5 +1286,5 @@ nfsd_export_shutdown(struct net *net)
 	cache_destroy_net(nn->svc_export_cache, net);
 	svcauth_unix_purge(net);
 
-	dprintk("nfsd: export shutdown complete (net: %p).\n", net);
+	dprintk("nfsd: export shutdown complete (net: %x).\n", net->ns.inum);
 }
-- 
2.7.4

