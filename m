Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaIRNNX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 09:13:23 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Stable Tree <stable@vger.kernel.org>
Subject: [PATCH] [V2] NFSv4: nfs4_state_manager() vs. nfs_server_remove_lists()
Date: Thu, 18 Sep 2014 09:13:17 -0400
Message-Id: <1411045997-3988-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a race between nfs4_state_manager() and
nfs_server_remove_lists() that happens during a nfsv3 mount.

The v3 mount notices there is already a supper block so
nfs_server_remove_lists() called which uses the nfs_client_lock
spin lock to synchronize access to the client list.

At the same time nfs4_state_manager() is running through
the client list looking for work to do, using the same
lock. When nfs4_state_manager() wins the race to the
list, a v3 client pointer is found and not ignored
properly which causes the panic.

Moving some protocol checks before the state checking
avoids the panic.

CC: Stable Tree <stable@vger.kernel.org>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/nfs4client.c | 38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 53e435a..ffdb28d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -482,6 +482,16 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
+
+		if (pos->rpc_ops != new->rpc_ops)
+			continue;
+
+		if (pos->cl_proto != new->cl_proto)
+			continue;
+
+		if (pos->cl_minorversion != new->cl_minorversion)
+			continue;
+
 		/* If "pos" isn't marked ready, we can't trust the
 		 * remaining fields in "pos" */
 		if (pos->cl_cons_state > NFS_CS_READY) {
@@ -501,15 +511,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		if (pos->cl_cons_state != NFS_CS_READY)
 			continue;
 
-		if (pos->rpc_ops != new->rpc_ops)
-			continue;
-
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
-		if (pos->cl_minorversion != new->cl_minorversion)
-			continue;
-
 		if (pos->cl_clientid != new->cl_clientid)
 			continue;
 
@@ -622,6 +623,16 @@ int nfs41_walk_client_list(struct nfs_client *new,
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
+
+		if (pos->rpc_ops != new->rpc_ops)
+			continue;
+
+		if (pos->cl_proto != new->cl_proto)
+			continue;
+
+		if (pos->cl_minorversion != new->cl_minorversion)
+			continue;
+
 		/* If "pos" isn't marked ready, we can't trust the
 		 * remaining fields in "pos", especially the client
 		 * ID and serverowner fields.  Wait for CREATE_SESSION
@@ -647,15 +658,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos->cl_cons_state != NFS_CS_READY)
 			continue;
 
-		if (pos->rpc_ops != new->rpc_ops)
-			continue;
-
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
-		if (pos->cl_minorversion != new->cl_minorversion)
-			continue;
-
 		if (!nfs4_match_clientids(pos, new))
 			continue;
 
-- 
1.8.3.1

