Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759449Ab0FJV0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 17:26:31 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: SQUASHME pnfs-submit: write to MDS on DS commit verifier mismatch
Date: Thu, 10 Jun 2010 17:26:23 -0400
Message-Id: <1276205183-14014-2-git-send-email-andros@netapp.com>
In-Reply-To: <1276205183-14014-1-git-send-email-andros@netapp.com>
References: <1276205183-14014-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/write.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 482d41e..a47f03d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -422,6 +422,17 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	nfs_clear_request(req);
 	nfs_release_request(req);
 }
+static void
+nfs_mark_request_nopnfs(struct nfs_page *req)
+{
+	struct pnfs_layout_segment *lseg = req->wb_lseg;
+
+	if (req->wb_lseg == NULL)
+		return;
+	req->wb_lseg = NULL;
+	put_lseg(lseg);
+	dprintk(" retry through MDS\n");
+}
 
 static void
 nfs_mark_request_dirty(struct nfs_page *req)
@@ -1463,11 +1474,7 @@ static void nfs_commit_release(void *calldata)
 			(long long)req_offset(req));
 		if (status < 0) {
 			if (req->wb_lseg) {
-				struct pnfs_layout_segment *lseg = req->wb_lseg;
-
-				req->wb_lseg = NULL;
-				put_lseg(lseg);
-				dprintk(" retry through MDS\n");
+				nfs_mark_request_nopnfs(req);
 				nfs_mark_request_dirty(req);
 				goto next;
 			}
@@ -1487,6 +1494,7 @@ static void nfs_commit_release(void *calldata)
 		}
 		/* We have a mismatch. Write the page again */
 		dprintk(" mismatch\n");
+		nfs_mark_request_nopnfs(req);
 		nfs_mark_request_dirty(req);
 	next:
 		nfs_clear_page_tag_locked(req);
-- 
1.6.6

