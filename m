Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:35302 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbbGMSIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:08:52 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 10/10] NFS: Remove nfs_release()
Date: Mon, 13 Jul 2015 14:01:33 -0400
Message-ID: <1436810493-22806-11-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And call nfs_file_clear_open_context() directly.  This makes it obvious
that nfs_file_release() will always return 0.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/file.c          | 3 ++-
 fs/nfs/inode.c         | 8 +-------
 include/linux/nfs_fs.h | 2 +-
 3 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cc4fa1e..7538a85 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -82,7 +82,8 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	dprintk("NFS: release(%pD2)\n", filp);
 
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
-	return nfs_release(inode, filp);
+	nfs_file_clear_open_context(filp);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_file_release);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b77b328..a0d195f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -887,7 +887,7 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
 	return ctx;
 }
 
-static void nfs_file_clear_open_context(struct file *filp)
+void nfs_file_clear_open_context(struct file *filp)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 
@@ -918,12 +918,6 @@ int nfs_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
-int nfs_release(struct inode *inode, struct file *filp)
-{
-	nfs_file_clear_open_context(filp);
-	return 0;
-}
-
 /*
  * This function is called whenever some part of NFS notices that
  * the cached attributes have to be refreshed.
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f91b5ad..9851f37 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -350,7 +350,6 @@ extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
 extern void nfs_access_set_mask(struct nfs_access_entry *, u32);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
-extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
@@ -368,6 +367,7 @@ extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struc
 extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
+extern void nfs_file_clear_open_context(struct file *flip);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
-- 
2.4.5

