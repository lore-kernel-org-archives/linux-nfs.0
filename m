Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23224 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360Ab1GHUqD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 16:46:03 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] NFSD: Pass a number to fault injection code
Date: Fri,  8 Jul 2011 16:45:59 -0400
Message-Id: <1310157959-11429-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1310157959-11429-1-git-send-email-bjschuma@netapp.com>
References: <1310157959-11429-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This number represents the maximum number of items to either forget or
recall.  Passing 0 means that we should forget or recall all items.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c |   35 ++++++++++-------
 fs/nfsd/nfs4state.c    |   96 ++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsd.h         |   20 +++++-----
 3 files changed, 98 insertions(+), 53 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 7f5ac83..b987d39 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -9,14 +9,14 @@
 #include "state.h"
 #include "nfsd.h"
 
-static void nfsd_forget_everything(void);
+static void nfsd_forget_everything(u64);
 
 struct nfsd_fault_inject_op {
 	char *action;
 	char *item;
 	char *file;
 	int file_data;
-	void (*func)(void);
+	void (*func)(u64);
 };
 
 #define INJECTION_OP(op_action, op_item, op_func) \
@@ -28,23 +28,23 @@ struct nfsd_fault_inject_op {
 }
 
 static struct nfsd_fault_inject_op inject_ops[] = {
-	INJECTION_OP("forget", "clients",     nfsd_forget_all_clients),
-	INJECTION_OP("forget", "locks",       nfsd_forget_all_locks),
-	INJECTION_OP("forget", "open_owners", nfsd_forget_all_open_owners),
-	INJECTION_OP("forget", "delegations", nfsd_forget_all_delegations),
+	INJECTION_OP("forget", "clients",     nfsd_forget_clients),
+	INJECTION_OP("forget", "locks",       nfsd_forget_locks),
+	INJECTION_OP("forget", "open_owners", nfsd_forget_open_owners),
+	INJECTION_OP("forget", "delegations", nfsd_forget_delegations),
 	INJECTION_OP("forget", "everything",  nfsd_forget_everything),
-	INJECTION_OP("recall", "delegations", nfsd_recall_all_delegations),
+	INJECTION_OP("recall", "delegations", nfsd_recall_delegations),
 };
 
 static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
 static struct dentry *debug_dir;
 
-static void nfsd_forget_everything(void)
+static void nfsd_forget_everything(u64 num)
 {
-	nfsd_forget_all_clients();
-	nfsd_forget_all_locks();
-	nfsd_forget_all_open_owners();
-	nfsd_forget_all_delegations();
+	nfsd_forget_clients(num);
+	nfsd_forget_locks(num);
+	nfsd_forget_open_owners(num);
+	nfsd_forget_delegations(num);
 }
 
 static int nfsd_inject_set(void *data, u64 val)
@@ -54,9 +54,14 @@ static int nfsd_inject_set(void *data, u64 val)
 	for (i = 0; i < NUM_INJECT_OPS; i++) {
 		op = &inject_ops[i];
 		if (&op->file_data == data) {
-			printk(KERN_INFO "%s %s Server will %s all %s", __FILE__,
-				__func__, op->action, op->item);
-			op->func();
+			if (val == 0) {
+				printk(KERN_INFO "%s %s Server %sing all %s",
+					__FILE__, __func__, op->action, op->item);
+			} else {
+				printk(KERN_INFO "%s %s Server %sing at most %llu %s",
+				__FILE__, __func__, op->action, val, op->item);
+			}
+			op->func(val);
 		}
 	}
 	return 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0b124c8..672d904 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4439,7 +4439,7 @@ nfs4_check_open_reclaim(clientid_t *clid)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
-void nfsd_forget_all_clients(void)
+void nfsd_forget_clients(u64 num)
 {
 	struct nfs4_client *clp;
 	struct list_head *pos, *next, reaplist;
@@ -4453,7 +4453,8 @@ void nfsd_forget_all_clients(void)
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		unhash_client_locked(clp);
 		list_add(&clp->cl_lru, &reaplist);
-		count ++;
+		if (++count == num)
+			break;
 	}
 	spin_unlock(&client_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -4466,107 +4467,146 @@ void nfsd_forget_all_clients(void)
 	printk(KERN_INFO "%s %s Forgot %d clients", __FILE__, __func__, count);
 }
 
-void nfsd_forget_all_locks(void)
+int nfsd_forget_locks_reaplist(struct list_head *reaplist, u64 num)
 {
+	int i;
+	int count = 0;
 	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
-	struct list_head reaplist;
-	int count = 0;
-	int i;
 
-	INIT_LIST_HEAD(&reaplist);
-	nfs4_lock_state();
+	INIT_LIST_HEAD(reaplist);
+
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		list_for_each_entry(sop, &lock_ownerid_hashtbl[i], so_idhash) {
 			list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-				list_add(&sop->so_perclient, &reaplist);
+				list_add(&sop->so_perclient, reaplist);
+				if (++count == num)
+					return count;
 			}
 		}
 	}
