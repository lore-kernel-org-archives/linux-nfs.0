From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: [PATCH] - kNFSd in 2.5.15 - Require export operations for exporting a filesystem
Date: Fri, 10 May 2002 16:56:42 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15579.28458.683710.803080@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1764LE-0002A2-00
	for <nfs@lists.sourceforge.net>; Thu, 09 May 2002 23:57:24 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 10 May 2002 16:57:14 +1000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>




This patch removes the alternates to export_operations
for exporting a filesystem.
It removes fh_to_dentry, dentry_to_fh, and s_nfsd_free_path_sem.
It also removes a lot of code.

The fs/ntfs change is because it was setting fh_to_dentry and
dentry_to_fh (which no longer exist) to NULL.

NeilBrown


 ----------- Diffstat output ------------
 Documentation/filesystems/porting |    6 
 fs/nfsd/export.c                  |    9 
 fs/nfsd/nfsfh.c                   |  554 --------------------------------------
 fs/ntfs/super.c                   |    9 
 fs/super.c                        |    1 
 include/linux/fs.h                |   33 --
 6 files changed, 14 insertions(+), 598 deletions(-)

--- ./Documentation/filesystems/porting	2002/05/10 06:34:19	1.1
+++ ./Documentation/filesystems/porting	2002/05/10 06:38:38	1.2
@@ -146,3 +146,9 @@
 
 It is planned that this will be required for exporting once the code
 settles down a bit.
+
+[mandatory]
+
+s_export_op is now required for exporting a filesystem.
+isofs, ext2, ext3, resierfs, fat
+can be used as examples of very different filesystems.
--- ./include/linux/fs.h	2002/05/10 06:40:06	1.1
+++ ./include/linux/fs.h	2002/05/10 06:54:26	1.3
@@ -660,15 +660,6 @@
 	 * even looking at it. You had been warned.
 	 */
 	struct semaphore s_vfs_rename_sem;	/* Kludge */
-
-	/* The next field is used by knfsd when converting a (inode number based)
-	 * file handle into a dentry. As it builds a path in the dcache tree from
-	 * the bottom up, there may for a time be a subpath of dentrys which is not
-	 * connected to the main tree.  This semaphore ensure that there is only ever
-	 * one such free path per filesystem.  Note that unconnected files (or other
-	 * non-directories) are allowed, but not unconnected diretories.
-	 */
-	struct semaphore s_nfsd_free_path_sem;
 };
 
 /*
@@ -798,30 +789,6 @@
 	void (*clear_inode) (struct inode *);
 	void (*umount_begin) (struct super_block *);
 
-	/* Following are for knfsd to interact with "interesting" filesystems
-	 * Currently just reiserfs, but possibly FAT and others later
-	 *
-	 * fh_to_dentry is given a filehandle fragement with length, and a type flag
-	 *   and must return a dentry for the referenced object or, if "parent" is
-	 *   set, a dentry for the parent of the object.
-	 *   If a dentry cannot be found, a "root" dentry should be created and
-	 *   flaged as DCACHE_DISCONNECTED. nfsd_iget is an example implementation.
-	 *
-	 * dentry_to_fh is given a dentry and must generate the filesys specific
-	 *   part of the file handle.  Available length is passed in *lenp and used
-	 *   length should be returned therein.
-	 *   If need_parent is set, then dentry_to_fh should encode sufficient information
-	 *   to find the (current) parent.
-	 *   dentry_to_fh should return a 1byte "type" which will be passed back in
-	 *   the fhtype arguement to fh_to_dentry.  Type of 0 is reserved.
-	 *   If filesystem was exportable before the introduction of fh_to_dentry,
-	 *   types 1 and 2 should be used is that same way as the generic code.
-	 *   Type 255 means error.
-	 *
-	 * Lengths are in units of 4bytes, not bytes.
-	 */
-	struct dentry * (*fh_to_dentry)(struct super_block *sb, __u32 *fh, int len, int fhtype, int parent);
-	int (*dentry_to_fh)(struct dentry *, __u32 *fh, int *lenp, int need_parent);
 	int (*show_options)(struct seq_file *, struct vfsmount *);
 };
 
