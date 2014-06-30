Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:46069 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbaF3Pwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:50 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so6704463qab.29
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 098/114] nfsd: add more granular locking to forget_openowners fault injector
Date: Mon, 30 Jun 2014 11:50:07 -0400
Message-Id: <1404143423-24381-99-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of relying on the client_mutex.

Also, fix up the printk output that is generated when the file is read.
It currently says that it's reporting the number of open files, but
it's actually reporting the number of openowners.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |   8 ++--
 fs/nfsd/nfs4state.c    | 122 +++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/state.h        |   7 ++-
 3 files changed, 122 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index a444d821d2a5..d4472cd19807 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -146,11 +146,9 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 	},
 	{
 		.file     = "forget_openowners",
-		.get	  = nfsd_inject_get,
-		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
-		.forget   = nfsd_forget_client_openowners,
-		.print    = nfsd_print_client_openowners,
+		.get	  = nfsd_inject_print_openowners,
+		.set_val  = nfsd_inject_forget_openowners,
+		.set_clnt = nfsd_inject_forget_client_openowners,
 	},
 	{
 		.file     = "forget_delegations",
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a00244918cd1..207d16f48761 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5910,30 +5910,136 @@ nfsd_inject_forget_locks(struct nfsd_fault_inject_op *op, u64 max)
 	return count;
 }
 
-static u64 nfsd_foreach_client_open(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_openowner *))
+static u64
+nfsd_foreach_client_openowner(struct nfs4_client *clp, u64 max,
+			      struct list_head *collect,
+			      void (*func)(struct nfs4_openowner *))
 {
 	struct nfs4_openowner *oop, *next;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
 	u64 count = 0;
 
+	lockdep_assert_held(&nn->client_lock);
+
+	spin_lock(&clp->cl_lock);
 	list_for_each_entry_safe(oop, next, &clp->cl_openowners, oo_perclient) {
-		if (func)
+		if (func) {
 			func(oop);
-		if (++count == max)
+			if (collect) {
+				atomic_inc(&clp->cl_refcount);
+				list_add(&oop->oo_perclient, collect);
+			}
+		}
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
+	spin_unlock(&clp->cl_lock);
+
+	return count;
+}
 
+static u64
+nfsd_print_client_openowners(struct nfs4_client *clp)
+{
+	u64 count = nfsd_foreach_client_openowner(clp, 0, NULL, NULL);
+
+	nfsd_print_count(clp, count, "openowners");
 	return count;
 }
 
-u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
+static u64
+nfsd_collect_client_openowners(struct nfs4_client *clp,
+			       struct list_head *collect, u64 max)
 {
-	return nfsd_foreach_client_open(clp, max, release_openowner);
+	return nfsd_foreach_client_openowner(clp, max, collect,
+						unhash_openowner_locked);
 }
 
-u64 nfsd_print_client_openowners(struct nfs4_client *clp, u64 max)
+u64
+nfsd_inject_print_openowners(struct nfsd_fault_inject_op *op)
 {
-	u64 count = nfsd_foreach_client_open(clp, max, NULL);
-	nfsd_print_count(clp, count, "open files");
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
+		count += nfsd_print_client_openowners(clp);
+	spin_unlock(&nn->client_lock);
+
+	return count;
+}
+
+static void
+nfsd_reap_openowners(struct list_head *reaplist)
+{
+	struct nfs4_client *clp;
+	struct nfs4_openowner *oop, *next;
+
+	list_for_each_entry_safe(oop, next, reaplist, oo_perclient) {
+		list_del_init(&oop->oo_perclient);
+		clp = oop->oo_owner.so_client;
+		release_openowner(oop);
+		put_client(clp);
+	}
+}
+
+u64
+nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *op,
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
+		count = nfsd_collect_client_openowners(clp, &reaplist, 0);
+	spin_unlock(&nn->client_lock);
+	nfsd_reap_openowners(&reaplist);
+	return count;
+}
+
+u64
+nfsd_inject_forget_openowners(struct nfsd_fault_inject_op *op, u64 max)
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
+		count += nfsd_collect_client_openowners(clp, &reaplist,
+							max - count);
+		if (max != 0 && count >= max)
+			break;
+	}
+	spin_unlock(&nn->client_lock);
+	nfsd_reap_openowners(&reaplist);
 	return count;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5015ad3c9282..36651017697b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -483,11 +483,14 @@ u64 nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *,
 				    struct sockaddr_storage *, size_t);
 u64 nfsd_inject_forget_locks(struct nfsd_fault_inject_op *, u64);
 
-u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
+u64 nfsd_inject_print_openowners(struct nfsd_fault_inject_op *);
+u64 nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *,
+					 struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_openowners(struct nfsd_fault_inject_op *, u64);
+
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
 u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
 
-u64 nfsd_print_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_print_client_delegations(struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
-- 
1.9.3

