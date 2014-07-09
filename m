Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:47852 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbaGINv6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 09:51:58 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so8935917pde.6
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jul 2014 06:51:58 -0700 (PDT)
Message-ID: <53BD48DF.2050506@gmail.com>
Date: Wed, 09 Jul 2014 21:51:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Fix bad checking of space for padding in splice read
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix commit dc97618ddd (nfsd4: separate splice and readv cases).
xdr->end and xdr->p are type of __be32 *, so padding needs one here.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 523c666..8a2fbb2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3067,11 +3067,8 @@ static __be32 nfsd4_encode_splice_read(
 	__be32 nfserr;
 	__be32 *p = xdr->p - 2;
 
-	/*
-	 * Don't inline pages unless we know there's room for eof,
-	 * count, and possible padding:
-	 */
-	if (xdr->end - xdr->p < 3)
+	/* Make sure there will be room for padding if needed */
+	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
 	nfserr = nfsd_splice_read(read->rd_rqstp, file,
-- 
1.9.3

