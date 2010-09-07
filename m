Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab0IGUDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:44 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3hig027298
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:43 -0700 (PDT)
Message-ID: <4C869A9F.4080906@netapp.com>
Date: Tue, 07 Sep 2010 16:03:43 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/6] NFS: use readdir cache array
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS: use readdir cache array

This patch modifies readdir to make use of the new cache array.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2e3f8d1..0fd3782 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -278,35 +278,19 @@ exit:
 	return status;
 }
 
-/* Now we cache directories properly, by stuffing the dirent
- * data directly in the page cache.
- *
- * Inode invalidation due to refresh etc. takes care of
- * _everything_, no sloppy entry flushing logic, no extraneous
- * copying, network direct to page cache, the way it was meant
- * to be.
- *
- * NOTE: Dirent information verification is done always by the
- *	 page-in of the RPC reply, nowhere else, this simplies
- *	 things substantially.
- */
-static
-int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
+/* Fill a page with xdr information before transferring to the cache page */
+static inline
+int nfs_readdir_xdr_filler(struct page *xdr_page, nfs_readdir_descriptor_t *desc,
+			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
-	struct file	*file = desc->file;
-	struct inode	*inode = file->f_path.dentry->d_inode;
 	struct rpc_cred	*cred = nfs_file_cred(file);
 	unsigned long	timestamp, gencount;
 	int		error;
 
-	dfprintk(DIRCACHE, "NFS: %s: reading cookie %Lu into page %lu\n",
-			__func__, (long long)desc->entry->cookie,
-			page->index);
-
  again:
 	timestamp = jiffies;
 	gencount = nfs_inc_attr_generation_counter();
-	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, desc->entry->cookie, page,
+	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, xdr_page,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -320,12 +304,98 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	}
 	desc->timestamp = timestamp;
 	desc->gencount = gencount;
