Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002327;
	b=p6B+vnSctEzsp/ji3wRrHSbrEhA3ePii0rXZjjvvfjhw7VXmEUI017EDb9Bnss5zmjRo
	 jty3eNg1qEI4eDk3hNR7prleoW8tV6tw7F73fYSOVEzzaXS0eexEnz6t6hsI20NXatdi6
	 QZM7eN6Q2AdUwZKdWqzTVS6D6tEI7dL39COsXh4PJGkPjDNuxi697ChiPDooCbZ70x+nv
	 kTYQUlZWbdk9mWHdjxZiFsa1hDmJDFkFU0SW7thlbyoeTV/FABNSDFVKTtETqV2MoqQNg
	 c2hqmGd2Ep0t9LTUChxPsw1zJ+TEe8Yv7tHJkYS3VaJfED79DwzA0uH1//iiYMvh2RQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002327;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=IhzIvmeeJn2NAjDpLTMQTcLVGDJ6DLJttS56TtytnVQ=;
	b=F+61CS3ZQUoSY5mbe/XJNmN77Pn/Yn+ma60N0blD87fC112ZGDCuPa+LiuBmzjkfQ4IO
	 BwxUNyN0iyDoFSlc2AknkPsfb3Xx64Izo7UD4eMwYgjsf4aEAvzRn5Xj1phaMSHC8Yq2i
	 aweqlNz/IBiSNWlvMe/rN2sv89JrN8bsuTeD4NxSjhJQxaOhzVR8t/Qwp8o4UD06kfa46
	 2O1bTybesqY1A0QRnbVEFNp9IZlPShi2gHDoD1X8zFoV2Zjz47tj2XWAbSLJ1EbVGdGZw
	 h2LsYIu9n1Nxt1WvXIv1wMl3UwS7MAucQ664TqWUbosqVVlFICrDhN1qM6wzRXbLMxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8375F606A320;
	Wed, 18 Nov 2026 11:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8375F606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id DAECB2DF337; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
From: Alexey Shabalin <shaba@altlinux.org>
To: devel-kernel@altlinux.org
Cc: David Howells <dhowells@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Chuck Lever <chuck.lever@oracle.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	linux-afs@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH 6.12/sisyphus 04/29] crypto/krb5: Add an API to alloc and prepare a crypto object
Date: Wed, 18 Nov 2026 14:44:53 +0300
Message-ID: <20261118114518.3605222-5-shaba@altlinux.org>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20261118114518.3605222-1-shaba@altlinux.org>
References: <20261118114518.3605222-1-shaba@altlinux.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: David Howells <dhowells@redhat.com>

Add an API by which users of the krb5 crypto library can get an allocated
and keyed crypto object.

For encryption-mode operation, an AEAD object is returned; for
checksum-mode operation, a synchronous hash object is returned.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Herbert Xu <herbert@gondor.apana.org.au>
cc: "David S. Miller" <davem@davemloft.net>
cc: Chuck Lever <chuck.lever@oracle.com>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Eric Dumazet <edumazet@google.com>
cc: Jakub Kicinski <kuba@kernel.org>
cc: Paolo Abeni <pabeni@redhat.com>
cc: Simon Horman <horms@kernel.org>
cc: linux-afs@lists.infradead.org
cc: linux-nfs@vger.kernel.org
cc: linux-crypto@vger.kernel.org
cc: netdev@vger.kernel.org
(cherry picked from commit a9c27d2d87a388433db100889262841afe771f7a)
---
 crypto/krb5/internal.h |  10 +++
 crypto/krb5/krb5_api.c | 144 +++++++++++++++++++++++++++++++++++++++++
 include/crypto/krb5.h  |   7 ++
 3 files changed, 161 insertions(+)

diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index 3ede858be4f7..b542d24e5fa5 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -110,3 +110,13 @@ struct krb5_crypto_profile {
 #define krb5_digest_size(TFM) \
 	crypto_roundup(crypto_shash_digestsize(TFM))
 #define round16(x) (((x) + 15) & ~15)
+
+/*
+ * krb5_api.c
+ */
+struct crypto_aead *krb5_prepare_encryption(const struct krb5_enctype *krb5,
+					    const struct krb5_buffer *keys,
+					    gfp_t gfp);
+struct crypto_shash *krb5_prepare_checksum(const struct krb5_enctype *krb5,
+					   const struct krb5_buffer *Kc,
+					   gfp_t gfp);
diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index f6d1bc813daa..f7f2528b3895 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -148,3 +148,147 @@ void crypto_krb5_where_is_the_data(const struct krb5_enctype *krb5,
 	}
 }
 EXPORT_SYMBOL(crypto_krb5_where_is_the_data);
