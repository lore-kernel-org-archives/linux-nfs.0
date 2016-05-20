Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from arethusa2.fi.muni.cz ([147.251.49.7]:55641 "EHLO
	arethusa2.fi.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbcETOqx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2016 10:46:53 -0400
From: =?utf-8?B?VG9tw6HFoQ==?= Trnka <ttrnka@mail.muni.cz>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: fix stripping of padded MIC tokens
Date: Fri, 20 May 2016 16:41:10 +0200
Message-ID: <38521704.8vjDAt0XQs@mintaka.ncbr.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The length of the GSS MIC token need not be a multiple of four bytes.
It is then padded by XDR to a multiple of 4 B, but unwrap_integ_data()
would previously only trim mic.len + 4 B. The remaining up to three
bytes would then trigger a check in nfs4svc_decode_compoundargs(),
leading to a "garbage args" error and mount failure:

nfs4svc_decode_compoundargs: compound not properly padded!
nfsd: failed to decode arguments!

This would prevent older clients using the pre-RFC 4121 MIC format
(37-byte MIC including a 9-byte OID) from mounting exports from v3.9+
servers using krb5i.

The trimming was introduced by commit 4c190e2f913f ("sunrpc: trim off
trailing checksum before returning decrypted or integrity authenticated
buffer").

Signed-off-by: Tomáš Trnka <ttrnka@mail.muni.cz>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c 
b/net/sunrpc/auth_gss/svcauth_gss.c
index 1095be9..4605dc7 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -857,8 +857,8 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf 
*buf, u32 seq, struct g
 		goto out;
 	if (svc_getnl(&buf->head[0]) != seq)
 		goto out;
-	/* trim off the mic at the end before returning */
-	xdr_buf_trim(buf, mic.len + 4);
+	/* trim off the mic and padding at the end before returning */
+	xdr_buf_trim(buf, round_up_to_quad(mic.len) + 4);
 	stat = 0;
 out:
 	kfree(mic.data);
-- 
2.5.5

