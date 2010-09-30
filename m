Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755299Ab0I3SP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:15:58 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/17] Add an AT_NO_AUTOMOUNT flag to suppress terminal
	automount
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Ian Kent <raven@themaw.net>
Date: Thu, 30 Sep 2010 19:15:26 +0100
Message-ID: <20100930181526.30939.22704.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add an AT_NO_AUTOMOUNT flag to suppress terminal automounting of directories
with follow_link semantics.  This can be used by fstatat() users to permit the
gathering of attributes on an automount point and also prevent
mass-automounting of a directory of automount points by ls.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Ian Kent <raven@themaw.net>
---

 fs/namei.c            |    6 ++++++
 fs/stat.c             |    4 +++-
 include/linux/fcntl.h |    1 +
 include/linux/namei.h |    2 ++
 4 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 86421f9..74bce3a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -625,6 +625,12 @@ static int follow_automount(struct path *path, unsigned flags,
 	if (!path->dentry->d_op || !path->dentry->d_op->d_automount)
 		return -EREMOTE;
 
+	/* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
+	 * and this is the terminal part of the path.
+	 */
+	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_CONTINUE))
+		return -EXDEV; /* we actually want to stop here */
+
 	/* We want to mount if someone is trying to open/create a file of any
 	 * type under the mountpoint, wants to traverse through the mountpoint
 	 * or wants to open the mounted directory.
diff --git a/fs/stat.c b/fs/stat.c
index 12e90e2..d5c61cf 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -75,11 +75,13 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	int error = -EINVAL;
 	int lookup_flags = 0;
 
-	if ((flag & ~AT_SYMLINK_NOFOLLOW) != 0)
+	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT)) != 0)
 		goto out;
 
 	if (!(flag & AT_SYMLINK_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
+	if (flag & AT_NO_AUTOMOUNT)
+		lookup_flags |= LOOKUP_NO_AUTOMOUNT;
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index afc00af..a562fa5 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -45,6 +45,7 @@
 #define AT_REMOVEDIR		0x200   /* Remove directory instead of
                                            unlinking file.  */
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
+#define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 05b441d..1e1febf 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -43,12 +43,14 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
  *  - internal "there are more path components" flag
  *  - locked when lookup done with dcache_lock held
  *  - dentry cache is untrusted; force a real lookup
+ *  - suppress terminal automount
  */
 #define LOOKUP_FOLLOW		 1
 #define LOOKUP_DIRECTORY	 2
 #define LOOKUP_CONTINUE		 4
 #define LOOKUP_PARENT		16
 #define LOOKUP_REVAL		64
+#define LOOKUP_NO_AUTOMOUNT	128
 /*
  * Intent data
  */

