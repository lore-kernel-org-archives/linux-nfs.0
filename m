Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33044 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757533Ab2EARQi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 13:16:38 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH v2 3/3] NFS: Simplify the nfs_read_completion functions
Date: Tue,  1 May 2012 13:16:36 -0400
Message-Id: <1335892596-13667-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335892596-13667-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1335892596-13667-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335892596-13667-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and correct a bug when NFS_IOHDR_ERROR is set: we should not be
setting PageUptodate/set_page_dirty on a page unless the number of
bytes read <= hdr->good_bytes

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
v2: Actually add the bugfix to direct.c...

 fs/nfs/direct.c |   46 +++++++++++++++++++---------------------------
 fs/nfs/read.c   |   42 +++++++++++++++++-------------------------
 2 files changed, 36 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 78d1ead..34027d5 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -253,36 +253,28 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		dreq->count += hdr->good_bytes;
 	spin_unlock(&dreq->lock);
 
-	if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
-		while (!list_empty(&hdr->pages)) {
-			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-			struct page *page = req->wb_page;
-
-			if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
-				if (bytes > hdr->good_bytes)
-					zero_user(page, 0, PAGE_SIZE);
-				else if (hdr->good_bytes - bytes < PAGE_SIZE)
-					zero_user_segment(page,
-						hdr->good_bytes & ~PAGE_MASK,
-						PAGE_SIZE);
-			}
-			bytes += req->wb_bytes;
-			nfs_list_remove_request(req);
-			if (!PageCompound(page))
-				set_page_dirty(page);
-			nfs_direct_readpage_release(req);
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+		struct page *page = req->wb_page;
+
+		if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
+			if (bytes > hdr->good_bytes)
+				zero_user(page, 0, PAGE_SIZE);
+			else if (hdr->good_bytes - bytes < PAGE_SIZE)
+				zero_user_segment(page,
+					hdr->good_bytes & ~PAGE_MASK,
+					PAGE_SIZE);
 		}
-	} else {
-		while (!list_empty(&hdr->pages)) {
-			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-
-			if (bytes < hdr->good_bytes)
-				if (!PageCompound(req->wb_page))
+		bytes += req->wb_bytes;
+		if (!PageCompound(page)) {
+			if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
+				if (bytes <= hdr->good_bytes)
 					set_page_dirty(req->wb_page);
-			bytes += req->wb_bytes;
-			nfs_list_remove_request(req);
-			nfs_direct_readpage_release(req);
+			} else
+				set_page_dirty(page);
 		}
+		nfs_list_remove_request(req);
+		nfs_direct_readpage_release(req);
 	}
 out_put:
 	if (put_dreq(dreq))
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 1961a19..b81281b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -179,34 +179,26 @@ static void nfs_read_completion(struct nfs_pgio_header *hdr)
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
 		goto out;
-	if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
-		while (!list_empty(&hdr->pages)) {
-			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-			struct page *page = req->wb_page;
-
-			if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
-				if (bytes > hdr->good_bytes)
-					zero_user(page, 0, PAGE_SIZE);
-				else if (hdr->good_bytes - bytes < PAGE_SIZE)
-					zero_user_segment(page,
-						hdr->good_bytes & ~PAGE_MASK,
-						PAGE_SIZE);
-			}
-			SetPageUptodate(page);
-			nfs_list_remove_request(req);
-			nfs_readpage_release(req);
-			bytes += PAGE_SIZE;
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+		struct page *page = req->wb_page;
+
+		if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
+			if (bytes > hdr->good_bytes)
+				zero_user(page, 0, PAGE_SIZE);
+			else if (hdr->good_bytes - bytes < PAGE_SIZE)
+				zero_user_segment(page,
+					hdr->good_bytes & ~PAGE_MASK,
+					PAGE_SIZE);
 		}
-	} else {
-		while (!list_empty(&hdr->pages)) {
-			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-
-			bytes += req->wb_bytes;
+		bytes += req->wb_bytes;
+		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
 			if (bytes <= hdr->good_bytes)
 				SetPageUptodate(req->wb_page);
-			nfs_list_remove_request(req);
-			nfs_readpage_release(req);
-		}
+		} else
+			SetPageUptodate(page);
+		nfs_list_remove_request(req);
+		nfs_readpage_release(req);
 	}
 out:
 	hdr->release(hdr);
-- 
1.7.7.6

