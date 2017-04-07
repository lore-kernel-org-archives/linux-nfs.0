Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:5551 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933093AbdDGSPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:51 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/34] NFS: Clean up nfs_init_client()
Date: Fri, 7 Apr 2017 14:15:05 -0400
Message-ID: <20170407181528.2832-12-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We always call nfs_mark_client_ready() even if nfs_create_rpc_client()
returns an error, so we can rearrange nfs_init_client() to mark the
client ready from a single place.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/client.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 390ada8741bc..675142189181 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -624,27 +624,21 @@ struct nfs_client *nfs_init_client(struct nfs_client *clp,
 {
 	int error;
 
-	if (clp->cl_cons_state == NFS_CS_READY) {
-		/* the client is already initialised */
-		dprintk("<-- nfs_init_client() = 0 [already %p]\n", clp);
+	/* the client is already initialised */
+	if (clp->cl_cons_state == NFS_CS_READY)
 		return clp;
-	}
 
 	/*
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
 	error = nfs_create_rpc_client(clp, cl_init, RPC_AUTH_UNIX);
-	if (error < 0)
-		goto error;
-	nfs_mark_client_ready(clp, NFS_CS_READY);
+	nfs_mark_client_ready(clp, error == 0 ? NFS_CS_READY : error);
+	if (error < 0) {
+		nfs_put_client(clp);
+		clp = ERR_PTR(error);
+	}
 	return clp;
-
-error:
-	nfs_mark_client_ready(clp, error);
-	nfs_put_client(clp);
-	dprintk("<-- nfs_init_client() = xerror %d\n", error);
-	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(nfs_init_client);
 
-- 
2.12.2

