Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40181 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756988Ab2ARERh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 23:17:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/10] NFS: Move struct nfs_unique_id into struct nfs_seqid_counter
Date: Tue, 17 Jan 2012 23:17:10 -0500
Message-Id: <1326860233-27947-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326860233-27947-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-3-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-4-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-5-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    8 ++++++--
 fs/nfs/nfs4proc.c  |   10 +++++-----
 fs/nfs/nfs4state.c |   10 +++++-----
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cef9d5d..b7e5a1d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -53,8 +53,14 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
 };
 
+struct nfs_unique_id {
+	struct rb_node rb_node;
+	__u64 id;
+};
+
 #define NFS_SEQID_CONFIRMED 1
 struct nfs_seqid_counter {
+	int owner_id;
 	int flags;
 	u32 counter;
 	spinlock_t lock;		/* Protects the list */
@@ -91,7 +97,6 @@ struct nfs4_state_owner {
 	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
-	int		     so_owner_id;
 };
 
 enum {
@@ -131,7 +136,6 @@ struct nfs4_lock_state {
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 1
 	int			ls_flags;
-	int			ls_id;
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3233ee0..7d431d7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -824,7 +824,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
-	p->o_arg.id = sp->so_owner_id;
+	p->o_arg.id = sp->so_seqid.owner_id;
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
@@ -1449,7 +1449,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		rcu_read_unlock();
 	}
 	/* Update sequence id. */
-	data->o_arg.id = sp->so_owner_id;
+	data->o_arg.id = sp->so_seqid.owner_id;
 	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
@@ -4032,7 +4032,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
-	arg.lock_owner.id = lsp->ls_id;
+	arg.lock_owner.id = lsp->ls_seqid.owner_id;
 	arg.lock_owner.s_dev = server->s_dev;
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
@@ -4278,7 +4278,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 		goto out_free_seqid;
 	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
-	p->arg.lock_owner.id = lsp->ls_id;
+	p->arg.lock_owner.id = lsp->ls_seqid.owner_id;
 	p->arg.lock_owner.s_dev = server->s_dev;
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
@@ -4696,7 +4696,7 @@ void nfs4_release_lockowner(const struct nfs4_lock_state *lsp)
 	if (!args)
 		return;
 	args->lock_owner.clientid = server->nfs_client->cl_clientid;
-	args->lock_owner.id = lsp->ls_id;
+	args->lock_owner.id = lsp->ls_seqid.owner_id;
 	args->lock_owner.s_dev = server->s_dev;
 	msg.rpc_argp = args;
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, args);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cf7bc39..a42e60d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -366,7 +366,7 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
 			return sp;
 		}
 	}
-	err = ida_get_new(&server->openowner_id, &new->so_owner_id);
+	err = ida_get_new(&server->openowner_id, &new->so_seqid.owner_id);
 	if (err)
 		return ERR_PTR(err);
 	rb_link_node(&new->so_server_node, parent, p);
@@ -381,7 +381,7 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
 
 	if (!RB_EMPTY_NODE(&sp->so_server_node))
 		rb_erase(&sp->so_server_node, &server->state_owners);
-	ida_remove(&server->openowner_id, sp->so_owner_id);
+	ida_remove(&server->openowner_id, sp->so_seqid.owner_id);
 }
 
 static void
@@ -775,8 +775,8 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	default:
 		goto out_free;
 	}
-	lsp->ls_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
-	if (lsp->ls_id < 0)
+	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
+	if (lsp->ls_seqid.owner_id < 0)
 		goto out_free;
 	INIT_LIST_HEAD(&lsp->ls_locks);
 	return lsp;
@@ -789,7 +789,7 @@ static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 {
 	struct nfs_server *server = lsp->ls_state->owner->so_server;
 
-	ida_simple_remove(&server->lockowner_id, lsp->ls_id);
+	ida_simple_remove(&server->lockowner_id, lsp->ls_seqid.owner_id);
 	nfs4_destroy_seqid_counter(&lsp->ls_seqid);
 	kfree(lsp);
 }
-- 
1.7.7.5