-	desc->timestamp_valid = 1;
+error:
+	return error;
+}
+
+/* Fill in an entry based on the xdr code stored in desc->page */
+static inline
+int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, __be32 **ptr)
+{
+	__be32	*p = *ptr;
+	p = desc->decode(p, entry, desc->plus);
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+	*ptr = p;
+
+	entry->fattr->time_start = desc->timestamp;
+	entry->fattr->gencount = desc->gencount;
+	return 0;
+}
+
+/* Perform conversion from xdr to cache array */
+static inline
+void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
+				struct page *xdr_page, struct page *page)
+{
+	__be32 *ptr = kmap(xdr_page);
+	while (xdr_decode(desc, entry, &ptr) == 0) {
+		if (nfs_readdir_add_to_array(entry, page) == -1)
+			break;
+	}
+	kunmap(xdr_page);
+}
+
+static
+int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
+{
+	struct page *xdr_page;
+	struct nfs_entry entry;
+	struct file	*file = desc->file;
+	struct nfs_cache_array *array;
+	unsigned int status = 0;
+
+	entry.prev_cookie = 0;
+	entry.cookie = *desc->dir_cookie;
+	entry.eof = 0;
+	entry.fh = nfs_alloc_fhandle();
+	entry.fattr = nfs_alloc_fattr();
+	if (entry.fh == NULL || entry.fattr == NULL)
+		goto out;
+
+	array = nfs_readdir_get_array(page);
+	memset(array, 0, sizeof(struct nfs_cache_array));
+	array->eof_index = -1;
+
+	if (page == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	xdr_page = alloc_page(GFP_KERNEL);
+	if (!xdr_page)
+		goto out_put_page;
+	do {
+		status = nfs_readdir_xdr_filler(xdr_page, desc, &entry, file, inode);
+		if (status < 0)
+			break;
+		nfs_readdir_page_filler(desc, &entry, xdr_page, page);
+	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
+
+out_put_page:
+	put_page(xdr_page);
+out:
+	nfs_free_fattr(entry.fattr);
+	nfs_free_fhandle(entry.fh);
+	kunmap(page);
+	return status;
+}
+
+/*
+ * Now we cache directories properly, by converting xdr information
+ * to an array that can be used for lookups later.  This results in
+ * fewer cache pages, since we can store more information on each page.
+ * We only need to convert from xdr once so future lookups are much simpler
+ */
+static
+int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
+{
+	struct inode	*inode = desc->file->f_path.dentry->d_inode;
+
+	if (nfs_readdir_xdr_to_array(desc, page, inode) == -1)
+		goto error;
 	SetPageUptodate(page);
-	/* Ensure consistent page alignment of the data.
-	 * Note: assumes we have exclusive access to this mapping either
-	 *	 through inode->i_mutex or some other mechanism.
-	 */
+
 	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
 		/* Should never happen */
 		nfs_zap_mapping(inode, inode->i_mapping);
@@ -354,14 +424,44 @@ int dir_decode(nfs_readdir_descriptor_t *desc)
 }
 
 static inline
-void dir_page_release(nfs_readdir_descriptor_t *desc)
+void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
 	kunmap(desc->page);
+	unlock_page(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
 	desc->ptr = NULL;
 }
 
+static inline
+struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
+{
+	struct page *page;
+	page = read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
+			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
+	if (IS_ERR(page))
+		desc->eof = 1;
+	return page;
+}
+
+/*
+ * Returns 0 if desc->dir_cookie was found on page desc->page_index
+ */
+static inline
+int find_cache_page(nfs_readdir_descriptor_t *desc)
+{
+	desc->page = get_cache_page(desc);
+	if (IS_ERR(desc->page))
+		return (size_t)desc->page;
+
+	if (nfs_readdir_search_array(desc) == 0)
+		return 0;
+	cache_page_release(desc);
+	if (desc->eof == 1)
+		return -EBADCOOKIE;
+	return -EAGAIN;
+}
+
 /*
  * Given a pointer to a buffer that has already been filled by a call
  * to readdir, find the next entry with cookie '*desc->dir_cookie'.
@@ -459,51 +559,27 @@ int find_dirent_page(nfs_readdir_descriptor_t *desc)
 		status = find_dirent(desc);
 	else
 		status = find_dirent_index(desc);
-	if (status < 0)
-		dir_page_release(desc);
  out:
 	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, status);
 	return status;
 }
 
-/*
- * Recurse through the page cache pages, and return a
- * filled nfs_entry structure of the next directory entry if possible.
- *
- * The target for the search is '*desc->dir_cookie' if non-0,
- * 'desc->file->f_pos' otherwise
- */
+/* Search for desc->dir_cookie from the beginning of the page cache */
 static inline
 int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 {
-	int		loop_count = 0;
-	int		res;
-
-	/* Always search-by-index from the beginning of the cache */
-	if (*desc->dir_cookie == 0) {
-		dfprintk(DIRCACHE, "NFS: readdir_search_pagecache() searching for offset %Ld\n",
-				(long long)desc->file->f_pos);
-		desc->page_index = 0;
-		desc->entry->cookie = desc->entry->prev_cookie = 0;
-		desc->entry->eof = 0;
-		desc->current_index = 0;
-	} else
-		dfprintk(DIRCACHE, "NFS: readdir_search_pagecache() searching for cookie %Lu\n",
-				(unsigned long long)*desc->dir_cookie);
+	int res = -EAGAIN;
+	desc->page_index = 0;
 
-	for (;;) {
-		res = find_dirent_page(desc);
+	if (*desc->dir_cookie == 0)
+		desc->cache_entry_index = 0;
+
+	while (1) {
+		res = find_cache_page(desc);
 		if (res != -EAGAIN)
 			break;
-		/* Align to beginning of next page */
-		desc->page_index ++;
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
+		desc->page_index++;
 	}
-
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, res);
 	return res;
 }
 
@@ -522,49 +598,35 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 		   filldir_t filldir)
 {
 	struct file	*file = desc->file;
-	struct nfs_entry *entry = desc->entry;
-	struct dentry	*dentry = NULL;
-	u64		fileid;
-	int		loop_count = 0,
-			res;
+	int i = 0;
+	int res = 0;
+	struct nfs_cache_array *array = NULL;
+	unsigned int d_type = DT_UNKNOWN;
+	struct dentry *dentry = NULL;
 
-	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling starting @ cookie %Lu\n",
-			(unsigned long long)entry->cookie);
+	array = nfs_readdir_get_array(desc->page);
 
-	for(;;) {
-		unsigned d_type = DT_UNKNOWN;
-		/* Note: entry->prev_cookie contains the cookie for
-		 *	 retrieving the current dirent on the server */
-		fileid = entry->ino;
-
-		/* Get a dentry if we have one */
-		if (dentry != NULL)
-			dput(dentry);
-		dentry = nfs_readdir_lookup(desc);
-
-		/* Use readdirplus info */
-		if (dentry != NULL && dentry->d_inode != NULL) {
-			d_type = dt_type(dentry->d_inode);
-			fileid = NFS_FILEID(dentry->d_inode);
-		}
+	for (i = desc->cache_entry_index; i < array->size; i++) {
+		d_type = DT_UNKNOWN;
 
-		res = filldir(dirent, entry->name, entry->len, 
-			      file->f_pos, nfs_compat_user_ino64(fileid),
-			      d_type);
+		res = filldir(dirent, array->array[i].string.name,
+			array->array[i].string.len, file->f_pos,
+			nfs_compat_user_ino64(array->array[i].ino), d_type);
 		if (res < 0)
 			break;
 		file->f_pos++;
-		*desc->dir_cookie = entry->cookie;
-		if (dir_decode(desc) != 0) {
-			desc->page_index ++;
+		desc->cache_entry_index = i;
+		if (i < (array->size-1))
+			*desc->dir_cookie = array->array[i+1].cookie;
+		else
+			*desc->dir_cookie = array->last_cookie;
+		if (i == array->eof_index) {
+			desc->eof = 1;
 			break;
 		}
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
 	}
-	dir_page_release(desc);
+
+	cache_page_release(desc);
 	if (dentry != NULL)
 		dput(dentry);
 	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
@@ -588,12 +650,9 @@ static inline
 int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		     filldir_t filldir)
 {
-	struct file	*file = desc->file;
-	struct inode	*inode = file->f_path.dentry->d_inode;
-	struct rpc_cred	*cred = nfs_file_cred(file);
 	struct page	*page = NULL;
 	int		status;
-	unsigned long	timestamp, gencount;
+	struct inode *inode = desc->file->f_path.dentry->d_inode;
 
 	dfprintk(DIRCACHE, "NFS: uncached_readdir() searching for cookie %Lu\n",
 			(unsigned long long)*desc->dir_cookie);
@@ -603,38 +662,22 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		status = -ENOMEM;
 		goto out;
 	}
-	timestamp = jiffies;
-	gencount = nfs_inc_attr_generation_counter();
-	status = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred,
-						*desc->dir_cookie, page,
-						NFS_SERVER(inode)->dtsize,
-						desc->plus);
-	desc->page = page;
-	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (status >= 0) {
-		desc->timestamp = timestamp;
-		desc->gencount = gencount;
-		desc->timestamp_valid = 1;
-		if ((status = dir_decode(desc)) == 0)
-			desc->entry->prev_cookie = *desc->dir_cookie;
-	} else
+
+	if (nfs_readdir_xdr_to_array(desc, page, inode) == -1) {
 		status = -EIO;
-	if (status < 0)
 		goto out_release;
+	}
 
+	desc->page = page;
+	kmap(page);
 	status = nfs_do_filldir(desc, dirent, filldir);
 
-	/* Reset read descriptor so it searches the page cache from
-	 * the start upon the next call to readdir_search_pagecache() */
-	desc->page_index = 0;
-	desc->entry->cookie = desc->entry->prev_cookie = 0;
-	desc->entry->eof = 0;
  out:
 	dfprintk(DIRCACHE, "NFS: %s: returns %d\n",
 			__func__, status);
 	return status;
  out_release:
-	dir_page_release(desc);
+	cache_page_release(desc);
 	goto out;
 }
 
@@ -683,12 +726,12 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	if (res < 0)
 		goto out;
 
-	while(!desc->entry->eof) {
+	while (desc->eof != 1) {
 		res = readdir_search_pagecache(desc);
 
 		if (res == -EBADCOOKIE) {
 			/* This means either end of directory */
-			if (*desc->dir_cookie && desc->entry->cookie != *desc->dir_cookie) {
+			if (*desc->dir_cookie && desc->eof == 0) {
 				/* Or that the server has 'lost' a cookie */
 				res = uncached_readdir(desc, dirent, filldir);
 				if (res >= 0)
