Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3926 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757159Ab0JVOOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:39 -0400
Message-ID: <4CC19C3B.4050708@netapp.com>
Date: Fri, 22 Oct 2010 10:14:19 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/10] NFS: add readdir cache array
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch adds the readdir cache array and functions to retreive the array
stored on a cache page, clear the array by freeing allocated memory, add an
entry to the array, and search the array for a given cookie.

It then modifies readdir to make use of the new cache array.
With the new cache array method, we no longer need some of this code.

Finally, nfs_llseek_dir() will set file->f_pos to a value greater than 0 and
desc->dir_cookie to zero.  When we see this, readdir needs to find the file
at position file->f_pos from the start of the directory.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |  632 ++++++++++++++++++++++++++++------------------------------
 1 files changed, 309 insertions(+), 323 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fe549f5..1d4138d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -55,6 +55,7 @@ static int nfs_rename(struct inode *, struct dentry *,
 		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
+static int nfs_readdir_clear_array(struct page*, gfp_t);
 
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
@@ -80,6 +81,10 @@ const struct inode_operations nfs_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 };
 
+const struct address_space_operations nfs_dir_addr_space_ops = {
+	.releasepage = nfs_readdir_clear_array,
+};
+
 #ifdef CONFIG_NFS_V3
 const struct inode_operations nfs3_dir_inode_operations = {
 	.create		= nfs_create,
@@ -151,51 +156,188 @@ nfs_opendir(struct inode *inode, struct file *filp)
 	return res;
 }
 
+struct nfs_cache_array_entry {
+	u64 cookie;
+	u64 ino;
+	struct qstr string;
+};
+
+struct nfs_cache_array {
+	unsigned int size;
+	int eof_index;
+	u64 last_cookie;
+	struct nfs_cache_array_entry array[0];
+};
+
+#define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
+
 typedef __be32 * (*decode_dirent_t)(__be32 *, struct nfs_entry *, int);
 typedef struct {
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
+	unsigned int	cache_entry_index;
+	unsigned int	plus:1;
+	unsigned int	eof:1;
 } nfs_readdir_descriptor_t;
 
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
+/*
+ * The caller is responsible for calling nfs_readdir_release_array(page)
  */
 static
-int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
+struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
+{
+	if (page == NULL)
+		return ERR_PTR(-EIO);
+	return (struct nfs_cache_array *)kmap(page);
+}
+
+static
+void nfs_readdir_release_array(struct page *page)
+{
+	kunmap(page);
+}
+
+/*
+ * we are freeing strings created by nfs_add_to_readdir_array()
+ */
+static
+int nfs_readdir_clear_array(struct page *page, gfp_t mask)
+{
+	struct nfs_cache_array *array = nfs_readdir_get_array(page);
+	int i;
+	for (i = 0; i < array->size; i++)
+		kfree(array->array[i].string.name);
+	nfs_readdir_release_array(page);
+	return 0;
+}
+
+/*
+ * the caller is responsible for freeing qstr.name
+ * when called by nfs_readdir_add_to_array, the strings will be freed in
+ * nfs_clear_readdir_array()
+ */
+static
+void nfs_readdir_make_qstr(struct qstr *string, const char *name, unsigned int len)
+{
+	string->len = len;
+	string->name = kmemdup(name, len, GFP_KERNEL);
+	string->hash = full_name_hash(string->name, string->len);
+}
+
+static
+int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
+{
+	struct nfs_cache_array *array = nfs_readdir_get_array(page);
+	if (IS_ERR(array))
+		return PTR_ERR(array);
+	if (array->size >= MAX_READDIR_ARRAY) {
+		nfs_readdir_release_array(page);
+		return -EIO;
+	}
+
+	array->array[array->size].cookie = entry->prev_cookie;
+	array->last_cookie = entry->cookie;
+	array->array[array->size].ino = entry->ino;
+	nfs_readdir_make_qstr(&array->array[array->size].string, entry->name, entry->len);
+	if (entry->eof == 1)
+		array->eof_index = array->size;
+	array->size++;
+	nfs_readdir_release_array(page);
+	return 0;
+}
+
+static
+int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
+{
+	loff_t diff = desc->file->f_pos - desc->current_index;
+	unsigned int index;
+
+	if (diff < 0)
+		goto out_eof;
+	if (diff >= array->size) {
+		if (array->eof_index > 0)
+			goto out_eof;
+		desc->current_index += array->size;
+		return -EAGAIN;
+	}
+
+	index = (unsigned int)diff;
+	*desc->dir_cookie = array->array[index].cookie;
+	desc->cache_entry_index = index;
+	if (index == array->eof_index)
+		desc->eof = 1;
+	return 0;
+out_eof:
+	desc->eof = 1;
+	return -EBADCOOKIE;
+}
+
+static
+int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
+{
+	int i;
+	int status = -EAGAIN;
+
+	for (i = 0; i < array->size; i++) {
+		if (i == array->eof_index) {
+			desc->eof = 1;
+			status = -EBADCOOKIE;
+		}
+		if (array->array[i].cookie == *desc->dir_cookie) {
+			desc->cache_entry_index = i;
+			status = 0;
+			break;
+		}
+	}
+
+	return status;
+}
+
+static
+int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
+{
+	struct nfs_cache_array *array;
+	int status = -EBADCOOKIE;
+
+	if (desc->dir_cookie == NULL)
+		goto out;
+
+	array = nfs_readdir_get_array(desc->page);
+	if (IS_ERR(array)) {
+		status = PTR_ERR(array);
+		goto out;
+	}
+
+	if (*desc->dir_cookie == 0)
+		status = nfs_readdir_search_for_pos(array, desc);
+	else
+		status = nfs_readdir_search_for_cookie(array, desc);
+
+	nfs_readdir_release_array(desc->page);
+out:
+	return status;
+}
+
+/* Fill a page with xdr information before transferring to the cache page */
+static
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
@@ -209,190 +351,157 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	}
 	desc->timestamp = timestamp;
 	desc->gencount = gencount;
