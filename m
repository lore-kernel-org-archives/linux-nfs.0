Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162700Ab3DEVQe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list
Date: Fri,  5 Apr 2013 17:16:28 -0400
Message-Id: <1365196588-25403-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365196588-25403-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365196588-25403-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is unsafe to use list_for_each_entry_safe() here, because
when we drop the nn->nfs_client_lock, we pin the _current_ list
entry and ensure that it stays in the list, but we don't do the
same for the _next_ list entry. Use of list_for_each_entry() is
therefore the correct thing to do.

Also fix the refcounting in nfs41_walk_client_list().

Finally, ensure that the nfs_client has finished being initialised
and, in the case of NFSv4.1, that the session is set up.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: stable@vger.kernel.org [>= 3.7]
---
 fs/nfs/nfs4client.c | 44 ++++++++++++++++++++++++++++----------------
 1 file changed, 28 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ac4fc9a..c7b346f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -300,7 +300,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			   struct rpc_cred *cred)
 {
 	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
-	struct nfs_client *pos, *n, *prev = NULL;
+	struct nfs_client *pos, *prev = NULL;
 	struct nfs4_setclientid_res clid = {
 		.clientid	= new->cl_clientid,
 		.confirm	= new->cl_confirm,
@@ -308,10 +308,23 @@ int nfs40_walk_client_list(struct nfs_client *new,
 	int status = -NFS4ERR_STALE_CLIENTID;
 
 	spin_lock(&nn->nfs_client_lock);
-	list_for_each_entry_safe(pos, n, &nn->nfs_client_list, cl_share_link) {
+	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
 		/* If "pos" isn't marked ready, we can't trust the
 		 * remaining fields in "pos" */
-		if (pos->cl_cons_state < NFS_CS_READY)
+		if (pos->cl_cons_state > NFS_CS_READY) {
+			atomic_inc(&pos->cl_count);
+			spin_unlock(&nn->nfs_client_lock);
+
+			if (prev)
+				nfs_put_client(prev);
+			prev = pos;
+
+			status = nfs_wait_client_init_complete(pos);
+			spin_lock(&nn->nfs_client_lock);
+			if (status < 0)
+				continue;
+		}
+		if (pos->cl_cons_state != NFS_CS_READY)
 			continue;
 
 		if (pos->rpc_ops != new->rpc_ops)
@@ -423,16 +436,16 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			   struct rpc_cred *cred)
 {
 	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
-	struct nfs_client *pos, *n, *prev = NULL;
+	struct nfs_client *pos, *prev = NULL;
 	int status = -NFS4ERR_STALE_CLIENTID;
 
 	spin_lock(&nn->nfs_client_lock);
-	list_for_each_entry_safe(pos, n, &nn->nfs_client_list, cl_share_link) {
+	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
 		/* If "pos" isn't marked ready, we can't trust the
 		 * remaining fields in "pos", especially the client
 		 * ID and serverowner fields.  Wait for CREATE_SESSION
 		 * to finish. */
-		if (pos->cl_cons_state < NFS_CS_READY) {
+		if (pos->cl_cons_state > NFS_CS_READY) {
 			atomic_inc(&pos->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
 
@@ -440,18 +453,17 @@ int nfs41_walk_client_list(struct nfs_client *new,
 				nfs_put_client(prev);
 			prev = pos;
 
-			nfs4_schedule_lease_recovery(pos);
 			status = nfs_wait_client_init_complete(pos);
-			if (status < 0) {
-				nfs_put_client(pos);
-				spin_lock(&nn->nfs_client_lock);
-				continue;
+			if (status == 0) {
+				nfs4_schedule_lease_recovery(pos);
+				status = nfs4_wait_clnt_recover(pos);
 			}
-			status = pos->cl_cons_state;
 			spin_lock(&nn->nfs_client_lock);
 			if (status < 0)
 				continue;
 		}
+		if (pos->cl_cons_state != NFS_CS_READY)
+			continue;
 
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
@@ -469,17 +481,17 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			continue;
 
 		atomic_inc(&pos->cl_count);
-		spin_unlock(&nn->nfs_client_lock);
+		*result = pos;
 		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
 			__func__, pos, atomic_read(&pos->cl_count));
-
-		*result = pos;
-		return 0;
+		break;
 	}
 
 	/* No matching nfs_client found. */
 	spin_unlock(&nn->nfs_client_lock);
 	dprintk("NFS: <-- %s status = %d\n", __func__, status);
+	if (prev)
+		nfs_put_client(prev);
 	return status;
 }
 #endif	/* CONFIG_NFS_V4_1 */
-- 
1.8.1.4

