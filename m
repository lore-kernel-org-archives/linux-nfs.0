From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 08/19] Remove define for KRB5_CKSUM_LENGTH,
	which will become enctype-dependent
Date: Thu, 21 Feb 2008 13:44:27 -0500
Message-ID: <20080221184427.19195.16243.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:42043 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833AbYBUSo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:27 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 804334606
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:27 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cleanup: When adding new encryption types, the checksum length
can be different for each enctype.  Face the fact that the
current code only supports DES which has a checksum length of 8.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h     |    2 --
 net/sunrpc/auth_gss/gss_krb5_seal.c |    3 +--
 net/sunrpc/auth_gss/gss_krb5_wrap.c |    4 +---
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 8c38aba..47d2110 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -72,8 +72,6 @@ enum seal_alg {
 
 extern struct xdr_netobj krb5_oid;
 
-#define KRB5_CKSUM_LENGTH 8
-
 #define CKSUMTYPE_CRC32			0x0001
 #define CKSUMTYPE_RSA_MD4		0x0002
 #define CKSUMTYPE_RSA_MD4_DES		0x0003
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index b2fa785..e7b2a52 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -109,8 +109,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 			  md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
 
-	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - KRB5_CKSUM_LENGTH,
-	       KRB5_CKSUM_LENGTH);
+	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send++;
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 384f470..9763bf1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -160,9 +160,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
 			  md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
-	memcpy(krb5_hdr + 16,
-	       md5cksum.data + md5cksum.len - KRB5_CKSUM_LENGTH,
-	       KRB5_CKSUM_LENGTH);
+	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = kctx->seq_send++;

