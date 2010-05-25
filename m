Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63099 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932192Ab0EYGu0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 02:50:26 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
        "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: nfs4callback encode_stateid helper function
Date: Tue, 25 May 2010 09:50:23 +0300
Message-Id: <1274770223-28968-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To be used also for the pnfs cb_layoutrecall callback

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd4: fix cb_recall encoding]
    "nfsd: nfs4callback encode_stateid helper function" forgot to reserve
    more space after return from the new helper.
Reported-by: Michael Groshans <groshans@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index eb78e7e..6bacd0e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -205,6 +205,16 @@ nfs_cb_stat_to_errno(int stat)
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
@@ -229,10 +239,10 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
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
1.6.6.1

