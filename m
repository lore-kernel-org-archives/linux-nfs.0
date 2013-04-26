Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f51.google.com ([209.85.215.51]:47858 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab3DZMAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 08:00:03 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v6 5/7] NFSv4: Add O_DENY* open flags support
Date: Fri, 26 Apr 2013 16:04:19 +0400
Message-Id: <1366977861-27678-6-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by passing these flags to NFSv4 open request. Make it return
-ESHAREDENIED on share conflicts with other opens and disable
O_DENYDELETE support since NFSv4 doesn't support it.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/nfs/dir.c       |  4 ++++
 fs/nfs/internal.h  |  3 ++-
 fs/nfs/nfs4file.c  |  4 ++++
 fs/nfs/nfs4proc.c  |  4 +++-
 fs/nfs/nfs4super.c |  9 ++++++---
 fs/nfs/nfs4xdr.c   | 21 +++++++++++++++++----
 fs/nfs/super.c     |  7 +++++--
 7 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f23f455..fe3215c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1395,6 +1395,10 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	dfprintk(VFS, "NFS: atomic_open(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
+	/* No support for O_DENYDELETE */
+	if (open_flags & O_DENYDELETE)
+		return -EINVAL;
+
 	/* NFS only supports OPEN on regular files */
 	if ((open_flags & O_DIRECTORY)) {
 		if (!d_unhashed(dentry)) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 541c9eb..70cd1b0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -6,7 +6,8 @@
 #include <linux/mount.h>
 #include <linux/security.h>
 
-#define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
+#define NFS_MS_MASK (MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC | \
+		     MS_SYNCHRONOUS | MS_SHARELOCK)
 
 struct nfs_string;
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 13e6bb3..f5ec400 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -34,6 +34,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 		dentry->d_parent->d_name.name,
 		dentry->d_name.name);
 
+	/* No support for O_DENYDELETE */
+	if (openflags & O_DENYDELETE)
+		return -EINVAL;
+
 	if ((openflags & O_ACCMODE) == 3)
 		openflags--;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ad025e..fcf0d80 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -102,7 +102,7 @@ static int nfs4_map_errors(int err)
 	case -NFS4ERR_BADNAME:
 		return -EINVAL;
 	case -NFS4ERR_SHARE_DENIED:
-		return -EACCES;
+		return -ESHAREDENIED;
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		return -EPROTONOSUPPORT;
 	case -NFS4ERR_ACCESS:
@@ -795,6 +795,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	atomic_inc(&sp->so_count);
 	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
+	if (!IS_SHARELOCK(dir))
+		p->o_arg.open_flags &= ~(O_DENYREAD | O_DENYWRITE);
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
 	 * will return permission denied for all bits until close */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 569b166..a25a929 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -28,7 +28,8 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 static struct file_system_type nfs4_remote_referral_fs_type = {
@@ -36,7 +37,8 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -44,7 +46,8 @@ struct file_system_type nfs4_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 static const struct super_operations nfs4_sops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e3edda5..cb0e8de 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1325,7 +1325,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
+				int open_flags)
 {
 	__be32 *p;
 
@@ -1343,7 +1344,19 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 	default:
 		*p++ = cpu_to_be32(0);
 	}
-	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
+	switch (open_flags & (O_DENYREAD|O_DENYWRITE)) {
+	case O_DENYREAD:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_READ);
+		break;
+	case O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_WRITE);
+		break;
+	case O_DENYREAD|O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_BOTH);
+		break;
+	default:
+		*p = cpu_to_be32(0);
+	}
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1354,7 +1367,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->open_flags);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1491,7 +1504,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, 0);
 }
 
 static void
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f8a29d..f351008 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -332,7 +332,8 @@ struct file_system_type nfs4_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 MODULE_ALIAS_FS("nfs4");
 MODULE_ALIAS("nfs4");
@@ -2544,6 +2545,8 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
+	/* save sharelock option */
+	int sharelock = data->sb->s_flags & MS_SHARELOCK;
 
 	dprintk("--> nfs_xdev_mount()\n");
 
@@ -2555,7 +2558,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	if (IS_ERR(server))
 		mntroot = ERR_CAST(server);
 	else
-		mntroot = nfs_fs_mount_common(server, flags,
+		mntroot = nfs_fs_mount_common(server, flags | sharelock,
 				dev_name, &mount_info, nfs_mod);
 
 	dprintk("<-- nfs_xdev_mount() = %ld\n",
-- 
1.8.1.5

