From: David Howells <dhowells@redhat.com>
Subject: [PATCH 17/18] xstat: Add an AT_NO_AUTOMOUNT flag to suppress terminal
	automount [ver #6]
Date: Thu, 15 Jul 2010 03:17:29 +0100
Message-ID: <20100715021729.5544.56390.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index bb0f538..3f2ab5f 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -182,11 +182,13 @@ int vfs_xstat(int dfd, const char __user *filename, int flags,
 	struct path path;
 	int error, lookup_flags;
 
-	if (flags & ~(AT_SYMLINK_NOFOLLOW | KSTAT_QUERY_FLAGS))
+	if (flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
+		      KSTAT_QUERY_FLAGS))
 		return -EINVAL;
 
 	stat->query_flags = flags & KSTAT_QUERY_FLAGS;
 	lookup_flags = (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	lookup_flags |= (flags & AT_NO_AUTOMOUNT) ? LOOKUP_NO_AUTOMOUNT : 0;
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (!error) {
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index bcf8083..768b0fd 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -46,6 +46,7 @@
                                            unlinking file.  */
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
 #define AT_FORCE_ATTR_SYNC	0x800	/* Force the attributes to be sync'd with the server */
+#define AT_NO_AUTOMOUNT		0x1000	/* Suppress terminal automount traversal */
 
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

