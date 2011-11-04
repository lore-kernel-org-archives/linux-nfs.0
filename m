Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42942 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640Ab1KDNde (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 09:33:34 -0400
Received: by vcbf1 with SMTP id f1so323425vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 06:33:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: when attempting to open a directory, fall back on normal lookup (try #4)
Date: Fri,  4 Nov 2011 09:33:28 -0400
Message-Id: <1320413608-17032-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1320413608-17032-1-git-send-email-jlayton@redhat.com>
References: <1320413608-17032-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit d953126 changed how nfs_atomic_lookup handles an -EISDIR return
from an OPEN call. Prior to that patch, that caused the client to fall
back to doing a normal lookup. When that patch went in, the code began
returning that error to userspace. The d_revalidate codepath however
never had the corresponding change, so it was still possible to end up
with a NULL ctx->state pointer after that.

That patch caused a regression. When we attempt to open a directory that
does not have a cached dentry, that open now errors out with EISDIR. If
you attempt the same open with a cached dentry, it will succeed.

Fix this by reverting the change in nfs_atomic_lookup and allowing
attempts to open directories to fall back to a normal lookup

Also, add a NFSv4-specific f_ops->open routine that just returns
-ENOTDIR. This should never be called if things are working properly,
but if it ever is, then the dprintk may help in debugging.

To facilitate this, a new file_operations field is also added to the
nfs_rpc_ops struct.

Cc: stable@kernel.org
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c            |    2 +-
 fs/nfs/file.c           |   32 ++++++++++++++++++++++++++++++++
 fs/nfs/inode.c          |    2 +-
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_fs.h  |    3 +++
 include/linux/nfs_xdr.h |    1 +
 8 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b238d95..ac28990 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1468,12 +1468,12 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 				res = NULL;
 				goto out;
 			/* This turned out not to be a regular file */
+			case -EISDIR:
 			case -ENOTDIR:
 				goto no_open;
 			case -ELOOP:
 				if (!(nd->intent.open.flags & O_NOFOLLOW))
 					goto no_open;
-			/* case -EISDIR: */
 			/* case -EINVAL: */
 			default:
 				res = ERR_CAST(inode);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 64ec4c8..531a3ba 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -868,3 +868,35 @@ const struct file_operations nfs_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
+
+#ifdef CONFIG_NFS_V4
+static int
+nfs4_file_open(struct inode *inode, struct file *filp)
+{
+	/*
+	 * NFSv4 opens are handled in d_lookup and d_revalidate. If we get to
+	 * this point, then something is very wrong
+	 */
+	dprintk("NFS: %s called! inode=%p filp=%p\n", __func__, inode, filp);
+	return -ENOTDIR;
+}
+
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
+#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f36543a..bf3a57b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -292,7 +292,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		 */
 		inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->file_inode_ops;
 		if (S_ISREG(inode->i_mode)) {
-			inode->i_fop = &nfs_file_operations;
+			inode->i_fop = NFS_SB(sb)->nfs_client->rpc_ops->file_ops;
 			inode->i_data.a_ops = &nfs_file_aops;
 			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
 		} else if (S_ISDIR(inode->i_mode)) {
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cc1d1e1..9194395 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -854,6 +854,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs3_dir_inode_operations,
 	.file_inode_ops	= &nfs3_file_inode_operations,
+	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs3_proc_get_root,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6c3db05..a17af37 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6248,6 +6248,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.dentry_ops	= &nfs4_dentry_operations,
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
 	.file_inode_ops	= &nfs4_file_inode_operations,
+	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4dda8b5..0c672588 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -711,6 +711,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs_dir_inode_operations,
 	.file_inode_ops	= &nfs_file_inode_operations,
+	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 60a137b..062a3d0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -409,6 +409,9 @@ extern const struct inode_operations nfs_file_inode_operations;
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
+#ifdef CONFIG_NFS_V4
+extern const struct file_operations nfs4_file_operations;
+#endif /* CONFIG_NFS_V4 */
 extern const struct address_space_operations nfs_file_aops;
 extern const struct address_space_operations nfs_dir_aops;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c74595b..2a7c533 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1192,6 +1192,7 @@ struct nfs_rpc_ops {
 	const struct dentry_operations *dentry_ops;
 	const struct inode_operations *dir_inode_ops;
 	const struct inode_operations *file_inode_ops;
+	const struct file_operations *file_ops;
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
-- 
1.7.6.4

