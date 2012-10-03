Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932864Ab2JCAS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 20:18:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.1: Deal with wraparound issues when updating the layout stateid
Date: Tue,  2 Oct 2012 17:18:23 -0700
Message-Id: <1349223505-59248-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349223505-59248-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and add a helper function.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c8c1d0c..f1387e8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -549,6 +549,15 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	}
 }
 
+/*
+ * Compare 2 layout stateid sequence ids, to see which is newer,
+ * taking into account wraparound issues.
+ */
+static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
+{
+	return (s32)s1 - (s32)s2 > 0;
+}
+
 /* update lo->plh_stateid with new if is more recent */
 void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
@@ -558,7 +567,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-	if (list_empty(&lo->plh_segs) || (int)(newseq - oldseq) > 0) {
+	if (list_empty(&lo->plh_segs) || pnfs_seqid_is_newer(newseq, oldseq)) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
 		if (update_barrier) {
 			u32 new_barrier = be32_to_cpu(new->seqid);
-- 
1.7.11.4

