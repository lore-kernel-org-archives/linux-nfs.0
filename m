Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43561 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932885Ab2JCAS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 20:18:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.1: Deal with wraparound when updating the layout "barrier" seqid
Date: Tue,  2 Oct 2012 17:18:24 -0700
Message-Id: <1349223505-59248-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349223505-59248-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-2-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and fix a bug in pnfs_set_layout_stateid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f1387e8..de82725 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -572,7 +572,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 		if (update_barrier) {
 			u32 new_barrier = be32_to_cpu(new->seqid);
 
-			if ((int)(new_barrier - lo->plh_barrier))
+			if (pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
 				lo->plh_barrier = new_barrier;
 		} else {
 			/* Because of wraparound, we want to keep the barrier
@@ -593,9 +593,12 @@ static bool
 pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 			int lget)
 {
-	if ((stateid) &&
-	    (int)(lo->plh_barrier - be32_to_cpu(stateid->seqid)) >= 0)
-		return true;
+	if (stateid != NULL) {
+		u32 seqid = be32_to_cpu(stateid->seqid);
+
+		if (!pnfs_seqid_is_newer(seqid, lo->plh_barrier))
+			return true;
+	}
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
-- 
1.7.11.4

