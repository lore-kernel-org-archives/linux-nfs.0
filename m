From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH 1/3] enhanced lookup ESTALE error handling (v2)
Date: Fri, 01 Feb 2008 15:57:51 -0500
Message-ID: <47A387CF.70201@redhat.com>
References: <4790C761.1010603@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050009010005040108090504"
Cc: linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4790C761.1010603@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050009010005040108090504
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

--------------050009010005040108090504
Content-Type: text/plain;
 name="estale.lookup.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="estale.lookup.2"

--- linux-2.6.24.i686/fs/namei.c.org
+++ linux-2.6.24.i686/fs/namei.c
@@ -741,7 +741,7 @@ static __always_inline void follow_dotdo
 {
 	struct fs_struct *fs = current->fs;
 
-	while(1) {
+	while (1) {
 		struct vfsmount *parent;
 		struct dentry *old = nd->dentry;
 
@@ -840,7 +840,7 @@ static fastcall int __link_path_walk(con
 		lookup_flags = LOOKUP_FOLLOW | (nd->flags & LOOKUP_CONTINUE);
 
 	/* At this point we know we have a real path component. */
-	for(;;) {
+	for (;;) {
 		unsigned long hash;
 		struct qstr this;
 		unsigned int c;
@@ -992,7 +992,7 @@ return_reval:
 		 */
 		if (nd->dentry && nd->dentry->d_sb &&
 		    (nd->dentry->d_sb->s_type->fs_flags & FS_REVAL_DOT)) {
-			err = -ESTALE;
+			err = -ENOENT;
 			/* Note: we do not d_invalidate() */
 			if (!nd->dentry->d_op->d_revalidate(nd->dentry, nd))
 				break;
@@ -1003,6 +1003,8 @@ out_dput:
 		dput_path(&next, nd);
 		break;
 	}
+	if (err == -ESTALE)
+		d_drop(nd->dentry);
 	path_release(nd);
 return_err:
 	return err;
@@ -1019,13 +1021,24 @@ static int fastcall link_path_walk(const
 {
 	struct nameidata save = *nd;
 	int result;
+	struct dentry *svd;
 
 	/* make sure the stuff we saved doesn't go away */
 	dget(save.dentry);
 	mntget(save.mnt);
 
+	svd = nd->dentry;
 	result = __link_path_walk(name, nd);
-	if (result == -ESTALE) {
+	while (result == -ESTALE) {
+		/*
+		 * If no progress was made looking up the pathname,
+		 * then stop and return ENOENT instead of ESTALE.
+		 */
+		if (nd->dentry == svd) {
+			result = -ENOENT;
+			break;
+		}
+		svd = nd->dentry;
 		*nd = save;
 		dget(nd->dentry);
 		mntget(nd->mnt);
@@ -1712,7 +1725,10 @@ int open_namei(int dfd, const char *path
 	int acc_mode, error;
 	struct path path;
 	struct dentry *dir;
-	int count = 0;
+	int count;
+
+top:
+	count = 0;
 
 	acc_mode = ACC_MODE(flag);
 
@@ -1739,7 +1755,8 @@ int open_namei(int dfd, const char *path
 	/*
 	 * Create - we need to know the parent.
 	 */
-	error = path_lookup_create(dfd,pathname,LOOKUP_PARENT,nd,flag,mode);
+	error = path_lookup_create(dfd, pathname, LOOKUP_PARENT, nd,
+				flag, mode);
 	if (error)
 		return error;
 
@@ -1812,10 +1829,17 @@ ok:
 	return 0;
 
 exit_dput:
+	if (error == -ESTALE)
+		d_drop(path.dentry);
 	dput_path(&path, nd);
 exit:
 	if (!IS_ERR(nd->intent.open.file))
 		release_open_intent(nd);
+	if (error == -ESTALE) {
+		d_drop(nd->dentry);
+		path_release(nd);
+		goto top;
+	}
 	path_release(nd);
 	return error;
 
@@ -1825,7 +1849,7 @@ do_link:
 		goto exit_dput;
 	/*
 	 * This is subtle. Instead of calling do_follow_link() we do the
-	 * thing by hands. The reason is that this way we have zero link_count
+	 * thing by hand. The reason is that this way we have zero link_count
 	 * and path_walk() (called from ->follow_link) honoring LOOKUP_PARENT.
 	 * After that we have the parent and last component, i.e.
 	 * we are in the same situation as after the first path_walk().
@@ -1844,6 +1868,8 @@ do_link:
 		 * with "intent.open".
 		 */
 		release_open_intent(nd);
+		if (error == ESTALE)
+			goto top;
 		return error;
 	}
 	nd->flags &= ~LOOKUP_PARENT;
@@ -1857,7 +1883,7 @@ do_link:
 		goto exit;
 	}
 	error = -ELOOP;
-	if (count++==32) {
+	if (count++ == 32) {
 		__putname(nd->last.name);
 		goto exit;
 	}

--------------050009010005040108090504--
