Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52812 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab2IQUQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:27 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] NFSD: Reading a fault injection file prints a state count
Date: Mon, 17 Sep 2012 16:16:17 -0400
Message-Id: <1347912979-20603-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I also log basic information that I can figure out about the type of
state (such as number of locks for each client IP address).  This can be
useful for checking that state was actually dropped and later for
checking if the client was able to recover.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 13 +++++++++--
 fs/nfsd/nfs4state.c    | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h        |  5 +++++
 3 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 09feb80..1fdf535 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -13,28 +13,34 @@
 struct nfsd_fault_inject_op {
 	char *file;
 	u64 (*forget)(struct nfs4_client *, u64);
+	u64 (*print)(struct nfs4_client *, u64);
 };
 
 static struct nfsd_fault_inject_op inject_ops[] = {
 	{
 		.file   = "forget_clients",
 		.forget = nfsd_forget_client,
+		.print  = nfsd_print_client,
 	},
 	{
 		.file   = "forget_locks",
 		.forget = nfsd_forget_client_locks,
+		.print  = nfsd_print_client_locks,
 	},
 	{
 		.file   = "forget_openowners",
 		.forget = nfsd_forget_client_openowners,
+		.print  = nfsd_print_client_openowners,
 	},
 	{
 		.file   = "forget_delegations",
 		.forget = nfsd_forget_client_delegations,
+		.print  = nfsd_print_client_delegations,
 	},
 	{
 		.file   = "recall_delegations",
 		.forget = nfsd_recall_client_delegations,
+		.print  = nfsd_print_client_delegations,
 	},
 };
 
@@ -58,9 +64,12 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 	return 0;
 }
 
-static int nfsd_inject_get(void *data, u64 *val)
+static int nfsd_inject_get(void *op_ptr, u64 *val)
 {
-	*val = 0;
+	struct nfsd_fault_inject_op *op = op_ptr;
+	nfs4_lock_state();
+	*val = nfsd_for_n_state(0, op->print);
+	nfs4_unlock_state();
 	return 0;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fee5c96..a5a3b46d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4539,6 +4539,22 @@ nfs4_check_open_reclaim(clientid_t *clid)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
+u64 nfsd_print_client(struct nfs4_client *clp, u64 num)
+{
+	char buf[INET6_ADDRSTRLEN];
+	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+	printk(KERN_INFO "NFS Client: %s\n", buf);
+	return 1;
+}
+
+static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
+			     const char *type)
+{
+	char buf[INET6_ADDRSTRLEN];
+	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+	printk(KERN_INFO "NFS Client: %s has %d %s\n", buf, count, type);
+}
+
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
 	nfsd4_client_record_remove(clp);
@@ -4564,6 +4580,23 @@ u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
+u64 nfsd_print_client_locks(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_stateowner *sop;
+	u64 count = 0;
+	int i;
+
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		list_for_each_entry(sop, &ownerstr_hashtbl[i], so_strhash) {
+			if (!sop->so_is_open_owner && (sop->so_client == clp))
+				count++;
+		}
+	}
+
+	nfsd_print_count(clp, count, "locked files");
+	return count;
+}
+
 u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
 {
 	struct nfs4_openowner *oop, *next;
@@ -4578,6 +4611,17 @@ u64 nfsd_forget_client_openowners(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
+u64 nfsd_print_client_openowners(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_openowner *oop;
+	u64 count = 0;
+
+	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient)
+		count++;
+	nfsd_print_count(clp, count, "open files");
+	return count;
+}
+
 static u64 nfsd_find_n_delegations(struct nfs4_client *clp, u64 max,
 				   struct list_head *victims)
 {
@@ -4624,6 +4668,20 @@ u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 	return count;
 }
 
+u64 nfsd_print_client_delegations(struct nfs4_client *clp, u64 max)
+{
+	struct nfs4_delegation *dp;
+	u64 count = 0;
+
+	spin_lock(&recall_lock);
+	list_for_each_entry(dp, &clp->cl_delegations, dl_perclnt)
+		count++;
+	spin_unlock(&recall_lock);
+
+	nfsd_print_count(clp, count, "delegations");
+	return count;
+}
+
 u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5628a33..881781a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -493,6 +493,11 @@ u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
 u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
+
+u64 nfsd_print_client(struct nfs4_client *, u64);
+u64 nfsd_print_client_locks(struct nfs4_client *, u64);
+u64 nfsd_print_client_openowners(struct nfs4_client *, u64);
+u64 nfsd_print_client_delegations(struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.7.12

