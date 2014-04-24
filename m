Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35065 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932385AbaDXSQF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:16:05 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so1355361igc.4
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:16:05 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 18/18 v2] nfs: support page groups in nfs_read_completion
Date: Thu, 24 Apr 2014 14:15:28 -0400
Message-Id: <1398363328-7100-19-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
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
index a889319..3ea06f0 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -130,7 +130,6 @@ static void nfs_page_group_set_uptodate(struct nfs_page *req)
 		SetPageUptodate(req->wb_page);
 }
 
-/* Note io was page aligned */
 static void nfs_read_completion(struct nfs_pgio_header *hdr)
 {
 	unsigned long bytes = 0;
@@ -140,14 +139,25 @@ static void nfs_read_completion(struct nfs_pgio_header *hdr)
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

