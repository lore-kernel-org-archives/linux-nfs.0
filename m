Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35320 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbcEAAST (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 20:18:19 -0400
Date: Sun, 1 May 2016 01:18:16 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160501001816.GH25498@ZenIV.linux.org.uk>
References: <1462022576.10011.22.camel@poochiereds.net>
 <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
 <20160430185836.GC25498@ZenIV.linux.org.uk>
 <20160430192931.GD25498@ZenIV.linux.org.uk>
 <1462048765.10011.44.camel@poochiereds.net>
 <20160430205705.GE25498@ZenIV.linux.org.uk>
 <1462055616.10011.62.camel@poochiereds.net>
 <20160430233138.GF25498@ZenIV.linux.org.uk>
 <20160501000254.GG25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160501000254.GG25498@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 01, 2016 at 01:02:55AM +0100, Al Viro wrote:
> I wonder if we ought to put a counter into nfs_cache_array, initialized to 1
> (in nfs_readdir_xdr_to_array()), bumped in get_cache_page() and decremented
> both in cache_page_release() and in ->freepage().  With actual freeing
> of names happening only when the sucker reaches 0, and get_cache_page()
> treating "oops, it's already 0, someone has just evicted it from page cache"
> as "page_cache_release() and retry".  Objections?

Something like (completely untested)
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index da109e6..037bfb4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -145,6 +145,7 @@ struct nfs_cache_array_entry {
 };
 
 struct nfs_cache_array {
+	atomic_t refcount;
 	int size;
 	int eof_index;
 	u64 last_cookie;
@@ -200,11 +201,20 @@ void nfs_readdir_clear_array(struct page *page)
 	int i;
 
 	array = kmap_atomic(page);
-	for (i = 0; i < array->size; i++)
-		kfree(array->array[i].string.name);
+	if (atomic_dec_and_test(&array->refcount))
+		for (i = 0; i < array->size; i++)
+			kfree(array->array[i].string.name);
 	kunmap_atomic(array);
 }
 
+static bool grab_page(struct page *page)
+{
+	struct nfs_cache_array *array = kmap_atomic(page);
+	bool res = atomic_inc_not_zero(&array->refcount);
+	kunmap_atomic(array);
+	return res;
+}
+
 /*
  * the caller is responsible for freeing qstr.name
  * when called by nfs_readdir_add_to_array, the strings will be freed in
@@ -645,6 +655,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out_label_free;
 	}
 	memset(array, 0, sizeof(struct nfs_cache_array));
+	atomic_set(&array->refcount, 1);
 	array->eof_index = -1;
 
 	status = nfs_readdir_alloc_pages(pages, array_size);
@@ -707,8 +718,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
-	if (!desc->page->mapping)
-		nfs_readdir_clear_array(desc->page);
+	nfs_readdir_clear_array(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
 }
@@ -716,8 +726,16 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 static
 struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
 {
-	return read_cache_page(file_inode(desc->file)->i_mapping,
+	struct page *page;
+
+	for (;;) {
+		page = read_cache_page(file_inode(desc->file)->i_mapping,
 			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
+		if (IS_ERR(page) || grab_page(page))
+			break;
+		page_cache_release(page);
+	}
+	return page;
 }
 
 /*
