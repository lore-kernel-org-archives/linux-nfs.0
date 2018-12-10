Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 401F1C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CAF3D20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BMybOI8n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAF3D20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728202AbeLJQat (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:49 -0500
Received: from mail-it1-f171.google.com ([209.85.166.171]:39455 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726261AbeLJQas (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:48 -0500
Received: by mail-it1-f171.google.com with SMTP id a6so19093894itl.4;
        Mon, 10 Dec 2018 08:30:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=7QjRPXg+O+T8Qh6JFQMpn/iSMG9cki9CXqNKrcNR2Bw=;
        b=BMybOI8nV3D722I3WkdIluAsx4dDiobAysosznBJHI138sTJFv6BdQ4Up1l5CxOt4c
         8ZmALsPBeDvtOpP4Pj2i6OB1Z9o1XqhlFqiS9pi8J9pCdBIOH0ZPKN1Of9621B7M94fs
         LrnjOs/sSu3zZ+Qat7DHRT3lXi9KDZ9Zy+SxwR/OP//O5sbCYZwc1n2a1bucNQWIaAOn
         rwcm4+z1LmP0vWQBFk+hsFbbSLiYIK1I/J2LAzmd85ufxwFAaDYz+doygz3Ze8iGIXqf
         WZSVsFJOVLAXSJPP4YuLIWjSNYe7x4MImRtSkgeFpKn270FDdu5jywgtfbHyK84zTuzG
         +AHg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7QjRPXg+O+T8Qh6JFQMpn/iSMG9cki9CXqNKrcNR2Bw=;
        b=VMUuNTEVngAR9As4RmaQMm0qUtnd/S4rsMdDc9LSGYqNh7qc0lfiEfw/75z1d1V0jS
         pn9Rq4pUnzGa/YNSRIYwe+wGY7cSsnPKaD+/157F7ZDH6V2UCttSZGrcMH/vn2KYIV19
         jdFDjDi/YmZIGWMMCSqF1+5abmU7uL+k72pDK6ELqFXZ3qki2S/VigwXZP0TBHSIAugo
         2qRTz5jxmhAJHMcy8e3Lpo9+fnsIbETPfrDUiVVaqiwTGMVzsLxlG4ugkZBA6RQa1jEu
         PTSdZtXFzzWOUMllYVaTiL6KngPtBHZldfLp4X/GEtHMResshh9FCum8WP+ebxbhtTmP
         +Qmg==
X-Gm-Message-State: AA+aEWaXxlBZQvtFzH91XlCLnbYDomwLN2irQJP5PTkDt8GlJGGMDkZx
        B74HNW0IP9h41iwxOKMwpiQK3vxi
X-Google-Smtp-Source: AFSGD/VcWnqoLTLSmPAhF35gQaQ/lx35FZsUGfoVx3Wd8WHJcbosorFR+k2A+sDqD51uyhapA+af0w==
X-Received: by 2002:a24:ec01:: with SMTP id g1mr12323928ith.152.1544459445831;
        Mon, 10 Dec 2018 08:30:45 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l15sm4478164iok.42.2018.12.10.08.30.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:45 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUiMv031070;
        Mon, 10 Dec 2018 16:30:44 GMT
Subject: [PATCH v3 16/24] SUNRPC: Remove support for kerberos_v1
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:44 -0500
Message-ID: <20181210163044.4198.33386.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Kerberos v1 allows the selection of encryption types that are known
to be insecure and are no longer widely deployed. Also there is no
convenient facility for testing v1 or these enctypes, so essentially
this code has been untested for some time.

Note that RFC 6649 deprecates DES and Arcfour_56 in Kerberos, and
RFC 8429 (October 2018) deprecates DES3 and Arcfour.

Support for DES_CBC_RAW, DES_CBC_CRC, DES_CBC_MD4, DES_CBC_MD5,
DES3_CBC_RAW, and ARCFOUR_HMAC encryption in the Linux kernel
RPCSEC_GSS implementation is removed by this patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/gss_krb5.h          |   39 ---
 include/linux/sunrpc/gss_krb5_enctypes.h |    2 
 net/sunrpc/Kconfig                       |    3 
 net/sunrpc/auth_gss/Makefile             |    2 
 net/sunrpc/auth_gss/gss_krb5_crypto.c    |  423 ------------------------------
 net/sunrpc/auth_gss/gss_krb5_keys.c      |   53 ----
 net/sunrpc/auth_gss/gss_krb5_mech.c      |  278 --------------------
 net/sunrpc/auth_gss/gss_krb5_seal.c      |   73 -----
 net/sunrpc/auth_gss/gss_krb5_seqnum.c    |  164 ------------
 net/sunrpc/auth_gss/gss_krb5_unseal.c    |   80 ------
 net/sunrpc/auth_gss/gss_krb5_wrap.c      |  254 ------------------
 11 files changed, 12 insertions(+), 1359 deletions(-)
 delete mode 100644 net/sunrpc/auth_gss/gss_krb5_seqnum.c

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 02c0412..57f4a49 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -105,7 +105,6 @@ struct krb5_ctx {
 	struct crypto_sync_skcipher *acceptor_enc_aux;
 	struct crypto_sync_skcipher *initiator_enc_aux;
 	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session key */
-	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	atomic_t		seq_send;
 	atomic64_t		seq_send64;
@@ -235,11 +234,6 @@ enum seal_alg {
 	+ GSS_KRB5_MAX_CKSUM_LEN)
 
 u32
-make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
-		struct xdr_buf *body, int body_offset, u8 *cksumkey,
-		unsigned int usage, struct xdr_netobj *cksumout);
-
-u32
 make_checksum_v2(struct krb5_ctx *, char *header, int hdrlen,
 		 struct xdr_buf *body, int body_offset, u8 *key,
 		 unsigned int usage, struct xdr_netobj *cksum);
@@ -268,25 +262,6 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 	     void *iv, void *in, void *out, int length); 
 
 int
-gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *outbuf,
-		    int offset, struct page **pages);
-
-int
-gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *inbuf,
-		    int offset);
-
-s32
-krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_sync_skcipher *key,
-		int direction,
-		u32 seqnum, unsigned char *cksum, unsigned char *buf);
-
-s32
-krb5_get_seq_num(struct krb5_ctx *kctx,
-	       unsigned char *cksum,
-	       unsigned char *buf, int *direction, u32 *seqnum);
-
-int
 xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen);
 
 u32
@@ -297,11 +272,6 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 		gfp_t gfp_mask);
 
 u32
-gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
-		       struct xdr_netobj *randombits,
-		       struct xdr_netobj *key);
-
-u32
 gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
 		      struct xdr_netobj *randombits,
 		      struct xdr_netobj *key);
@@ -316,14 +286,5 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 		     struct xdr_buf *buf, u32 *plainoffset,
 		     u32 *plainlen);
 
