Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35981 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaG3M2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:16 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so1309822qgd.9
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 22/37] nfsd: add more granular locking to *_delegations fault injectors
Date: Wed, 30 Jul 2014 08:27:23 -0400
Message-Id: <1406723258-8512-23-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of relying on the client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  16 ++---
 fs/nfsd/nfs4state.c    | 175 +++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/state.h        |  11 ++--
 3 files changed, 162 insertions(+), 40 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index d4472cd19807..2479dba71c3c 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -152,19 +152,15 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 	},
 	{
 		.file     = "forget_delegations",
-		.get	  = nfsd_inject_get,
-		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
-		.forget   = nfsd_forget_client_delegations,
-		.print    = nfsd_print_client_delegations,
+		.get	  = nfsd_inject_print_delegations,
+		.set_val  = nfsd_inject_forget_delegations,
+		.set_clnt = nfsd_inject_forget_client_delegations,
 	},
 	{
 		.file     = "recall_delegations",
-		.get	  = nfsd_inject_get,
-		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
-		.forget   = nfsd_recall_client_delegations,
-		.print    = nfsd_print_client_delegations,
+		.get	  = nfsd_inject_print_delegations,
+		.set_val  = nfsd_inject_recall_delegations,
+		.set_clnt = nfsd_inject_recall_client_delegations,
 	},
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 996287e1f0be..f558b12af267 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6098,9 +6098,13 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 				     struct list_head *victims)
 {
 	struct nfs4_delegation *dp, *next;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
 	u64 count = 0;
 
-	lockdep_assert_held(&state_lock);
+	lockdep_assert_held(&nn->client_lock);
+
+	spin_lock(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
 		if (victims) {
 			/*
@@ -6112,62 +6116,180 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 			if (dp->dl_time != 0)
 				continue;
 
+			atomic_inc(&clp->cl_refcount);
 			unhash_delegation_locked(dp);
 			list_add(&dp->dl_recall_lru, victims);
 		}
-		if (++count == max)
+		++count;
+		/*
+		 * Despite the fact that these functions deal with
+		 * 64-bit integers for "count", we must ensure that
+		 * it doesn't blow up the clp->cl_refcount. Throw a
+		 * warning if we start to approach INT_MAX here.
+		 */
+		WARN_ON_ONCE(count == (INT_MAX / 2));
+		if (count == max)
 			break;
 	}
+	spin_unlock(&state_lock);
 	return count;
 }
 
-u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
+static u64
+nfsd_print_client_delegations(struct nfs4_client *clp)
 {
-	struct nfs4_delegation *dp, *next;
-	LIST_HEAD(victims);
-	u64 count;
+	u64 count = nfsd_find_all_delegations(clp, 0, NULL);
 
-	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, &victims);
-	spin_unlock(&state_lock);
+	nfsd_print_count(clp, count, "delegations");
+	return count;
+}
+
+u64
+nfsd_inject_print_delegations(struct nfsd_fault_inject_op *op)
+{
+	struct nfs4_client *clp;
+	u64 count = 0;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+
+	if (!nfsd_netns_ready(nn))
+		return 0;
 
-	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru) {
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru)
+		count += nfsd_print_client_delegations(clp);
+	spin_unlock(&nn->client_lock);
+
+	return count;
+}
+
+static void
+nfsd_forget_delegations(struct list_head *reaplist)
+{
+	struct nfs4_client *clp;
+	struct nfs4_delegation *dp, *next;
+
+	list_for_each_entry_safe(dp, next, reaplist, dl_recall_lru) {
 		list_del_init(&dp->dl_recall_lru);
+		clp = dp->dl_stid.sc_client;
 		revoke_delegation(dp);
+		put_client(clp);
 	}
+}
+
+u64
+nfsd_inject_forget_client_delegations(struct nfsd_fault_inject_op *op,
+				struct sockaddr_storage *addr, size_t addr_size)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	clp = nfsd_find_client(addr, addr_size);
+	if (clp)
+		count = nfsd_find_all_delegations(clp, 0, &reaplist);
+	spin_unlock(&nn->client_lock);
+
+	nfsd_forget_delegations(&reaplist);
+	return count;
+}
 
