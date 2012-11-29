Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2K2Qkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:52 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 3/9] NFSD: Clean up forgetting locks
Date: Thu, 29 Nov 2012 11:40:40 -0500
Message-Id: <1354207246-32343-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
References: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
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
index 2478c89..46bece4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4611,6 +4611,32 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
+static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_lockowner *))
+{
+	struct nfs4_openowner *oop;
+	struct nfs4_lockowner *lop, *lo_next;
+	struct nfs4_ol_stateid *stp, *st_next;
+	u64 count = 0;
+
+	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient) {
+		list_for_each_entry_safe(stp, st_next, &oop->oo_owner.so_stateids, st_perstateowner) {
+			list_for_each_entry_safe(lop, lo_next, &stp->st_lockowners, lo_perstateid) {
+				if (func)
+					func(lop);
+				if (++count == max)
+					return count;
+			}
+		}
+	}
+
+	return count;
+}
+
+u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
+{
+	return nfsd_foreach_client_lock(clp, max, release_lockowner);
+}
+
 u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
@@ -4635,11 +4661,6 @@ void nfsd_forget_clients(u64 num)
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
@@ -4666,9 +4687,8 @@ static int nfsd_release_n_owners(u64 num, bool is_open_owner,
 
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

