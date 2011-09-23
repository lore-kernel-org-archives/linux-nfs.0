Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab1IWQ0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:26:40 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/7] VFS: Make stat and xattr calls not automount
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:25:53 +0100
Message-ID: <20110923162553.13574.77501.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make stat() and get/set/list/removexattr calls not automount so that the
autofs behaviour remains the same.  This causes NFS, AFS and CIFS automounting
behaviour to change, however.

To vary the behaviour follow_automount() needs to know when it is mounting for
autofs and when the aforementioned calls are the ones being processed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/stat.c  |    7 ++++---
 fs/xattr.c |    8 ++++----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index 305aa10..7fa96a1 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -80,7 +80,7 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW |
 		      AT_EMPTY_PATH)) != 0)
 		goto out;
-	lookup_flags = at_to_lookup_flags(flag, LOOKUP_FOLLOW_ALL);
+	lookup_flags = at_to_lookup_flags(flag, LOOKUP_FOLLOW);
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
@@ -95,13 +95,14 @@ EXPORT_SYMBOL(vfs_fstatat);
 
 int vfs_stat(const char __user *name, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, 0);
+	return vfs_fstatat(AT_FDCWD, name, stat, AT_NO_AUTOMOUNT);
 }
 EXPORT_SYMBOL(vfs_stat);
 
 int vfs_lstat(const char __user *name, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
+	return vfs_fstatat(AT_FDCWD, name, stat,
+			   AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT);
 }
 EXPORT_SYMBOL(vfs_lstat);
 
diff --git a/fs/xattr.c b/fs/xattr.c
index 4921010..bb9d5be 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -290,7 +290,7 @@ SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
@@ -386,7 +386,7 @@ SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
 	struct path path;
 	ssize_t error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
 	error = getxattr(path.dentry, name, value, size);
@@ -459,7 +459,7 @@ SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, list,
 	struct path path;
 	ssize_t error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
 	error = listxattr(path.dentry, list, size);
@@ -519,7 +519,7 @@ SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);

