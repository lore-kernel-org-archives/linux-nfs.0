From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 4] Get rid of open_private_file
Date: Fri, 20 Aug 2004 16:51:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1By3FQ-000734-59@notabene.cse.unsw.edu.au>
References: <20040820164909.27056.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By3Fe-0004g7-P7
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:50 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By3Fc-0006oc-6x
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:50 -0700
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


This is only used by nfsd to save one kmalloc, and
the code is not always kept up-to-date with dentry_open,
so just get rid of it.


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/exportfs/expfs.c         |   15 ++++--
 ./fs/file_table.c             |   46 ---------------------
 ./fs/lockd/svc4proc.c         |    2 
 ./fs/lockd/svclock.c          |   30 ++++++-------
 ./fs/lockd/svcproc.c          |    2 
 ./fs/lockd/svcsubs.c          |    8 +--
 ./fs/nfsd/lockd.c             |   11 +----
 ./fs/nfsd/nfs4state.c         |   22 ++++------
 ./fs/nfsd/vfs.c               |   91 ++++++++++++++++++------------------------
 ./include/linux/fs.h          |    5 --
 ./include/linux/lockd/bind.h  |    2 
 ./include/linux/lockd/lockd.h |    4 -
 ./include/linux/nfsd/nfsd.h   |    2 
 ./include/linux/nfsd/state.h  |    2 
 14 files changed, 88 insertions(+), 154 deletions(-)