-int
-krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
-		       struct crypto_sync_skcipher *cipher,
-		       unsigned char *cksum);
-
-int
-krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
-		       struct crypto_sync_skcipher *cipher,
-		       s32 seqnum);
 void
 gss_krb5_make_confounder(char *p, u32 conflen);
diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h b/include/linux/sunrpc/gss_krb5_enctypes.h
index ec6234e..7a8abcf 100644
--- a/include/linux/sunrpc/gss_krb5_enctypes.h
+++ b/include/linux/sunrpc/gss_krb5_enctypes.h
@@ -1,4 +1,4 @@
 /*
  * Dumb way to share this static piece of information with nfsd
  */
-#define KRB5_SUPPORTED_ENCTYPES "18,17,16,23,3,1,2"
+#define KRB5_SUPPORTED_ENCTYPES "18,17"
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index ac09ca8..80c8efc 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -18,9 +18,8 @@ config SUNRPC_SWAP
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism"
 	depends on SUNRPC && CRYPTO
-	depends on CRYPTO_MD5 && CRYPTO_DES && CRYPTO_CBC && CRYPTO_CTS
+	depends on CRYPTO_MD5 && CRYPTO_CTS
 	depends on CRYPTO_ECB && CRYPTO_HMAC && CRYPTO_SHA1 && CRYPTO_AES
-	depends on CRYPTO_ARC4
 	default y
 	select SUNRPC_GSS
 	help
diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
index c374268..b5a65a0 100644
--- a/net/sunrpc/auth_gss/Makefile
+++ b/net/sunrpc/auth_gss/Makefile
@@ -12,4 +12,4 @@ auth_rpcgss-y := auth_gss.o gss_generic_token.o \
 obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 
 rpcsec_gss_krb5-y := gss_krb5_mech.o gss_krb5_seal.o gss_krb5_unseal.o \
-	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
+	gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 4f43383..896dd87 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -138,230 +138,6 @@
 	return crypto_ahash_update(req);
 }
 