--- ./fs/nfsd/export.c	2002/05/10 05:30:36	1.1
+++ ./fs/nfsd/export.c	2002/05/10 06:38:38	1.2
@@ -313,15 +313,12 @@
 	 *       either a device number (so FS_REQUIRES_DEV needed)
 	 *       or an FSID number (so NFSEXP_FSID needed).
 	 * 2:  We must be able to find an inode from a filehandle.
-	 *       either using fh_to_dentry (prefered)
-	 *       or using read_inode (the hack).
+	 *       This means that s_export_op must be set.
 	 */
 	if (((inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)
-	      || (nxp->ex_flags & NFSEXP_FSID))
+	     || (nxp->ex_flags & NFSEXP_FSID))
 	    &&
-	    (inode->i_sb->s_op->read_inode
-	     || inode->i_sb->s_export_op
-	     || inode->i_sb->s_op->fh_to_dentry)) 
+	    inode->i_sb->s_export_op)
 		/* Ok, we can export it */;
 	else {
 		dprintk("exp_export: export of invalid fs type.\n");
--- ./fs/nfsd/nfsfh.c	2002/05/10 05:32:23	1.1
+++ ./fs/nfsd/nfsfh.c	2002/05/10 06:46:08	1.3
@@ -34,474 +34,6 @@
 
 #define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
 
-
-
-struct nfsd_getdents_callback {
-	char *name;		/* name that was found. It already points to a buffer NAME_MAX+1 is size */
-	unsigned long ino;	/* the inum we are looking for */
-	int found;		/* inode matched? */
-	int sequence;		/* sequence counter */
-};
-
-/*
- * A rather strange filldir function to capture
- * the name matching the specified inode number.
- */
-static int filldir_one(void * __buf, const char * name, int len,
-			loff_t pos, ino_t ino, unsigned int d_type)
-{
-	struct nfsd_getdents_callback *buf = __buf;
-	int result = 0;
-
-	buf->sequence++;
-#ifdef NFSD_DEBUG_VERBOSE
-dprintk("filldir_one: seq=%d, ino=%ld, name=%s\n", buf->sequence, ino, name);
-#endif
-	if (buf->ino == ino) {
-		memcpy(buf->name, name, len);
-		buf->name[len] = '\0';
-		buf->found = 1;
-		result = -1;
-	}
-	return result;
-}
-
-static int nfsd_get_name(struct dentry *dentry, char *name,
-			struct dentry *child)
-{
-	struct inode *dir = dentry->d_inode;
-	int error;
-	struct file file;
-	struct nfsd_getdents_callback buffer;
-
-	error = -ENOTDIR;
-	if (!dir || !S_ISDIR(dir->i_mode))
-		goto out;
-	error = -EINVAL;
-	if (!dir->i_fop)
-		goto out;
-	/*
-	 * Open the directory ...
-	 */
-	error = init_private_file(&file, dentry, FMODE_READ);
-	if (error)
-		goto out;
-	error = -EINVAL;
-	if (!file.f_op->readdir)
-		goto out_close;
-
-	buffer.name = name;
-	buffer.ino = child->d_inode->i_ino;
-	buffer.found = 0;
-	buffer.sequence = 0;
-	while (1) {
-		int old_seq = buffer.sequence;
-
-		error = vfs_readdir(&file, filldir_one, &buffer);
-
-		if (error < 0)
-			break;
-
-		error = 0;
-		if (buffer.found)
-			break;
-		error = -ENOENT;
-		if (old_seq == buffer.sequence)
-			break;
-	}
-
-out_close:
-	if (file.f_op->release)
-		file.f_op->release(dir, &file);
-out:
-	return error;
-}
-
-static struct dentry *nfsd_iget(struct super_block *sb, unsigned long ino, __u32 generation)
-{
-
-	/* iget isn't really right if the inode is currently unallocated!!
-	 * This should really all be done inside each filesystem
-	 *
-	 * ext2fs' read_inode has been strengthed to return a bad_inode if the inode
-	 *   had been deleted.
-	 *
-	 * Currently we don't know the generation for parent directory, so a generation
-	 * of 0 means "accept any"
-	 */
-	struct inode *inode;
-	struct dentry *result;
-	if (ino == 0)
-		return ERR_PTR(-ESTALE);
-	inode = iget(sb, ino);
-	if (inode == NULL)
-		return ERR_PTR(-ENOMEM);
-	if (is_bad_inode(inode)
-	    || (generation && inode->i_generation != generation)
-		) {
-		/* we didn't find the right inode.. */
-		dprintk("fh_verify: Inode %lu, Bad count: %d %d or version  %u %u\n",
-			inode->i_ino,
-			inode->i_nlink, atomic_read(&inode->i_count),
-			inode->i_generation,
-			generation);
-
-		iput(inode);
-		return ERR_PTR(-ESTALE);
-	}
-	/* now to find a dentry.
-	 * If possible, get a well-connected one
-	 */
-	result = d_alloc_anon(inode);
-	if (!result) {
-		iput(inode);
-		return ERR_PTR(-ENOMEM);
-	}
-	result->d_vfs_flags |= DCACHE_REFERENCED;
-	return result;
-}
-
-static struct dentry *nfsd_get_dentry(struct super_block *sb, __u32 *fh,
-					     int len, int fhtype, int parent)
-{
-	if (sb->s_op->fh_to_dentry)
-		return sb->s_op->fh_to_dentry(sb, fh, len, fhtype, parent);
-	switch (fhtype) {
-	case 1:
-		if (len < 2)
-			break;
-		if (parent)
-			break;
-		return nfsd_iget(sb, fh[0], fh[1]);
-
-	case 2:
-		if (len < 3)
-			break;
-		if (parent)
-			return nfsd_iget(sb,fh[2],0);
-		return nfsd_iget(sb,fh[0],fh[1]);
-	default: break;
-	}
-	return ERR_PTR(-EINVAL);
-}
-
-
-/* this routine links an IS_ROOT dentry into the dcache tree.  It gains "parent"
- * as a parent and "name" as a name
- * It should possibly go in dcache.c
- */
-int d_splice(struct dentry *target, struct dentry *parent, struct qstr *name)
-{
-	struct dentry *tdentry;
-#ifdef NFSD_PARANOIA
-	if (!IS_ROOT(target))
-		printk("nfsd: d_splice with no-root target: %s/%s\n", parent->d_name.name, name->name);
-	if (!(target->d_flags & DCACHE_DISCONNECTED))
-		printk("nfsd: d_splice with non-DISCONNECTED target: %s/%s\n", parent->d_name.name, name->name);
-#endif
-	tdentry = d_alloc(parent, name);
-	if (tdentry == NULL)
-		return -ENOMEM;
-	d_move(target, tdentry);
-
-	d_rehash(target);
-	dput(tdentry);
-
-	/* if parent is properly connected, then we can assert that
-	 * the children are connected, but it must be a singluar (non-forking)
-	 * branch
-	 */
-	if (!(parent->d_flags & DCACHE_DISCONNECTED)) {
-		while (target) {
-			target->d_flags &= ~DCACHE_DISCONNECTED;
-			parent = target;
-			spin_lock(&dcache_lock);
-			if (list_empty(&parent->d_subdirs))
-				target = NULL;
-			else {
-				target = list_entry(parent->d_subdirs.next, struct dentry, d_child);
-#ifdef NFSD_PARANOIA
-				/* must be only child */
-				if (target->d_child.next != &parent->d_subdirs
-				    || target->d_child.prev != &parent->d_subdirs) {
-					printk("nfsd: d_splice found non-singular disconnected branch: %s/%s\n",
-					       parent->d_name.name, target->d_name.name);
-					spin_unlock(&dcache_lock);
-					return 0;
-				}
-#endif
-			}
-			spin_unlock(&dcache_lock);
-		}
-	}
-	return 0;
-}
-
-/* this routine finds the dentry of the parent of a given directory
- * it assumes lookup("..") works.
- */
-struct dentry *nfsd_findparent(struct dentry *child)
-{
-	struct dentry *tdentry, *pdentry;
-	tdentry = d_alloc(child, &(const struct qstr) {"..", 2, 0});
-	if (!tdentry)
-		return ERR_PTR(-ENOMEM);
-
-	/* I'm going to assume that if the returned dentry is different, then
-	 * it is well connected.  But nobody returns different dentrys do they?
-	 */
-	down(&child->d_inode->i_sem);
-	pdentry = child->d_inode->i_op->lookup(child->d_inode, tdentry);
-	up(&child->d_inode->i_sem);
-	d_drop(tdentry); /* we never want ".." hashed */
-	if (!pdentry && tdentry->d_inode == NULL) {
-		/* File system cannot find ".." ... sad but possible */
-		pdentry = ERR_PTR(-EINVAL);
-	}
-	if (!pdentry) {
-		/* I don't want to return a ".." dentry.
-		 * I would prefer to return an unconnected "IS_ROOT" dentry,
-		 * though a properly connected dentry is even better
-		 */
-		/* if first or last of alias list is not tdentry, use that
-		 * else make a root dentry
-		 */
-		struct list_head *aliases = &tdentry->d_inode->i_dentry;
-		spin_lock(&dcache_lock);
-		if (aliases->next != aliases) {
-			pdentry = list_entry(aliases->next, struct dentry, d_alias);
-			if (pdentry == tdentry)
-				pdentry = list_entry(aliases->prev, struct dentry, d_alias);
-			if (pdentry == tdentry)
-				pdentry = NULL;
-			if (pdentry) dget_locked(pdentry);
-		}
-		spin_unlock(&dcache_lock);
-		if (pdentry == NULL) {
-			pdentry = d_alloc_root(tdentry->d_inode);
-			if (pdentry) {
-				igrab(tdentry->d_inode);
-				pdentry->d_flags |= DCACHE_DISCONNECTED;
-			}
-		}
-		if (pdentry == NULL)
-			pdentry = ERR_PTR(-ENOMEM);
-	}
-	dput(tdentry); /* it is not hashed, it will be discarded */
-	return pdentry;
-}
-
-static struct dentry *splice(struct dentry *child, struct dentry *parent)
-{
-	int err = 0, nerr;
-	struct qstr qs;
-	char namebuf[256];
-	struct list_head *lp;
-	/* child is an IS_ROOT (anonymous) dentry, but it is hypothesised that
-	 * it should be a child of parent.
-	 * We see if we can find a name and, if we can - splice it in.
-	 * We lookup the name before locking (i_sem) the directory as namelookup
-	 * also claims i_sem.  If the name gets changed then we will loop around
-	 * and try again in find_fh_dentry.
-	 */
-
-	nerr = nfsd_get_name(parent, namebuf, child);
-
-	/*
-	 * We now claim the parent i_sem so that no-one else tries to create
-	 * a dentry in the parent while we are.
-	 */
-	
-	down(&parent->d_inode->i_sem);
-
-	/* Now, things might have changed while we waited.
-	 * Possibly a friendly filesystem found child and spliced it in in response
-	 * to a lookup (though nobody does this yet).  In this case, just succeed.
-	 */
-	if (child->d_parent == parent) goto out;
-	
-	/* Possibly a new dentry has been made for this child->d_inode in
-	 * parent by a lookup.  In this case return that dentry. Caller must
-	 * notice and act accordingly
-	 */
-	spin_lock(&dcache_lock);
-	list_for_each(lp, &child->d_inode->i_dentry) {
-		struct dentry *tmp = list_entry(lp,struct dentry, d_alias);
-		if (!list_empty(&tmp->d_hash) &&
-		    tmp->d_parent == parent) {
-			child = dget_locked(tmp);
-			spin_unlock(&dcache_lock);
-			goto out;
-		}
-	}
-	spin_unlock(&dcache_lock);
-
-	/* now we need that name.  If there was an error getting it, now is th
-	 * time to bail out.
-	 */
-	if ((err = nerr))
-		goto out;
-	qs.name = namebuf;
-	qs.len = strlen(namebuf);
-	if (find_inode_number(parent, &qs) != 0) {
-		/* Now that IS odd.  I wonder what it means... */
-		err = -EEXIST;
-		printk("nfsd-fh: found a name that I didn't expect: %s/%s\n", parent->d_name.name, qs.name);
-		goto out;
-	}
-	err = d_splice(child, parent, &qs);
-	dprintk("nfsd_fh: found name %s for ino %ld\n", child->d_name.name, child->d_inode->i_ino);
- out:
-	up(&parent->d_inode->i_sem);
-	if (err)
-		return ERR_PTR(err);
-	else
-		return child;
-}
-
-/*
- * This is the basic lookup mechanism for turning an NFS file handle
- * into a dentry.
- * We use nfsd_iget and if that doesn't return a suitably connected dentry,
- * we try to find the parent, and the parent of that and so-on until a
- * connection if made.
- */
-static struct dentry *
-find_fh_dentry(struct super_block *sb, __u32 *datap, int len, int fhtype, int needpath)
-{
-	struct dentry *dentry, *result = NULL;
-	struct dentry *tmp;
-	int err = -ESTALE;
-	/* the sb->s_nfsd_free_path_sem semaphore is needed to make sure that only one unconnected (free)
-	 * dcache path ever exists, as otherwise two partial paths might get
-	 * joined together, which would be very confusing.
-	 * If there is ever an unconnected non-root directory, then this lock
-	 * must be held.
-	 */
-
-
-	nfsdstats.fh_lookup++;
-	/*
-	 * Attempt to find the inode.
-	 */
- retry:
-	down(&sb->s_nfsd_free_path_sem);
-	result = nfsd_get_dentry(sb, datap, len, fhtype, 0);
-	if (IS_ERR(result)
-	    || !(result->d_flags & DCACHE_DISCONNECTED)
-	    || (!S_ISDIR(result->d_inode->i_mode) && ! needpath)) {
-		up(&sb->s_nfsd_free_path_sem);
-	    
-		err = PTR_ERR(result);
-		if (IS_ERR(result))
-			goto err_out;
-		if ((result->d_flags & DCACHE_DISCONNECTED))
-			nfsdstats.fh_anon++;
-		return result;
-	}
-
-	/* It's a directory, or we are required to confirm the file's
-	 * location in the tree.
-	 */
-	dprintk("nfs_fh: need to look harder for %s/%d\n", sb->s_id, datap[0]);
-
-	lock_kernel();
-	if (!S_ISDIR(result->d_inode->i_mode)) {
-		nfsdstats.fh_nocache_nondir++;
-			/* need to iget dirino and make sure this inode is in that directory */
-			dentry = nfsd_get_dentry(sb, datap, len, fhtype, 1);
-			err = PTR_ERR(dentry);
-			if (IS_ERR(dentry))
-				goto err_result;
-			err = -ESTALE;
-			if (!dentry->d_inode
-			    || !S_ISDIR(dentry->d_inode->i_mode)) {
-				goto err_dentry;
-			}
-			tmp = splice(result, dentry);
-			err = PTR_ERR(tmp);
-			if (IS_ERR(tmp))
-				goto err_dentry;
-			if (tmp != result) {
-				/* it is safe to just use tmp instead, but we must discard result first */
-				d_drop(result);
-				dput(result);
-				result = tmp;
-			}
-	} else {
-		nfsdstats.fh_nocache_dir++;
-		dentry = dget(result);
-	}
-
-	while(dentry->d_flags & DCACHE_DISCONNECTED) {
-		/* LOOP INVARIANT */
-		/* haven't found a place in the tree yet, but we do have a free path
-		 * from dentry down to result, and dentry is a directory.
-		 * Have a hold on dentry and result */
-		struct dentry *pdentry;
-		struct inode *parent;
-
-		pdentry = nfsd_findparent(dentry);
-		err = PTR_ERR(pdentry);
-		if (IS_ERR(pdentry))
-			goto err_dentry;
-		parent = pdentry->d_inode;
-		err = -EACCES;
-		if (!parent) {
-			dput(pdentry);
-			goto err_dentry;
-		}
-
-		tmp = splice(dentry, pdentry);
-		if (tmp != dentry) {
-			/* Something wrong.  We need to drop the whole dentry->result path
-			 * whatever it was
-			 */
-			/*
-			 *  FIXME: the loop below will do Bad Things(tm) if
-			 *  dentry (or one of its ancestors) become attached
-			 *  to the tree (e.g. due to VFAT-style alias handling)
-			 */
-			struct dentry *d;
-			for (d=result ; d ; d=(d->d_parent == d)?NULL:d->d_parent)
-				d_drop(d);
-		}
-		if (IS_ERR(tmp)) {
-			err = PTR_ERR(tmp);
-			dput(pdentry);
-			goto err_dentry;
-		}
-		if (tmp != dentry) {
-			/* we lost a race,  try again
-			 */
-			dput(pdentry);
-			dput(tmp);
-			dput(dentry);
-			dput(result);	/* this will discard the whole free path, so we can up the semaphore */
-			up(&sb->s_nfsd_free_path_sem);
-			unlock_kernel();
-			goto retry;
-		}
-		dput(dentry);
-		dentry = pdentry;
-	}
-	dput(dentry);
-	up(&sb->s_nfsd_free_path_sem);
-	unlock_kernel();
-	return result;
-
-err_dentry:
-	dput(dentry);
-err_result:
-	dput(result);
-	up(&sb->s_nfsd_free_path_sem);
-	unlock_kernel();
-err_out:
-	if (err == -ESTALE)
-		nfsdstats.fh_stale++;
-	return ERR_PTR(err);
-}
-
 /*
  * our acceptability function.
  * if NOSUBTREECHECK, accept anything
@@ -660,15 +192,10 @@
 			dentry = dget(exp->ex_dentry);
 		else {
 			struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-			if (nop)
 				dentry = CALL(nop,decode_fh)(exp->ex_mnt->mnt_sb,
 							     datap, data_left,
 							     fileid_type,
 							     nfsd_acceptable, exp);
-			else
-				dentry = find_fh_dentry(exp->ex_dentry->d_sb,
-							datap, data_left, fileid_type,
-							!(exp->ex_flags & NFSEXP_NOSUBTREECHECK));
 		}
 		if (dentry == NULL)
 			goto out;
@@ -716,56 +243,9 @@
 		goto out;
 	}
 
-	/*
-	 * Security: Check that the export is valid for dentry <gam3@acm.org>
-	 *  This is only needed with subtree_check, and if export_operations is
-	 *  not being used -  export_operations does the check via  the "acceptable"
-	 *  callback
-	 */
-	error = 0;
-
-	if (exp->ex_mnt->mnt_sb->s_export_op == NULL &&
-	    !(exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {
-		if (exp->ex_dentry != dentry) {
-			struct dentry *tdentry = dentry;
-
-			spin_lock(&dcache_lock);
-			do {
-				tdentry = tdentry->d_parent;
-				if (exp->ex_dentry == tdentry)
-					break;
-				/* executable only by root and we can't be root */
-				/*
-				 * FIXME: permissions check is not that simple
-				 */
-				if (current->fsuid
-				    && (exp->ex_flags & NFSEXP_ROOTSQUASH)
-				    && !(tdentry->d_inode->i_uid
-					 && (tdentry->d_inode->i_mode & S_IXUSR))
-				    && !(tdentry->d_inode->i_gid
-					 && (tdentry->d_inode->i_mode & S_IXGRP))
-				    && !(tdentry->d_inode->i_mode & S_IXOTH)
-					) {
-					error = nfserr_stale;
-					dprintk("fh_verify: no root_squashed access.\n");
-				}
-			} while ((tdentry != tdentry->d_parent));
-			if (exp->ex_dentry != tdentry) {
-				error = nfserr_stale;
-				printk("nfsd Security: %s/%s bad export.\n",
-				       dentry->d_parent->d_name.name,
-				       dentry->d_name.name);
-				spin_unlock(&dcache_lock);
-				goto out;
-			}
-			spin_unlock(&dcache_lock);
-		}
-	}
-
 	/* Finally, check access permissions. */
-	if (!error) {
-		error = nfsd_permission(exp, dentry, access);
-	}
+	error = nfsd_permission(exp, dentry, access);
+
 #ifdef NFSD_PARANOIA_EXTREME
 	if (error) {
 		printk("fh_verify: %s/%s permission failure, acc=%x, error=%d\n",
@@ -790,38 +270,14 @@
 		      __u32 *datap, int *maxsize)
 {
 	struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-	struct super_block *sb = dentry->d_sb;
 	
 	if (dentry == exp->ex_dentry) {
 		*maxsize = 0;
 		return 0;
 	}
 
-	if (nop)
-		return CALL(nop,encode_fh)(dentry, datap, maxsize,
+	return CALL(nop,encode_fh)(dentry, datap, maxsize,
 			  !(exp->ex_flags&NFSEXP_NOSUBTREECHECK));
-
-	if (sb->s_op->dentry_to_fh) {
-		int need_parent = !S_ISDIR(dentry->d_inode->i_mode) &&
-			!(exp->ex_flags & NFSEXP_NOSUBTREECHECK);
-		
-		int type = sb->s_op->dentry_to_fh(dentry, datap, maxsize, need_parent);
-		return type;
-	}
-
-	if (*maxsize < 2)
-		return 255;
-	*datap++ = ino_t_to_u32(dentry->d_inode->i_ino);
-	*datap++ = dentry->d_inode->i_generation;
-	if (*maxsize ==2 ||
-	    S_ISDIR(dentry->d_inode->i_mode) ||
-	    (exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {
-		*maxsize = 2;
-		return 1;
-	}
-	*datap++ = ino_t_to_u32(parent_ino(dentry));
-	*maxsize = 3;
-	return 2;
 }
 
 /*
@@ -845,7 +301,6 @@
 	 * of the same version, where possible.
 	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
 	 * Then create a 32byte filehandle using nfs_fhbase_old
-	 * But only do this if dentry_to_fh is not available
 	 *
 	 */
 	
@@ -870,8 +325,7 @@
 	fhp->fh_export = exp;
 
 	if (ref_fh &&
-	    ref_fh->fh_handle.fh_version == 0xca &&
-	    dentry->d_sb->s_op->dentry_to_fh == NULL) {
+	    ref_fh->fh_handle.fh_version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
--- ./fs/ntfs/super.c	2002/05/10 06:43:17	1.1
+++ ./fs/ntfs/super.c	2002/05/10 06:46:08	1.2
@@ -1441,14 +1441,7 @@
 	clear_inode:	ntfs_clear_big_inode,	/* VFS: Called when an inode is
 						   removed from memory. */
 	umount_begin:	NULL,		/* Forced umount. */
-	/*
-	 * These are NFSd support functions but NTFS is a standard fs so
-	 * shouldn't need to implement these manually. At least we can try
-	 * without and if it doesn't work in some way we can always implement
-	 * something here.
-	 */
-	fh_to_dentry:	NULL,		/* Get dentry for given file handle. */
-	dentry_to_fh:	NULL,		/* Get file handle for given dentry. */
+
 	show_options:	ntfs_show_options, /* Show mount options in proc. */
 };
 
--- ./fs/super.c	2002/05/10 06:53:59	1.1
+++ ./fs/super.c	2002/05/10 06:54:27	1.2
@@ -58,7 +58,6 @@
 		s->s_count = S_BIAS;
 		atomic_set(&s->s_active, 1);
 		sema_init(&s->s_vfs_rename_sem,1);
-		sema_init(&s->s_nfsd_free_path_sem,1);
 		sema_init(&s->s_dquot.dqio_sem, 1);
 		sema_init(&s->s_dquot.dqoff_sem, 1);
 		s->s_maxbytes = MAX_NON_LFS;

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