-	desc->timestamp_valid = 1;
-	SetPageUptodate(page);
-	/* Ensure consistent page alignment of the data.
-	 * Note: assumes we have exclusive access to this mapping either
-	 *	 through inode->i_mutex or some other mechanism.
-	 */
-	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
-		/* Should never happen */
-		nfs_zap_mapping(inode, inode->i_mapping);
-	}
-	unlock_page(page);
-	return 0;
- error:
-	unlock_page(page);
-	return -EIO;
+error:
+	return error;
 }
 
-static inline
-int dir_decode(nfs_readdir_descriptor_t *desc)
+/* Fill in an entry based on the xdr code stored in desc->page */
+static
+int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, __be32 **ptr)
 {
-	__be32	*p = desc->ptr;
-	p = desc->decode(p, desc->entry, desc->plus);
+	__be32	*p = *ptr;
+	p = desc->decode(p, entry, desc->plus);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
-	desc->ptr = p;
-	if (desc->timestamp_valid) {
-		desc->entry->fattr->time_start = desc->timestamp;
-		desc->entry->fattr->gencount = desc->gencount;
-	} else
-		desc->entry->fattr->valid &= ~NFS_ATTR_FATTR;
-	return 0;
-}
+	*ptr = p;
 
-static inline
-void dir_page_release(nfs_readdir_descriptor_t *desc)
-{
-	kunmap(desc->page);
-	page_cache_release(desc->page);
-	desc->page = NULL;
-	desc->ptr = NULL;
+	entry->fattr->time_start = desc->timestamp;
+	entry->fattr->gencount = desc->gencount;
+	return 0;
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
+/* Perform conversion from xdr to cache array */
+static
+void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
+				struct page *xdr_page, struct page *page)
 {
-	struct nfs_entry *entry = desc->entry;
-	int		loop_count = 0,
-			status;
-
-	while((status = dir_decode(desc)) == 0) {
-		dfprintk(DIRCACHE, "NFS: %s: examining cookie %Lu\n",
-				__func__, (unsigned long long)entry->cookie);
-		if (entry->prev_cookie == *desc->dir_cookie)
+	__be32 *ptr = kmap(xdr_page);
+	while (xdr_decode(desc, entry, &ptr) == 0) {
+		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
 	}
-	return status;
+	kunmap(xdr_page);
 }
 
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
+static
+int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
 {
-	struct nfs_entry *entry = desc->entry;
-	int		loop_count = 0,
-			status;
-
-	for(;;) {
-		status = dir_decode(desc);
-		if (status)
-			break;
+	struct page *xdr_page;
+	struct nfs_entry entry;
+	struct file	*file = desc->file;
+	struct nfs_cache_array *array;
+	int status = 0;
+
+	entry.prev_cookie = 0;
+	entry.cookie = *desc->dir_cookie;
+	entry.eof = 0;
+	entry.fh = nfs_alloc_fhandle();
+	entry.fattr = nfs_alloc_fattr();
+	if (entry.fh == NULL || entry.fattr == NULL)
+		goto out;
 
-		dfprintk(DIRCACHE, "NFS: found cookie %Lu at index %Ld\n",
-				(unsigned long long)entry->cookie, desc->current_index);
+	array = nfs_readdir_get_array(page);
+	memset(array, 0, sizeof(struct nfs_cache_array));
+	array->eof_index = -1;
 
-		if (desc->file->f_pos == desc->current_index) {
-			*desc->dir_cookie = entry->cookie;
+	xdr_page = alloc_page(GFP_KERNEL);
+	if (!xdr_page)
+		goto out_release_array;
+	do {
+		status = nfs_readdir_xdr_filler(xdr_page, desc, &entry, file, inode);
+		if (status < 0)
 			break;
-		}
-		desc->current_index++;
-		if (loop_count++ > 200) {
-			loop_count = 0;
-			schedule();
-		}
-	}
+		nfs_readdir_page_filler(desc, &entry, xdr_page, page);
+	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
+
+	put_page(xdr_page);
+out_release_array:
+	nfs_readdir_release_array(page);
+out:
+	nfs_free_fattr(entry.fattr);
+	nfs_free_fhandle(entry.fh);
 	return status;
 }
 
 /*
- * Find the given page, and call find_dirent() or find_dirent_index in
- * order to try to return the next entry.
+ * Now we cache directories properly, by converting xdr information
+ * to an array that can be used for lookups later.  This results in
+ * fewer cache pages, since we can store more information on each page.
+ * We only need to convert from xdr once so future lookups are much simpler
  */
-static inline
-int find_dirent_page(nfs_readdir_descriptor_t *desc)
+static
+int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 {
 	struct inode	*inode = desc->file->f_path.dentry->d_inode;
-	struct page	*page;
-	int		status;
 
-	dfprintk(DIRCACHE, "NFS: %s: searching page %ld for target %Lu\n",
-			__func__, desc->page_index,
-			(long long) *desc->dir_cookie);
+	if (nfs_readdir_xdr_to_array(desc, page, inode) == -1)
+		goto error;
+	SetPageUptodate(page);
 
-	/* If we find the page in the page_cache, we cannot be sure
-	 * how fresh the data is, so we will ignore readdir_plus attributes.
-	 */
-	desc->timestamp_valid = 0;
-	page = read_cache_page(inode->i_mapping, desc->page_index,
-			       (filler_t *)nfs_readdir_filler, desc);
-	if (IS_ERR(page)) {
-		status = PTR_ERR(page);
-		goto out;
+	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
+		/* Should never happen */
+		nfs_zap_mapping(inode, inode->i_mapping);
 	}
+	unlock_page(page);
+	return 0;
+ error:
+	unlock_page(page);
+	return -EIO;
+}
 
-	/* NOTE: Someone else may have changed the READDIRPLUS flag */
-	desc->page = page;
-	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (*desc->dir_cookie != 0)
-		status = find_dirent(desc);
-	else
-		status = find_dirent_index(desc);
-	if (status < 0)
-		dir_page_release(desc);
- out:
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, status);
-	return status;
+static
+void cache_page_release(nfs_readdir_descriptor_t *desc)
+{
+	page_cache_release(desc->page);
+	desc->page = NULL;
+}
+
+static
+struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
+{
+	struct page *page;
+	page = read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
+			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
+	if (IS_ERR(page))
+		desc->eof = 1;
+	return page;
 }
 
 /*
- * Recurse through the page cache pages, and return a
- * filled nfs_entry structure of the next directory entry if possible.
- *
- * The target for the search is '*desc->dir_cookie' if non-0,
- * 'desc->file->f_pos' otherwise
+ * Returns 0 if desc->dir_cookie was found on page desc->page_index
  */
+static
+int find_cache_page(nfs_readdir_descriptor_t *desc)
+{
+	int res;
+
+	desc->page = get_cache_page(desc);
+	if (IS_ERR(desc->page))
+		return PTR_ERR(desc->page);
+
+	res = nfs_readdir_search_array(desc);
+	if (res == 0)
+		return 0;
+	cache_page_release(desc);
+	return res;
+}
+
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
 
@@ -401,8 +510,6 @@ static inline unsigned int dt_type(struct inode *inode)
 	return (inode->i_mode >> 12) & 15;
 }
 