-static int
-arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
-{
-	unsigned int ms_usage;
-
-	switch (usage) {
-	case KG_USAGE_SIGN:
-		ms_usage = 15;
-		break;
-	case KG_USAGE_SEAL:
-		ms_usage = 13;
-		break;
-	default:
-		return -EINVAL;
-	}
-	salt[0] = (ms_usage >> 0) & 0xff;
-	salt[1] = (ms_usage >> 8) & 0xff;
-	salt[2] = (ms_usage >> 16) & 0xff;
-	salt[3] = (ms_usage >> 24) & 0xff;
-
-	return 0;
-}
-
-static u32
-make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
-		       struct xdr_buf *body, int body_offset, u8 *cksumkey,
-		       unsigned int usage, struct xdr_netobj *cksumout)
-{
-	struct scatterlist              sg[1];
-	int err = -1;
-	u8 *checksumdata;
-	u8 *rc4salt;
-	struct crypto_ahash *md5;
-	struct crypto_ahash *hmac_md5;
-	struct ahash_request *req;
-
-	if (cksumkey == NULL)
-		return GSS_S_FAILURE;
-
-	if (cksumout->len < kctx->gk5e->cksumlength) {
-		dprintk("%s: checksum buffer length, %u, too small for %s\n",
-			__func__, cksumout->len, kctx->gk5e->name);
-		return GSS_S_FAILURE;
-	}
-
-	rc4salt = kmalloc_array(4, sizeof(*rc4salt), GFP_NOFS);
-	if (!rc4salt)
-		return GSS_S_FAILURE;
-
-	if (arcfour_hmac_md5_usage_to_salt(usage, rc4salt)) {
-		dprintk("%s: invalid usage value %u\n", __func__, usage);
-		goto out_free_rc4salt;
-	}
-
-	checksumdata = kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_NOFS);
-	if (!checksumdata)
-		goto out_free_rc4salt;
-
-	md5 = crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(md5))
-		goto out_free_cksum;
-
-	hmac_md5 = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0,
-				      CRYPTO_ALG_ASYNC);
-	if (IS_ERR(hmac_md5))
-		goto out_free_md5;
-
-	req = ahash_request_alloc(md5, GFP_NOFS);
-	if (!req)
-		goto out_free_hmac_md5;
-
-	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
-
-	err = crypto_ahash_init(req);
-	if (err)
-		goto out;
-	sg_init_one(sg, rc4salt, 4);
-	ahash_request_set_crypt(req, sg, NULL, 4);
-	err = crypto_ahash_update(req);
-	if (err)
-		goto out;
-
-	sg_init_one(sg, header, hdrlen);
-	ahash_request_set_crypt(req, sg, NULL, hdrlen);
-	err = crypto_ahash_update(req);
-	if (err)
-		goto out;
-	err = xdr_process_buf(body, body_offset, body->len - body_offset,
-			      checksummer, req);
-	if (err)
-		goto out;
-	ahash_request_set_crypt(req, NULL, checksumdata, 0);
-	err = crypto_ahash_final(req);
-	if (err)
-		goto out;
-
-	ahash_request_free(req);
-	req = ahash_request_alloc(hmac_md5, GFP_NOFS);
-	if (!req)
-		goto out_free_hmac_md5;
-
-	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
-
-	err = crypto_ahash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
-	if (err)
-		goto out;
-
-	sg_init_one(sg, checksumdata, crypto_ahash_digestsize(md5));
-	ahash_request_set_crypt(req, sg, checksumdata,
-				crypto_ahash_digestsize(md5));
-	err = crypto_ahash_digest(req);
-	if (err)
-		goto out;
-
-	memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
-	cksumout->len = kctx->gk5e->cksumlength;
-out:
-	ahash_request_free(req);
-out_free_hmac_md5:
-	crypto_free_ahash(hmac_md5);
-out_free_md5:
-	crypto_free_ahash(md5);
-out_free_cksum:
-	kfree(checksumdata);
-out_free_rc4salt:
-	kfree(rc4salt);
-	return err ? GSS_S_FAILURE : 0;
-}
-
-/*
- * checksum the plaintext data and hdrlen bytes of the token header
- * The checksum is performed over the first 8 bytes of the
- * gss token header and then over the data body
- */
-u32
-make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
-	      struct xdr_buf *body, int body_offset, u8 *cksumkey,
-	      unsigned int usage, struct xdr_netobj *cksumout)
-{
-	struct crypto_ahash *tfm;
-	struct ahash_request *req;
-	struct scatterlist              sg[1];
-	int err = -1;
-	u8 *checksumdata;
-	unsigned int checksumlen;
-
-	if (kctx->gk5e->ctype == CKSUMTYPE_HMAC_MD5_ARCFOUR)
-		return make_checksum_hmac_md5(kctx, header, hdrlen,
-					      body, body_offset,
-					      cksumkey, usage, cksumout);
-
-	if (cksumout->len < kctx->gk5e->cksumlength) {
-		dprintk("%s: checksum buffer length, %u, too small for %s\n",
-			__func__, cksumout->len, kctx->gk5e->name);
-		return GSS_S_FAILURE;
-	}
-
-	checksumdata = kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_NOFS);
-	if (checksumdata == NULL)
-		return GSS_S_FAILURE;
-
-	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(tfm))
-		goto out_free_cksum;
-
-	req = ahash_request_alloc(tfm, GFP_NOFS);
-	if (!req)
-		goto out_free_ahash;
-
-	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
-
-	checksumlen = crypto_ahash_digestsize(tfm);
-
-	if (cksumkey != NULL) {
-		err = crypto_ahash_setkey(tfm, cksumkey,
-					  kctx->gk5e->keylength);
-		if (err)
-			goto out;
-	}
-
-	err = crypto_ahash_init(req);
-	if (err)
-		goto out;
-	sg_init_one(sg, header, hdrlen);
-	ahash_request_set_crypt(req, sg, NULL, hdrlen);
-	err = crypto_ahash_update(req);
-	if (err)
-		goto out;
-	err = xdr_process_buf(body, body_offset, body->len - body_offset,
-			      checksummer, req);
-	if (err)
-		goto out;
-	ahash_request_set_crypt(req, NULL, checksumdata, 0);
-	err = crypto_ahash_final(req);
-	if (err)
-		goto out;
-
-	switch (kctx->gk5e->ctype) {
-	case CKSUMTYPE_RSA_MD5:
-		err = kctx->gk5e->encrypt(kctx->seq, NULL, checksumdata,
-					  checksumdata, checksumlen);
-		if (err)
-			goto out;
-		memcpy(cksumout->data,
-		       checksumdata + checksumlen - kctx->gk5e->cksumlength,
-		       kctx->gk5e->cksumlength);
-		break;
-	case CKSUMTYPE_HMAC_SHA1_DES3:
-		memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
-		break;
-	default:
-		BUG();
-		break;
-	}
-	cksumout->len = kctx->gk5e->cksumlength;
-out:
-	ahash_request_free(req);
-out_free_ahash:
-	crypto_free_ahash(tfm);
-out_free_cksum:
-	kfree(checksumdata);
-	return err ? GSS_S_FAILURE : 0;
-}
-
 /*
  * checksum the plaintext data and hdrlen bytes of the token header
  * Per rfc4121, sec. 4.2.4, the checksum is performed over the data
@@ -526,35 +302,6 @@ struct encryptor_desc {
 	return 0;
 }
 
-int
-gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *buf,
-		    int offset, struct page **pages)
-{
-	int ret;
-	struct encryptor_desc desc;
-	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
-
-	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) != 0);
-
-	skcipher_request_set_sync_tfm(req, tfm);
-	skcipher_request_set_callback(req, 0, NULL, NULL);
-
-	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.req = req;
-	desc.pos = offset;
-	desc.outbuf = buf;
-	desc.pages = pages;
-	desc.fragno = 0;
-	desc.fraglen = 0;
-
-	sg_init_table(desc.infrags, 4);
-	sg_init_table(desc.outfrags, 4);
-
-	ret = xdr_process_buf(buf, offset, buf->len - offset, encryptor, &desc);
-	skcipher_request_zero(req);
-	return ret;
-}
-
 struct decryptor_desc {
 	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct skcipher_request *req;
@@ -609,32 +356,6 @@ struct decryptor_desc {
 	return 0;
 }
 
-int
-gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *buf,
-		    int offset)
-{
-	int ret;
-	struct decryptor_desc desc;
-	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
-
-	/* XXXJBF: */
-	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) != 0);
-
-	skcipher_request_set_sync_tfm(req, tfm);
-	skcipher_request_set_callback(req, 0, NULL, NULL);
-
-	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.req = req;
-	desc.fragno = 0;
-	desc.fraglen = 0;
-
-	sg_init_table(desc.frags, 4);
-
-	ret = xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
-	skcipher_request_zero(req);
-	return ret;
-}
-
 /*
  * This function makes the assumption that it was ultimately called
  * from gss_wrap().
@@ -942,147 +663,3 @@ struct decryptor_desc {
 		ret = GSS_S_FAILURE;
 	return ret;
 }
-
-/*
- * Compute Kseq given the initial session key and the checksum.
- * Set the key of the given cipher.
- */
-int
-krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
-		       struct crypto_sync_skcipher *cipher,
-		       unsigned char *cksum)
-{
-	struct crypto_shash *hmac;
-	struct shash_desc *desc;
-	u8 Kseq[GSS_KRB5_MAX_KEYLEN];
-	u32 zeroconstant = 0;
-	int err;
-
-	dprintk("%s: entered\n", __func__);
-
-	hmac = crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
-	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld, allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
-		return PTR_ERR(hmac);
-	}
-
-	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
-		       GFP_NOFS);
-	if (!desc) {
-		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
-			__func__, kctx->gk5e->cksum_name);
-		crypto_free_shash(hmac);
-		return -ENOMEM;
-	}
-
-	desc->tfm = hmac;
-	desc->flags = 0;
-
-	/* Compute intermediate Kseq from session key */
-	err = crypto_shash_setkey(hmac, kctx->Ksess, kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	err = crypto_shash_digest(desc, (u8 *)&zeroconstant, 4, Kseq);
-	if (err)
-		goto out_err;
-
-	/* Compute final Kseq from the checksum and intermediate Kseq */
-	err = crypto_shash_setkey(hmac, Kseq, kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	err = crypto_shash_digest(desc, cksum, 8, Kseq);
-	if (err)
-		goto out_err;
-
-	err = crypto_sync_skcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	err = 0;
-
-out_err:
-	kzfree(desc);
-	crypto_free_shash(hmac);
-	dprintk("%s: returning %d\n", __func__, err);
-	return err;
-}
-
-/*
- * Compute Kcrypt given the initial session key and the plaintext seqnum.
- * Set the key of cipher kctx->enc.
- */
-int
-krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
-		       struct crypto_sync_skcipher *cipher,
-		       s32 seqnum)
-{
-	struct crypto_shash *hmac;
-	struct shash_desc *desc;
-	u8 Kcrypt[GSS_KRB5_MAX_KEYLEN];
-	u8 zeroconstant[4] = {0};
-	u8 seqnumarray[4];
-	int err, i;
-
-	dprintk("%s: entered, seqnum %u\n", __func__, seqnum);
-
-	hmac = crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
-	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld, allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
-		return PTR_ERR(hmac);
-	}
-
-	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
-		       GFP_NOFS);
-	if (!desc) {
-		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
-			__func__, kctx->gk5e->cksum_name);
-		crypto_free_shash(hmac);
-		return -ENOMEM;
-	}
-
-	desc->tfm = hmac;
-	desc->flags = 0;
-
-	/* Compute intermediate Kcrypt from session key */
-	for (i = 0; i < kctx->gk5e->keylength; i++)
-		Kcrypt[i] = kctx->Ksess[i] ^ 0xf0;
-
-	err = crypto_shash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	err = crypto_shash_digest(desc, zeroconstant, 4, Kcrypt);
-	if (err)
-		goto out_err;
-
-	/* Compute final Kcrypt from the seqnum and intermediate Kcrypt */
-	err = crypto_shash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	seqnumarray[0] = (unsigned char) ((seqnum >> 24) & 0xff);
-	seqnumarray[1] = (unsigned char) ((seqnum >> 16) & 0xff);
-	seqnumarray[2] = (unsigned char) ((seqnum >> 8) & 0xff);
-	seqnumarray[3] = (unsigned char) ((seqnum >> 0) & 0xff);
-
-	err = crypto_shash_digest(desc, seqnumarray, 4, Kcrypt);
-	if (err)
-		goto out_err;
-
-	err = crypto_sync_skcipher_setkey(cipher, Kcrypt,
-					  kctx->gk5e->keylength);
-	if (err)
-		goto out_err;
-
-	err = 0;
-
-out_err:
-	kzfree(desc);
-	crypto_free_shash(hmac);
-	dprintk("%s: returning %d\n", __func__, err);
-	return err;
-}
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 550fdf1..de327ae 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -242,59 +242,6 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	return ret;
 }
 
