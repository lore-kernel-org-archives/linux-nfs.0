Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49089 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752893AbdKIHvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 02:51:12 -0500
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>,
        Jeff Layton <jlayton@redhat.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 09 Nov 2017 18:20:24 +1100
Subject: [PATCH 3/3] VFS / autofs4: remove kern_path_mountpoint()
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Message-ID: <151021202428.22743.11071460838655377498.stgit@noble>
In-Reply-To: <151021179901.22743.15252956909042161062.stgit@noble>
References: <151021179901.22743.15252956909042161062.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kern_path_mountpoint() is only called from autofs4 to perform
lookups which need to identify autofs4 mount points.

Many of the differences between kern_path() and kern_path_mountpoint()
are related to the fact that we will never use O_CREAT with the
latter, and don't need to "open" the target.
The main differences that could be relevant to autofs4 are:
- kern_path_mountpoint() does not call complete_walk() in
  mountpoint_last(), contrasting with do_last() which does call it.
  This means ->d_weak_revalidate() is not called from autofs4.

- follow_managed() is not call from mountpoint_last().

- LOOKUP_NO_REVAL is used for lookup_slow on the last component,
  if it isn't in cache.

As ->d_weak_revalidate() is now a no-op when LOOKUP_OPEN isn't
present, the first difference is no longer important.

The use of LOOKUP_NO_REVAL shouldn't cause autofs4 any problems
as no autofs4 dentry has ->d_revalidate().

follow_managed() might:
 a/ call ->d_manage()
 b/ might cross a mountpoint
 c/ might call follow_automount()

'b' cannot be relevant as path_mountpoint calls follow_mount() after
mountpoint_last() is called.

'a' might only be interesting when ->d_manage is autofs4_d_manage(),
but autofs4 only calls kern_path_mountpoint from ioctls issued by the
automount daemon, and autofs4_d_manage() will exit quickly in that
case.  So there is no risk of autofs4_d_manage() waiting for the
automount daemon (which it would be blocking) and causing a deadlock.

