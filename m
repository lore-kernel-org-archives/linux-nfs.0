From: steved@redhat.com
Subject: [PATCH 01/23] gss_krb5: Introduce encryption type framework
Date: Wed, 17 Mar 2010 13:02:46 -0400
Message-ID: <1268845388-9516-2-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:55120 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753242Ab0CQRDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:03:11 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweD-0003fC-4o
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:09 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Make the client and server code consistent regarding the extra buffer
space made available for the auth code when wrapping data.

Add some comments/documentation about the available buffer space
in the xdr_buf head and tail when gss_wrap is called.

Add a compile-time check to make sure we are not exceeding the available
buffer space.

Add a central function to shift head data.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h       |   25 +++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   38 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +---
 4 files changed, 66 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index e7bbdba..00dc5cf 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -40,6 +40,12 @@
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
 
+/* Maximum checksum function output for the supported crypto algorithms */
+#define GSS_KRB5_MAX_CKSUM_LEN  (20)
+
+/* Maximum blocksize for the supported crypto algorithms */
+#define GSS_KRB5_MAX_BLOCKSIZE  (16)
+
 struct krb5_ctx {
 	int			initiate; /* 1 = initiating, 0 = accepting */
 	struct crypto_blkcipher	*enc;
@@ -113,6 +119,22 @@ enum seal_alg {
 #define ENCTYPE_DES3_CBC_SHA1   0x0010
 #define ENCTYPE_UNKNOWN         0x01ff
 
+/*
+ * This compile-time check verifies that we will not exceed the
+ * slack space allotted by the client and server auth_gss code
+ * before they call gss_wrap().
+ */
+#define GSS_KRB5_MAX_SLACK_NEEDED \
+	GSS_KRB5_TOK_HDR_LEN      /* gss token header */         \
+	+ GSS_KRB5_MAX_CKSUM_LEN  /* gss token checksum */       \
+	+ GSS_KRB5_MAX_BLOCKSIZE  /* confounder */               \
+	+ GSS_KRB5_MAX_BLOCKSIZE  /* possible padding */         \
+	+ GSS_KRB5_TOK_HDR_LEN    /* encrypted hdr in v2 token */\
+	+ GSS_KRB5_MAX_CKSUM_LEN  /* encryption hmac */          \
+	+ 4 + 4                   /* RPC verifier */             \
+	+ GSS_KRB5_TOK_HDR_LEN                                   \
+	+ GSS_KRB5_MAX_CKSUM_LEN
+
 s32
 make_checksum(char *, char *header, int hdrlen, struct xdr_buf *body,
 		   int body_offset, struct xdr_netobj *cksum);
@@ -157,3 +179,6 @@ s32
 krb5_get_seq_num(struct crypto_blkcipher *key,
 	       unsigned char *cksum,
 	       unsigned char *buf, int *direction, u32 *seqnum);
+
+int
+xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0cfccc2..7c50ea6 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -61,7 +61,7 @@ static const struct rpc_credops gss_nullops;
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define GSS_CRED_SLACK		1024
+#define GSS_CRED_SLACK		(RPC_MAX_AUTH_SIZE * 2)
 /* length of a krb5 verifier (48), plus data added before arguments when
  * using integrity (two 4-byte integers): */
 #define GSS_VERF_SLACK		100
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index c93fca2..52dfde0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -326,3 +326,41 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 
 	return xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
 }
+
+/*
+ * This function makes the assumption that it was ultimately called
+ * from gss_wrap().
+ *
+ * The client auth_gss code moves any existing tail data into a
+ * separate page before calling gss_wrap.
+ * The server svcauth_gss code ensures that both the head and the
+ * tail have slack space of RPC_MAX_AUTH_SIZE before calling gss_wrap.
+ *
+ * Even with that guarantee, this function may be called more than
+ * once in the processing of gss_wrap().  The best we can do is
+ * verify at compile-time (see GSS_KRB5_SLACK_CHECK) that the
+ * largest expected shift will fit within RPC_MAX_AUTH_SIZE.
+ * At run-time we can verify that a single invocation of this
+ * function doesn't attempt to use more the RPC_MAX_AUTH_SIZE.
+ */
+
+int
+xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen)
+{
+	u8 *p;
+
+	if (shiftlen == 0)
+		return 0;
+
+	BUILD_BUG_ON(GSS_KRB5_MAX_SLACK_NEEDED > RPC_MAX_AUTH_SIZE);
+	BUG_ON(shiftlen > RPC_MAX_AUTH_SIZE);
+
+	p = buf->head[0].iov_base + base;
+
+	memmove(p + shiftlen, p, buf->head[0].iov_len - base);
+
+	buf->head[0].iov_len += shiftlen;
+	buf->len += shiftlen;
+
+	return 0;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index ae8e69b..8bc3701 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -156,11 +156,9 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 
 	ptr = buf->head[0].iov_base + offset;
 	/* shift data to make room for header. */
+	xdr_extend_head(buf, offset, headlen);
+
 	/* XXX Would be cleverer to encrypt while copying. */
-	/* XXX bounds checking, slack, etc. */
-	memmove(ptr + headlen, ptr, buf->head[0].iov_len - offset);
-	buf->head[0].iov_len += headlen;
-	buf->len += headlen;
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
 	g_make_token_header(&kctx->mech_used,
-- 
1.6.6.1

