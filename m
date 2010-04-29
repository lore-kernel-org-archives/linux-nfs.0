From: andros@netapp.com
Subject: [PATCH 10/13] SQUASHME pnfs_submit: remove pnfs_fs_ltype
Date: Thu, 29 Apr 2010 16:34:48 -0400
Message-ID: <1272573291-8986-11-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
 <1272573291-8986-7-git-send-email-andros@netapp.com>
 <1272573291-8986-8-git-send-email-andros@netapp.com>
 <1272573291-8986-9-git-send-email-andros@netapp.com>
 <1272573291-8986-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab0D3Qs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:57 -0400
In-Reply-To: <1272573291-8986-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the pnfs_curr_ld pointer in nfs_probe_fsinfo. Use the pnfs_curr_ld
layout type.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |   20 ++++++++++++++++----
 fs/nfs/pnfs.c             |    3 +--
 fs/nfs/pnfs.h             |    2 +-
 fs/nfs/super.c            |   26 ++------------------------
 include/linux/nfs_fs_sb.h |    1 -
 5 files changed, 20 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f1624df..8f3bf8a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -49,6 +49,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
@@ -870,6 +871,20 @@ error:
 }
 
 /*
+ * Initialize the pNFS layout driver and setup pNFS related parameters
+ */
+static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs_client *clp = server->nfs_client;
+
+	if (nfs4_has_session(clp) &&
+	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+		set_pnfs_layoutdriver(server, fsinfo->layouttype);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
  * Load up the server record from information gained in an fsinfo record
  */
 static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
@@ -902,10 +917,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-#ifdef CONFIG_NFS_V4_1
-	/* Save the layout type for use during init of layout driver */
-	server->pnfs_fs_ltype = fsinfo->layouttype;
-#endif /* CONFIG_NFS_V4_1 */
+	nfs4_init_pnfs(server, fsinfo);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0306d05..1560b4d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -203,10 +203,9 @@ unmount_pnfs_layoutdriver(struct nfs_server *nfss)
  * Only one pNFS layout driver is supported.
  */
 void
-set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
+set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 {
 	struct pnfs_module *mod;
-	struct nfs_server *server = NFS_SB(sb);
 
 	if (server->pnfs_curr_ld)
 		return;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3761f48..29e63d9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -38,7 +38,7 @@ int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type);
-void set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id);
+void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_use_read(struct inode *inode, ssize_t count);
 int pnfs_use_ds_io(struct list_head *, struct inode *, int);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 021683d..fce7d47 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -679,13 +679,13 @@ char *layout_name(u32 layouttype)
 
 void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
-	char *name = layout_name(server->pnfs_fs_ltype);
+	char *name = layout_name(server->pnfs_curr_ld->id);
 
 	seq_printf(m, ",pnfs=");
 	if (name)
 		seq_printf(m, "%s", name);
 	else
-		seq_printf(m, "unknown(%d)", server->pnfs_fs_ltype);
+		seq_printf(m, "unknown(%d)", server->pnfs_curr_ld->id);
 }
 #else  /* CONFIG_NFS_V4_1 */
 void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
@@ -2580,22 +2580,6 @@ out_no_address:
 }
 
 /*
- * Initialize the pNFS layout driver and setup pNFS related parameters
- */
-static void nfs4_init_pnfs(struct super_block *sb, struct nfs_fh *fh)
-{
-#if defined(CONFIG_NFS_V4_1)
-	struct nfs_server *server = NFS_SB(sb);
-	struct nfs_client *clp = server->nfs_client;
-
-	if (nfs4_has_session(clp) &&
-	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
-		set_pnfs_layoutdriver(sb, fh, server->pnfs_fs_ltype);
-	}
-#endif /* CONFIG_NFS_V4_1 */
-}
-
-/*
  * Get the superblock for the NFS4 root partition
  */
 static int nfs4_remote_get_sb(struct file_system_type *fs_type,
@@ -2662,8 +2646,6 @@ static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 	if (error)
 		goto error_splat_root;
 
-	nfs4_init_pnfs(s, mntfh);
-
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
@@ -2909,8 +2891,6 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	nfs4_init_pnfs(s, data->fh);
-
 	dprintk("<-- nfs4_xdev_get_sb() = 0\n");
 	return 0;
 
@@ -2996,8 +2976,6 @@ static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	nfs4_init_pnfs(s, &mntfh);
-
 	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return 0;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index cd58033..276735f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -163,7 +163,6 @@ struct nfs_server {
 #endif
 
 #ifdef CONFIG_NFS_V4_1
-	u32				pnfs_fs_ltype;/* fs_layouttype attr */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.6

