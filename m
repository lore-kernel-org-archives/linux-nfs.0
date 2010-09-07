Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab0IGUDr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:47 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3ktl027336
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:47 -0700 (PDT)
Message-ID: <4C869AA2.30704@netapp.com>
Date: Tue, 07 Sep 2010 16:03:46 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/6] NFS: remove old readdir code
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS: remove old readdir code

With the new cache array method, we no longer need some of this code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0fd3782..87f74bb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -175,17 +175,15 @@ typedef struct {
 	struct file	*file;
 	struct page	*page;
 	unsigned long	page_index;
-	__be32		*ptr;
 	u64		*dir_cookie;
 	loff_t		current_index;
-	struct nfs_entry *entry;
 	decode_dirent_t	decode;
-	int		plus;
+
 	unsigned long	timestamp;
 	unsigned long	gencount;
-	int		timestamp_valid;
 	unsigned int	cache_entry_index;
-	unsigned int	eof;
+	unsigned int	plus:1;
+	unsigned int	eof:1;
 } nfs_readdir_descriptor_t;
 
 /*
@@ -408,29 +406,12 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 }
 
 static inline
-int dir_decode(nfs_readdir_descriptor_t *desc)
-{
-	__be32	*p = desc->ptr;
-	p = desc->decode(p, desc->entry, desc->plus);
-	if (IS_ERR(p))
-		return PTR_ERR(p);
-	desc->ptr = p;
-	if (desc->timestamp_valid) {
-		desc->entry->fattr->time_start = desc->timestamp;
-		desc->entry->fattr->gencount = desc->gencount;
-	} else
-		desc->entry->fattr->valid &= ~NFS_ATTR_FATTR;
-	return 0;
-}
-
-static inline
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
 	kunmap(desc->page);
 	unlock_page(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
-	desc->ptr = NULL;
 }
 
 static inline
@@ -462,108 +443,6 @@ int find_cache_page(nfs_readdir_descriptor_t *desc)
 	return -EAGAIN;
 }
 
-/*
- * Given a pointer to a buffer that has already been filled by a call
- * to readdir, find the next entry with cookie '*desc->dir_cookie'.
- *
- * If the end of the buffer has been reached, return -EAGAIN, if not,
- * return the offset within the buffer of the next entry to be
- * read.
- */
-static inline
-int find_dirent(nfs_readdir_descriptor_t *desc)
-{
-	struct nfs_entry *entry = desc->entry;
-	int		loop_count = 0,
-			status;
-
-	while((status = dir_decode(desc)) == 0) {
-		dfprintk(DIRCACHE, "NFS: %s: examining cookie %Lu\n",
-				__func__, (unsigned long long)entry->cookie);
-		if (entry->prev_cookie == *desc->dir_cookie)
-			break;
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
-	}
-	return status;
-}
-
-/*
- * Given a pointer to a buffer that has already been filled by a call
- * to readdir, find the entry at offset 'desc->file->f_pos'.
- *
- * If the end of the buffer has been reached, return -EAGAIN, if not,
- * return the offset within the buffer of the next entry to be
- * read.
- */
-static inline
-int find_dirent_index(nfs_readdir_descriptor_t *desc)
-{
-	struct nfs_entry *entry = desc->entry;
-	int		loop_count = 0,
-			status;
-
-	for(;;) {
-		status = dir_decode(desc);
-		if (status)
-			break;
-
-		dfprintk(DIRCACHE, "NFS: found cookie %Lu at index %Ld\n",
-				(unsigned long long)entry->cookie, desc->current_index);
-
-		if (desc->file->f_pos == desc->current_index) {
-			*desc->dir_cookie = entry->cookie;
-			break;
-		}
-		desc->current_index++;
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
-	}
-	return status;
-}
-
-/*
- * Find the given page, and call find_dirent() or find_dirent_index in
- * order to try to return the next entry.
- */
-static inline
-int find_dirent_page(nfs_readdir_descriptor_t *desc)
-{
-	struct inode	*inode = desc->file->f_path.dentry->d_inode;
-	struct page	*page;
-	int		status;
-
-	dfprintk(DIRCACHE, "NFS: %s: searching page %ld for target %Lu\n",
-			__func__, desc->page_index,
-			(long long) *desc->dir_cookie);
-
-	/* If we find the page in the page_cache, we cannot be sure
-	 * how fresh the data is, so we will ignore readdir_plus attributes.
-	 */
-	desc->timestamp_valid = 0;
-	page = read_cache_page(inode->i_mapping, desc->page_index,
-			       (filler_t *)nfs_readdir_filler, desc);
-	if (IS_ERR(page)) {
-		status = PTR_ERR(page);
-		goto out;
-	}
-
-	/* NOTE: Someone else may have changed the READDIRPLUS flag */
-	desc->page = page;
-	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (*desc->dir_cookie != 0)
-		status = find_dirent(desc);
-	else
-		status = find_dirent_index(desc);
- out:
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, status);
-	return status;
-}
-
 /* Search for desc->dir_cookie from the beginning of the page cache */
 static inline
 int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
