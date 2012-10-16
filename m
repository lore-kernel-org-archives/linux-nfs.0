Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755449Ab2JPWBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 18:01:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
        David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: [PATCH 12/12] locks: break delegations on any attribute modification
Date: Tue, 16 Oct 2012 18:01:37 -0400
Message-Id: <1350424897-26894-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1350424897-26894-1-git-send-email-bfields@redhat.com>
References: <1350424897-26894-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

NFSv4 uses leases to guarantee that clients can cache metadata as well
as data.

Cc: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: David Howells <dhowells@redhat.com>
Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 drivers/base/devtmpfs.c   |    4 ++--
 fs/attr.c                 |    5 ++++-
 fs/cachefiles/interface.c |    4 ++--
 fs/ecryptfs/inode.c       |    2 +-
 fs/hpfs/namei.c           |    2 +-
 fs/inode.c                |    6 +++++-
 fs/nfsd/vfs.c             |    8 ++++++--
 fs/open.c                 |   21 +++++++++++++++++----
 fs/utimes.c               |    9 ++++++++-
 include/linux/fs.h        |    2 +-
 10 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 21099da..5295e4c 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -210,7 +210,7 @@ static int handle_create(const char *nodename, umode_t mode, struct device *dev)
 		newattrs.ia_mode = mode;
 		newattrs.ia_valid = ATTR_MODE;
 		mutex_lock(&dentry->d_inode->i_mutex);
-		notify_change(dentry, &newattrs);
+		notify_change(dentry, &newattrs, NULL);
 		mutex_unlock(&dentry->d_inode->i_mutex);
 
 		/* mark as kernel-created inode */
@@ -315,7 +315,7 @@ static int handle_remove(const char *nodename, struct device *dev)
 			newattrs.ia_valid =
 				ATTR_UID|ATTR_GID|ATTR_MODE;
 			mutex_lock(&dentry->d_inode->i_mutex);
-			notify_change(dentry, &newattrs);
+			notify_change(dentry, &newattrs, NULL);
 			mutex_unlock(&dentry->d_inode->i_mutex);
 			err = vfs_unlink(parent.dentry->d_inode, dentry, NULL);
 			if (!err || err == -ENOENT)
diff --git a/fs/attr.c b/fs/attr.c
index cce7df5..ad0a943 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -164,7 +164,7 @@ void setattr_copy(struct inode *inode, const struct iattr *attr)
 }
 EXPORT_SYMBOL(setattr_copy);
 
-int notify_change(struct dentry * dentry, struct iattr * attr)
+int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **delegated_inode)
 {
 	struct inode *inode = dentry->d_inode;
 	umode_t mode = inode->i_mode;
@@ -240,6 +240,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
+	error = try_break_deleg(inode, delegated_inode);
+	if (error)
+		return error;
 
 	if (inode->i_op->setattr)
 		error = inode->i_op->setattr(dentry, attr);
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 67bef6d..67674b4 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -417,14 +417,14 @@ static int cachefiles_attr_changed(struct fscache_object *_object)
 		_debug("discard tail %llx", oi_size);
 		newattrs.ia_valid = ATTR_SIZE;
 		newattrs.ia_size = oi_size & PAGE_MASK;
-		ret = notify_change(object->backer, &newattrs);
+		ret = notify_change(object->backer, &newattrs, NULL);
 		if (ret < 0)
 			goto truncate_failed;
 	}
 
 	newattrs.ia_valid = ATTR_SIZE;
 	newattrs.ia_size = ni_size;
-	ret = notify_change(object->backer, &newattrs);
+	ret = notify_change(object->backer, &newattrs, NULL);
 
 truncate_failed:
 	mutex_unlock(&object->backer->d_inode->i_mutex);
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index a3b2b08..d751d8a 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -992,7 +992,7 @@ static int ecryptfs_setattr(struct dentry *dentry, struct iattr *ia)
 		lower_ia.ia_valid &= ~ATTR_MODE;
 
 	mutex_lock(&lower_dentry->d_inode->i_mutex);
-	rc = notify_change(lower_dentry, &lower_ia);
+	rc = notify_change(lower_dentry, &lower_ia, NULL);
 	mutex_unlock(&lower_dentry->d_inode->i_mutex);
 out:
 	fsstack_copy_attr_all(inode, lower_inode);
diff --git a/fs/hpfs/namei.c b/fs/hpfs/namei.c
index 345713d..1b39afd 100644
--- a/fs/hpfs/namei.c
+++ b/fs/hpfs/namei.c
@@ -407,7 +407,7 @@ again:
 			/*printk("HPFS: truncating file before delete.\n");*/
 			newattrs.ia_size = 0;
 			newattrs.ia_valid = ATTR_SIZE | ATTR_CTIME;
-			err = notify_change(dentry, &newattrs);
+			err = notify_change(dentry, &newattrs, NULL);
 			put_write_access(inode);
 			if (!err)
 				goto again;