+u64
+nfsd_inject_forget_delegations(struct nfsd_fault_inject_op *op, u64 max)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		count += nfsd_find_all_delegations(clp, max - count, &reaplist);
+		if (max != 0 && count >= max)
+			break;
+	}
+	spin_unlock(&nn->client_lock);
+	nfsd_forget_delegations(&reaplist);
 	return count;
 }
 
-u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
+static void
+nfsd_recall_delegations(struct list_head *reaplist)
 {
-	struct nfs4_delegation *dp;
-	LIST_HEAD(victims);
-	u64 count;
+	struct nfs4_client *clp;
+	struct nfs4_delegation *dp, *next;
 
-	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, &victims);
-	while (!list_empty(&victims)) {
-		dp = list_first_entry(&victims, struct nfs4_delegation,
-					dl_recall_lru);
+	list_for_each_entry_safe(dp, next, reaplist, dl_recall_lru) {
 		list_del_init(&dp->dl_recall_lru);
+		clp = dp->dl_stid.sc_client;
+		/*
+		 * We skipped all entries that had a zero dl_time before,
+		 * so we can now reset the dl_time back to 0. If a delegation
+		 * break comes in now, then it won't make any difference since
+		 * we're recalling it either way.
+		 */
+		spin_lock(&state_lock);
 		dp->dl_time = 0;
+		spin_unlock(&state_lock);
 		nfsd_break_one_deleg(dp);
+		put_client(clp);
 	}
-	spin_unlock(&state_lock);
+}
 
+u64
+nfsd_inject_recall_client_delegations(struct nfsd_fault_inject_op *op,
+				      struct sockaddr_storage *addr,
+				      size_t addr_size)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	clp = nfsd_find_client(addr, addr_size);
+	if (clp)
+		count = nfsd_find_all_delegations(clp, 0, &reaplist);
+	spin_unlock(&nn->client_lock);
+
+	nfsd_recall_delegations(&reaplist);
 	return count;
 }
 
-u64 nfsd_print_client_delegations(struct nfs4_client *clp, u64 max)
+u64
+nfsd_inject_recall_delegations(struct nfsd_fault_inject_op *op, u64 max)
 {
 	u64 count = 0;
+	struct nfs4_client *clp, *next;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+	LIST_HEAD(reaplist);
 
-	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, NULL);
-	spin_unlock(&state_lock);
+	if (!nfsd_netns_ready(nn))
+		return count;
 
-	nfsd_print_count(clp, count, "delegations");
+	spin_lock(&nn->client_lock);
+	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
+		count += nfsd_find_all_delegations(clp, max - count, &reaplist);
+		if (max != 0 && ++count >= max)
+			break;
+	}
+	spin_unlock(&nn->client_lock);
+	nfsd_recall_delegations(&reaplist);
 	return count;
 }
 
@@ -6175,7 +6297,8 @@ u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
 	u64 count = 0;
-	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
 
 	if (!nfsd_netns_ready(nn))
 		return 0;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 881ea7d5c69e..1a9ba857cbab 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -493,10 +493,13 @@ u64 nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *,
 					 struct sockaddr_storage *, size_t);
 u64 nfsd_inject_forget_openowners(struct nfsd_fault_inject_op *, u64);
 
-u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
-u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
-
-u64 nfsd_print_client_delegations(struct nfs4_client *, u64);
+u64 nfsd_inject_print_delegations(struct nfsd_fault_inject_op *);
+u64 nfsd_inject_forget_client_delegations(struct nfsd_fault_inject_op *,
+					  struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_delegations(struct nfsd_fault_inject_op *, u64);
+u64 nfsd_inject_recall_client_delegations(struct nfsd_fault_inject_op *,
+					  struct sockaddr_storage *, size_t);
+u64 nfsd_inject_recall_delegations(struct nfsd_fault_inject_op *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.9.3

