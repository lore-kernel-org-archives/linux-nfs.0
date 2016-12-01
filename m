Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34629 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759718AbcLAWTg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:36 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so3917173ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/26] NFSv4: Ignore LAYOUTRETURN result if the layout doesn't match or is invalid
Date: Thu,  1 Dec 2016 17:19:06 -0500
Message-Id: <20161201221922.15657-11-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-10-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a potential race with CB_LAYOUTRECALL in which the server recalls the
remaining layout segments while our LAYOUTRETURN is still in transit.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 fs/nfs/pnfs.c     | 8 +++++++-
 fs/nfs/pnfs.h     | 2 +-
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 561b21e4a930..87972cfa62bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8574,8 +8574,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	struct pnfs_layout_hdr *lo = lrp->args.layout;
 
 	dprintk("--> %s\n", __func__);
-	pnfs_layoutreturn_free_lsegs(lo, &lrp->args.range,
-			be32_to_cpu(lrp->args.stateid.seqid),
+	pnfs_layoutreturn_free_lsegs(lo, &lrp->args.stateid, &lrp->args.range,
 			lrp->res.lrs_present ? &lrp->res.stateid : NULL);
 	nfs4_sequence_free_slot(&lrp->res.seq_res);
 	pnfs_put_layout_hdr(lrp->args.layout);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 555151b6d31b..471018f27c8d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -961,20 +961,26 @@ static void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 }
 
 void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
+		const nfs4_stateid *arg_stateid,
 		const struct pnfs_layout_range *range,
-		u32 seq,
 		const nfs4_stateid *stateid)
 {
 	struct inode *inode = lo->plh_inode;
 	LIST_HEAD(freeme);
 
 	spin_lock(&inode->i_lock);
+	if (!pnfs_layout_is_valid(lo) || !arg_stateid ||
+	    !nfs4_stateid_match_other(&lo->plh_stateid, arg_stateid))
+		goto out_unlock;
 	if (stateid) {
+		u32 seq = be32_to_cpu(arg_stateid->seqid);
+
 		pnfs_mark_matching_lsegs_invalid(lo, &freeme, range, seq);
 		pnfs_free_returned_lsegs(lo, &freeme, range, seq);
 		pnfs_set_layout_stateid(lo, stateid, true);
 	} else
 		pnfs_mark_layout_stateid_invalid(lo, &freeme);
+out_unlock:
 	pnfs_clear_layoutreturn_waitbit(lo);
 	spin_unlock(&inode->i_lock);
 	pnfs_free_lseg_list(&freeme);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a382710edf40..bc9a3aa31d3c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -295,8 +295,8 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       bool strict_iomode,
 					       gfp_t gfp_flags);
 void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
+		const nfs4_stateid *arg_stateid,
 		const struct pnfs_layout_range *range,
-		u32 seq,
 		const nfs4_stateid *stateid);
 
 void pnfs_generic_layout_insert_lseg(struct pnfs_layout_hdr *lo,
-- 
2.9.3

