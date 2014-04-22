Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:54882 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757973AbaDVV3Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:24 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so217399igb.11
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:23 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 17/17] nfs: support page groups in nfs_read_completion
Date: Tue, 22 Apr 2014 17:29:25 -0400
Message-Id: <1398202165-78897-18-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_read_completion relied on the fact that there was a 1:1 mapping
of page to nfs_request, but this has now changed.

Regions not covered by a request have already been zeroed elsewhere.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/read.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c6b7dd0..e3613e2 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -182,7 +182,6 @@ static void nfs_page_group_set_uptodate(struct nfs_page *req)
 		SetPageUptodate(req->wb_page);
 }
 
-/* Note io was page aligned */
 static void nfs_read_completion(struct nfs_pgio_header *hdr)
 {
 	unsigned long bytes = 0;
@@ -192,14 +191,25 @@ static void nfs_read_completion(struct nfs_pgio_header *hdr)
 	while (!list_empty(&hdr->pages)) {
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
+		unsigned long start = req->wb_pgbase;
+		unsigned long end = req->wb_pgbase + req->wb_bytes;
 
 		if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
-			if (bytes > hdr->good_bytes)
-				zero_user(page, 0, PAGE_SIZE);
-			else if (hdr->good_bytes - bytes < PAGE_SIZE)
-				zero_user_segment(page,
-					hdr->good_bytes & ~PAGE_MASK,
-					PAGE_SIZE);
+			/* note: regions of the page not covered by a
+			 * request are zeroed in nfs_readpage_async /
+			 * readpage_async_filler */
+			if (bytes > hdr->good_bytes) {
+				/* nothing in this request was good, so zero
+				 * the full extent of the request */
+				zero_user_segment(page, start, end);
+
+			} else if (hdr->good_bytes - bytes < req->wb_bytes) {
+				/* part of this request has good bytes, but
+				 * not all. zero the bad bytes */
+				start += hdr->good_bytes - bytes;
+				WARN_ON(start < req->wb_pgbase);
+				zero_user_segment(page, start, end);
+			}
 		}
 		bytes += req->wb_bytes;
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
-- 
1.8.5.2 (Apple Git-48)

