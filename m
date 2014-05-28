Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41544 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbaE1In7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 04:43:59 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: getattr for FATTR4_WORD0_FILES_AVAIL needs the statfs buffer
Date: Wed, 28 May 2014 10:46:13 +0200
Message-Id: <1401266773-19048-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d23412e..4bfe880c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2049,8 +2049,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 	err = vfs_getattr(&path, &stat);
 	if (err)
 		goto out_nfserr;
-	if ((bmval0 & (FATTR4_WORD0_FILES_FREE | FATTR4_WORD0_FILES_TOTAL |
-			FATTR4_WORD0_MAXNAME)) ||
+	if ((bmval0 & (FATTR4_WORD0_FILES_AVAIL | FATTR4_WORD0_FILES_FREE |
+			FATTR4_WORD0_FILES_TOTAL | FATTR4_WORD0_MAXNAME)) ||
 	    (bmval1 & (FATTR4_WORD1_SPACE_AVAIL | FATTR4_WORD1_SPACE_FREE |
 		       FATTR4_WORD1_SPACE_TOTAL))) {
 		err = vfs_statfs(&path, &statfs);
-- 
1.7.10.4

