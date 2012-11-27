Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755058Ab2K0OfZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:35:25 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/10] NFSD: Clean up forgetting openowners
Date: Tue, 27 Nov 2012 09:35:14 -0500
Message-Id: <1354026919-13313-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Using "forget_n_state()" forces me to implement the code needed to
forget a specific client's openowners.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 50 +++++++++++++++++++++++---------------------------
 1 file changed, 23 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c931e65..94c009e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4624,6 +4624,27 @@ u64 nfsd_forget_client_locks(struct nfsd_net *nn, struct nfs4_client *clp, u64 m
 	return nfsd_foreach_client_lock(nn, clp, max, release_lockowner);
 }
 
+static u64 nfsd_foreach_client_open(struct nfsd_net *nn, struct nfs4_client *clp,
+				    u64 max, void (*func)(struct nfs4_openowner *))
+{
+	struct nfs4_openowner *oop, *next;
+	u64 count = 0;
+
+	list_for_each_entry_safe(oop, next, &clp->cl_openowners, oo_perclient) {
+		if (func)
+			func(oop);
+		if (++count == max)
+			break;
+	}
+
+	return count;
+}
+
+u64 nfsd_forget_client_openowners(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
+{
+	return nfsd_foreach_client_open(nn, clp, max, release_openowner);
+}
+
 static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4645,30 +4666,6 @@ void nfsd_forget_clients(u64 num)
 	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
 }
 
-static void release_openowner_sop(struct nfs4_stateowner *sop)
-{
-	release_openowner(openowner(sop));
-}
-
-static int nfsd_release_n_owners(u64 num, bool is_open_owner,
-				void (*release_sop)(struct nfs4_stateowner *),
-				struct nfsd_net *nn)
-{
-	int i, count = 0;
-	struct nfs4_stateowner *sop, *next;
-
-	for (i = 0; i < OWNER_HASH_SIZE; i++) {
-		list_for_each_entry_safe(sop, next, &nn->ownerstr_hashtbl[i], so_strhash) {
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
@@ -4677,9 +4674,8 @@ void nfsd_forget_locks(u64 num)
 
 void nfsd_forget_openowners(u64 num)
 {
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
-	int count = nfsd_release_n_owners(num, true, release_openowner_sop, nn);
-	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client_openowners);
+	printk(KERN_INFO "NFSD: Forgot %llu open owners", count);
 }
 
 static int nfsd_process_n_delegations(u64 num, struct list_head *list)
-- 
1.8.0.1

