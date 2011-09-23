Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab1IWQZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:25:51 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/7] VFS: Make chown() and lchown() call fchownat()
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:25:04 +0100
Message-ID: <20110923162503.13574.38791.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make the chown() and lchown() syscalls jump to the fchownat() syscall with the
appropriate extra arguments.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/open.c |   40 ++++++----------------------------------
 1 files changed, 6 insertions(+), 34 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index f711921..6d6cd90 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -527,25 +527,6 @@ static int chown_common(struct path *path, uid_t user, gid_t group)
 	return error;
 }
 
-SYSCALL_DEFINE3(chown, const char __user *, filename, uid_t, user, gid_t, group)
-{
-	struct path path;
-	int error;
-
-	error = user_path(filename, &path);
-	if (error)
-		goto out;
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_release;
-	error = chown_common(&path, user, group);
-	mnt_drop_write(path.mnt);
-out_release:
-	path_put(&path);
-out:
-	return error;
-}
-
 SYSCALL_DEFINE5(fchownat, int, dfd, const char __user *, filename, uid_t, user,
 		gid_t, group, int, flag)
 {
@@ -573,23 +554,14 @@ out:
 	return error;
 }
 
-SYSCALL_DEFINE3(lchown, const char __user *, filename, uid_t, user, gid_t, group)
+SYSCALL_DEFINE3(chown, const char __user *, filename, uid_t, user, gid_t, group)
 {
-	struct path path;
-	int error;
+	return fchownat(AT_FDCWD, filename, user, group, 0);
+}
 
-	error = user_lpath(filename, &path);
-	if (error)
-		goto out;
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_release;
-	error = chown_common(&path, user, group);
-	mnt_drop_write(path.mnt);
-out_release:
-	path_put(&path);
-out:
-	return error;
+SYSCALL_DEFINE3(lchown, const char __user *, filename, uid_t, user, gid_t, group)
+{
+	return fchownat(AT_FDCWD, filename, user, group, AT_SYMLINK_NOFOLLOW);
 }
 
 SYSCALL_DEFINE3(fchown, unsigned int, fd, uid_t, user, gid_t, group)

