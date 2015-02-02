Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64935 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbbBBWkq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:40:46 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so87842101pab.11
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:46 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 32/53] nfs: handle overlapping reqs in lock_and_join
Date: Mon,  2 Feb 2015 14:38:46 -0800
Message-Id: <1422916747-86649-33-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

This is needed for mirrored DS support, where multuple requests
cover the same range.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8800bd3..e997457 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -473,13 +473,18 @@ try_again:
 	do {
 		/*
 		 * Subrequests are always contiguous, non overlapping
-		 * and in order. If not, it's a programming error.
+		 * and in order - but may be repeated (mirrored writes).
 		 */
-		WARN_ON_ONCE(subreq->wb_offset !=
-		     (head->wb_offset + total_bytes));
-
-		/* keep track of how many bytes this group covers */
-		total_bytes += subreq->wb_bytes;
+		if (subreq->wb_offset == (head->wb_offset + total_bytes)) {
+			/* keep track of how many bytes this group covers */
+			total_bytes += subreq->wb_bytes;
+		} else if (WARN_ON_ONCE(subreq->wb_offset < head->wb_offset ||
+			    ((subreq->wb_offset + subreq->wb_bytes) >
+			     (head->wb_offset + total_bytes)))) {
+			nfs_page_group_unlock(head);
+			spin_unlock(&inode->i_lock);
+			return ERR_PTR(-EIO);
+		}
 
 		if (!nfs_lock_request(subreq)) {
 			/* releases page group bit lock and
-- 
1.9.3

