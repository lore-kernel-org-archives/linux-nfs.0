Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32837 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbcEYObp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 10:31:45 -0400
Received: by mail-pf0-f172.google.com with SMTP id b124so19147970pfb.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 07:31:45 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [V2 1/3] nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
Date: Wed, 25 May 2016 07:31:12 -0700
Message-Id: <1464186674-104401-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464186674-104401-1-git-send-email-loghyr@primarydata.com>
References: <1464186674-104401-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mds can inform the client not to use the IOMODE_RW layout
segment for doing READs. I.e., it is basically a
IOMODE_WRITE layout segment.

It would do this to not interfere with the WRITEs.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 11 ++++++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index b540581..1bcdb15 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -10,7 +10,8 @@
 #define FS_NFS_NFS4FLEXFILELAYOUT_H
 
 #define FF_FLAGS_NO_LAYOUTCOMMIT 1
-#define FF_FLAGS_NO_IO_THRU_MDS 2
+#define FF_FLAGS_NO_IO_THRU_MDS  2
+#define FF_FLAGS_NO_READ_IO      4
 
 #include "../pnfs.h"
 
@@ -153,6 +154,12 @@ ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
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
@@ -192,4 +199,6 @@ struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
 				       u32 ds_idx, struct rpc_cred *mdscred);
 bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
+bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
+
 #endif /* FS_NFS_NFS4FLEXFILELAYOUT_H */
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 35d84d0..0aa36be 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -557,6 +557,12 @@ bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg)
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

