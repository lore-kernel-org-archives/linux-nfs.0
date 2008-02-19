From: Eric Paris <eparis@redhat.com>
Subject: NFS/LSM: allow NFS to control all of its own mount options
Date: Tue, 19 Feb 2008 16:38:14 -0500
Message-ID: <1203457094.2928.113.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: steved@redhat.com, jlayton@redhat.com, sds@tycho.nsa.gov,
	jmorris@namei.org, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org, selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754672AbYBSViy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 16:38:54 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the current code (approved by SELinux and NFS people in 2004) SELinux
tries to understand NFS's binary mount data.  This blows up in the face
of things like nohide mounts which don't use struct nfs_mount_data and I
assume just looking at the code that things don't work since NFS moved
to using nfs_parsed_mount_data as its default binary mount data blob.

This patch moves all of the ownership of the mount options into NFS.  It
brings the text based mount options capabilities up to the same level of
support which existed in version 6 of the old binary mount data from
userspace.  I am not looking at NFSv4 at the moment and the only mount
option this is supporting is context= (just like the old binary support)

Basically this patch causes NFS to make use of the new LSM hooks
security_sb_set_mnt_opts() and security_sb_clone_mnt_opts().  We do this
in the NFS get_sb() calls so that security settings are set explicitly
by NFS before they are set by the generic vfs security hooks which
handle filesystems which use text mount data.

We need to push this for 2.6.25 since at the moment SELinux(or SMACK) +
nohide mounts cause security_sb_copy_mount_data() to copy one page of
mount data starting at the struct nfs_clone_mount_data on the stack.  If
the stack doesn't span 2 pages we run off the end of the stack and hit a
page fault BUG().  Not sure why this didn't happen for me in 2.6.24, but
my guess is the stack size is significantly smaller for this operation
in 2.6.25 so the window is just bigger.

Signed-off-by: Eric Paris <eparis@redhat.com>

---

I tested mounting using both the version 6 binary mount data from
userspace and using the text mount options in a simple program I wrote
to call mount directly.  I was able to correctly set the selinux context
of my mounts and of clone mounts like those created by nohide exports.

This also fixes the BUG() in SMACK code because of the VFS change.
SMACK may want to move to a BUG_ON() like I do in the
selinux_sb_copy_data code just to make it clear binary mount data is not
expected, but I'll leave that up to you.

 fs/nfs/internal.h        |    7 ++++++
 fs/nfs/super.c           |   31 ++++++++++++++++++++++++++--
 fs/super.c               |    2 +-
 security/security.c      |    3 ++
 security/selinux/hooks.c |   48 ++++++++++++++++++++-------------------------
 5 files changed, 60 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0f56196..8e4981c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -14,6 +14,9 @@ struct nfs_string;
  */
 #define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
 
+/* this MUST stay at least as large as the define in nfs_mount.h */
+#define NFS_MAX_INTERNAL_CONTEXT_LEN 256
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
@@ -57,6 +60,10 @@ struct nfs_parsed_mount_data {
 		char			*export_path;
 		int			protocol;
 	} nfs_server;
+
+	struct {
+		char context[NFS_MAX_INTERNAL_CONTEXT_LEN + 1];
+	} lsm_opts;
 };
 
 /* client.c */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1fb3818..dd85c22 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -90,7 +90,7 @@ enum {
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
-	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_addr, Opt_mountaddr, Opt_clientaddr, Opt_context,
 
 	/* Mount options that are ignored */
 	Opt_userspace, Opt_deprecated,
@@ -151,6 +151,8 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
+	{ Opt_context, "context=%s" },
+
 	{ Opt_err, NULL }
 };
 
