Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:47663
	"HELO p3plsmtps2ded03-02.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751727Ab1I0NlX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 09:41:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: [PATCH 2/2] VFS: Document automounter semantics
Date: Tue, 27 Sep 2011 09:34:32 -0400
Message-Id: <1317130472-7790-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1317130472-7790-1-git-send-email-Trond.Myklebust@netapp.com>
References: <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
 <1317130472-7790-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add LOOKUP_AUTOMOUNT flags to all the lookups that _should_ trigger
an automount on the last path element.
IOW: Set it for all cases where we currently have the LOOKUP_OPEN,
LOOKUP_DIRECTORY or LOOKUP_CREATE flags set.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/cachefiles/bind.c               |    3 ++-
 fs/configfs/symlink.c              |    3 ++-
 fs/ecryptfs/main.c                 |    3 ++-
 fs/namei.c                         |    8 +++++---
 fs/nfs/super.c                     |    3 ++-
 fs/notify/fanotify/fanotify_user.c |    2 +-
 fs/notify/inotify/inotify_user.c   |    2 +-
 fs/open.c                          |    6 +++---
 include/linux/namei.h              |    3 ++-
 9 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/fs/cachefiles/bind.c b/fs/cachefiles/bind.c
index 622f469..3ccc141 100644
--- a/fs/cachefiles/bind.c
+++ b/fs/cachefiles/bind.c
@@ -114,7 +114,8 @@ static int cachefiles_daemon_add_cache(struct cachefiles_cache *cache)
 	_debug("- fsdef %p", fsdef);
 
 	/* look up the directory at the root of the cache */
-	ret = kern_path(cache->rootdirname, LOOKUP_DIRECTORY, &path);
+	ret = kern_path(cache->rootdirname, LOOKUP_DIRECTORY |
+			LOOKUP_AUTOMOUNT, &path);
 	if (ret < 0)
 		goto error_open_root;
 
