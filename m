Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47325 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab0LOScq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:32:46 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] Revert "pnfs-submit: wave2: check that partial LAYOUTGET return is ignored"
Date: Wed, 15 Dec 2010 20:32:44 +0200
Message-Id: <1292437964-21985-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 0980d08ae8e980c001a31f0f29f9f1b8b5da6f94.
---
 fs/nfs/pnfs.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b778032..653be24 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -898,17 +898,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	int status = 0;
 
-	/* Verify we got what we asked for.
-	 * Note that because the xdr parsing only accepts a single
-	 * element array, this can fail even if the server is behaving
-	 * correctly.
-	 */
-	if (lgp->args.range.iomode > res->range.iomode ||
-	    res->range.offset != 0 ||
-	    res->range.length != NFS4_MAX_UINT64) {
-		status = -EINVAL;
-		goto out;
-	}
 	/* Inject layout blob into I/O device driver */
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res);
 	if (!lseg || IS_ERR(lseg)) {
-- 
1.7.2.3

