Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734Ab2K2Qky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:54 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 5/9] NFSD: Clean up forgetting and recalling delegations
Date: Thu, 29 Nov 2012 11:40:42 -0500
Message-Id: <1354207246-32343-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
References: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Once I have a client, I can easily use its delegation list rather than
searching the file hash table for delegations to remove.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 94 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 50 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 00d4398..dc7c22f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4657,6 +4657,52 @@ u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
 	return nfsd_foreach_client_open(clp, max, release_openowner);
 }
 
+static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
+				     struct list_head *victims)
+{
+	struct nfs4_delegation *dp, *next;
+	u64 count = 0;
+
+	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
+		if (victims)
+			list_move(&dp->dl_recall_lru, victims);
+		if (++count == max)
+			break;
+	}
+	return count;
+}
+
+u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_delegation *dp, *next;
+	LIST_HEAD(victims);
+	u64 count;
+
+	spin_lock(&recall_lock);
+	count = nfsd_find_all_delegations(clp, max, &victims);
+	spin_unlock(&recall_lock);
+
+	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
+		unhash_delegation(dp);
+
+	return count;
+}
+
+u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_delegation *dp, *next;
+	LIST_HEAD(victims);
+	u64 count;
+
+	spin_lock(&recall_lock);
+	count = nfsd_find_all_delegations(clp, max, &victims);
+	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
+		nfsd_break_one_deleg(dp);
+	spin_unlock(&recall_lock);
+
+	return count;
+}
+
 u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4693,56 +4739,16 @@ void nfsd_forget_openowners(u64 num)
 	printk(KERN_INFO "NFSD: Forgot %llu open owners", count);
 }
 
-static int nfsd_process_n_delegations(u64 num, struct list_head *list)
-{
-	int i, count = 0;
-	struct nfs4_file *fp, *fnext;
-	struct nfs4_delegation *dp, *dnext;
-
-	for (i = 0; i < FILE_HASH_SIZE; i++) {
-		list_for_each_entry_safe(fp, fnext, &file_hashtbl[i], fi_hash) {
-			list_for_each_entry_safe(dp, dnext, &fp->fi_delegations, dl_perfile) {
-				list_move(&dp->dl_recall_lru, list);
-				if (++count == num)
-					return count;
-			}
-		}
-	}
-
-	return count;
-}
-
 void nfsd_forget_delegations(u64 num)
 {
-	unsigned int count;
-	LIST_HEAD(victims);
-	struct nfs4_delegation *dp, *dnext;
-
-	spin_lock(&recall_lock);
-	count = nfsd_process_n_delegations(num, &victims);
-	spin_unlock(&recall_lock);
-
-	list_for_each_entry_safe(dp, dnext, &victims, dl_recall_lru)
-		unhash_delegation(dp);
-
-	printk(KERN_INFO "NFSD: Forgot %d delegations", count);
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client_delegations);
+	printk(KERN_INFO "NFSD: Forgot %llu delegations", count);
 }
 
 void nfsd_recall_delegations(u64 num)
 {
-	unsigned int count;
-	LIST_HEAD(victims);
-	struct nfs4_delegation *dp, *dnext;
-
-	spin_lock(&recall_lock);
-	count = nfsd_process_n_delegations(num, &victims);
-	list_for_each_entry_safe(dp, dnext, &victims, dl_recall_lru) {
-		list_del(&dp->dl_recall_lru);
-		nfsd_break_one_deleg(dp);
-	}
-	spin_unlock(&recall_lock);
-
-	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
+	u64 count = nfsd_for_n_state(num, nfsd_recall_client_delegations);
+	printk(KERN_INFO "NFSD: Recalled %llu delegations", count);
 }
 
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
-- 
1.8.0.1

