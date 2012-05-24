Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936Ab2EXTmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 15:42:19 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] nfsd: add fault injection for CB_PATH_DOWN
Date: Thu, 24 May 2012 15:42:16 -0400
Message-Id: <1337888537-21754-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fault injection hook causes all SEQUENCE operation replies to have the
SEQ4_STATUS_CB_PATH_DOWN flag set until the client calls BIND_CONN_TO_SESSION
or creates a new session.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfsd/fault_inject.c |    4 ++++
 fs/nfsd/fault_inject.h |    2 ++
 fs/nfsd/nfs4state.c    |   20 ++++++++++++++++++++
 3 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index e6c3815..ab81144 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -38,6 +38,10 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 		.file   = "recall_delegations",
 		.func   = nfsd_recall_delegations,
 	},
+	{
+		.file   = "kill_backchannel",
+		.func   = nfsd_kill_backchannel,
+	},
 };
 
 static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
diff --git a/fs/nfsd/fault_inject.h b/fs/nfsd/fault_inject.h
index 90bd057..b058e03 100644
--- a/fs/nfsd/fault_inject.h
+++ b/fs/nfsd/fault_inject.h
@@ -15,6 +15,7 @@ void nfsd_forget_locks(u64);
 void nfsd_forget_openowners(u64);
 void nfsd_forget_delegations(u64);
 void nfsd_recall_delegations(u64);
+void nfsd_kill_backchannel(u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
@@ -23,6 +24,7 @@ static inline void nfsd_forget_locks(u64 num) {}
 static inline void nfsd_forget_openowners(u64 num) {}
 static inline void nfsd_forget_delegations(u64 num) {}
 static inline void nfsd_recall_delegations(u64 num) {}
+static inline void nfsd_kill_backchannel(u64 num) {}
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 #endif /* LINUX_NFSD_FAULT_INJECT_H */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 21266c7..9afc902 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4737,6 +4737,26 @@ void nfsd_recall_delegations(u64 num)
 	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
 }
 
+/*
+ * Force SEQUENCE operations to have SEQ4_STATUS_CB_PATH_DOWN flag set
+ * until backchannel is reestablished by BIND_CONN_TO_SESSION or
+ * DESTROY_SESSION/CREATE_SESSION with SP4_NONE.
+ *
+ * The argument 'num' is ignored, any value will trigger the fault on
+ * all clients.
+ */
+void nfsd_kill_backchannel(u64 num)
+{
+	struct nfs4_client *clp, *next;
+
+	nfs4_lock_state();
+	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
+		clp->cl_cb_state = NFSD4_CB_DOWN;
+	}
+	nfs4_unlock_state();
+
+	printk(KERN_INFO "NFSD: killed backchannel");
+}
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 /* initialization to perform at module load time: */
-- 
1.7.4.4

