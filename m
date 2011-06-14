Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38109 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:00 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/10] SQUASHME: pnfsd-exofs: Move all Server xdr definisions to separate header
Date: Tue, 14 Jun 2011 17:35:59 -0400
Message-Id: <1308087359-13095-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Server XDR definitions are defined in there own header

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c        |    3 ++-
 include/linux/nfsd/pnfs_osd_xdr_srv.h |   17 +++++++++++++++++
 2 files changed, 19 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/nfsd/pnfs_osd_xdr_srv.h

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 444798c..67564f6 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -38,7 +38,8 @@
  */
 
 #include <linux/nfsd/nfsd4_pnfs.h>
-#include <linux/pnfs_osd_xdr.h>
+
+#include "linux/nfsd/pnfs_osd_xdr_srv.h"
 
 /*
  * struct pnfs_osd_data_map {
diff --git a/include/linux/nfsd/pnfs_osd_xdr_srv.h b/include/linux/nfsd/pnfs_osd_xdr_srv.h
new file mode 100644
index 0000000..65de588
--- /dev/null
+++ b/include/linux/nfsd/pnfs_osd_xdr_srv.h
@@ -0,0 +1,17 @@
+#include <linux/pnfs_osd_xdr.h>
+#include <linux/exp_xdr.h>
+
+/* Layout encoding */
+extern int pnfs_osd_xdr_encode_layout(
+	struct exp_xdr_stream *xdr,
+	struct pnfs_osd_layout *layout);
+
+/* deviceaddr for Servers */
+extern int pnfs_osd_xdr_encode_deviceaddr(
+	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
+
+extern __be32 * pnfs_osd_xdr_decode_layoutupdate(
+	struct pnfs_osd_layoutupdate *lou, __be32 *p);
+
+extern bool pnfs_osd_xdr_decode_ioerr(
+	struct pnfs_osd_ioerr *ioerr, struct exp_xdr_stream *xdr);
-- 
1.7.3.4

