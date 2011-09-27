Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:37724
	"HELO p3plsmtps2ded02-02.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751727Ab1I0NlW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 09:41:22 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: [PATCH 1/2] VFS: Fix the remaining automounter semantics regressions
Date: Tue, 27 Sep 2011 09:34:31 -0400
Message-Id: <1317130472-7790-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
References: <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The concensus seems to be that system calls such as stat() etc should not
trigger an automount. Neither should the l* versions.

This patch therefore adds a LOOKUP_AUTOMOUNT flag to tag those lookups that
don't currently trigger an automount on the last path element but that
should.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/namei.c            |    8 +-------
 fs/namespace.c        |    2 +-
 fs/nfs/super.c        |    4 ++--
 fs/quota/quota.c      |    3 ++-
 fs/stat.c             |    2 --
 include/linux/namei.h |    2 +-
 6 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index f478836..c076492 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -721,12 +721,6 @@ static int follow_automount(struct path *path, unsigned flags,
 	if (!path->dentry->d_op || !path->dentry->d_op->d_automount)
 		return -EREMOTE;
 
-	/* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
-	 * and this is the terminal part of the path.
-	 */
-	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
-		return -EISDIR; /* we actually want to stop here */
-
 	/* We don't want to mount if someone's just doing a stat -
 	 * unless they're stat'ing a directory and appended a '/' to
 	 * the name.
@@ -738,7 +732,7 @@ static int follow_automount(struct path *path, unsigned flags,
 	 * as being automount points.  These will need the attentions
 	 * of the daemon to instantiate them before they can be used.
 	 */
-	if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
+	if (!(flags & (LOOKUP_AUTOMOUNT | LOOKUP_PARENT | LOOKUP_DIRECTORY |
 		     LOOKUP_OPEN | LOOKUP_CREATE)) &&
 	    path->dentry->d_inode)
 		return -EISDIR;
diff --git a/fs/namespace.c b/fs/namespace.c
index 22bfe82..b4febb2 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1757,7 +1757,7 @@ static int do_loopback(struct path *path, char *old_name,
 		return err;
 	if (!old_name || !*old_name)
 		return -EINVAL;
-	err = kern_path(old_name, LOOKUP_FOLLOW, &old_path);
+	err = kern_path(old_name, LOOKUP_FOLLOW|LOOKUP_AUTOMOUNT, &old_path);
 	if (err)
 		return err;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9b7dd70..8aa6968 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2797,8 +2797,8 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	if (ret != 0)
 		goto out_put_mnt_ns;
 
-	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt,
-			export_path, LOOKUP_FOLLOW, &path);
+	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt, export_path,
+			LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
 
 	nfs_referral_loop_unprotect();
 	put_mnt_ns(ns_private);
diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index b34bdb2..9ea9fce 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -355,7 +355,8 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const char __user *, special,
 	 * resolution (think about autofs) and thus deadlocks could arise.
 	 */
 	if (cmds == Q_QUOTAON) {
-		ret = user_path_at(AT_FDCWD, addr, LOOKUP_FOLLOW, &path);
+		ret = user_path_at(AT_FDCWD, addr, LOOKUP_FOLLOW |
+				LOOKUP_AUTOMOUNT, &path);
 		if (ret)
 			pathp = ERR_PTR(ret);
 		else
diff --git a/fs/stat.c b/fs/stat.c
index ba5316f..78a3aa8 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -81,8 +81,6 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 
 	if (!(flag & AT_SYMLINK_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
-	if (flag & AT_NO_AUTOMOUNT)
-		lookup_flags |= LOOKUP_NO_AUTOMOUNT;
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 76fe2c6..bfcd2e0 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -52,7 +52,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_PARENT		0x0010
 #define LOOKUP_REVAL		0x0020
 #define LOOKUP_RCU		0x0040
-#define LOOKUP_NO_AUTOMOUNT	0x0080
+#define LOOKUP_AUTOMOUNT	0x0080
 /*
  * Intent data
  */
-- 
1.7.6.2

