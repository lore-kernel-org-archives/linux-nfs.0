Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016Ab0I3SPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:15:50 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/17] CIFS: Use d_automount() rather than abusing
	follow_link()
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Steve French <sfrench@samba.org>
Date: Thu, 30 Sep 2010 19:15:16 +0100
Message-ID: <20100930181515.30939.57129.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make CIFS use the new d_automount() dentry operation rather than abusing
follow_link() on directories.

[NOTE: THIS IS UNTESTED!]

[Question:  Why does cifs_dfs_do_refmount() when the caller has already done
	    that and could pass the result through?]

Signed-off-by: David Howells <dhowells@redhat.com>
Cc: Steve French <sfrench@samba.org>
---

 fs/cifs/cifs_dfs_ref.c |  134 +++++++++++++++++++++++-------------------------
 fs/cifs/cifsfs.h       |    6 ++
 fs/cifs/dir.c          |    2 +
 fs/cifs/inode.c        |    8 ++-
 4 files changed, 78 insertions(+), 72 deletions(-)

diff --git a/fs/cifs/cifs_dfs_ref.c b/fs/cifs/cifs_dfs_ref.c
index d6ced7a..8fc4943 100644
--- a/fs/cifs/cifs_dfs_ref.c
+++ b/fs/cifs/cifs_dfs_ref.c
@@ -256,35 +256,6 @@ static struct vfsmount *cifs_dfs_do_refmount(struct cifs_sb_info *cifs_sb,
 
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
@@ -294,34 +265,30 @@ static void dump_referral(const struct dfs_info3_param *ref)
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
@@ -329,56 +296,85 @@ cifs_dfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
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
 		mnt = cifs_dfs_do_refmount(cifs_sb,
 				full_path, referrals + i);
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
index d82f5fb..34b18a6 100644
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
index f9ed075..fc97233 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -795,6 +795,7 @@ cifs_d_revalidate(struct dentry *direntry, struct nameidata *nd)
 
 const struct dentry_operations cifs_dentry_ops = {
 	.d_revalidate = cifs_d_revalidate,
+	.d_automount = cifs_dfs_d_automount,
 /* d_delete:       cifs_d_delete,      */ /* not needed except for debugging */
 };
 
@@ -835,4 +836,5 @@ const struct dentry_operations cifs_ci_dentry_ops = {
 	.d_revalidate = cifs_d_revalidate,
 	.d_hash = cifs_ci_hash,
 	.d_compare = cifs_ci_compare,
+	.d_automount = cifs_dfs_d_automount,
 };
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 93f77d4..a1f810c 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -32,7 +32,7 @@
 #include "fscache.h"
 
 
-static void cifs_set_ops(struct inode *inode, const bool is_dfs_referral)
+static void cifs_set_ops(struct inode *inode)
 {
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 
@@ -60,7 +60,7 @@ static void cifs_set_ops(struct inode *inode, const bool is_dfs_referral)
 		break;
 	case S_IFDIR:
 #ifdef CONFIG_CIFS_DFS_UPCALL
-		if (is_dfs_referral) {
+		if (IS_AUTOMOUNT(inode)) {
 			inode->i_op = &cifs_dfs_referral_inode_operations;
 		} else {
 #else /* NO DFS support, treat as a directory */
@@ -167,7 +167,9 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
 	}
 	spin_unlock(&inode->i_lock);
 
-	cifs_set_ops(inode, fattr->cf_flags & CIFS_FATTR_DFS_REFERRAL);
+	if (fattr->cf_flags & CIFS_FATTR_DFS_REFERRAL)
+		inode->i_flags |= S_AUTOMOUNT;
+	cifs_set_ops(inode);
 }
 
 void

