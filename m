Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19771 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1EUKc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:32:27 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/13] SQUASHME: pnfs_osd_xdr: Remove Server API declarations
Date: Sat, 21 May 2011 13:32:16 +0300
Message-Id: <1305973936-17444-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Server API will be added later with it's implementation patch.

This also removes the dependency on the exp_xdr_stream header.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/pnfs_osd_xdr.h |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index e4c2b25..db22471 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -41,7 +41,6 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
-#include <linux/exp_xdr.h>
 #include <scsi/osd_protocol.h>
 
 #define PNFS_OSD_OSDNAME_MAXSIZE 256
@@ -333,11 +332,6 @@ extern bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
 	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
 	int *err);
 
-/* Layout encoding */
-extern int pnfs_osd_xdr_encode_layout(
-	struct exp_xdr_stream *xdr,
-	struct pnfs_osd_layout *layout);
-
 /* Device Info helpers */
 
 /* Note: All strings inside @deviceaddr point to space inside @p.
@@ -346,10 +340,6 @@ extern int pnfs_osd_xdr_encode_layout(
 extern void pnfs_osd_xdr_decode_deviceaddr(
 	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p);
 
-/* For Servers */
-extern int pnfs_osd_xdr_encode_deviceaddr(
-	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
-
 /* layoutupdate (layout_commit) xdr helpers */
 extern int
 pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
-- 
1.7.2.3

