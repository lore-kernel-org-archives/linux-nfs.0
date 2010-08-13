Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab0HMVcN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:13 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 10/50] pnfs_submit: register unregister pnfs module
Date: Fri, 13 Aug 2010 17:31:22 -0400
Message-Id: <1281735122-1496-11-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-10-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c            |   10 ++++
 fs/nfs/pnfs.c             |  113 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   10 ++++
 include/linux/nfs4_pnfs.h |   31 ++++++++++++
 include/linux/nfs_fs.h    |    1 +
 5 files changed, 165 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ec7a8f9..64261ea 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -48,6 +48,7 @@
 #include "internal.h"
 #include "fscache.h"
 #include "dns_resolve.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -1550,6 +1551,12 @@ static int __init init_nfs_fs(void)
 	if (err)
 		goto out0;
 
+#ifdef CONFIG_NFS_V4_1
+	err = pnfs_initialize();
+	if (err)
+		goto out00;
+#endif /* CONFIG_NFS_V4_1 */
+
 #ifdef CONFIG_PROC_FS
 	rpc_proc_register(&nfs_rpcstat);
 #endif
@@ -1560,6 +1567,9 @@ out:
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
+#ifdef CONFIG_NFS_V4_1
+out00:
+#endif /* CONFIG_NFS_V4_1 */
 	nfs_destroy_directcache();
 out0:
 	nfs_destroy_writepagecache();
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4ea7301..73558b7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -34,4 +34,117 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/fs.h>
+#include <linux/module.h>
+#include <linux/smp_lock.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
+#include <linux/nfs_page.h>
+#include <linux/nfs4.h>
+#include <linux/pnfs_xdr.h>
+#include <linux/nfs4_pnfs.h>
+#include <linux/rculist.h>
+
+#include "internal.h"
+#include "nfs4_fs.h"
+#include "pnfs.h"
+
 #define NFSDBG_FACILITY		NFSDBG_PNFS
+
+#define MIN_POOL_LC		(4)
+
+static int pnfs_initialized;
+
+/* Locking:
+ *
+ * pnfs_spinlock:
+ * 	protects pnfs_modules_tbl.
+ */
+static spinlock_t pnfs_spinlock = __SPIN_LOCK_UNLOCKED(pnfs_spinlock);
+
+/*
+ * pnfs_modules_tbl holds all pnfs modules
+ */
+static struct list_head	pnfs_modules_tbl;
+
+/*
+ * struct pnfs_module - One per pNFS device module.
+ */
+struct pnfs_module {
+	struct pnfs_layoutdriver_type *pnfs_ld_type;
+	struct list_head        pnfs_tblid;
+};
+
+int
+pnfs_initialize(void)
+{
+	INIT_LIST_HEAD(&pnfs_modules_tbl);
+
+	pnfs_initialized = 1;
+	return 0;
+}
+
+/* search pnfs_modules_tbl for right pnfs module */
+static int
+find_pnfs(u32 id, struct pnfs_module **module) {
+	struct  pnfs_module *local = NULL;
+
+	dprintk("PNFS: %s: Searching for %u\n", __func__, id);
+	list_for_each_entry(local, &pnfs_modules_tbl, pnfs_tblid) {
+		if (local->pnfs_ld_type->id == id) {
+			*module = local;
+			return(1);
+		}
+	}
+	return 0;
+}
+
+
+/* Allow I/O module to set its functions structure */
+struct pnfs_client_operations*
+pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
+{
+	struct pnfs_module *pnfs_mod;
+
+	if (!pnfs_initialized) {
+		printk(KERN_ERR "%s Registration failure. "
+		       "pNFS not initialized.\n", __func__);
+		return NULL;
+	}
+
+	pnfs_mod = kmalloc(sizeof(struct pnfs_module), GFP_KERNEL);
+	if (pnfs_mod != NULL) {
+		dprintk("%s Registering id:%u name:%s\n",
+			__func__,
+			ld_type->id,
+			ld_type->name);
+		pnfs_mod->pnfs_ld_type = ld_type;
+		INIT_LIST_HEAD(&pnfs_mod->pnfs_tblid);
+
+		spin_lock(&pnfs_spinlock);
+		list_add(&pnfs_mod->pnfs_tblid, &pnfs_modules_tbl);
+		spin_unlock(&pnfs_spinlock);
+	}
+
+	return &pnfs_ops;
+}
+
+/*  Allow I/O module to set its functions structure */
+void
+pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
+{
+	struct pnfs_module *pnfs_mod;
+
+	if (find_pnfs(ld_type->id, &pnfs_mod)) {
+		dprintk("%s Deregistering id:%u\n", __func__, ld_type->id);
+		spin_lock(&pnfs_spinlock);
+		list_del(&pnfs_mod->pnfs_tblid);
+		spin_unlock(&pnfs_spinlock);
+		kfree(pnfs_mod);
+	}
+}
+
+EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
+EXPORT_SYMBOL(pnfs_register_layoutdriver);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7b5ebd9..92538ce 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -12,7 +12,17 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+#include <linux/nfs4_pnfs.h>
+
 #ifdef CONFIG_NFS_V4_1
+
+#include <linux/nfs_page.h>
+#include <linux/pnfs_xdr.h>
+#include <linux/nfs_iostat.h>
+#include "iostat.h"
+
+int pnfs_initialize(void);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 04bdd10..4cc22c6 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -12,4 +12,35 @@
 #ifndef LINUX_NFS4_PNFS_H
 #define LINUX_NFS4_PNFS_H
 
+
+/* Per-layout driver specific registration structure */
+struct pnfs_layoutdriver_type {
+	const u32 id;
+	const char *name;
+	struct layoutdriver_io_operations *ld_io_ops;
+	struct layoutdriver_policy_operations *ld_policy_ops;
+};
+
+/* Layout driver I/O operations.
+ * Either the pagecache or non-pagecache read/write operations must be implemented
+ */
+struct layoutdriver_io_operations {
+};
+
+struct layoutdriver_policy_operations {
+};
+
+/* pNFS client callback functions.
+ * These operations allow the layout driver to access pNFS client
+ * specific information or call pNFS client->server operations.
+ * E.g., getdeviceinfo, I/O callbacks, etc
+ */
+struct pnfs_client_operations {
+};
+
+extern struct pnfs_client_operations pnfs_ops;
+
+extern struct pnfs_client_operations *pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
+extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
+
 #endif /* LINUX_NFS4_PNFS_H */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 508f8cf..042c2bd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -613,6 +613,7 @@ extern void * nfs_root_data(void);
 #define NFSDBG_CLIENT		0x0200
 #define NFSDBG_MOUNT		0x0400
 #define NFSDBG_FSCACHE		0x0800
+#define NFSDBG_PNFS		0x1000
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__
-- 
1.6.2.5

