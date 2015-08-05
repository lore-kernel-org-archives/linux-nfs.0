Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35343 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbHECaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:30:04 -0400
Received: by iodd187 with SMTP id d187so36064266iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:30:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFSv4.1/pnfs: Remove redundant check in pnfs_layoutgets_blocked()
Date: Tue,  4 Aug 2015 22:29:55 -0400
Message-Id: <1438741796-22681-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438741796-22681-4-git-send-email-trond.myklebust@primarydata.com>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

layoutget now should already be serialised w.r.t. layout returns

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 26 +++++---------------------
 1 file changed, 5 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c6aa13525e4..b6540cc41f7c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -816,23 +816,12 @@ pnfs_layout_stateid_blocked(const struct pnfs_layout_hdr *lo,
 	return !pnfs_seqid_is_newer(seqid, lo->plh_barrier);
 }
 
-static bool
-pnfs_layout_returning(const struct pnfs_layout_hdr *lo,
-		      struct pnfs_layout_range *range)
-{
-	return test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
-		(lo->plh_return_iomode == IOMODE_ANY ||
-		 lo->plh_return_iomode == range->iomode);
-}
-
 /* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
-pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo,
-			struct pnfs_layout_range *range)
+pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
 {
 	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		pnfs_layout_returning(lo, range);
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 }
 
 int
@@ -844,7 +833,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, range)) {
+	if (pnfs_layoutgets_blocked(lo)) {
 		status = -EAGAIN;
 	} else if (!nfs4_valid_open_stateid(open_state)) {
 		status = -EBADF;
@@ -1546,7 +1535,7 @@ lookup_again:
 		goto out_put_layout_hdr;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, &arg))
+	if (pnfs_layoutgets_blocked(lo))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 	spin_unlock(&ino->i_lock);
@@ -1618,12 +1607,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	lseg->pls_range = res->range;
 
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
-		dprintk("%s forget reply due to recall\n", __func__);
-		goto out_forget_reply;
-	}
-
-	if (pnfs_layoutgets_blocked(lo, &lgp->args.range)) {
+	if (pnfs_layoutgets_blocked(lo)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
-- 
2.4.3

