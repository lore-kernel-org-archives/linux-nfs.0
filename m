Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932742Ab2AMULT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:19 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 14/44] NFS: Move v4 to its own subdirectory
Date: Fri, 13 Jan 2012 15:10:23 -0500
Message-Id: <1326485453-1350-15-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This keeps all the v4 code together and separate from the generic NFS
client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile                              |    8 ++++----
 fs/nfs/client.c                              |    6 +++---
 fs/nfs/dir.c                                 |    2 +-
 fs/nfs/file.c                                |    2 +-
 fs/nfs/getroot.c                             |    4 ++--
 fs/nfs/inode.c                               |    6 +++---
 fs/nfs/internal.h                            |    2 +-
 fs/nfs/{ => nfs4}/callback.c                 |    2 +-
 fs/nfs/{ => nfs4}/callback.h                 |    0
 fs/nfs/{ => nfs4}/callback_proc.c            |    4 ++--
 fs/nfs/{ => nfs4}/callback_xdr.c             |    2 +-
 fs/nfs/{ => nfs4}/delegation.c               |    2 +-
 fs/nfs/{ => nfs4}/delegation.h               |    0
 fs/nfs/{ => nfs4}/idmap.c                    |    0
 fs/nfs/{nfs4namespace.c => nfs4/namespace.c} |    4 ++--
 fs/nfs/nfs4/nfs4.h                           |    6 ++++++
 fs/nfs/{ => nfs4}/nfs4_fs.h                  |    0
 fs/nfs/{nfs4proc.c => nfs4/proc.c}           |    6 +++---
 fs/nfs/{nfs4renewd.c => nfs4/renewd.c}       |    0
 fs/nfs/{nfs4state.c => nfs4/state.c}         |    4 ++--
 fs/nfs/{nfs4xdr.c => nfs4/xdr.c}             |    4 ++--
 fs/nfs/read.c                                |    2 +-
 fs/nfs/super.c                               |    6 +++---
 fs/nfs/sysctl.c                              |    2 +-
 fs/nfs/unlink.c                              |    4 ++--
 fs/nfs/write.c                               |    4 ++--
 26 files changed, 44 insertions(+), 38 deletions(-)
 rename fs/nfs/{ => nfs4}/callback.c (99%)
 rename fs/nfs/{ => nfs4}/callback.h (100%)
 rename fs/nfs/{ => nfs4}/callback_proc.c (99%)
 rename fs/nfs/{ => nfs4}/callback_xdr.c (99%)
 rename fs/nfs/{ => nfs4}/delegation.c (99%)
 rename fs/nfs/{ => nfs4}/delegation.h (100%)
 rename fs/nfs/{ => nfs4}/idmap.c (100%)
 rename fs/nfs/{nfs4namespace.c => nfs4/namespace.c} (99%)
 create mode 100644 fs/nfs/nfs4/nfs4.h
 rename fs/nfs/{ => nfs4}/nfs4_fs.h (100%)
 rename fs/nfs/{nfs4proc.c => nfs4/proc.c} (99%)
 rename fs/nfs/{nfs4renewd.c => nfs4/renewd.c} (100%)
 rename fs/nfs/{nfs4state.c => nfs4/state.c} (99%)
 rename fs/nfs/{nfs4xdr.c => nfs4/xdr.c} (99%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index cfd238e..d782c47 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,10 +9,10 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   delegation.o idmap.o \
-			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o
+nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
+			   nfs4/delegation.o nfs4/idmap.o \
+			   nfs4/callback.o nfs4/callback_xdr.o \
+			   nfs4/callback_proc.o nfs4/namespace.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1e1bbf8..e24dd90 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -42,9 +42,9 @@
 
 #include <asm/system.h>
 
-#include "nfs4_fs.h"
-#include "callback.h"
-#include "delegation.h"
+#include "nfs4/nfs4_fs.h"
+#include "nfs4/callback.h"
+#include "nfs4/delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0348727..b72aab3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -37,7 +37,7 @@
 #include <linux/kmemleak.h>
 #include <linux/xattr.h>
 
-#include "delegation.h"
+#include "nfs4/delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d9f11c5..a691996 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -33,7 +33,7 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
-#include "delegation.h"
+#include "nfs4/delegation.h"
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index dcb6154..64e086e 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -35,8 +35,8 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "delegation.h"
+#include "nfs4/nfs4_fs.h"
+#include "nfs4/delegation.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cf2bab9..3588727 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -42,9 +42,9 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "callback.h"
-#include "delegation.h"
+#include "nfs4/nfs4_fs.h"
+#include "nfs4/callback.h"
+#include "nfs4/delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1dd22dc..347f49f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -5,7 +5,7 @@
 #ifndef __LINUX_NFS_INTERNAL_H
 #define __LINUX_NFS_INTERNAL_H
 
-#include "nfs4_fs.h"
+#include "nfs4/nfs4_fs.h"
 #include <linux/mount.h>
 #include <linux/security.h>
 
diff --git a/fs/nfs/callback.c b/fs/nfs/nfs4/callback.c
similarity index 99%
rename from fs/nfs/callback.c
rename to fs/nfs/nfs4/callback.c
index 516f337..e428afc 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/nfs4/callback.c
@@ -22,7 +22,7 @@
 
 #include "nfs4_fs.h"
 #include "callback.h"
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
diff --git a/fs/nfs/callback.h b/fs/nfs/nfs4/callback.h
similarity index 100%
rename from fs/nfs/callback.h
rename to fs/nfs/nfs4/callback.h
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/nfs4/callback_proc.c
similarity index 99%
rename from fs/nfs/callback_proc.c
rename to fs/nfs/nfs4/callback_proc.c
index 54cea8a..d11deba 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/nfs4/callback_proc.c
@@ -11,8 +11,8 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-#include "internal.h"
-#include "pnfs.h"
+#include "../internal.h"
+#include "../pnfs.h"
 
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/nfs4/callback_xdr.c
similarity index 99%
rename from fs/nfs/callback_xdr.c
rename to fs/nfs/nfs4/callback_xdr.c
index 726e59a..24a3114 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/nfs4/callback_xdr.c
@@ -13,7 +13,7 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include "nfs4_fs.h"
 #include "callback.h"
-#include "internal.h"
+#include "../internal.h"
 
 #define CB_OP_TAGLEN_MAXSZ	(512)
 #define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
diff --git a/fs/nfs/delegation.c b/fs/nfs/nfs4/delegation.c
similarity index 99%
rename from fs/nfs/delegation.c
rename to fs/nfs/nfs4/delegation.c
index 7f26540..2f3dc3e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/nfs4/delegation.c
@@ -19,7 +19,7 @@
 
 #include "nfs4_fs.h"
 #include "delegation.h"
-#include "internal.h"
+#include "../internal.h"
 
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
diff --git a/fs/nfs/delegation.h b/fs/nfs/nfs4/delegation.h
similarity index 100%
rename from fs/nfs/delegation.h
rename to fs/nfs/nfs4/delegation.h
diff --git a/fs/nfs/idmap.c b/fs/nfs/nfs4/idmap.c
similarity index 100%
rename from fs/nfs/idmap.c
rename to fs/nfs/nfs4/idmap.c
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4/namespace.c
similarity index 99%
rename from fs/nfs/nfs4namespace.c
rename to fs/nfs/nfs4/namespace.c
index bb80c49..6a21d95 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4/namespace.c
@@ -16,9 +16,9 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
-#include "internal.h"
+#include "../internal.h"
 #include "nfs4_fs.h"
-#include "dns_resolve.h"
+#include "../dns_resolve.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
new file mode 100644
index 0000000..8ed9951
--- /dev/null
+++ b/fs/nfs/nfs4/nfs4.h
@@ -0,0 +1,6 @@
+#ifndef __LINUX_FS_NFS_NFS4_H
+#define __LINUX_FS_NFS_NFS4_H
+
+void nfs4_init_aclclient(struct nfs_server *);
+
+#endif /* __LINUX_FS_NFS_NFS4_H */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4/nfs4_fs.h
similarity index 100%
rename from fs/nfs/nfs4_fs.h
rename to fs/nfs/nfs4/nfs4_fs.h
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4/proc.c
similarity index 99%
rename from fs/nfs/nfs4proc.c
rename to fs/nfs/nfs4/proc.c
index df3d306..c86c351 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4/proc.c
@@ -59,10 +59,10 @@
 
 #include "nfs4_fs.h"
 #include "delegation.h"
-#include "internal.h"
-#include "iostat.h"
+#include "../internal.h"
+#include "../iostat.h"
 #include "callback.h"
-#include "pnfs.h"
+#include "../pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4/renewd.c
similarity index 100%
rename from fs/nfs/nfs4renewd.c
rename to fs/nfs/nfs4/renewd.c
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4/state.c
similarity index 99%
rename from fs/nfs/nfs4state.c
rename to fs/nfs/nfs4/state.c
index a53f33b..e16e178 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4/state.c
@@ -54,8 +54,8 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-#include "internal.h"
-#include "pnfs.h"
+#include "../internal.h"
+#include "../pnfs.h"
 
 #define OPENOWNER_POOL_SIZE	8
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4/xdr.c
similarity index 99%
rename from fs/nfs/nfs4xdr.c
rename to fs/nfs/nfs4/xdr.c
index 95e92e4..97c36ca 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4/xdr.c
@@ -52,8 +52,8 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
 #include "nfs4_fs.h"
-#include "internal.h"
-#include "pnfs.h"
+#include "../internal.h"
+#include "../pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cfa175c..1f0cc70 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -23,7 +23,7 @@
 #include <asm/system.h>
 #include "pnfs.h"
 
-#include "nfs4_fs.h"
+#include "nfs4/nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2889a70..d7cdc50 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -57,9 +57,9 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "callback.h"
-#include "delegation.h"
+#include "nfs4/nfs4_fs.h"
+#include "nfs4/callback.h"
+#include "nfs4/delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 978aaeb..d839b40d 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -13,7 +13,7 @@
 #include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
-#include "callback.h"
+#include "nfs4/callback.h"
 
 #ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 4f9319a..1dbe14a 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -16,9 +16,9 @@
 #include <linux/namei.h>
 
 #include "internal.h"
-#include "nfs4_fs.h"
+#include "nfs4/nfs4_fs.h"
 #include "iostat.h"
-#include "delegation.h"
+#include "nfs4/delegation.h"
 
 struct nfs_unlinkdata {
 	struct hlist_node list;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1e92376..d5f61af 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -24,10 +24,10 @@
 
 #include <asm/uaccess.h>
 
-#include "delegation.h"
+#include "nfs4/delegation.h"
 #include "internal.h"
 #include "iostat.h"
-#include "nfs4_fs.h"
+#include "nfs4/nfs4_fs.h"
 #include "fscache.h"
 #include "pnfs.h"
 
-- 
1.7.8.3

