Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:47421 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbaG3M2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:17 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so1173290qaq.24
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 23/37] nfsd: remove old fault injection infrastructure
Date: Wed, 30 Jul 2014 08:27:24 -0400
Message-Id: <1406723258-8512-24-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the old nfsd_for_n_state function and move nfsd_find_client
higher up into the file to get rid of forward declaration. Remove
the struct nfsd_fault_inject_op arguments from the operations as
they are no longer needed by any of them.

Finally, remove the old "standard" get and set routines, which
also eliminates the client_mutex from this code.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c | 51 ++++-------------------------
 fs/nfsd/nfs4state.c    | 87 +++++++++++++++++++-------------------------------
 fs/nfsd/state.h        | 45 +++++++++++---------------
 3 files changed, 57 insertions(+), 126 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 2479dba71c3c..c16bf5af6831 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -17,52 +17,13 @@
 
 struct nfsd_fault_inject_op {
 	char *file;
-	u64 (*get)(struct nfsd_fault_inject_op *);
-	u64 (*set_val)(struct nfsd_fault_inject_op *, u64);
-	u64 (*set_clnt)(struct nfsd_fault_inject_op *,
-			struct sockaddr_storage *, size_t);
-	u64 (*forget)(struct nfs4_client *, u64);
-	u64 (*print)(struct nfs4_client *, u64);
+	u64 (*get)(void);
+	u64 (*set_val)(u64);
+	u64 (*set_clnt)(struct sockaddr_storage *, size_t);
 };
 
 static struct dentry *debug_dir;
 
-static u64 nfsd_inject_set(struct nfsd_fault_inject_op *op, u64 val)
-{
-	u64 count;
-
-	nfs4_lock_state();
-	count = nfsd_for_n_state(val, op->forget);
-	nfs4_unlock_state();
-	return count;
-}
-
-static u64 nfsd_inject_set_client(struct nfsd_fault_inject_op *op,
-				   struct sockaddr_storage *addr,
-				   size_t addr_size)
-{
-	struct nfs4_client *clp;
-	u64 count = 0;
-
-	nfs4_lock_state();
-	clp = nfsd_find_client(addr, addr_size);
-	if (clp)
-		count = op->forget(clp, 0);
-	nfs4_unlock_state();
-	return count;
-}
-
-static u64 nfsd_inject_get(struct nfsd_fault_inject_op *op)
-{
-	u64 count;
-
-	nfs4_lock_state();
-	count = nfsd_for_n_state(0, op->print);
-	nfs4_unlock_state();
-
-	return count;
-}
-
 static ssize_t fault_inject_read(struct file *file, char __user *buf,
 				 size_t len, loff_t *ppos)
 {
@@ -73,7 +34,7 @@ static ssize_t fault_inject_read(struct file *file, char __user *buf,
 	struct nfsd_fault_inject_op *op = file_inode(file)->i_private;
 
 	if (!pos)
-		val = op->get(op);
+		val = op->get();
 	size = scnprintf(read_buf, sizeof(read_buf), "%llu\n", val);
 
 	return simple_read_from_buffer(buf, len, ppos, read_buf, size);
@@ -103,7 +64,7 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 
 	size = rpc_pton(net, write_buf, size, (struct sockaddr *)&sa, sizeof(sa));
 	if (size > 0) {
-		val = op->set_clnt(op, &sa, size);
+		val = op->set_clnt(&sa, size);
 		if (val)
 			pr_info("NFSD [%s]: Client %s had %llu state object(s)\n",
 				op->file, write_buf, val);
@@ -114,7 +75,7 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 		else
 			pr_info("NFSD Fault Injection: %s (n = %llu)",
 				op->file, val);
-		val = op->set_val(op, val);
+		val = op->set_val(val);
 		pr_info("NFSD: %s: found %llu", op->file, val);
 	}
 	return len; /* on success, claim we got the whole input */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f558b12af267..baf83cf96b26 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5725,8 +5725,25 @@ put_client(struct nfs4_client *clp)
 	atomic_dec(&clp->cl_refcount);
 }
 
+static struct nfs4_client *
+nfsd_find_client(struct sockaddr_storage *addr, size_t addr_size)
+{
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+					  nfsd_net_id);
+
+	if (!nfsd_netns_ready(nn))
+		return NULL;
+
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		if (memcmp(&clp->cl_addr, addr, addr_size) == 0)
+			return clp;
+	}
+	return NULL;
+}
+
 u64
-nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
+nfsd_inject_print_clients(void)
 {
 	struct nfs4_client *clp;
 	u64 count = 0;
@@ -5749,8 +5766,7 @@ nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
 }
 
 u64
-nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
-			  struct sockaddr_storage *addr, size_t addr_size)
+nfsd_inject_forget_client(struct sockaddr_storage *addr, size_t addr_size)
 {
 	u64 count = 0;
 	struct nfs4_client *clp;
@@ -5777,7 +5793,7 @@ nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
 }
 
 u64
-nfsd_inject_forget_clients(struct nfsd_fault_inject_op *op, u64 max)
+nfsd_inject_forget_clients(u64 max)
 {
 	u64 count = 0;
 	struct nfs4_client *clp, *next;
@@ -5884,7 +5900,7 @@ nfsd_print_client_locks(struct nfs4_client *clp)
 }
 
 u64
-nfsd_inject_print_locks(struct nfsd_fault_inject_op *op)
+nfsd_inject_print_locks(void)
 {
 	struct nfs4_client *clp;
 	u64 count = 0;
@@ -5917,8 +5933,7 @@ nfsd_reap_locks(struct list_head *reaplist)
 }
 
 u64
-nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *op,
-				struct sockaddr_storage *addr, size_t addr_size)
+nfsd_inject_forget_client_locks(struct sockaddr_storage *addr, size_t addr_size)
 {
 	unsigned int count = 0;
 	struct nfs4_client *clp;
@@ -5939,7 +5954,7 @@ nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *op,
 }
 
 u64
-nfsd_inject_forget_locks(struct nfsd_fault_inject_op *op, u64 max)
+nfsd_inject_forget_locks(u64 max)
 {
 	u64 count = 0;
 	struct nfs4_client *clp;
@@ -6016,7 +6031,7 @@ nfsd_collect_client_openowners(struct nfs4_client *clp,
 }
 
 u64
-nfsd_inject_print_openowners(struct nfsd_fault_inject_op *op)
+nfsd_inject_print_openowners(void)
 {
 	struct nfs4_client *clp;
 	u64 count = 0;
@@ -6049,8 +6064,8 @@ nfsd_reap_openowners(struct list_head *reaplist)
 }
 
 u64
-nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *op,
-				struct sockaddr_storage *addr, size_t addr_size)
+nfsd_inject_forget_client_openowners(struct sockaddr_storage *addr,
+				     size_t addr_size)
 {
 	unsigned int count = 0;
 	struct nfs4_client *clp;
@@ -6071,7 +6086,7 @@ nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *op,
 }
 
 u64
-nfsd_inject_forget_openowners(struct nfsd_fault_inject_op *op, u64 max)
+nfsd_inject_forget_openowners(u64 max)
 {
 	u64 count = 0;
 	struct nfs4_client *clp;
@@ -6145,7 +6160,7 @@ nfsd_print_client_delegations(struct nfs4_client *clp)
 }
 
 u64
-nfsd_inject_print_delegations(struct nfsd_fault_inject_op *op)
+nfsd_inject_print_delegations(void)
 {
 	struct nfs4_client *clp;
 	u64 count = 0;
@@ -6178,8 +6193,8 @@ nfsd_forget_delegations(struct list_head *reaplist)
 }
 
 u64