-#define smask(step) ((1<<step)-1)
-#define pstep(x, step) (((x)&smask(step))^(((x)>>step)&smask(step)))
-#define parity_char(x) pstep(pstep(pstep((x), 4), 2), 1)
-
-static void mit_des_fixup_key_parity(u8 key[8])
-{
-	int i;
-	for (i = 0; i < 8; i++) {
-		key[i] &= 0xfe;
-		key[i] |= 1^parity_char(key[i]);
-	}
-}
-
-/*
- * This is the des3 key derivation postprocess function
- */
-u32 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
-			   struct xdr_netobj *randombits,
-			   struct xdr_netobj *key)
-{
-	int i;
-	u32 ret = EINVAL;
-
-	if (key->len != 24) {
-		dprintk("%s: key->len is %d\n", __func__, key->len);
-		goto err_out;
-	}
-	if (randombits->len != 21) {
-		dprintk("%s: randombits->len is %d\n",
-			__func__, randombits->len);
-		goto err_out;
-	}
-
-	/* take the seven bytes, move them around into the top 7 bits of the
-	   8 key bytes, then compute the parity bits.  Do this three times. */
-
-	for (i = 0; i < 3; i++) {
-		memcpy(key->data + i*8, randombits->data + i*7, 7);
-		key->data[i*8+7] = (((key->data[i*8]&1)<<1) |
-				    ((key->data[i*8+1]&1)<<2) |
-				    ((key->data[i*8+2]&1)<<3) |
-				    ((key->data[i*8+3]&1)<<4) |
-				    ((key->data[i*8+4]&1)<<5) |
-				    ((key->data[i*8+5]&1)<<6) |
-				    ((key->data[i*8+6]&1)<<7));
-
-		mit_des_fixup_key_parity(key->data + i*8);
-	}
-	ret = 0;
-err_out:
-	return ret;
-}
-
 /*
  * This is the aes key derivation postprocess function
  */
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index eab71fc..0837543 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -54,69 +54,6 @@
 
 static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	/*
-	 * DES (All DES enctypes are mapped to the same gss functionality)
-	 */
-	{
-	  .etype = ENCTYPE_DES_CBC_RAW,
-	  .ctype = CKSUMTYPE_RSA_MD5,
-	  .name = "des-cbc-crc",
-	  .encrypt_name = "cbc(des)",
-	  .cksum_name = "md5",
-	  .encrypt = krb5_encrypt,
-	  .decrypt = krb5_decrypt,
-	  .mk_key = NULL,
-	  .signalg = SGN_ALG_DES_MAC_MD5,
-	  .sealalg = SEAL_ALG_DES,
-	  .keybytes = 7,
-	  .keylength = 8,
-	  .blocksize = 8,
-	  .conflen = 8,
-	  .cksumlength = 8,
-	  .keyed_cksum = 0,
-	},
-	/*
-	 * RC4-HMAC
-	 */
-	{
-	  .etype = ENCTYPE_ARCFOUR_HMAC,
-	  .ctype = CKSUMTYPE_HMAC_MD5_ARCFOUR,
-	  .name = "rc4-hmac",
-	  .encrypt_name = "ecb(arc4)",
-	  .cksum_name = "hmac(md5)",
-	  .encrypt = krb5_encrypt,
-	  .decrypt = krb5_decrypt,
-	  .mk_key = NULL,
-	  .signalg = SGN_ALG_HMAC_MD5,
-	  .sealalg = SEAL_ALG_MICROSOFT_RC4,
-	  .keybytes = 16,
-	  .keylength = 16,
-	  .blocksize = 1,
-	  .conflen = 8,
-	  .cksumlength = 8,
-	  .keyed_cksum = 1,
-	},
-	/*
-	 * 3DES
-	 */
-	{
-	  .etype = ENCTYPE_DES3_CBC_RAW,
-	  .ctype = CKSUMTYPE_HMAC_SHA1_DES3,
-	  .name = "des3-hmac-sha1",
-	  .encrypt_name = "cbc(des3_ede)",
-	  .cksum_name = "hmac(sha1)",
-	  .encrypt = krb5_encrypt,
-	  .decrypt = krb5_decrypt,
-	  .mk_key = gss_krb5_des3_make_key,
-	  .signalg = SGN_ALG_HMAC_SHA1_DES3_KD,
-	  .sealalg = SEAL_ALG_DES3KD,
-	  .keybytes = 21,
-	  .keylength = 24,
-	  .blocksize = 8,
-	  .conflen = 8,
-	  .cksumlength = 20,
-	  .keyed_cksum = 1,
-	},
-	/*
 	 * AES128
 	 */
 	{
@@ -227,15 +164,6 @@
 	if (IS_ERR(p))
 		goto out_err;
 
-	switch (alg) {
-	case ENCTYPE_DES_CBC_CRC:
-	case ENCTYPE_DES_CBC_MD4:
-	case ENCTYPE_DES_CBC_MD5:
-		/* Map all these key types to ENCTYPE_DES_CBC_RAW */
-		alg = ENCTYPE_DES_CBC_RAW;
-		break;
-	}
-
 	if (!supported_gss_krb5_enctype(alg)) {
 		printk(KERN_WARNING "gss_kerberos_mech: unsupported "
 			"encryption key algorithm %d\n", alg);
@@ -271,81 +199,6 @@
 	return p;
 }
 
-static int
-gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
-{
-	u32 seq_send;
-	int tmp;
-
-	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
-	if (IS_ERR(p))
-		goto out_err;
-
-	/* Old format supports only DES!  Any other enctype uses new format */
-	ctx->enctype = ENCTYPE_DES_CBC_RAW;
-
-	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
-	if (ctx->gk5e == NULL) {
-		p = ERR_PTR(-EINVAL);
-		goto out_err;
-	}
-
-	/* The downcall format was designed before we completely understood
-	 * the uses of the context fields; so it includes some stuff we
-	 * just give some minimal sanity-checking, and some we ignore
-	 * completely (like the next twenty bytes): */
-	if (unlikely(p + 20 > end || p + 20 < p)) {
-		p = ERR_PTR(-EFAULT);
-		goto out_err;
-	}
-	p += 20;
-	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
-	if (IS_ERR(p))
-		goto out_err;
-	if (tmp != SGN_ALG_DES_MAC_MD5) {
-		p = ERR_PTR(-ENOSYS);
-		goto out_err;
-	}
-	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
-	if (IS_ERR(p))
-		goto out_err;
-	if (tmp != SEAL_ALG_DES) {
-		p = ERR_PTR(-ENOSYS);
-		goto out_err;
-	}
-	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
-	if (IS_ERR(p))
-		goto out_err;
-	p = simple_get_bytes(p, end, &seq_send, sizeof(seq_send));
-	if (IS_ERR(p))
-		goto out_err;
-	atomic_set(&ctx->seq_send, seq_send);
-	p = simple_get_netobj(p, end, &ctx->mech_used);
-	if (IS_ERR(p))
-		goto out_err;
-	p = get_key(p, end, ctx, &ctx->enc);
-	if (IS_ERR(p))
-		goto out_err_free_mech;
-	p = get_key(p, end, ctx, &ctx->seq);
-	if (IS_ERR(p))
-		goto out_err_free_key1;
-	if (p != end) {
-		p = ERR_PTR(-EFAULT);
-		goto out_err_free_key2;
-	}
-
-	return 0;
-
-out_err_free_key2:
-	crypto_free_sync_skcipher(ctx->seq);
-out_err_free_key1:
-	crypto_free_sync_skcipher(ctx->enc);
-out_err_free_mech:
-	kfree(ctx->mech_used.data);
-out_err:
-	return PTR_ERR(p);
-}
-
 static struct crypto_sync_skcipher *
 context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 *key)
 {
@@ -377,124 +230,6 @@
 }
 
 static int
