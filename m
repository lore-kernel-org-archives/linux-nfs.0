Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:33076 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549AbaCQLHJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 07:07:09 -0400
Received: by mail-qa0-f45.google.com with SMTP id hw13so5020836qab.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 04:07:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] nfs: make nfs_async_rename non-static
Date: Mon, 17 Mar 2014 07:06:55 -0400
Message-Id: <1395054418-14504-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
References: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and move the prototype for nfs_sillyrename to internal.h.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/internal.h      | 7 +++++++
 fs/nfs/unlink.c        | 2 +-
 include/linux/nfs_fs.h | 1 -
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b46cf5a67329..ae765a56b84f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -474,6 +474,13 @@ extern int nfs_migrate_page(struct address_space *,
 #define nfs_migrate_page NULL
 #endif
 
+/* unlink.c */
+extern struct rpc_task *
+nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
+		 struct dentry *old_dentry, struct dentry *new_dentry,
+		 void (*complete)(struct rpc_task *, struct nfs_renamedata *));
+extern int nfs_sillyrename(struct inode *dir, struct dentry *dentry);
+
 /* direct.c */
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3e6798c9ba1f..818ded7b7b74 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -399,7 +399,7 @@ static const struct rpc_call_ops nfs_rename_ops = {
  *
  * It's expected that valid references to the dentries and inodes are held
  */
-static struct rpc_task *
+struct rpc_task *
 nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 		 struct dentry *old_dentry, struct dentry *new_dentry,
 		 void (*complete)(struct rpc_task *, struct nfs_renamedata *))
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0ae5807480f4..85d31ccc00f8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -510,7 +510,6 @@ extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
 extern void nfs_wait_on_sillyrename(struct dentry *dentry);
 extern void nfs_block_sillyrename(struct dentry *dentry);
 extern void nfs_unblock_sillyrename(struct dentry *dentry);
-extern int  nfs_sillyrename(struct inode *dir, struct dentry *dentry);
 
 /*
  * linux/fs/nfs/write.c
-- 
1.8.5.3

