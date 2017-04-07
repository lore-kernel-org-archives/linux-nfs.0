Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2540 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933584AbdDGSQA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:00 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 17/34] NFS: Clean up nfs4_match_clientids()
Date: Fri, 7 Apr 2017 14:15:11 -0400
Message-ID: <20170407181528.2832-18-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

If we cut out the dprintk()s, then we don't even need this to be a
separate function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 19 ++-----------------
 1 file changed, 2 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8346ccbf2d52..39b8c38b6a68 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -583,21 +583,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 #ifdef CONFIG_NFS_V4_1
 /*
- * Returns true if the client IDs match
- */
-static bool nfs4_match_clientids(u64 a, u64 b)
-{
-	if (a != b) {
-		dprintk("NFS: --> %s client ID %llx does not match %llx\n",
-			__func__, a, b);
-		return false;
-	}
-	dprintk("NFS: --> %s client ID %llx matches %llx\n",
-		__func__, a, b);
-	return true;
-}
-
-/*
  * Returns true if the server major ids match
  */
 static bool
@@ -680,7 +665,7 @@ int nfs4_detect_session_trunking(struct nfs_client *clp,
 				 struct rpc_xprt *xprt)
 {
 	/* Check eir_clientid */
-	if (!nfs4_match_clientids(clp->cl_clientid, res->clientid))
+	if (clp->cl_clientid != res->clientid)
 		goto out_err;
 
 	/* Check eir_server_owner so_major_id */
@@ -765,7 +750,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos->cl_cons_state != NFS_CS_READY)
 			continue;
 
-		if (!nfs4_match_clientids(pos->cl_clientid, new->cl_clientid))
+		if (pos->cl_clientid != new->cl_clientid)
 			continue;
 
 		/*
-- 
2.12.2

