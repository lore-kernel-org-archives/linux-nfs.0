Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997Ab0LGWQz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Dec 2010 17:16:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] NFS: Readdir cleanups
Date: Tue,  7 Dec 2010 17:16:48 -0500
Message-Id: <1291760208-11251-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291760208-11251-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1291760208-11251-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

No functional changes, but clarify the code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   47 +++++++++++++++++------------------------------
 1 files changed, 17 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ad2fde2..996dd89 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -271,7 +271,7 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 		goto out;
 	array->last_cookie = entry->cookie;
 	array->size++;
-	if (entry->eof == 1)
+	if (entry->eof != 0)
 		array->eof_index = array->size;
 out:
 	nfs_readdir_release_array(page);
@@ -311,16 +311,14 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 	for (i = 0; i < array->size; i++) {
 		if (array->array[i].cookie == *desc->dir_cookie) {
 			desc->cache_entry_index = i;
-			status = 0;
-			goto out;
+			return 0;
 		}
 	}
-	if (i == array->eof_index) {
+	if (array->eof_index >= 0) {
 		status = -EBADCOOKIE;
 		if (*desc->dir_cookie == array->last_cookie)
 			desc->eof = 1;
 	}
-out:
 	return status;
 }
 
@@ -328,10 +326,7 @@ static
 int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 {
 	struct nfs_cache_array *array;
-	int status = -EBADCOOKIE;
-
-	if (desc->dir_cookie == NULL)
-		goto out;
+	int status;
 
 	array = nfs_readdir_get_array(desc->page);
 	if (IS_ERR(array)) {
@@ -344,8 +339,10 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 	else
 		status = nfs_readdir_search_for_cookie(array, desc);
 
-	if (status == -EAGAIN)
+	if (status == -EAGAIN) {
 		desc->last_cookie = array->last_cookie;
+		desc->page_index++;
+	}
 	nfs_readdir_release_array(desc->page);
 out:
 	return status;
@@ -492,7 +489,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 
 		count++;
 
-		if (desc->plus == 1)
+		if (desc->plus != 0)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 
 		status = nfs_readdir_add_to_array(entry, page);
@@ -500,7 +497,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 			break;
 	} while (!entry->eof);
 
-	if (count == 0 || (status == -EBADCOOKIE && entry->eof == 1)) {
+	if (count == 0 || (status == -EBADCOOKIE && entry->eof != 0)) {
 		array = nfs_readdir_get_array(page);
 		if (!IS_ERR(array)) {
 			array->eof_index = array->size;
@@ -664,9 +661,8 @@ int find_cache_page(nfs_readdir_descriptor_t *desc)
 		return PTR_ERR(desc->page);
 
 	res = nfs_readdir_search_array(desc);
-	if (res == 0)
-		return 0;
-	cache_page_release(desc);
+	if (res != 0)
+		cache_page_release(desc);
 	return res;
 }
 
@@ -680,20 +676,12 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 		desc->current_index = 0;
 		desc->last_cookie = 0;
 	}
-	while (1) {
+	do {
 		res = find_cache_page(desc);
-		if (res != -EAGAIN)
-			break;
-		desc->page_index++;
-	}
+	} while (res == -EAGAIN);
 	return res;
 }
 
-static inline unsigned int dt_type(struct inode *inode)
-{
-	return (inode->i_mode >> 12) & 15;
-}
-
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
@@ -723,13 +711,12 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 			break;
 		}
 		file->f_pos++;
-		desc->cache_entry_index = i;
 		if (i < (array->size-1))
 			*desc->dir_cookie = array->array[i+1].cookie;
 		else
 			*desc->dir_cookie = array->last_cookie;
 	}
-	if (i == array->eof_index)
+	if (array->eof_index >= 0)
 		desc->eof = 1;
 
 	nfs_readdir_release_array(desc->page);
@@ -798,7 +785,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct inode	*inode = dentry->d_inode;
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
-	int res = -ENOMEM;
+	int res;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -823,7 +810,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	if (res < 0)
 		goto out;
 
-	while (desc->eof != 1) {
+	do {
 		res = readdir_search_pagecache(desc);
 
 		if (res == -EBADCOOKIE) {
@@ -851,7 +838,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 		res = nfs_do_filldir(desc, dirent, filldir);
 		if (res < 0)
 			break;
-	}
+	} while (!desc->eof);
 out:
 	nfs_unblock_sillyrename(dentry);
 	if (res > 0)
-- 
1.7.3.2

