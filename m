Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760264Ab2BJWCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:31 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 19/21] NFS: Convert v4 into a module
Date: Fri, 10 Feb 2012 17:02:03 -0500
Message-Id: <1328911325-1566-19-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The module will be created in the same directory as nfs.ko.  You need to
run `modprobe nfs4` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig     |    2 +-
 fs/nfs/Makefile    |   14 ++++++++------
 fs/nfs/inode.c     |    6 ------
 fs/nfs/nfs4super.c |    5 +++++
 4 files changed, 14 insertions(+), 13 deletions(-)

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
index e983eb0..c356cda 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -7,14 +7,10 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   direct.o pagelist.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o \
-			   dns_resolve.o cache_lib.o
+			   cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   nfs4super.o delegation.o idmap.o \
-			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4client.o nfs4getroot.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
-nfs-$(CONFIG_SYSCTL) += sysctl.o nfs4sysctl.o
+nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_NFS_V2) += nfs2.o
@@ -24,6 +20,12 @@ obj-$(CONFIG_NFS_V3) += nfs3.o
 nfs3-y += nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs3-y += nfs3acl.o
 
+obj-$(CONFIG_NFS_V4) += nfs4.o
+nfs4-y = nfs4super.o nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
+	 delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
+	 nfs4namespace.o dns_resolve.o nfs4client.o nfs4getroot.o
+nfs4-$(CONFIG_SYSCTL) += nfs4sysctl.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cb645e3f..2ee6259 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1637,9 +1637,6 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-#if IS_ENABLED(CONFIG_NFS_V4)
-	init_nfs_v4();
-#endif
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
@@ -1670,9 +1667,6 @@ out9:
 
 static void __exit exit_nfs_fs(void)
 {
-#if IS_ENABLED(CONFIG_NFS_V4)
-	exit_nfs_v4();
-#endif
 	nfs_destroy_directcache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 2764c28..3e515db 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -669,3 +669,8 @@ void __exit exit_nfs_v4(void)
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v4);
+module_exit(exit_nfs_v4);
-- 
1.7.9

