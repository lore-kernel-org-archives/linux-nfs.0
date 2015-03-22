Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33941 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbbCVOR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 10:17:28 -0400
Received: by pacwe9 with SMTP id we9so162868404pac.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 07:17:28 -0700 (PDT)
Message-ID: <550ECEF0.6030505@gmail.com>
Date: Sun, 22 Mar 2015 22:17:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Fix bad update of layout in nfsd4_return_file_layout
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With return layout as, (seg is return layout, lo is record layout) 
seg->offset <= lo->offset and layout_end(seg) < layout_end(lo), 
nfsd should update lo's offset to seg's end,
and, 
seg->offset > lo->offset and layout_end(seg) >= layout_end(lo),
nfsd should update lo's end to seg's offset.

Fixes: 9cf514ccfa ("nfsd: implement pNFS operations")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6964613..80e236b 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -440,15 +440,14 @@ nfsd4_return_file_layout(struct nfs4_layout *lp, struct nfsd4_layout_seg *seg,
 			list_move_tail(&lp->lo_perstate, reaplist);
 			return;
 		}
-		end = seg->offset;
+		lo->offset = layout_end(seg);
 	} else {
 		/* retain the whole layout segment on a split. */
 		if (layout_end(seg) < end) {
 			dprintk("%s: split not supported\n", __func__);
 			return;
 		}
-
-		lo->offset = layout_end(seg);
+		end = seg->offset;
 	}
 
 	layout_update_len(lo, end);
-- 
2.3.3

