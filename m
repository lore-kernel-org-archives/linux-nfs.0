Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33008 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcGNEB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 00:01:26 -0400
Received: by mail-pa0-f66.google.com with SMTP id q2so3983293pap.0
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 21:01:26 -0700 (PDT)
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsd/blocklayout: Make sure calculate signature/designator
 length aligned
Message-ID: <53d87a05-76c2-d1f5-4c48-52290468a6e7@gmail.com>
Date: Thu, 14 Jul 2016 12:01:17 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/blocklayoutxdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index 6c3b316..d72467e 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -43,7 +43,7 @@ nfsd4_block_encode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 
 	switch (b->type) {
 	case PNFS_BLOCK_VOLUME_SIMPLE:
-		len = 4 + 4 + 8 + 4 + b->simple.sig_len;
+		len = 4 + 4 + 8 + 4 + (XDR_QUADLEN(b->simple.sig_len) << 2);
 		p = xdr_reserve_space(xdr, len);
 		if (!p)
 			return -ETOOSMALL;
@@ -54,7 +54,7 @@ nfsd4_block_encode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		p = xdr_encode_opaque(p, b->simple.sig, b->simple.sig_len);
 		break;
 	case PNFS_BLOCK_VOLUME_SCSI:
-		len = 4 + 4 + 4 + 4 + b->scsi.designator_len + 8;
+		len = 4 + 4 + 4 + 4 + (XDR_QUADLEN(b->scsi.designator_len) << 2) + 8;
 		p = xdr_reserve_space(xdr, len);
 		if (!p)
 			return -ETOOSMALL;
-- 
2.7.4

