Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45461 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNuB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:50:01 -0500
Received: by eaak14 with SMTP id k14so3593300eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:49:59 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/13] pnfsd-block: undo dependence on spnfs
Date: Sun,  4 Dec 2011 15:49:53 +0200
Message-Id: <1323006593-13837-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/Kconfig                  |    6 +++---
 fs/nfsd/Makefile                 |    2 +-
 fs/nfsd/bl_com.c                 |    3 ---
 fs/nfsd/bl_ops.c                 |   13 +++++--------
 fs/nfsd/export.c                 |   27 +++++++++++++++------------
 fs/nfsd/nfs4proc.c               |   20 +++++++-------------
 fs/nfsd/nfsctl.c                 |    8 ++------
 fs/nfsd/vfs.c                    |    9 ++-------
 include/linux/nfsd/nfsd4_block.h |    8 +++++++-
 9 files changed, 42 insertions(+), 54 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index e707145..071bdbf 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -141,11 +141,11 @@ config SPNFS_LAYOUTSEGMENTS
 
 	  If unsure, say N.
 
-config SPNFS_BLOCK
+config PNFSD_BLOCK
 	bool "Provide Block Layout server support (EXPERIMENTAL)"
-	depends on SPNFS
+	depends on PNFSD
 	select EXPORTFS_BLOCK_LAYOUT
 	help
-	  Say Y here if you want spNFS block layout support
+	  Say Y here if you want pNFS block layout support
 
 	  If unsure, say N.
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index fed6c25..d2e7f43 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -14,4 +14,4 @@ nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o nfs4pnfsdlm.o nfs4pnfsds.o
 nfsd-$(CONFIG_PNFSD_LOCAL_EXPORT) += pnfsd_lexp.o
 nfsd-$(CONFIG_SPNFS)	+= spnfs_com.o spnfs_ops.o
-nfsd-$(CONFIG_SPNFS_BLOCK) += bl_com.o bl_ops.o
+nfsd-$(CONFIG_PNFSD_BLOCK) += bl_com.o bl_ops.o
diff --git a/fs/nfsd/bl_com.c b/fs/nfsd/bl_com.c
index 388d71a..2199725 100644
--- a/fs/nfsd/bl_com.c
+++ b/fs/nfsd/bl_com.c
@@ -1,5 +1,3 @@
-#if defined(CONFIG_SPNFS_BLOCK)
-
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/init.h>
@@ -289,4 +287,3 @@ static ssize_t ctl_write(struct file *file, const char __user *buf, size_t len,
 
 	return 0;
 }
-#endif /* CONFIG_SPNFS_BLOCK */
diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 31e23c2..f5980a3 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -13,7 +13,6 @@
  * These functions, with the exception of pnfs_block_enabled, are assigned to
  * the super block s_export_op structure.
  */
-#if defined(CONFIG_SPNFS_BLOCK)
 
 #include <linux/module.h>
 #include <linux/genhd.h>
@@ -139,7 +138,7 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
  * pnfs_block_enabled -- check to see if this file system should be export as
  * block pnfs
  */
-int
+bool
 pnfs_block_enabled(struct inode *inode, int ex_flags)
 {
 	bl_comm_msg_t	msg;
@@ -159,7 +158,7 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
 #ifdef notyet
 	if (!(ex_flags & NFSEXP_PNFS_BLOCK)) {
 		dprintk("%s: pnfs_block not set in export\n", __func__);
-		return 0;
+		return false;
 	}
 #endif
 	
@@ -170,13 +169,13 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
 		if (bl_upcall(bl_comm_global, &msg, &res)) {
 			dprintk("%s: Failed to contact pNFS block daemon\n",
 				__func__);
-			return 0;
+			return false;
 		}
 		if (msg.u.msg_vers != res->u.vers) {
 			dprintk("%s: vers mismatch, kernel != daemon\n",
 				__func__);
 			kfree(res);
-			return 0;
+			return false;
 		}
 	}
 	bl_comm_once = 1;
