Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2020 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919Ab2GPUj1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:27 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/12] NFS: Initialize v4 sysctls from nfs_init_v4()
Date: Mon, 16 Jul 2012 16:39:14 -0400
Message-Id: <1342471161-22452-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

And split them out of the generic client into their own file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |  7 +++++-
 fs/nfs/nfs4_fs.h    | 15 ++++++++++++
 fs/nfs/nfs4super.c  |  9 +++++++
 fs/nfs/nfs4sysctl.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/sysctl.c     | 26 --------------------
 5 files changed, 98 insertions(+), 27 deletions(-)
 create mode 100644 fs/nfs/nfs4sysctl.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 162a699..4a78e76 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -17,7 +17,12 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
-nfs-$(CONFIG_SYSCTL) += sysctl.o
+
+ifeq ($(CONFIG_SYSCTL), y)
+nfs-y += sysctl.o
+nfs-$(CONFIG_NFS_V4) += nfs4sysctl.o
+endif
+
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1a6ed3f..b508fef 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -368,6 +368,21 @@ extern const nfs4_stateid zero_stateid;
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
+/* nfs4sysctl.c */
+#ifdef CONFIG_SYSCTL
+int nfs4_register_sysctl(void);
+void nfs4_unregister_sysctl(void);
+#else
+static inline int nfs4_register_sysctl(void)
+{
+	return 0;
+}
+
+static inline int nfs4_unregister_sysctl(void)
+{
+}
+#endif
+
 /* nfs4xdr.c */
 extern struct rpc_procinfo nfs4_procedures[];
 
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 366e414..70c394e 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,6 +3,8 @@
  */
 #include <linux/init.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_fs.h>
+#include "nfs4_fs.h"
 
 int __init init_nfs_v4(void)
 {
@@ -12,12 +14,19 @@ int __init init_nfs_v4(void)
 	if (err)
 		goto out;
 
+	err = nfs4_register_sysctl();
+	if (err)
+		goto out1;
+
 	return 0;
+out1:
+	nfs_idmap_quit();
 out:
 	return err;
 }
 
 void __exit exit_nfs_v4(void)
 {
+	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
new file mode 100644
index 0000000..5729bc8
--- /dev/null
+++ b/fs/nfs/nfs4sysctl.c
@@ -0,0 +1,68 @@
+/*
+ * linux/fs/nfs/nfs4sysctl.c
+ *
+ * Sysctl interface to NFS v4 parameters
+ *
+ * Copyright (c) 2006 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+#include <linux/sysctl.h>
+#include <linux/nfs_idmap.h>
+#include <linux/nfs_fs.h>
+
+#include "callback.h"
+
+static const int nfs_set_port_min = 0;
+static const int nfs_set_port_max = 65535;
+static struct ctl_table_header *nfs4_callback_sysctl_table;
+
+static ctl_table nfs4_cb_sysctls[] = {
+	{
+		.procname = "nfs_callback_tcpport",
+		.data = &nfs_callback_set_tcpport,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = proc_dointvec_minmax,
+		.extra1 = (int *)&nfs_set_port_min,
+		.extra2 = (int *)&nfs_set_port_max,
+	},
+	{
+		.procname = "idmap_cache_timeout",
+		.data = &nfs_idmap_cache_timeout,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = proc_dointvec_jiffies,
+	},
+	{ }
+};
+
+static ctl_table nfs4_cb_sysctl_dir[] = {
+	{
+		.procname = "nfs",
+		.mode = 0555,
+		.child = nfs4_cb_sysctls,
+	},
+	{ }
+};
+
+static ctl_table nfs4_cb_sysctl_root[] = {
+	{
+		.procname = "fs",
+		.mode = 0555,
+		.child = nfs4_cb_sysctl_dir,
+	},
+	{ }
+};
+
+int nfs4_register_sysctl(void)
+{
+	nfs4_callback_sysctl_table = register_sysctl_table(nfs4_cb_sysctl_root);
+	if (nfs4_callback_sysctl_table == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+void nfs4_unregister_sysctl(void)
+{
+	unregister_sysctl_table(nfs4_callback_sysctl_table);
+	nfs4_callback_sysctl_table = NULL;
+}
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index ad4d2e7..6b3f253 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -9,37 +9,11 @@
 #include <linux/fs.h>
 #include <linux/sysctl.h>
 #include <linux/module.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
-#include "callback.h"
-
-#ifdef CONFIG_NFS_V4
-static const int nfs_set_port_min = 0;
-static const int nfs_set_port_max = 65535;
-#endif
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
 static ctl_table nfs_cb_sysctls[] = {
-#ifdef CONFIG_NFS_V4
-	{
-		.procname = "nfs_callback_tcpport",
-		.data = &nfs_callback_set_tcpport,
-		.maxlen = sizeof(int),
-		.mode = 0644,
-		.proc_handler = proc_dointvec_minmax,
-		.extra1 = (int *)&nfs_set_port_min,
-		.extra2 = (int *)&nfs_set_port_max,
-	},
-	{
-		.procname = "idmap_cache_timeout",
-		.data = &nfs_idmap_cache_timeout,
-		.maxlen = sizeof(int),
-		.mode = 0644,
-		.proc_handler = proc_dointvec_jiffies,
-	},
-#endif
 	{
 		.procname	= "nfs_mountpoint_timeout",
 		.data		= &nfs_mountpoint_expiry_timeout,
-- 
1.7.11.2

