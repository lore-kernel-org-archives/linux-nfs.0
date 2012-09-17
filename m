Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932551Ab2IQUQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:23 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] NFSD: Clean up forgetting clients
Date: Mon, 17 Sep 2012 16:16:12 -0400
Message-Id: <1347912979-20603-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I added in a generic for-each loop that takes a pass over the client_lru
list and calls some function.  The next few patches will update other
operations to use this function as well.  A value of 0 still means "forget
everything that is found".

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f7278d7..6321dc3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4539,19 +4539,31 @@ nfs4_check_open_reclaim(clientid_t *clid)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
-void nfsd_forget_clients(u64 num)
+static u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
+{
+	nfsd4_client_record_remove(clp);
+	expire_client(clp);
+	return 1;
+}
+
+static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
-	int count = 0;
+	u64 count = 0;
 
 	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
-		nfsd4_client_record_remove(clp);
-		expire_client(clp);
-		if (++count == num)
+		count += func(clp, max - count);
+		if ((max != 0) && (count >= max))
 			break;
 	}
 
-	printk(KERN_INFO "NFSD: Forgot %d clients", count);
+	return count;
+}
+
+void nfsd_forget_clients(u64 num)
+{
+	u64 count = nfsd_for_n_state(num, nfsd_forget_client);
+	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
 }
 
 static void release_lockowner_sop(struct nfs4_stateowner *sop)
-- 
1.7.12