@@ -184,7 +183,7 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
 	kfree(res);
 	
 	dprintk("<-- %s okay\n", __func__);
-	return 1;
+	return true;
 }
 
 int
@@ -1677,5 +1676,3 @@ struct list_head *
 	}
 	return True;
 }
-
-#endif /* CONFIG_SPNFS_BLOCK */
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a12d7a9..10b61b6 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -16,11 +16,9 @@
 #include <linux/module.h>
 #include <linux/exportfs.h>
 #include <linux/nfsd/nfsd4_pnfs.h>
+#include <linux/nfsd/nfsd4_block.h>
 #if defined(CONFIG_SPNFS)
 #include <linux/nfsd4_spnfs.h>
-#if defined(CONFIG_SPNFS_BLOCK)
-#include <linux/nfsd/nfsd4_block.h>
-#endif
 #endif
 #include <net/ipv6.h>
 
@@ -374,7 +372,8 @@ static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
 	.get_state = spnfs_get_state,
 };
 
-#if defined(CONFIG_SPNFS_BLOCK)
+#endif /* CONFIG_SPNFS */
+#if defined(CONFIG_PNFSD_BLOCK)
 static struct pnfs_export_operations bl_export_ops = {
 	.layout_type = bl_layout_type,
 	.get_device_info = bl_getdeviceinfo,
@@ -382,8 +381,7 @@ static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
 	.layout_get = bl_layoutget,
 	.layout_return = bl_layoutreturn,
 };
-#endif /* CONFIG_SPNFS_BLOCK */
-#endif /* CONFIG_SPNFS */
+#endif /* CONFIG_PNFSD_BLOCK */
 #endif /* CONFIG_PNFSD */
 
 static struct svc_export *svc_export_update(struct svc_export *new,
@@ -400,13 +398,18 @@ static int pnfsd_check_export(struct inode *inode, int *flags)
 	return 0;
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 
+	if (pnfs_block_enabled(inode, *flags)) {
+		if (!inode->i_sb->s_pnfs_op) {
+			dprintk("set pnfs block export structure\n");
+			inode->i_sb->s_pnfs_op = &bl_export_ops;
+		} else
+			dprintk("pnfs block enabled, fs provided s_pnfs_op\n");
+		dprintk("pnfs block enabled, sb=%p s_pnfs_op=%p\n",
+			inode->i_sb, inode->i_sb->s_pnfs_op);
+		return 0;
+	}
+
 #if defined(CONFIG_SPNFS)
-#if defined(CONFIG_SPNFS_BLOCK)
-	if (!inode->i_sb->s_pnfs_op && pnfs_block_enabled(inode, *flags)) {
-		dprintk("set pnfs block export structure... \n");
-		inode->i_sb->s_pnfs_op = &bl_export_ops;
-	} else
-#endif /* CONFIG_SPNFS_BLOCK */
 	/*
 	 * spnfs_enabled() indicates we're an MDS.
 	 * XXX Better to check an export time option as well.
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 501781d..b887690 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -924,18 +924,6 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	nfsd4_get_verifier(cstate->current_fh.fh_dentry->d_inode->i_sb,
 			   &write->wr_verifier);
 #if defined(CONFIG_SPNFS)
-#if defined(CONFIG_SPNFS_BLOCK)
-	if (pnfs_block_enabled(cstate->current_fh.fh_dentry->d_inode, 0)) {
-                status = bl_layoutrecall(cstate->current_fh.fh_dentry->d_inode,
-		    RETURN_FILE, write->wr_offset, write->wr_buflen, false);
-                if (!status) {
-                        status =  nfsd_write(rqstp, &cstate->current_fh, filp,
-			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
-			     &cnt, &write->wr_how_written);
-                }
-        } else
-#endif
-		
 	if (spnfs_enabled()) {
 		status = spnfs_write(cstate->current_fh.fh_dentry->d_inode,
 			write->wr_offset, write->wr_buflen, write->wr_vlen,
@@ -958,11 +946,17 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
 			     &cnt, &write->wr_how_written);
 #else
+	if (pnfs_block_enabled(cstate->current_fh.fh_dentry->d_inode, 0)) {
+                status = bl_layoutrecall(cstate->current_fh.fh_dentry->d_inode,
+		    RETURN_FILE, write->wr_offset, write->wr_buflen, false);
+                if (status)
+			goto out_put;
+        }
 	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
 			     &cnt, &write->wr_how_written);
+out_put:
 #endif /* CONFIG_SPNFS */
-
 	if (filp)
 		fput(filp);
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 02a6ddd..29cfbea 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/gss_krb5_enctypes.h>
 #include <linux/module.h>
 #include <linux/nfsd/nfs4pnfsdlm.h>
+#include <linux/nfsd/nfsd4_block.h>
 
 #include "idmap.h"
 #include "nfsd.h"
@@ -1203,9 +1204,6 @@ static int create_proc_exports_entry(void)
 }
 #endif
 
