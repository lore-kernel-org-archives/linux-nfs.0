Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754Ab2AMUL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:29 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 30/44] NFS: Move over NFS v4 sysctls
Date: Fri, 13 Jan 2012 15:10:39 -0500
Message-Id: <1326485453-1350-31-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I moved the sysctls from the generic NFS client to the v4 subdirectory
and then changed the v4 startup function to register sysctls when it is
run.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile            |    2 +-
 fs/nfs/nfs.h               |    2 --
 fs/nfs/nfs4/module.c       |    9 +++++++++
 fs/nfs/nfs4/nfs4.h         |    3 +++
 fs/nfs/{ => nfs4}/sysctl.c |   27 +++------------------------
 fs/nfs/sysctl.c            |   28 ----------------------------
 6 files changed, 16 insertions(+), 55 deletions(-)
 copy fs/nfs/{ => nfs4}/sysctl.c (69%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 3850b1f..87213a8 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/delegation.o nfs4/idmap.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
-			   nfs4/client.o nfs4/module.o
+			   nfs4/client.o nfs4/module.o nfs4/sysctl.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 455bacf..7b40e24 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -51,8 +51,6 @@ struct nfs_subversion {
 					   struct nfs_clone_mount *);
 };
 
-void nfs_register_versions(void);
-
 struct nfs_subversion *get_nfs_version(unsigned int);
 struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
 struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
diff --git a/fs/nfs/nfs4/module.c b/fs/nfs/nfs4/module.c
index 4ac3069..9edd174 100644
--- a/fs/nfs/nfs4/module.c
+++ b/fs/nfs/nfs4/module.c
@@ -43,11 +43,20 @@ static struct nfs_subversion nfs_v4 = {
 
 int __init init_nfs_v4(void)
 {
+	int ret;
+
+	ret = nfs4_register_sysctl();
+	if (ret < 0)
+		goto error_0;
 	register_nfs_version(&nfs_v4);
 	return 0;
+
+error_0:
+	return ret;
 }
 
 void exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
+	nfs4_unregister_sysctl();
 }
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 227a617..5f69528 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -20,4 +20,7 @@ int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
 int nfs4_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
 void nfs4_put_client(struct nfs_client *);
 
+int nfs4_register_sysctl(void);
+void nfs4_unregister_sysctl(void);
+
 #endif /* __LINUX_FS_NFS_NFS4_H */
diff --git a/fs/nfs/sysctl.c b/fs/nfs/nfs4/sysctl.c
similarity index 69%
copy from fs/nfs/sysctl.c
copy to fs/nfs/nfs4/sysctl.c
index d839b40d..8250314 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/nfs4/sysctl.c
@@ -13,16 +13,13 @@
 #include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
-#include "nfs4/callback.h"
+#include "callback.h"
 
-#ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
-#endif
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
 static ctl_table nfs_cb_sysctls[] = {
-#ifdef CONFIG_NFS_V4
 	{
 		.procname = "nfs_callback_tcpport",
 		.data = &nfs_callback_set_tcpport,
@@ -32,7 +29,6 @@ static ctl_table nfs_cb_sysctls[] = {
 		.extra1 = (int *)&nfs_set_port_min,
 		.extra2 = (int *)&nfs_set_port_max,
 	},
-#ifndef CONFIG_NFS_USE_NEW_IDMAPPER
 	{
 		.procname = "idmap_cache_timeout",
 		.data = &nfs_idmap_cache_timeout,
@@ -40,23 +36,6 @@ static ctl_table nfs_cb_sysctls[] = {
 		.mode = 0644,
 		.proc_handler = proc_dointvec_jiffies,
 	},
-#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
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
-	{ }
 };
 
 static ctl_table nfs_cb_sysctl_dir[] = {
@@ -77,7 +56,7 @@ static ctl_table nfs_cb_sysctl_root[] = {
 	{ }
 };
 
-int nfs_register_sysctl(void)
+int nfs4_register_sysctl(void)
 {
 	nfs_callback_sysctl_table = register_sysctl_table(nfs_cb_sysctl_root);
 	if (nfs_callback_sysctl_table == NULL)
@@ -85,7 +64,7 @@ int nfs_register_sysctl(void)
 	return 0;
 }
 
-void nfs_unregister_sysctl(void)
+void nfs4_unregister_sysctl(void)
 {
 	unregister_sysctl_table(nfs_callback_sysctl_table);
 	nfs_callback_sysctl_table = NULL;
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index d839b40d..6b3f253 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -9,39 +9,11 @@
 #include <linux/fs.h>
 #include <linux/sysctl.h>
 #include <linux/module.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
-#include "nfs4/callback.h"
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
-#ifndef CONFIG_NFS_USE_NEW_IDMAPPER
-	{
-		.procname = "idmap_cache_timeout",
-		.data = &nfs_idmap_cache_timeout,
-		.maxlen = sizeof(int),
-		.mode = 0644,
-		.proc_handler = proc_dointvec_jiffies,
-	},
-#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
-#endif
 	{
 		.procname	= "nfs_mountpoint_timeout",
 		.data		= &nfs_mountpoint_expiry_timeout,
-- 
1.7.8.3

