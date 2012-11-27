Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356Ab2K0OfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:35:24 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/10] NFSD: Clean up forgetting locks
Date: Tue, 27 Nov 2012 09:35:13 -0500
Message-Id: <1354026919-13313-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I use the new "forget_n_state()" function to iterate through each client
first when searching for locks.  This may slow down forgetting locks a
little bit, but it implements most of the code needed to forget a
specified client's locks.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 07abca5..c931e65 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4598,6 +4598,32 @@ u64 nfsd_forget_client(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
+static u64 nfsd_foreach_client_lock(struct nfsd_net *nn, struct nfs4_client *clp,
+				    u64 max, void (*func)(struct nfs4_lockowner *))
+{
+	struct nfs4_stateowner *sop, *next;
+	u64 count = 0;
+	int i;
+
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		list_for_each_entry_safe(sop, next, &nn->ownerstr_hashtbl[i], so_strhash) {
+			if (!sop->so_is_open_owner && (sop->so_client == clp)) {
+				if (func)
+					func(lockowner(sop));
+				if (++count == max)
+					break;
+			}
+		}
+	}
+
+	return count;
+}
+
+u64 nfsd_forget_client_locks(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
+{
+	return nfsd_foreach_client_lock(nn, clp, max, release_lockowner);
+}
+
 static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4619,11 +4645,6 @@ void nfsd_forget_clients(u64 num)
 	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
 }
 
-static void release_lockowner_sop(struct nfs4_stateowner *sop)
-{
-	release_lockowner(lockowner(sop));
-}
-
 static void release_openowner_sop(struct nfs4_stateowner *sop)
 {
 	release_openowner(openowner(sop));
@@ -4650,9 +4671,8 @@ static int nfsd_release_n_owners(u64 num, bool is_open_owner,
 
 void nfsd_forget_locks(u64 num)
 {
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
-	int count = nfsd_release_n_owners(num, false, release_lockowner_sop, nn);
-	printk(KERN_INFO "NFSD: Forgot %d locks", count);
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client_locks);
+	printk(KERN_INFO "NFSD: Forgot %llu locks", count);
 }
 
 void nfsd_forget_openowners(u64 num)
-- 
1.8.0.1

