Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33593 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbcERVIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 17:08:07 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so21408009pac.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 14:08:06 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 1/3] nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
Date: Wed, 18 May 2016 14:07:54 -0700
Message-Id: <1463605676-82483-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
References: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mds can inform the client not to use the IOMODE_RW layout
segment for doing READs. I.e., it is basically a
IOMODE_WRITE layout segment.

It would do this to not interfere with the WRITEs.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 10 +++++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8dabf64..c66c6c1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -10,7 +10,8 @@
 #define FS_NFS_NFS4FLEXFILELAYOUT_H
 
 #define FF_FLAGS_NO_LAYOUTCOMMIT 1
-#define FF_FLAGS_NO_IO_THRU_MDS 2
+#define FF_FLAGS_NO_IO_THRU_MDS  2
+#define FF_FLAGS_NO_READ_IO      4
 
 #include "../pnfs.h"
 
@@ -155,6 +156,12 @@ ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
 }
 
 static inline bool
+ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
+{
+	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_READ_IO;
+}
+
+static inline bool
 ff_layout_test_devid_unavailable(struct nfs4_deviceid_node *node)
 {
 	return nfs4_test_deviceid_unavailable(node);
@@ -194,6 +201,7 @@ struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
 				       u32 ds_idx, struct rpc_cred *mdscred);
 bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
+bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
 
 struct file *ff_local_open_fh(struct pnfs_layout_segment *lseg, u32 ds_idx,
 		 struct nfs_client *clp, struct rpc_cred *cred,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 1a603d4..b90c2bd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -623,6 +623,12 @@ bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg)
 	       ff_layout_has_available_ds(lseg);
 }
 
+bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg)
+{
+	return lseg->pls_range.iomode == IOMODE_RW &&
+	       ff_layout_no_read_on_rw(lseg);
+}
+
 module_param(dataserver_retrans, uint, 0644);
 MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
 			"retries a request before it attempts further "
-- 
1.8.3.1

