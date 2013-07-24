Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843Ab3GXLXv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 07:23:51 -0400
Date: Wed, 24 Jul 2013 07:24:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Funk <pf@artcom-gmbh.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not
 available?
Message-ID: <20130724072421.11ed2043@corrin.poochiereds.net>
In-Reply-To: <20130724091856.GA30866@pfmaster>
References: <20130724091856.GA30866@pfmaster>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 24 Jul 2013 11:18:58 +0200
Peter Funk <pf@artcom-gmbh.de> wrote:

> Hello all,
> 
> We've researched this question for quite a while now and nobody here
> found a solution to the following problem:
> 
>  1: A Linux computer is NFS client of some other Linux NFS server
>     and has some active mounts and some processes working with files 
>     on that NFS server.  
> 
>  2: Now the NFS server becomes unavailable and a system administrator 
>     wants to clean up the situation on the NFS client computer without 
>     having to reboot this client computer.
> 
> Is this possible?  And if how exactly?
> 
> Best Regards and many thanks in advance, 
> Peter Funk
> P.S.: umount -f -l did not work  
>       System hangs for a long time in shutdown and shutdown 
>       only succeeds without hard reset after reconnecting the
>       NFS server.

The problem is likely that the lookup phase in the umount() syscall is
trying to revalidate the root of the mount. Since that server is down,
it's getting stuck.

Does this patch help at all? I'm hoping to get this into 3.12, and some
extra confirmation that it works would be helpful. It mentions about
the mount being stale, but it may also help the situation where it's
unavailable:

-----------------------[snip]-------------------------------

[PATCH] vfs: allow umount to handle mountpoints without revalidating them

Christopher reported a regression where he was unable to unmount a NFS
filesystem where the root had gone stale. The problem is that
d_revalidate handles the root of the filesystem differently from other
dentries, but d_weak_revalidate does not. We could simply fix this by
making d_weak_revalidate return success on IS_ROOT dentries, but there
are cases where we do want to revalidate the root of the fs.

A umount is really a special case. We generally aren't interested in
anything but the dentry and vfsmount that's attached at that point. If
the inode turns out to be stale we just don't care since the intent is
to stop using it anyway.

Try to handle this situation better by treating umount as a special
case in the lookup code. Have it resolve the parent using normal
means, and then do a lookup of the final dentry without revalidating
it. In most cases, the final lookup will come out of the dcache, but
the case where there's a trailing symlink or !LAST_NORM entry on the
end complicates things a bit.

Cc: Neil Brown <neilb@suse.de>
Reported-by: Christopher T Vogan <cvogan@us.ibm.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c            | 182 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/namespace.c        |   2 +-
 include/linux/namei.h |   1 +
 3 files changed, 184 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 8b61d10..d9f65bd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2184,6 +2184,188 @@ user_path_parent(int dfd, const char __user *path, struct nameidata *nd,
 	return s;
 }
 
