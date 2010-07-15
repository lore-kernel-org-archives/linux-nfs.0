From: David Howells <dhowells@redhat.com>
Subject: [PATCH 15/18] xstat: CIFS: Use d_automount() rather than abusing
	follow_link() [ver #6]
Date: Thu, 15 Jul 2010 03:17:27 +0100
Message-ID: <20100715021727.5544.70469.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make CIFS use the new d_automount() dentry operation rather than abusing
follow_link() on directories.

[NOTE: THIS IS UNTESTED!]

[Question:  Why does cifs_dfs_do_refmount() when the caller has already done
	    that and could pass the result through?]

Signed-off-by: David Howells <dhowells@redhat.com>
Cc: Steve French <sfrench@samba.org>
---

 fs/cifs/cifs_dfs_ref.c |  145 +++++++++++++++++++++++-------------------------
 fs/cifs/cifsfs.h       |    6 ++
 fs/cifs/dir.c          |    2 +
 fs/cifs/inode.c        |    8 ++-
 4 files changed, 83 insertions(+), 78 deletions(-)

diff --git a/fs/cifs/cifs_dfs_ref.c b/fs/cifs/cifs_dfs_ref.c
index 4516867..500b952 100644
--- a/fs/cifs/cifs_dfs_ref.c
+++ b/fs/cifs/cifs_dfs_ref.c
@@ -230,8 +230,8 @@ compose_mount_options_err:
 }
 
 
