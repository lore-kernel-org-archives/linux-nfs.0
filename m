Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52812 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555Ab2IQUQ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:26 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] NFSD: Fault injection operations take a per-client forget function
Date: Mon, 17 Sep 2012 16:16:16 -0400
Message-Id: <1347912979-20603-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The eventual goal is to forget state based on ip address, so it makes
sense to call this function in a for-each-client loop until the correct
amount of state is forgotten.  I also use this patch as an opportunity
to rename the forget function from "func()" to "forget()".

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 16 +++++++++-------
 fs/nfsd/nfs4state.c    | 42 ++++++------------------------------------
 fs/nfsd/state.h        | 12 +++++++-----
 3 files changed, 22 insertions(+), 48 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 3dac486..09feb80 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -12,29 +12,29 @@
 
 struct nfsd_fault_inject_op {
 	char *file;
-	void (*func)(u64);
+	u64 (*forget)(struct nfs4_client *, u64);
 };
 
 static struct nfsd_fault_inject_op inject_ops[] = {
 	{
 		.file   = "forget_clients",
-		.func   = nfsd_forget_clients,
+		.forget = nfsd_forget_client,
 	},
 	{
 		.file   = "forget_locks",
-		.func   = nfsd_forget_locks,
+		.forget = nfsd_forget_client_locks,
 	},
 	{
 		.file   = "forget_openowners",
-		.func   = nfsd_forget_openowners,
+		.forget = nfsd_forget_client_openowners,
 	},
 	{
 		.file   = "forget_delegations",
-		.func   = nfsd_forget_delegations,
+		.forget = nfsd_forget_client_delegations,
 	},
 	{
 		.file   = "recall_delegations",
-		.func   = nfsd_recall_delegations,
+		.forget = nfsd_recall_client_delegations,
 	},
 };
 
@@ -43,6 +43,7 @@ static struct dentry *debug_dir;
 
 static int nfsd_inject_set(void *op_ptr, u64 val)
 {
+	u64 count = 0;
 	struct nfsd_fault_inject_op *op = op_ptr;
 
 	if (val == 0)
@@ -51,8 +52,9 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 		printk(KERN_INFO "NFSD Fault Injection: %s (n = %llu)", op->file, val);
 
 	nfs4_lock_state();
-	op->func(val);
+	count = nfsd_for_n_state(val, op->forget);
 	nfs4_unlock_state();
+	printk(KERN_INFO "NFSD: %s: found %llu", op->file, count);
 	return 0;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c91aae8..fee5c96 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4539,14 +4539,14 @@ nfs4_check_open_reclaim(clientid_t *clid)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
-static u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
+u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
 	nfsd4_client_record_remove(clp);
 	expire_client(clp);
 	return 1;
 }
 
-static u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
+u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 {
 	struct nfs4_stateowner *sop, *next;
 	u64 count = 0;
@@ -4564,7 +4564,7 @@ static u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
-static u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
+u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
 {
 	struct nfs4_openowner *oop, *next;
 	u64 count = 0;
@@ -4592,7 +4592,7 @@ static u64 nfsd_find_n_delegations(struct nfs4_client *clp, u64 max,
 	return count;
 }
 
-static u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
+u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 {
 	struct nfs4_delegation *dp, *next;
 	LIST_HEAD(victims);
@@ -4608,7 +4608,7 @@ static u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
-static u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
+u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 {
 	struct nfs4_delegation *dp, *next;
 	LIST_HEAD(victims);
@@ -4624,7 +4624,7 @@ static u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
-static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
+u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
 	u64 count = 0;
@@ -4638,36 +4638,6 @@ static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 	return count;
 }
 
-void nfsd_forget_clients(u64 num)
-{
-	u64 count = nfsd_for_n_state(num, nfsd_forget_client);
-	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
-}
-
-void nfsd_forget_locks(u64 num)
-{
-	u64 count = nfsd_for_n_state(num, nfsd_forget_client_locks);
-	printk(KERN_INFO "NFSD: Forgot %llu locks", count);
-}
-
-void nfsd_forget_openowners(u64 num)
-{
-	u64 count = nfsd_for_n_state(num, nfsd_forget_client_openowners);
-	printk(KERN_INFO "NFSD: Forgot %llu open owners", count);
-}
-
-void nfsd_forget_delegations(u64 num)
-{
-	u64 count = nfsd_for_n_state(num, nfsd_forget_client_delegations);
-	printk(KERN_INFO "NFSD: Forgot %llu delegations", count);
-}
-
-void nfsd_recall_delegations(u64 num)
-{
-	u64 count = nfsd_for_n_state(num, nfsd_recall_client_delegations);
-	printk(KERN_INFO "NFSD: Recalled %llu delegations", count);
-}
-
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 /* initialization to perform at module load time: */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f25fee2..5628a33 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -486,11 +486,13 @@ extern void nfsd4_record_grace_done(struct net *net, time_t boot_time);
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
-void nfsd_forget_clients(u64);
-void nfsd_forget_locks(u64);
-void nfsd_forget_openowners(u64);
-void nfsd_forget_delegations(u64);
-void nfsd_recall_delegations(u64);
+u64 nfsd_for_n_state(u64, u64 (*)(struct nfs4_client *, u64));
+
+u64 nfsd_forget_client(struct nfs4_client *, u64);
+u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
+u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
+u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
+u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.7.12

