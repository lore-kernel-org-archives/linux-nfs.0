Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26345 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751204AbdCNHIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:08:12 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 12/12] fs, nfs: convert nfs_cache_array.refcount from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:20 +0200
Message-Id: <1489475240-6594-13-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfs/dir.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fad8104..0c95d2b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -145,7 +145,7 @@ struct nfs_cache_array_entry {
 };
 
 struct nfs_cache_array {
-	atomic_t refcount;
+	refcount_t refcount;
 	int size;
 	int eof_index;
 	u64 last_cookie;
@@ -201,7 +201,7 @@ void nfs_readdir_clear_array(struct page *page)
 	int i;
 
 	array = kmap_atomic(page);
-	if (atomic_dec_and_test(&array->refcount))
+	if (refcount_dec_and_test(&array->refcount))
 		for (i = 0; i < array->size; i++)
 			kfree(array->array[i].string.name);
 	kunmap_atomic(array);
@@ -210,7 +210,7 @@ void nfs_readdir_clear_array(struct page *page)
 static bool grab_page(struct page *page)
 {
 	struct nfs_cache_array *array = kmap_atomic(page);
-	bool res = atomic_inc_not_zero(&array->refcount);
+	bool res = refcount_inc_not_zero(&array->refcount);
 	kunmap_atomic(array);
 	return res;
 }
@@ -680,7 +680,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out_label_free;
 	}
 	memset(array, 0, sizeof(struct nfs_cache_array));
-	atomic_set(&array->refcount, 1);
+	refcount_set(&array->refcount, 1);
 	array->eof_index = -1;
 
 	status = nfs_readdir_alloc_pages(pages, array_size);
-- 
2.7.4

