Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43279 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752671AbdKEKAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Nov 2017 05:00:17 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 06/21] nfs client: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <5cbecaf0-dbb6-4140-43ed-ae94fc161941@virtuozzo.com>
Date: Sun, 5 Nov 2017 13:00:06 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that nfs_client_list and nfs_volume_list lists initialized
in net_init hook were return to initial state in net_exit hook.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/client.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 22880ef..7c0691c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -204,6 +204,10 @@ void nfs_cleanup_cb_ident_idr(struct net *net)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	idr_destroy(&nn->cb_ident_idr);
+	WARN(!list_empty(&nn->nfs_client_list),
+	     "net %p exit: nfs_client_list is not empty\n", net);
+	WARN(!list_empty(&nn->nfs_volume_list),
+	     "net %p exit: nfs_volume_list is not empty\n", net);
 }
 
 /* nfs_client_lock held */
-- 
2.7.4