-context_derive_keys_des3(struct krb5_ctx *ctx, gfp_t gfp_mask)
-{
-	struct xdr_netobj c, keyin, keyout;
-	u8 cdata[GSS_KRB5_K5CLENGTH];
-	u32 err;
-
-	c.len = GSS_KRB5_K5CLENGTH;
-	c.data = cdata;
-
-	keyin.data = ctx->Ksess;
-	keyin.len = ctx->gk5e->keylength;
-	keyout.len = ctx->gk5e->keylength;
-
-	/* seq uses the raw key */
-	ctx->seq = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
-					   ctx->Ksess);
-	if (ctx->seq == NULL)
-		goto out_err;
-
-	ctx->enc = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
-					   ctx->Ksess);
-	if (ctx->enc == NULL)
-		goto out_free_seq;
-
-	/* derive cksum */
-	set_cdata(cdata, KG_USAGE_SIGN, KEY_USAGE_SEED_CHECKSUM);
-	keyout.data = ctx->cksum;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
-	if (err) {
-		dprintk("%s: Error %d deriving cksum key\n",
-			__func__, err);
-		goto out_free_enc;
-	}
-
-	return 0;
-
-out_free_enc:
-	crypto_free_sync_skcipher(ctx->enc);
-out_free_seq:
-	crypto_free_sync_skcipher(ctx->seq);
-out_err:
-	return -EINVAL;
-}
-
-/*
- * Note that RC4 depends on deriving keys using the sequence
- * number or the checksum of a token.  Therefore, the final keys
- * cannot be calculated until the token is being constructed!
- */
-static int
-context_derive_keys_rc4(struct krb5_ctx *ctx)
-{
-	struct crypto_shash *hmac;
-	char sigkeyconstant[] = "signaturekey";
-	int slen = strlen(sigkeyconstant) + 1;	/* include null terminator */
-	struct shash_desc *desc;
-	int err;
-
-	dprintk("RPC:       %s: entered\n", __func__);
-	/*
-	 * derive cksum (aka Ksign) key
-	 */
-	hmac = crypto_alloc_shash(ctx->gk5e->cksum_name, 0, 0);
-	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), ctx->gk5e->cksum_name);
-		err = PTR_ERR(hmac);
-		goto out_err;
-	}
-
-	err = crypto_shash_setkey(hmac, ctx->Ksess, ctx->gk5e->keylength);
-	if (err)
-		goto out_err_free_hmac;
-
-
-	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac), GFP_NOFS);
-	if (!desc) {
-		dprintk("%s: failed to allocate hash descriptor for '%s'\n",
-			__func__, ctx->gk5e->cksum_name);
-		err = -ENOMEM;
-		goto out_err_free_hmac;
-	}
-
-	desc->tfm = hmac;
-	desc->flags = 0;
-
-	err = crypto_shash_digest(desc, sigkeyconstant, slen, ctx->cksum);
-	kzfree(desc);
-	if (err)
-		goto out_err_free_hmac;
-	/*
-	 * allocate hash, and skciphers for data and seqnum encryption
-	 */
-	ctx->enc = crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, 0, 0);
-	if (IS_ERR(ctx->enc)) {
-		err = PTR_ERR(ctx->enc);
-		goto out_err_free_hmac;
-	}
-
-	ctx->seq = crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, 0, 0);
-	if (IS_ERR(ctx->seq)) {
-		crypto_free_sync_skcipher(ctx->enc);
-		err = PTR_ERR(ctx->seq);
-		goto out_err_free_hmac;
-	}
-
-	dprintk("RPC:       %s: returning success\n", __func__);
-
-	err = 0;
-
-out_err_free_hmac:
-	crypto_free_shash(hmac);
-out_err:
-	dprintk("RPC:       %s: returning %d\n", __func__, err);
-	return err;
-}
-
-static int
 context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 {
 	struct xdr_netobj c, keyin, keyout;
@@ -635,9 +370,6 @@
 	p = simple_get_bytes(p, end, &ctx->enctype, sizeof(ctx->enctype));
 	if (IS_ERR(p))
 		goto out_err;
-	/* Map ENCTYPE_DES3_CBC_SHA1 to ENCTYPE_DES3_CBC_RAW */
-	if (ctx->enctype == ENCTYPE_DES3_CBC_SHA1)
-		ctx->enctype = ENCTYPE_DES3_CBC_RAW;
 	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
 	if (ctx->gk5e == NULL) {
 		dprintk("gss_kerberos_mech: unsupported krb5 enctype %u\n",
@@ -665,10 +397,6 @@
 	ctx->mech_used.len = gss_kerberos_mech.gm_oid.len;
 
 	switch (ctx->enctype) {
-	case ENCTYPE_DES3_CBC_RAW:
-		return context_derive_keys_des3(ctx, gfp_mask);
-	case ENCTYPE_ARCFOUR_HMAC:
-		return context_derive_keys_rc4(ctx);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return context_derive_keys_new(ctx, gfp_mask);
@@ -694,11 +422,7 @@
 	if (ctx == NULL)
 		return -ENOMEM;
 
-	if (len == 85)
-		ret = gss_import_v1_context(p, end, ctx);
-	else
-		ret = gss_import_v2_context(p, end, ctx, gfp_mask);
-
+	ret = gss_import_v2_context(p, end, ctx, gfp_mask);
 	if (ret == 0) {
 		ctx_id->internal_ctx_id = ctx;
 		if (endtime)
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 48fe4a5..feb0f2a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -70,32 +70,6 @@
 #endif
 
 static void *
-setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
-{
-	u16 *ptr;
-	void *krb5_hdr;
-	int body_size = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
-
-	token->len = g_token_size(&ctx->mech_used, body_size);
-
-	ptr = (u16 *)token->data;
-	g_make_token_header(&ctx->mech_used, body_size, (unsigned char **)&ptr);
-
-	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
-	krb5_hdr = ptr;
-	*ptr++ = KG_TOK_MIC_MSG;
-	/*
-	 * signalg is stored as if it were converted from LE to host endian, even
-	 * though it's an opaque pair of bytes according to the RFC.
-	 */
-	*ptr++ = (__force u16)cpu_to_le16(ctx->gk5e->signalg);
-	*ptr++ = SEAL_ALG_NONE;
-	*ptr = 0xffff;
-
-	return krb5_hdr;
-}
-
-static void *
 setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
 {
 	u16 *ptr;
@@ -124,45 +98,6 @@
 }
 
 static u32
-gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
-		struct xdr_netobj *token)
-{
-	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
-	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
-					    .data = cksumdata};
-	void			*ptr;
-	s32			now;
-	u32			seq_send;
-	u8			*cksumkey;
-
-	dprintk("RPC:       %s\n", __func__);
-	BUG_ON(ctx == NULL);
-
-	now = get_seconds();
-
-	ptr = setup_token(ctx, token);
-
-	if (ctx->gk5e->keyed_cksum)
-		cksumkey = ctx->cksum;
-	else
-		cksumkey = NULL;
-
-	if (make_checksum(ctx, ptr, 8, text, 0, cksumkey,
-			  KG_USAGE_SIGN, &md5cksum))
-		return GSS_S_FAILURE;
-
-	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
-
-	seq_send = atomic_fetch_inc(&ctx->seq_send);
-
-	if (krb5_make_seq_num(ctx, ctx->seq, ctx->initiate ? 0 : 0xff,
-			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8))
-		return GSS_S_FAILURE;
-
-	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
-}
-
-static u32
 gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
 {
@@ -210,14 +145,10 @@
 	struct krb5_ctx		*ctx = gss_ctx->internal_ctx_id;
 
 	switch (ctx->enctype) {
-	default:
-		BUG();
-	case ENCTYPE_DES_CBC_RAW:
-	case ENCTYPE_DES3_CBC_RAW:
-	case ENCTYPE_ARCFOUR_HMAC:
-		return gss_get_mic_v1(ctx, text, token);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return gss_get_mic_v2(ctx, text, token);
+	default:
+		return GSS_S_FAILURE;
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
deleted file mode 100644
index fb66562..0000000
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ /dev/null
@@ -1,164 +0,0 @@
-/*
- *  linux/net/sunrpc/gss_krb5_seqnum.c
- *
- *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/util_seqnum.c
- *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson   <andros@umich.edu>
- */
-
-/*
- * Copyright 1993 by OpenVision Technologies, Inc.
- *
- * Permission to use, copy, modify, distribute, and sell this software
- * and its documentation for any purpose is hereby granted without fee,
- * provided that the above copyright notice appears in all copies and
- * that both that copyright notice and this permission notice appear in
- * supporting documentation, and that the name of OpenVision not be used
- * in advertising or publicity pertaining to distribution of the software
- * without specific, written prior permission. OpenVision makes no
- * representations about the suitability of this software for any
- * purpose.  It is provided "as is" without express or implied warranty.
- *
- * OPENVISION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
- * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
- * EVENT SHALL OPENVISION BE LIABLE FOR ANY SPECIAL, INDIRECT OR
- * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
- * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
- * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
- * PERFORMANCE OF THIS SOFTWARE.
- */
-
-#include <crypto/skcipher.h>
-#include <linux/types.h>
-#include <linux/sunrpc/gss_krb5.h>
-
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY        RPCDBG_AUTH
-#endif
-
-static s32
-krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
-		      unsigned char *cksum, unsigned char *buf)
-{
-	struct crypto_sync_skcipher *cipher;
-	unsigned char plain[8];
-	s32 code;
-
-	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, 0, 0);
-	if (IS_ERR(cipher))
-		return PTR_ERR(cipher);
-
-	plain[0] = (unsigned char) ((seqnum >> 24) & 0xff);
-	plain[1] = (unsigned char) ((seqnum >> 16) & 0xff);
-	plain[2] = (unsigned char) ((seqnum >> 8) & 0xff);
-	plain[3] = (unsigned char) ((seqnum >> 0) & 0xff);
-	plain[4] = direction;
-	plain[5] = direction;
-	plain[6] = direction;
-	plain[7] = direction;
-
-	code = krb5_rc4_setup_seq_key(kctx, cipher, cksum);
-	if (code)
-		goto out;
-
-	code = krb5_encrypt(cipher, cksum, plain, buf, 8);
-out:
-	crypto_free_sync_skcipher(cipher);
-	return code;
-}
-s32
-krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_sync_skcipher *key,
-		int direction,
-		u32 seqnum,
-		unsigned char *cksum, unsigned char *buf)
-{
-	unsigned char plain[8];
-
-	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC)
-		return krb5_make_rc4_seq_num(kctx, direction, seqnum,
-					     cksum, buf);
-
-	plain[0] = (unsigned char) (seqnum & 0xff);
-	plain[1] = (unsigned char) ((seqnum >> 8) & 0xff);
-	plain[2] = (unsigned char) ((seqnum >> 16) & 0xff);
-	plain[3] = (unsigned char) ((seqnum >> 24) & 0xff);
-
-	plain[4] = direction;
-	plain[5] = direction;
-	plain[6] = direction;
-	plain[7] = direction;
-
-	return krb5_encrypt(key, cksum, plain, buf, 8);
-}
-
-static s32
-krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
-		     unsigned char *buf, int *direction, s32 *seqnum)
-{
-	struct crypto_sync_skcipher *cipher;
-	unsigned char plain[8];
-	s32 code;
-
-	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, 0, 0);
-	if (IS_ERR(cipher))
-		return PTR_ERR(cipher);
-
-	code = krb5_rc4_setup_seq_key(kctx, cipher, cksum);
-	if (code)
-		goto out;
-
-	code = krb5_decrypt(cipher, cksum, buf, plain, 8);
-	if (code)
-		goto out;
-
-	if ((plain[4] != plain[5]) || (plain[4] != plain[6])
-				   || (plain[4] != plain[7])) {
-		code = (s32)KG_BAD_SEQ;
-		goto out;
-	}
-
-	*direction = plain[4];
-
-	*seqnum = ((plain[0] << 24) | (plain[1] << 16) |
-					(plain[2] << 8) | (plain[3]));
-out:
-	crypto_free_sync_skcipher(cipher);
-	return code;
-}
-
-s32
-krb5_get_seq_num(struct krb5_ctx *kctx,
-	       unsigned char *cksum,
-	       unsigned char *buf,
-	       int *direction, u32 *seqnum)
-{
-	s32 code;
-	unsigned char plain[8];
-	struct crypto_sync_skcipher *key = kctx->seq;
-
-	dprintk("RPC:       krb5_get_seq_num:\n");
-
-	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC)
-		return krb5_get_rc4_seq_num(kctx, cksum, buf,
-					    direction, seqnum);
-
-	if ((code = krb5_decrypt(key, cksum, buf, plain, 8)))
-		return code;
-
-	if ((plain[4] != plain[5]) || (plain[4] != plain[6]) ||
-	    (plain[4] != plain[7]))
-		return (s32)KG_BAD_SEQ;
-
-	*direction = plain[4];
-
-	*seqnum = ((plain[0]) |
-		   (plain[1] << 8) | (plain[2] << 16) | (plain[3] << 24));
-
-	return 0;
-}
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index ef2b25b..f0f646a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -71,78 +71,6 @@
  * supposedly taken over. */
 
 static u32