-static struct vfsmount *cifs_dfs_do_refmount(const struct vfsmount *mnt_parent,
-		struct dentry *dentry, const struct dfs_info3_param *ref)
+static struct vfsmount *cifs_dfs_do_refmount(struct dentry *mntpt,
+					     const struct dfs_info3_param *ref)
 {
 	struct cifs_sb_info *cifs_sb;
 	struct vfsmount *mnt;
@@ -239,12 +239,12 @@ static struct vfsmount *cifs_dfs_do_refmount(const struct vfsmount *mnt_parent,
 	char *devname = NULL;
 	char *fullpath;
 
-	cifs_sb = CIFS_SB(dentry->d_inode->i_sb);
+	cifs_sb = CIFS_SB(mntpt->d_inode->i_sb);
 	/*
 	 * this function gives us a path with a double backslash prefix. We
 	 * require a single backslash for DFS.
 	 */
-	fullpath = build_path_from_dentry(dentry);
+	fullpath = build_path_from_dentry(mntpt);
 	if (!fullpath)
 		return ERR_PTR(-ENOMEM);
 
@@ -262,35 +262,6 @@ static struct vfsmount *cifs_dfs_do_refmount(const struct vfsmount *mnt_parent,
 
 }
 
-static int add_mount_helper(struct vfsmount *newmnt, struct nameidata *nd,
-				struct list_head *mntlist)
-{
-	/* stolen from afs code */
-	int err;
-
-	mntget(newmnt);
-	err = do_add_mount(newmnt, &nd->path, nd->path.mnt->mnt_flags | MNT_SHRINKABLE, mntlist);
-	switch (err) {
-	case 0:
-		path_put(&nd->path);
-		nd->path.mnt = newmnt;
-		nd->path.dentry = dget(newmnt->mnt_root);
-		schedule_delayed_work(&cifs_dfs_automount_task,
-				      cifs_dfs_mountpoint_expiry_timeout);
-		break;
-	case -EBUSY:
-		/* someone else made a mount here whilst we were busy */
-		while (d_mountpoint(nd->path.dentry) &&
-		       follow_down(&nd->path))
-			;
-		err = 0;
-	default:
-		mntput(newmnt);
-		break;
-	}
-	return err;
-}
-
 static void dump_referral(const struct dfs_info3_param *ref)
 {
 	cFYI(1, "DFS: ref path: %s", ref->path_name);
@@ -300,34 +271,30 @@ static void dump_referral(const struct dfs_info3_param *ref)
 				ref->path_consumed);
 }
 
-
-static void*
-cifs_dfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
+/*
+ * Create a vfsmount that we can automount
+ */
+static struct vfsmount *cifs_dfs_do_automount(struct dentry *mntpt)
 {
 	struct dfs_info3_param *referrals = NULL;
 	unsigned int num_referrals = 0;
 	struct cifs_sb_info *cifs_sb;
 	struct cifsSesInfo *ses;
-	char *full_path = NULL;
+	char *full_path;
 	int xid, i;
-	int rc = 0;
-	struct vfsmount *mnt = ERR_PTR(-ENOENT);
+	int rc;
+	struct vfsmount *mnt;
 
 	cFYI(1, "in %s", __func__);
-	BUG_ON(IS_ROOT(dentry));
+	BUG_ON(IS_ROOT(mntpt));
 
 	xid = GetXid();
 
-	dput(nd->path.dentry);
-	nd->path.dentry = dget(dentry);
-
-	cifs_sb = CIFS_SB(dentry->d_inode->i_sb);
+	cifs_sb = CIFS_SB(mntpt->d_inode->i_sb);
+	mnt = ERR_PTR(-EINVAL);
 	ses = cifs_sb->tcon->ses;
-
-	if (!ses) {
-		rc = -EINVAL;
-		goto out_err;
-	}
+	if (!ses)
+		goto free_xid;
 
 	/*
 	 * The MSDFS spec states that paths in DFS referral requests and
@@ -335,56 +302,84 @@ cifs_dfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	 * the double backslashes usually used in the UNC. This function
 	 * gives us the latter, so we must adjust the result.
 	 */
-	full_path = build_path_from_dentry(dentry);
-	if (full_path == NULL) {
-		rc = -ENOMEM;
-		goto out_err;
-	}
+	mnt = ERR_PTR(-ENOMEM);
+	full_path = build_path_from_dentry(mntpt);
+	if (full_path == NULL)
+		goto free_xid;
 
 	rc = get_dfs_path(xid, ses , full_path + 1, cifs_sb->local_nls,
 		&num_referrals, &referrals,
 		cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 
+	mnt = ERR_PTR(-ENOENT);
 	for (i = 0; i < num_referrals; i++) {
 		int len;
-		dump_referral(referrals+i);
+		dump_referral(referrals + i);
 		/* connect to a node */
 		len = strlen(referrals[i].node_name);
 		if (len < 2) {
 			cERROR(1, "%s: Net Address path too short: %s",
 					__func__, referrals[i].node_name);
-			rc = -EINVAL;
-			goto out_err;
+			mnt = ERR_PTR(-EINVAL);
+			break;
 		}
-		mnt = cifs_dfs_do_refmount(nd->path.mnt,
-				nd->path.dentry, referrals + i);
+		mnt = cifs_dfs_do_refmount(mntpt, referrals + i);
 		cFYI(1, "%s: cifs_dfs_do_refmount:%s , mnt:%p", __func__,
 					referrals[i].node_name, mnt);
-
-		/* complete mount procedure if we accured submount */
 		if (!IS_ERR(mnt))
-			break;
+			goto success;
 	}
 
-	/* we need it cause for() above could exit without valid submount */
-	rc = PTR_ERR(mnt);
-	if (IS_ERR(mnt))
-		goto out_err;
-
-	rc = add_mount_helper(mnt, nd, &cifs_dfs_automount_list);
+	/* no valid submounts were found; return error from get_dfs_path() by
+	 * preference */
+	if (rc != 0)
+		mnt = ERR_PTR(rc);
 
-out:
-	FreeXid(xid);
+success:
 	free_dfs_info_array(referrals, num_referrals);
 	kfree(full_path);
+free_xid:
+	FreeXid(xid);
 	cFYI(1, "leaving %s" , __func__);
 	return ERR_PTR(rc);
-out_err:
-	path_put(&nd->path);
-	goto out;
+}
+
+/*
+ * Attempt to automount the referral
+ */
+struct vfsmount *cifs_dfs_d_automount(struct path *path)
+{
+	struct vfsmount *newmnt;
+	int err;
+
+	cFYI(1, "in %s", __func__);
+
+	newmnt = cifs_dfs_do_automount(path->dentry);
+	if (IS_ERR(newmnt)) {
+		cFYI(1, "leaving %s [automount failed]" , __func__);
+		return newmnt;
+	}
+
+	mntget(newmnt);
+	err = do_add_mount(newmnt, path, MNT_SHRINKABLE,
+			   &cifs_dfs_automount_list);
+	switch (err) {
+	case 0:
+		schedule_delayed_work(&cifs_dfs_automount_task,
+				      cifs_dfs_mountpoint_expiry_timeout);
+		cFYI(1, "leaving %s [ok]" , __func__);
+		return newmnt;
+	case -EBUSY:
+		/* someone else made a mount here whilst we were busy */
+		mntput(newmnt);
+		cFYI(1, "leaving %s [EBUSY]" , __func__);
+		return NULL;
+	default:
+		mntput(newmnt);
+		cFYI(1, "leaving %s [error %d]" , __func__, err);
+		return ERR_PTR(err);
+	}
 }
 
 const struct inode_operations cifs_dfs_referral_inode_operations = {
-	.follow_link = cifs_dfs_follow_mountpoint,
 };
-
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 50bf70b..fb50a4a 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -95,6 +95,12 @@ extern int cifs_readdir(struct file *file, void *direntry, filldir_t filldir);
 extern const struct dentry_operations cifs_dentry_ops;
 extern const struct dentry_operations cifs_ci_dentry_ops;
 
+#ifdef CONFIG_CIFS_DFS_UPCALL
+extern struct vfsmount *cifs_dfs_d_automount(struct path *path);
+#else
+#define cifs_dfs_d_automount NULL
+#endif
+
 /* Functions related to symlinks */
 extern void *cifs_follow_link(struct dentry *direntry, struct nameidata *nd);
 extern void cifs_put_link(struct dentry *direntry,
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index 65da30e..73fd652 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -804,6 +804,7 @@ cifs_d_revalidate(struct dentry *direntry, struct nameidata *nd)
 
 const struct dentry_operations cifs_dentry_ops = {
 	.d_revalidate = cifs_d_revalidate,
+	.d_automount = cifs_dfs_d_automount,
 /* d_delete:       cifs_d_delete,      */ /* not needed except for debugging */
 };
 
@@ -844,4 +845,5 @@ const struct dentry_operations cifs_ci_dentry_ops = {
 	.d_revalidate = cifs_d_revalidate,
 	.d_hash = cifs_ci_hash,
 	.d_compare = cifs_ci_compare,
+	.d_automount = cifs_dfs_d_automount,
 };
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index ff4a62f..12d95f4 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -31,7 +31,7 @@
 #include "cifs_fs_sb.h"
 
 
-static void cifs_set_ops(struct inode *inode, const bool is_dfs_referral)
+static void cifs_set_ops(struct inode *inode)
 {
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 
@@ -59,7 +59,7 @@ static void cifs_set_ops(struct inode *inode, const bool is_dfs_referral)
 		break;
 	case S_IFDIR:
 #ifdef CONFIG_CIFS_DFS_UPCALL
-		if (is_dfs_referral) {
+		if (IS_AUTOMOUNT(inode)) {
 			inode->i_op = &cifs_dfs_referral_inode_operations;
 		} else {
 #else /* NO DFS support, treat as a directory */
@@ -170,7 +170,9 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
 	}
 	spin_unlock(&inode->i_lock);
 
-	cifs_set_ops(inode, fattr->cf_flags & CIFS_FATTR_DFS_REFERRAL);
+	if (fattr->cf_flags & CIFS_FATTR_DFS_REFERRAL)
+		inode->i_flags |= S_AUTOMOUNT;
+	cifs_set_ops(inode);
 }
 
 void

