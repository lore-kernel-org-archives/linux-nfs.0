Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:36721 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684AbcEESZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 14:25:00 -0400
Received: by mail-qk0-f169.google.com with SMTP id x7so47665696qkd.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 11:25:00 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: hch@lst.de, Anna.Schumaker@netapp.com
Subject: [RFC PATCH 5/6] nfs4: remove pointless setting of NFS_LAYOUT_RETURN_REQUESTED in flexfiles code
Date: Thu,  5 May 2016 14:24:47 -0400
Message-Id: <1462472688-5663-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
References: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Setting just the NFS_LAYOUT_RETURN_REQUESTED flag doesn't do anything,
unless there are lsegs that are also being marked for return. At the
point where that happens this flag is also set, so these set_bit calls
don't do anything useful.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 2 --
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 8 +-------
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0ee2613b8aa6..e2bb3eaaff32 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1249,8 +1249,6 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
 			goto out_eagain;
-		set_bit(NFS_LAYOUT_RETURN_REQUESTED,
-			&hdr->lseg->pls_layout->plh_flags);
 		pnfs_read_resend_pnfs(hdr);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 56296f3df19c..5eff05e9eb4d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -393,13 +393,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 					 mirror, lseg->pls_range.offset,
 					 lseg->pls_range.length, NFS4ERR_NXIO,
 					 OP_ILLEGAL, GFP_NOIO);
-		if (!fail_return) {
-			if (ff_layout_has_available_ds(lseg))
-				set_bit(NFS_LAYOUT_RETURN_REQUESTED,
-					&lseg->pls_layout->plh_flags);
-			else
-				pnfs_error_mark_layout_for_return(ino, lseg);
-		} else
+		if (fail_return || !ff_layout_has_available_ds(lseg))
 			pnfs_error_mark_layout_for_return(ino, lseg);
 		ds = NULL;
 	}
-- 
2.5.5

