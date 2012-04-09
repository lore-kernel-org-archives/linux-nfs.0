Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57517 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758244Ab2DIUw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:52:59 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/26] NFS: remove unused wb_complete field from struct nfs_page
Date: Mon,  9 Apr 2012 16:52:15 -0400
Message-Id: <1334004744-31842-18-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c        |    1 -
 fs/nfs/write.c           |    1 -
 include/linux/nfs_page.h |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e2c2af0..b360d08 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -112,7 +112,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
-	atomic_set(&req->wb_complete, 0);
 	req->wb_index	= page->index;
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4d9bbaf..293ddb9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1055,7 +1055,6 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 		nbytes -= len;
 		offset += len;
 	} while (nbytes != 0);
-	atomic_set(&req->wb_complete, requests);
 	desc->pg_rpc_callops = &nfs_write_common_ops;
 	return ret;
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index a36fbb6..1198f18 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -36,7 +36,6 @@ struct nfs_page {
 	struct page		*wb_page;	/* page to read in/write out */
 	struct nfs_open_context	*wb_context;	/* File state context info */
 	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
-	atomic_t		wb_complete;	/* i/os we're waiting for */
 	pgoff_t			wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
 	unsigned int		wb_offset,	/* Offset & ~PAGE_CACHE_MASK */
 				wb_pgbase,	/* Start of page data */
-- 
1.7.2.1

