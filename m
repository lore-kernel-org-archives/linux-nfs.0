Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932882Ab2JCAS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 20:18:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.1: Always set the layout stateid if this is the first layoutget
Date: Tue,  2 Oct 2012 17:18:22 -0700
Message-Id: <1349223505-59248-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the list of layout segments is empty, we must unconditionally set
the layout stateid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fe9968a..c8c1d0c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -558,7 +558,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-	if ((int)(newseq - oldseq) > 0) {
+	if (list_empty(&lo->plh_segs) || (int)(newseq - oldseq) > 0) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
 		if (update_barrier) {
 			u32 new_barrier = be32_to_cpu(new->seqid);
@@ -1181,6 +1181,10 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
+
+	/* Done processing layoutget. Set the layout stateid */
+	pnfs_set_layout_stateid(lo, &res->stateid, false);
+
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
 	pnfs_get_lseg(lseg);
@@ -1191,8 +1195,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		set_bit(NFS_LAYOUT_ROC, &lo->plh_flags);
 	}
 
-	/* Done processing layoutget. Set the layout stateid */
-	pnfs_set_layout_stateid(lo, &res->stateid, false);
 	spin_unlock(&ino->i_lock);
 	return lseg;
 out:
-- 
1.7.11.4

