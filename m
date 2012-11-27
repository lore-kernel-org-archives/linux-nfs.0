Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755290Ab2K0Of2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:35:28 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 08/10] NFSD: Reading a fault injection file prints a state count
Date: Tue, 27 Nov 2012 09:35:17 -0500
Message-Id: <1354026919-13313-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I also log basic information that I can figure out about the type of
state (such as number of locks for each client IP address).  This can be
useful for checking that state was actually dropped and later for
checking if the client was able to recover.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 13 +++++++++++--
 fs/nfsd/nfs4state.c    | 42 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h        |  5 +++++
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index bdef6a8..43a591b 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -14,28 +14,34 @@
 struct nfsd_fault_inject_op {
 	char *file;
 	u64 (*forget)(struct nfsd_net *, struct nfs4_client *, u64);
+	u64 (*print)(struct nfsd_net *, struct nfs4_client *, u64);
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
 
@@ -59,9 +65,12 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
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
index ba41006..cf2082d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4591,6 +4591,22 @@ nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
 
+u64 nfsd_print_client(struct nfsd_net *nn, struct nfs4_client *clp, u64 num)
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
+	printk(KERN_INFO "NFS Client: %s has %u %s\n", buf, count, type);
+}
+
 u64 nfsd_forget_client(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
 {
 	nfsd4_client_record_remove(clp);
@@ -4624,6 +4640,13 @@ u64 nfsd_forget_client_locks(struct nfsd_net *nn, struct nfs4_client *clp, u64 m
 	return nfsd_foreach_client_lock(nn, clp, max, release_lockowner);
 }
 
+u64 nfsd_print_client_locks(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
+{
+	u64 count = nfsd_foreach_client_lock(nn, clp, max, NULL);
+	nfsd_print_count(clp, count, "locked files");
+	return count;
+}
+
 static u64 nfsd_foreach_client_open(struct nfsd_net *nn, struct nfs4_client *clp,
 				    u64 max, void (*func)(struct nfs4_openowner *))
 {
@@ -4645,6 +4668,13 @@ u64 nfsd_forget_client_openowners(struct nfsd_net *nn, struct nfs4_client *clp,
 	return nfsd_foreach_client_open(nn, clp, max, release_openowner);
 }
 
+u64 nfsd_print_client_openowners(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
+{
+	u64 count = nfsd_foreach_client_open(nn, clp, max, NULL);
+	nfsd_print_count(clp, count, "open files");
+	return count;
+}
+
 static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 				     struct list_head *victims)
 {
@@ -4691,6 +4721,18 @@ u64 nfsd_recall_client_delegations(struct nfsd_net *nn, struct nfs4_client *clp,
 	return count;
 }
 
+u64 nfsd_print_client_delegations(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
+{
+	u64 count = 0;
+
+	spin_lock(&recall_lock);
+	count = nfsd_find_all_delegations(clp, max, NULL);
+	spin_unlock(&recall_lock);
+
+	nfsd_print_count(clp, count, "delegations");
+	return count;
+}
+
 u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
 {
 	struct nfs4_client *clp, *next;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4d836ed..1878234 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -508,6 +508,11 @@ u64 nfsd_forget_client_locks(struct nfsd_net *, struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfsd_net *, struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfsd_net *, struct nfs4_client *, u64);
 u64 nfsd_recall_client_delegations(struct nfsd_net *, struct nfs4_client *, u64);
+
+u64 nfsd_print_client(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_print_client_locks(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_print_client_openowners(struct nfsd_net *, struct nfs4_client *, u64);
+u64 nfsd_print_client_delegations(struct nfsd_net *, struct nfs4_client *, u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.8.0.1

