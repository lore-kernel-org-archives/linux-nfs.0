Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53618 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab2AQTNl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:13:41 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFSv4: Replace lock_owner->ld_id with an ida based allocator
Date: Tue, 17 Jan 2012 14:13:29 -0500
Message-Id: <1326827613-7997-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326827613-7997-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1326827613-7997-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again, We're unlikely to ever need more than 2^31 simultaneous lock
owners, so let's replace the custom allocator.

Now that there are no more users, we can also get rid of the custom
allocator code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           |    2 +
 fs/nfs/nfs4_fs.h          |    7 +----
 fs/nfs/nfs4proc.c         |    6 ++--
 fs/nfs/nfs4state.c        |   74 +++++----------------------------------------
 include/linux/nfs_fs_sb.h |    2 +-
 5 files changed, 15 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8d1739d..df60d99 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1093,6 +1093,7 @@ static struct nfs_server *nfs_alloc_server(void)
 	}
 
 	ida_init(&server->openowner_id);
+	ida_init(&server->lockowner_id);
 	pnfs_init_server(server);
 
 	return server;
@@ -1118,6 +1119,7 @@ void nfs_free_server(struct nfs_server *server)
 
 	nfs_put_client(server->nfs_client);
 
+	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
 	bdi_destroy(&server->backing_dev_info);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a754f47..2d1f5a5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -81,11 +81,6 @@ static inline void nfs_confirm_seqid(struct nfs_seqid_counter *seqid, int status
 		seqid->flags |= NFS_SEQID_CONFIRMED;
 }
 
-struct nfs_unique_id {
-	struct rb_node rb_node;
-	__u64 id;
-};
-
 /*
  * NFS4 state_owners and lock_owners are simply labels for ordered
  * sequences of RPC calls. Their sole purpose is to provide once-only
@@ -145,9 +140,9 @@ struct nfs4_lock_state {
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 1
 	int			ls_flags;
+	int			ls_id;
 	struct nfs_seqid_counter	ls_seqid;
 	struct rpc_sequence	ls_sequence;
-	struct nfs_unique_id	ls_id;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
 	struct nfs4_lock_owner	ls_owner;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ddedf0..7ccc12d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4016,7 +4016,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
-	arg.lock_owner.id = lsp->ls_id.id;
+	arg.lock_owner.id = lsp->ls_id;
 	arg.lock_owner.s_dev = server->s_dev;
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
@@ -4261,7 +4261,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 		goto out_free_seqid;
 	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
-	p->arg.lock_owner.id = lsp->ls_id.id;
+	p->arg.lock_owner.id = lsp->ls_id;
 	p->arg.lock_owner.s_dev = server->s_dev;
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
@@ -4678,7 +4678,7 @@ void nfs4_release_lockowner(const struct nfs4_lock_state *lsp)
 	if (!args)
 		return;
 	args->lock_owner.clientid = server->nfs_client->cl_clientid;
-	args->lock_owner.id = lsp->ls_id.id;
+	args->lock_owner.id = lsp->ls_id;
 	args->lock_owner.s_dev = server->s_dev;
 	msg.rpc_argp = args;
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, args);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8472707..5abf236 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -317,62 +317,6 @@ out:
 	return cred;
 }
 
-static void nfs_alloc_unique_id_locked(struct rb_root *root,
-				       struct nfs_unique_id *new,
-				       __u64 minval, int maxbits)
-{
-	struct rb_node **p, *parent;
-	struct nfs_unique_id *pos;
-	__u64 mask = ~0ULL;
-
-	if (maxbits < 64)
-		mask = (1ULL << maxbits) - 1ULL;
-
-	/* Ensure distribution is more or less flat */
-	get_random_bytes(&new->id, sizeof(new->id));
-	new->id &= mask;
-	if (new->id < minval)
-		new->id += minval;
-retry:
-	p = &root->rb_node;
-	parent = NULL;
-
-	while (*p != NULL) {
-		parent = *p;
-		pos = rb_entry(parent, struct nfs_unique_id, rb_node);
-
-		if (new->id < pos->id)
-			p = &(*p)->rb_left;
-		else if (new->id > pos->id)
-			p = &(*p)->rb_right;
-		else
-			goto id_exists;
-	}
-	rb_link_node(&new->rb_node, parent, p);
-	rb_insert_color(&new->rb_node, root);
-	return;
-id_exists:
-	for (;;) {
-		new->id++;
-		if (new->id < minval || (new->id & mask) != new->id) {
-			new->id = minval;
-			break;
-		}
-		parent = rb_next(parent);
-		if (parent == NULL)
-			break;
-		pos = rb_entry(parent, struct nfs_unique_id, rb_node);
-		if (new->id < pos->id)
-			break;
-	}
-	goto retry;
-}
-
-static void nfs_free_unique_id(struct rb_root *root, struct nfs_unique_id *id)
-{
-	rb_erase(&id->rb_node, root);
-}
-
 static struct nfs4_state_owner *
 nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
 {
@@ -800,7 +744,6 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 {
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = state->owner->so_server;
-	struct nfs_client *clp = server->nfs_client;
 
 	lsp = kzalloc(sizeof(*lsp), GFP_NOFS);
 	if (lsp == NULL)
@@ -820,24 +763,23 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 		lsp->ls_owner.lo_u.posix_owner = fl_owner;
 		break;
 	default:
-		kfree(lsp);
-		return NULL;
+		goto out_free;
 	}
-	spin_lock(&clp->cl_lock);
-	nfs_alloc_unique_id_locked(&server->lockowner_id, &lsp->ls_id, 1, 64);
-	spin_unlock(&clp->cl_lock);
+	lsp->ls_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
+	if (lsp->ls_id < 0)
+		goto out_free;
 	INIT_LIST_HEAD(&lsp->ls_locks);
 	return lsp;
+out_free:
+	kfree(lsp);
+	return NULL;
 }
 
 static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 {
 	struct nfs_server *server = lsp->ls_state->owner->so_server;
-	struct nfs_client *clp = server->nfs_client;
 
-	spin_lock(&clp->cl_lock);
-	nfs_free_unique_id(&server->lockowner_id, &lsp->ls_id);
-	spin_unlock(&clp->cl_lock);
+	ida_simple_remove(&server->lockowner_id, lsp->ls_id);
 	rpc_destroy_wait_queue(&lsp->ls_sequence.wait);
 	kfree(lsp);
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 645537e..c234693 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -152,9 +152,9 @@ struct nfs_server {
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
-	struct rb_root		lockowner_id;
 #endif
 	struct ida		openowner_id;
+	struct ida		lockowner_id;
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
-- 
1.7.7.5

