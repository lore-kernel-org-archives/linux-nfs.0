Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36616 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab1FNVDk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:03:40 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 8/8] pnfsd-exofs: layoutreturn pnfs-obj information decoding
Date: Tue, 14 Jun 2011 17:03:39 -0400
Message-Id: <1308085419-12686-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
References: <4DF7CA2F.7030407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use pnfs_osd_xdr_decode_ioerr() in exofs_layout_return,
and print the received errors.

TODO: Call exofs_file_recovery() on errors that need it.
      (When it's implemented)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index c0705df..8281c85 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -229,11 +229,31 @@ static int exofs_layout_commit(
 	return 0;
 }
 
+static void exofs_handle_error(struct pnfs_osd_ioerr *ioerr)
+{
+	EXOFS_ERR("exofs_handle_error: errno=%d is_write=%d obj=0x%llx "
+		  "offset=0x%llx length=0x%llx\n",
+		  ioerr->oer_errno, ioerr->oer_iswrite,
+		  _LLU(ioerr->oer_component.oid_object_id),
+		  _LLU(ioerr->oer_comp_offset),
+		  _LLU(ioerr->oer_comp_length));
+}
+
 static int exofs_layout_return(
 	struct inode *inode,
 	const struct nfsd4_pnfs_layoutreturn_arg *args)
 {
-	/* TODO: Decode the pnfs_osd_ioerr if lrf_body_len > 0 */
+	struct exp_xdr_stream xdr = {
+		.p = args->lrf_body,
+		.end = args->lrf_body + exp_xdr_qwords(args->lrf_body_len),
+	};
+	struct pnfs_osd_ioerr ioerr;
+
+	EXOFS_DBGMSG("(0x%lx) cookie %p body_len %d\n",
+		     inode->i_ino, args->lr_cookie, args->lrf_body_len);
+
+	while (pnfs_osd_xdr_decode_ioerr(&ioerr, &xdr))
+		exofs_handle_error(&ioerr);
 
 	if (args->lr_cookie) {
 		struct exofs_i_info *oi = exofs_i(inode);
-- 
1.7.3.4