@@ -588,8 +467,6 @@ static inline unsigned int dt_type(struct inode *inode)
 	return (inode->i_mode >> 12) & 15;
 }
 
-static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc);
-
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
@@ -691,7 +568,6 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct inode	*inode = dentry->d_inode;
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
-	struct nfs_entry my_entry;
 	int res = -ENOMEM;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
@@ -712,15 +588,6 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = NFS_USE_READDIRPLUS(inode);
 
-	my_entry.cookie = my_entry.prev_cookie = 0;
-	my_entry.eof = 0;
-	my_entry.fh = nfs_alloc_fhandle();
-	my_entry.fattr = nfs_alloc_fattr();
-	if (my_entry.fh == NULL || my_entry.fattr == NULL)
-		goto out_alloc_failed;
-
-	desc->entry = &my_entry;
-
 	nfs_block_sillyrename(dentry);
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0)
@@ -744,7 +611,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			nfs_zap_caches(inode);
 			desc->plus = 0;
-			desc->entry->eof = 0;
+			desc->eof = 0;
 			continue;
 		}
 		if (res < 0)
@@ -760,9 +627,6 @@ out:
 	nfs_unblock_sillyrename(dentry);
 	if (res > 0)
 		res = 0;
-out_alloc_failed:
-	nfs_free_fattr(my_entry.fattr);
-	nfs_free_fhandle(my_entry.fh);
 	dfprintk(FILE, "NFS: readdir(%s/%s) returns %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			res);
@@ -1285,81 +1149,6 @@ no_open:
 }
 #endif /* CONFIG_NFSV4 */
 
-static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
-{
-	struct dentry *parent = desc->file->f_path.dentry;
-	struct inode *dir = parent->d_inode;
-	struct nfs_entry *entry = desc->entry;
-	struct dentry *dentry, *alias;
-	struct qstr name = {
-		.name = entry->name,
-		.len = entry->len,
-	};
-	struct inode *inode;
-	unsigned long verf = nfs_save_change_attribute(dir);
-
-	switch (name.len) {
-		case 2:
-			if (name.name[0] == '.' && name.name[1] == '.')
-				return dget_parent(parent);
-			break;
-		case 1:
-			if (name.name[0] == '.')
-				return dget(parent);
-	}
-
-	spin_lock(&dir->i_lock);
-	if (NFS_I(dir)->cache_validity & NFS_INO_INVALID_DATA) {
-		spin_unlock(&dir->i_lock);
-		return NULL;
-	}
-	spin_unlock(&dir->i_lock);
-
-	name.hash = full_name_hash(name.name, name.len);
-	dentry = d_lookup(parent, &name);
-	if (dentry != NULL) {
-		/* Is this a positive dentry that matches the readdir info? */
-		if (dentry->d_inode != NULL &&
-				(NFS_FILEID(dentry->d_inode) == entry->ino ||
-				d_mountpoint(dentry))) {
-			if (!desc->plus || entry->fh->size == 0)
-				return dentry;
-			if (nfs_compare_fh(NFS_FH(dentry->d_inode),
-						entry->fh) == 0)
-				goto out_renew;
-		}
-		/* No, so d_drop to allow one to be created */
-		d_drop(dentry);
-		dput(dentry);
-	}
-	if (!desc->plus || !(entry->fattr->valid & NFS_ATTR_FATTR))
-		return NULL;
-	if (name.len > NFS_SERVER(dir)->namelen)
-		return NULL;
-	/* Note: caller is already holding the dir->i_mutex! */
-	dentry = d_alloc(parent, &name);
-	if (dentry == NULL)
-		return NULL;
-	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
-	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
-	if (IS_ERR(inode)) {
-		dput(dentry);
-		return NULL;
-	}
-
-	alias = d_materialise_unique(dentry, inode);
-	if (alias != NULL) {
-		dput(dentry);
-		if (IS_ERR(alias))
-			return NULL;
-		dentry = alias;
-	}
-
-out_renew:
-	nfs_set_verifier(dentry, verf);
-	return dentry;
-}
-
 /*
  * Code common to create, mkdir, and mknod.
  */
