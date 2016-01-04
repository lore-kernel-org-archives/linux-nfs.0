Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34772 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbcADSV6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:58 -0500
Received: by mail-io0-f174.google.com with SMTP id 1so116649052ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:58 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 16/18] NFSv4.1/pNFS: Cleanup pnfs_mark_matching_lsegs_invalid()
Date: Mon,  4 Jan 2016 13:21:14 -0500
Message-Id: <1451931676-68481-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-15-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it more obvious what we're returning...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8e1d4229bf2d..f86f060f853d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -569,7 +569,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct pnfs_layout_range *recall_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
-	int invalid = 0, removed = 0;
+	int remaining = 0;
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
@@ -582,11 +582,11 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
 				lseg->pls_range.length);
-			invalid++;
-			removed += mark_lseg_invalid(lseg, tmp_list);
+			if (!mark_lseg_invalid(lseg, tmp_list))
+				remaining++;
 		}
-	dprintk("%s:Return %i\n", __func__, invalid - removed);
-	return invalid - removed;
+	dprintk("%s:Return %i\n", __func__, remaining);
+	return remaining;
 }
 
 /* note free_me must contain lsegs from a single layout_hdr */
-- 
2.5.0

