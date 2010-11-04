Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4135 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab0KDQHq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Nov 2010 12:07:46 -0400
Subject: Re: [regression] NFS readdir change break fully cached nfs root
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Bowler <nbowler@elliptictech.com>
Cc: Andi Kleen <andi@firstfloor.org>, bjschuma@netapp.com,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <20101103162423.GA3797@elliptictech.com>
References: <20101102180051.GA26089@basil.fritz.box>
	 <1288731930.534.1.camel@heimdal.trondhjem.org>
	 <20101103162423.GA3797@elliptictech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 12:06:54 -0400
Message-ID: <1288886814.3285.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-11-03 at 12:24 -0400, Nick Bowler wrote:
> I applied this patch, and it solves the lockups, but there's a new
> problem: the directory list sometimes comes back _empty_!
> 
> Here's the test script I used:
> 
>   #!/bin/sh -e
>   
>   mkdir gittest
>   cd gittest
>   git init
>   
>   for i in `seq 500`
>   do
>   	printf 'Hello\nWorld!\n' > $i.txt
>   done
>   
>   git add ./*.txt
>   git commit -m 'Initial Commit'
>   sed -i 1d ./*.txt
>   git stash
>   git stash pop
>   
>   echo 'Directory listing:'
>   ls
> 
> the 'ls' at the end prints nothing when the directory actually contains
> 500 files.  If we insert an 'ls' just before the 'git stash pop', that
> one prints the full listing.  Touching the directory afterwards makes
> the listings work again.
> 
> The script works fine on 2.6.36.

I found a couple more issues. Can you try this revision of the same
patch?

Cheers
  Trond
-------------------------------------------------------------------------------------------
NFS: Fix a couple of regressions in readdir.

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix up the issue that array->eof_index needs to be able to be set
even if array->size == 0.

Ensure that we catch all important memory allocation error conditions
and/or kmap() failures.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |   90 ++++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 56 insertions(+), 34 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 07ac384..4c6968b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -194,9 +194,13 @@ typedef struct {
 static
 struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
 {
+	void *ptr;
 	if (page == NULL)
 		return ERR_PTR(-EIO);
-	return (struct nfs_cache_array *)kmap(page);
+	ptr = kmap(page);
+	if (ptr == NULL)
+		return ERR_PTR(-ENOMEM);
+	return ptr;
 }
 
 static
@@ -213,6 +217,9 @@ int nfs_readdir_clear_array(struct page *page, gfp_t mask)
 {
 	struct nfs_cache_array *array = nfs_readdir_get_array(page);
 	int i;
+
+	if (IS_ERR(array))
+		return PTR_ERR(array);
 	for (i = 0; i < array->size; i++)
 		kfree(array->array[i].string.name);
 	nfs_readdir_release_array(page);
@@ -244,7 +251,7 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 
 	if (IS_ERR(array))
 		return PTR_ERR(array);
-	ret = -EIO;
+	ret = -ENOSPC;
 	if (array->size >= MAX_READDIR_ARRAY)
 		goto out;
 
@@ -255,9 +262,9 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 	if (ret)
 		goto out;
 	array->last_cookie = entry->cookie;
+	array->size++;
 	if (entry->eof == 1)
 		array->eof_index = array->size;
-	array->size++;
 out:
 	nfs_readdir_release_array(page);
 	return ret;
@@ -272,7 +279,7 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
 	if (diff < 0)
 		goto out_eof;
 	if (diff >= array->size) {
-		if (array->eof_index > 0)
+		if (array->eof_index >= 0)
 			goto out_eof;
 		desc->current_index += array->size;
 		return -EAGAIN;
@@ -281,8 +288,6 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
 	index = (unsigned int)diff;
 	*desc->dir_cookie = array->array[index].cookie;
 	desc->cache_entry_index = index;
-	if (index == array->eof_index)
-		desc->eof = 1;
 	return 0;
 out_eof:
 	desc->eof = 1;
@@ -296,17 +301,17 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 	int status = -EAGAIN;
 
 	for (i = 0; i < array->size; i++) {
-		if (i == array->eof_index) {
-			desc->eof = 1;
-			status = -EBADCOOKIE;
-		}
 		if (array->array[i].cookie == *desc->dir_cookie) {
 			desc->cache_entry_index = i;
 			status = 0;
-			break;
+			goto out;
 		}
 	}
-
+	if (i == array->eof_index) {
+		desc->eof = 1;
+		status = -EBADCOOKIE;
+	}
+out:
 	return status;
 }
 
@@ -449,7 +454,7 @@ out:
 
 /* Perform conversion from xdr to cache array */
 static
