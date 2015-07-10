Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:13056 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932476AbbGJVFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 17:05:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 2/9] NFS: Rename nfs_readdir_free_pagearray() and nfs_readdir_large_page()
Date: Fri, 10 Jul 2015 16:58:10 -0400
Message-ID: <1436561897-8051-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_readdir_xdr_to_array() uses both a cache array and an array of
pages, so I rename these functions to make it clearer how the code
works.  nfs_readdir_large_page() becomes nfs_readdir_alloc_pages()
because this function has absolutely nothing to do with setting up a
large page.  nfs_readdir_free_pagearray() becomes
nfs_readdir_free_pages() to stay consistent with the new alloc_pages()
function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/dir.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ecb8ed5..c722212 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -583,7 +583,7 @@ out_nopages:
 }
 
 static
-void nfs_readdir_free_pagearray(struct page **pages, unsigned int npages)
+void nfs_readdir_free_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
 	for (i = 0; i < npages; i++)
@@ -595,7 +595,7 @@ void nfs_readdir_free_pagearray(struct page **pages, unsigned int npages)
  * to nfs_readdir_free_pagearray
  */
 static
-int nfs_readdir_large_page(struct page **pages, unsigned int npages)
+int nfs_readdir_alloc_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
 
@@ -608,7 +608,7 @@ int nfs_readdir_large_page(struct page **pages, unsigned int npages)
 	return 0;
 
 out_freepages:
-	nfs_readdir_free_pagearray(pages, i);
+	nfs_readdir_free_pages(pages, i);
 	return -ENOMEM;
 }
 
@@ -645,7 +645,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	memset(array, 0, sizeof(struct nfs_cache_array));
 	array->eof_index = -1;
 
-	status = nfs_readdir_large_page(pages, array_size);
+	status = nfs_readdir_alloc_pages(pages, array_size);
 	if (status < 0)
 		goto out_release_array;
 	do {
@@ -663,7 +663,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		}
 	} while (array->eof_index < 0);
 
-	nfs_readdir_free_pagearray(pages, array_size);
+	nfs_readdir_free_pages(pages, array_size);
 out_release_array:
 	nfs_readdir_release_array(page);
 out_label_free:
-- 
2.4.5

