Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:5551 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932552AbdDGSP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:59 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 18/34] NFS: Clean up nfs4_check_serverowner_minor_id()
Date: Fri, 7 Apr 2017 14:15:12 -0400
Message-ID: <20170407181528.2832-19-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Once again, we can remove the function and compare integer values
directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 39b8c38b6a68..4f4f179cb849 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -604,25 +604,6 @@ nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
 }
 
 /*
- * Returns true if server minor ids match
- */
-static bool
-nfs4_check_serverowner_minor_id(struct nfs41_server_owner *o1,
-				struct nfs41_server_owner *o2)
-{
-	/* Check eir_server_owner so_minor_id */
-	if (o1->minor_id != o2->minor_id)
-		goto out_minor_mismatch;
-
-	dprintk("NFS: --> %s server owner minor IDs match\n", __func__);
-	return true;
-
-out_minor_mismatch:
-	dprintk("NFS: --> %s server owner minor IDs do not match\n", __func__);
-	return false;
-}
-
-/*
  * Returns true if the server scopes match
  */
 static bool
@@ -674,8 +655,7 @@ int nfs4_detect_session_trunking(struct nfs_client *clp,
 		goto out_err;
 
 	/* Check eir_server_owner so_minor_id */
-	if (!nfs4_check_serverowner_minor_id(clp->cl_serverowner,
-					     res->server_owner))
+	if (clp->cl_serverowner->minor_id != res->server_owner->minor_id)
 		goto out_err;
 
 	/* Check eir_server_scope */
-- 
2.12.2

