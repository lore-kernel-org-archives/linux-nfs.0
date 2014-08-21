Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51177 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaHUQH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:26 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtZ-00009H-2F
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:25 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/19] pnfs: don't check sequence on new stateids in layoutget
Date: Thu, 21 Aug 2014 11:09:20 -0500
Message-Id: <1408637375-11343-5-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When layoutget returns an entirely new layout stateid it should not
check the generation counter as the new stateid will start with a new
counter entirely unrelated to old one.

The current behavior causes constant layoutget failures against a block
server which allocates a new stateid after an recall that removed all
outstanding layouts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 242e73f..32a14a6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -685,17 +685,6 @@ static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
 	return (s32)(s1 - s2) > 0;
 }
 
-static void
-pnfs_verify_layout_stateid(struct pnfs_layout_hdr *lo,
-		const nfs4_stateid *new,
-		struct list_head *free_me_list)
-{
-	if (nfs4_stateid_match_other(&lo->plh_stateid, new))
-		return;
-	/* Layout is new! Kill existing layout segments */
-	pnfs_mark_matching_lsegs_invalid(lo, free_me_list, NULL);
-}
-
 /* update lo->plh_stateid with new if is more recent */
 void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
@@ -1370,16 +1359,29 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget_reply;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, 1) ||
-	    pnfs_layout_stateid_blocked(lo, &res->stateid)) {
+	if (pnfs_layoutgets_blocked(lo, 1)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
 
-	/* Check that the new stateid matches the old stateid */
-	pnfs_verify_layout_stateid(lo, &res->stateid, &free_me);
-	/* Done processing layoutget. Set the layout stateid */
-	pnfs_set_layout_stateid(lo, &res->stateid, false);
+	if (nfs4_stateid_match_other(&lo->plh_stateid, &res->stateid)) {
+		/* existing state ID, make sure the sequence number matches. */
+		if (pnfs_layout_stateid_blocked(lo, &res->stateid)) {
+			dprintk("%s forget reply due to sequence\n", __func__);
+			goto out_forget_reply;
+		}
+		pnfs_set_layout_stateid(lo, &res->stateid, false);
+	} else {
+		/*
+		 * We got an entirely new state ID.  Mark all segments for the
+		 * inode invalid, and don't bother validating the stateid
+		 * sequence number.
+		 */
+		pnfs_mark_matching_lsegs_invalid(lo, &free_me, NULL);
+
+		nfs4_stateid_copy(&lo->plh_stateid, &res->stateid);
+		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
+	}
 
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg);
-- 
1.9.1

