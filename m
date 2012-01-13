Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688Ab2AMULN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:13 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 05/44] NFS: Move v2 to new subdirectory
Date: Fri, 13 Jan 2012 15:10:14 -0500
Message-Id: <1326485453-1350-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Still compiled as part of the nfs module, this prepares for making it
its own module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile                  |    2 +-
 fs/nfs/{ => nfs2}/proc.c         |    2 +-
 fs/nfs/{nfs2xdr.c => nfs2/xdr.c} |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)
 rename fs/nfs/{ => nfs2}/proc.c (99%)
 rename fs/nfs/{nfs2xdr.c => nfs2/xdr.c} (99%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7ddd45d..44db87d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
+nfs-$(CONFIG_NFS_V2)	+= nfs2/proc.o nfs2/xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
diff --git a/fs/nfs/proc.c b/fs/nfs/nfs2/proc.c
similarity index 99%
rename from fs/nfs/proc.c
rename to fs/nfs/nfs2/proc.c
index f48125d..65eafa3 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/nfs2/proc.c
@@ -41,7 +41,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2/xdr.c
similarity index 99%
rename from fs/nfs/nfs2xdr.c
rename to fs/nfs/nfs2/xdr.c
index 61df96d..4b052a2 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2/xdr.c
@@ -21,7 +21,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs_fs.h>
-#include "internal.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
-- 
1.7.8.3

