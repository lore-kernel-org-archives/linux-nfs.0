Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5792 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdJXRre (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Oct 2017 13:47:34 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 08/12] NFS handle COPY reply CB_OFFLOAD call race
Date: Tue, 24 Oct 2017 13:47:21 -0400
Message-ID: <20171024174725.74870-9-kolga@netapp.com>
In-Reply-To: <20171024174725.74870-1-kolga@netapp.com>
References: <20171024174725.74870-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that server replies back with CB_OFFLOAD call and
COPY reply at the same time such that client will process
CB_OFFLOAD before reply to COPY. For that keep a list of pending
callback stateids received and then before waiting on completion
check the pending list.

Cleanup any pending copies on the client shutdown.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c    | 17 ++++++++++++++---
 fs/nfs/nfs42proc.c        | 22 ++++++++++++++++++++--
 fs/nfs/nfs4client.c       | 15 +++++++++++++++
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index d3e7b61..d546c9f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -676,11 +676,12 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 	struct cb_offloadargs *args = data;
 	struct nfs_server *server;
 	struct nfs4_copy_state *copy;
+	bool found = false;
 
+	spin_lock(&cps->clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
 				client_link) {
-		spin_lock(&server->nfs_client->cl_lock);
 		list_for_each_entry(copy, &server->ss_copies, copies) {
 			if (memcmp(args->coa_stateid.other,
 					copy->stateid.other,
@@ -688,13 +689,23 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 				continue;
 			nfs4_copy_cb_args(copy, args);
 			complete(&copy->completion);
-			spin_unlock(&server->nfs_client->cl_lock);
+			found = true;
 			goto out;
 		}
-		spin_unlock(&server->nfs_client->cl_lock);
 	}
 out:
 	rcu_read_unlock();
+	if (!found) {
+		copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+		if (!copy) {
+			spin_unlock(&cps->clp->cl_lock);
+			return -ENOMEM;
+		}
+		memcpy(&copy->stateid, &args->coa_stateid, NFS4_STATEID_SIZE);
+		nfs4_copy_cb_args(copy, args);
+		list_add_tail(&copy->copies, &cps->clp->pending_cb_stateids);
+	}
+	spin_unlock(&cps->clp->cl_lock);
 
 	return 0;
 }
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index f2d22f1..ed46578 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -138,14 +138,31 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 {
 	struct nfs4_copy_state *copy;
 	int status = NFS4_OK;
+	bool found_pending = false;
+
+	spin_lock(&server->nfs_client->cl_lock);
+	list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
+				copies) {
+		if (memcmp(&res->write_res.stateid, &copy->stateid,
+				NFS4_STATEID_SIZE))
+			continue;
+		found_pending = true;
+		list_del(&copy->copies);
+		break;
+	}
+	if (found_pending) {
+		spin_unlock(&server->nfs_client->cl_lock);
+		goto out;
+	}
 
 	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
-	if (!copy)
+	if (!copy) {
+		spin_unlock(&server->nfs_client->cl_lock);
 		return -ENOMEM;
+	}
 	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
 	init_completion(&copy->completion);
 
-	spin_lock(&server->nfs_client->cl_lock);
 	list_add_tail(&copy->copies, &server->ss_copies);
 	spin_unlock(&server->nfs_client->cl_lock);
 
@@ -153,6 +170,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	spin_lock(&server->nfs_client->cl_lock);
 	list_del_init(&copy->copies);
 	spin_unlock(&server->nfs_client->cl_lock);
+out:
 	*ret_count = copy->count;
 	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
 	status = -copy->error;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e9bea90..46d4649 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -156,9 +156,23 @@ struct rpc_clnt *
 	}
 }
 
+static void
+nfs4_cleanup_callback(struct nfs_client *clp)
+{
+	struct nfs4_copy_state *cp_state;
+
+	while (!list_empty(&clp->pending_cb_stateids)) {
+		cp_state = list_entry(clp->pending_cb_stateids.next,
+					struct nfs4_copy_state, copies);
+		list_del(&cp_state->copies);
+		kfree(cp_state);
+	}
+}
+
 void nfs41_shutdown_client(struct nfs_client *clp)
 {
 	if (nfs4_has_session(clp)) {
+		nfs4_cleanup_callback(clp);
 		nfs4_shutdown_ds_clients(clp);
 		nfs4_destroy_session(clp->cl_session);
 		nfs4_destroy_clientid(clp);
@@ -202,6 +216,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 #if IS_ENABLED(CONFIG_NFS_V4_1)
 	init_waitqueue_head(&clp->cl_lock_waitq);
 #endif
+	INIT_LIST_HEAD(&clp->pending_cb_stateids);
 	return clp;
 
 error:
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 511eefb..72f159e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -119,6 +119,7 @@ struct nfs_client {
 #endif
 
 	struct net		*cl_net;
+	struct list_head	pending_cb_stateids;
 };
 
 /*
-- 
1.8.3.1