-#if defined(CONFIG_SPNFS_BLOCK)
-int nfsd_bl_init(void);
-#endif
 static int __init init_nfsd(void)
 {
 	int retval;
@@ -1232,10 +1230,8 @@ static int __init init_nfsd(void)
 	retval = spnfs_init_proc();
 	if (retval != 0)
 		goto out_free_idmap;
-#if defined(CONFIG_SPNFS_BLOCK)
-	nfsd_bl_init();
-#endif /* CONFIG_SPNFS_BLOCK */
 #endif /* CONFIG_PROC_FS && CONFIG_SPNFS */
+	nfsd_bl_init();
 
 	retval = register_filesystem(&nfsd_fs_type);
 	if (retval)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ce07f67..da18d1d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -38,10 +38,8 @@
 #include "idmap.h"
 #include "pnfsd.h"
 #include <linux/nfsd4_spnfs.h>
-#endif /* CONFIG_NFSD_V4 */
-#if defined(CONFIG_SPNFS_BLOCK)
 #include <linux/nfsd/nfsd4_block.h>
-#endif
+#endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
 #include "vfs.h"
@@ -388,13 +386,10 @@ static int nfsd_break_lease(struct inode *inode)
 			if (is_inode_pnfsd_lexp(inode))
 				pnfsd_lexp_recall_layout(inode, with_nfs4_state_lock);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
-#if defined(CONFIG_SPNFS_BLOCK)
-			if (pnfs_block_enabled(inode, 0)) {
+			if (pnfs_block_enabled(inode, 0))
 				err = bl_layoutrecall(inode, RETURN_FILE,
 					iap->ia_size, inode->i_size - iap->ia_size,
 					with_nfs4_state_lock);
-			}
-#endif /* CONFIG_SPNFS_BLOCK */
 		}
 
 		host_err = get_write_access(inode);
diff --git a/include/linux/nfsd/nfsd4_block.h b/include/linux/nfsd/nfsd4_block.h
index b8a8e44..4daae91 100644
--- a/include/linux/nfsd/nfsd4_block.h
+++ b/include/linux/nfsd/nfsd4_block.h
@@ -75,7 +75,13 @@
 	bl_comm_msg_t		msg;
 } bl_comm_t;
 
-int pnfs_block_enabled(struct inode *, int);
+#ifdef CONFIG_PNFSD_BLOCK
+bool pnfs_block_enabled(struct inode *, int);
+void nfsd_bl_init(void);
+#else
+static inline bool pnfs_block_enabled(struct inode *, int) { return false; }
+static inline void nfsd_bl_init(void) {}
+#endif /* CONFIG_PNFSD_BLOCK */
 int bl_layout_type(struct super_block *sb);
 int bl_getdeviceiter(struct super_block *, u32 layout_type,
 		     struct nfsd4_pnfs_dev_iter_res *);
-- 
1.7.6