diff --git a/fs/configfs/symlink.c b/fs/configfs/symlink.c
index 0f3eb41..5e1e1d4 100644
--- a/fs/configfs/symlink.c
+++ b/fs/configfs/symlink.c
@@ -114,7 +114,8 @@ static int get_target(const char *symname, struct path *path,
 {
 	int ret;
 
-	ret = kern_path(symname, LOOKUP_FOLLOW|LOOKUP_DIRECTORY, path);
+	ret = kern_path(symname, LOOKUP_FOLLOW | LOOKUP_DIRECTORY |
+			LOOKUP_AUTOMOUNT, path);
 	if (!ret) {
 		if (path->dentry->d_sb == configfs_sb) {
 			*target = configfs_get_config_item(path->dentry);
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index b4a6bef..e3de2c8 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -519,7 +519,8 @@ static struct dentry *ecryptfs_mount(struct file_system_type *fs_type, int flags
 	s->s_d_op = &ecryptfs_dops;
 
 	err = "Reading sb failed";
-	rc = kern_path(dev_name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	rc = kern_path(dev_name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY |
+			LOOKUP_AUTOMOUNT, &path);
 	if (rc) {
 		ecryptfs_printk(KERN_WARNING, "kern_path() failed\n");
 		goto out1;
diff --git a/fs/namei.c b/fs/namei.c
index c076492..3db5992 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1564,7 +1564,8 @@ out_fail:
 static inline int lookup_last(struct nameidata *nd, struct path *path)
 {
 	if (nd->last_type == LAST_NORM && nd->last.name[nd->last.len])
-		nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
+		nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY |
+			LOOKUP_AUTOMOUNT;
 
 	nd->flags &= ~LOOKUP_PARENT;
 	return walk_component(nd, path, &nd->last, nd->last_type,
@@ -2116,7 +2117,8 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	if (!(open_flag & O_CREAT)) {
 		int symlink_ok = 0;
 		if (nd->last.name[nd->last.len])
-			nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
+			nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY |
+				LOOKUP_AUTOMOUNT;
 		if (open_flag & O_PATH && !(nd->flags & LOOKUP_FOLLOW))
 			symlink_ok = 1;
 		/* we _can_ be in RCU mode here */
@@ -2376,7 +2378,7 @@ struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path
 	if (nd.last_type != LAST_NORM)
 		goto out;
 	nd.flags &= ~LOOKUP_PARENT;
-	nd.flags |= LOOKUP_CREATE | LOOKUP_EXCL;
+	nd.flags |= LOOKUP_AUTOMOUNT | LOOKUP_CREATE | LOOKUP_EXCL;
 	nd.intent.open.flags = O_EXCL;
 
 	/*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8aa6968..b7f1abd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2798,7 +2798,8 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 		goto out_put_mnt_ns;
 
 	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt, export_path,
-			LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+			LOOKUP_FOLLOW | LOOKUP_DIRECTORY | LOOKUP_AUTOMOUNT,
+			&path);
 
 	nfs_referral_loop_unprotect();
 	put_mnt_ns(ns_private);
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index 9fde1c0..c7c8891 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -496,7 +496,7 @@ static int fanotify_find_path(int dfd, const char __user *filename,
 		if (!(flags & FAN_MARK_DONT_FOLLOW))
 			lookup_flags |= LOOKUP_FOLLOW;
 		if (flags & FAN_MARK_ONLYDIR)
-			lookup_flags |= LOOKUP_DIRECTORY;
+			lookup_flags |= LOOKUP_DIRECTORY | LOOKUP_AUTOMOUNT;
 
 		ret = user_path_at(dfd, filename, lookup_flags, path);
 		if (ret)
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 8445fbc..145395a 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -774,7 +774,7 @@ SYSCALL_DEFINE3(inotify_add_watch, int, fd, const char __user *, pathname,
 	if (!(mask & IN_DONT_FOLLOW))
 		flags |= LOOKUP_FOLLOW;
 	if (mask & IN_ONLYDIR)
-		flags |= LOOKUP_DIRECTORY;
+		flags |= LOOKUP_DIRECTORY | LOOKUP_AUTOMOUNT;
 
 	ret = inotify_find_inode(pathname, &path, flags);
 	if (ret)
diff --git a/fs/open.c b/fs/open.c
index f711921..cc38b85 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -918,16 +918,16 @@ static inline int build_open_flags(int flags, int mode, struct open_flags *op)
 
 	op->acc_mode = acc_mode;
 
-	op->intent = flags & O_PATH ? 0 : LOOKUP_OPEN;
+	op->intent = flags & O_PATH ? 0 : (LOOKUP_OPEN | LOOKUP_AUTOMOUNT);
 
 	if (flags & O_CREAT) {
-		op->intent |= LOOKUP_CREATE;
+		op->intent |= LOOKUP_CREATE|LOOKUP_AUTOMOUNT;
 		if (flags & O_EXCL)
 			op->intent |= LOOKUP_EXCL;
 	}
 
 	if (flags & O_DIRECTORY)
-		lookup_flags |= LOOKUP_DIRECTORY;
+		lookup_flags |= LOOKUP_DIRECTORY | LOOKUP_AUTOMOUNT;
 	if (!(flags & O_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
 	return lookup_flags;
diff --git a/include/linux/namei.h b/include/linux/namei.h
index bfcd2e0..209ba9f 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -70,7 +70,8 @@ extern int user_path_at(int, const char __user *, unsigned, struct path *);
 #define user_path(name, path) user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW, path)
 #define user_lpath(name, path) user_path_at(AT_FDCWD, name, 0, path)
 #define user_path_dir(name, path) \
-	user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, path)
+	user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY | \
+			LOOKUP_AUTOMOUNT, path)
 
 extern int kern_path(const char *, unsigned, struct path *);
 
-- 
1.7.6.2

