From: steved@redhat.com
Subject: [PATCH 20/23] gss_krb5: Use confounder length in wrap code
Date: Wed, 17 Mar 2010 13:03:05 -0400
Message-ID: <1268845388-9516-21-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43410 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754132Ab0CQRZz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:25:55 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweJ-0003fC-HJ
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:15 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

All encryption types use a confounder at the beginning of the
wrap token.  In all encryption types except arcfour-hmac, the
confounder is the same as the blocksize.  arcfour-hmac has a
blocksize of one, but uses an eight byte confounder.

Add an entry to the crypto framework definitions for the
confounder length and change the wrap/unwrap code to use
the confounder length rather than assuming it is always
the blocksize.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h       |    3 +++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 ++++
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   12 +++++++-----
 4 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 9cc39fe..582ad76 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -64,6 +64,9 @@ struct gss_krb5_enctype {
 	const u16		signalg;	/* signing algorithm */
 	const u16		sealalg;	/* sealing algorithm */
 	const u32		blocksize;	/* encryption blocksize */
+	const u32		conflen;	/* confounder length
+						   (normally the same as
+						   the blocksize) */
 	const u32		cksumlength;	/* checksum length */
 	const u32		keyed_cksum;	/* is it a keyed cksum? */
 	const u32		keybytes;	/* raw key len, in bytes */
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 5ace3cd..7d6c7ee 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -555,9 +555,9 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 
 	/* hide the gss token header and insert the confounder */
 	offset += GSS_KRB5_TOK_HDR_LEN;
-	if (xdr_extend_head(buf, offset, blocksize))
+	if (xdr_extend_head(buf, offset, kctx->gk5e->conflen))
 		return GSS_S_FAILURE;
-	make_confounder(buf->head[0].iov_base + offset, blocksize);
+	make_confounder(buf->head[0].iov_base + offset, kctx->gk5e->conflen);
 	offset -= GSS_KRB5_TOK_HDR_LEN;
 
 	if (buf->tail[0].iov_base != NULL) {
@@ -727,7 +727,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 		ret = GSS_S_BAD_SIG;
 		goto out_err;
 	}
-	*headskip = crypto_blkcipher_blocksize(cipher);
+	*headskip = kctx->gk5e->conflen;
 	*tailskip = kctx->gk5e->cksumlength;
 out_err:
 	if (ret && ret != GSS_S_BAD_SIG)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 41549e5..60bd6e4 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -68,6 +68,7 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keybytes = 7,
 	  .keylength = 8,
 	  .blocksize = 8,
+	  .conflen = 8,
 	  .cksumlength = 8,
 	  .keyed_cksum = 0,
 	},
@@ -88,6 +89,7 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keybytes = 21,
 	  .keylength = 24,
 	  .blocksize = 8,
+	  .conflen = 8,
 	  .cksumlength = 20,
 	  .keyed_cksum = 1,
 	},
@@ -110,6 +112,7 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keybytes = 16,
 	  .keylength = 16,
 	  .blocksize = 16,
+	  .conflen = 16,
 	  .cksumlength = 12,
 	  .keyed_cksum = 1,
 	},
@@ -132,6 +135,7 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keybytes = 32,
 	  .keylength = 32,
 	  .blocksize = 16,
+	  .conflen = 16,
 	  .cksumlength = 12,
 	  .keyed_cksum = 1,
 	},
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 82014cc..61cd3be 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -169,6 +169,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	struct page		**tmp_pages;
 	u32			seq_send;
 	u8			*cksumkey;
+	u32			conflen = kctx->gk5e->conflen;
 
 	dprintk("RPC:       %s\n", __func__);
 
@@ -177,7 +178,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	gss_krb5_add_padding(buf, offset, blocksize);
 	BUG_ON((buf->len - offset) % blocksize);
-	plainlen = blocksize + buf->len - offset;
+	plainlen = conflen + buf->len - offset;
 
 	headlen = g_token_size(&kctx->mech_used,
 		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + plainlen) -
@@ -205,7 +206,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	memset(ptr + 4, 0xff, 4);
 	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
 
-	make_confounder(msg_start, blocksize);
+	make_confounder(msg_start, conflen);
 
 	if (kctx->gk5e->keyed_cksum)
 		cksumkey = kctx->cksum;
@@ -215,7 +216,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - blocksize,
+	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - conflen,
 					cksumkey, KG_USAGE_SEAL, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
@@ -232,7 +233,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
-	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - blocksize,
+	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - conflen,
 									pages))
 		return GSS_S_FAILURE;
 
@@ -255,6 +256,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	void			*data_start, *orig_start;
 	int			data_len;
 	int			blocksize;
+	u32			conflen = kctx->gk5e->conflen;
 	int			crypt_offset;
 	u8			*cksumkey;
 
@@ -328,7 +330,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
-					blocksize;
+					conflen;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
 	memmove(orig_start, data_start, data_len);
-- 
1.6.6.1

