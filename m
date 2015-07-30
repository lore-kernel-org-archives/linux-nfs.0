Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36789 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbG3Nym (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:54:42 -0400
Received: by pachj5 with SMTP id hj5so23979817pac.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:54:42 -0700 (PDT)
Message-ID: <55BA2C92.5000600@gmail.com>
Date: Thu, 30 Jul 2015 21:54:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 3/5] nfsd: SUPPATTR_EXCLCREAT must be encoded before SECURITY_LABEL.
References: <55BA2B46.90204@gmail.com>
In-Reply-To: <55BA2B46.90204@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The encode order should be as the bitmask defined order.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 76d6653..21e1263 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2734,12 +2734,6 @@ out_acl:
 		*p++ = cpu_to_be32(stat.blksize);
 	}
 #endif /* CONFIG_NFSD_PNFS */
-	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
-		status = nfsd4_encode_security_label(xdr, rqstp, context,
-								contextlen);
-		if (status)
-			goto out;
-	}
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
 		p = xdr_reserve_space(xdr, 16);
 		if (!p)
@@ -2750,6 +2744,13 @@ out_acl:
 		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
 	}
 
+	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
+		status = nfsd4_encode_security_label(xdr, rqstp, context,
+								contextlen);
+		if (status)
+			goto out;
+	}
+
 	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
 	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
 	status = nfs_ok;
-- 
2.4.3