diff ./fs/exportfs/expfs.c~current~ ./fs/exportfs/expfs.c
--- ./fs/exportfs/expfs.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/exportfs/expfs.c	2004-08-20 16:38:15.000000000 +1000
@@ -1,5 +1,6 @@
 
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/module.h>
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
@@ -347,7 +348,7 @@ static int get_name(struct dentry *dentr
 {
 	struct inode *dir = dentry->d_inode;
 	int error;
-	struct file file;
+	struct file *file;
 	struct getdents_callback buffer;
 
 	error = -ENOTDIR;
@@ -359,11 +360,13 @@ static int get_name(struct dentry *dentr
 	/*
 	 * Open the directory ...
 	 */
-	error = open_private_file(&file, dentry, O_RDONLY);
-	if (error)
+	file = dentry_open(dget(dentry), NULL, O_RDONLY);
+	error = PTR_ERR(file);
+	if (IS_ERR(file))
 		goto out;
+
 	error = -EINVAL;
-	if (!file.f_op->readdir)
+	if (!file->f_op->readdir)
 		goto out_close;
 
 	buffer.name = name;
@@ -373,7 +376,7 @@ static int get_name(struct dentry *dentr
 	while (1) {
 		int old_seq = buffer.sequence;
 
-		error = vfs_readdir(&file, filldir_one, &buffer);
+		error = vfs_readdir(file, filldir_one, &buffer);
 
 		if (error < 0)
 			break;
@@ -387,7 +390,7 @@ static int get_name(struct dentry *dentr
 	}
 
 out_close:
-	close_private_file(&file);
+	fput(file);
 out:
 	return error;
 }

diff ./fs/file_table.c~current~ ./fs/file_table.c
--- ./fs/file_table.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/file_table.c	2004-08-20 16:38:15.000000000 +1000
@@ -106,52 +106,6 @@ fail:
 
 EXPORT_SYMBOL(get_empty_filp);
 
-/*
- * Clear and initialize a (private) struct file for the given dentry,
- * allocate the security structure, and call the open function (if any).  
- * The file should be released using close_private_file.
- */
-int open_private_file(struct file *filp, struct dentry *dentry, int flags)
-{
-	int error;
-	memset(filp, 0, sizeof(*filp));
-	eventpoll_init_file(filp);
-	filp->f_flags  = flags;
-	filp->f_mode   = ((flags+1) & O_ACCMODE) | FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
-	atomic_set(&filp->f_count, 1);
-	filp->f_dentry = dentry;
-	filp->f_mapping = dentry->d_inode->i_mapping;
-	filp->f_uid    = current->fsuid;
-	filp->f_gid    = current->fsgid;
-	filp->f_op     = dentry->d_inode->i_fop;
-	INIT_LIST_HEAD(&filp->f_list);
-	error = security_file_alloc(filp);
-	if (!error)
-		if (filp->f_op && filp->f_op->open) {
-			error = filp->f_op->open(dentry->d_inode, filp);
-			if (error)
-				security_file_free(filp);
-		}
-	return error;
-}
-
-EXPORT_SYMBOL(open_private_file);
-
-/*
- * Release a private file by calling the release function (if any) and
- * freeing the security structure.
- */
-void close_private_file(struct file *file)
-{
-	struct inode * inode = file->f_dentry->d_inode;
-
-	if (file->f_op && file->f_op->release)
-		file->f_op->release(inode, file);
-	security_file_free(file);
-}
-
-EXPORT_SYMBOL(close_private_file);
-
 void fastcall fput(struct file *file)
 {
 	if (atomic_dec_and_test(&file->f_count))

diff ./fs/lockd/svc4proc.c~current~ ./fs/lockd/svc4proc.c
--- ./fs/lockd/svc4proc.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2004-08-20 16:38:15.000000000 +1000
@@ -53,7 +53,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 		*filp = file;
 
 		/* Set up the missing parts of the file_lock structure */
-		lock->fl.fl_file  = &file->f_file;
+		lock->fl.fl_file  = file->f_file;
 		lock->fl.fl_owner = (fl_owner_t) host;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}

diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/lockd/svclock.c	2004-08-20 16:38:15.000000000 +1000
@@ -237,7 +237,7 @@ nlmsvc_delete_block(struct nlm_block *bl
 
 	/* Remove block from list */
 	nlmsvc_remove_block(block);
-	posix_unblock_lock(&file->f_file, fl);
+	posix_unblock_lock(file->f_file, fl);
 	block->b_granted = 0;
 
 	/* If the block is in the middle of a GRANT callback,
@@ -298,8 +298,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 	int			error;
 
 	dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
-				file->f_file.f_dentry->d_inode->i_sb->s_id,
-				file->f_file.f_dentry->d_inode->i_ino,
+				file->f_file->f_dentry->d_inode->i_sb->s_id,
+				file->f_file->f_dentry->d_inode->i_ino,
 				lock->fl.fl_type, lock->fl.fl_pid,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end,
@@ -315,8 +315,8 @@ again:
 	/* Lock file against concurrent access */
 	down(&file->f_sema);
 
-	if (!(conflock = posix_test_lock(&file->f_file, &lock->fl))) {
-		error = posix_lock_file(&file->f_file, &lock->fl);
+	if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
+		error = posix_lock_file(file->f_file, &lock->fl);
 
 		if (block)
 			nlmsvc_delete_block(block, 0);
@@ -381,13 +381,13 @@ nlmsvc_testlock(struct nlm_file *file, s
 	struct file_lock	*fl;
 
 	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
-				file->f_file.f_dentry->d_inode->i_sb->s_id,
-				file->f_file.f_dentry->d_inode->i_ino,
+				file->f_file->f_dentry->d_inode->i_sb->s_id,
+				file->f_file->f_dentry->d_inode->i_ino,
 				lock->fl.fl_type,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	if ((fl = posix_test_lock(&file->f_file, &lock->fl)) != NULL) {
+	if ((fl = posix_test_lock(file->f_file, &lock->fl)) != NULL) {
 		dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
 				fl->fl_type, (long long)fl->fl_start,
 				(long long)fl->fl_end);
@@ -413,8 +413,8 @@ nlmsvc_unlock(struct nlm_file *file, str
 	int	error;
 
 	dprintk("lockd: nlmsvc_unlock(%s/%ld, pi=%d, %Ld-%Ld)\n",
-				file->f_file.f_dentry->d_inode->i_sb->s_id,
-				file->f_file.f_dentry->d_inode->i_ino,
+				file->f_file->f_dentry->d_inode->i_sb->s_id,
+				file->f_file->f_dentry->d_inode->i_ino,
 				lock->fl.fl_pid,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
@@ -423,7 +423,7 @@ nlmsvc_unlock(struct nlm_file *file, str
 	nlmsvc_cancel_blocked(file, lock);
 
 	lock->fl.fl_type = F_UNLCK;
-	error = posix_lock_file(&file->f_file, &lock->fl);
+	error = posix_lock_file(file->f_file, &lock->fl);
 
 	return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
 }
@@ -441,8 +441,8 @@ nlmsvc_cancel_blocked(struct nlm_file *f
 	struct nlm_block	*block;
 
 	dprintk("lockd: nlmsvc_cancel(%s/%ld, pi=%d, %Ld-%Ld)\n",
-				file->f_file.f_dentry->d_inode->i_sb->s_id,
-				file->f_file.f_dentry->d_inode->i_ino,
+				file->f_file->f_dentry->d_inode->i_sb->s_id,
+				file->f_file->f_dentry->d_inode->i_ino,
 				lock->fl.fl_pid,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
@@ -524,7 +524,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
 	}
 
 	/* Try the lock operation again */
-	if ((conflock = posix_test_lock(&file->f_file, &lock->fl)) != NULL) {
+	if ((conflock = posix_test_lock(file->f_file, &lock->fl)) != NULL) {
 		/* Bummer, we blocked again */
 		dprintk("lockd: lock still blocked\n");
 		nlmsvc_insert_block(block, NLM_NEVER);
@@ -537,7 +537,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
 	 * following yields an error, this is most probably due to low
 	 * memory. Retry the lock in a few seconds.
 	 */
-	if ((error = posix_lock_file(&file->f_file, &lock->fl)) < 0) {
+	if ((error = posix_lock_file(file->f_file, &lock->fl)) < 0) {
 		printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
 				-error, __FUNCTION__);
 		nlmsvc_insert_block(block, 10 * HZ);

diff ./fs/lockd/svcproc.c~current~ ./fs/lockd/svcproc.c
--- ./fs/lockd/svcproc.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/lockd/svcproc.c	2004-08-20 16:38:15.000000000 +1000
@@ -82,7 +82,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 		*filp = file;
 
 		/* Set up the missing parts of the file_lock structure */
-		lock->fl.fl_file  = &file->f_file;
+		lock->fl.fl_file  = file->f_file;
 		lock->fl.fl_owner = (fl_owner_t) host;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}

diff ./fs/lockd/svcsubs.c~current~ ./fs/lockd/svcsubs.c
--- ./fs/lockd/svcsubs.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2004-08-20 16:38:15.000000000 +1000
@@ -124,7 +124,7 @@ out_free:
 static inline void
 nlm_delete_file(struct nlm_file *file)
 {
-	struct inode *inode = file->f_file.f_dentry->d_inode;
+	struct inode *inode = file->f_file->f_dentry->d_inode;
 	struct nlm_file	**fp, *f;
 
 	dprintk("lockd: closing file %s/%ld\n",
@@ -133,7 +133,7 @@ nlm_delete_file(struct nlm_file *file)
 	while ((f = *fp) != NULL) {
 		if (f == file) {
 			*fp = file->f_next;
-			nlmsvc_ops->fclose(&file->f_file);
+			nlmsvc_ops->fclose(file->f_file);
 			kfree(file);
 			return;
 		}
@@ -176,7 +176,7 @@ again:
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
-			if (posix_lock_file(&file->f_file, &lock) < 0) {
+			if (posix_lock_file(file->f_file, &lock) < 0) {
 				printk("lockd: unlock failure in %s:%d\n",
 						__FILE__, __LINE__);
 				return 1;
@@ -230,7 +230,7 @@ nlm_traverse_files(struct nlm_host *host
 			if (!file->f_blocks && !file->f_locks
 			 && !file->f_shares && !file->f_count) {
 				*fp = file->f_next;
-				nlmsvc_ops->fclose(&file->f_file);
+				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);
 			} else {
 				fp = &file->f_next;

diff ./fs/nfsd/lockd.c~current~ ./fs/nfsd/lockd.c
--- ./fs/nfsd/lockd.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/nfsd/lockd.c	2004-08-20 16:38:15.000000000 +1000
@@ -10,6 +10,7 @@
 
 #include <linux/types.h>
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
@@ -22,7 +23,7 @@
  * Note: we hold the dentry use count while the file is open.
  */
 static u32
-nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f, struct file *filp)
+nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f, struct file **filp)
 {
 	u32		nfserr;
 	struct svc_fh	fh;
@@ -35,10 +36,6 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 
 	exp_readlock();
 	nfserr = nfsd_open(rqstp, &fh, S_IFREG, MAY_LOCK, filp);
-	if (!nfserr) {
-		dget(filp->f_dentry);
-		mntget(filp->f_vfsmnt);
-	}
 	fh_put(&fh);
 	rqstp->rq_client = NULL;
 	exp_readunlock();
@@ -60,9 +57,7 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 static void
 nlm_fclose(struct file *filp)
 {
-	nfsd_close(filp);
-	dput(filp->f_dentry);
-	mntput(filp->f_vfsmnt);
+	fput(filp);
 }
 
 struct nlmsvc_binding		nfsd_nlm_ops = {

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-08-20 16:38:15.000000000 +1000
@@ -962,12 +962,10 @@ release_stateid(struct nfs4_stateid *stp
 	list_del(&stp->st_perfilestate);
 	if((stp->st_vfs_set) && (flags & OPEN_STATE)) {
 		release_stateid_lockowner(stp);
-		nfsd_close(&stp->st_vfs_file);
+		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
-		dput(stp->st_vfs_file.f_dentry);
-		mntput(stp->st_vfs_file.f_vfsmnt);
 	} else if ((stp->st_vfs_set) && (flags & LOCK_STATE)) {
-		struct file *filp = &stp->st_vfs_file;
+		struct file *filp = stp->st_vfs_file;
 
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
 	}
@@ -1315,8 +1313,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			goto out_free;
 
 		vfsopen++;
-		dget(stp->st_vfs_file.f_dentry);
-		mntget(stp->st_vfs_file.f_vfsmnt);
 
 		init_stateid(stp, fp, sop, open);
 		stp->st_vfs_set = 1;
@@ -1331,7 +1327,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		share_access &= open->op_share_access;
 
 		/* update the struct file */
-		if ((status = nfs4_file_upgrade(&stp->st_vfs_file, share_access)))
+		if ((status = nfs4_file_upgrade(stp->st_vfs_file, share_access)))
 			goto out;
 		/* remember the open */
 		set_bit(open->op_share_access, &stp->st_access_bmap);
@@ -1499,7 +1495,7 @@ static inline int
 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
 {
 	return (stp->st_vfs_set == 0 ||
-		fhp->fh_dentry->d_inode != stp->st_vfs_file.f_dentry->d_inode);
+		fhp->fh_dentry->d_inode != stp->st_vfs_file->f_dentry->d_inode);
 }
 
 static int
@@ -1816,7 +1812,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 		goto out;
 	}
 	set_access(&share_access, stp->st_access_bmap);
-	nfs4_file_downgrade(&stp->st_vfs_file, 
+	nfs4_file_downgrade(stp->st_vfs_file, 
 	                    share_access & ~od->od_share_access);
 
 	reset_union_bmap_access(od->od_share_access, &stp->st_access_bmap);
@@ -2059,7 +2055,7 @@ alloc_init_lock_stateid(struct nfs4_stat
 	stp->st_stateid.si_stateownerid = sop->so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
 	stp->st_stateid.si_generation = 0;
-	stp->st_vfs_file = open_stp->st_vfs_file;
+	stp->st_vfs_file = open_stp->st_vfs_file; /* FIXME refcount?? */
 	stp->st_vfs_set = open_stp->st_vfs_set;
 	stp->st_access_bmap = open_stp->st_access_bmap;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
@@ -2172,7 +2168,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 			goto out;
 	}
 	/* lock->lk_stateowner and lock_stp have been created or found */
-	filp = &lock_stp->st_vfs_file;
+	filp = lock_stp->st_vfs_file;
 
 	if ((status = fh_verify(rqstp, current_fh, S_IFREG, MAY_LOCK))) {
 		printk("NFSD: nfsd4_lock: permission denied!\n");
@@ -2379,7 +2375,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 					&locku->lu_stateowner, &stp, NULL)))
 		goto out;
 
-	filp = &stp->st_vfs_file;
+	filp = stp->st_vfs_file;
 	BUG_ON(!filp);
 	locks_init_lock(&file_lock);
 	file_lock.fl_type = F_UNLCK;
@@ -2474,7 +2470,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 		list_for_each_entry(stp, &local->so_perfilestate,
 				st_perfilestate) {
 			if(stp->st_vfs_set) {
-				if (check_for_locks(&stp->st_vfs_file, local))
+				if (check_for_locks(stp->st_vfs_file, local))
 					goto out;
 			}
 		}

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-08-20 16:38:15.000000000 +1000
@@ -21,6 +21,7 @@
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/major.h>
 #include <linux/ext2_fs.h>
@@ -79,6 +80,7 @@ struct raparms {
 	unsigned int		p_count;
 	ino_t			p_ino;
 	dev_t			p_dev;
+	int			p_set;
 	struct file_ra_state	p_ra;
 };
 
@@ -636,7 +638,7 @@ nfsd_access(struct svc_rqst *rqstp, stru
  */
 int
 nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
-			int access, struct file *filp)
+			int access, struct file **filp)
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
@@ -672,21 +674,13 @@ nfsd_open(struct svc_rqst *rqstp, struct
 		goto out_nfserr;
 
 	if (access & MAY_WRITE) {
-		err = get_write_access(inode);
-		if (err)
-			goto out_nfserr;
-
 		flags = O_WRONLY|O_LARGEFILE;
 
 		DQUOT_INIT(inode);
 	}
-
-	err = open_private_file(filp, dentry, flags);
-	if (!err) {
-		filp->f_vfsmnt = fhp->fh_export->ex_mnt;
-	} else if (access & MAY_WRITE)
-		put_write_access(inode);
-
+	*filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_mnt), flags);
+	if (IS_ERR(*filp))
+		err = PTR_ERR(*filp);
 out_nfserr:
 	if (err)
 		err = nfserrno(err);
@@ -700,12 +694,7 @@ out:
 void
 nfsd_close(struct file *filp)
 {
-	struct dentry	*dentry = filp->f_dentry;
-	struct inode	*inode = dentry->d_inode;
-
-	close_private_file(filp);
-	if (filp->f_mode & FMODE_WRITE)
-		put_write_access(inode);
+	fput(filp);
 }
 
 /*
@@ -749,7 +738,7 @@ nfsd_sync_dir(struct dentry *dp)
 static spinlock_t ra_lock = SPIN_LOCK_UNLOCKED;
 
 static inline struct raparms *
-nfsd_get_raparms(dev_t dev, ino_t ino, struct address_space *mapping)
+nfsd_get_raparms(dev_t dev, ino_t ino)
 {
 	struct raparms	*ra, **rap, **frap = NULL;
 	int depth = 0;
@@ -771,7 +760,7 @@ nfsd_get_raparms(dev_t dev, ino_t ino, s
 	ra = *frap;
 	ra->p_dev = dev;
 	ra->p_ino = ino;
-	file_ra_state_init(&ra->p_ra, mapping);
+	ra->p_set = 0;
 found:
 	if (rap != &raparm_cache) {
 		*rap = ra->p_next;
@@ -828,14 +817,14 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	struct raparms	*ra;
 	mm_segment_t	oldfs;
 	int		err;
-	struct file	file;
+	struct file	*file;
 	struct inode	*inode;
 
 	err = nfsd_open(rqstp, fhp, S_IFREG, MAY_READ, &file);
 	if (err)
 		goto out;
 	err = nfserr_perm;
-	inode = file.f_dentry->d_inode;
+	inode = file->f_dentry->d_inode;
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		(!lock_may_read(inode, offset, *count)))
@@ -843,38 +832,40 @@ nfsd_read(struct svc_rqst *rqstp, struct
 #endif
 
 	/* Get readahead parameters */
-	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino,
-			      inode->i_mapping->host->i_mapping);
-	if (ra)
-		file.f_ra = ra->p_ra;
+	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
+
+	if (ra && ra->p_set)
+		file->f_ra = ra->p_ra;
 
-	if (file.f_op->sendfile) {
+	if (file->f_op->sendfile) {
 		svc_pushback_unused_pages(rqstp);
-		err = file.f_op->sendfile(&file, &offset, *count,
+		err = file->f_op->sendfile(file, &offset, *count,
 						 nfsd_read_actor, rqstp);
 	} else {
 		oldfs = get_fs();
 		set_fs(KERNEL_DS);
-		err = vfs_readv(&file, (struct iovec __user *)vec, vlen, &offset);
+		err = vfs_readv(file, (struct iovec __user *)vec, vlen, &offset);
 		set_fs(oldfs);
 	}
 
 	/* Write back readahead params */
 	if (ra) {
 		spin_lock(&ra_lock);
-		ra->p_ra = file.f_ra;
+		ra->p_ra = file->f_ra;
+		ra->p_set = 1;
 		ra->p_count--;
 		spin_unlock(&ra_lock);
 	}
+
 	if (err >= 0) {
 		nfsdstats.io_read += err;
 		*count = err;
 		err = 0;
-		dnotify_parent(file.f_dentry, DN_ACCESS);
+		dnotify_parent(file->f_dentry, DN_ACCESS);
 	} else 
 		err = nfserrno(err);
 out_close:
-	nfsd_close(&file);
+	nfsd_close(file);
 out:
 	return err;
 }
@@ -890,7 +881,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	   			unsigned long cnt, int *stablep)
 {
 	struct svc_export	*exp;
-	struct file		file;
+	struct file		*file;
 	struct dentry		*dentry;
 	struct inode		*inode;
 	mm_segment_t		oldfs;
@@ -906,11 +897,11 @@ nfsd_write(struct svc_rqst *rqstp, struc
 
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
-		(!lock_may_write(file.f_dentry->d_inode, offset, cnt)))
+		(!lock_may_write(file->f_dentry->d_inode, offset, cnt)))
 		goto out_close;
 #endif
 
-	dentry = file.f_dentry;
+	dentry = file->f_dentry;
 	inode = dentry->d_inode;
 	exp   = fhp->fh_export;
 
@@ -923,7 +914,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	 * flushing the data to disk is handled separately below.
 	 */
 
-	if (file.f_op->fsync == 0) {/* COMMIT3 cannot work */
+	if (file->f_op->fsync == 0) {/* COMMIT3 cannot work */
 	       stable = 2;
 	       *stablep = 2; /* FILE_SYNC */
 	}
@@ -931,15 +922,15 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	if (!EX_ISSYNC(exp))
 		stable = 0;
 	if (stable && !EX_WGATHER(exp))
-		file.f_flags |= O_SYNC;
+		file->f_flags |= O_SYNC;
 
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = vfs_writev(&file, (struct iovec __user *)vec, vlen, &offset);
+	err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
 	if (err >= 0) {
 		nfsdstats.io_write += cnt;
-		dnotify_parent(file.f_dentry, DN_MODIFY);
+		dnotify_parent(file->f_dentry, DN_MODIFY);
 	}
 
 	/* clear setuid/setgid flag after write */
@@ -979,7 +970,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 
 			if (inode->i_state & I_DIRTY) {
 				dprintk("nfsd: write sync %d\n", current->pid);
-				nfsd_sync(&file);
+				nfsd_sync(file);
 			}
 #if 0
 			wake_up(&inode->i_wait);
@@ -995,7 +986,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	else 
 		err = nfserrno(err);
 out_close:
-	nfsd_close(&file);
+	nfsd_close(file);
 out:
 	return err;
 }
@@ -1014,7 +1005,7 @@ int
 nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
                loff_t offset, unsigned long count)
 {
-	struct file	file;
+	struct file	*file;
 	int		err;
 
 	if ((u64)count > ~(u64)offset)
@@ -1023,14 +1014,14 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 	if ((err = nfsd_open(rqstp, fhp, S_IFREG, MAY_WRITE, &file)) != 0)
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		if (file.f_op && file.f_op->fsync) {
-			nfsd_sync(&file);
+		if (file->f_op && file->f_op->fsync) {
+			nfsd_sync(file);
 		} else {
 			err = nfserr_notsupp;
 		}
 	}
 
-	nfsd_close(&file);
+	nfsd_close(file);
 	return err;
 }
 #endif /* CONFIG_NFSD_V3 */
@@ -1653,14 +1644,14 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	     struct readdir_cd *cdp, encode_dent_fn func)
 {
 	int		err;
-	struct file	file;
+	struct file	*file;
 	loff_t		offset = *offsetp;
 
 	err = nfsd_open(rqstp, fhp, S_IFDIR, MAY_READ, &file);
 	if (err)
 		goto out;
 
-	offset = vfs_llseek(&file, offset, 0);
+	offset = vfs_llseek(file, offset, 0);
 	if (offset < 0) {
 		err = nfserrno((int)offset);
 		goto out_close;
@@ -1674,18 +1665,18 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 
 	do {
 		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		err = vfs_readdir(&file, (filldir_t) func, cdp);
+		err = vfs_readdir(file, (filldir_t) func, cdp);
 	} while (err >=0 && cdp->err == nfs_ok);
 	if (err)
 		err = nfserrno(err);
 	else
 		err = cdp->err;
-	*offsetp = vfs_llseek(&file, 0, 1);
+	*offsetp = vfs_llseek(file, 0, 1);
 
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
 out_close:
-	nfsd_close(&file);
+	nfsd_close(file);
 out:
 	return err;
 }

diff ./include/linux/fs.h~current~ ./include/linux/fs.h
--- ./include/linux/fs.h~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./include/linux/fs.h	2004-08-20 16:38:15.000000000 +1000
@@ -597,11 +597,6 @@ extern spinlock_t files_lock;
 #define get_file(x)	atomic_inc(&(x)->f_count)
 #define file_count(x)	atomic_read(&(x)->f_count)
 
-/* Initialize and open a private file and allocate its security structure. */
-extern int open_private_file(struct file *, struct dentry *, int);
-/* Release a private file and free its security structure. */
-extern void close_private_file(struct file *file);
-
 #define	MAX_NON_LFS	((1UL<<31) - 1)
 
 /* Page cache limit. The filesystems should put that into their s_maxbytes 

diff ./include/linux/lockd/bind.h~current~ ./include/linux/lockd/bind.h
--- ./include/linux/lockd/bind.h~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./include/linux/lockd/bind.h	2004-08-20 16:38:15.000000000 +1000
@@ -20,7 +20,7 @@ struct svc_rqst;
 struct nlmsvc_binding {
 	u32			(*fopen)(struct svc_rqst *,
 						struct nfs_fh *,
-						struct file *);
+						struct file **);
 	void			(*fclose)(struct file *);
 };
 

diff ./include/linux/lockd/lockd.h~current~ ./include/linux/lockd/lockd.h
--- ./include/linux/lockd/lockd.h~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2004-08-20 16:38:15.000000000 +1000
@@ -92,7 +92,7 @@ struct nlm_rqst {
 struct nlm_file {
 	struct nlm_file *	f_next;		/* linked list */
 	struct nfs_fh		f_handle;	/* NFS file handle */
-	struct file		f_file;		/* VFS file pointer */
+	struct file *		f_file;		/* VFS file pointer */
 	struct nlm_share *	f_shares;	/* DOS shares */
 	struct nlm_block *	f_blocks;	/* blocked locks */
 	unsigned int		f_locks;	/* guesstimate # of locks */
@@ -195,7 +195,7 @@ void		  nlmsvc_invalidate_all(void);
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
 {
-	return file->f_file.f_dentry->d_inode;
+	return file->f_file->f_dentry->d_inode;
 }
 
 /*

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2004-08-20 16:38:15.000000000 +1000
@@ -94,7 +94,7 @@ int		nfsd_commit(struct svc_rqst *, stru
 				loff_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
 int		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
-				int, struct file *);
+				int, struct file **);
 void		nfsd_close(struct file *);
 int		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *,int, unsigned long *);

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-08-20 16:38:11.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-08-20 16:38:15.000000000 +1000
@@ -218,7 +218,7 @@ struct nfs4_stateid {
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;
-	struct file                   st_vfs_file;
+	struct file                 * st_vfs_file;
 	int                           st_vfs_set;
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