diff --git a/fs/inode.c b/fs/inode.c
index 2cffc18..03ba513 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1626,7 +1626,11 @@ static int __remove_suid(struct dentry *dentry, int kill)
 	struct iattr newattrs;
 
 	newattrs.ia_valid = ATTR_FORCE | kill;
-	return notify_change(dentry, &newattrs);
+	/*
+	 * Note we call this on write, so notify_change will not
+	 * encounter any conflicting delegations:
+	 */
+	return notify_change(dentry, &newattrs, NULL);
 }
 
 int file_remove_suid(struct file *file)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5e36961..e8d5d25 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -426,7 +426,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 			goto out_nfserr;
 		fh_lock(fhp);
 
-		host_err = notify_change(dentry, iap);
+		host_err = notify_change(dentry, iap, NULL);
 		err = nfserrno(host_err);
 		fh_unlock(fhp);
 	}
@@ -961,7 +961,11 @@ static void kill_suid(struct dentry *dentry)
 	ia.ia_valid = ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
 
 	mutex_lock(&dentry->d_inode->i_mutex);
-	notify_change(dentry, &ia);
+	/*
+	 * Note we call this on write, so notify_change will not
+	 * encounter any conflicting delegations:
+	 */
+	notify_change(dentry, &ia, NULL);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 }
 
diff --git a/fs/open.c b/fs/open.c
index 59071f5..83e15dd 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -56,7 +56,7 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
 		newattrs.ia_valid |= ret | ATTR_FORCE;
 
 	mutex_lock(&dentry->d_inode->i_mutex);
-	ret = notify_change(dentry, &newattrs);
+	ret = notify_change(dentry, &newattrs, NULL);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 	return ret;
 }
@@ -452,21 +452,28 @@ out:
 static int chmod_common(struct path *path, umode_t mode)
 {
 	struct inode *inode = path->dentry->d_inode;
+	struct inode *delegated_inode = NULL;
 	struct iattr newattrs;
 	int error;
 
 	error = mnt_want_write(path->mnt);
 	if (error)
 		return error;
+retry_deleg:
 	mutex_lock(&inode->i_mutex);
 	error = security_path_chmod(path, mode);
 	if (error)
 		goto out_unlock;
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	error = notify_change(path->dentry, &newattrs);
+	error = notify_change(path->dentry, &newattrs, &delegated_inode);
 out_unlock:
 	mutex_unlock(&inode->i_mutex);
+	if (delegated_inode) {
+		error = break_deleg_wait(&delegated_inode);
+		if (!error)
+			goto retry_deleg;
+	}
 	mnt_drop_write(path->mnt);
 	return error;
 }
@@ -506,6 +513,7 @@ SYSCALL_DEFINE2(chmod, const char __user *, filename, umode_t, mode)
 static int chown_common(struct path *path, uid_t user, gid_t group)
 {
 	struct inode *inode = path->dentry->d_inode;
+	struct inode *delegated_inode = NULL;
 	int error;
 	struct iattr newattrs;
 	kuid_t uid;
@@ -530,12 +538,17 @@ static int chown_common(struct path *path, uid_t user, gid_t group)
 	if (!S_ISDIR(inode->i_mode))
 		newattrs.ia_valid |=
 			ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
+retry_deleg:
 	mutex_lock(&inode->i_mutex);
 	error = security_path_chown(path, uid, gid);
 	if (!error)
-		error = notify_change(path->dentry, &newattrs);
+		error = notify_change(path->dentry, &newattrs, &delegated_inode);
 	mutex_unlock(&inode->i_mutex);
-
+	if (delegated_inode) {
+		error = break_deleg_wait(&delegated_inode);
+		if (!error)
+			goto retry_deleg;
+	}
 	return error;
 }
 
diff --git a/fs/utimes.c b/fs/utimes.c
index bb0696a..671c27e 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -53,6 +53,7 @@ static int utimes_common(struct path *path, struct timespec *times)
 	int error;
 	struct iattr newattrs;
 	struct inode *inode = path->dentry->d_inode;
+	struct inode *delegated_inode = NULL;
 
 	error = mnt_want_write(path->mnt);
 	if (error)
@@ -101,9 +102,15 @@ static int utimes_common(struct path *path, struct timespec *times)
 				goto mnt_drop_write_and_out;
 		}
 	}
+retry_deleg:
 	mutex_lock(&inode->i_mutex);
-	error = notify_change(path->dentry, &newattrs);
+	error = notify_change(path->dentry, &newattrs, &delegated_inode);
 	mutex_unlock(&inode->i_mutex);
+	if (delegated_inode) {
+		error = break_deleg_wait(&delegated_inode);
+		if (!error)
+			goto retry_deleg;
+	}
 
 mnt_drop_write_and_out:
 	mnt_drop_write(path->mnt);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f12a380..07e7369 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2137,7 +2137,7 @@ extern void emergency_remount(void);
 #ifdef CONFIG_BLOCK
 extern sector_t bmap(struct inode *, sector_t);
 #endif
-extern int notify_change(struct dentry *, struct iattr *);
+extern int notify_change(struct dentry *, struct iattr *, struct inode **);
 extern int inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);
 
-- 
1.7.9.5

