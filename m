From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] nfsd: open a file descriptor for fsync in nfs4 recovery
Date: Mon, 22 Mar 2010 17:32:14 +0100
Message-ID: <20100322163214.GA1307@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: viro@zeniv.linux.org.uk
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:52011 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755054Ab0CVQcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Mar 2010 12:32:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of just looking up a path use do_filp_open to get us a file
structure for the nfs4 recovery directory.  This allows us to get
rid of the last non-standard vfs_fsync caller with a NULL file
pointer.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/nfs4recover.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfs4recover.c	2010-03-22 15:33:13.404255603 +0100
+++ linux-2.6/fs/nfsd/nfs4recover.c	2010-03-22 15:33:24.520253578 +0100
@@ -43,8 +43,7 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
-static struct path rec_dir;
-static int rec_dir_init = 0;
+static struct file *rec_file;
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -116,12 +115,6 @@ out_no_tfm:
 	return status;
 }
 
-static void
-nfsd4_sync_rec_dir(void)
-{
-	vfs_fsync(NULL, rec_dir.dentry, 0);
-}
-
 int
 nfsd4_create_clid_dir(struct nfs4_client *clp)
 {
@@ -132,7 +125,7 @@ nfsd4_create_clid_dir(struct nfs4_client
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
 
-	if (!rec_dir_init || clp->cl_firststate)
+	if (!rec_file || clp->cl_firststate)
 		return 0;
 
 	status = nfs4_save_creds(&original_cred);
@@ -140,9 +133,9 @@ nfsd4_create_clid_dir(struct nfs4_client
 		return status;
 
 	/* lock the parent */
-	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
+	mutex_lock(&rec_file->f_path.dentry->d_inode->i_mutex);
 
-	dentry = lookup_one_len(dname, rec_dir.dentry, HEXDIR_LEN-1);
+	dentry = lookup_one_len(dname, rec_file->f_path.dentry, HEXDIR_LEN-1);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
 		goto out_unlock;
@@ -152,18 +145,18 @@ nfsd4_create_clid_dir(struct nfs4_client
 		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
 		goto out_put;
 	}
-	status = mnt_want_write(rec_dir.mnt);
+	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
 		goto out_put;
-	status = vfs_mkdir(rec_dir.dentry->d_inode, dentry, S_IRWXU);
-	mnt_drop_write(rec_dir.mnt);
+	status = vfs_mkdir(rec_file->f_path.dentry->d_inode, dentry, S_IRWXU);
+	mnt_drop_write(rec_file->f_path.mnt);
 out_put:
 	dput(dentry);
 out_unlock:
-	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
+	mutex_unlock(&rec_file->f_path.dentry->d_inode->i_mutex);
 	if (status == 0) {
 		clp->cl_firststate = 1;
-		nfsd4_sync_rec_dir();
+		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
 	}
 	nfs4_reset_creds(original_cred);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
@@ -205,14 +198,14 @@ nfsd4_list_rec_dir(struct dentry *dir, r
 	struct dentry *dentry;
 	int status;
 
-	if (!rec_dir_init)
+	if (!rec_file)
 		return 0;
 
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return status;
 
-	filp = dentry_open(dget(dir), mntget(rec_dir.mnt), O_RDONLY,
+	filp = dentry_open(dget(dir), mntget(rec_file->f_path.mnt), O_RDONLY,
 			   current_cred());
 	status = PTR_ERR(filp);
 	if (IS_ERR(filp))
@@ -254,8 +247,8 @@ nfsd4_unlink_clid_dir(char *name, int na
 
 	dprintk("NFSD: nfsd4_unlink_clid_dir. name %.*s\n", namlen, name);
 
-	mutex_lock_nested(&rec_dir.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
-	dentry = lookup_one_len(name, rec_dir.dentry, namlen);
+	mutex_lock_nested(&rec_file->f_path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
+	dentry = lookup_one_len(name, rec_file->f_path.dentry, namlen);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
 		goto out_unlock;
@@ -263,11 +256,11 @@ nfsd4_unlink_clid_dir(char *name, int na
 	status = -ENOENT;
 	if (!dentry->d_inode)
 		goto out;
-	status = vfs_rmdir(rec_dir.dentry->d_inode, dentry);
+	status = vfs_rmdir(rec_file->f_path.dentry->d_inode, dentry);
 out:
 	dput(dentry);
 out_unlock:
-	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
+	mutex_unlock(&rec_file->f_path.dentry->d_inode->i_mutex);
 	return status;
 }
 
@@ -277,10 +270,10 @@ nfsd4_remove_clid_dir(struct nfs4_client
 	const struct cred *original_cred;
 	int status;
 
-	if (!rec_dir_init || !clp->cl_firststate)
+	if (!rec_file || !clp->cl_firststate)
 		return;
 
-	status = mnt_want_write(rec_dir.mnt);
+	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
 		goto out;
 	clp->cl_firststate = 0;
@@ -292,8 +285,8 @@ nfsd4_remove_clid_dir(struct nfs4_client
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_creds(original_cred);
 	if (status == 0)
-		nfsd4_sync_rec_dir();
-	mnt_drop_write(rec_dir.mnt);
+		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
+	mnt_drop_write(rec_file->f_path.mnt);
 out:
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
@@ -322,19 +315,19 @@ void
 nfsd4_recdir_purge_old(void) {
 	int status;
 
-	if (!rec_dir_init)
+	if (!rec_file)
 		return;
-	status = mnt_want_write(rec_dir.mnt);
+	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
 		goto out;
-	status = nfsd4_list_rec_dir(rec_dir.dentry, purge_old);
+	status = nfsd4_list_rec_dir(rec_file->f_path.dentry, purge_old);
 	if (status == 0)
-		nfsd4_sync_rec_dir();
-	mnt_drop_write(rec_dir.mnt);
+		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
+	mnt_drop_write(rec_file->f_path.mnt);
 out:
 	if (status)
 		printk("nfsd4: failed to purge old clients from recovery"
-			" directory %s\n", rec_dir.dentry->d_name.name);
+			" directory %s\n", rec_file->f_path.dentry->d_name.name);
 }
 
 static int
@@ -354,10 +347,13 @@ int
 nfsd4_recdir_load(void) {
 	int status;
 
-	status = nfsd4_list_rec_dir(rec_dir.dentry, load_recdir);
+	if (!rec_file)
+		return 0;
+
+	status = nfsd4_list_rec_dir(rec_file->f_path.dentry, load_recdir);
 	if (status)
 		printk("nfsd4: failed loading clients from recovery"
-			" directory %s\n", rec_dir.dentry->d_name.name);
+			" directory %s\n", rec_file->f_path.dentry->d_name.name);
 	return status;
 }
 
@@ -374,7 +370,7 @@ nfsd4_init_recdir(char *rec_dirname)
 	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
 			rec_dirname);
 
-	BUG_ON(rec_dir_init);
+	BUG_ON(rec_file);
 
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0) {
@@ -384,22 +380,21 @@ nfsd4_init_recdir(char *rec_dirname)
 		return;
 	}
 
-	status = kern_path(rec_dirname, LOOKUP_FOLLOW | LOOKUP_DIRECTORY,
-			&rec_dir);
-	if (status)
+	rec_file = filp_open(rec_dirname, O_RDONLY | O_DIRECTORY, 0);
+	if (IS_ERR(rec_file)) {
 		printk("NFSD: unable to find recovery directory %s\n",
 				rec_dirname);
+		rec_file = NULL;
+	}
 
-	if (!status)
-		rec_dir_init = 1;
 	nfs4_reset_creds(original_cred);
 }
 
 void
 nfsd4_shutdown_recdir(void)
 {
-	if (!rec_dir_init)
+	if (!rec_file)
 		return;
-	rec_dir_init = 0;
-	path_put(&rec_dir);
+	filp_close(rec_file, current->files);
+	rec_file = NULL;
 }
