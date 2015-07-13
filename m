Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4156 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060AbbGMSCD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:02:03 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 01/10] NFS: Remove unused variable "pages_ptr"
Date: Mon, 13 Jul 2015 14:01:24 -0400
Message-ID: <1436810493-22806-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This variable is initialized to NULL and is never modified before being
passed to nfs_readdir_free_large_page().  But that's okay, because
nfs_readdir_free_large_page() only seems to exist as a way of calling
nfs_readdir_free_pagearray() without this parameter.  Let's simplify by
removing pages_ptr and nfs_readdir_free_pagearray().

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/dir.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 21457bb..ecb8ed5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -590,16 +590,9 @@ void nfs_readdir_free_pagearray(struct page **pages, unsigned int npages)
 		put_page(pages[i]);
 }
 
-static
-void nfs_readdir_free_large_page(void *ptr, struct page **pages,
-		unsigned int npages)
-{
-	nfs_readdir_free_pagearray(pages, npages);
-}
-
 /*
  * nfs_readdir_large_page will allocate pages that must be freed with a call
- * to nfs_readdir_free_large_page
+ * to nfs_readdir_free_pagearray
  */
 static
 int nfs_readdir_large_page(struct page **pages, unsigned int npages)
@@ -623,7 +616,6 @@ static
 int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
 {
 	struct page *pages[NFS_MAX_READDIR_PAGES];
-	void *pages_ptr = NULL;
 	struct nfs_entry entry;
 	struct file	*file = desc->file;
 	struct nfs_cache_array *array;
@@ -671,7 +663,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		}
 	} while (array->eof_index < 0);
 
-	nfs_readdir_free_large_page(pages_ptr, pages, array_size);
+	nfs_readdir_free_pagearray(pages, array_size);
 out_release_array:
 	nfs_readdir_release_array(page);
 out_label_free:
-- 
2.4.5

