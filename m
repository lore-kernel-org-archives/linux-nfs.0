Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35234 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbbG3OWj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 10:22:39 -0400
Received: by pabkd10 with SMTP id kd10so24344330pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 07:22:39 -0700 (PDT)
Message-ID: <55BA3320.8050502@gmail.com>
Date: Thu, 30 Jul 2015 22:22:24 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH] NFS: Decode security label as an array
References: <55B76B9B.4090700@gmail.com> <20150729193734.GB21949@fieldses.org> <55BA130C.1050604@gmail.com>
In-Reply-To: <55BA130C.1050604@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According at,
https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-38#section-12.2.4

"The FATTR4_SEC_LABEL contains an array of two components with the
 first component being an LFS."

So, the security label returned from server should be stored in an array.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4xdr.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..d8a35d2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4114,17 +4114,21 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[2] & (FATTR4_WORD2_SECURITY_LABEL - 1U)))
 		return -EIO;
 	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
-		p = xdr_inline_decode(xdr, 4);
+		uint32_t dummy;
+
+		p = xdr_inline_decode(xdr, 16);
 		if (unlikely(!p))
 			goto out_overflow;
-		lfs = be32_to_cpup(p++);
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
+
+		dummy = be32_to_cpup(p++);
+		if (dummy != 1) {
+			printk(KERN_WARNING "%s: More than one labels (%u)!",
+				__func__, dummy);
 			goto out_overflow;
+		}
+
+		lfs = be32_to_cpup(p++);
 		pi = be32_to_cpup(p++);
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
-			goto out_overflow;
 		len = be32_to_cpup(p++);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
-- 
2.4.3

