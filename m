Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33171 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbcEQQ26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:28:58 -0400
Received: by mail-qk0-f196.google.com with SMTP id q184so1931087qkf.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:28:58 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 02/13] pNFS/flexfiles: When checking for available DSes, conditionally check for MDS io
Date: Tue, 17 May 2016 12:28:37 -0400
Message-Id: <1463502528-11519-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <loghyr@primarydata.com>

Whenever we check to see if we have the needed number of DSes for the
action, we may also have to check to see whether IO is allowed to go to
the MDS or not.

[jlayton: fix merge conflict due to lack of localio patches here]

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 5 ++---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 1 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 6 ++++++
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 51f6660a2247..f538ca6bbe81 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1101,8 +1101,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
-		if (ff_layout_no_fallback_to_mds(lseg) ||
-		    ff_layout_has_available_ds(lseg))
+		if (ff_layout_avoid_mds_available_ds(lseg))
 			return -NFS4ERR_RESET_TO_PNFS;
 reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
@@ -1764,7 +1763,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	return PNFS_ATTEMPTED;
 
 out_failed:
-	if (ff_layout_has_available_ds(lseg))
+	if (ff_layout_avoid_mds_available_ds(lseg))
 		return PNFS_TRY_AGAIN;
 	return PNFS_NOT_ATTEMPTED;
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 1318c77aeb35..b54058122647 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -191,4 +191,5 @@ nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg,
 struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
 				       u32 ds_idx, struct rpc_cred *mdscred);
 bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
+bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
 #endif /* FS_NFS_NFS4FLEXFILELAYOUT_H */
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 56296f3df19c..c52ca75081a8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -540,6 +540,12 @@ bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 	return ff_rw_layout_has_available_ds(lseg);
 }
 
+bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg)
+{
+	return ff_layout_no_fallback_to_mds(lseg) ||
+	       ff_layout_has_available_ds(lseg);
+}
+
 module_param(dataserver_retrans, uint, 0644);
 MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
 			"retries a request before it attempts further "
-- 
2.5.5

