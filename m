Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:43141 "HELO
	exprod5og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751197Ab0JGTRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 15:17:52 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SQUASHME: pnfs-submit: do not get_lseg in pnfs_has_layout
Date: Thu,  7 Oct 2010 15:17:49 -0400
Message-Id: <1286479069-29035-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CAE16FA.9040606@panasas.com>
References: <4CAE16FA.9040606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

let its caller do that if necessary

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 40d1dc6..a27df2b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -844,8 +844,6 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(lseg, &lo->segs, fi_list) {
 		if (is_matching_lseg(lseg, range)) {
 			ret = lseg;
-			if (lseg->valid)
-				get_lseg(ret);
 			break;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
@@ -857,7 +855,6 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 		ret ? ret->valid : 0);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(pnfs_has_layout);
 
 /*
  * Layout segment is retreived from the server if not cached.
@@ -897,6 +894,7 @@ pnfs_update_layout(struct inode *ino,
 	if (lseg) {
 		dprintk("%s: Using cached lseg %p for iomode %d)\n",
 			__func__, lseg, iomode);
+		get_lseg(lseg);
 		goto out_unlock;
 	}
 
-- 
1.7.2.3

