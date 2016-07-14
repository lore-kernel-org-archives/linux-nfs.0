Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36545 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbcGNW7F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 18:59:05 -0400
Received: by mail-io0-f194.google.com with SMTP id y34so5351007ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2016 15:59:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pNFS: Fix post-layoutget error handling in pnfs_update_layout()
Date: Thu, 14 Jul 2016 18:58:32 -0400
Message-Id: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The non-retry error path is currently broken and ends up releasing the
reference to the layout twice. It also can end up clearing the
NFS_LAYOUT_FIRST_LAYOUTGET flag twice, causing a race.

In addition, the retry path will fail to decrement the plh_outstanding
counter.

Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
Cc: stable@vger.kernel.org # 4.7
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0fbe734cc38c..73b0dc90265a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1645,6 +1645,7 @@ lookup_again:
 	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
 	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
+	atomic_dec(&lo->plh_outstanding);
 	if (IS_ERR(lseg)) {
 		switch(PTR_ERR(lseg)) {
 		case -ERECALLCONFLICT:
@@ -1652,26 +1653,25 @@ lookup_again:
 				lseg = NULL;
 			/* Fallthrough */
 		case -EAGAIN:
-			pnfs_put_layout_hdr(lo);
-			if (first)
-				pnfs_clear_first_layoutget(lo);
-			if (lseg) {
-				trace_pnfs_update_layout(ino, pos, count,
-					iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
-				goto lookup_again;
-			}
-			/* Fallthrough */
+			break;
 		default:
 			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
 				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 				lseg = NULL;
 			}
 		}
+		if (lseg) {
+			pnfs_put_layout_hdr(lo);
+			if (first)
+				pnfs_clear_first_layoutget(lo);
+			trace_pnfs_update_layout(ino, pos, count,
+				iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
+			goto lookup_again;
+		}
 	} else {
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 	}
 
-	atomic_dec(&lo->plh_outstanding);
 out_put_layout_hdr:
 	if (first)
 		pnfs_clear_first_layoutget(lo);
-- 
2.7.4

