Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2987 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab0G0BKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jul 2010 21:10:36 -0400
From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] SQUASHME: pnfs-submit: Use generic layout name to load layout modules
Date: Mon, 26 Jul 2010 18:10:18 -0700
Message-Id: <1280193018-1628-1-git-send-email-Ricardo.Labiaga@netapp.com>
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Future NFSv4.x work will add several new layout types.  Use
nfs-layouttype4-<number> in request_module() to allow current and future
layout types to be loaded without requiring changes to the module loading
code.

The kernel issues request_module(nfs4-layouttype4-<number>) which is
then mapped to the actual module name in the modprobe aliases file.
Something like:
   alias nfs-layouttype4-1 nfs_layout_nfsv41_files
   alias nfs-layouttype4-2 nfs_layout_osd2_objects

It can be turned off by commenting out the alias, or specifying it off.
For example:
   alias nfs-layouttype4-3 off

The module can still be loaded by hand using modprobe.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/Makefile |    4 ++--
 fs/nfs/pnfs.c   |   10 +---------
 fs/nfs/pnfs.h   |    2 +-
 3 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 6c218e7..4776ff9 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -19,5 +19,5 @@ nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
-obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfslayoutdriver.o
-nfslayoutdriver-y := nfs4filelayout.o nfs4filelayoutdev.o
+obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
+nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3494d5e..b2fb693 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -210,14 +210,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		return;
 
 	if (!find_pnfs(id, &mod)) {
-		switch (id) {
-		case LAYOUT_NFSV4_1_FILES:
-			request_module(LAYOUT_NFSV4_1_FILES_MODULE);
-			break;
-		default:
-			goto out_not_found;
-		};
-
+		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
 		find_pnfs(id, &mod);
 	}
 
@@ -233,7 +226,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		return;
 	}
 
-out_not_found:
 	dprintk("%s: No pNFS module found for %u. ", __func__, id);
 out_err:
 	dprintk("Using NFSv4 I/O\n");
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6bc27af..f48ef24 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -73,7 +73,7 @@ void put_layout(struct inode *inode);
 				     (srv)->pnfs_curr_ld->ld_policy_ops && \
 				     (srv)->pnfs_curr_ld->ld_policy_ops->opname)
 
-#define LAYOUT_NFSV4_1_FILES_MODULE "nfslayoutdriver"
+#define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
 static inline int lo_fail_bit(u32 iomode)
 {
-- 
1.5.4.3

