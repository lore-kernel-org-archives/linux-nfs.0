Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52774 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaGFDfk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jul 2014 23:35:40 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so3665865pab.30
        for <linux-nfs@vger.kernel.org>; Sat, 05 Jul 2014 20:35:39 -0700 (PDT)
Message-ID: <53B8C3D3.7080201@gmail.com>
Date: Sun, 06 Jul 2014 11:34:43 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: kinglongmee@gmail.com, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduced by commit 561f0ed498 (nfsd4: allow large readdirs).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3540462..5a1d088 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2646,7 +2646,7 @@ nfsd4_encode_rdattr_error(struct xdr_stream *xdr, __be32 nfserr)
 {
 	__be32 *p;
 
-	p = xdr_reserve_space(xdr, 6);
+	p = xdr_reserve_space(xdr, 20);
 	if (!p)
 		return NULL;
 	*p++ = htonl(2);
-- 
1.9.3

