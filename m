Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59109 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2K2Qkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:55 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 6/9] NFSD: Fault injection operations take a per-client forget function
Date: Thu, 29 Nov 2012 11:40:43 -0500
Message-Id: <1354207246-32343-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
References: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
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
 fs/nfsd/nfs4state.c    | 30 ------------------------------
 fs/nfsd/state.h        | 12 +++++++-----
 3 files changed, 16 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 4b385a1..bf6161a 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -13,29 +13,29 @@
 
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
index dc7c22f..ab45cdd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4721,36 +4721,6 @@ u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
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
index b542bf2..423ac64 100644
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
1.8.0.1

