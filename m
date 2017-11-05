Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42234 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750817AbdKEQuK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Nov 2017 11:50:10 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2 06/21] nfs client: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <bafb347d-e36e-8b2b-7646-afc458a7a32a@virtuozzo.com>
Message-ID: <80d93023-9c22-4c28-fe42-6cb71fc585f3@virtuozzo.com>
Date: Sun, 5 Nov 2017 19:50:00 +0300
MIME-Version: 1.0
In-Reply-To: <bafb347d-e36e-8b2b-7646-afc458a7a32a@virtuozzo.com>
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
index 22880ef..e099a01 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -204,6 +204,10 @@ void nfs_cleanup_cb_ident_idr(struct net *net)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	idr_destroy(&nn->cb_ident_idr);
+	WARN(!list_empty(&nn->nfs_client_list),
+	     "nfs net_exit: nfs_client_list is not empty\n");
+	WARN(!list_empty(&nn->nfs_volume_list),
+	     "nfs net_exit: nfs_volume_list is not empty\n");
 }
 
 /* nfs_client_lock held */
-- 
2.7.4

