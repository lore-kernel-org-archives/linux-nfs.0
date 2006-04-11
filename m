From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 3/6] VFS: Remove dependency of ->umount_begin() call on MNT_FORCE
Date: Tue, 11 Apr 2006 14:05:35 -0400
Message-ID: <20060411180535.12579.80763.stgit@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Allow filesystems to decide to perform pre-umount processing whether or not
MNT_FORCE is set.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/9p/vfs_super.c  |    7 ++++---
 fs/cifs/cifsfs.c   |    6 ++++--
 fs/fuse/inode.c    |    5 +++--
 fs/namespace.c     |    4 ++--
 fs/nfs/inode.c     |   14 +++++++++-----
 include/linux/fs.h |    2 +-
 6 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index 61c599b..00c1f6b 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -253,11 +253,12 @@ static int v9fs_show_options(struct seq_
 }
 
 static void
-v9fs_umount_begin(struct super_block *sb)
+v9fs_umount_begin(struct vfsmount *vfsmnt, int flags)
 {
-	struct v9fs_session_info *v9ses = sb->s_fs_info;
+	struct v9fs_session_info *v9ses = vfsmnt->mnt_sb->s_fs_info;
 
-	v9fs_session_cancel(v9ses);
+	if (flags & MNT_FORCE)
+		v9fs_session_cancel(v9ses);
 }
 
 static struct super_operations v9fs_super_ops = {
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index d4b713e..8c60c53 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -404,12 +404,14 @@ static struct quotactl_ops cifs_quotactl
 #endif
 
 #ifdef CONFIG_CIFS_EXPERIMENTAL
-static void cifs_umount_begin(struct super_block * sblock)
+static void cifs_umount_begin(struct vfsmount * vfsmnt, int flags)
 {
 	struct cifs_sb_info *cifs_sb;
 	struct cifsTconInfo * tcon;
 
-	cifs_sb = CIFS_SB(sblock);
+	if (!(flags & MNT_FORCE))
+		return;
+	cifs_sb = CIFS_SB(vfsmnt->mnt_sb);
 	if(cifs_sb == NULL)
 		return;
 
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index fd34037..7b3d4e7 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -195,9 +195,10 @@ struct inode *fuse_iget(struct super_blo
 	return inode;
 }
 
-static void fuse_umount_begin(struct super_block *sb)
+static void fuse_umount_begin(struct vfsmount *vfsmnt, int flags)
 {
-	fuse_abort_conn(get_fuse_conn_super(sb));
+	if (flags & MNT_FORCE)
+		fuse_abort_conn(get_fuse_conn_super(vfsmnt->mnt_sb));
 }
 
 static void fuse_put_super(struct super_block *sb)
diff --git a/fs/namespace.c b/fs/namespace.c
index 7bff436..b21c5c2 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -576,8 +576,8 @@ static int do_umount(struct vfsmount *mn
 	 */
 
 	lock_kernel();
-	if ((flags & MNT_FORCE) && sb->s_op->umount_begin)
-		sb->s_op->umount_begin(sb);
+	if (sb->s_op->umount_begin)
+		sb->s_op->umount_begin(mnt, flags);
 	unlock_kernel();
 
 	/*
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1fd3452..cfcc585 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -64,7 +64,7 @@ static void nfs_destroy_inode(struct ino
 static int nfs_write_inode(struct inode *,int);
 static void nfs_delete_inode(struct inode *);
 static void nfs_clear_inode(struct inode *);
-static void nfs_umount_begin(struct super_block *);
+static void nfs_umount_begin(struct vfsmount *, int);
 static int  nfs_statfs(struct super_block *, struct kstatfs *);
 static int  nfs_show_options(struct seq_file *, struct vfsmount *);
 static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
@@ -179,15 +179,19 @@ nfs_clear_inode(struct inode *inode)
 	BUG_ON(atomic_read(&nfsi->data_updates) != 0);
 }
 
-void
-nfs_umount_begin(struct super_block *sb)
+static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 {
-	struct rpc_clnt	*rpc = NFS_SB(sb)->client;
+	struct nfs_server *server;
+	struct rpc_clnt	*rpc;
 
+	if (!(flags & MNT_FORCE))
+		return;
 	/* -EIO all pending I/O */
+	server = NFS_SB(vfsmnt->mnt_sb);
+	rpc = server->client;
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
-	rpc = NFS_SB(sb)->client_acl;
+	rpc = server->client_acl;
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 162c6e5..f83400a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1100,7 +1100,7 @@ struct super_operations {
 	int (*statfs) (struct super_block *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
 	void (*clear_inode) (struct inode *);
-	void (*umount_begin) (struct super_block *);
+	void (*umount_begin) (struct vfsmount *, int);
 
 	int (*show_options)(struct seq_file *, struct vfsmount *);
 	int (*show_stats)(struct seq_file *, struct vfsmount *);
