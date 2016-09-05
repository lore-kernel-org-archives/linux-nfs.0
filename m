Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34235 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbcIENqy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 09:46:54 -0400
Received: by mail-it0-f66.google.com with SMTP id e124so8909907ith.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Sep 2016 06:46:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pNFS: Clear out all layout segments if the server unsets lrp->res.lrs_present
Date: Mon,  5 Sep 2016 09:46:01 -0400
Message-Id: <1473083162-4697-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473083162-4697-3-git-send-email-trond.myklebust@primarydata.com>
References: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-2-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server fails to set lrp->res.lrs_present in the LAYOUTRETURN reply,
then that means it believes the client holds no more layout state for that
file, and that the layout stateid is now invalid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5aecaabcb7c..c380d2ee4137 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8190,10 +8190,13 @@ static void nfs4_layoutreturn_release(void *calldata)
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range,
-			be32_to_cpu(lrp->args.stateid.seqid));
-	if (lrp->res.lrs_present && pnfs_layout_is_valid(lo))
+	if (lrp->res.lrs_present) {
+		pnfs_mark_matching_lsegs_invalid(lo, &freeme,
+				&lrp->args.range,
+				be32_to_cpu(lrp->args.stateid.seqid));
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
+	} else
+		pnfs_mark_layout_stateid_invalid(lo, &freeme);
 	pnfs_clear_layoutreturn_waitbit(lo);
 	spin_unlock(&lo->plh_inode->i_lock);
 	nfs4_sequence_free_slot(&lrp->res.seq_res);
-- 
2.7.4

