Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755197Ab2K0Ofa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:35:30 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/10] NFSD: Forget state for a specific client
Date: Tue, 27 Nov 2012 09:35:19 -0500
Message-Id: <1354026919-13313-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Write the client's ip address to any state file and all appropriate
state for that client will be forgotten.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 38 ++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c    | 12 ++++++++++++
 fs/nfsd/state.h        |  1 +
 3 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index bf3b869..699de07 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -8,9 +8,12 @@
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/module.h>
+#include <linux/nsproxy.h>
+#include <linux/sunrpc/clnt.h>
 #include <asm/uaccess.h>
 
 #include "state.h"
+#include "netns.h"
 
 struct nfsd_fault_inject_op {
 	char *file;
@@ -64,6 +67,25 @@ static void nfsd_inject_set(struct nfsd_fault_inject_op *op, u64 val)
 	printk(KERN_INFO "NFSD: %s: found %llu", op->file, count);
 }
 
+static void nfsd_inject_set_client(struct nfsd_fault_inject_op *op,
+				   struct sockaddr_storage *addr,
+				   size_t addr_size)
+{
+	char buf[INET6_ADDRSTRLEN];
+	struct nfs4_client *clp;
+	u64 count;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+
+	nfs4_lock_state();
+	clp = nfsd_find_client(nn, addr, addr_size);
+	if (clp) {
+		count = op->forget(nn, clp, 0);
+		rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+		printk(KERN_INFO "NFSD [%s]: Client %s had %llu state object(s)\n", op->file, buf, count);
+	}
+	nfs4_unlock_state();
+}
+
 static void nfsd_inject_get(struct nfsd_fault_inject_op *op, u64 *val)
 {
 	nfs4_lock_state();
@@ -100,15 +122,23 @@ static ssize_t fault_inject_read(struct file *file, char __user *buf,
 static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 				  size_t len, loff_t *ppos)
 {
-	char write_buf[24];
+	char write_buf[INET6_ADDRSTRLEN];
 	size_t size = min(sizeof(write_buf), len) - 1;
+	struct net *net = current->nsproxy->net_ns;
+	struct sockaddr_storage sa;
 	u64 val;
 
 	if (copy_from_user(write_buf, buf, size))
 		return -EFAULT;
-
-	val = simple_strtoll(write_buf, NULL, 0);
-	nfsd_inject_set(file->f_dentry->d_inode->i_private, val);
+	write_buf[size] = '\0';
+
+	size = rpc_pton(net, write_buf, size, (struct sockaddr *)&sa, sizeof(sa));
+	if (size > 0)
+		nfsd_inject_set_client(file->f_dentry->d_inode->i_private, &sa, size);
+	else {
+		val = simple_strtoll(write_buf, NULL, 0);
+		nfsd_inject_set(file->f_dentry->d_inode->i_private, val);
+	}
 	return len; /* on success, claim we got the whole input */
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cf2082d..b32414e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4748,6 +4748,18 @@ u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client
 	return count;
 }
 
+struct nfs4_client *nfsd_find_client(struct nfsd_net *nn, struct sockaddr_storage *addr,
+				     size_t addr_size)
+{
+	struct nfs4_client *clp;
+
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		if (memcmp(&clp->cl_addr, addr, addr_size) == 0)
+			return clp;
+	}
+	return NULL;
+}
+
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 /* initialization to perform at module load time: */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1878234..996ce69 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -502,6 +502,7 @@ extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
 u64 nfsd_for_n_state(u64, u64 (*)(struct nfsd_net *, struct nfs4_client *, u64));
+struct nfs4_client *nfsd_find_client(struct nfsd_net *, struct sockaddr_storage *, size_t);
 
 u64 nfsd_forget_client(struct nfsd_net *, struct nfs4_client *, u64);
 u64 nfsd_forget_client_locks(struct nfsd_net *, struct nfs4_client*, u64);
-- 
1.8.0.1

