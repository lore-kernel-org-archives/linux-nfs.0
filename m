From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/5] NFSv4: Clean up struct nfs4_state_owner
Date: Wed, 30 Jun 2010 17:25:33 -0400
Message-ID: <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757272Ab0F3VZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:54 -0400
In-Reply-To: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'so_delegations' list appears to be unused.

Also eliminate so_client. If we already have so_server, we can get to the
nfs_client structure.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 --
 fs/nfs/nfs4proc.c  |    2 +-
 fs/nfs/nfs4state.c |   14 ++++++--------
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a986f13..cee8714 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -108,7 +108,6 @@ struct nfs_unique_id {
  */
 struct nfs4_state_owner {
 	struct nfs_unique_id so_owner_id;
-	struct nfs_client    *so_client;
 	struct nfs_server    *so_server;
 	struct rb_node	     so_client_node;
 
@@ -118,7 +117,6 @@ struct nfs4_state_owner {
 	atomic_t	     so_count;
 	unsigned long	     so_flags;
 	struct list_head     so_states;
-	struct list_head     so_delegations;
 	struct nfs_seqid_counter so_seqid;
 	struct rpc_sequence  so_sequence;
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 243d6c7..de9ff15 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1350,7 +1350,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	}
 	/* Update sequence id. */
 	data->o_arg.id = sp->so_owner_id.id;
-	data->o_arg.clientid = sp->so_client->cl_clientid;
+	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c3c6b8a..13e17e3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -373,7 +373,6 @@ nfs4_alloc_state_owner(void)
 		return NULL;
 	spin_lock_init(&sp->so_lock);
 	INIT_LIST_HEAD(&sp->so_states);
-	INIT_LIST_HEAD(&sp->so_delegations);
 	rpc_init_wait_queue(&sp->so_sequence.wait, "Seqid_waitqueue");
 	sp->so_seqid.sequence = &sp->so_sequence;
 	spin_lock_init(&sp->so_sequence.lock);
@@ -386,7 +385,7 @@ static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
 	if (!RB_EMPTY_NODE(&sp->so_client_node)) {
-		struct nfs_client *clp = sp->so_client;
+		struct nfs_client *clp = sp->so_server->nfs_client;
 
 		spin_lock(&clp->cl_lock);
 		rb_erase(&sp->so_client_node, &clp->cl_state_owners);
@@ -408,7 +407,6 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
 	new = nfs4_alloc_state_owner();
 	if (new == NULL)
 		return NULL;
-	new->so_client = clp;
 	new->so_server = server;
 	new->so_cred = cred;
 	spin_lock(&clp->cl_lock);
@@ -425,7 +423,7 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
 
 void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 {
-	struct nfs_client *clp = sp->so_client;
+	struct nfs_client *clp = sp->so_server->nfs_client;
 	struct rpc_cred *cred = sp->so_cred;
 
 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
@@ -624,7 +622,7 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
 static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
 {
 	struct nfs4_lock_state *lsp;
-	struct nfs_client *clp = state->owner->so_client;
+	struct nfs_client *clp = state->owner->so_server->nfs_client;
 
 	lsp = kzalloc(sizeof(*lsp), GFP_NOFS);
 	if (lsp == NULL)
@@ -645,7 +643,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 
 static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 {
-	struct nfs_client *clp = lsp->ls_state->owner->so_client;
+	struct nfs_client *clp = lsp->ls_state->owner->so_server->nfs_client;
 
 	spin_lock(&clp->cl_lock);
 	nfs_free_unique_id(&clp->cl_lockowner_id, &lsp->ls_id);
@@ -1043,11 +1041,11 @@ restart:
 			case -NFS4ERR_BAD_STATEID:
 			case -NFS4ERR_RECLAIM_BAD:
 			case -NFS4ERR_RECLAIM_CONFLICT:
-				nfs4_state_mark_reclaim_nograce(sp->so_client, state);
+				nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
 				break;
 			case -NFS4ERR_EXPIRED:
 			case -NFS4ERR_NO_GRACE:
-				nfs4_state_mark_reclaim_nograce(sp->so_client, state);
+				nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_BADSESSION:
 			case -NFS4ERR_BADSLOT:
-- 
1.7.0.1

