From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/37] NFS: Optimise append writes with holes
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.31830.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761AbYFLTd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:33:59 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJXxUn001523
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:33:59 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a file is being extended, and we're creating a hole, we might as well
declare the entire page to be up to date.

This patch significantly improves the write performance for sparse files
in the case where lseek(SEEK_END) is used to append several non-contiguous
writes at intervals of < PAGE_SIZE.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c  |   20 ++++++++++++++++++++
 fs/nfs/write.c |   12 +++---------
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7c73f06..7ac89a8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -344,6 +344,26 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
 
+	/*
+	 * Zero any uninitialised parts of the page, and then mark the page
+	 * as up to date if it turns out that we're extending the file.
+	 */
+	if (!PageUptodate(page)) {
+		unsigned pglen = nfs_page_length(page);
+		unsigned end = offset + len;
+
+		if (pglen == 0) {
+			zero_user_segments(page, 0, offset,
+					end, PAGE_CACHE_SIZE);
+			SetPageUptodate(page);
+		} else if (end >= pglen) {
+			zero_user_segment(page, end, PAGE_CACHE_SIZE);
+			if (offset == 0)
+				SetPageUptodate(page);
+		} else
+			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
+	}
+
 	lock_kernel();
 	status = nfs_updatepage(file, page, offset, copied);
 	unlock_kernel();
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index dc62bc5..eea2d2b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -616,7 +616,7 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 			spin_unlock(&inode->i_lock);
 			radix_tree_preload_end();
 			req = new;
-			goto zero_page;
+			goto out;
 		}
 		spin_unlock(&inode->i_lock);
 
@@ -649,19 +649,13 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		req->wb_offset = offset;
 		req->wb_pgbase = offset;
 		req->wb_bytes = max(end, rqend) - req->wb_offset;
-		goto zero_page;
+		goto out;
 	}
 
 	if (end > rqend)
 		req->wb_bytes = end - req->wb_offset;
 
-	return req;
-zero_page:
-	/* If this page might potentially be marked as up to date,
-	 * then we need to zero any uninitalised data. */
-	if (req->wb_pgbase == 0 && req->wb_bytes != PAGE_CACHE_SIZE
-			&& !PageUptodate(req->wb_page))
-		zero_user_segment(req->wb_page, req->wb_bytes, PAGE_CACHE_SIZE);
+out:
 	return req;
 }
 

