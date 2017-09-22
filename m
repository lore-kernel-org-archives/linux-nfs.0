Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752054AbdIVL5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Sep 2017 07:57:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Michael Sterrett <michael@sterretts.net>
Subject: [PATCH] NFS: Fix uninitialized rpc_wait_queue
Date: Fri, 22 Sep 2017 07:57:10 -0400
Message-Id: <20566df4b4370dfd62b88642803f850af84dd969.1506081260.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Michael Sterrett reports a NULL pointer dereference on NFSv3 mounts when
CONFIG_NFS_V4 is not set because the NFS UOC rpc_wait_queue has not been
initialized.  Move the initialization of the queue out of the CONFIG_NFS_V4
conditional setion.

Fixes: 7d6ddf88c4db ("NFS: Add an iocounter wait function for async RPC tasks")
Cc: stable@vger.kernel.org # 4.11+
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index efebe6cf4378..22880ef6d8dd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -218,7 +218,6 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 static void pnfs_init_server(struct nfs_server *server)
 {
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
-	rpc_init_wait_queue(&server->uoc_rpcwaitq, "NFS UOC");
 }
 
 #else
@@ -888,6 +887,7 @@ struct nfs_server *nfs_alloc_server(void)
 	ida_init(&server->openowner_id);
 	ida_init(&server->lockowner_id);
 	pnfs_init_server(server);
+	rpc_init_wait_queue(&server->uoc_rpcwaitq, "NFS UOC");
 
 	return server;
 }
-- 
2.9.3

