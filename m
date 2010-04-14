From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/22] gss_krb5: Use confounder length in wrap code
Date: Wed, 14 Apr 2010 13:36:56 -0400
Message-ID: <1271266618-26016-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-20-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756554Ab0DNRhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:22 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawKG021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:10 -0700 (PDT)
In-Reply-To: <1271266618-26016-20-git-send-email-Trond.Myklebust@netapp.com>
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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h       |    3 +++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 ++++
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   12 +++++++-----
 4 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index d840856..79f6ac2 100644
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
index 33ae702..ed4106a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -554,9 +554,9 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 
 	/* hide the gss token header and insert the confounder */
 	offset += GSS_KRB5_TOK_HDR_LEN;
-	if (xdr_extend_head(buf, offset, blocksize))
+	if (xdr_extend_head(buf, offset, kctx->gk5e->conflen))
 		return GSS_S_FAILURE;
-	gss_krb5_make_confounder(buf->head[0].iov_base + offset, blocksize);
+	gss_krb5_make_confounder(buf->head[0].iov_base + offset, kctx->gk5e->conflen);
 	offset -= GSS_KRB5_TOK_HDR_LEN;
 
 	if (buf->tail[0].iov_base != NULL) {
@@ -726,7 +726,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 		ret = GSS_S_BAD_SIG;
 		goto out_err;
 	}
-	*headskip = crypto_blkcipher_blocksize(cipher);
+	*headskip = kctx->gk5e->conflen;
 	*tailskip = kctx->gk5e->cksumlength;
 out_err:
 	if (ret && ret != GSS_S_BAD_SIG)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 6908d38..1135056 100644
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
index a95e7e0..383db89 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -168,6 +168,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	struct page		**tmp_pages;
 	u32			seq_send;
 	u8			*cksumkey;
+	u32			conflen = kctx->gk5e->conflen;
 
 	dprintk("RPC:       %s\n", __func__);
 
@@ -176,7 +177,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	gss_krb5_add_padding(buf, offset, blocksize);
 	BUG_ON((buf->len - offset) % blocksize);
-	plainlen = blocksize + buf->len - offset;
+	plainlen = conflen + buf->len - offset;
 
 	headlen = g_token_size(&kctx->mech_used,
 		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + plainlen) -
@@ -204,7 +205,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	memset(ptr + 4, 0xff, 4);
 	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
 
-	gss_krb5_make_confounder(msg_start, blocksize);
+	gss_krb5_make_confounder(msg_start, conflen);
 
 	if (kctx->gk5e->keyed_cksum)
 		cksumkey = kctx->cksum;
@@ -214,7 +215,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - blocksize,
+	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - conflen,
 					cksumkey, KG_USAGE_SEAL, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
@@ -231,7 +232,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
-	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - blocksize,
+	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - conflen,
 									pages))
 		return GSS_S_FAILURE;
 
@@ -254,6 +255,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	void			*data_start, *orig_start;
 	int			data_len;
 	int			blocksize;
+	u32			conflen = kctx->gk5e->conflen;
 	int			crypt_offset;
 	u8			*cksumkey;
 
@@ -327,7 +329,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
-					blocksize;
+					conflen;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
 	memmove(orig_start, data_start, data_len);
-- 
1.6.6.1