'c' could have been a problem before commit 42f461482178 ("autofs: fix
AT_NO_AUTOMOUNT not being honored").  Prior to that commit a lookup
for a negative autofs4 dentry could trigger an automount, even though
'flags' is 0.  Since that commit and error is returned instead.

So follow_managed() is no longer a problem.

So there is no reason that autofs4 needs to use kern_path_mountpoint()
any more.  It cannot deadlock.
So the whole 'path mountpoint' infrastructure can be discarded.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/autofs4/dev-ioctl.c |    5 +-
 fs/namei.c             |  129 ------------------------------------------------
 include/linux/namei.h  |    1 
 3 files changed, 2 insertions(+), 133 deletions(-)

diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index b7c816f39404..716c44593117 100644
--- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -209,7 +209,7 @@ static int find_autofs_mount(const char *pathname,
 	struct path path;
 	int err;
 
-	err = kern_path_mountpoint(AT_FDCWD, pathname, &path, 0);
+	err = kern_path(pathname,0 , &path);
 	if (err)
 		return err;
 	err = -ENOENT;
@@ -547,8 +547,7 @@ static int autofs_dev_ioctl_ismountpoint(struct file *fp,
 
 	if (!fp || param->ioctlfd == -1) {
 		if (autofs_type_any(type))
-			err = kern_path_mountpoint(AT_FDCWD,
-						   name, &path, LOOKUP_FOLLOW);
+			err = kern_path(name, LOOKUP_FOLLOW, &path);
 		else
 			err = find_autofs_mount(name, &path,
 						test_by_type, &type);
diff --git a/fs/namei.c b/fs/namei.c
index 6639203d7eba..e90680a3f6f1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2601,135 +2601,6 @@ int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
 }
 EXPORT_SYMBOL(user_path_at_empty);
 
-/**
- * mountpoint_last - look up last component for umount
- * @nd:   pathwalk nameidata - currently pointing at parent directory of "last"
- *
- * This is a special lookup_last function just for umount. In this case, we
- * need to resolve the path without doing any revalidation.
- *
- * The nameidata should be the result of doing a LOOKUP_PARENT pathwalk. Since
- * mountpoints are always pinned in the dcache, their ancestors are too. Thus,
- * in almost all cases, this lookup will be served out of the dcache. The only
- * cases where it won't are if nd->last refers to a symlink or the path is
- * bogus and it doesn't exist.
- *
- * Returns:
- * -error: if there was an error during lookup. This includes -ENOENT if the
- *         lookup found a negative dentry.
- *
- * 0:      if we successfully resolved nd->last and found it to not to be a
- *         symlink that needs to be followed.
- *
- * 1:      if we successfully resolved nd->last and found it to be a symlink
- *         that needs to be followed.
- */
-static int
-mountpoint_last(struct nameidata *nd)
-{
-	int error = 0;
-	struct dentry *dir = nd->path.dentry;
-	struct path path;
-
-	/* If we're in rcuwalk, drop out of it to handle last component */
-	if (nd->flags & LOOKUP_RCU) {
-		if (unlazy_walk(nd))
-			return -ECHILD;
-	}
-
-	nd->flags &= ~LOOKUP_PARENT;
-
-	if (unlikely(nd->last_type != LAST_NORM)) {
-		error = handle_dots(nd, nd->last_type);
-		if (error)
-			return error;
-		path.dentry = dget(nd->path.dentry);
-	} else {
-		path.dentry = d_lookup(dir, &nd->last);
-		if (!path.dentry) {
-			/*
-			 * No cached dentry. Mounted dentries are pinned in the
-			 * cache, so that means that this dentry is probably
-			 * a symlink or the path doesn't actually point
-			 * to a mounted dentry.
-			 */
-			path.dentry = lookup_slow(&nd->last, dir,
-					     nd->flags | LOOKUP_NO_REVAL);
-			if (IS_ERR(path.dentry))
-				return PTR_ERR(path.dentry);
-		}
-	}
-	if (d_is_negative(path.dentry)) {
-		dput(path.dentry);
-		return -ENOENT;
-	}
-	path.mnt = nd->path.mnt;
-	return step_into(nd, &path, 0, d_backing_inode(path.dentry), 0);
-}
-
-/**
- * path_mountpoint - look up a path to be umounted
- * @nd:		lookup context
- * @flags:	lookup flags
- * @path:	pointer to container for result
- *
- * Look up the given name, but don't attempt to revalidate the last component.
- * Returns 0 and "path" will be valid on success; Returns error otherwise.
- */
-static int
-path_mountpoint(struct nameidata *nd, unsigned flags, struct path *path)
-{
-	const char *s = path_init(nd, flags);
-	int err;
-	if (IS_ERR(s))
-		return PTR_ERR(s);
-	while (!(err = link_path_walk(s, nd)) &&
-		(err = mountpoint_last(nd)) > 0) {
-		s = trailing_symlink(nd);
-		if (IS_ERR(s)) {
-			err = PTR_ERR(s);
-			break;
-		}
-	}
-	if (!err) {
-		*path = nd->path;
-		nd->path.mnt = NULL;
-		nd->path.dentry = NULL;
-		follow_mount(path);
-	}
-	terminate_walk(nd);
-	return err;
-}
-
-static int
-filename_mountpoint(int dfd, struct filename *name, struct path *path,
-			unsigned int flags)
-{
-	struct nameidata nd;
-	int error;
-	if (IS_ERR(name))
-		return PTR_ERR(name);
-	set_nameidata(&nd, dfd, name);
-	error = path_mountpoint(&nd, flags | LOOKUP_RCU, path);
-	if (unlikely(error == -ECHILD))
-		error = path_mountpoint(&nd, flags, path);
-	if (unlikely(error == -ESTALE))
-		error = path_mountpoint(&nd, flags | LOOKUP_REVAL, path);
-	if (likely(!error))
-		audit_inode(name, path->dentry, 0);
-	restore_nameidata();
-	putname(name);
-	return error;
-}
-
-int
-kern_path_mountpoint(int dfd, const char *name, struct path *path,
-			unsigned int flags)
-{
-	return filename_mountpoint(dfd, getname_kernel(name), path, flags);
-}
-EXPORT_SYMBOL(kern_path_mountpoint);
-
 int __check_sticky(struct inode *dir, struct inode *inode)
 {
 	kuid_t fsuid = current_fsuid();
diff --git a/include/linux/namei.h b/include/linux/namei.h
index a982bb7cd480..e576bf40d761 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -79,7 +79,6 @@ extern struct dentry *kern_path_create(int, const char *, struct path *, unsigne
 extern struct dentry *user_path_create(int, const char __user *, struct path *, unsigned int);
 extern void done_path_create(struct path *, struct dentry *);
 extern struct dentry *kern_path_locked(const char *, struct path *);
-extern int kern_path_mountpoint(int, const char *, struct path *, unsigned int);
 
 extern struct dentry *lookup_one_len(const char *, struct dentry *, int);
 extern struct dentry *lookup_one_len_unlocked(const char *, struct dentry *, int);


