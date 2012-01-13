Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33936 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932781Ab2AMULo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:44 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 44/44] NFS: Convert NFS v4 into a module
Date: Fri, 13 Jan 2012 15:10:53 -0500
Message-Id: <1326485453-1350-45-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

You need to run `modprobe nfs4` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig       |    2 +-
 fs/nfs/Makefile      |    1 +
 fs/nfs/inode.c       |    1 -
 fs/nfs/nfs4/module.c |    9 +++++++--
 fs/nfs/nfs4/nfs4.h   |    2 --
 fs/nfs/super.c       |   12 ------------
 6 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 57c4b19..608b84a 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -70,7 +70,7 @@ config NFS_V3_ACL
 	  If unsure, say N.
 
 config NFS_V4
-	bool "NFS client support for NFS version 4"
+	tristate "NFS client support for NFS version 4"
 	depends on NFS_FS
 	select SUNRPC_GSS
 	help
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 34f752d..2a88234 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -25,5 +25,6 @@ nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
 obj-$(CONFIG_NFS_V2) += nfs2/
 obj-$(CONFIG_NFS_V3) += nfs3/
+obj-$(CONFIG_NFS_V4) += nfs4/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d7afc2b..d5f1b5c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1665,7 +1665,6 @@ static void __exit exit_nfs_fs(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
-	nfs_cleanup_cb_ident_idr();
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
diff --git a/fs/nfs/nfs4/module.c b/fs/nfs/nfs4/module.c
index c57b642..80f77c8 100644
--- a/fs/nfs/nfs4/module.c
+++ b/fs/nfs/nfs4/module.c
@@ -41,7 +41,7 @@ static struct nfs_subversion nfs_v4 = {
 	.do_clone_mount = nfs4_do_clone_mount,
 };
 
-int __init init_nfs_v4(void)
+static int __init init_nfs_v4(void)
 {
 	int ret;
 
@@ -60,9 +60,14 @@ error_0:
 	return ret;
 }
 
-void exit_nfs_v4(void)
+static void __exit exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
 	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v4);
+module_exit(exit_nfs_v4);
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 111ba82..dd8f94b 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -5,8 +5,6 @@
 
 extern struct file_system_type nfs4_fs_type;
 
-int init_nfs_v4(void);
-void exit_nfs_v4(void);
 struct nfs_server *nfs4_alloc_server(void);
 struct nfs_server *nfs4_clone_server(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d2d1b6b..c4c5244 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -318,18 +318,9 @@ int __init register_nfs_fs(void)
 	ret = nfs_register_sysctl();
 	if (ret < 0)
 		goto error_1;
-#if IS_ENABLED(CONFIG_NFS_V4)
-	ret = init_nfs_v4();
-	if (ret < 0)
-		goto error_2;
-#endif
 	register_shrinker(&acl_shrinker);
 	return 0;
 
-#if IS_ENABLED(CONFIG_NFS_V4)
-error_2:
-	nfs_unregister_sysctl();
-#endif
 error_1:
 	unregister_filesystem(&nfs_fs_type);
 error_0:
@@ -342,9 +333,6 @@ error_0:
 void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
-#if IS_ENABLED(CONFIG_NFS_V4)
-	exit_nfs_v4();
-#endif
 	nfs_unregister_sysctl();
 	unregister_filesystem(&nfs_fs_type);
 }
-- 
1.7.8.3

