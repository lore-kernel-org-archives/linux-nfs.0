Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36342 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbbL1SF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 13:05:56 -0500
Received: by mail-ig0-f171.google.com with SMTP id ph11so149680560igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 10:05:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/6] NFSv4.1/pnfs: Fixup an lo->plh_block_lgets imbalance in layoutreturn
Date: Mon, 28 Dec 2015 13:05:13 -0500
Message-Id: <1451325918-33544-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 2d8ae84fbc32, nothing is bumping lo->plh_block_lgets in the
layoutreturn path, so it should not be touched in nfs4_layoutreturn_release
either.

Fixes: 2d8ae84fbc32 ("NFSv4.1/pnfs: Remove redundant lo->plh_block_lgets...")
Cc: stable@vger.kernel.org # 4.3+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index adae525edec4..306a8a0cf5bd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8077,7 +8077,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
 	pnfs_clear_layoutreturn_waitbit(lo);
-	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_free_lseg_list(&freeme);
 	pnfs_put_layout_hdr(lrp->args.layout);
-- 
2.5.0

