Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:53251 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169AbaBKThO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:14 -0500
Received: by mail-ig0-f170.google.com with SMTP id m12so100805iga.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Refactor NFS sequence id counter
Date: Tue, 11 Feb 2014 14:37:05 -0500
Message-Id: <1392147428-23087-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
References: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More preparatory work for the NFSv4.1 parallel OPEN capability.

Refactor the code that deals with sequence ids to separate out the
bits that deal with serialisation, and convert those into separate
locking structures.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h   |  18 ++++++---
 fs/nfs/nfs4state.c | 116 +++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 95 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index df81fcc138a7..cd24d9d79830 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -63,21 +63,29 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_mig_recovery_ops *mig_recovery_ops;
 };
 
+struct nfs4_stateid_lock {
+	spinlock_t lock;		/* Protects the list */
+	struct list_head list;		/* Defines sequence of RPC calls */
+	struct rpc_wait_queue	wait;	/* RPC call delay queue */
+};
+
+struct nfs4_stateid_lock_wait {
+	struct list_head list;
+	struct rpc_task *task;
+};
+
 #define NFS_SEQID_CONFIRMED 1
 struct nfs_seqid_counter {
 	ktime_t create_time;
 	int owner_id;
 	int flags;
 	u32 counter;
-	spinlock_t lock;		/* Protects the list */
-	struct list_head list;		/* Defines sequence of RPC calls */
-	struct rpc_wait_queue	wait;	/* RPC call delay queue */
+	struct nfs4_stateid_lock st_lock;
 };
 
 struct nfs_seqid {
 	struct nfs_seqid_counter *sequence;
-	struct list_head list;
-	struct rpc_task *task;
+	struct nfs4_stateid_lock_wait wait;
 };
 
 static inline void nfs_confirm_seqid(struct nfs_seqid_counter *seqid, int status)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e5be72518bd7..73c7c9ce6f75 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -437,20 +437,91 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
 }
 
 static void
