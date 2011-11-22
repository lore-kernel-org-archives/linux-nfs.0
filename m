Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39409 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab1KVW6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 17:58:22 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 2.5/4] NFS: Move the NFS v3 code into its own subdirectory
Date: Tue, 22 Nov 2011 17:58:02 -0500
Message-Id: <1322002684-20436-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
References: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This finishes off the changes started in the last patch.  Note that
after applying this patch NFS v3 is still directly compiled into the
main NFS kernel module.  The changes to turn it into a module will come
in a later patch.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile        |    4 ++--
 fs/nfs/nfs3/nfs3acl.c  |    2 +-
 fs/nfs/nfs3/nfs3proc.c |    4 ++--
 fs/nfs/nfs3/nfs3xdr.c  |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index b58613d..ac0e5df 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,8 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3/nfs3proc.o nfs3/nfs3xdr.o
+nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3/nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
diff --git a/fs/nfs/nfs3/nfs3acl.c b/fs/nfs/nfs3/nfs3acl.c
index 7ef2397..ac589ff 100644
--- a/fs/nfs/nfs3/nfs3acl.c
+++ b/fs/nfs/nfs3/nfs3acl.c
@@ -6,7 +6,7 @@
 #include <linux/posix_acl_xattr.h>
 #include <linux/nfsacl.h>
 
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3/nfs3proc.c b/fs/nfs/nfs3/nfs3proc.c
index d4bc9ed9..f37ddb9 100644
--- a/fs/nfs/nfs3/nfs3proc.c
+++ b/fs/nfs/nfs3/nfs3proc.c
@@ -18,8 +18,8 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
 
-#include "iostat.h"
-#include "internal.h"
+#include "../iostat.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3/nfs3xdr.c b/fs/nfs/nfs3/nfs3xdr.c
index 183c6b1..be27fb8 100644
--- a/fs/nfs/nfs3/nfs3xdr.c
+++ b/fs/nfs/nfs3/nfs3xdr.c
@@ -20,7 +20,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
-- 
1.7.7.4

