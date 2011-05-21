Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19800 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab1EUKeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:34:17 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/13] SQUASHME: XDR API changes to pnfs_osd_xdr_decode_ioerr()
Date: Sat, 21 May 2011 13:34:06 +0300
Message-Id: <1305974046-17556-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now accepts an exp_xdr_stream. And returns a bool when
done. Easier on the coding.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 69bce46..31e16b4 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -246,19 +246,17 @@ static int exofs_layout_return(
 	struct inode *inode,
 	const struct nfsd4_pnfs_layoutreturn_arg *args)
 {
-	__be32 *p = args->lrf_body;
-	unsigned len = exp_xdr_qwords(args->lrf_body_len);
+	struct exp_xdr_stream xdr = {
+		.p = args->lrf_body,
+		.end = args->lrf_body + exp_xdr_qwords(args->lrf_body_len),
+	};
+	struct pnfs_osd_ioerr ioerr;
 
-	EXOFS_DBGMSG("(0x%lx) cookie %p xdr_len %d\n",
-		     inode->i_ino, args->lr_cookie, len);
+	EXOFS_DBGMSG("(0x%lx) cookie %p body_len %d\n",
+		     inode->i_ino, args->lr_cookie, args->lrf_body_len);
 
-	while (len >= pnfs_osd_ioerr_xdr_sz()) {
-		struct pnfs_osd_ioerr ioerr;
-
-		p = pnfs_osd_xdr_decode_ioerr(&ioerr, p);
-		len -= pnfs_osd_ioerr_xdr_sz();
+	while (pnfs_osd_xdr_decode_ioerr(&ioerr, &xdr))
 		exofs_handle_error(&ioerr);
-	}
 
 	if (args->lr_cookie) {
 		struct exofs_i_info *oi = exofs_i(inode);
-- 
1.7.2.3