+nfs4_init_stateid_lock(struct nfs4_stateid_lock *st_lock)
+{
+	spin_lock_init(&st_lock->lock);
+	INIT_LIST_HEAD(&st_lock->list);
+	rpc_init_wait_queue(&st_lock->wait, "Seqid_waitqueue");
+}
+
+static void
+nfs4_destroy_stateid_lock(struct nfs4_stateid_lock *st_lock)
+{
+	rpc_destroy_wait_queue(&st_lock->wait);
+}
+
+static bool
+nfs4_stateid_lock_is_blocked(struct nfs4_stateid_lock *st_lock)
+{
+	return !list_empty(&st_lock->list);
+}
+
+static void
+nfs4_stateid_lock_wake_next_locked(struct nfs4_stateid_lock *st_lock)
+{
+	struct nfs4_stateid_lock_wait *next;
+
+	if (list_empty(&st_lock->list))
+		return;
+
+	next = list_first_entry(&st_lock->list,
+				struct nfs4_stateid_lock_wait,
+				list);
+	rpc_wake_up_queued_task(&st_lock->wait, next->task);
+}
+
+static void
+nfs4_stateid_lock_wait_init(struct nfs4_stateid_lock_wait *wait)
+{
+	INIT_LIST_HEAD(&wait->list);
+	wait->task = NULL;
+}
+
+static int
+nfs4_stateid_lock_wait_begin(struct nfs4_stateid_lock *st_lock,
+		struct nfs4_stateid_lock_wait *wait,
+		struct rpc_task *task)
+{
+	int status = 0;
+
+	spin_lock(&st_lock->lock);
+	wait->task = task;
+	if (list_empty(&wait->list))
+		list_add_tail(&wait->list, &st_lock->list);
+	if (list_first_entry(&st_lock->list, struct nfs4_stateid_lock_wait, list) == wait)
+		goto unlock;
+	rpc_sleep_on(&st_lock->wait, task, NULL);
+	status = -EAGAIN;
+unlock:
+	spin_unlock(&st_lock->lock);
+	return status;
+}
+
+static void
+nfs4_stateid_lock_wait_end(struct nfs4_stateid_lock *st_lock,
+		struct nfs4_stateid_lock_wait *wait)
+{
+	if (list_empty(&wait->list))
+		return;
+	spin_lock(&st_lock->lock);
+	list_del_init(&wait->list);
+	nfs4_stateid_lock_wake_next_locked(st_lock);
+	spin_unlock(&st_lock->lock);
+}
+
+static void
 nfs4_init_seqid_counter(struct nfs_seqid_counter *sc)
 {
 	sc->create_time = ktime_get();
 	sc->flags = 0;
 	sc->counter = 0;
-	spin_lock_init(&sc->lock);
-	INIT_LIST_HEAD(&sc->list);
-	rpc_init_wait_queue(&sc->wait, "Seqid_waitqueue");
+	nfs4_init_stateid_lock(&sc->st_lock);
 }
 
 static void
 nfs4_destroy_seqid_counter(struct nfs_seqid_counter *sc)
 {
-	rpc_destroy_wait_queue(&sc->wait);
+	nfs4_destroy_stateid_lock(&sc->st_lock);
 }
 
 /*
@@ -975,7 +1046,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		nfs4_stateid_copy(dst, &lsp->ls_stateid);
 		ret = 0;
 		smp_rmb();
-		if (!list_empty(&lsp->ls_seqid.list))
+		if (nfs4_stateid_lock_is_blocked(&lsp->ls_seqid.st_lock))
 			ret = -EWOULDBLOCK;
 	}
 	spin_unlock(&state->state_lock);
@@ -998,7 +1069,7 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 		nfs4_stateid_copy(dst, src);
 		ret = 0;
 		smp_rmb();
-		if (!list_empty(&state->owner->so_seqid.list))
+		if (nfs4_stateid_lock_is_blocked(&state->owner->so_seqid.st_lock))
 			ret = -EWOULDBLOCK;
 	} while (read_seqretry(&state->seqlock, seq));
 	return ret;
@@ -1037,29 +1108,16 @@ struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_m
 	new = kmalloc(sizeof(*new), gfp_mask);
 	if (new != NULL) {
 		new->sequence = counter;
-		INIT_LIST_HEAD(&new->list);
-		new->task = NULL;
+		nfs4_stateid_lock_wait_init(&new->wait);
 	}
 	return new;
 }
 
 void nfs_release_seqid(struct nfs_seqid *seqid)
 {
-	struct nfs_seqid_counter *sequence;
+	struct nfs_seqid_counter *sequence = seqid->sequence;
 
-	if (list_empty(&seqid->list))
-		return;
-	sequence = seqid->sequence;
-	spin_lock(&sequence->lock);
-	list_del_init(&seqid->list);
-	if (!list_empty(&sequence->list)) {
-		struct nfs_seqid *next;
-
-		next = list_first_entry(&sequence->list,
-				struct nfs_seqid, list);
-		rpc_wake_up_queued_task(&sequence->wait, next->task);
-	}
-	spin_unlock(&sequence->lock);
+	nfs4_stateid_lock_wait_end(&sequence->st_lock, &seqid->wait);
 }
 
 void nfs_free_seqid(struct nfs_seqid *seqid)
@@ -1126,19 +1184,9 @@ void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid)
 int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 {
 	struct nfs_seqid_counter *sequence = seqid->sequence;
-	int status = 0;
 
-	spin_lock(&sequence->lock);
-	seqid->task = task;
-	if (list_empty(&seqid->list))
-		list_add_tail(&seqid->list, &sequence->list);
-	if (list_first_entry(&sequence->list, struct nfs_seqid, list) == seqid)
-		goto unlock;
-	rpc_sleep_on(&sequence->wait, task, NULL);
-	status = -EAGAIN;
-unlock:
-	spin_unlock(&sequence->lock);
-	return status;
+	return nfs4_stateid_lock_wait_begin(&sequence->st_lock,
+			&seqid->wait, task);
 }
 
 static int nfs4_run_state_manager(void *);
-- 
1.8.5.3

