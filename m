Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35323 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbcEOBHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2016 21:07:06 -0400
Received: by mail-qg0-f47.google.com with SMTP id f74so75199119qge.2
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2016 18:07:05 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 13/13] pnfs: make pnfs_layout_process more robust
Date: Sat, 14 May 2016 21:06:42 -0400
Message-Id: <1463274402-17746-14-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It can return NULL if layoutgets are blocked currently. Fix it to return
-EAGAIN in that case, so we can properly handle it in pnfs_update_layout.

Also, clean up and simplify the error handling -- eliminate "status" and
just use "lseg".

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d0760d30734d..4108e78ae3b6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1706,21 +1706,19 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = lo->plh_inode;
 	LIST_HEAD(free_me);
-	int status = -EINVAL;
 
 	if (!pnfs_sanity_check_layout_range(&res->range))
-		goto out;
+		return ERR_PTR(-EINVAL);
 
 	/* Inject layout blob into I/O device driver */
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res, lgp->gfp_flags);
-	if (!lseg || IS_ERR(lseg)) {
+	if (IS_ERR_OR_NULL(lseg)) {
 		if (!lseg)
-			status = -ENOMEM;
-		else
-			status = PTR_ERR(lseg);
-		dprintk("%s: Could not allocate layout: error %d\n",
-		       __func__, status);
-		goto out;
+			lseg = ERR_PTR(-ENOMEM);
+
+		dprintk("%s: Could not allocate layout: error %ld\n",
+		       __func__, PTR_ERR(lseg));
+		return lseg;
 	}
 
 	init_lseg(lo, lseg);
@@ -1730,15 +1728,14 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	spin_lock(&ino->i_lock);
 	if (pnfs_layoutgets_blocked(lo)) {
 		dprintk("%s forget reply due to state\n", __func__);
-		goto out_forget_reply;
+		goto out_forget;
 	}
 
 	if (nfs4_stateid_match_other(&lo->plh_stateid, &res->stateid)) {
 		/* existing state ID, make sure the sequence number matches. */
 		if (pnfs_layout_stateid_blocked(lo, &res->stateid)) {
 			dprintk("%s forget reply due to sequence\n", __func__);
-			status = -EAGAIN;
-			goto out_forget_reply;
+			goto out_forget;
 		}
 		pnfs_set_layout_stateid(lo, &res->stateid, false);
 	} else {
@@ -1764,14 +1761,12 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me);
 	return lseg;
-out:
-	return ERR_PTR(status);
 
-out_forget_reply:
+out_forget:
 	spin_unlock(&ino->i_lock);
 	lseg->pls_layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	goto out;
+	return ERR_PTR(-EAGAIN);
 }
 
 static void
-- 
2.5.5

