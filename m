From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 4/4] Optimize NFS open() calls by means of 'intents'...
Date: Fri, 23 May 2003 14:46:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16078.6164.953953.259773@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux FSdevel <linux-fsdevel@vger.kernel.org>,
    Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JC6k-0006Nc-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 05:57:14 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Do close-to-open data revalidation inside the i_op->lookup() and
d_op->d_revalidate() routines by using intents to discover whether or
not this is an open().

Implement open(O_EXCL) by means of the i_op->create() intents.

Cheers,
 Trond


diff -u --recursive --new-file linux-2.5.69-03-creat/fs/nfs/dir.c linux-2.5.69-04-cto_excl/fs/nfs/dir.c
--- linux-2.5.69-03-creat/fs/nfs/dir.c	2003-05-23 00:13:37.000000000 +0200
+++ linux-2.5.69-04-cto_excl/fs/nfs/dir.c	2003-05-23 01:17:20.000000000 +0200
@@ -31,6 +31,7 @@
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
+#include <linux/open.h>
 
 #define NFS_PARANOIA 1
 /* #define NFS_DEBUG_VERBOSE 1 */
@@ -78,16 +79,11 @@
 static int
 nfs_opendir(struct inode *inode, struct file *filp)
 {
-	struct nfs_server *server = NFS_SERVER(inode);
-	int res = 0;
+	int res;
 
 	lock_kernel();
-	/* Do cto revalidation */
-	if (!(server->flags & NFS_MOUNT_NOCTO))
-		res = __nfs_revalidate_inode(server, inode);
 	/* Call generic open code in order to cache credentials */
-	if (!res)
-		res = nfs_open(inode, filp);
+	res = nfs_open(inode, filp);
 	unlock_kernel();
 	return res;
 }
@@ -466,11 +462,17 @@
  * and may need to be looked up again.
  */
 static inline
-int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
+int nfs_check_verifier(struct inode *dir, struct dentry *dentry, struct vfsintent *intent)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	if (IS_ROOT(dentry))
 		return 1;
-	if (nfs_revalidate_inode(NFS_SERVER(dir), dir))
+	/* If we're doing an open(), then observe the 'cto' flag */
+	if (intent && intent->type == OPEN_INTENT
+			&& !(server->flags & NFS_MOUNT_NOCTO)) {
+		if (__nfs_revalidate_inode(server, dir))
+			return 0;
+	} else if (nfs_revalidate_inode(server, dir))
 		return 0;
 	return time_after(dentry->d_time, NFS_MTIME_UPDATE(dir));
 }
@@ -485,9 +487,15 @@
 }
 
 static inline
-int nfs_lookup_verify_inode(struct inode *inode)
+int nfs_lookup_verify_inode(struct inode *inode, struct vfsintent *intent)
 {
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	/* If we're doing an open(), then observe the 'cto' flag */
+	if (intent && intent->type == OPEN_INTENT
+			&& !(server->flags & NFS_MOUNT_NOCTO))
+		return __nfs_revalidate_inode(server, inode);
+	return nfs_revalidate_inode(server, inode);
 }
 
 /*
@@ -497,9 +505,11 @@
  * If parent mtime has changed, we revalidate, else we wait for a
  * period corresponding to the parent's attribute cache timeout value.
  */
-static inline int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry)
+static inline
+int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
+		struct vfsintent *intent)
 {
-	if (!nfs_check_verifier(dir, dentry))
+	if (!nfs_check_verifier(dir, dentry, intent))
 		return 1;
 	return time_after(jiffies, dentry->d_time + NFS_ATTRTIMEO(dir));
 }
@@ -530,7 +540,7 @@
 	inode = dentry->d_inode;
 
 	if (!inode) {
-		if (nfs_neg_need_reval(dir, dentry))
+		if (nfs_neg_need_reval(dir, dentry, intent))
 			goto out_bad;
 		goto out_valid;
 	}
@@ -542,8 +552,8 @@
 	}
 
 	/* Force a full look up iff the parent directory has changed */