-gss_verify_mic_v1(struct krb5_ctx *ctx,
-		struct xdr_buf *message_buffer, struct xdr_netobj *read_token)
-{
-	int			signalg;
-	int			sealalg;
-	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
-	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
-					    .data = cksumdata};
-	s32			now;
-	int			direction;
-	u32			seqnum;
-	unsigned char		*ptr = (unsigned char *)read_token->data;
-	int			bodysize;
-	u8			*cksumkey;
-
-	dprintk("RPC:       krb5_read_token\n");
-
-	if (g_verify_token_header(&ctx->mech_used, &bodysize, &ptr,
-					read_token->len))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	if ((ptr[0] != ((KG_TOK_MIC_MSG >> 8) & 0xff)) ||
-	    (ptr[1] !=  (KG_TOK_MIC_MSG & 0xff)))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	/* XXX sanity-check bodysize?? */
-
-	signalg = ptr[2] + (ptr[3] << 8);
-	if (signalg != ctx->gk5e->signalg)
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	sealalg = ptr[4] + (ptr[5] << 8);
-	if (sealalg != SEAL_ALG_NONE)
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	if (ctx->gk5e->keyed_cksum)
-		cksumkey = ctx->cksum;
-	else
-		cksumkey = NULL;
-
-	if (make_checksum(ctx, ptr, 8, message_buffer, 0,
-			  cksumkey, KG_USAGE_SIGN, &md5cksum))
-		return GSS_S_FAILURE;
-
-	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
-					ctx->gk5e->cksumlength))
-		return GSS_S_BAD_SIG;
-
-	/* it got through unscathed.  Make sure the context is unexpired */
-
-	now = get_seconds();
-
-	if (now > ctx->endtime)
-		return GSS_S_CONTEXT_EXPIRED;
-
-	/* do sequencing checks */
-
-	if (krb5_get_seq_num(ctx, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
-			     &direction, &seqnum))
-		return GSS_S_FAILURE;
-
-	if ((ctx->initiate && direction != 0xff) ||
-	    (!ctx->initiate && direction != 0))
-		return GSS_S_BAD_SIG;
-
-	return GSS_S_COMPLETE;
-}
-
-static u32
 gss_verify_mic_v2(struct krb5_ctx *ctx,
 		struct xdr_buf *message_buffer, struct xdr_netobj *read_token)
 {
@@ -214,14 +142,10 @@
 	struct krb5_ctx *ctx = gss_ctx->internal_ctx_id;
 
 	switch (ctx->enctype) {
-	default:
-		BUG();
-	case ENCTYPE_DES_CBC_RAW:
-	case ENCTYPE_DES3_CBC_RAW:
-	case ENCTYPE_ARCFOUR_HMAC:
-		return gss_verify_mic_v1(ctx, message_buffer, read_token);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return gss_verify_mic_v2(ctx, message_buffer, read_token);
+	default:
+		return GSS_S_FAILURE;
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 5cdde6c..98c99d3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -146,244 +146,6 @@
 	}
 }
 
