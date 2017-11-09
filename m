Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49058 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753085AbdKIHvD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 02:51:03 -0500
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>,
        Jeff Layton <jlayton@redhat.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 09 Nov 2017 18:20:24 +1100
Subject: [PATCH 2/3] VFS: remove user_path_mountpoint_at()
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Message-ID: <151021202424.22743.15152208623289288317.stgit@noble>
In-Reply-To: <151021179901.22743.15252956909042161062.stgit@noble>
References: <151021179901.22743.15252956909042161062.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that d_weak_revalidate doesn't revalidate the inode (unless
LOOKUP_OPEN is set), we don't need any extra care when umounting.
A simple user_path_at() will find the desired dentry without
performing any access on the mounted filesystems.
So we don't need user_path_mountpoint_at().

By switching to user_path_at(), there are other changes than just the
d_weak_revalidate() change.
- We no longer use LOOKUP_NO_REVAL on the last component, in the
  unlikely case that d_lookup() failed.  It is hard to see why
  this is relevant.  Most likely if d_lookup() failed we will
  have called i_op->lookup, which is at least as much of a problem
  as d_revalidate() might be.
- we now call follow_managed() on the final dentry.  This cannot
  trigger an automount, due to the flags used, but might call
  ->d_manage().  There is no reason to expect that this might
  cause problems.

So we can safely switch to user_path_at() and discard
user_path_mountpoint_at().

kern_path_mountpoint() is still in use by autofs, and so cannot go
just yet.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/internal.h  |    1 -
 fs/namei.c     |   21 ---------------------
 fs/namespace.c |    2 +-
 3 files changed, 1 insertion(+), 23 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 48cee21b4f14..d1228af28761 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -52,7 +52,6 @@ extern void __init chrdev_init(void);
 /*
  * namei.c
  */
-extern int user_path_mountpoint_at(int, const char __user *, unsigned int, struct path *);
 extern int vfs_path_lookup(struct dentry *, struct vfsmount *,
 			   const char *, unsigned int, struct path *);
 
diff --git a/fs/namei.c b/fs/namei.c
index ed8b9488a890..6639203d7eba 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2722,27 +2722,6 @@ filename_mountpoint(int dfd, struct filename *name, struct path *path,
 	return error;
 }
 
-/**
- * user_path_mountpoint_at - lookup a path from userland in order to umount it
- * @dfd:	directory file descriptor
- * @name:	pathname from userland
- * @flags:	lookup flags
- * @path:	pointer to container to hold result
- *
- * A umount is a special case for path walking. We're not actually interested
- * in the inode in this situation, and ESTALE errors can be a problem. We
- * simply want track down the dentry and vfsmount attached at the mountpoint
- * and avoid revalidating the last component.
- *
- * Returns 0 and populates "path" on success.
- */
-int
-user_path_mountpoint_at(int dfd, const char __user *name, unsigned int flags,
-			struct path *path)
-{
-	return filename_mountpoint(dfd, getname(name), path, flags);
-}
-
 int
 kern_path_mountpoint(int dfd, const char *name, struct path *path,
 			unsigned int flags)
diff --git a/fs/namespace.c b/fs/namespace.c
index 23cdf6c62895..6de22f658359 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1696,7 +1696,7 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
 	if (!(flags & UMOUNT_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
 
-	retval = user_path_mountpoint_at(AT_FDCWD, name, lookup_flags, &path);
+	retval = user_path_at(AT_FDCWD, name, lookup_flags, &path);
 	if (retval)
 		goto out;
 	mnt = real_mount(path.mnt);


