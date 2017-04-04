Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:48448 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751156AbdDDNNB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Apr 2017 09:13:01 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 124762804F3
        for <linux-nfs@vger.kernel.org>; Tue,  4 Apr 2017 15:12:58 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2] nfs: flexfilelayout: remove v3-only data server limitation
Date: Tue,  4 Apr 2017 15:12:51 +0200
Message-Id: <20170404131251.14212-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Flexfilelayout supports data servers which talk NFS v3 and v4.{0,1,2}.
However, this code path is disabled and v3 only servers are accepted.
This change removes this limitation.
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 457cfeb..aae05fc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -119,7 +119,13 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
 			ds_versions[i].wsize = NFS_MAX_FILE_IO_SIZE;
 
-		if (ds_versions[i].version != 3 || ds_versions[i].minor_version != 0) {
+		/*
+ 		 * check for valid major/minor combination.
+ 		 * currently we support dataserver which talk:
+ 		 *   v3, v4.0, v4.1, v4.2
+ 		 */
+		if (!((ds_versions[i].version == 3 && ds_versions[i].minor_version == 0) ||
+			(ds_versions[i].version == 4 && ds_versions[i].minor_version < 3))) {
 			dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
 				i, ds_versions[i].version,
 				ds_versions[i].minor_version);
-- 
2.9.3

