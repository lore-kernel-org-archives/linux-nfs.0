From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs4: handle situation where dentry wasn't revalidated on open
Date: Fri, 13 Nov 2009 08:23:56 -0500
Message-ID: <1258118636-1348-1-git-send-email-jlayton@redhat.com>
Cc: ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org,
	trond.myklebust@fys.uio.no
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbZKMNYF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Nov 2009 08:24:05 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is an alternate approach to fixing this problem that doesn't
rely on VFS changes...

Currently, the NFSv4 client code relies on the ->lookup and
->d_revalidate codepaths to handle the open processing during lookup. In
certain situations (notably LAST_BIND symlinks and file bind mounts)
it's possible for the VFS to skip calling d_revalidate on a dentry that
it finds in the cache. If this is done on an open call, the file doesn't
get opened on the wire, no state is established and stateful operations
fail against it.

This patchset fixes this problem by taking advantage of the fact that we
can pass an open routine to lookup_instantiate_filp. A new open file
operation for NFSv4 is added that should only be called if the filp
wasn't instantiated during lookup. The original open routine is passed
to lookup_instantiate_filp to ensure no change in behavior there.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c           |   42 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/inode.c          |   36 +++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_fs.h  |    3 +++
 include/linux/nfs_xdr.h |    1 +
 8 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f5fdd39..4ffb0c0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -38,7 +38,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
-static int nfs_file_open(struct inode *, struct file *);
+static int nfs4_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
 static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
@@ -80,6 +80,27 @@ const struct file_operations nfs_file_operations = {
 	.setlease	= nfs_setlease,
 };
 
+#ifdef CONFIG_NFS_V4
+const struct file_operations nfs4_file_operations = {
+	.llseek		= nfs_file_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= nfs_file_read,
+	.aio_write	= nfs_file_write,
+	.mmap		= nfs_file_mmap,
+	.open		= nfs4_file_open,
+	.flush		= nfs_file_flush,
+	.release	= nfs_file_release,
+	.fsync		= nfs_file_fsync,
+	.lock		= nfs_lock,
+	.flock		= nfs_flock,
+	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
+	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
+};
+#endif  /* CONFIG_NFS_V4 */
+
 const struct inode_operations nfs_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
@@ -114,7 +135,7 @@ static int nfs_check_flags(int flags)
 /*
  * Open file
  */
-static int
+int
 nfs_file_open(struct inode *inode, struct file *filp)
 {
 	int res;
@@ -132,6 +153,23 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	return res;
 }
 
+/*
+ * should only be called when VFS skips revalidation
+ */
+static int
+nfs4_file_open(struct inode *inode, struct file *filp)
+{
+	int res;
+
+	res = nfs_check_flags(filp->f_flags);
+	if (res)
+		return res;
+
+	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
+	res = nfs4_open(inode, filp);
+	return res;
+}
+
 static int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..dcf5eef 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -297,7 +297,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		 */
 		inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->file_inode_ops;
 		if (S_ISREG(inode->i_mode)) {
-			inode->i_fop = &nfs_file_operations;
+			inode->i_fop = NFS_SB(sb)->nfs_client->rpc_ops->file_ops;
 			inode->i_data.a_ops = &nfs_file_aops;
 			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
 		} else if (S_ISDIR(inode->i_mode)) {
@@ -697,6 +697,40 @@ int nfs_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+/*
+ * should only be called when VFS skips revalidation
+ */
+int
+nfs4_open(struct inode *inode, struct file *filp)
+{
+	struct inode *dir = filp->f_path.dentry->d_parent->d_inode;
+	struct rpc_cred *cred;
+	struct nfs_open_context *ctx;
+
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+
+	ctx = alloc_nfs_open_context(filp->f_path.mnt, filp->f_path.dentry, cred);
+	if (ctx == NULL) {
+		put_rpccred(cred);
+		return -ENOMEM;
+	}
+
+	ctx->state = nfs4_do_open(dir, &filp->f_path, filp->f_mode, filp->f_flags, NULL, cred);
+	put_rpccred(cred);
+	if (IS_ERR(ctx->state)) {
+		put_nfs_open_context(ctx);
+		return PTR_ERR(ctx->state);
+	}
+	ctx->mode = filp->f_mode;
+	nfs_set_verifier(filp->f_path.dentry, nfs_save_change_attribute(dir));
+	nfs_file_set_open_context(filp, ctx);
+	put_nfs_open_context(ctx);
+	nfs_fscache_set_inode_cookie(inode, filp);
+	return 0;
+}
+
 int nfs_release(struct inode *inode, struct file *filp)
 {
 	nfs_file_clear_open_context(filp);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 3f8881d..a281f06 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -803,6 +803,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs3_dir_inode_operations,
 	.file_inode_ops	= &nfs3_file_inode_operations,
+	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs3_proc_get_root,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6ea07a3..e20aed2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -203,6 +203,7 @@ extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *)
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
+extern struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff37454..197a2ba 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1587,7 +1587,7 @@ out_err:
 }
 
 
-static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
+struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
 {
 	struct nfs4_exception exception = { };
 	struct nfs4_state *res;
@@ -1879,7 +1879,7 @@ static int nfs4_intent_set_file(struct nameidata *nd, struct path *path, struct
 		if (ret < 0)
 			goto out_close;
 	}
-	filp = lookup_instantiate_filp(nd, path->dentry, NULL);
+	filp = lookup_instantiate_filp(nd, path->dentry, nfs_file_open);
 	if (!IS_ERR(filp)) {
 		struct nfs_open_context *ctx;
 		ctx = nfs_file_open_context(filp);
@@ -5026,6 +5026,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.dentry_ops	= &nfs4_dentry_operations,
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
 	.file_inode_ops	= &nfs4_file_inode_operations,
+	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ef58385..1d4dec7 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -634,6 +634,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs_dir_inode_operations,
 	.file_inode_ops	= &nfs_file_inode_operations,
+	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d09db1b..ee9bcf0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -344,6 +344,7 @@ extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fa
 extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
+extern int nfs4_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
@@ -370,7 +371,9 @@ extern const struct inode_operations nfs_file_inode_operations;
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
+extern const struct file_operations nfs4_file_operations;
 extern const struct address_space_operations nfs_file_aops;
+extern int nfs_file_open(struct inode *inode, struct file *filp);
 
 static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62f63fb..954b703 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -991,6 +991,7 @@ struct nfs_rpc_ops {
 	const struct dentry_operations *dentry_ops;
 	const struct inode_operations *dir_inode_ops;
 	const struct inode_operations *file_inode_ops;
+	const struct file_operations *file_ops;
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
-- 
1.5.5.6

