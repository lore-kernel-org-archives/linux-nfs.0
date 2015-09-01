Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33421 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbIAWLt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 18:11:49 -0400
Received: by paap5 with SMTP id p5so1452394paa.0
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 15:11:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFSv4.1/flexfiles: Fix incorrect usage of pnfs_generic_mark_devid_invalid()
Date: Tue,  1 Sep 2015 15:11:44 -0700
Message-Id: <1441145506-2891-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike the files layout, flexfiles does not test for the NFS_DEVICEID_INVALID
flag. Instead it relies on NFS_DEVICEID_UNAVAILABLE.
Fix is to replace with nfs4_mark_deviceid_unavailable().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index b28fa4cbea52..883d35c86778 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -344,7 +344,7 @@ nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 			__func__, mirror_idx);
 		if (mirror && mirror->mirror_ds) {
 			devid = &mirror->mirror_ds->id_node;
-			pnfs_generic_mark_devid_invalid(devid);
+			nfs4_mark_deviceid_unavailable(devid);
 		}
 		goto out;
 	}
@@ -374,7 +374,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			__func__, ds_idx);
 		if (mirror && mirror->mirror_ds) {
 			devid = &mirror->mirror_ds->id_node;
-			pnfs_generic_mark_devid_invalid(devid);
+			nfs4_mark_deviceid_unavailable(devid);
 		}
 		goto out;
 	}
-- 
2.4.3

