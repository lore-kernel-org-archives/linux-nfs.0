Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555Ab2IQUQZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:25 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] NFSD: Clean up forgetting openowners
Date: Mon, 17 Sep 2012 16:16:14 -0400
Message-Id: <1347912979-20603-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Using "forget_n_state()" forces me to implement the code needed to
forget a specific client's openowners.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 41 ++++++++++++++++-------------------------
 1 file changed, 16 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 631c16b..611a827 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4564,6 +4564,20 @@ static u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
+static u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_openowner *oop, *next;
+	u64 count = 0;
+
+	list_for_each_entry_safe(oop, next, &clp->cl_openowners, oo_perclient) {
+		release_openowner(oop);
+		if (++count == max)
+			break;
+	}
+
+	return count;
+}
+
 static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4584,29 +4598,6 @@ void nfsd_forget_clients(u64 num)
 	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
 }
 
-static void release_openowner_sop(struct nfs4_stateowner *sop)
-{
-	release_openowner(openowner(sop));
-}
-
-static int nfsd_release_n_owners(u64 num, bool is_open_owner,
-				void (*release_sop)(struct nfs4_stateowner *))
-{
-	int i, count = 0;
-	struct nfs4_stateowner *sop, *next;
-
-	for (i = 0; i < OWNER_HASH_SIZE; i++) {
-		list_for_each_entry_safe(sop, next, &ownerstr_hashtbl[i], so_strhash) {
-			if (sop->so_is_open_owner != is_open_owner)
-				continue;
-			release_sop(sop);
-			if (++count == num)
-				return count;
-		}
-	}
-	return count;
-}
-
 void nfsd_forget_locks(u64 num)
 {
 	u64 count = nfsd_for_n_state(num, nfsd_forget_client_locks);
@@ -4615,8 +4606,8 @@ void nfsd_forget_locks(u64 num)
 
 void nfsd_forget_openowners(u64 num)
 {
-	int count = nfsd_release_n_owners(num, true, release_openowner_sop);
-	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client_openowners);
+	printk(KERN_INFO "NFSD: Forgot %llu open owners", count);
 }
 
 static int nfsd_process_n_delegations(u64 num, struct list_head *list)
-- 
1.7.12