-	if (nfs_check_verifier(dir, dentry)) {
-		if (nfs_lookup_verify_inode(inode))
+	if (nfs_check_verifier(dir, dentry, intent)) {
+		if (nfs_lookup_verify_inode(inode, intent))
 			goto out_bad;
 		goto out_valid;
 	}
@@ -552,7 +562,7 @@
 	if (!error) {
 		if (memcmp(NFS_FH(inode), &fhandle, sizeof(struct nfs_fh))!= 0)
 			goto out_bad;
-		if (nfs_lookup_verify_inode(inode))
+		if (nfs_lookup_verify_inode(inode, intent))
 			goto out_bad;
 		goto out_valid_renew;
 	}
@@ -632,6 +642,7 @@
 
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct vfsintent *intent)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	struct inode *inode = NULL;
 	int error;
 	struct nfs_fh fhandle;
@@ -641,23 +652,29 @@
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
 	error = -ENAMETOOLONG;
-	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
+	if (dentry->d_name.len > server->namelen)
 		goto out;
 
 	error = -ENOMEM;
 	dentry->d_op = &nfs_dentry_operations;
 
 	lock_kernel();
-	error = nfs_cached_lookup(dir, dentry, &fhandle, &fattr);
-	if (!error) {
-		error = -EACCES;
-		inode = nfs_fhget(dentry, &fhandle, &fattr);
-		if (inode) {
-			d_add(dentry, inode);
-			nfs_renew_times(dentry);
-			error = 0;
+	/* If we're not doing an open(), or we are 'nocto', then
+	 * we may use the readdirplus cache
+	 */
+	if (!intent || intent->type != OPEN_INTENT ||
+			(server->flags & NFS_MOUNT_NOCTO)) {
+		error = nfs_cached_lookup(dir, dentry, &fhandle, &fattr);
+		if (!error) {
+			error = -EACCES;
+			inode = nfs_fhget(dentry, &fhandle, &fattr);
+			if (inode) {
+				d_add(dentry, inode);
+				nfs_renew_times(dentry);
+				error = 0;
+			}
+			goto out_unlock;
 		}
-		goto out_unlock;
 	}
 
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
@@ -793,6 +810,7 @@
 	struct iattr attr;
 	struct nfs_fattr fattr;
 	struct nfs_fh fhandle;
+	int flags = 0;
 	int error;
 
 	dfprintk(VFS, "NFS: create(%s/%ld, %s\n", dir->i_sb->s_id, 
@@ -801,16 +819,15 @@
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	/*
-	 * The 0 argument passed into the create function should one day
-	 * contain the O_EXCL flag if requested. This allows NFSv3 to
-	 * select the appropriate create strategy. Currently open_namei
-	 * does not pass the create flags.
-	 */
+	if (intent && intent->type == OPEN_INTENT) {
+		struct opendata *opendata;
+		opendata = container_of(intent, struct opendata, intent);
+		flags = opendata->flag;
+	}
 	lock_kernel();
 	nfs_zap_caches(dir);
 	error = NFS_PROTO(dir)->create(dir, &dentry->d_name,
-					 &attr, 0, &fhandle, &fattr);
+					 &attr, flags, &fhandle, &fattr);
 	if (!error)
 		error = nfs_instantiate(dentry, &fhandle, &fattr);
 	else
diff -u --recursive --new-file linux-2.5.69-03-creat/fs/nfs/file.c linux-2.5.69-04-cto_excl/fs/nfs/file.c
--- linux-2.5.69-03-creat/fs/nfs/file.c	2003-05-07 12:34:41.000000000 +0200
+++ linux-2.5.69-04-cto_excl/fs/nfs/file.c	2003-05-23 00:50:27.000000000 +0200
@@ -82,9 +82,6 @@
 	/* Do NFSv4 open() call */
 	if ((open = server->rpc_ops->file_open) != NULL)
 		res = open(inode, filp);
-	/* Do cto revalidation */
-	else if (!(server->flags & NFS_MOUNT_NOCTO))
-		res = __nfs_revalidate_inode(server, inode);
 	/* Call generic open code in order to cache credentials */
 	if (!res)
 		res = nfs_open(inode, filp);


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