-static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc);
-
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
@@ -411,49 +518,36 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 		   filldir_t filldir)
 {
 	struct file	*file = desc->file;
-	struct nfs_entry *entry = desc->entry;
-	struct dentry	*dentry = NULL;
-	u64		fileid;
-	int		loop_count = 0,
-			res;
-
-	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling starting @ cookie %Lu\n",
-			(unsigned long long)entry->cookie);
-
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
+	int i = 0;
+	int res = 0;
+	struct nfs_cache_array *array = NULL;
+	unsigned int d_type = DT_UNKNOWN;
+	struct dentry *dentry = NULL;
 
-		res = filldir(dirent, entry->name, entry->len, 
-			      file->f_pos, nfs_compat_user_ino64(fileid),
-			      d_type);
+	array = nfs_readdir_get_array(desc->page);
+
+	for (i = desc->cache_entry_index; i < array->size; i++) {
+		d_type = DT_UNKNOWN;
+
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
+	nfs_readdir_release_array(desc->page);
+	cache_page_release(desc);
 	if (dentry != NULL)
 		dput(dentry);
 	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
@@ -477,12 +571,9 @@ static inline
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
@@ -492,38 +583,21 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
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
 
@@ -537,7 +611,6 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct inode	*inode = dentry->d_inode;
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
-	struct nfs_entry my_entry;
 	int res = -ENOMEM;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
@@ -558,26 +631,17 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
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
@@ -590,7 +654,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			nfs_zap_caches(inode);
 			desc->plus = 0;
-			desc->entry->eof = 0;
+			desc->eof = 0;
 			continue;
 		}
 		if (res < 0)
@@ -606,9 +670,6 @@ out:
 	nfs_unblock_sillyrename(dentry);
 	if (res > 0)
 		res = 0;
-out_alloc_failed:
-	nfs_free_fattr(my_entry.fattr);
-	nfs_free_fhandle(my_entry.fh);
 	dfprintk(FILE, "NFS: readdir(%s/%s) returns %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			res);
@@ -1281,81 +1342,6 @@ out_err:
 
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
