Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055Ab0GVR7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:59:19 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/6] Add an AT_NO_AUTOMOUNT flag to suppress terminal automount
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>
Date: Thu, 22 Jul 2010 18:59:13 +0100
Message-ID: <20100722175913.5552.3905.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
References: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add an AT_NO_AUTOMOUNT flag to suppress terminal automounting of directories
with follow_link semantics.  This can be used by fstatat()/xstat() users to
permit the gathering of attributes on an automount point and also prevent
mass-automounting of a directory of automount points by ls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c            |   15 ++++++++++-----
 fs/stat.c             |    4 +++-
 include/linux/fcntl.h |    1 +
 include/linux/namei.h |    2 ++
 4 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 86068a2..056427e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -654,7 +654,8 @@ static int follow_automount(struct path *path, int res)
 /* no need for dcache_lock, as serialization is taken care in
  * namespace.c
  */
-static int __follow_mount(struct path *path, unsigned nofollow)
+static int __follow_mount(struct path *path, unsigned nofollow,
+			  struct nameidata *nd)
 {
 	struct vfsmount *mounted;
 	int ret, res = 0;
@@ -674,8 +675,12 @@ static int __follow_mount(struct path *path, unsigned nofollow)
 		}
 		if (!d_automount_point(path->dentry))
 			break;
-		if (nofollow)
-			return -ELOOP;
+		if (!(nd->flags & LOOKUP_CONTINUE)) {
+			if (nofollow)
+				return -ELOOP;
+			if (nd->flags & LOOKUP_NO_AUTOMOUNT)
+				break;
+		}
 		ret = follow_automount(path, res);
 		if (ret < 0)
 			return ret;
@@ -769,7 +774,7 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
 done:
 	path->mnt = mnt;
 	path->dentry = dentry;
-	ret = __follow_mount(path, 0);
+	ret = __follow_mount(path, 0, nd);
 	if (unlikely(ret < 0))
 		path_put(path);
 	return ret;
@@ -1762,7 +1767,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	if (open_flag & O_EXCL)
 		goto exit_dput;
 
-	error = __follow_mount(path, open_flag & O_NOFOLLOW);
+	error = __follow_mount(path, open_flag & O_NOFOLLOW, nd);
 	if (error < 0)
 		goto exit_dput;
 
diff --git a/fs/stat.c b/fs/stat.c
index c4ecd52..e4662de 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -74,11 +74,13 @@ int vfs_fstatat(int dfd, char __user *filename, struct kstat *stat, int flag)
 	int error = -EINVAL;
 	int lookup_flags = 0;
 
-	if ((flag & ~AT_SYMLINK_NOFOLLOW) != 0)
+	if ((flag & ~AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT) != 0)
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

