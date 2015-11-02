Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35716 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbbKBStf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 13:49:35 -0500
Received: by igpw7 with SMTP id w7so63539332igp.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 10:49:34 -0800 (PST)
Received: from leira.trondhjem.org (c-68-49-164-203.hsd1.mi.comcast.net. [68.49.164.203])
        by smtp.gmail.com with ESMTPSA id q10sm6347055igh.4.2015.11.02.10.49.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 10:49:34 -0800 (PST)
Message-ID: <1446490172.30323.3.camel@primarydata.com>
Subject: [PATCH 2/2] pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 02 Nov 2015 13:49:32 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For loosely coupled pNFS/flexfiles systems, there is often no advantage
at all in going through the MDS for I/O, since the MDS is subject to
the same limitations as all other clients when talking to DSes. If a
DS is unresponsive, I/O through the MDS will fail.

For such systems, the only scalable solution is to have the pNFS
clients
retry doing pNFS, and so the protocol now provides a flag that allows
the pNFS server to signal this.

If LAYOUTGET returns FF_FLAGS_NO_IO_THRU_MDS, then we should assume
that
the MDS wants the client to retry using these devices, even if they
were
previously marked as being unavailable. To do so, we add a helper,
ff_layout_mark_devices_valid() that will be called from layoutget.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 18 ++++++++++++++++--
 fs/nfs/flexfilelayout/flexfilelayout.h |  7 +++++++
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fc14b90886e..03516c80855a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -339,6 +339,19 @@ static void ff_layout_sort_mirrors(struct
nfs4_ff_layout_segment *fls)
 	}
 }
 
+static void ff_layout_mark_devices_valid(struct nfs4_ff_layout_segment
*fls)
+{
+	struct nfs4_deviceid_node *node;
+	int i;
+
+	if (!(fls->flags & FF_FLAGS_NO_IO_THRU_MDS))
+		return;
+	for (i = 0; i < fls->mirror_array_cnt; i++) {
+		node = &fls->mirror_array[i]->mirror_ds->id_node;
+		clear_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+	}
+}
+
 static struct pnfs_layout_segment *
 ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		     struct nfs4_layoutget_res *lgr,
@@ -499,6 +512,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	rc = ff_layout_check_layout(lgr);
 	if (rc)
 		goto out_err_free;
+	ff_layout_mark_devices_valid(fls);
 
 	ret = &fls->generic_hdr;
 	dprintk("<-- %s (success)\n", __func__);
@@ -1035,7 +1049,8 @@ static int ff_layout_async_handle_error_v4(struct
rpc_task *task,
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
-		if (ff_layout_has_available_ds(lseg))
+		if (ff_layout_no_fallback_to_mds(lseg) ||
+		    ff_layout_has_available_ds(lseg))
 			return -NFS4ERR_RESET_TO_PNFS;
 reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
@@ -1153,7 +1168,6 @@ static void ff_layout_io_track_ds_error(struct
pnfs_layout_segment *lseg,
 }
 
 /* NFS_PROTO call done callback routines */
-
 static int ff_layout_read_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h
b/fs/nfs/flexfilelayout/flexfilelayout.h
index 68cc0d9828f9..2bb08bc6aaf0 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -10,6 +10,7 @@
 #define FS_NFS_NFS4FLEXFILELAYOUT_H
 
 #define FF_FLAGS_NO_LAYOUTCOMMIT 1
+#define FF_FLAGS_NO_IO_THRU_MDS 2
 
 #include "../pnfs.h"
 
@@ -146,6 +147,12 @@ FF_LAYOUT_MIRROR_COUNT(struct pnfs_layout_segment
*lseg)
 }
 
 static inline bool
+ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
+{
+	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_IO_THRU_MDS;
+}
+
+static inline bool
 ff_layout_test_devid_unavailable(struct nfs4_deviceid_node *node)
 {
 	return nfs4_test_deviceid_unavailable(node);
