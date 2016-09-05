Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35125 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933113AbcIENqx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 09:46:53 -0400
Received: by mail-it0-f67.google.com with SMTP id c198so8887001ith.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Sep 2016 06:46:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pNFS: Fix pnfs_set_layout_stateid() to clear NFS_LAYOUT_INVALID_STID
Date: Mon,  5 Sep 2016 09:46:00 -0400
Message-Id: <1473083162-4697-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473083162-4697-2-git-send-email-trond.myklebust@primarydata.com>
References: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout was marked as invalid, we want to ensure to initialise
the layout header fields correctly.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 519ad320f5cd..cd8b5fca33f6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -768,17 +768,32 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	pnfs_destroy_layouts_byclid(clp, false);
 }
 
+static void
+pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
+{
+	lo->plh_return_iomode = 0;
+	lo->plh_return_seq = 0;
+	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+}
+
 /* update lo->plh_stateid with new if is more recent */
 void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 			bool update_barrier)
 {
 	u32 oldseq, newseq, new_barrier = 0;
-	bool invalid = !pnfs_layout_is_valid(lo);
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-	if (invalid || pnfs_seqid_is_newer(newseq, oldseq)) {
+
+	if (!pnfs_layout_is_valid(lo)) {
+		nfs4_stateid_copy(&lo->plh_stateid, new);
+		lo->plh_barrier = newseq;
+		pnfs_clear_layoutreturn_info(lo);
+		clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+		return;
+	}
+	if (pnfs_seqid_is_newer(newseq, oldseq)) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
 		/*
 		 * Because of wraparound, we want to keep the barrier
@@ -790,7 +805,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 		new_barrier = be32_to_cpu(new->seqid);
 	else if (new_barrier == 0)
 		return;
-	if (invalid || pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
+	if (pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
 		lo->plh_barrier = new_barrier;
 }
 
@@ -886,14 +901,6 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 }
 
-static void
-pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
-{
-	lo->plh_return_iomode = 0;
-	lo->plh_return_seq = 0;
-	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
-}
-
 static bool
 pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 		nfs4_stateid *stateid,
@@ -1801,16 +1808,11 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		 */
 		pnfs_mark_layout_stateid_invalid(lo, &free_me);
 
-		nfs4_stateid_copy(&lo->plh_stateid, &res->stateid);
-		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
+		pnfs_set_layout_stateid(lo, &res->stateid, true);
 	}
 
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg, &free_me);
-	if (!pnfs_layout_is_valid(lo)) {
-		pnfs_clear_layoutreturn_info(lo);
-		clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-	}
 
 
 	if (res->return_on_close)
-- 
2.7.4

