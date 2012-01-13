Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688Ab2AMULR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:17 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 09/44] NFS: Move v3 to its own subdirectory
Date: Fri, 13 Jan 2012 15:10:18 -0500
Message-Id: <1326485453-1350-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This keeps all the v3 code together and separate from the rest of the
NFS code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile                    |    4 ++--
 fs/nfs/{nfs3acl.c => nfs3/acl.c}   |    2 +-
 fs/nfs/{nfs3proc.c => nfs3/proc.c} |    4 ++--
 fs/nfs/{nfs3xdr.c => nfs3/xdr.c}   |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)
 rename fs/nfs/{nfs3acl.c => nfs3/acl.c} (99%)
 rename fs/nfs/{nfs3proc.c => nfs3/proc.c} (99%)
 rename fs/nfs/{nfs3xdr.c => nfs3/xdr.c} (99%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 5733451..7d674a0 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,8 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3/proc.o nfs3/xdr.o
+nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3/acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3/acl.c
similarity index 99%
rename from fs/nfs/nfs3acl.c
rename to fs/nfs/nfs3/acl.c
index 7ef2397..ac589ff 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3/acl.c
@@ -6,7 +6,7 @@
 #include <linux/posix_acl_xattr.h>
 #include <linux/nfsacl.h>
 
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3/proc.c
similarity index 99%
rename from fs/nfs/nfs3proc.c
rename to fs/nfs/nfs3/proc.c
index d4bc9ed9..f37ddb9 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3/proc.c
@@ -18,8 +18,8 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
 
-#include "iostat.h"
-#include "internal.h"
+#include "../iostat.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3/xdr.c
similarity index 99%
rename from fs/nfs/nfs3xdr.c
rename to fs/nfs/nfs3/xdr.c
index 183c6b1..be27fb8 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3/xdr.c
@@ -20,7 +20,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
-- 
1.7.8.3

