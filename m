Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38119 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab1FNVgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:08 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/10] SQUASHME: pnfsd-exofs: Prettify pnfs_osd_xdr_srv.h
Date: Tue, 14 Jun 2011 17:36:07 -0400
Message-Id: <1308087367-13123-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfsd/pnfs_osd_xdr_srv.h |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/linux/nfsd/pnfs_osd_xdr_srv.h b/include/linux/nfsd/pnfs_osd_xdr_srv.h
index 65de588..256a7e07 100644
--- a/include/linux/nfsd/pnfs_osd_xdr_srv.h
+++ b/include/linux/nfsd/pnfs_osd_xdr_srv.h
@@ -1,17 +1,36 @@
+/*
+ * pnfs-objects Server XDR definitions and API
+ *
+ * Copyright (C) from 2011 Panasas Inc.  All rights reserved.
+ *
+ * Authors:
+ *   Boaz Harrosh <bharrosh@panasas.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ *
+ */
+#ifndef __PNFS_OSD_XDR_SRV_H__
+#define __PNFS_OSD_XDR_SRV_H__
+
 #include <linux/pnfs_osd_xdr.h>
 #include <linux/exp_xdr.h>
 
 /* Layout encoding */
-extern int pnfs_osd_xdr_encode_layout(
+int pnfs_osd_xdr_encode_layout(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *layout);
 
-/* deviceaddr for Servers */
-extern int pnfs_osd_xdr_encode_deviceaddr(
+/* deviceaddr encoding */
+int pnfs_osd_xdr_encode_deviceaddr(
 	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
 
-extern __be32 * pnfs_osd_xdr_decode_layoutupdate(
+/* layout_commit decoding */
+__be32 * pnfs_osd_xdr_decode_layoutupdate(
 	struct pnfs_osd_layoutupdate *lou, __be32 *p);
 
-extern bool pnfs_osd_xdr_decode_ioerr(
+/* layout_return decoding */
+bool pnfs_osd_xdr_decode_ioerr(
 	struct pnfs_osd_ioerr *ioerr, struct exp_xdr_stream *xdr);
+
+#endif /* __PNFS_OSD_XDR_SRV_H__ */
-- 
1.7.3.4