@@ -1025,7 +1027,15 @@ static int nfs_parse_mount_options(char *raw,
 						 &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
-
+		case Opt_context:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			/* last byte of the array will be 0 if arg too long */
+			strncpy(mnt->lsm_opts.context, string,
+				NFS_MAX_CONTEXT_LEN);
+			kfree(string);
+			break;
 		case Opt_userspace:
 		case Opt_deprecated:
 			break;
@@ -1214,6 +1224,8 @@ static int nfs_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 		args->auth_flavors[0]	= data->pseudoflavor;
+		strncpy(args->lsm_opts.context, data->context,
+			NFS_MAX_CONTEXT_LEN + 1);
 		break;
 	default: {
 		unsigned int len;
@@ -1518,6 +1530,15 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
+
+	/* explicitly set lsm options, all we know is context= from SELinux */
+	if (data.lsm_opts.context[0]) {
+		char *opt = data.lsm_opts.context;
+		int opt_num = CONTEXT_MNT;
+		error = security_sb_set_mnt_opts(s, &opt, &opt_num, 1);
+		if (error)
+			goto error_splat_root;
+	}
 	error = 0;
 
 out:
@@ -1528,7 +1549,8 @@ out:
 out_err_nosb:
 	nfs_free_server(server);
 	goto out;
-
+error_splat_root:
+	dput(mnt->mnt_root);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -1608,6 +1630,9 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	/* clone any lsm security options from the parent to the new sb */
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs_xdev_get_sb() = 0\n");
 	return 0;
 
diff --git a/fs/super.c b/fs/super.c
index 88811f6..0986944 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -870,7 +870,7 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 	if (!mnt)
 		goto out;
 
-	if (data) {
+	if (data && !(type->fs_flags & FS_BINARY_MOUNTDATA)) {
 		secdata = alloc_secdata();
 		if (!secdata)
 			goto out_mnt;
diff --git a/security/security.c b/security/security.c
index d15e56c..ba9a42d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -311,6 +311,7 @@ int security_sb_get_mnt_opts(const struct super_block *sb,
 {
 	return security_ops->sb_get_mnt_opts(sb, mount_options, flags, num_opts);
 }
+EXPORT_SYMBOL(security_sb_get_mnt_opts);
 
 int security_sb_set_mnt_opts(struct super_block *sb,
 			      char **mount_options,
@@ -318,12 +319,14 @@ int security_sb_set_mnt_opts(struct super_block *sb,
 {
 	return security_ops->sb_set_mnt_opts(sb, mount_options, flags, num_opts);
 }
+EXPORT_SYMBOL(security_sb_set_mnt_opts);
 
 void security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb)
 {
 	security_ops->sb_clone_mnt_opts(oldsb, newsb);
 }
+EXPORT_SYMBOL(security_sb_clone_mnt_opts);
 
 int security_inode_alloc(struct inode *inode)
 {
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 75c2e99..6f78041 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -556,6 +556,9 @@ static int bad_option(struct superblock_security_struct *sbsec, char flag,
 /*
  * Allow filesystems with binary mount data to explicitly set mount point
  * labeling information.
+ *
+ * This function also attempts to verify that the superblock is not already
+ * in use with different mount options.
  */
 static int selinux_set_mnt_opts(struct super_block *sb, char **mount_options,
 				int *flags, int num_opts)
@@ -589,6 +592,21 @@ static int selinux_set_mnt_opts(struct super_block *sb, char **mount_options,
 	}
 
 	/*
+	 * Binary mount data FS will come through this function twice.  Once
+	 * from an explicit call and once from the generic calls from the vfs.
+	 * Since the generic VFS calls will not contain any security mount data
+	 * we need to skip the double mount verification.
+	 *
+	 * This does open a tiny hole in which we will not notice if the first
+	 * mount using this sb set explict options and a second mount using
+	 * superblock does not set any security options.  (The first options
+	 * will be used for both mounts)
+	 */
+	if (sbsec->initialized && (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
+	    && (num_opts == 0))
+		goto out;
+
+	/*
 	 * parse the mount options, check if they are valid sids.
 	 * also check if someone is trying to mount the same sb more
 	 * than once with different security options.
@@ -808,27 +826,8 @@ static int superblock_doinit(struct super_block *sb, void *data)
 	if (!data)
 		goto out;
 
-	/* with the nfs patch this will become a goto out; */
-	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
-		const char *name = sb->s_type->name;
-		/* NFS we understand. */
-		if (!strcmp(name, "nfs")) {
-			struct nfs_mount_data *d = data;
-
-			if (d->version !=  NFS_MOUNT_VERSION)
-				goto out;
-
-			if (d->context[0]) {
-				context = kstrdup(d->context, GFP_KERNEL);
-				if (!context) {
-					rc = -ENOMEM;
-					goto out;
-				}
-			}
-			goto build_flags;
-		} else
-			goto out;
-	}
+	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
+		goto out;
 
 	/* Standard string-based options. */
 	while ((p = strsep(&options, "|")) != NULL) {
@@ -901,7 +900,6 @@ static int superblock_doinit(struct super_block *sb, void *data)
 		}
 	}
 
-build_flags:
 	if (fscontext) {
 		mnt_opts[num_mnt_opts] = fscontext;
 		mnt_opts_flags[num_mnt_opts++] = FSCONTEXT_MNT;
@@ -2263,11 +2261,7 @@ static int selinux_sb_copy_data(struct file_system_type *type, void *orig, void
 	in_curr = orig;
 	sec_curr = copy;
 
-	/* Binary mount data: just copy */
-	if (type->fs_flags & FS_BINARY_MOUNTDATA) {
-		copy_page(sec_curr, in_curr);
-		goto out;
-	}
+	BUG_ON(type->fs_flags & FS_BINARY_MOUNTDATA);
 
 	nosec = (char *)get_zeroed_page(GFP_KERNEL);
 	if (!nosec) {


