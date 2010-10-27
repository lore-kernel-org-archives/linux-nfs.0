Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:65188 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932178Ab0J0NqZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 09:46:25 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 15:46:08 +0200
Cc: Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <20101027083924.GA28129@infradead.org> <20101027133924.GB6328@fieldses.org>
In-Reply-To: <20101027133924.GB6328@fieldses.org>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201010271546.09036.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 October 2010, J. Bruce Fields wrote:
> On Wed, Oct 27, 2010 at 04:39:24AM -0400, Christoph Hellwig wrote:
> > Do locks_alloc_lock and initialization of the heap struct file_lock
> > in the caller.  This also avoids an entirely useless copy of the
> > lock structure.  free the passed in structure if we are modifying
> > an existing lock structure.
> 
> That sounds good; I'll give it a try.

I've already started, this is what I've come up with. I don't have
a good way to test it though, and don't know as much as you about this
code. Feel free to use it as a starting point if you like.
It does look correct to me, but I'm not very confident in this.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---

diff --git a/fs/locks.c b/fs/locks.c
index 8b2b6ad..c5ec771 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -162,10 +162,11 @@ EXPORT_SYMBOL_GPL(unlock_flocks);
 static struct kmem_cache *filelock_cache __read_mostly;
 
 /* Allocate an empty lock structure. */
-static struct file_lock *locks_alloc_lock(void)
+struct file_lock *locks_alloc_lock(void)
 {
 	return kmem_cache_alloc(filelock_cache, GFP_KERNEL);
 }
+EXPORT_SYMBOL_GPL(locks_alloc_lock);
 
 void locks_release_private(struct file_lock *fl)
 {
@@ -1365,7 +1366,6 @@ int fcntl_getlease(struct file *filp)
 int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
-	struct file_lock *new_fl = NULL;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 	int error, rdlease_count = 0, wrlease_count = 0;
@@ -1385,11 +1385,6 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	lease = *flp;
 
 	if (arg != F_UNLCK) {
-		error = -ENOMEM;
-		new_fl = locks_alloc_lock();
-		if (new_fl == NULL)
-			goto out;
-
 		error = -EAGAIN;
 		if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 			goto out;
@@ -1434,23 +1429,19 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 		goto out;
 	}
 
-	error = 0;
 	if (arg == F_UNLCK)
-		goto out;
+		goto out_unlck;
 
 	error = -EINVAL;
 	if (!leases_enable)
 		goto out;
 
-	locks_copy_lock(new_fl, lease);
-	locks_insert_lock(before, new_fl);
-
-	*flp = new_fl;
+	locks_insert_lock(before, lease);
+out_unlck:
 	return 0;
 
 out:
-	if (new_fl != NULL)
-		locks_free_lock(new_fl);
+	locks_free_lock(lease);
 	return error;
 }
 EXPORT_SYMBOL(generic_setlease);
@@ -1514,26 +1505,31 @@ EXPORT_SYMBOL_GPL(vfs_setlease);
  */
 int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 {
-	struct file_lock fl, *flp = &fl;
+	struct file_lock *fl;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int error;
 
-	locks_init_lock(&fl);
-	error = lease_init(filp, arg, &fl);
-	if (error)
+	fl = locks_alloc_lock();
+	if (!fl)
+		return -ENOMEM;
+
+	locks_init_lock(fl);
+	error = lease_init(filp, arg, fl);
+	if (error) {
+		locks_free_lock(fl);
 		return error;
+	}
 
 	lock_flocks();
-
-	error = __vfs_setlease(filp, arg, &flp);
+	error = __vfs_setlease(filp, arg, &fl);
 	if (error || arg == F_UNLCK)
 		goto out_unlock;
 
-	error = fasync_helper(fd, filp, 1, &flp->fl_fasync);
+	error = fasync_helper(fd, filp, 1, &fl->fl_fasync);
 	if (error < 0) {
 		/* remove lease just inserted by setlease */
-		flp->fl_type = F_UNLCK | F_INPROGRESS;
-		flp->fl_break_time = jiffies - 10;
+		fl->fl_type = F_UNLCK | F_INPROGRESS;
+		fl->fl_break_time = jiffies - 10;
 		time_out_leases(inode);
 		goto out_unlock;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9019e8e..56347e0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2614,7 +2614,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	int cb_up = atomic_read(&sop->so_client->cl_cb_set);
-	struct file_lock fl, *flp = &fl;
+	struct file_lock *fl;
 	int status, flag = 0;
 
 	flag = NFS4_OPEN_DELEGATE_NONE;
@@ -2648,20 +2648,24 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 		flag = NFS4_OPEN_DELEGATE_NONE;
 		goto out;
 	}
-	locks_init_lock(&fl);
-	fl.fl_lmops = &nfsd_lease_mng_ops;
-	fl.fl_flags = FL_LEASE;
-	fl.fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
-	fl.fl_end = OFFSET_MAX;
-	fl.fl_owner =  (fl_owner_t)dp;
-	fl.fl_file = find_readable_file(stp->st_file);
-	BUG_ON(!fl.fl_file);
-	fl.fl_pid = current->tgid;
+	status = -ENOMEM;
+	fl = locks_alloc_lock();
+	if (!fl)
+		goto out;
+	locks_init_lock(fl);
+	fl->fl_lmops = &nfsd_lease_mng_ops;
+	fl->fl_flags = FL_LEASE;
+	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
+	fl->fl_end = OFFSET_MAX;
+	fl->fl_owner =  (fl_owner_t)dp;
+	fl->fl_file = find_readable_file(stp->st_file);
+	BUG_ON(!fl->fl_file);
+	fl->fl_pid = current->tgid;
 
 	/* vfs_setlease checks to see if delegation should be handed out.
 	 * the lock_manager callbacks fl_mylease and fl_change are used
 	 */
-	if ((status = vfs_setlease(fl.fl_file, fl.fl_type, &flp))) {
+	if ((status = vfs_setlease(fl->fl_file, fl->fl_type, &fl))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		unhash_delegation(dp);
 		flag = NFS4_OPEN_DELEGATE_NONE;
