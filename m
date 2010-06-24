From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/6] nfsd: nfs4callback encode_stateid helper function
Date: Thu, 24 Jun 2010 12:29:07 -0400
Message-ID: <1277396950-18298-4-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055Ab0FXQ3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:11 -0400
In-Reply-To: <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

To be used also for the pnfs cb_layoutrecall callback

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd4: fix cb_recall encoding]
    "nfsd: nfs4callback encode_stateid helper function" forgot to reserve
    more space after return from the new helper.
Reported-by: Michael Groshans <groshans@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c8dd03c..874a56a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -203,6 +203,16 @@ nfs_cb_stat_to_errno(int stat)
  */
 
 static void
+encode_stateid(struct xdr_stream *xdr, stateid_t *sid)
+{
+	__be32 *p;
+
+	RESERVE_SPACE(sizeof(stateid_t));
+	WRITE32(sid->si_generation);
+	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
+}
+
+static void
 encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 * p;
@@ -227,10 +237,10 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 	__be32 *p;
 	int len = dp->dl_fh.fh_size;
 
-	RESERVE_SPACE(12+sizeof(dp->dl_stateid) + len);
+	RESERVE_SPACE(4);
 	WRITE32(OP_CB_RECALL);
-	WRITE32(dp->dl_stateid.si_generation);
-	WRITEMEM(&dp->dl_stateid.si_opaque, sizeof(stateid_opaque_t));
+	encode_stateid(xdr, &dp->dl_stateid);
+	RESERVE_SPACE(8 + (XDR_QUADLEN(len) << 2));
 	WRITE32(0); /* truncate optimization not implemented */
 	WRITE32(len);
 	WRITEMEM(&dp->dl_fh.fh_base, len);
-- 
1.7.0.4

