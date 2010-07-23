From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/6] Add an AT_NO_AUTOMOUNT flag to suppress terminal automount [ver #2]
Date: Fri, 23 Jul 2010 16:11:05 +0100
Message-ID: <17789.1279897865@redhat.com>
References: <20100722175913.5552.3905.stgit@warthog.procyon.org.uk> <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, raven@themaw.net,
	linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <20100722175913.5552.3905.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is an update required because the first patch in the series was also
altered in the same area.

David
---
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Add an AT_NO_AUTOMOUNT flag to suppress terminal automount

Add an AT_NO_AUTOMOUNT flag to suppress terminal automounting of directories
with follow_link semantics.  This can be used by fstatat() users to permit the
gathering of attributes on an automount point and also prevent
mass-automounting of a directory of automount points by ls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c            |    6 ++++++
 fs/stat.c             |    4 +++-
 include/linux/fcntl.h |    1 +
 include/linux/namei.h |    2 ++
 4 files changed, 12 insertions(+), 1 deletions(-)


diff --git a/fs/namei.c b/fs/namei.c
index f2910b7..c154112 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -629,6 +629,12 @@ static int follow_automount(struct path *path, unsigned flags, int res)
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
index c4ecd52..bae6fa2 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -74,11 +74,13 @@ int vfs_fstatat(int dfd, char __user *filename, struct kstat *stat, int flag)
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
