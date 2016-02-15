Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35122 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbcBOSNr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 13:13:47 -0500
Received: by mail-ig0-f170.google.com with SMTP id hb3so57008441igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 10:13:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: Always set NFS_LAYOUT_RETURN_REQUESTED with lo->plh_return_iomode
Date: Mon, 15 Feb 2016 13:13:03 -0500
Message-Id: <1455559983-11808-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1455559983-11808-1-git-send-email-trond.myklebust@primarydata.com>
References: <1455559983-11808-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When setting the layout return mode, we must always also set the
NFS_LAYOUT_RETURN_REQUESTED flag to ensure that we send a layoutreturn.
Otherwise pnfs_error_mark_layout_for_return() could set the mode, but
fail to send the layoutreturn because another is already in flight.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8d9fa4e40e89..5064f23ca8cc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1738,6 +1738,7 @@ pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
 	if (lo->plh_return_iomode != 0)
 		iomode = IOMODE_ANY;
 	lo->plh_return_iomode = iomode;
+	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
 }
 
 /**
@@ -1777,8 +1778,6 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			pnfs_set_plh_return_iomode(lo, return_range->iomode);
-			set_bit(NFS_LAYOUT_RETURN_REQUESTED,
-					&lo->plh_flags);
 		}
 	return remaining;
 }
-- 
2.5.0

