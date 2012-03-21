Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758607Ab2CUPVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:17 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 10/23] NFS: Initialize NFS v4 from nfs4super.c
Date: Wed, 21 Mar 2012 11:20:40 -0400
Message-Id: <1332343253-24970-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This includes starting the idmapper, registering sysctls and registering
the nfs_subversion struct with the generic NFS client.  I also added in
a call to exit_nfs_v4() when the NFS module exits to undo everything
before exiting.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile                   |    2 +-
 fs/nfs/client.c                   |   12 ----------
 fs/nfs/inode.c                    |   14 +++++------
 fs/nfs/nfs.h                      |    2 +-
 fs/nfs/nfs4_fs.h                  |    9 +++++++
 fs/nfs/nfs4super.c                |   23 ++++++++++++++++++
 fs/nfs/{sysctl.c => nfs4sysctl.c} |   47 ++++++++++++++-----------------------
 fs/nfs/sysctl.c                   |   26 --------------------
 8 files changed, 57 insertions(+), 78 deletions(-)
 copy fs/nfs/{sysctl.c => nfs4sysctl.c} (51%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index e155299..7c8a7a0 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,7 +12,7 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o
+			   nfs4namespace.o nfs4sysctl.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 66d4875..adc548c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -179,18 +179,6 @@ void unregister_nfs_version(struct nfs_subversion *nfs)
 EXPORT_SYMBOL_GPL(unregister_nfs_version);
 
 /*
- * Preload all configured NFS versions during module init.
- * This function should be edited after each protocol is converted,
- * and eventually removed.
- */
-void __init nfs_register_versions(void)
-{
-#ifdef CONFIG_NFS_V4
-	init_nfs_v4();
-#endif
-}
-
-/*
  * Allocate a shared client record
  *
  * Since these are allocated/deallocated very rarely, we don't
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 88da7cd..30c7103 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1660,10 +1660,6 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
-	err = nfs_idmap_init();
-	if (err < 0)
-		goto out10;
-
 	err = nfs_dns_resolver_init();
 	if (err < 0)
 		goto out9;
@@ -1709,7 +1705,9 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-	nfs_register_versions();
+#ifdef CONFIG_NFS_V4
+	init_nfs_v4();
+#endif
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
@@ -1735,13 +1733,14 @@ out7:
 out8:
 	nfs_dns_resolver_destroy();
 out9:
-	nfs_idmap_quit();
-out10:
 	return err;
 }
 
 static void __exit exit_nfs_fs(void)
 {
+#ifdef CONFIG_NFS_V4
+	exit_nfs_v4();
+#endif
 	nfs_destroy_directcache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
@@ -1750,7 +1749,6 @@ static void __exit exit_nfs_fs(void)
 	nfs_fscache_unregister();
 	unregister_pernet_subsys(&nfs_net_ops);
 	nfs_dns_resolver_destroy();
-	nfs_idmap_quit();
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
 #endif
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 9caae33..1f93181 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -27,8 +27,8 @@ struct nfs_subversion {
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 };
 
-void nfs_register_versions(void);
 int init_nfs_v4(void);
+void exit_nfs_v4(void);
 
 struct nfs_subversion *get_nfs_version(unsigned int);
 struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6786c4f..0652352 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -350,6 +350,15 @@ extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_sta
 
 extern const nfs4_stateid zero_stateid;
 
+/* nfs4sysctl.h */
+#ifdef CONFIG_SYSCTL
+int nfs4_register_sysctl(void);
+void nfs4_unregister_sysctl(void);
+#else
+inline int nfs4_register_sysctl(void) { return 0; }
+inline void nfs4_unregister_sysctl(void) { }
+#endif /* CONFIG_SYSCTL */
+
 /* nfs4xdr.c */
 extern struct rpc_procinfo nfs4_procedures[];
 
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index f6c8f9f..9dc0c37 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -4,6 +4,7 @@
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs4_mount.h>
+#include <linux/nfs_idmap.h>
 #include "internal.h"
 #include "nfs4_fs.h"
 #include "nfs.h"
@@ -51,6 +52,28 @@ static struct nfs_subversion nfs_v4 = {
 
 int __init init_nfs_v4(void)
 {
+	int err;
+
+	err = nfs_idmap_init();
+	if (err < 0)
+		goto out_1;
+
+	err = nfs4_register_sysctl();
+	if (err < 0)
+		goto out_0;
+
 	register_nfs_version(&nfs_v4);
 	return 0;
+
+out_0:
+	nfs_idmap_quit();
+out_1:
+	return err;
+}
+
+void __exit exit_nfs_v4(void)
+{
+	unregister_nfs_version(&nfs_v4);
+	nfs4_unregister_sysctl();
+	nfs_idmap_quit();
 }
diff --git a/fs/nfs/sysctl.c b/fs/nfs/nfs4sysctl.c
similarity index 51%
copy from fs/nfs/sysctl.c
copy to fs/nfs/nfs4sysctl.c
index ad4d2e7..07b67bb 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -3,6 +3,9 @@
  *
  * Sysctl interface to NFS parameters
  */
+
+#ifdef CONFIG_SYSCTL
+
 #include <linux/types.h>
 #include <linux/linkage.h>
 #include <linux/ctype.h>
@@ -15,14 +18,11 @@
 
 #include "callback.h"
 
-#ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
-#endif
-static struct ctl_table_header *nfs_callback_sysctl_table;
+static struct ctl_table_header *nfs4_callback_sysctl_table;
 
-static ctl_table nfs_cb_sysctls[] = {
-#ifdef CONFIG_NFS_V4
+static ctl_table nfs4_cb_sysctls[] = {
 	{
 		.procname = "nfs_callback_tcpport",
 		.data = &nfs_callback_set_tcpport,
@@ -39,52 +39,39 @@ static ctl_table nfs_cb_sysctls[] = {
 		.mode = 0644,
 		.proc_handler = proc_dointvec_jiffies,
 	},
-#endif
-	{
-		.procname	= "nfs_mountpoint_timeout",
-		.data		= &nfs_mountpoint_expiry_timeout,
-		.maxlen		= sizeof(nfs_mountpoint_expiry_timeout),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nfs_congestion_kb",
-		.data		= &nfs_congestion_kb,
-		.maxlen		= sizeof(nfs_congestion_kb),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{ }
 };
 
-static ctl_table nfs_cb_sysctl_dir[] = {
+static ctl_table nfs4_cb_sysctl_dir[] = {
 	{
 		.procname = "nfs",
 		.mode = 0555,
-		.child = nfs_cb_sysctls,
+		.child = nfs4_cb_sysctls,
 	},
 	{ }
 };
 
-static ctl_table nfs_cb_sysctl_root[] = {
+static ctl_table nfs4_cb_sysctl_root[] = {
 	{
 		.procname = "fs",
 		.mode = 0555,
-		.child = nfs_cb_sysctl_dir,
+		.child = nfs4_cb_sysctl_dir,
 	},
 	{ }
 };
 
-int nfs_register_sysctl(void)
+int nfs4_register_sysctl(void)
 {
-	nfs_callback_sysctl_table = register_sysctl_table(nfs_cb_sysctl_root);
-	if (nfs_callback_sysctl_table == NULL)
+	nfs4_callback_sysctl_table = register_sysctl_table(nfs4_cb_sysctl_root);
+	if (nfs4_callback_sysctl_table == NULL)
 		return -ENOMEM;
 	return 0;
 }
 
-void nfs_unregister_sysctl(void)
+void nfs4_unregister_sysctl(void)
 {
-	unregister_sysctl_table(nfs_callback_sysctl_table);
-	nfs_callback_sysctl_table = NULL;
+	unregister_sysctl_table(nfs4_callback_sysctl_table);
+	nfs4_callback_sysctl_table = NULL;
 }
+
+#endif /* CONFIG_SYSCTL */
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
1.7.9.4

