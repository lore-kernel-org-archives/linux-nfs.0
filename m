Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19795 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab1EUKdn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:33:43 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/13] SQUASHME: pnfs_osd_xdr: Add Server API for encoding/decoding osd XDRs
Date: Sat, 21 May 2011 13:33:33 +0300
Message-Id: <1305974013-17528-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch adds declarations and implementation fixes
to the objects Server XDR implementation. Needs squashing to
the patch That intruduces the pnfs_osd_xdr_srv.c file

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c |   23 +++++++++++++----------
 include/linux/pnfs_osd_xdr.h   |   14 ++++++++++++--
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 60df0df..cf2df46 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -1,12 +1,11 @@
 /*
- *  pnfs_osd_xdr_enc.c
+ *  Object-Based pNFS Layout XDR layer for the Server side
  *
- *  Object-Based pNFS Layout XDR layer
- *
- *  Copyright (C) 2007-2009 Panasas Inc.
+ *  Copyright (C) 2007 and on Panasas Inc.
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
@@ -253,7 +252,7 @@ EXPORT_SYMBOL(pnfs_osd_xdr_decode_layoutupdate);
  * 	struct pnfs_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
  * 	u64			oid_object_id;
- * };
+ * }; xdr size 32
  */
 static inline __be32 *
 pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
@@ -274,16 +273,20 @@ pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
  * 	u64			oer_comp_length;
  * 	u32			oer_iswrite;
  * 	u32			oer_errno;
- * };
+ * }; xdr size 32 + 24
  */
-__be32 *
-pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr, __be32 *p)
+bool pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr,
+			       struct exp_xdr_stream *xdr)
 {
+	__be32 *p = exp_xdr_reserve_space(xdr, 32 + 24);
+	if (!p)
+		return false;
+
 	p = pnfs_osd_xdr_decode_objid(p, &ioerr->oer_component);
 	p = xdr_decode_hyper(p, &ioerr->oer_comp_offset);
 	p = xdr_decode_hyper(p, &ioerr->oer_comp_length);
 	ioerr->oer_iswrite = be32_to_cpu(*p++);
-	ioerr->oer_errno = be32_to_cpu(*p++);
-	return p;
+	ioerr->oer_errno = be32_to_cpu(*p);
+	return true;
 }
 EXPORT_SYMBOL(pnfs_osd_xdr_decode_ioerr);
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 747d06d..9581d2b 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -41,6 +41,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/exp_xdr.h>
 #include <scsi/osd_protocol.h>
 
 #define PNFS_OSD_OSDNAME_MAXSIZE 256
@@ -324,6 +325,11 @@ extern bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
 	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
 	int *err);
 
+/* Layout encoding */
+extern int pnfs_osd_xdr_encode_layout(
+	struct exp_xdr_stream *xdr,
+	struct pnfs_osd_layout *layout);
+
 /* Device Info helpers */
 
 /* Note: All strings inside @deviceaddr point to space inside @p.
@@ -332,6 +338,10 @@ extern bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
 extern void pnfs_osd_xdr_decode_deviceaddr(
 	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p);
 
+/* For Servers */
+extern int pnfs_osd_xdr_encode_deviceaddr(
+	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
+
 /* layoutupdate (layout_commit) xdr helpers */
 extern int
 pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
@@ -344,7 +354,7 @@ pnfs_osd_xdr_decode_layoutupdate(struct pnfs_osd_layoutupdate *lou, __be32 *p);
 extern __be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr);
 extern void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr);
 /* Server*/
-extern __be32 *
-pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr, __be32 *p);
+extern bool pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr,
+				      struct exp_xdr_stream *xdr);
 
 #endif /* __PNFS_OSD_XDR_H__ */
-- 
1.7.2.3

