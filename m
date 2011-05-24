Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46698 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab1EXPGj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:06:39 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/12] SQUASHME: pnfs-obj: pnfs_osd_xdr.h Remove server definitions
Date: Tue, 24 May 2011 18:06:08 +0300
Message-Id: <1306249568-23304-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are later added by the Server patchset

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/pnfs_osd_xdr.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 747d06d..76efbdd 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -336,15 +336,10 @@ extern void pnfs_osd_xdr_decode_deviceaddr(
 extern int
 pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
 				 struct pnfs_osd_layoutupdate *lou);
-extern __be32 *
-pnfs_osd_xdr_decode_layoutupdate(struct pnfs_osd_layoutupdate *lou, __be32 *p);
 
 /* osd_ioerror encoding/decoding (layout_return) */
 /* Client */
 extern __be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr);
 extern void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr);
-/* Server*/
-extern __be32 *
-pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr, __be32 *p);
 
 #endif /* __PNFS_OSD_XDR_H__ */
-- 
1.7.2.3

