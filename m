Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay105.isp.belgacom.be ([195.238.20.132]:36384 "EHLO
        mailrelay105.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751670AbdECSwa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 14:52:30 -0400
From: Fabian Frederick <fabf@skynet.be>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        fabf@skynet.be
Subject: [PATCH V3 linux-next] nfs: use kmap/kunmap directly
Date: Wed,  3 May 2017 20:52:21 +0200
Message-Id: <20170503185221.4701-1-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes useless nfs_readdir_get_array() and
nfs_readdir_release_array() as suggested by Trond Myklebust

nfs_readdir() calls nfs_revalidate_mapping() before
readdir_search_pagecache() , nfs_do_filldir(), uncached_readdir()
so mapping should be correct.

While kmap() can't fail, all subsequent error checks were removed
as well as unused labels.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V3:
	-Remove nfs_readdir_get_array()/release_array() (suggested by Trond Myklebust)
	-Remove subsequent checks

V2:
	-Remove ptr and return kmap(page) directly (suggested by Anna Schumaker)

 fs/nfs/dir.c | 67 +++++++++++-------------------------------------------------
 1 file changed, 12 insertions(+), 55 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3a188cb..32ccd77 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -170,27 +170,6 @@ typedef struct {
 } nfs_readdir_descriptor_t;
 
 /*
- * The caller is responsible for calling nfs_readdir_release_array(page)
- */
-static
-struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
-{
-	void *ptr;
-	if (page == NULL)
-		return ERR_PTR(-EIO);
-	ptr = kmap(page);
-	if (ptr == NULL)
-		return ERR_PTR(-ENOMEM);
-	return ptr;
-}
-
-static
-void nfs_readdir_release_array(struct page *page)
-{
-	kunmap(page);
-}
-
-/*
  * we are freeing strings created by nfs_add_to_readdir_array()
  */
 static
@@ -229,13 +208,10 @@ int nfs_readdir_make_qstr(struct qstr *string, const char *name, unsigned int le
 static
 int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 {
-	struct nfs_cache_array *array = nfs_readdir_get_array(page);
+	struct nfs_cache_array *array = kmap(page);
 	struct nfs_cache_array_entry *cache_entry;
 	int ret;
 
-	if (IS_ERR(array))
-		return PTR_ERR(array);
-
 	cache_entry = &array->array[array->size];
 
 	/* Check that this entry lies within the page bounds */
@@ -254,7 +230,7 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 	if (entry->eof != 0)
 		array->eof_index = array->size;
 out:
-	nfs_readdir_release_array(page);
+	kunmap(page);
 	return ret;
 }
 
@@ -343,11 +319,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 	struct nfs_cache_array *array;
 	int status;
 
-	array = nfs_readdir_get_array(desc->page);
-	if (IS_ERR(array)) {
-		status = PTR_ERR(array);
-		goto out;
-	}
+	array = kmap(desc->page);
 
 	if (*desc->dir_cookie == 0)
 		status = nfs_readdir_search_for_pos(array, desc);
@@ -359,8 +331,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 		desc->current_index += array->size;
 		desc->page_index++;
 	}
-	nfs_readdir_release_array(desc->page);
-out:
+	kunmap(desc->page);
 	return status;
 }
 
@@ -596,13 +567,10 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 
 out_nopages:
 	if (count == 0 || (status == -EBADCOOKIE && entry->eof != 0)) {
-		array = nfs_readdir_get_array(page);
-		if (!IS_ERR(array)) {
-			array->eof_index = array->size;
-			status = 0;
-			nfs_readdir_release_array(page);
-		} else
-			status = PTR_ERR(array);
+		array = kmap(page);
+		array->eof_index = array->size;
+		status = 0;
+		kunmap(page);
 	}
 
 	put_page(scratch);
@@ -664,11 +632,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out;
 	}
 
-	array = nfs_readdir_get_array(page);
-	if (IS_ERR(array)) {
-		status = PTR_ERR(array);
-		goto out_label_free;
-	}
+	array = kmap(page);
 	memset(array, 0, sizeof(struct nfs_cache_array));
 	array->eof_index = -1;
 
@@ -692,8 +656,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 
 	nfs_readdir_free_pages(pages, array_size);
 out_release_array:
-	nfs_readdir_release_array(page);
-out_label_free:
+	kunmap(page);
 	nfs4_label_free(entry.label);
 out:
 	nfs_free_fattr(entry.fattr);
@@ -791,12 +754,7 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
 	struct nfs_cache_array *array = NULL;
 	struct nfs_open_dir_context *ctx = file->private_data;
 
-	array = nfs_readdir_get_array(desc->page);
-	if (IS_ERR(array)) {
-		res = PTR_ERR(array);
-		goto out;
-	}
-
+	array = kmap(desc->page);
 	for (i = desc->cache_entry_index; i < array->size; i++) {
 		struct nfs_cache_array_entry *ent;
 
@@ -817,8 +775,7 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
 	if (array->eof_index >= 0)
 		desc->eof = 1;
 
-	nfs_readdir_release_array(desc->page);
-out:
+	kunmap(desc->page);
 	cache_page_release(desc);
 	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
 			(unsigned long long)*desc->dir_cookie, res);
-- 
2.9.3

