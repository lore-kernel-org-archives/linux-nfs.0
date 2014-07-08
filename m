Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:53621 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406AbaGHSG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:27 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5532200qcy.32
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 083/100] nfsd: add more granular locking to forget_locks fault injector
Date: Tue,  8 Jul 2014 14:04:11 -0400
Message-Id: <1404842668-22521-84-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of relying on the client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |   8 ++-
 fs/nfsd/nfs4state.c    | 132 +++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/state.h        |   7 ++-
 3 files changed, 131 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 76ecdff37ea2..a444d821d2a5 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -140,11 +140,9 @@ static struct nfsd_fault_inject_op inject_ops[] = {
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
index dbd1f422b3ae..5f781c843523 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5702,6 +5702,12 @@ nfs4_check_open_reclaim(clientid_t *clid,
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
+static inline void
+put_client(struct nfs4_client *clp)
+{
+	atomic_dec(&clp->cl_refcount);
+}
+
 u64
 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
 {
@@ -5789,6 +5795,22 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 	printk(KERN_INFO "NFS Client: %s has %u %s\n", buf, count, type);
 }
 
+static void
+nfsd_inject_add_lock_to_list(struct nfs4_ol_stateid *lst,
+			     struct list_head *collect)
+{
+	struct nfs4_client *clp = lst->st_stid.sc_client;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+					  nfsd_net_id);
+
+	if (!collect)
+		return;
+
+	lockdep_assert_held(&nn->client_lock);
+	atomic_inc(&clp->cl_refcount);
+	list_add(&lst->st_locks, collect);
+}
+
 static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 				    struct list_head *collect,
 				    void (*func)(struct nfs4_ol_stateid *))
@@ -5798,6 +5820,7 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 	struct nfs4_ol_stateid *lst, *lst_next;
 	u64 count = 0;
 
+	spin_lock(&clp->cl_lock);
 	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient) {
 		list_for_each_entry_safe(stp, st_next,
 				&oop->oo_owner.so_stateids, st_perstateowner) {
@@ -5805,31 +5828,122 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 					&stp->st_locks, st_locks) {
 				if (func) {
 					func(lst);
-					if (collect)
-						list_add(&lst->st_locks,
-							 collect);
+					nfsd_inject_add_lock_to_list(lst,
+								collect);
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
+nfsd_collect_client_locks(struct nfs4_client *clp, struct list_head *collect,
+			  u64 max)
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
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
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
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
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
index 25b4df7bc57a..5015ad3c9282 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -478,12 +478,15 @@ u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *,
 			      struct sockaddr_storage *, size_t);
 u64 nfsd_inject_forget_clients(struct nfsd_fault_inject_op *, u64);
 
-u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
+u64 nfsd_inject_print_locks(struct nfsd_fault_inject_op *);
+u64 nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *,
+				    struct sockaddr_storage *, size_t);
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

