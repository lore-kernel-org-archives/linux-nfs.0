Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab2K0Of1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:35:27 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/10] NFSD: Fault injection operations take a per-client forget function
Date: Tue, 27 Nov 2012 09:35:16 -0500
Message-Id: <1354026919-13313-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
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
 fs/nfsd/nfs4state.c    | 32 +-------------------------------
 fs/nfsd/state.h        | 12 +++++++-----
 3 files changed, 17 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 4b385a1..bdef6a8 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -13,29 +13,29 @@
 
 struct nfsd_fault_inject_op {
 	char *file;
-	void (*func)(u64);
+	u64 (*forget)(struct nfsd_net *, struct nfs4_client *, u64);
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
 
@@ -44,6 +44,7 @@ static struct dentry *debug_dir;
 
 static int nfsd_inject_set(void *op_ptr, u64 val)
 {
+	u64 count = 0;
 	struct nfsd_fault_inject_op *op = op_ptr;
 
 	if (val == 0)
@@ -52,8 +53,9 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 		printk(KERN_INFO "NFSD Fault Injection: %s (n = %llu)", op->file, val);
 
 	nfs4_lock_state();
-	op->func(val);
+	count = nfsd_for_n_state(val, op->forget);
 	nfs4_unlock_state();
+	printk(KERN_INFO "NFSD: %s: found %llu", op->file, count);
 	return 0;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 84bd4c4..ba41006 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4691,7 +4691,7 @@ u64 nfsd_recall_client_delegations(struct nfsd_net *nn, struct nfs4_client *clp,
 	return count;
 }
 
-static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
+u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
 	u64 count = 0;
@@ -4706,36 +4706,6 @@ static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_
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
index b542bf2..4d836ed 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -501,11 +501,13 @@ extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
-void nfsd_forget_clients(u64);
-void nfsd_forget_locks(u64);
-void nfsd_forget_openowners(u64);
-void nfsd_forget_delegations(u64);
-void nfsd_recall_delegations(u64);
+u64 nfsd_for_n_state(u64, u64 (*)(struct nfsd_net *, struct nfs4_client *, u64));
+
+u64 nfsd_forget_client(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_forget_client_locks(struct nfsd_net *, struct nfs4_client*, u64);
+u64 nfsd_forget_client_openowners(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_forget_client_delegations(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_recall_client_delegations(struct nfsd_net *, struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.8.0.1

