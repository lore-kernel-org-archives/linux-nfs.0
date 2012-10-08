Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15896 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461Ab2JHRwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 13:52:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1: Ensure that the layout sequence id stays 'close' to the current
Date: Mon,  8 Oct 2012 13:50:28 -0400
Message-Id: <1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clamp the layout barrier sequence id to the current sequence id
minus the maximum number of outstanding layoutget requests.

Also ensure that we correctly initialise lo->plh_barrier if there are
no layout segments associated to this layout header.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 42613bd..861dd97 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -563,28 +563,23 @@ void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 			bool update_barrier)
 {
-	u32 oldseq, newseq;
+	u32 oldseq, newseq, new_barrier;
+	int empty = list_empty(&lo->plh_segs);
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-	if (list_empty(&lo->plh_segs) || pnfs_seqid_is_newer(newseq, oldseq)) {
+	if (empty || pnfs_seqid_is_newer(newseq, oldseq)) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
 		if (update_barrier) {
-			u32 new_barrier = be32_to_cpu(new->seqid);
-
-			if (pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
-				lo->plh_barrier = new_barrier;
+			new_barrier = be32_to_cpu(new->seqid);
 		} else {
 			/* Because of wraparound, we want to keep the barrier
-			 * "close" to the current seqids.  It needs to be
-			 * within 2**31 to count as "behind", so if it
-			 * gets too near that limit, give us a litle leeway
-			 * and bring it to within 2**30.
-			 * NOTE - and yes, this is all unsigned arithmetic.
+			 * "close" to the current seqids.
 			 */
-			if (unlikely((newseq - lo->plh_barrier) > (3 << 29)))
-				lo->plh_barrier = newseq - (1 << 30);
+			new_barrier = newseq - atomic_read(&lo->plh_outstanding);
 		}
+		if (empty || pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
+			lo->plh_barrier = new_barrier;
 	}
 }
 
-- 
1.7.11.4

