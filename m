Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52812 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564Ab2IQUQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 16:16:28 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] NFSD: Forget state for a specific client
Date: Mon, 17 Sep 2012 16:16:19 -0400
Message-Id: <1347912979-20603-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Write the client's ip address to any state file and all appropriate
state for that client will be forgotten.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 31 +++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c    | 11 +++++++++++
 fs/nfsd/state.h        |  1 +
 3 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 19b3348..bb6b487 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -8,6 +8,8 @@
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/module.h>
+#include <linux/nsproxy.h>
+#include <linux/sunrpc/clnt.h>
 #include <asm/uaccess.h>
 #include "state.h"
 
@@ -63,6 +65,19 @@ static void nfsd_inject_set(struct nfsd_fault_inject_op *op, u64 val)
 	printk(KERN_INFO "NFSD: %s: found %llu", op->file, count);
 }
 
+static void nfsd_inject_set_client(struct nfsd_fault_inject_op *op,
+				   struct sockaddr_storage *addr,
+				   size_t addr_size)
+{
+	struct nfs4_client *clp;
+
+	nfs4_lock_state();
+	clp = nfsd_find_client(addr, addr_size);
+	if (clp)
+		op->forget(clp, 0);
+	nfs4_unlock_state();
+}
+
 static void nfsd_inject_get(struct nfsd_fault_inject_op *op, u64 *val)
 {
 	nfs4_lock_state();
@@ -99,15 +114,23 @@ static ssize_t fault_inject_read(struct file *file, char __user *buf,
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
index a5a3b46d..9dd145e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4696,6 +4696,17 @@ u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfs4_client *, u64))
 	return count;
 }
 
+struct nfs4_client *nfsd_find_client(struct sockaddr_storage *addr, size_t addr_size)
+{
+	struct nfs4_client *clp;
+
+	list_for_each_entry(clp, &client_lru, cl_lru) {
+		if (memcmp(&clp->cl_addr, addr, addr_size) == 0)
+			return clp;
+	}
+	return NULL;
+}
+
 #endif /* CONFIG_NFSD_FAULT_INJECTION */
 
 /* initialization to perform at module load time: */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 881781a..17435d9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -487,6 +487,7 @@ extern void nfsd4_record_grace_done(struct net *net, time_t boot_time);
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
 u64 nfsd_for_n_state(u64, u64 (*)(struct nfs4_client *, u64));
+struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
 
 u64 nfsd_forget_client(struct nfs4_client *, u64);
 u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
-- 
1.7.12