+
+/*
+ * Prepare the encryption with derived key data.
+ */
+struct crypto_aead *krb5_prepare_encryption(const struct krb5_enctype *krb5,
+					    const struct krb5_buffer *keys,
+					    gfp_t gfp)
+{
+	struct crypto_aead *ci = NULL;
+	int ret = -ENOMEM;
+
+	ci = crypto_alloc_aead(krb5->encrypt_name, 0, 0);
+	if (IS_ERR(ci)) {
+		ret = PTR_ERR(ci);
+		if (ret == -ENOENT)
+			ret = -ENOPKG;
+		goto err;
+	}
+
+	ret = crypto_aead_setkey(ci, keys->data, keys->len);
+	if (ret < 0) {
+		pr_err("Couldn't set AEAD key %s: %d\n", krb5->encrypt_name, ret);
+		goto err_ci;
+	}
+
+	ret = crypto_aead_setauthsize(ci, krb5->cksum_len);
+	if (ret < 0) {
+		pr_err("Couldn't set AEAD authsize %s: %d\n", krb5->encrypt_name, ret);
+		goto err_ci;
+	}
+
+	return ci;
+err_ci:
+	crypto_free_aead(ci);
+err:
+	return ERR_PTR(ret);
+}
+
+/**
+ * crypto_krb5_prepare_encryption - Prepare AEAD crypto object for encryption-mode
+ * @krb5: The encoding to use.
+ * @TK: The transport key to use.
+ * @usage: The usage constant for key derivation.
+ * @gfp: Allocation flags.
+ *
+ * Allocate a crypto object that does all the necessary crypto, key it and set
+ * its parameters and return the crypto handle to it.  This can then be used to
+ * dispatch encrypt and decrypt operations.
+ */
+struct crypto_aead *crypto_krb5_prepare_encryption(const struct krb5_enctype *krb5,
+						   const struct krb5_buffer *TK,
+						   u32 usage, gfp_t gfp)
+{
+	struct crypto_aead *ci = NULL;
+	struct krb5_buffer keys = {};
+	int ret;
+
+	ret = krb5->profile->derive_encrypt_keys(krb5, TK, usage, &keys, gfp);
+	if (ret < 0)
+		goto err;
+
+	ci = krb5_prepare_encryption(krb5, &keys, gfp);
+	if (IS_ERR(ci)) {
+		ret = PTR_ERR(ci);
+		goto err;
+	}
+
+	kfree(keys.data);
+	return ci;
+err:
+	kfree(keys.data);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(crypto_krb5_prepare_encryption);
+
+/*
+ * Prepare the checksum with derived key data.
+ */
+struct crypto_shash *krb5_prepare_checksum(const struct krb5_enctype *krb5,
+					   const struct krb5_buffer *Kc,
+					   gfp_t gfp)
+{
+	struct crypto_shash *ci = NULL;
+	int ret = -ENOMEM;
+
+	ci = crypto_alloc_shash(krb5->cksum_name, 0, 0);
+	if (IS_ERR(ci)) {
+		ret = PTR_ERR(ci);
+		if (ret == -ENOENT)
+			ret = -ENOPKG;
+		goto err;
+	}
+
+	ret = crypto_shash_setkey(ci, Kc->data, Kc->len);
+	if (ret < 0) {
+		pr_err("Couldn't set shash key %s: %d\n", krb5->cksum_name, ret);
+		goto err_ci;
+	}
+
+	return ci;
+err_ci:
+	crypto_free_shash(ci);
+err:
+	return ERR_PTR(ret);
+}
+
+/**
+ * crypto_krb5_prepare_checksum - Prepare AEAD crypto object for checksum-mode
+ * @krb5: The encoding to use.
+ * @TK: The transport key to use.
+ * @usage: The usage constant for key derivation.
+ * @gfp: Allocation flags.
+ *
+ * Allocate a crypto object that does all the necessary crypto, key it and set
+ * its parameters and return the crypto handle to it.  This can then be used to
+ * dispatch get_mic and verify_mic operations.
+ */
+struct crypto_shash *crypto_krb5_prepare_checksum(const struct krb5_enctype *krb5,
+						  const struct krb5_buffer *TK,
+						  u32 usage, gfp_t gfp)
+{
+	struct crypto_shash *ci = NULL;
+	struct krb5_buffer keys = {};
+	int ret;
+
+	ret = krb5->profile->derive_checksum_key(krb5, TK, usage, &keys, gfp);
+	if (ret < 0) {
+		pr_err("get_Kc failed %d\n", ret);
+		goto err;
+	}
+
+	ci = krb5_prepare_checksum(krb5, &keys, gfp);
+	if (IS_ERR(ci)) {
+		ret = PTR_ERR(ci);
+		goto err;
+	}
+
+	kfree(keys.data);
+	return ci;
+err:
+	kfree(keys.data);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(crypto_krb5_prepare_checksum);
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index b414141b8b42..94af2c558fa1 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -10,6 +10,7 @@
 
 #include <linux/crypto.h>
 #include <crypto/aead.h>
+#include <crypto/hash.h>
 
 struct crypto_shash;
 struct scatterlist;
@@ -110,5 +111,11 @@ size_t crypto_krb5_how_much_data(const struct krb5_enctype *krb5,
 void crypto_krb5_where_is_the_data(const struct krb5_enctype *krb5,
 				   enum krb5_crypto_mode mode,
 				   size_t *_offset, size_t *_len);
+struct crypto_aead *crypto_krb5_prepare_encryption(const struct krb5_enctype *krb5,
+						   const struct krb5_buffer *TK,
+						   u32 usage, gfp_t gfp);
+struct crypto_shash *crypto_krb5_prepare_checksum(const struct krb5_enctype *krb5,
+						  const struct krb5_buffer *TK,
+						  u32 usage, gfp_t gfp);
 
 #endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

