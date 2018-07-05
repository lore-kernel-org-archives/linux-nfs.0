Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:37362 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbeGEQIu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2018 12:08:50 -0400
From: Calum Mackay <calum.mackay@oracle.com>
To: trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Referrals not inheriting proto setting from parent
Date: Thu,  5 Jul 2018 17:08:08 +0100
Message-Id: <20180705160808.7849-1-calum.mackay@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 530ea4219231 ("nfs: Referrals should use the same proto setting
as their parent") encloses the fix with #ifdef CONFIG_SUNRPC_XPRT_RDMA.

CONFIG_SUNRPC_XPRT_RDMA is a tristate option, so it should be tested
with #if IS_ENABLED().

Fixes: 530ea4219231 ("nfs: Referrals should use the same proto setting as their parent")
Reported-by: Helen Chao <helen.chao@oracle.com>
Tested-by: Helen Chao <helen.chao@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Bill Baker <bill.baker@oracle.com>
Signed-off-by: Calum Mackay <calum.mackay@oracle.com>
---
 fs/nfs/nfs4client.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 979631411a0e..d7124fb12041 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1127,7 +1127,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	nfs_server_copy_userdata(server, parent_server);
 
 	/* Get a client representation */
-#ifdef CONFIG_SUNRPC_XPRT_RDMA
+#if IS_ENABLED(CONFIG_SUNRPC_XPRT_RDMA)
 	rpc_set_port(data->addr, NFS_RDMA_PORT);
 	error = nfs4_set_client(server, data->hostname,
 				data->addr,
@@ -1139,7 +1139,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				parent_client->cl_net);
 	if (!error)
 		goto init_server;
-#endif	/* CONFIG_SUNRPC_XPRT_RDMA */
+#endif	/* IS_ENABLED(CONFIG_SUNRPC_XPRT_RDMA) */
 
 	rpc_set_port(data->addr, NFS_PORT);
 	error = nfs4_set_client(server, data->hostname,
@@ -1153,7 +1153,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-#ifdef CONFIG_SUNRPC_XPRT_RDMA
+#if IS_ENABLED(CONFIG_SUNRPC_XPRT_RDMA)
 init_server:
 #endif
 	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
-- 
2.9.3

