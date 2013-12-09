Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:32959 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932691Ab3LILba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 06:31:30 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so5279474pbc.12
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 03:31:30 -0800 (PST)
Message-ID: <52A5AA09.4030409@gmail.com>
Date: Mon, 09 Dec 2013 19:31:21 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: make calculate  reserved space correctly
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcsec_gss_oid is defined as below, So, must using XDR_LEN to calculate reserved space.
When len is not the multiples of 4, client will get bad data.

struct rpcsec_gss_oid {
        unsigned int    len;
        u8              data[GSS_OID_MAX_LEN];
};

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b0b886e..a57e67d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3233,7 +3233,7 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 
 		if (rpcauth_get_gssinfo(pf, &info) == 0) {
 			supported++;
-			RESERVE_SPACE(4 + 4 + info.oid.len + 4 + 4);
+			RESERVE_SPACE(4 + 4 + XDR_LEN(info.oid.len) + 4 + 4);
 			WRITE32(RPC_AUTH_GSS);
 			WRITE32(info.oid.len);
 			WRITEMEM(info.oid.data, info.oid.len);
-- 
1.8.4.2
