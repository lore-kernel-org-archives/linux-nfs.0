Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15896 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754408Ab2JHRwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 13:52:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1: Cleanup ugliness in pnfs_layoutgets_blocked()
Date: Mon,  8 Oct 2012 13:50:29 -0400
Message-Id: <1349718630-26008-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
 <1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split it into two functions, one which checks if layoutgets are blocked,
and one which checks if the layout stateid has expired.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 861dd97..bd97692 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -583,17 +583,19 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	}
 }
 
-/* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
-pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
-			int lget)
+pnfs_layout_stateid_blocked(const struct pnfs_layout_hdr *lo,
+		const nfs4_stateid *stateid)
 {
-	if (stateid != NULL) {
-		u32 seqid = be32_to_cpu(stateid->seqid);
+	u32 seqid = be32_to_cpu(stateid->seqid);
 
-		if (!pnfs_seqid_is_newer(seqid, lo->plh_barrier))
-			return true;
-	}
+	return !pnfs_seqid_is_newer(seqid, lo->plh_barrier);
+}
+
+/* lget is set to 1 if called from inside send_layoutget call chain */
+static bool
+pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo, int lget)
+{
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
@@ -608,7 +610,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, NULL, 1)) {
+	if (pnfs_layoutgets_blocked(lo, 1)) {
 		status = -EAGAIN;
 	} else if (list_empty(&lo->plh_segs)) {
 		int seq;
@@ -1111,7 +1113,7 @@ pnfs_update_layout(struct inode *ino,
 	if (lseg)
 		goto out_unlock;
 
-	if (pnfs_layoutgets_blocked(lo, NULL, 0))
+	if (pnfs_layoutgets_blocked(lo, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
@@ -1184,7 +1186,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget_reply;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
+	if (pnfs_layoutgets_blocked(lo, 1) ||
+	    pnfs_layout_stateid_blocked(lo, &res->stateid)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
-- 
1.7.11.4

