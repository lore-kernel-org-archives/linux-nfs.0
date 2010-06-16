From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd: fix error handling for s_pnfs_op->get_device_info
Date: Wed, 16 Jun 2010 09:49:30 -0400
Message-ID: <1276696170-19115-1-git-send-email-bhalevy@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42091 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754771Ab0FPNt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 09:49:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was apparently dropped by mistake back in:
efeeb16 pnfsd: set_device_notify

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b61fb05..225023c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3434,8 +3434,8 @@ nfsd4_encode_getdevinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	nfserr = sb->s_pnfs_op->get_device_info(sb, &xdr, gdev->gd_layout_type,
 						&gdev->gd_devid);
-	if (nfserr) {
-	}
+	if (nfserr)
+		goto err;
 
 	/* The file system should never write 0 bytes without
 	 * returning an error
-- 
1.6.4.4

