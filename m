Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56868 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399Ab2JOVbk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:31:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/13] NFS: Get rid of unnecessary asserts
Date: Mon, 15 Oct 2012 17:30:53 -0400
Message-Id: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the nfs_client fails to initialise correctly, then it will
return an error condition.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c     | 6 +-----
 fs/nfs/nfs4client.c | 4 ----
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..c285e0a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -277,7 +277,7 @@ void nfs_put_client(struct nfs_client *clp)
 		nfs_cb_idr_remove_locked(clp);
 		spin_unlock(&nn->nfs_client_lock);
 
-		BUG_ON(!list_empty(&clp->cl_superblocks));
+		WARN_ON_ONCE(!list_empty(&clp->cl_superblocks));
 
 		clp->rpc_ops->free_client(clp);
 	}
@@ -1061,10 +1061,6 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	if (error < 0)
 		goto error;
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	/* Probe the root fh to retrieve its FSID */
 	error = nfs_probe_fsinfo(server, mount_info->mntfh, fattr);
 	if (error < 0)
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 6bacfde..72717e6 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -713,10 +713,6 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	struct nfs_fattr *fattr;
 	int error;
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	/* data servers support only a subset of NFSv4.1 */
 	if (is_ds_only_client(server->nfs_client))
 		return -EPROTONOSUPPORT;
-- 
1.7.11.7

