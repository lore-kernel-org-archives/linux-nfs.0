Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932482AbdCJWHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 17:07:49 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2] NFS: switch back to to ->iterate()
Date: Fri, 10 Mar 2017 17:07:46 -0500
Message-Id: <4a243778db6f9ccd052364ba2e4dded4390d1cc0.1489183437.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS has some optimizations for readdir to choose between using READDIR or
READDIRPLUS based on workload, and which NFS operation to use is determined
by subsequent interactions with lookup, d_revalidate, and getattr.

Concurrent use of nfs_readdir() via ->iterate_shared() can cause those
optimizations to repeatedly invalidate the pagecache used to store
directory entries during readdir(), which causes some very bad performance
for directories with many entries (more than about 10000).

There's a couple ways to fix this in NFS, but no fix would be as simple as
going back to ->iterate() to serialize nfs_readdir(), and neither fix I
tested performed as well as going back to ->iterate().

The first required taking the directory's i_lock for each entry, with the
result of terrible contention.

The second way adds another flag to the nfs_inode, and so keeps the
optimizations working for large directories.  The difference from using
->iterate() here is that much more memory is consumed for a given workload
without any performance gain.

The workings of nfs_readdir() are such that concurrent users are serialized
within read_cache_page() waiting to retrieve pages of entries from the
server.  By serializing this work in iterate_dir() instead, contention for
cache pages is reduced.  Waiting processes can have an uncontended pass at
the entirety of the directory's pagecache once previous processes have
completed filling it.

v2 - Keep the bits needed for parallel lookup

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 37 ++++++++++++-------------------------
 1 file changed, 12 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fad81041f5ab..18cdf11a1720 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -57,7 +57,7 @@ static void nfs_readdir_clear_array(struct page*);
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
 	.read		= generic_read_dir,
-	.iterate_shared	= nfs_readdir,
+	.iterate	= nfs_readdir,
 	.open		= nfs_opendir,
 	.release	= nfs_closedir,
 	.fsync		= nfs_fsync_dir,
@@ -145,7 +145,6 @@ struct nfs_cache_array_entry {
 };
 
 struct nfs_cache_array {
-	atomic_t refcount;
 	int size;
 	int eof_index;
 	u64 last_cookie;
@@ -201,20 +200,11 @@ void nfs_readdir_clear_array(struct page *page)
 	int i;
 
 	array = kmap_atomic(page);
-	if (atomic_dec_and_test(&array->refcount))
-		for (i = 0; i < array->size; i++)
-			kfree(array->array[i].string.name);
+	for (i = 0; i < array->size; i++)
+		kfree(array->array[i].string.name);
 	kunmap_atomic(array);
 }
 
-static bool grab_page(struct page *page)
-{
-	struct nfs_cache_array *array = kmap_atomic(page);
-	bool res = atomic_inc_not_zero(&array->refcount);
-	kunmap_atomic(array);
-	return res;
-}
-
 /*
  * the caller is responsible for freeing qstr.name
  * when called by nfs_readdir_add_to_array, the strings will be freed in
@@ -680,7 +670,6 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out_label_free;
 	}
 	memset(array, 0, sizeof(struct nfs_cache_array));
-	atomic_set(&array->refcount, 1);
 	array->eof_index = -1;
 
 	status = nfs_readdir_alloc_pages(pages, array_size);
@@ -743,7 +732,8 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
-	nfs_readdir_clear_array(desc->page);
+	if (!desc->page->mapping)
+		nfs_readdir_clear_array(desc->page);
 	put_page(desc->page);
 	desc->page = NULL;
 }
@@ -751,16 +741,8 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 static
 struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
 {
-	struct page *page;
-
-	for (;;) {
-		page = read_cache_page(desc->file->f_mapping,
+	return read_cache_page(desc->file->f_mapping,
 			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
-		if (IS_ERR(page) || grab_page(page))
-			break;
-		put_page(page);
-	}
-	return page;
 }
 
 /*
@@ -966,11 +948,13 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 
 static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 {
+	struct inode *inode = file_inode(filp);
 	struct nfs_open_dir_context *dir_ctx = filp->private_data;
 
 	dfprintk(FILE, "NFS: llseek dir(%pD2, %lld, %d)\n",
 			filp, offset, whence);
 
+	inode_lock(inode);
 	switch (whence) {
 		case 1:
 			offset += filp->f_pos;
@@ -978,13 +962,16 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 			if (offset >= 0)
 				break;
 		default:
-			return -EINVAL;
+			offset = -EINVAL;
+			goto out;
 	}
 	if (offset != filp->f_pos) {
 		filp->f_pos = offset;
 		dir_ctx->dir_cookie = 0;
 		dir_ctx->duped = 0;
 	}
+out:
+	inode_unlock(inode);
 	return offset;
 }
 
-- 
2.9.3

