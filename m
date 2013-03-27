Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:12457 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab3C0IdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 04:33:13 -0400
Message-ID: <5152AEE8.8020607@cn.fujitsu.com>
Date: Wed, 27 Mar 2013 16:33:44 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] pnfsd-block: block layout should cleanup when register
 nfsd filesystem error
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

this patch can do:

1. remove /proc/fs/pnfs_block when create /proc/fs/pnfs_block/ctl
   error.

2. cleanup /proc/fs/pnfs_block and /proc/fs/pnfs_block/ctl when
   register nfsd filesystem error.
 
 Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
 Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>

---
 fs/nfsd/bl_com.c      |    4 +++-
 fs/nfsd/bl_ops.c      |   12 ++++++++++--
 fs/nfsd/nfsctl.c      |    7 +++++--
 fs/nfsd/nfsd4_block.h |    6 ++++--
 4 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/bl_com.c b/fs/nfsd/bl_com.c
index 39aac40..e003900 100644
--- a/fs/nfsd/bl_com.c
+++ b/fs/nfsd/bl_com.c
@@ -281,8 +281,10 @@ bl_init_proc(void)
 		return -ENOMEM;
 
 	e = create_proc_entry("fs/pnfs_block/ctl", 0, NULL);
-	if (!e)
+	if (!e) {
+		remove_proc_entry("fs/pnfs_block", NULL);
 		return -ENOMEM;
+	}
 	e->proc_fops = &ctl_ops;
 
 	return 0;
diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index a7046c6..3807fba 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -120,17 +120,25 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
     u64 sbid, dev_t dev, pnfs_blocklayout_layout_t *b);
 static void extents_cleanup(struct fiemap_extent_info *fei);
 
-void
+int
 nfsd_bl_init(void)
 {
 	int	i;
+
 	dprintk("%s loaded\n", __func__);
 
 	spin_lock_init(&layout_hashtbl_lock);
 	INIT_LIST_HEAD(&layout_hash);
 	for (i = 0; i < BL_LAYOUT_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&layout_hashtbl[i]);
-	bl_init_proc();
+	return bl_init_proc();
+}
+
+void
+nfsd_bl_cleanup(void)
+{
+	remove_proc_entry("fs/pnfs_block/ctl", NULL);
+	remove_proc_entry("fs/pnfs_block", NULL);
 }
 
 /*
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 61a61e7..0af6019 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1204,8 +1204,9 @@ static int create_proc_exports_entry(void)
 static int __init init_nfsd(void)
 {
 	int retval;
-	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
+	int bl_retval;
 
+	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 	retval = nfsd4_init_slabs();
 	if (retval)
 		return retval;
@@ -1227,7 +1228,7 @@ static int __init init_nfsd(void)
 	retval = create_proc_exports_entry();
 	if (retval)
 		goto out_free_idmap;
-	nfsd_bl_init();
+	bl_retval = nfsd_bl_init();
 
 	retval = register_filesystem(&nfsd_fs_type);
 	if (retval)
@@ -1236,6 +1237,8 @@ static int __init init_nfsd(void)
 out_free_all:
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
+	if (!bl_retval)
+		nfsd_bl_cleanup();
 out_free_idmap:
 	nfsd_idmap_shutdown();
 out_free_lockd:
diff --git a/fs/nfsd/nfsd4_block.h b/fs/nfsd/nfsd4_block.h
index f79c779..d46bd0b 100644
--- a/fs/nfsd/nfsd4_block.h
+++ b/fs/nfsd/nfsd4_block.h
@@ -78,7 +78,8 @@ typedef struct bl_comm {
 #ifdef CONFIG_PNFSD_BLOCK
 
 bool pnfs_block_enabled(struct inode *, int ex_flags);
-void nfsd_bl_init(void);
+int nfsd_bl_init(void);
+void nfsd_bl_cleanup(void);
 int bl_layout_type(struct super_block *sb);
 int bl_getdeviceiter(struct super_block *, u32 layout_type,
 		     struct nfsd4_pnfs_dev_iter_res *);
@@ -112,7 +113,8 @@ extern bl_comm_t	*bl_comm_global;	// Ugly...
 #else
 
 static inline bool pnfs_block_enabled(struct inode *i, int ex_flags) { return false; }
-static inline void nfsd_bl_init(void) {}
+static inline int nfsd_bl_init(void) {return false; }
+static inline void nfsd_bl_cleanup(void) {}
 
 static inline int bl_recall_layout(struct inode *inode, int type, u64 offset,
 				   u64 len, bool with_nfs4_state_lock)
-- 
1.5.5.1


