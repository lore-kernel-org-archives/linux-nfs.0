Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from chipog116.obsmtp.com ([64.18.12.91]:59707 "HELO
	chipog116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750967Ab0KDRRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Nov 2010 13:17:04 -0400
Message-ID: <4CD2E7B4.8070805@panasas.com>
Date: Thu, 04 Nov 2010 19:04:52 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: pnfs-obj: bug in last conversion to embedded pnfs_layout_segment
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The range field in pnfs_layout_segment is passed to io-engine's
objio_alloc_lseg but was never set properly.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index efe7984..332c832 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -102,6 +102,7 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
 	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, layout);
 
+	objlseg->lseg.range = lgr->range;
 	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
 				  pnfs_osd_layout);
 	if (status)
-- 
1.7.2.3

