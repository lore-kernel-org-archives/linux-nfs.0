Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35255 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbaHFOMw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 10:12:52 -0400
Date: Wed, 6 Aug 2014 19:42:48 +0530
From: Himangi Saraogi <himangi774@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: julia.lawall@lip6.fr
Subject: [PATCH] nfs: Remove typedef nfs_readdir_descriptor_t
Message-ID: <20140806141248.GA15627@himangi-Dell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedef for
nfs_readdir_descriptor_t. Also the names of the struct is changed to
drop the _t, to make the name look less typedef-like.

The following Coccinelle semantic patch detects the case.

@tn1@
type td;
@@

typedef struct { ... } td;

@script:python tf@
td << tn1.td;
tdres;
@@

coccinelle.tdres = td;

@@
type tn1.td;
identifier tf.tdres;
@@

-typedef
 struct
+  tdres
   { ... }
-td
 ;

@@
type tn1.td;
identifier tf.tdres;
@@

(
-td
+ struct tdres
|
 const
- td
+ struct tdres
)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 fs/nfs/dir.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7e17687..ba5bb19 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -152,7 +152,7 @@ struct nfs_cache_array {
 };
 
 typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, int);
-typedef struct {
+struct nfs_readdir_descriptor {
 	struct file	*file;
 	struct page	*page;
 	struct dir_context *ctx;
@@ -167,7 +167,7 @@ typedef struct {
 	unsigned int	cache_entry_index;
 	unsigned int	plus:1;
 	unsigned int	eof:1;
-} nfs_readdir_descriptor_t;
+};
 
 /*
  * The caller is responsible for calling nfs_readdir_release_array(page)
@@ -259,7 +259,8 @@ out:
 }
 
 static
-int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
+int nfs_readdir_search_for_pos(struct nfs_cache_array *array,
+			       struct nfs_readdir_descriptor *desc)
 {
 	loff_t diff = desc->ctx->pos - desc->current_index;
 	unsigned int index;
@@ -291,7 +292,8 @@ nfs_readdir_inode_mapping_valid(struct nfs_inode *nfsi)
 }
 
 static
-int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
+int nfs_readdir_search_for_cookie(struct nfs_cache_array *array,
+				  struct nfs_readdir_descriptor *desc)
 {
 	int i;
 	loff_t new_pos;
@@ -338,7 +340,7 @@ out:
 }
 
 static
-int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
+int nfs_readdir_search_array(struct nfs_readdir_descriptor *desc)
 {
 	struct nfs_cache_array *array;
 	int status;
@@ -366,7 +368,8 @@ out:
 
 /* Fill a page with xdr information before transferring to the cache page */
 static
-int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
+int nfs_readdir_xdr_filler(struct page **pages,
+			   struct nfs_readdir_descriptor *desc,
 			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
 	struct nfs_open_dir_context *ctx = file->private_data;
@@ -395,7 +398,7 @@ error:
 	return error;
 }
 
-static int xdr_decode(nfs_readdir_descriptor_t *desc,
+static int xdr_decode(struct nfs_readdir_descriptor *desc,
 		      struct nfs_entry *entry, struct xdr_stream *xdr)
 {
 	int error;
@@ -515,7 +518,8 @@ out:
 
 /* Perform conversion from xdr to cache array */
 static
-int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
+int nfs_readdir_page_filler(struct nfs_readdir_descriptor *desc,
+			    struct nfs_entry *entry,
 				struct page **xdr_pages, struct page *page, unsigned int buflen)
 {
 	struct xdr_stream stream;
@@ -602,7 +606,8 @@ out_freepages:
 }
 
 static
-int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
+int nfs_readdir_xdr_to_array(struct nfs_readdir_descriptor *desc,
+			     struct page *page, struct inode *inode)
 {
 	struct page *pages[NFS_MAX_READDIR_PAGES];
 	void *pages_ptr = NULL;
@@ -671,7 +676,8 @@ out:
  * We only need to convert from xdr once so future lookups are much simpler
  */
 static
-int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
+int nfs_readdir_filler(struct nfs_readdir_descriptor *desc,
+		       struct page *page)
 {
 	struct inode	*inode = file_inode(desc->file);
 	int ret;
@@ -693,7 +699,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 }
 
 static
-void cache_page_release(nfs_readdir_descriptor_t *desc)
+void cache_page_release(struct nfs_readdir_descriptor *desc)
 {
 	if (!desc->page->mapping)
 		nfs_readdir_clear_array(desc->page);
@@ -702,7 +708,7 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 }
 
 static
-struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
+struct page *get_cache_page(struct nfs_readdir_descriptor *desc)
 {
 	return read_cache_page(file_inode(desc->file)->i_mapping,
 			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
@@ -712,7 +718,7 @@ struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
  * Returns 0 if desc->dir_cookie was found on page desc->page_index
  */
 static
-int find_cache_page(nfs_readdir_descriptor_t *desc)
+int find_cache_page(struct nfs_readdir_descriptor *desc)
 {
 	int res;
 
@@ -728,7 +734,7 @@ int find_cache_page(nfs_readdir_descriptor_t *desc)
 
 /* Search for desc->dir_cookie from the beginning of the page cache */
 static inline
-int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
+int readdir_search_pagecache(struct nfs_readdir_descriptor *desc)
 {
 	int res;
 
@@ -746,7 +752,7 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
 static 
-int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
+int nfs_do_filldir(struct nfs_readdir_descriptor *desc)
 {
 	struct file	*file = desc->file;
 	int i = 0;
@@ -801,7 +807,7 @@ out:
  *	 directory in the page cache by the time we get here.
  */
 static inline
-int uncached_readdir(nfs_readdir_descriptor_t *desc)
+int uncached_readdir(struct nfs_readdir_descriptor *desc)
 {
 	struct page	*page = NULL;
 	int		status;
@@ -856,7 +862,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 {
 	struct dentry	*dentry = file->f_path.dentry;
 	struct inode	*inode = dentry->d_inode;
-	nfs_readdir_descriptor_t my_desc,
+	struct nfs_readdir_descriptor my_desc,
 			*desc = &my_desc;
 	struct nfs_open_dir_context *dir_ctx = file->private_data;
 	int res = 0;
-- 
1.9.1

