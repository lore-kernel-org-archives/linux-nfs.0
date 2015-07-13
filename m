Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36620 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbGMFUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:20:31 -0400
Received: by lagw2 with SMTP id w2so7879820lag.3
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:20:29 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] pNFS: Layoutreturn must invalidate all existing layout segments.
Date: Mon, 13 Jul 2015 07:20:01 +0200
Message-Id: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9f24238032f8..671498ca36d7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7964,16 +7964,19 @@ static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct pnfs_layout_hdr *lo = lrp->args.layout;
+	LIST_HEAD(freeme);
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
+	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
 	pnfs_clear_layoutreturn_waitbit(lo);
 	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
+	pnfs_free_lseg_list(&freeme);
 	pnfs_put_layout_hdr(lrp->args.layout);
 	nfs_iput_and_deactive(lrp->inode);
 	kfree(calldata);
-- 
2.4.3

