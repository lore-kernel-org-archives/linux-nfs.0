Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33453 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:45 -0400
Received: by mail-io0-f195.google.com with SMTP id y195so10763591iod.0
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/14] pNFS: Remove redundant pnfs_mark_layout_returned_if_empty()
Date: Sun, 24 Jul 2016 17:30:56 -0400
Message-Id: <1469395859-83194-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's already being taken care of in pnfs_layout_remove_lseg().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c |  1 -
 fs/nfs/nfs4proc.c      |  1 -
 fs/nfs/pnfs.c          |  1 -
 fs/nfs/pnfs.h          | 13 -------------
 4 files changed, 16 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 837da8a02d35..c92a75e066a6 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -252,7 +252,6 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
 			&args->cbl_range);
 	}
-	pnfs_mark_layout_returned_if_empty(lo);
 unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c453515d98c..d38cc5f0282f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8128,7 +8128,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 	spin_lock(&lo->plh_inode->i_lock);
 	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range,
 			be32_to_cpu(lrp->args.stateid.seqid));
-	pnfs_mark_layout_returned_if_empty(lo);
 	if (lrp->res.lrs_present && pnfs_layout_is_valid(lo))
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	pnfs_clear_layoutreturn_waitbit(lo);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e16997da157f..49e952968ede 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1159,7 +1159,6 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
-	pnfs_mark_layout_returned_if_empty(lo);
 	if (pnfs_seqid_is_newer(barrier, lo->plh_barrier))
 		lo->plh_barrier = barrier;
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d71c9493693a..595648a3ad7a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -552,19 +552,6 @@ pnfs_calc_offset_length(u64 offset, u64 end)
 	return 1 + end - offset;
 }
 
-/**
- * pnfs_mark_layout_returned_if_empty - marks the layout as returned
- * @lo: layout header
- *
- * Note: Caller must hold inode->i_lock
- */
-static inline void
-pnfs_mark_layout_returned_if_empty(struct pnfs_layout_hdr *lo)
-{
-	if (list_empty(&lo->plh_segs))
-		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-}
-
 static inline void
 pnfs_copy_range(struct pnfs_layout_range *dst,
 		const struct pnfs_layout_range *src)
-- 
2.7.4

