From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH 1/3] enhanced lookup ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 16:23:33 -0400
Message-ID: <47D598C5.7080609@redhat.com>
References: <4790C761.1010603@redhat.com> <47A387CF.70201@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010507020900030509040003"
Cc: linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbYCJUYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 16:24:12 -0400
In-Reply-To: <47A387CF.70201@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010507020900030509040003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

This is a patch to enhance ESTALE error handling during the
lookup process.  The error, ESTALE, can occur when out of data
dentries, stored in the dcache, is used to translate a pathname
component to a dentry.  When this occurs, the dentry which
contains the pointer to the inode which refers to the non-existent
file is dropped from the dcache and then the lookup process
started again.  Care is taken to ensure that forward process is
always being made.  If forward process is not detected, then the
lookup process is terminated and the error, ENOENT, is returned
to the caller.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------010507020900030509040003
Content-Type: text/plain;
 name="estale.lookup.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="estale.lookup.3"

--- linux-2.6.24.i686/fs/namei.c.org
+++ linux-2.6.24.i686/fs/namei.c
@@ -750,7 +750,7 @@ static __always_inline void follow_dotdo
 {
 	struct fs_struct *fs = current->fs;
 
-	while(1) {
+	while (1) {
 		struct vfsmount *parent;
 		struct dentry *old = nd->path.dentry;
 
@@ -849,7 +849,7 @@ static int __link_path_walk(const char *
 		lookup_flags = LOOKUP_FOLLOW | (nd->flags & LOOKUP_CONTINUE);
 
 	/* At this point we know we have a real path component. */
-	for(;;) {
+	for (;;) {
 		unsigned long hash;
 		struct qstr this;
 		unsigned int c;
@@ -1003,7 +1003,7 @@ return_reval:
 		 */
 		if (nd->path.dentry && nd->path.dentry->d_sb &&
 		    (nd->path.dentry->d_sb->s_type->fs_flags & FS_REVAL_DOT)) {
-			err = -ESTALE;
+			err = -ENOENT;
 			/* Note: we do not d_invalidate() */
 			if (!nd->path.dentry->d_op->d_revalidate(
 					nd->path.dentry, nd))
@@ -1015,6 +1015,8 @@ out_dput:
 		path_put_conditional(&next, nd);
 		break;
 	}
+	if (err == -ESTALE)
+		d_drop(nd->path.dentry);
 	path_put(&nd->path);
 return_err:
 	return err;
@@ -1031,13 +1033,24 @@ static int link_path_walk(const char *na
 {
 	struct nameidata save = *nd;
 	int result;
+	struct dentry *svd;
 
 	/* make sure the stuff we saved doesn't go away */
 	dget(save.path.dentry);
 	mntget(save.path.mnt);
 
+	svd = nd->path.dentry;
 	result = __link_path_walk(name, nd);
-	if (result == -ESTALE) {
+	while (result == -ESTALE) {
+		/*
+		 * If no progress was made looking up the pathname,
+		 * then stop and return ENOENT instead of ESTALE.
+		 */
+		if (nd->path.dentry == svd) {
+			result = -ENOENT;
+			break;
+		}
+		svd = nd->path.dentry;
 		*nd = save;
 		dget(nd->path.dentry);
 		mntget(nd->path.mnt);
@@ -1714,7 +1727,10 @@ int open_namei(int dfd, const char *path
 	int acc_mode, error;
 	struct path path;
 	struct dentry *dir;
-	int count = 0;
+	int count;
+
+top:
+	count = 0;
 
 	acc_mode = ACC_MODE(flag);
 
@@ -1741,7 +1757,8 @@ int open_namei(int dfd, const char *path
 	/*
 	 * Create - we need to know the parent.
 	 */
-	error = path_lookup_create(dfd,pathname,LOOKUP_PARENT,nd,flag,mode);
+	error = path_lookup_create(dfd, pathname, LOOKUP_PARENT, nd,
+				flag, mode);
 	if (error)
 		return error;
 
@@ -1814,10 +1831,17 @@ ok:
 	return 0;
 
 exit_dput:
+	if (error == -ESTALE)
+		d_drop(path.dentry);
 	path_put_conditional(&path, nd);
 exit:
 	if (!IS_ERR(nd->intent.open.file))
 		release_open_intent(nd);
+	if (error == -ESTALE) {
+		d_drop(nd->path.dentry);
+		path_put(&nd->path);
+		goto top;
+	}
 	path_put(&nd->path);
 	return error;
 
@@ -1827,7 +1851,7 @@ do_link:
 		goto exit_dput;
 	/*
 	 * This is subtle. Instead of calling do_follow_link() we do the
-	 * thing by hands. The reason is that this way we have zero link_count
+	 * thing by hand. The reason is that this way we have zero link_count
 	 * and path_walk() (called from ->follow_link) honoring LOOKUP_PARENT.
 	 * After that we have the parent and last component, i.e.
 	 * we are in the same situation as after the first path_walk().
@@ -1846,6 +1870,8 @@ do_link:
 		 * with "intent.open".
 		 */
 		release_open_intent(nd);
+		if (error == ESTALE)
+			goto top;
 		return error;
 	}
 	nd->flags &= ~LOOKUP_PARENT;
@@ -1859,7 +1885,7 @@ do_link:
 		goto exit;
 	}
 	error = -ELOOP;
-	if (count++==32) {
+	if (count++ == 32) {
 		__putname(nd->last.name);
 		goto exit;
 	}

--------------010507020900030509040003--
