Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982Ab0EXP20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 11:28:26 -0400
Date: Mon, 24 May 2010 11:28:25 -0400
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Michael Groshans <groshans@citi.umich.edu>
Subject: [PATCH] SQUASHME: nfsd4: fix cb_recall encoding
Message-ID: <20100524152825.GB18625@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

"nfsd: nfs4callback encode_stateid helper function" forgot to reserve
more space after return from the new helper.

Reported-by: Michael Groshans <groshans@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Benny, maybe you could fix that patch and then pass it upstream?

--b.

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b279738..238e0b8 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -246,6 +246,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 	RESERVE_SPACE(4);
 	WRITE32(OP_CB_RECALL);
 	encode_stateid(xdr, &dp->dl_stateid);
+	RESERVE_SPACE(8 + (XDR_QUADLEN(len) << 2));
 	WRITE32(0); /* truncate optimization not implemented */
 	WRITE32(len);
 	WRITEMEM(&dp->dl_fh.fh_base, len);
-- 
1.7.0.4

