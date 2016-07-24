Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35428 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbcGXVbe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:34 -0400
Received: by mail-it0-f65.google.com with SMTP id f6so6441320ith.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 01/14] pNFS: LAYOUTRETURN should only update the stateid if the layout is valid
Date: Sun, 24 Jul 2016 17:30:46 -0400
Message-Id: <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout was completely returned, then ignore the returned layout
stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 fs/nfs/pnfs.h     | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff416d0e24bc..dc50ba4d84ad 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8130,7 +8130,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range,
 			be32_to_cpu(lrp->args.stateid.seqid));
 	pnfs_mark_layout_returned_if_empty(lo);
-	if (lrp->res.lrs_present)
+	if (lrp->res.lrs_present && pnfs_layout_is_valid(lo))
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	pnfs_clear_layoutreturn_waitbit(lo);
 	spin_unlock(&lo->plh_inode->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b21bd0bee784..2f4f26905c03 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -375,6 +375,11 @@ static inline bool nfs_have_layout(struct inode *inode)
 	return NFS_I(inode)->layout != NULL;
 }
 
+static inline bool pnfs_layout_is_valid(const struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) == 0;
+}
+
 static inline struct nfs4_deviceid_node *
 nfs4_get_deviceid(struct nfs4_deviceid_node *d)
 {
-- 
2.7.4

