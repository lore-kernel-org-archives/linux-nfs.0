Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760478Ab0JGNLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 09:11:00 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97DAgWA017616
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 06:10:45 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pnfs_submit: Only update stateid if it is more recent than current
Date: Wed,  6 Oct 2010 16:35:15 -0400
Message-Id: <1286397317-17881-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Right now, when we set the stateid, we blindly overwrite the current
one, allowing the seqid to incorrectly roll backward.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   38 ++++++++++++++++++++++++++++++++------
 1 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 39bce9b..555955b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -459,16 +459,42 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	}
 }
 
+/* update lo->stateid with new if is more recent
+ *
+ * lo->stateid could be the open stateid, in which case we just use what given.
+ */
 static void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
-			const nfs4_stateid *stateid)
+			const nfs4_stateid *new)
 {
-	/* TODO - should enforce that embedded seqid, in the case
-	 * that the two stateid.others are equal,  only increases.
-	 * Complicated by wrap-around.
-	 */
+	nfs4_stateid *old = &lo->stateid;
+	bool overwrite = false;
+
 	write_seqlock(&lo->seqlock);
-	memcpy(lo->stateid.data, stateid->data, sizeof(lo->stateid.data));
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
+	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
+		overwrite = true;
+	else {
+		u32 oldseq, newseq, limit;
+
+		oldseq = be32_to_cpu(old->stateid.seqid);
+		newseq = be32_to_cpu(new->stateid.seqid);
+		/* There are no good bounds on window size, so just
+		 * use a ridiculously large window of 2^31.
+		 */
+		limit = oldseq + (1 << 31);
+		if (oldseq < limit) {
+			/* The easy, non-wraparound case */
+			if (oldseq < newseq && newseq < limit)
+				overwrite = true;
+		} else {
+			/* Near wraparound edge */
+			if (oldseq < newseq || newseq < limit)
+				overwrite = true;
+		}
+	}
+	if (overwrite)
+		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
 	write_sequnlock(&lo->seqlock);
 }
 
-- 
1.7.2.1

