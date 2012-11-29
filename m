Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59109 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2K2Qk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:57 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 8/9] NFSD: Add a custom file operations structure for fault injection
Date: Thu, 29 Nov 2012 11:40:45 -0500
Message-Id: <1354207246-32343-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
References: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Controlling the read and write functions allows me to add in "forget
client w.x.y.z", since we won't be limited to reading and writing only
u64 values.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 56 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 545f8e4..19f9094 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -8,6 +8,7 @@
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/module.h>
+#include <asm/uaccess.h>
 
 #include "state.h"
 
@@ -48,10 +49,9 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
 static struct dentry *debug_dir;
 
-static int nfsd_inject_set(void *op_ptr, u64 val)
+static void nfsd_inject_set(struct nfsd_fault_inject_op *op, u64 val)
 {
 	u64 count = 0;
-	struct nfsd_fault_inject_op *op = op_ptr;
 
 	if (val == 0)
 		printk(KERN_INFO "NFSD Fault Injection: %s (all)", op->file);
@@ -62,19 +62,61 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 	count = nfsd_for_n_state(val, op->forget);
 	nfs4_unlock_state();
 	printk(KERN_INFO "NFSD: %s: found %llu", op->file, count);
-	return 0;
 }
 
-static int nfsd_inject_get(void *op_ptr, u64 *val)
+static void nfsd_inject_get(struct nfsd_fault_inject_op *op, u64 *val)
 {
-	struct nfsd_fault_inject_op *op = op_ptr;
 	nfs4_lock_state();
 	*val = nfsd_for_n_state(0, op->print);
 	nfs4_unlock_state();
-	return 0;
 }
 
-DEFINE_SIMPLE_ATTRIBUTE(fops_nfsd, nfsd_inject_get, nfsd_inject_set, "%llu\n");
+static ssize_t fault_inject_read(struct file *file, char __user *buf,
+				 size_t len, loff_t *ppos)
+{
+	static u64 val;
+	char read_buf[25];
+	size_t size, ret;
+	loff_t pos = *ppos;
+
+	if (!pos)
+		nfsd_inject_get(file->f_dentry->d_inode->i_private, &val);
+	size = scnprintf(read_buf, sizeof(read_buf), "%llu\n", val);
+
+	if (pos < 0)
+		return -EINVAL;
+	if (pos >= size || !len)
+		return 0;
+	if (len > size - pos)
+		len = size - pos;
+	ret = copy_to_user(buf, read_buf + pos, len);
+	if (ret == len)
+		return -EFAULT;
+	len -= ret;
+	*ppos = pos + len;
+	return len;
+}
+
+static ssize_t fault_inject_write(struct file *file, const char __user *buf,
+				  size_t len, loff_t *ppos)
+{
+	char write_buf[24];
+	size_t size = min(sizeof(write_buf), len) - 1;
+	u64 val;
+
+	if (copy_from_user(write_buf, buf, size))
+		return -EFAULT;
+
+	val = simple_strtoll(write_buf, NULL, 0);
+	nfsd_inject_set(file->f_dentry->d_inode->i_private, val);
+	return len; /* on success, claim we got the whole input */
+}
+
+static const struct file_operations fops_nfsd = {
+	.owner   = THIS_MODULE,
+	.read    = fault_inject_read,
+	.write   = fault_inject_write,
+};
 
 void nfsd_fault_inject_cleanup(void)
 {
-- 
1.8.0.1

