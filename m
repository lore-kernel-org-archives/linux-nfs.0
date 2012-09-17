Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932238Ab2IQUQW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:22 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] NFSD: Lock state before calling fault injection function
Date: Mon, 17 Sep 2012 16:16:11 -0400
Message-Id: <1347912979-20603-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Each function touches state in some way, so getting the lock earlier
can help simplify code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c |  2 ++
 fs/nfsd/nfs4state.c    | 18 ++----------------
 2 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index ae94da1..3dac486 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -50,7 +50,9 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 	else
 		printk(KERN_INFO "NFSD Fault Injection: %s (n = %llu)", op->file, val);
 
+	nfs4_lock_state();
 	op->func(val);
+	nfs4_unlock_state();
 	return 0;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d024ffd..f7278d7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4544,14 +4544,12 @@ void nfsd_forget_clients(u64 num)
 	struct nfs4_client *clp, *next;
 	int count = 0;
 
-	nfs4_lock_state();
 	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
 		nfsd4_client_record_remove(clp);
 		expire_client(clp);
 		if (++count == num)
 			break;
 	}
-	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d clients", count);
 }
@@ -4586,23 +4584,13 @@ static int nfsd_release_n_owners(u64 num, bool is_open_owner,
 
 void nfsd_forget_locks(u64 num)
 {
-	int count;
-
-	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, false, release_lockowner_sop);
-	nfs4_unlock_state();
-
+	int count = nfsd_release_n_owners(num, false, release_lockowner_sop);
 	printk(KERN_INFO "NFSD: Forgot %d locks", count);
 }
 
 void nfsd_forget_openowners(u64 num)
 {
-	int count;
-
-	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, true, release_openowner_sop);
-	nfs4_unlock_state();
-
+	int count = nfsd_release_n_owners(num, true, release_openowner_sop);
 	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
 }
 
@@ -4635,10 +4623,8 @@ void nfsd_forget_delegations(u64 num)
 	count = nfsd_process_n_delegations(num, &victims);
 	spin_unlock(&recall_lock);
 
-	nfs4_lock_state();
 	list_for_each_entry_safe(dp, dnext, &victims, dl_recall_lru)
 		unhash_delegation(dp);
-	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d delegations", count);
 }
-- 
1.7.12

