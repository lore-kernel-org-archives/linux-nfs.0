Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:63829 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab3LJLOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 06:14:41 -0500
Message-ID: <52A6F6C9.90704@huawei.com>
Date: Tue, 10 Dec 2013 19:11:05 +0800
From: Rui Xiang <rui.xiang@huawei.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4.1: remove unused cred parameter from nfs41_walk_client_list
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean Up.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 fs/nfs/internal.h   | 3 +--
 fs/nfs/nfs4client.c | 4 +---
 fs/nfs/nfs4state.c  | 2 +-
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b5cc04..cdcfc8f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -482,8 +482,7 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
 extern int nfs41_walk_client_list(struct nfs_client *clp,
-				struct nfs_client **result,
-				struct rpc_cred *cred);
+				struct nfs_client **result);
 
 /*
  * Determine the device name as a string
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b4a160a..4db9b38 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -596,7 +596,6 @@ out_major_mismatch:
  *
  * @new: nfs_client with client ID to test
  * @result: OUT: found nfs_client, or new
- * @cred: credential to use for trunking test
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status.
  * If zero is returned, an nfs_client pointer is planted in "result."
@@ -605,8 +604,7 @@ out_major_mismatch:
  *     the last nfs_client on the list.
  */
 int nfs41_walk_client_list(struct nfs_client *new,
-			   struct nfs_client **result,
-			   struct rpc_cred *cred)
+			   struct nfs_client **result)
 {
 	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
 	struct nfs_client *pos, *prev = NULL;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 059c01b..268a17a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -348,7 +348,7 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 		return status;
 	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 
-	return nfs41_walk_client_list(clp, result, cred);
+	return nfs41_walk_client_list(clp, result);
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.8.2.2


