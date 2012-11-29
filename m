Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab2K2Qkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:51 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/9] NFSD: Clean up forgetting clients
Date: Thu, 29 Nov 2012 11:40:39 -0500
Message-Id: <1354207246-32343-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
References: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I added in a generic for-each loop that takes a pass over the client_lru
list for the current net namespace and calls some function.  The next few
patches will update other operations to use this function as well.  A value
of 0 still means "forget everything that is found".

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/netns.h     |  3 +++
 fs/nfsd/nfs4state.c | 25 ++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 2c4b2e2..964b554 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -92,5 +92,8 @@ struct nfsd_net {
 	time_t nfsd4_grace;
 };
 
+/* Simple check to find out if a given net was properly initialized */
+#define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
+
 extern int nfsd_net_id;
 #endif /* __NFSD_NETNS_H__ */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8e19c69..2478c89 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4605,19 +4605,34 @@ nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
-void nfsd_forget_clients(u64 num)
+u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
+{
+	expire_client(clp);
+	return 1;
+}
+
+u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
-	int count = 0;
+	u64 count = 0;
 	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
 
+	if (!nfsd_netns_ready(nn))
+		return 0;
+
 	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
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
1.8.0.1

