Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36679 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbcEOBHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2016 21:07:00 -0400
Received: by mail-qk0-f196.google.com with SMTP id l68so11320546qkf.3
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2016 18:07:00 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 08/13] flexfiles: remove pointless setting of NFS_LAYOUT_RETURN_REQUESTED
Date: Sat, 14 May 2016 21:06:37 -0400
Message-Id: <1463274402-17746-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
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
index 127a65fa639a..1c902b01db9e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1269,8 +1269,6 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
 			goto out_eagain;
-		set_bit(NFS_LAYOUT_RETURN_REQUESTED,
-			&hdr->lseg->pls_layout->plh_flags);
 		pnfs_read_resend_pnfs(hdr);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index c52ca75081a8..5532cb14e800 100644
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

