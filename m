Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:43838 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751590AbdDCMKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 08:10:32 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 7D8B5280270
        for <linux-nfs@vger.kernel.org>; Mon,  3 Apr 2017 14:10:30 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs: flexfilelayout: remove v3-only data server limitation
Date: Mon,  3 Apr 2017 14:10:26 +0200
Message-Id: <20170403121026.14142-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Flexfilelayout supports data servers which talk NFS v3 and v4.{0,1}.
However, this code path is disabled and v3 only servers are accepted.
This change removes this limitation.
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 457cfeb..fac0ef2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -119,12 +119,18 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
 			ds_versions[i].wsize = NFS_MAX_FILE_IO_SIZE;
 
-		if (ds_versions[i].version != 3 || ds_versions[i].minor_version != 0) {
-			dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
-				i, ds_versions[i].version,
-				ds_versions[i].minor_version);
-			ret = -EPROTONOSUPPORT;
-			goto out_err_drain_dsaddrs;
+		/* check for valid major minor combination */
+		switch (ds_versions[i].version * 100 + ds_versions[i].minor_version) {
+			case 300: /* v3   */
+			case 400: /* v4.0 */
+			case 401: /* v4.1 */
+				break;
+			default:
+				dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
+					i, ds_versions[i].version,
+					ds_versions[i].minor_version);
+				ret = -EPROTONOSUPPORT;
+				goto out_err_drain_dsaddrs;
 		}
 
 		dprintk("%s: [%d] vers %u minor_ver %u rsize %u wsize %u coupled %d\n",
-- 
2.9.3