-nfsd_inject_forget_client_delegations(struct nfsd_fault_inject_op *op,
-				struct sockaddr_storage *addr, size_t addr_size)
+nfsd_inject_forget_client_delegations(struct sockaddr_storage *addr,
+				      size_t addr_size)
 {
 	u64 count = 0;
 	struct nfs4_client *clp;
@@ -6201,7 +6216,7 @@ nfsd_inject_forget_client_delegations(struct nfsd_fault_inject_op *op,
 }
 
 u64
-nfsd_inject_forget_delegations(struct nfsd_fault_inject_op *op, u64 max)
+nfsd_inject_forget_delegations(u64 max)
 {
 	u64 count = 0;
 	struct nfs4_client *clp;
@@ -6247,8 +6262,7 @@ nfsd_recall_delegations(struct list_head *reaplist)
 }
 
 u64
-nfsd_inject_recall_client_delegations(struct nfsd_fault_inject_op *op,
-				      struct sockaddr_storage *addr,
+nfsd_inject_recall_client_delegations(struct sockaddr_storage *addr,
 				      size_t addr_size)
 {
 	u64 count = 0;
@@ -6271,7 +6285,7 @@ nfsd_inject_recall_client_delegations(struct nfsd_fault_inject_op *op,
 }
 
 u64
-nfsd_inject_recall_delegations(struct nfsd_fault_inject_op *op, u64 max)
+nfsd_inject_recall_delegations(u64 max)
 {
 	u64 count = 0;
 	struct nfs4_client *clp, *next;
@@ -6292,41 +6306,6 @@ nfsd_inject_recall_delegations(struct nfsd_fault_inject_op *op, u64 max)
 	nfsd_recall_delegations(&reaplist);
 	return count;
 }
-
-u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
-{
-	struct nfs4_client *clp, *next;
-	u64 count = 0;
-	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
-						nfsd_net_id);
-
-	if (!nfsd_netns_ready(nn))
-		return 0;
-
-	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
-		count += func(clp, max - count);
-		if ((max != 0) && (count >= max))
-			break;
-	}
-
-	return count;
-}
-
-struct nfs4_client *nfsd_find_client(struct sockaddr_storage *addr, size_t addr_size)
-{
-	struct nfs4_client *clp;
-	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
-
-	if (!nfsd_netns_ready(nn))
-		return NULL;
-
-	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
-		if (memcmp(&clp->cl_addr, addr, addr_size) == 0)
-			return clp;
-	}
-	return NULL;
-}
-
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1a9ba857cbab..a363f6bb621e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -471,35 +471,26 @@ extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 
 /* nfs fault injection functions */
 #ifdef CONFIG_NFSD_FAULT_INJECTION
-struct nfsd_fault_inject_op;
-
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
-u64 nfsd_for_n_state(u64, u64 (*)(struct nfs4_client *, u64));
-struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
-
-u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
-u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *,
-			      struct sockaddr_storage *, size_t);
-u64 nfsd_inject_forget_clients(struct nfsd_fault_inject_op *, u64);
-
-u64 nfsd_inject_print_locks(struct nfsd_fault_inject_op *);
-u64 nfsd_inject_forget_client_locks(struct nfsd_fault_inject_op *,
-				    struct sockaddr_storage *, size_t);
-u64 nfsd_inject_forget_locks(struct nfsd_fault_inject_op *, u64);
-
-u64 nfsd_inject_print_openowners(struct nfsd_fault_inject_op *);
-u64 nfsd_inject_forget_client_openowners(struct nfsd_fault_inject_op *,
-					 struct sockaddr_storage *, size_t);
-u64 nfsd_inject_forget_openowners(struct nfsd_fault_inject_op *, u64);
-
-u64 nfsd_inject_print_delegations(struct nfsd_fault_inject_op *);
-u64 nfsd_inject_forget_client_delegations(struct nfsd_fault_inject_op *,
-					  struct sockaddr_storage *, size_t);
-u64 nfsd_inject_forget_delegations(struct nfsd_fault_inject_op *, u64);
-u64 nfsd_inject_recall_client_delegations(struct nfsd_fault_inject_op *,
-					  struct sockaddr_storage *, size_t);
-u64 nfsd_inject_recall_delegations(struct nfsd_fault_inject_op *, u64);
+
+u64 nfsd_inject_print_clients(void);
+u64 nfsd_inject_forget_client(struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_clients(u64);
+
+u64 nfsd_inject_print_locks(void);
+u64 nfsd_inject_forget_client_locks(struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_locks(u64);
+
+u64 nfsd_inject_print_openowners(void);
+u64 nfsd_inject_forget_client_openowners(struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_openowners(u64);
+
+u64 nfsd_inject_print_delegations(void);
+u64 nfsd_inject_forget_client_delegations(struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_delegations(u64);
+u64 nfsd_inject_recall_client_delegations(struct sockaddr_storage *, size_t);
+u64 nfsd_inject_recall_delegations(u64);
 #else /* CONFIG_NFSD_FAULT_INJECTION */
 static inline int nfsd_fault_inject_init(void) { return 0; }
 static inline void nfsd_fault_inject_cleanup(void) {}
-- 
1.9.3

