Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34626 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbcADSVq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:46 -0500
Received: by mail-io0-f176.google.com with SMTP id 1so116643499ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/18] NFSv4.1/pNFS: Add a helper to mark the layout as returned
Date: Mon,  4 Jan 2016 13:21:00 -0500
Message-Id: <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This ensures that we don't reuse the stateid if a layout return or
implied layout return means that we've returned all layout segments

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c |  1 +
 fs/nfs/nfs4proc.c      |  3 ++-
 fs/nfs/pnfs.c          |  1 +
 fs/nfs/pnfs.h          | 13 +++++++++++++
 4 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 807eb6ef4f91..716cbff24450 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -192,6 +192,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
 			&args->cbl_range);
 	}
+	pnfs_mark_layout_returned_if_empty(lo);
 unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fcd7a9039020..883da29b9ace 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8049,9 +8049,10 @@ static void nfs4_layoutreturn_release(void *calldata)
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
+	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
+	pnfs_mark_layout_returned_if_empty(lo);
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
 	pnfs_clear_layoutreturn_waitbit(lo);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6095a8d42766..b3fb6bb02275 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1149,6 +1149,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
+	pnfs_mark_layout_returned_if_empty(lo);
 	if (pnfs_seqid_is_newer(barrier, lo->plh_barrier))
 		lo->plh_barrier = barrier;
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d1990e90e7a0..be24a759b655 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -556,6 +556,19 @@ pnfs_calc_offset_length(u64 offset, u64 end)
 	return 1 + end - offset;
 }
 
+/**
+ * pnfs_mark_layout_returned_if_empty - marks the layout as returned
+ * @lo: layout header
+ *
+ * Note: Caller must hold inode->i_lock
+ */
+static inline void
+pnfs_mark_layout_returned_if_empty(struct pnfs_layout_hdr *lo)
+{
+	if (list_empty(&lo->plh_segs))
+		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+}
+
 extern unsigned int layoutstats_timer;
 
 #ifdef NFS_DEBUG
-- 
2.5.0

