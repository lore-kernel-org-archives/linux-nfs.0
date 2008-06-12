From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/37] NFS: Revert commit 44dd151d
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.67406.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbYFLTeA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:00 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJXxUp001523
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:33:59 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Revert commit 44dd151d "NFS: Don't mark a written page as uptodate until it
is on disk". While it is true that the write may fail, that is always the
case. There is no reason why we should treat data on pages that are not
already marked as PG_uptodate as being special. The only thing we gain is a
noticeable slowdown when re-reading these pages.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index eea2d2b..ee6fcde 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -188,6 +188,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	}
 	/* Update file length */
 	nfs_grow_file(page, offset, count);
+	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 	nfs_clear_page_tag_locked(req);
 	return 0;
 }
@@ -743,12 +744,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 static void nfs_writepage_release(struct nfs_page *req)
 {
 
-	if (PageError(req->wb_page)) {
-		nfs_end_page_writeback(req->wb_page);
-		nfs_inode_remove_request(req);
-	} else if (!nfs_reschedule_unstable_write(req)) {
-		/* Set the PG_uptodate flag */
-		nfs_mark_uptodate(req->wb_page, req->wb_pgbase, req->wb_bytes);
+	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req)) {
 		nfs_end_page_writeback(req->wb_page);
 		nfs_inode_remove_request(req);
 	} else
@@ -1069,8 +1065,6 @@ static void nfs_writeback_release_full(void *calldata)
 			dprintk(" marked for commit\n");
 			goto next;
 		}
-		/* Set the PG_uptodate flag? */
-		nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 		dprintk(" OK\n");
 remove_request:
 		nfs_end_page_writeback(page);
@@ -1309,9 +1303,6 @@ static void nfs_commit_release(void *calldata)
 		 * returned by the server against all stored verfs. */
 		if (!memcmp(req->wb_verf.verifier, data->verf.verifier, sizeof(data->verf.verifier))) {
 			/* We have a match */
-			/* Set the PG_uptodate flag */
-			nfs_mark_uptodate(req->wb_page, req->wb_pgbase,
-					req->wb_bytes);
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
 			goto next;

