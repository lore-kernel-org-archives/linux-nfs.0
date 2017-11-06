Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32287 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753192AbdKFNY3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:24:29 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 08/21] nfs client: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Message-ID: <f06b08d0-d708-dfa9-5440-a00f59325585@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:24:21 +0300
MIME-Version: 1.0
In-Reply-To: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
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
index 22880ef..3966c98 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -204,6 +204,10 @@ void nfs_cleanup_cb_ident_idr(struct net *net)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	idr_destroy(&nn->cb_ident_idr);
+	WARN_ONCE(!list_empty(&nn->nfs_client_list),
+		  "net %x exit: nfs_client_list is not empty\n", net->ns.inum);
+	WARN_ONCE(!list_empty(&nn->nfs_volume_list),
+		  "net %x exit: nfs_volume_list is not empty\n", net->ns.inum);
 }
 
 /* nfs_client_lock held */
-- 
2.7.4

