Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:54268 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932490AbaFSOxC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:02 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so2233605qgd.27
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 087/104] nfsd: add more granular locking to forget_locks fault injector
Date: Thu, 19 Jun 2014 10:50:33 -0400
Message-Id: <1403189450-18729-88-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |   8 ++--
 fs/nfsd/nfs4state.c    | 117 ++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/state.h        |   6 ++-
 3 files changed, 117 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index d7c79e984d16..675594cd316c 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -139,11 +139,9 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 	},
 	{
 		.file     = "forget_locks",
-		.get	  = nfsd_inject_get,
-		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
-		.forget   = nfsd_forget_client_locks,
-		.print    = nfsd_print_client_locks,
+		.get	  = nfsd_inject_print_locks,
+		.set_val  = nfsd_inject_forget_locks,
+		.set_clnt = nfsd_inject_forget_client_locks,
 	},
 	{
 		.file     = "forget_openowners",
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61102b93902c..af726e934ea9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -209,6 +209,16 @@ static void put_client_renew(struct nfs4_client *clp)
 	spin_unlock(&nn->client_lock);
 }
 
+static void
+put_client(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	atomic_dec(&clp->cl_refcount);
+	spin_unlock(&nn->client_lock);
+}
+
 static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 {
 	__be32 status;
@@ -5661,37 +5671,130 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 	struct nfs4_openowner *oop;
 	struct nfs4_ol_stateid *stp, *st_next;
 	struct nfs4_ol_stateid *lst, *lst_next;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
 	u64 count = 0;
 
+	spin_lock(&clp->cl_lock);
 	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient) {
 		list_for_each_entry_safe(stp, st_next, &oop->oo_owner.so_stateids, st_perstateowner) {
 			list_for_each_entry_safe(lst, lst_next, &stp->st_locks, st_locks) {
 				if (func) {
 					func(lst);
-					if (collect)
+					if (collect) {
+						lockdep_assert_held(&nn->client_lock);
+						atomic_inc(&clp->cl_refcount);
 						list_add(&lst->st_locks, collect);
+					}
 				}
-				if (++count == max)
-					return count;
+				++count;
+				/*
+				 * Despite the fact that these functions deal
+				 * with 64-bit integers for "count", we must
+				 * ensure that it doesn't blow up the
+				 * clp->cl_refcount. Throw a warning if we
+				 * start to approach INT_MAX here.
+				 */
+				WARN_ON_ONCE(count == (INT_MAX / 2));
+				if (count == max)
+					goto out;
 			}
 		}
 	}
+out:
+	spin_unlock(&clp->cl_lock);
 
 	return count;
 }
 
-u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
+static u64
+nfsd_collect_client_locks(struct nfs4_client *clp, struct list_head *collect, u64 max)
 {
-	return nfsd_foreach_client_lock(clp, max, NULL, release_lock_stateid);
+	return nfsd_foreach_client_lock(clp, max, collect, unhash_lock_stateid);
 }
 
-u64 nfsd_print_client_locks(struct nfs4_client *clp, u64 max)
+static u64
+nfsd_print_client_locks(struct nfs4_client *clp)
 {
-	u64 count = nfsd_foreach_client_lock(clp, max, NULL, NULL);
+	u64 count = nfsd_foreach_client_lock(clp, 0, NULL, NULL);
 	nfsd_print_count(clp, count, "locked files");
 	return count;
 }
 
+u64
+nfsd_inject_print_locks(struct nfsd_fault_inject_op *op)
+{
+	struct nfs4_client *clp;
+	u64 count = 0;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+
+	if (!nfsd_netns_ready(nn))
+		return 0;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru)
+		count += nfsd_print_client_locks(clp);
+	spin_unlock(&nn->client_lock);
+
+	return count;
+}
+
+static void
+nfsd_reap_locks(struct list_head *reaplist)
+{
+	struct nfs4_client *clp;
+	struct nfs4_ol_stateid *stp, *next;
+
+	list_for_each_entry_safe(stp, next, reaplist, st_locks) {
+		list_del_init(&stp->st_locks);
+		clp = stp->st_stid.sc_client;
+		put_generic_stateid(stp);
+		put_client(clp);
+	}
+}
+
+u64
+nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *op,
+				struct sockaddr_storage *addr, size_t addr_size)
+{
+	unsigned int count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	clp = nfsd_find_client(addr, addr_size);
+	if (clp)
+		count = nfsd_collect_client_locks(clp, &reaplist, 0);
+	spin_unlock(&nn->client_lock);
+	nfsd_reap_locks(&reaplist);
+	return count;
+}
+
+u64
+nfsd_inject_forget_locks(struct nfsd_fault_inject_op *op, u64 max)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		count += nfsd_collect_client_locks(clp, &reaplist, max - count);
+		if (max != 0 && count >= max)
+			break;
+	}
+	spin_unlock(&nn->client_lock);
+	nfsd_reap_locks(&reaplist);
+	return count;
+}
+
 static u64 nfsd_foreach_client_open(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_openowner *))
 {
 	struct nfs4_openowner *oop, *next;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0c4247b2bf8c..fdac0c19cb3c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -478,12 +478,14 @@ u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
 u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *, struct sockaddr_storage *, size_t);
 u64 nfsd_inject_forget_clients(struct nfsd_fault_inject_op *, u64);
 
-u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
+u64 nfsd_inject_print_locks(struct nfsd_fault_inject_op *);
+u64 nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *, struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_locks(struct nfsd_fault_inject_op *, u64);
+
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
 u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
 
-u64 nfsd_print_client_locks(struct nfs4_client *, u64);
 u64 nfsd_print_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_print_client_delegations(struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
-- 
1.9.3

