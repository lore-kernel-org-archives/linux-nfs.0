Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab1IWQ0w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:26:52 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/7] VFS: Vary the automounting rules for autofs
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:26:06 +0100
Message-ID: <20110923162605.13574.86939.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Allow the behaviour of in-kernel automounting to vary according to whether
we're mounting on autofs or not.

The differences of behaviour concern the fstatat, stat, getxattr, setxattr,
listxattr and removexattr system calls.  Prior to the d_automount changes
being applied, these caused automounting for NFS, AFS and CIFS automount
points, but not for autofs mountpounts.

After the d_automount changes they caused automounting unconditionally because
LOOKUP_FOLLOW was set.

With the application of a later patch from Miklos Szeredi to revert the
behaviour of autofs to the original, these no longer cause a mountpoint to
automount.

Reinstate the pre-d_automount behaviour.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/internal.h         |   17 ++++++++++++-----
 fs/namei.c            |    7 +++++--
 fs/stat.c             |    3 ++-
 fs/xattr.c            |   16 ++++++++++++----
 include/linux/namei.h |    1 +
 5 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 11664f5..b54c5e6 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -24,11 +24,18 @@ struct path;
  */
 static inline int at_to_lookup_flags(int flag, int lookup_flags)
 {
-	if (flag & AT_SYMLINK_NOFOLLOW)	lookup_flags &= ~LOOKUP_FOLLOW_ALL;
-	if (flag & AT_SYMLINK_FOLLOW)	lookup_flags |= LOOKUP_FOLLOW_ALL;
-	if (flag & AT_NO_AUTOMOUNT)	lookup_flags &= ~LOOKUP_AUTOMOUNT;
-	if (flag & AT_AUTOMOUNT_FOLLOW)	lookup_flags |= LOOKUP_AUTOMOUNT;
-	if (flag & AT_EMPTY_PATH)	lookup_flags |= LOOKUP_EMPTY;
+	if (flag & AT_SYMLINK_NOFOLLOW)
+		lookup_flags &= ~(LOOKUP_FOLLOW_ALL | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS);
+	if (flag & AT_SYMLINK_FOLLOW)
+		lookup_flags |= LOOKUP_FOLLOW_ALL;
+	if (flag & AT_NO_AUTOMOUNT)
+		lookup_flags &= ~(LOOKUP_AUTOMOUNT | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS);
+	if (flag & AT_AUTOMOUNT_FOLLOW)	{
+		lookup_flags |= LOOKUP_AUTOMOUNT;
+		lookup_flags &= ~LOOKUP_AUTOMOUNT_UNLESS_AUTOFS;
+	}
+	if (flag & AT_EMPTY_PATH)
+		lookup_flags |= LOOKUP_EMPTY;
 
 	return lookup_flags;
 }
diff --git a/fs/namei.c b/fs/namei.c
index 89e3dc3..3b1da48 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -724,8 +724,11 @@ static int follow_automount(struct path *path, unsigned flags,
 	/* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
 	 * and this is the terminal part of the path.
 	 */
-	if (!(flags & LOOKUP_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
-		return -EISDIR; /* we actually want to stop here */
+	if (!(flags & LOOKUP_AUTOMOUNT) && !(flags & LOOKUP_PARENT)) {
+		if (!(flags & LOOKUP_AUTOMOUNT_UNLESS_AUTOFS) ||
+		    strcmp(path->dentry->d_sb->s_type->name, "autofs") == 0)
+			return -EISDIR; /* we actually want to stop here */
+	}
 
 	current->total_link_count++;
 	if (current->total_link_count >= 40)
diff --git a/fs/stat.c b/fs/stat.c
index 7fa96a1..f7e9abb 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -80,7 +80,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW |
 		      AT_EMPTY_PATH)) != 0)
 		goto out;
-	lookup_flags = at_to_lookup_flags(flag, LOOKUP_FOLLOW);
+	lookup_flags = at_to_lookup_flags(
+		flag, LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS);
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
diff --git a/fs/xattr.c b/fs/xattr.c
index bb9d5be..7a85b9a 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -290,7 +290,9 @@ SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
+	error = user_path_at(AT_FDCWD, pathname,
+			     LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS,
+			     &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
@@ -386,7 +388,9 @@ SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
 	struct path path;
 	ssize_t error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
+	error = user_path_at(AT_FDCWD, pathname,
+			     LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS,
+			     &path);
 	if (error)
 		return error;
 	error = getxattr(path.dentry, name, value, size);
@@ -459,7 +463,9 @@ SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, list,
 	struct path path;
 	ssize_t error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
+	error = user_path_at(AT_FDCWD, pathname,
+			     LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS,
+			     &path);
 	if (error)
 		return error;
 	error = listxattr(path.dentry, list, size);
@@ -519,7 +525,9 @@ SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
+	error = user_path_at(AT_FDCWD, pathname,
+			     LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT_UNLESS_AUTOFS,
+			     &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 86d6993..e1b03a0 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -65,6 +65,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_JUMPED		0x1000
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
+#define LOOKUP_AUTOMOUNT_UNLESS_AUTOFS	0x8000
 
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 

