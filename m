Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:35137 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163AbaBKThQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:16 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so4876185iec.10
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:16 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Convert NFS sequence id lock into a shared/exclusive lock
Date: Tue, 11 Feb 2014 14:37:06 -0500
Message-Id: <1392147428-23087-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392147428-23087-3-git-send-email-trond.myklebust@primarydata.com>
References: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4.1, we want OPEN to be parallelised, while OPEN_DOWNGRADE/CLOSE
needs to be fully serialised with those OPENs. Do so by adding a
'shared lock' mode to the sequence ids.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h   |  6 ++++-
 fs/nfs/nfs4state.c | 64 +++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cd24d9d79830..04ca08dada68 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -65,13 +65,17 @@ struct nfs4_minor_version_ops {
 
 struct nfs4_stateid_lock {
 	spinlock_t lock;		/* Protects the list */
-	struct list_head list;		/* Defines sequence of RPC calls */
+	int n_active;			/* Number of active shared locks */
+					/* == -1 for an exclusive lock */
+	struct list_head list;		/* Waiting RPC calls */
 	struct rpc_wait_queue	wait;	/* RPC call delay queue */
 };
 
 struct nfs4_stateid_lock_wait {
 	struct list_head list;
 	struct rpc_task *task;
+	unsigned char active : 1,
+		      shared : 1;
 };
 
 #define NFS_SEQID_CONFIRMED 1
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 73c7c9ce6f75..d1fe275b6a36 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -441,6 +441,7 @@ nfs4_init_stateid_lock(struct nfs4_stateid_lock *st_lock)
 {
 	spin_lock_init(&st_lock->lock);
 	INIT_LIST_HEAD(&st_lock->list);
+	st_lock->n_active = 0;
 	rpc_init_wait_queue(&st_lock->wait, "Seqid_waitqueue");
 }
 
@@ -453,7 +454,25 @@ nfs4_destroy_stateid_lock(struct nfs4_stateid_lock *st_lock)
 static bool
 nfs4_stateid_lock_is_blocked(struct nfs4_stateid_lock *st_lock)
 {
-	return !list_empty(&st_lock->list);
+	return st_lock->n_active != 0;
+}
+
+static bool
+nfs4_stateid_lock_make_active(struct nfs4_stateid_lock *st_lock,
+		struct nfs4_stateid_lock_wait *wait)
+{
+	if (wait->shared) {
+		if (st_lock->n_active < 0)
+			return false;
+		st_lock->n_active++;
+	} else {
+		if (st_lock->n_active != 0)
+			return false;
+		st_lock->n_active = -1;
+	}
+	list_del_init(&wait->list);
+	wait->active = 1;
+	return true;
 }
 
 static void
@@ -461,13 +480,17 @@ nfs4_stateid_lock_wake_next_locked(struct nfs4_stateid_lock *st_lock)
 {
 	struct nfs4_stateid_lock_wait *next;
 
-	if (list_empty(&st_lock->list))
-		return;
+	for (;;) {
+		if (list_empty(&st_lock->list))
+			break;
 
-	next = list_first_entry(&st_lock->list,
+		next = list_first_entry(&st_lock->list,
 				struct nfs4_stateid_lock_wait,
 				list);
-	rpc_wake_up_queued_task(&st_lock->wait, next->task);
+		if (!nfs4_stateid_lock_make_active(st_lock, next))
+			break;
+		rpc_wake_up_queued_task(&st_lock->wait, next->task);
+	}
 }
 
 static void
@@ -475,6 +498,8 @@ nfs4_stateid_lock_wait_init(struct nfs4_stateid_lock_wait *wait)
 {
 	INIT_LIST_HEAD(&wait->list);
 	wait->task = NULL;
+	wait->active = 0;
+	wait->shared = 0;
 }
 
 static int
@@ -485,14 +510,16 @@ nfs4_stateid_lock_wait_begin(struct nfs4_stateid_lock *st_lock,
 	int status = 0;
 
 	spin_lock(&st_lock->lock);
-	wait->task = task;
-	if (list_empty(&wait->list))
-		list_add_tail(&wait->list, &st_lock->list);
-	if (list_first_entry(&st_lock->list, struct nfs4_stateid_lock_wait, list) == wait)
-		goto unlock;
-	rpc_sleep_on(&st_lock->wait, task, NULL);
-	status = -EAGAIN;
-unlock:
+	if (!wait->active && list_empty(&wait->list)) {
+		wait->task = task;
+		if (!list_empty(&st_lock->list) ||
+		    !nfs4_stateid_lock_make_active(st_lock, wait))
+			list_add_tail(&wait->list, &st_lock->list);
+	}
+	if (!wait->active) {
+		rpc_sleep_on(&st_lock->wait, task, NULL);
+		status = -EAGAIN;
+	}
 	spin_unlock(&st_lock->lock);
 	return status;
 }
@@ -501,12 +528,19 @@ static void
 nfs4_stateid_lock_wait_end(struct nfs4_stateid_lock *st_lock,
 		struct nfs4_stateid_lock_wait *wait)
 {
-	if (list_empty(&wait->list))
+	if (!wait->active && list_empty(&wait->list))
 		return;
 	spin_lock(&st_lock->lock);
 	list_del_init(&wait->list);
-	nfs4_stateid_lock_wake_next_locked(st_lock);
+	if (wait->active) {
+		if (wait->shared)
+			st_lock->n_active--;
+		else
+			st_lock->n_active = 0;
+		nfs4_stateid_lock_wake_next_locked(st_lock);
+	}
 	spin_unlock(&st_lock->lock);
+	wait->active = 0;
 }
 
 static void
-- 
1.8.5.3

