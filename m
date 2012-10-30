Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57592 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961Ab2J3UvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 16:51:00 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/10] NFSD: Clean up forgetting locks
Date: Tue, 30 Oct 2012 16:50:48 -0400
Message-Id: <1351630254-26166-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1351630254-26166-1-git-send-email-bjschuma@netapp.com>
References: <1351630254-26166-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I use the new "forget_n_state()" function to iterate through each client
first when searching for locks.  This may slow down forgetting locks a
little bit, but it implements most of the code needed to forget a
specified client's locks.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3c5719a..5c62323 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4563,6 +4563,24 @@ static u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
+static u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_stateowner *sop, *next;
+	u64 count = 0;
+	int i;
+
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		list_for_each_entry_safe(sop, next, &ownerstr_hashtbl[i], so_strhash) {
+			if (!sop->so_is_open_owner && (sop->so_client == clp)) {
+				release_lockowner(lockowner(sop));
+				count++;
+			}
+		}
+	}
+
+	return count;
+}
+
 static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4583,11 +4601,6 @@ void nfsd_forget_clients(u64 num)
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
@@ -4613,8 +4626,8 @@ static int nfsd_release_n_owners(u64 num, bool is_open_owner,
 
 void nfsd_forget_locks(u64 num)
 {
-	int count = nfsd_release_n_owners(num, false, release_lockowner_sop);
-	printk(KERN_INFO "NFSD: Forgot %d locks", count);
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client_locks);
+	printk(KERN_INFO "NFSD: Forgot %llu locks", count);
 }
 
 void nfsd_forget_openowners(u64 num)
-- 
1.8.0