-void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
+int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
 				void *xdr_page, struct page *page, unsigned int buflen)
 {
 	struct xdr_stream stream;
@@ -471,21 +476,29 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 
 	do {
 		status = xdr_decode(desc, entry, &stream);
-		if (status != 0)
+		if (status != 0) {
+			if (status == -EAGAIN)
+				status = 0;
 			break;
+		}
 
-		if (nfs_readdir_add_to_array(entry, page) == -1)
-			break;
 		if (desc->plus == 1)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
+
+		status = nfs_readdir_add_to_array(entry, page);
+		if (status != 0)
+			break;
 	} while (!entry->eof);
 
 	if (status == -EBADCOOKIE && entry->eof) {
 		array = nfs_readdir_get_array(page);
-		array->eof_index = array->size - 1;
-		status = 0;
-		nfs_readdir_release_array(page);
+		if (!IS_ERR(array)) {
+			array->eof_index = array->size;
+			status = 0;
+			nfs_readdir_release_array(page);
+		}
 	}
+	return status;
 }
 
 static
@@ -537,7 +550,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	struct nfs_entry entry;
 	struct file	*file = desc->file;
 	struct nfs_cache_array *array;
-	int status = 0;
+	int status = -ENOMEM;
 	unsigned int array_size = ARRAY_SIZE(pages);
 
 	entry.prev_cookie = 0;
@@ -549,6 +562,10 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out;
 
 	array = nfs_readdir_get_array(page);
+	if (IS_ERR(array)) {
+		status = PTR_ERR(array);
+		goto out;
+	}
 	memset(array, 0, sizeof(struct nfs_cache_array));
 	array->eof_index = -1;
 
@@ -560,8 +577,13 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 
 		if (status < 0)
 			break;
-		nfs_readdir_page_filler(desc, &entry, pages_ptr, page, array_size * PAGE_SIZE);
-	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
+		status = nfs_readdir_page_filler(desc, &entry, pages_ptr, page, array_size * PAGE_SIZE);
+		if (status < 0) {
+			if (status == -ENOSPC)
+				status = 0;
+			break;
+		}
+	} while (array->eof_index < 0);
 
 	nfs_readdir_free_large_page(pages_ptr, pages, array_size);
 out_release_array:
@@ -582,8 +604,10 @@ static
 int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 {
 	struct inode	*inode = desc->file->f_path.dentry->d_inode;
+	int ret;
 
-	if (nfs_readdir_xdr_to_array(desc, page, inode) < 0)
+	ret = nfs_readdir_xdr_to_array(desc, page, inode);
+	if (ret < 0)
 		goto error;
 	SetPageUptodate(page);
 
@@ -595,7 +619,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 	return 0;
  error:
 	unlock_page(page);
-	return -EIO;
+	return ret;
 }
 
 static
@@ -608,12 +632,8 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 static
 struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
 {
-	struct page *page;
-	page = read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
+	return read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
 			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
-	if (IS_ERR(page))
-		desc->eof = 1;
-	return page;
 }
 
 /*
@@ -639,8 +659,10 @@ int find_cache_page(nfs_readdir_descriptor_t *desc)
 static inline
 int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 {
-	int res = -EAGAIN;
+	int res;
 
+	if (desc->page_index == 0)
+		desc->current_index = 0;
 	while (1) {
 		res = find_cache_page(desc);
 		if (res != -EAGAIN)
@@ -670,6 +692,8 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	struct dentry *dentry = NULL;
 
 	array = nfs_readdir_get_array(desc->page);
+	if (IS_ERR(array))
+		return PTR_ERR(array);
 
 	for (i = desc->cache_entry_index; i < array->size; i++) {
 		d_type = DT_UNKNOWN;
@@ -685,11 +709,9 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 			*desc->dir_cookie = array->array[i+1].cookie;
 		else
 			*desc->dir_cookie = array->last_cookie;
-		if (i == array->eof_index) {
-			desc->eof = 1;
-			break;
-		}
 	}
+	if (i == array->eof_index)
+		desc->eof = 1;
 
 	nfs_readdir_release_array(desc->page);
 	cache_page_release(desc);



