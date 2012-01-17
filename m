Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53625 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405Ab2AQTNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:13:42 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFSv4: Move contents of struct rpc_sequence into struct nfs_seqid_counter
Date: Tue, 17 Jan 2012 14:13:31 -0500
Message-Id: <1326827613-7997-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326827613-7997-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1326827613-7997-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-3-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-4-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |   16 +++-------------
 fs/nfs/nfs4state.c |   36 +++++++++++++++++++++++-------------
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 583ded0..cef9d5d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -53,21 +53,13 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
 };
 
-/*
- * struct rpc_sequence ensures that RPC calls are sent in the exact
- * order that they appear on the list.
- */
-struct rpc_sequence {
-	struct rpc_wait_queue	wait;	/* RPC call delay queue */
-	spinlock_t lock;		/* Protects the list */
-	struct list_head list;		/* Defines sequence of RPC calls */
-};
-
 #define NFS_SEQID_CONFIRMED 1
 struct nfs_seqid_counter {
-	struct rpc_sequence *sequence;
 	int flags;
 	u32 counter;
+	spinlock_t lock;		/* Protects the list */
+	struct list_head list;		/* Defines sequence of RPC calls */
+	struct rpc_wait_queue	wait;	/* RPC call delay queue */
 };
 
 struct nfs_seqid {
@@ -99,7 +91,6 @@ struct nfs4_state_owner {
 	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
-	struct rpc_sequence  so_sequence;
 	int		     so_owner_id;
 };
 
@@ -142,7 +133,6 @@ struct nfs4_lock_state {
 	int			ls_flags;
 	int			ls_id;
 	struct nfs_seqid_counter	ls_seqid;
-	struct rpc_sequence	ls_sequence;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
 	struct nfs4_lock_owner	ls_owner;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5abf236..cf7bc39 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -384,6 +384,22 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
 	ida_remove(&server->openowner_id, sp->so_owner_id);
 }
 
+static void
+nfs4_init_seqid_counter(struct nfs_seqid_counter *sc)
+{
+	sc->flags = 0;
+	sc->counter = 0;
+	spin_lock_init(&sc->lock);
+	INIT_LIST_HEAD(&sc->list);
+	rpc_init_wait_queue(&sc->wait, "Seqid_waitqueue");
+}
+
+static void
+nfs4_destroy_seqid_counter(struct nfs_seqid_counter *sc)
+{
+	rpc_destroy_wait_queue(&sc->wait);
+}
+
 /*
  * nfs4_alloc_state_owner(): this is called on the OPEN or CREATE path to
  * create a new state_owner.
@@ -403,10 +419,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	sp->so_cred = get_rpccred(cred);
 	spin_lock_init(&sp->so_lock);
 	INIT_LIST_HEAD(&sp->so_states);
-	rpc_init_wait_queue(&sp->so_sequence.wait, "Seqid_waitqueue");
-	sp->so_seqid.sequence = &sp->so_sequence;
-	spin_lock_init(&sp->so_sequence.lock);
-	INIT_LIST_HEAD(&sp->so_sequence.list);
+	nfs4_init_seqid_counter(&sp->so_seqid);
 	atomic_set(&sp->so_count, 1);
 	INIT_LIST_HEAD(&sp->so_lru);
 	return sp;
@@ -428,7 +441,7 @@ nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
 {
-	rpc_destroy_wait_queue(&sp->so_sequence.wait);
+	nfs4_destroy_seqid_counter(&sp->so_seqid);
 	put_rpccred(sp->so_cred);
 	kfree(sp);
 }
@@ -748,10 +761,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	lsp = kzalloc(sizeof(*lsp), GFP_NOFS);
 	if (lsp == NULL)
 		return NULL;
-	rpc_init_wait_queue(&lsp->ls_sequence.wait, "lock_seqid_waitqueue");
-	spin_lock_init(&lsp->ls_sequence.lock);
-	INIT_LIST_HEAD(&lsp->ls_sequence.list);
-	lsp->ls_seqid.sequence = &lsp->ls_sequence;
+	nfs4_init_seqid_counter(&lsp->ls_seqid);
 	atomic_set(&lsp->ls_count, 1);
 	lsp->ls_state = state;
 	lsp->ls_owner.lo_type = type;
@@ -780,7 +790,7 @@ static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 	struct nfs_server *server = lsp->ls_state->owner->so_server;
 
 	ida_simple_remove(&server->lockowner_id, lsp->ls_id);
-	rpc_destroy_wait_queue(&lsp->ls_sequence.wait);
+	nfs4_destroy_seqid_counter(&lsp->ls_seqid);
 	kfree(lsp);
 }
 
@@ -914,7 +924,7 @@ struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_m
 void nfs_release_seqid(struct nfs_seqid *seqid)
 {
 	if (!list_empty(&seqid->list)) {
-		struct rpc_sequence *sequence = seqid->sequence->sequence;
+		struct nfs_seqid_counter *sequence = seqid->sequence;
 
 		spin_lock(&sequence->lock);
 		list_del_init(&seqid->list);
@@ -936,7 +946,7 @@ void nfs_free_seqid(struct nfs_seqid *seqid)
  */
 static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 {
-	BUG_ON(list_first_entry(&seqid->sequence->sequence->list, struct nfs_seqid, list) != seqid);
+	BUG_ON(list_first_entry(&seqid->sequence->list, struct nfs_seqid, list) != seqid);
 	switch (status) {
 		case 0:
 			break;
@@ -987,7 +997,7 @@ void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid)
 
 int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 {
-	struct rpc_sequence *sequence = seqid->sequence->sequence;
+	struct nfs_seqid_counter *sequence = seqid->sequence;
 	int status = 0;
 
 	spin_lock(&sequence->lock);
-- 
1.7.7.5