-/* Assumptions: the head and tail of inbuf are ours to play with.
- * The pages, however, may be real pages in the page cache and we replace
- * them with scratch pages from **pages before writing to them. */
-/* XXX: obviously the above should be documentation of wrap interface,
- * and shouldn't be in this kerberos-specific file. */
-
-/* XXX factor out common code with seal/unseal. */
-
-static u32
-gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
-		struct xdr_buf *buf, struct page **pages)
-{
-	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
-	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
-					    .data = cksumdata};
-	int			blocksize = 0, plainlen;
-	unsigned char		*ptr, *msg_start;
-	s32			now;
-	int			headlen;
-	struct page		**tmp_pages;
-	u32			seq_send;
-	u8			*cksumkey;
-	u32			conflen = kctx->gk5e->conflen;
-
-	dprintk("RPC:       %s\n", __func__);
-
-	now = get_seconds();
-
-	blocksize = crypto_sync_skcipher_blocksize(kctx->enc);
-	gss_krb5_add_padding(buf, offset, blocksize);
-	BUG_ON((buf->len - offset) % blocksize);
-	plainlen = conflen + buf->len - offset;
-
-	headlen = g_token_size(&kctx->mech_used,
-		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + plainlen) -
-		(buf->len - offset);
-
-	ptr = buf->head[0].iov_base + offset;
-	/* shift data to make room for header. */
-	xdr_extend_head(buf, offset, headlen);
-
-	/* XXX Would be cleverer to encrypt while copying. */
-	BUG_ON((buf->len - offset - headlen) % blocksize);
-
-	g_make_token_header(&kctx->mech_used,
-				GSS_KRB5_TOK_HDR_LEN +
-				kctx->gk5e->cksumlength + plainlen, &ptr);
-
-
-	/* ptr now at header described in rfc 1964, section 1.2.1: */
-	ptr[0] = (unsigned char) ((KG_TOK_WRAP_MSG >> 8) & 0xff);
-	ptr[1] = (unsigned char) (KG_TOK_WRAP_MSG & 0xff);
-
-	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
-
-	/*
-	 * signalg and sealalg are stored as if they were converted from LE
-	 * to host endian, even though they're opaque pairs of bytes according
-	 * to the RFC.
-	 */
-	*(__le16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
-	*(__le16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
-	ptr[6] = 0xff;
-	ptr[7] = 0xff;
-
-	gss_krb5_make_confounder(msg_start, conflen);
-
-	if (kctx->gk5e->keyed_cksum)
-		cksumkey = kctx->cksum;
-	else
-		cksumkey = NULL;
-
-	/* XXXJBF: UGH!: */
-	tmp_pages = buf->pages;
-	buf->pages = pages;
-	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - conflen,
-					cksumkey, KG_USAGE_SEAL, &md5cksum))
-		return GSS_S_FAILURE;
-	buf->pages = tmp_pages;
-
-	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
-
-	seq_send = atomic_fetch_inc(&kctx->seq_send);
-
-	/* XXX would probably be more efficient to compute checksum
-	 * and encrypt at the same time: */
-	if ((krb5_make_seq_num(kctx, kctx->seq, kctx->initiate ? 0 : 0xff,
-			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
-		return GSS_S_FAILURE;
-
-	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_sync_skcipher *cipher;
-		int err;
-		cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
-						    0, 0);
-		if (IS_ERR(cipher))
-			return GSS_S_FAILURE;
-
-		krb5_rc4_setup_enc_key(kctx, cipher, seq_send);
-
-		err = gss_encrypt_xdr_buf(cipher, buf,
-					  offset + headlen - conflen, pages);
-		crypto_free_sync_skcipher(cipher);
-		if (err)
-			return GSS_S_FAILURE;
-	} else {
-		if (gss_encrypt_xdr_buf(kctx->enc, buf,
-					offset + headlen - conflen, pages))
-			return GSS_S_FAILURE;
-	}
-
-	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
-}
-
-static u32
-gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
-{
-	int			signalg;
-	int			sealalg;
-	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
-	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
-					    .data = cksumdata};
-	s32			now;
-	int			direction;
-	s32			seqnum;
-	unsigned char		*ptr;
-	int			bodysize;
-	void			*data_start, *orig_start;
-	int			data_len;
-	int			blocksize;
-	u32			conflen = kctx->gk5e->conflen;
-	int			crypt_offset;
-	u8			*cksumkey;
-
-	dprintk("RPC:       gss_unwrap_kerberos\n");
-
-	ptr = (u8 *)buf->head[0].iov_base + offset;
-	if (g_verify_token_header(&kctx->mech_used, &bodysize, &ptr,
-					buf->len - offset))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	if ((ptr[0] != ((KG_TOK_WRAP_MSG >> 8) & 0xff)) ||
-	    (ptr[1] !=  (KG_TOK_WRAP_MSG & 0xff)))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	/* XXX sanity-check bodysize?? */
-
-	/* get the sign and seal algorithms */
-
-	signalg = ptr[2] + (ptr[3] << 8);
-	if (signalg != kctx->gk5e->signalg)
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	sealalg = ptr[4] + (ptr[5] << 8);
-	if (sealalg != kctx->gk5e->sealalg)
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	/*
-	 * Data starts after token header and checksum.  ptr points
-	 * to the beginning of the token header
-	 */
-	crypt_offset = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) -
-					(unsigned char *)buf->head[0].iov_base;
-
-	/*
-	 * Need plaintext seqnum to derive encryption key for arcfour-hmac
-	 */
-	if (krb5_get_seq_num(kctx, ptr + GSS_KRB5_TOK_HDR_LEN,
-			     ptr + 8, &direction, &seqnum))
-		return GSS_S_BAD_SIG;
-
-	if ((kctx->initiate && direction != 0xff) ||
-	    (!kctx->initiate && direction != 0))
-		return GSS_S_BAD_SIG;
-
-	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_sync_skcipher *cipher;
-		int err;
-
-		cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
-						    0, 0);
-		if (IS_ERR(cipher))
-			return GSS_S_FAILURE;
-
-		krb5_rc4_setup_enc_key(kctx, cipher, seqnum);
-
-		err = gss_decrypt_xdr_buf(cipher, buf, crypt_offset);
-		crypto_free_sync_skcipher(cipher);
-		if (err)
-			return GSS_S_DEFECTIVE_TOKEN;
-	} else {
-		if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
-			return GSS_S_DEFECTIVE_TOKEN;
-	}
-
-	if (kctx->gk5e->keyed_cksum)
-		cksumkey = kctx->cksum;
-	else
-		cksumkey = NULL;
-
-	if (make_checksum(kctx, ptr, 8, buf, crypt_offset,
-					cksumkey, KG_USAGE_SEAL, &md5cksum))
-		return GSS_S_FAILURE;
-
-	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
-						kctx->gk5e->cksumlength))
-		return GSS_S_BAD_SIG;
-
-	/* it got through unscathed.  Make sure the context is unexpired */
-
-	now = get_seconds();
-
-	if (now > kctx->endtime)
-		return GSS_S_CONTEXT_EXPIRED;
-
-	/* do sequencing checks */
-
-	/* Copy the data back to the right position.  XXX: Would probably be
-	 * better to copy and encrypt at the same time. */
-
-	blocksize = crypto_sync_skcipher_blocksize(kctx->enc);
-	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
-					conflen;
-	orig_start = buf->head[0].iov_base + offset;
-	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
-	memmove(orig_start, data_start, data_len);
-	buf->head[0].iov_len -= (data_start - orig_start);
-	buf->len -= (data_start - orig_start);
-
-	if (gss_krb5_remove_padding(buf, blocksize))
-		return GSS_S_DEFECTIVE_TOKEN;
-
-	return GSS_S_COMPLETE;
-}
-
 /*
  * We can shift data by up to LOCAL_BUF_LEN bytes in a pass.  If we need
  * to do more than that, we shift repeatedly.  Kevin Coffman reports
@@ -588,15 +350,11 @@ static void rotate_left(u32 base, struct xdr_buf *buf, unsigned int shift)
 	struct krb5_ctx	*kctx = gctx->internal_ctx_id;
 
 	switch (kctx->enctype) {
-	default:
-		BUG();
-	case ENCTYPE_DES_CBC_RAW:
-	case ENCTYPE_DES3_CBC_RAW:
-	case ENCTYPE_ARCFOUR_HMAC:
-		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return gss_wrap_kerberos_v2(kctx, offset, buf, pages);
+	default:
+		return GSS_S_FAILURE;
 	}
 }
 
@@ -606,14 +364,10 @@ static void rotate_left(u32 base, struct xdr_buf *buf, unsigned int shift)
 	struct krb5_ctx	*kctx = gctx->internal_ctx_id;
 
 	switch (kctx->enctype) {
-	default:
-		BUG();
-	case ENCTYPE_DES_CBC_RAW:
-	case ENCTYPE_DES3_CBC_RAW:
-	case ENCTYPE_ARCFOUR_HMAC:
-		return gss_unwrap_kerberos_v1(kctx, offset, buf);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return gss_unwrap_kerberos_v2(kctx, offset, buf);
+	default:
+		return GSS_S_FAILURE;
 	}
 }