+/**
+ * umount_lookup_last - look up last component for umount
+ * @nd:   pathwalk nameidata - currently pointing at parent directory of "last"
+ * @path: pointer to container for result
+ *
+ * This is a special lookup_last function just for umount. In this case, we
+ * need to resolve the path without doing any revalidation.
+ *
+ * The nameidata should be the result of doing a LOOKUP_PARENT pathwalk. Since
+ * mountpoints are always pinned in the dcache, their ancestors are too. Thus,
+ * in almost all cases, this lookup will be served out of the dcache. The only
+ * cases where it won't are if nd->last refers to a symlink or the path is
+ * bogus and it doesn't exist.
+ *
+ * Returns:
+ * -error: if there was an error during lookup. This includes -ENOENT if the
+ *         lookup found a negative dentry. The nd->path reference will also be
+ *         put in this case.
+ *
+ * 0:      if we successfully resolved nd->path and found it to not to be a
+ *         symlink that needs to be followed. "path" will also be populated.
+ *         The nd->path reference will also be put.
+ *
+ * 1:      if we successfully resolved nd->last and found it to be a symlink
+ *         that needs to be followed. "path" will be populated with the path
+ *         to the link, and nd->path will *not* be put.
+ */
+static int
+umount_lookup_last(struct nameidata *nd, struct path *path)
+{
+	int error = 0;
+	struct dentry *dentry;
+	struct dentry *dir = nd->path.dentry;
+
+	if (unlikely(nd->flags & LOOKUP_RCU)) {
+		WARN_ON_ONCE(1);
+		error = -ECHILD;
+		goto error_check;
+	}
+
+	nd->flags &= ~LOOKUP_PARENT;
+
+	if (unlikely(nd->last_type != LAST_NORM)) {
+		error = handle_dots(nd, nd->last_type);
+		if (!error)
+			dentry = dget(nd->path.dentry);
+		goto error_check;
+	}
+
+	mutex_lock(&dir->d_inode->i_mutex);
+	dentry = d_lookup(dir, &nd->last);
+	if (!dentry) {
+		/*
+		 * No cached dentry. Mounted dentries are pinned in the cache,
+		 * so that means that this dentry is probably a symlink or the
+		 * path doesn't actually point to a mounted dentry.
+		 */
+		dentry = d_alloc(dir, &nd->last);
+		if (!dentry) {
+			error = -ENOMEM;
+		} else {
+			dentry = lookup_real(dir->d_inode, dentry, nd->flags);
+			if (IS_ERR(dentry))
+				error = PTR_ERR(dentry);
+		}
+	}
+	mutex_unlock(&dir->d_inode->i_mutex);
+
+error_check:
+	if (!error) {
+		if (!dentry->d_inode) {
+			error = -ENOENT;
+			dput(dentry);
+		} else {
+			path->dentry = dentry;
+			path->mnt = mntget(nd->path.mnt);
+			if (should_follow_link(dentry->d_inode,
+						nd->flags & LOOKUP_FOLLOW))
+				return 1;
+			follow_mount(path);
+		}
+	}
+	terminate_walk(nd);
+	return error;
+}
+
+/**
+ * path_umountat - look up a path to be umounted
+ * @dfd:	directory file descriptor to start walk from
+ * @name:	full pathname to walk
+ * @flags:	lookup flags
+ * @nd:		pathwalk nameidata
+ *
+ * Look up the given name, but don't attempt to revalidate the last component.
+ * Returns 0 and "path" will be valid on success; Retuns error otherwise.
+ */
+static int
+path_umountat(int dfd, const char *name, struct path *path, unsigned int flags)
+{
+	struct file *base = NULL;
+	struct nameidata nd;
+	int err;
+
+	err = path_init(dfd, name, flags | LOOKUP_PARENT, &nd, &base);
+	if (unlikely(err))
+		return err;
+
+	current->total_link_count = 0;
+	err = link_path_walk(name, &nd);
+	if (err)
+		goto out;
+
+	/* If we're in rcuwalk, drop out of it to handle last component */
+	if (nd.flags & LOOKUP_RCU) {
+		err = unlazy_walk(&nd, NULL);
+		if (err) {
+			terminate_walk(&nd);
+			goto out;
+		}
+	}
+
+	err = umount_lookup_last(&nd, path);
+	while (err > 0) {
+		void *cookie;
+		struct path link = *path;
+		err = may_follow_link(&link, &nd);
+		if (unlikely(err))
+			break;
+		nd.flags |= LOOKUP_PARENT;
+		err = follow_link(&link, &nd, &cookie);
+		if (err)
+			break;
+		err = umount_lookup_last(&nd, path);
+		put_link(&nd, &link, cookie);
+	}
+out:
+	if (base)
+		fput(base);
+
+	if (nd.root.mnt && !(nd.flags & LOOKUP_ROOT))
+		path_put(&nd.root);
+
+	return err;
+}
+
+/**
+ * user_path_umountat - lookup a path from userland in order to umount it
+ * @dfd:	directory file descriptor
+ * @name:	pathname from userland
+ * @flags:	lookup flags
+ * @path:	pointer to container to hold result
+ *
+ * A umount is a special case for path walking. We're not actually interested
+ * in the inode in this situation, and ESTALE errors can be a problem. We
+ * simply want track down the dentry and vfsmount attached at the mountpoint
+ * and avoid revalidating the last component.
+ *
+ * Returns 0 and populates "path" on success.
+ */
+int
+user_path_umountat(int dfd, const char __user *name, unsigned int flags,
+			struct path *path)
+{
+	struct filename *s = getname(name);
+	int error;
+
+	if (IS_ERR(s))
+		return PTR_ERR(s);
+
+	error = path_umountat(dfd, s->name, path, flags | LOOKUP_RCU);
+	if (unlikely(error == -ECHILD))
+		error = path_umountat(dfd, s->name, path, flags);
+	if (unlikely(error == -ESTALE))
+		error = path_umountat(dfd, s->name, path, flags | LOOKUP_REVAL);
+
+	if (likely(!error))
+		audit_inode(s, path->dentry, 0);
+
+	putname(s);
+	return error;
+}
+
 /*
  * It's inline, so penalty for filesystems that don't use sticky bit is
  * minimal.
diff --git a/fs/namespace.c b/fs/namespace.c
index 7b1ca9b..5d2676a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1318,7 +1318,7 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
 	if (!(flags & UMOUNT_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
 
-	retval = user_path_at(AT_FDCWD, name, lookup_flags, &path);
+	retval = user_path_umountat(AT_FDCWD, name, lookup_flags, &path);
 	if (retval)
 		goto out;
 	mnt = real_mount(path.mnt);
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 5a5ff57..cd09751 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -58,6 +58,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
+extern int user_path_umountat(int, const char __user *, unsigned int, struct path *);
 
 #define user_path(name, path) user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW, path)
 #define user_lpath(name, path) user_path_at(AT_FDCWD, name, 0, path)
-- 
1.8.3.1