+	return count;
+}
+
+void nfsd_forget_locks(u64 num)
+{
+	struct nfs4_stateowner *sop;
+	struct list_head reaplist;
+	int count;
 
+	nfs4_lock_state();
+	count = nfsd_forget_locks_reaplist(&reaplist, num);
 	while (!list_empty(&reaplist)) {
 		sop = list_entry(reaplist.next, struct nfs4_stateowner, so_perclient);
 		list_del(&sop->so_perclient);
 		release_lockowner(sop);
-		count ++;
 	}
 	nfs4_unlock_state();
 
 	printk(KERN_INFO "%s %s Forgot %d locks", __FILE__, __func__, count);
 }
 
-void nfsd_forget_all_open_owners(void)
+int nfsd_forget_n_open_owners(u64 num)
 {
+	int i, count = 0;
 	struct nfs4_stateid *stp, *next;
-	unsigned int i;
-	int count = 0;
 
-	nfs4_lock_state();
 	for (i = 0; i < STATEID_HASH_SIZE; i++) {
 		list_for_each_entry_safe(stp, next, &stateid_hashtbl[i], st_hash) {
 			if (stp->st_openstp == NULL) {
 				release_openowner(stp->st_stateowner);
-				count++;
+				if (++count == num)
+					return count;
 			}
 		}
 	}
+	return count;
+}
+
+void nfsd_forget_open_owners(u64 num)
+{
+	int count;
+	nfs4_lock_state();
+	count = nfsd_forget_n_open_owners(num);
 	nfs4_unlock_state();
 	printk(KERN_INFO "%s %s Forgot %d open owners", __FILE__, __func__, count);
 }
 
-void nfsd_forget_all_delegations(void)
+int nfsd_forget_delegations_reaplist(struct list_head *reaplist, u64 num)
 {
+	int i, count = 0;
 	struct nfs4_file *fp;
 	struct nfs4_delegation *dp;
-	struct list_head *pos, *next, reaplist;
-	unsigned int i;
-	unsigned int count = 0;
+	struct list_head *pos;
 
-	INIT_LIST_HEAD(&reaplist);
+	INIT_LIST_HEAD(reaplist);
 
-	nfs4_lock_state();
 	spin_lock(&recall_lock);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
 			list_for_each(pos, &fp->fi_delegations) {
 				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
 				list_del_init(&dp->dl_perclnt);
-				list_move(&dp->dl_recall_lru, &reaplist);
+				list_move(&dp->dl_recall_lru, reaplist);
+				if (++count == num)
+					return count;
 			}
 		}
 	}
+	return count;
+}
+
+void nfsd_forget_delegations(u64 num)
+{
+	struct nfs4_delegation *dp;
+	struct list_head *pos, *next, reaplist;
+	unsigned int count;
+
+	nfs4_lock_state();
 
+	spin_lock(&recall_lock);
+	count = nfsd_forget_delegations_reaplist(&reaplist, num);
 	spin_unlock(&recall_lock);
+
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry(pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 		count++;
 	}
-	nfs4_unlock_state();
 
+	nfs4_unlock_state();
 	printk(KERN_INFO "%s %s Forgot %d delegations", __FILE__, __func__, count);
 }
 
-void nfsd_recall_all_delegations(void)
+int nfsd_recall_n_delegations(u64 num)
 {
 	struct nfs4_file *fp;
 	struct nfs4_delegation *dp;
 	struct list_head *pos;
 	unsigned int i;
-	unsigned int count = 0;
+	int count = 0;
 
-	nfs4_lock_state();
-	spin_lock(&recall_lock);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
 			list_for_each(pos, &fp->fi_delegations) {
 				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
 				nfsd_break_one_deleg(dp);
-				count++;
+				if (++count == num)
+					return count;
 			}
 		}
 	}
+
+	return count;
+}
+
+void nfsd_recall_delegations(u64 num)
+{
+	unsigned int count;
+	nfs4_lock_state();
+	spin_lock(&recall_lock);
+	count = nfsd_recall_n_delegations(num);
 	spin_unlock(&recall_lock);
 	nfs4_unlock_state();
 	printk(KERN_INFO "%s %s Recalled %d delegations", __FILE__, __func__, count);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 4a6cded..167a824 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -86,11 +86,11 @@ int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
-void nfsd_forget_all_clients(void);
-void nfsd_forget_all_locks(void);
-void nfsd_forget_all_open_owners(void);
-void nfsd_forget_all_delegations(void);
-void nfsd_recall_all_delegations(void);
+void nfsd_forget_clients(u64);
+void nfsd_forget_locks(u64);
+void nfsd_forget_open_owners(u64);
+void nfsd_forget_delegations(u64);
+void nfsd_recall_delegations(u64);
 #else
 static inline int nfs4_state_init(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
@@ -98,11 +98,11 @@ static inline int nfs4_state_start(void) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
 static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
-static inline void nfsd_forget_all_clients(void) {};
-static inline void nfsd_forget_all_locks(void) {};
-static inline void nfsd_forget_all_open_owners(void) {};
-static inline void nfsd_forget_all_delegations(void) {};
-static inline void nfsd_recall_all_delegations(void) {};
+static inline void nfsd_forget_clients(u64) {};
+static inline void nfsd_forget_locks(u64) {};
+static inline void nfsd_forget_open_owners(u64) {};
+static inline void nfsd_forget_delegations(u64) {};
+static inline void nfsd_recall_delegations(u64) {};
 #endif
 
 /*
-- 
1.7.6

