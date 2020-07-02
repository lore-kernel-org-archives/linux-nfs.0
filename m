Return-Path: <SRS0=k2H/=AN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D02CC433E0
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Jul 2020 10:22:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2CEFE20772
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Jul 2020 10:22:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1593685332;
	bh=9PRSQMjLI8/4sHoDfY859AuP95S3O2JmFarTQDw/GUw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=flx1CorhVHsCa6s+Daw1DuqWGCKZ4oZ11j7/zxvzp7LT18yvtlS0zeZrrWjC1GWIe
	 1T9NcyIqK1VUpkc86nMTzFzagGt8RtbXi2xV0mhLtICjMqbe/8znMnh800ICm3BSPc
	 pMdU+MY+xS3algmf0KQznI/Ga0Ho4lTFiEIXq0WU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728465AbgGBKWL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 2 Jul 2020 06:22:11 -0400
Received: from mail.kernel.org ([198.145.29.99]:59910 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727991AbgGBKUh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Jul 2020 06:20:37 -0400
Received: from e123331-lin.nice.arm.com (lfbn-nic-1-188-42.w2-15.abo.wanadoo.fr [2.15.37.42])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9447520780;
        Thu,  2 Jul 2020 10:20:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1593685237;
        bh=9PRSQMjLI8/4sHoDfY859AuP95S3O2JmFarTQDw/GUw=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=zywTpzGD+H8Buhi2wxFCHNucxSUj9+QWHWpuUCXBZk2R+OOa1sXCqaW0YhCNW5ogr
         wT6crb423AqZvmeqPSAgk1VPFCxNHmgepLW6YUjhiUnyVPyRW4G6zXaM/niaQmhTN7
         638SY/2ekUVYsQUVZAWVx/m+xWBBqoPrObtCFX50=
From:   Ard Biesheuvel <ardb@kernel.org>
To:     linux-kernel@vger.kernel.org
Cc:     Ard Biesheuvel <ardb@kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Eric Biggers <ebiggers@google.com>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-nfs@vger.kernel.org
Subject: [RFC PATCH 5/7] crypto: n2 - remove ecb(arc4) support
Date:   Thu,  2 Jul 2020 12:19:45 +0200
Message-Id: <20200702101947.682-6-ardb@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20200702101947.682-1-ardb@kernel.org>
References: <20200702101947.682-1-ardb@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
---
 drivers/crypto/n2_core.c | 46 --------------------
 1 file changed, 46 deletions(-)

diff --git a/drivers/crypto/n2_core.c b/drivers/crypto/n2_core.c
index 6a828bbecea4..c347e58cd9a1 100644
--- a/drivers/crypto/n2_core.c
+++ b/drivers/crypto/n2_core.c
@@ -662,7 +662,6 @@ struct n2_skcipher_context {
 		u8		aes[AES_MAX_KEY_SIZE];
 		u8		des[DES_KEY_SIZE];
 		u8		des3[3 * DES_KEY_SIZE];
-		u8		arc4[258]; /* S-box, X, Y */
 	} key;
 };
 
@@ -789,36 +788,6 @@ static int n2_3des_setkey(struct crypto_skcipher *skcipher, const u8 *key,
 	return 0;
 }
 
-static int n2_arc4_setkey(struct crypto_skcipher *skcipher, const u8 *key,
-			  unsigned int keylen)
-{
-	struct crypto_tfm *tfm = crypto_skcipher_tfm(skcipher);
-	struct n2_skcipher_context *ctx = crypto_tfm_ctx(tfm);
-	struct n2_skcipher_alg *n2alg = n2_skcipher_alg(skcipher);
-	u8 *s = ctx->key.arc4;
-	u8 *x = s + 256;
-	u8 *y = x + 1;
-	int i, j, k;
-
-	ctx->enc_type = n2alg->enc_type;
-
-	j = k = 0;
-	*x = 0;
-	*y = 0;
-	for (i = 0; i < 256; i++)
-		s[i] = i;
-	for (i = 0; i < 256; i++) {
-		u8 a = s[i];
-		j = (j + key[k] + a) & 0xff;
-		s[i] = s[j];
-		s[j] = a;
-		if (++k >= keylen)
-			k = 0;
-	}
-
-	return 0;
-}
-
 static inline int skcipher_descriptor_len(int nbytes, unsigned int block_size)
 {
 	int this_len = nbytes;
@@ -1122,21 +1091,6 @@ struct n2_skcipher_tmpl {
 };
 
 static const struct n2_skcipher_tmpl skcipher_tmpls[] = {
-	/* ARC4: only ECB is supported (chaining bits ignored) */
-	{	.name		= "ecb(arc4)",
-		.drv_name	= "ecb-arc4",
-		.block_size	= 1,
-		.enc_type	= (ENC_TYPE_ALG_RC4_STREAM |
-				   ENC_TYPE_CHAINING_ECB),
-		.skcipher	= {
-			.min_keysize	= 1,
-			.max_keysize	= 256,
-			.setkey		= n2_arc4_setkey,
-			.encrypt	= n2_encrypt_ecb,
-			.decrypt	= n2_decrypt_ecb,
-		},
-	},
-
 	/* DES: ECB CBC and CFB are supported */
 	{	.name		= "ecb(des)",
 		.drv_name	= "ecb-des",
-- 
2.17.1

