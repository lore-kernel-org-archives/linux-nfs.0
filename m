Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:64822 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbaLXHOG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:06 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so6627521igi.0
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:06 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 32/49] nfs: handle overlapping reqs in lock_and_join
Date: Tue, 23 Dec 2014 23:13:11 -0800
Message-Id: <1419405208-25975-33-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
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
index ab392af..a6eadac 100644
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

