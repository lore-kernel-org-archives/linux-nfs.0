Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48892 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965279AbbBBWln (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:43 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so88041980pad.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:43 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 53/53] pnfs: lookup new lseg at lseg boundary
Date: Mon,  2 Feb 2015 14:39:07 -0800
Message-Id: <1422916747-86649-54-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Before mirroring support was added, the pageio descriptor's pg_lseg was
set to null when an RPC was sent. Because of this, pg_init was called
at lseg boundaries with pg_lseg = NULL, and it could be set to the new
lseg.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pnfs.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c7be9b9..9304984 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1788,10 +1788,16 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 		seg_end = end_offset(pgio->pg_lseg->pls_range.offset,
 				     pgio->pg_lseg->pls_range.length);
 		req_start = req_offset(req);
-		WARN_ON_ONCE(req_start > seg_end);
+		WARN_ON_ONCE(req_start >= seg_end);
 		/* start of request is past the last byte of this segment */
-		if (req_start >= seg_end)
+		if (req_start >= seg_end) {
+			/* reference the new lseg */
+			if (pgio->pg_ops->pg_cleanup)
+				pgio->pg_ops->pg_cleanup(pgio);
+			if (pgio->pg_ops->pg_init)
+				pgio->pg_ops->pg_init(pgio, req);
 			return 0;
+		}
 
 		/* adjust 'size' iff there are fewer bytes left in the
 		 * segment than what nfs_generic_pg_test returned */
-- 
1.9.3

