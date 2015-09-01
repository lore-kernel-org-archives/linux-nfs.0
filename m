Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35440 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbIAWLu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 18:11:50 -0400
Received: by pacfv12 with SMTP id fv12so9022924pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 15:11:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4.1/flexfiles: RW layouts are valid only if all mirrors are valid
Date: Tue,  1 Sep 2015 15:11:45 -0700
Message-Id: <1441145506-2891-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441145506-2891-1-git-send-email-trond.myklebust@primarydata.com>
References: <1441145506-2891-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike read layouts, the writeable layout cannot fall back to using only
one of the mirrors. It need to write to all of them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 883d35c86778..b6c21e9fa002 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -528,11 +528,11 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 	return 0;
 }
 
-bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
+static bool ff_read_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_deviceid_node *devid;
-	int idx;
+	u32 idx;
 
 	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
 		mirror = FF_LAYOUT_COMP(lseg, idx);
@@ -546,6 +546,32 @@ bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 	return false;
 }
 
+static bool ff_rw_layout_has_available_ds(struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_deviceid_node *devid;
+	u32 idx;
+
+	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
+		mirror = FF_LAYOUT_COMP(lseg, idx);
+		if (!mirror || !mirror->mirror_ds)
+			return false;
+		devid = &mirror->mirror_ds->id_node;
+		if (ff_layout_test_devid_unavailable(devid))
+			return false;
+	}
+
+	return FF_LAYOUT_MIRROR_COUNT(lseg) != 0;
+}
+
+bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
+{
+	if (lseg->pls_range.iomode == IOMODE_READ)
+		return  ff_read_layout_has_available_ds(lseg);
+	/* Note: RW layout needs all mirrors available */
+	return ff_rw_layout_has_available_ds(lseg);
+}
+
 module_param(dataserver_retrans, uint, 0644);
 MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
 			"retries a request before it attempts further "
-- 
2.4.3

