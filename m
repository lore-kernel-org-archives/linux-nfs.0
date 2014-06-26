Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35551 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbaFZOXR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 10:23:17 -0400
Received: by mail-wg0-f41.google.com with SMTP id a1so3724662wgh.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 07:23:16 -0700 (PDT)
From: Avi Kivity <avi@cloudius-systems.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix nfs4d readlink truncated packet
Date: Thu, 26 Jun 2014 17:23:12 +0300
Message-Id: <1403792592-1517-1-git-send-email-avi@cloudius-systems.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

XDR requires 4-byte alignment; nfs4d READLINK reply writes out the padding,
but truncates the packet to the padding-less size.

Fix by taking the padding into consideration when truncating the packet.

Signed-off-by: Avi Kivity <avi@cloudius-systems.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 83baf2b..cba93ea 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3267,7 +3267,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 
 	wire_count = htonl(maxcount);
 	write_bytes_to_xdr_buf(xdr->buf, length_offset, &wire_count, 4);
-	xdr_truncate_encode(xdr, length_offset + 4 + maxcount);
+	xdr_truncate_encode(xdr, length_offset + 4 + ALIGN(maxcount, 4));
 	if (maxcount & 3)
 		write_bytes_to_xdr_buf(xdr->buf, length_offset + 4 + maxcount,
 						&zero, 4 - (maxcount&3));
-- 
1.9.3

