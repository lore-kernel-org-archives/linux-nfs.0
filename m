Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=3r58uNgkmemSXbHBs1wulyTlSradKNbNXE2WYZPbk05uwOs0gaZy5iBBMYLKhQ8OgdQw
	 e5pCIaUgUGLRiwe1ptrosVVL06N92NhYvr3Hx/h1qCXqM5nW9l3V+XMjKueSDATedG3sc
	 h2NN593di+DO03huNaZF3eFkSy3TahPOkgmXHCIUEdK85rFXqN1yziGhSjaHIyz8hu5gQ
	 K9eseDuTitJsy0uFbw7Ie2YIa0fDwrVbeLadc3InyTtpVblxHDQ3eHYtt5rV8IicqrcHI
	 7w128TmdpsfLZwLuY/8Pf6CtWVZI89+LQgg1RuQqlM7n2AbccwStqdAwAoGik4gAidQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=p4uAstBqCOqQ9Ibbrs8uDsdz+izyLnUae77SN1BnzNo=;
	b=aI6WMB457uYqqqQDxuMZQ04Rm2pbtA4rM67QPG2RrliGEX4OQABzJRSKl6d6H8RVQV2l
	 621v+GYZ3XqdtYU02SnZjJmOGwRYubp+1L/lelhImiIx+lhjxVuSIZFVJGTFkQ3HUNIhN
	 trNA9o/XFqDKZDBC8CfYkFFtFgELGtpQsuGSO0FSegS6R0s1iIaE1QSwp107Jeu9whg5k
	 nIcOJTqQSQOG/KT7vyfSU/CLXcV0BeQ2vMqOWvqGQJXEoRf0piM6oNclm9MFTSDPgFsbq
	 QTYo468t92kdckfHPfUvp6sbW0gca7YsaWJF2bno6t+u0OVV4kdDJNh+u5fQqCYvYCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E502060A262D;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E502060A262D
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id 070E52DF349; Wed, 18 Nov 2026 14:45:19 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 13/29] crypto/krb5: Implement the Camellia enctypes from rfc6803
Date: Wed, 18 Nov 2026 14:45:02 +0300
Message-ID: <20261118114518.3605222-14-shaba@altlinux.org>
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

Implement the camellia128-cts-cmac and camellia256-cts-cmac enctypes from
rfc6803.

Note that the test vectors in rfc6803 for encryption are incomplete,
lacking the key usage number needed to derive Ke and Ki, and there are
errata for this:

	https://www.rfc-editor.org/errata_search.php?rfc=6803

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
(cherry picked from commit 742e38d4d4033e7ff53178acf7edd2b1fe0142ef)
---
 crypto/krb5/Kconfig            |   2 +
 crypto/krb5/Makefile           |   1 +
 crypto/krb5/internal.h         |   6 +
 crypto/krb5/krb5_api.c         |   2 +
 crypto/krb5/rfc6803_camellia.c | 237 +++++++++++++++++++++++++++++++++
 include/crypto/krb5.h          |   4 +
 6 files changed, 252 insertions(+)
 create mode 100644 crypto/krb5/rfc6803_camellia.c

diff --git a/crypto/krb5/Kconfig b/crypto/krb5/Kconfig
index 52f0ed2d7820..5b339690905c 100644
--- a/crypto/krb5/Kconfig
+++ b/crypto/krb5/Kconfig
@@ -6,12 +6,14 @@ config CRYPTO_KRB5
 	select CRYPTO_SKCIPHER
 	select CRYPTO_HASH_INFO
 	select CRYPTO_HMAC
+	select CRYPTO_CMAC
 	select CRYPTO_SHA1
 	select CRYPTO_SHA256
 	select CRYPTO_SHA512
 	select CRYPTO_CBC
 	select CRYPTO_CTS
 	select CRYPTO_AES
+	select CRYPTO_CAMELLIA
 	help
 	  Provide a library for provision of Kerberos-5-based crypto.  This is
 	  intended for network filesystems to use.
diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
index 7fd215ec3a85..7cbe5e5ded19 100644
--- a/crypto/krb5/Makefile
+++ b/crypto/krb5/Makefile
@@ -8,6 +8,7 @@ krb5-y += \
 	krb5_api.o \
 	rfc3961_simplified.o \
 	rfc3962_aes.o \
+	rfc6803_camellia.o \
 	rfc8009_aes2.o
 
 obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index f537f6eb86eb..8679140ef90d 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -186,6 +186,12 @@ int rfc3961_verify_mic(const struct krb5_enctype *krb5,
 extern const struct krb5_enctype krb5_aes128_cts_hmac_sha1_96;
 extern const struct krb5_enctype krb5_aes256_cts_hmac_sha1_96;
 
+/*
+ * rfc6803_camellia.c
+ */
+extern const struct krb5_enctype krb5_camellia128_cts_cmac;
+extern const struct krb5_enctype krb5_camellia256_cts_cmac;
+
 /*
  * rfc8009_aes2.c
  */
diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index 5b94cc5db461..02e21c8f4d14 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -21,6 +21,8 @@ static const struct krb5_enctype *const krb5_supported_enctypes[] = {
 	&krb5_aes256_cts_hmac_sha1_96,
 	&krb5_aes128_cts_hmac_sha256_128,
 	&krb5_aes256_cts_hmac_sha384_192,
+	&krb5_camellia128_cts_cmac,
+	&krb5_camellia256_cts_cmac,
 };
 
 /**
diff --git a/crypto/krb5/rfc6803_camellia.c b/crypto/krb5/rfc6803_camellia.c
new file mode 100644
index 000000000000..77cd4ce023f1
--- /dev/null
+++ b/crypto/krb5/rfc6803_camellia.c
@@ -0,0 +1,237 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/* rfc6803 Camellia Encryption for Kerberos 5
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/slab.h>
+#include "internal.h"
+
+/*
+ * Calculate the key derivation function KDF-FEEDBACK_CMAC(key, constant)
+ *
+ *	n = ceiling(k / 128)
+ *	K(0) = zeros
+ *	K(i) = CMAC(key, K(i-1) | i | constant | 0x00 | k)
+ *	DR(key, constant) = k-truncate(K(1) | K(2) | ... | K(n))
+ *	KDF-FEEDBACK-CMAC(key, constant) = random-to-key(DR(key, constant))
+ *
+ *	[rfc6803 sec 3]
+ */
+static int rfc6803_calc_KDF_FEEDBACK_CMAC(const struct krb5_enctype *krb5,
+					  const struct krb5_buffer *key,
+					  const struct krb5_buffer *constant,
+					  struct krb5_buffer *result,
+					  gfp_t gfp)
+{
+	struct crypto_shash *shash;
+	struct krb5_buffer K, data;
+	struct shash_desc *desc;
+	__be32 tmp;
+	size_t bsize, offset, seg;
+	void *buffer;
+	u32 i = 0, k = result->len * 8;
+	u8 *p;
+	int ret = -ENOMEM;
+
+	shash = crypto_alloc_shash(krb5->cksum_name, 0, 0);
+	if (IS_ERR(shash))
+		return (PTR_ERR(shash) == -ENOENT) ? -ENOPKG : PTR_ERR(shash);
+	ret = crypto_shash_setkey(shash, key->data, key->len);
+	if (ret < 0)
+		goto error_shash;
+
+	ret = -ENOMEM;
+	K.len = crypto_shash_digestsize(shash);
+	data.len = K.len + 4 + constant->len + 1 + 4;
+	bsize = krb5_shash_size(shash) +
+		krb5_digest_size(shash) +
+		crypto_roundup(K.len) +
+		crypto_roundup(data.len);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		goto error_shash;
+
+	desc = buffer;
+	desc->tfm = shash;
+
+	K.data = buffer +
+		krb5_shash_size(shash) +
+		krb5_digest_size(shash);
+	data.data = buffer +
+		krb5_shash_size(shash) +
+		krb5_digest_size(shash) +
+		crypto_roundup(K.len);
+
+	p = data.data + K.len + 4;
+	memcpy(p, constant->data, constant->len);
+	p += constant->len;
+	*p++ = 0x00;
+	tmp = htonl(k);
+	memcpy(p, &tmp, 4);
+	p += 4;
+
+	ret = -EINVAL;
+	if (WARN_ON(p - (u8 *)data.data != data.len))
+		goto error;
+
+	offset = 0;
+	do {
+		i++;
+		p = data.data;
+		memcpy(p, K.data, K.len);
+		p += K.len;
+		*(__be32 *)p = htonl(i);
+
+		ret = crypto_shash_init(desc);
+		if (ret < 0)
+			goto error;
+		ret = crypto_shash_finup(desc, data.data, data.len, K.data);
+		if (ret < 0)
+			goto error;
+
+		seg = min_t(size_t, result->len - offset, K.len);
+		memcpy(result->data + offset, K.data, seg);
+		offset += seg;
+	} while (offset < result->len);
+
+error:
+	kfree_sensitive(buffer);
+error_shash:
+	crypto_free_shash(shash);
+	return ret;
+}
+
+/*
+ * Calculate the pseudo-random function, PRF().
+ *
+ *	Kp = KDF-FEEDBACK-CMAC(protocol-key, "prf")
+ *	PRF = CMAC(Kp, octet-string)
+ *      [rfc6803 sec 6]
+ */
+static int rfc6803_calc_PRF(const struct krb5_enctype *krb5,
+			    const struct krb5_buffer *protocol_key,
+			    const struct krb5_buffer *octet_string,
+			    struct krb5_buffer *result,
+			    gfp_t gfp)
+{
+	static const struct krb5_buffer prfconstant = { 3, "prf" };
+	struct crypto_shash *shash;
+	struct krb5_buffer Kp;
+	struct shash_desc *desc;
+	size_t bsize;
+	void *buffer;
+	int ret;
+
+	Kp.len = krb5->prf_len;
+
+	shash = crypto_alloc_shash(krb5->cksum_name, 0, 0);
+	if (IS_ERR(shash))
+		return (PTR_ERR(shash) == -ENOENT) ? -ENOPKG : PTR_ERR(shash);
+
+	ret = -EINVAL;
+	if (result->len != crypto_shash_digestsize(shash))
+		goto out_shash;
+
+	ret = -ENOMEM;
+	bsize = krb5_shash_size(shash) +
+		krb5_digest_size(shash) +
+		crypto_roundup(Kp.len);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		goto out_shash;
+
+	Kp.data = buffer +
+		krb5_shash_size(shash) +
+		krb5_digest_size(shash);
+
+	ret = rfc6803_calc_KDF_FEEDBACK_CMAC(krb5, protocol_key, &prfconstant,
+					     &Kp, gfp);
+	if (ret < 0)
+		goto out;
+
+	ret = crypto_shash_setkey(shash, Kp.data, Kp.len);
+	if (ret < 0)
+		goto out;
+
+	desc = buffer;
+	desc->tfm = shash;
+	ret = crypto_shash_init(desc);
+	if (ret < 0)
+		goto out;
+
+	ret = crypto_shash_finup(desc, octet_string->data, octet_string->len, result->data);
+	if (ret < 0)
+		goto out;
+
+out:
+	kfree_sensitive(buffer);
+out_shash:
+	crypto_free_shash(shash);
+	return ret;
+}
+
+
+static const struct krb5_crypto_profile rfc6803_crypto_profile = {
+	.calc_PRF		= rfc6803_calc_PRF,
+	.calc_Kc		= rfc6803_calc_KDF_FEEDBACK_CMAC,
+	.calc_Ke		= rfc6803_calc_KDF_FEEDBACK_CMAC,
+	.calc_Ki		= rfc6803_calc_KDF_FEEDBACK_CMAC,
+	.derive_encrypt_keys	= authenc_derive_encrypt_keys,
+	.load_encrypt_keys	= authenc_load_encrypt_keys,
+	.derive_checksum_key	= rfc3961_derive_checksum_key,
+	.load_checksum_key	= rfc3961_load_checksum_key,
+	.encrypt		= krb5_aead_encrypt,
+	.decrypt		= krb5_aead_decrypt,
+	.get_mic		= rfc3961_get_mic,
+	.verify_mic		= rfc3961_verify_mic,
+};
+
+const struct krb5_enctype krb5_camellia128_cts_cmac = {
+	.etype		= KRB5_ENCTYPE_CAMELLIA128_CTS_CMAC,
+	.ctype		= KRB5_CKSUMTYPE_CMAC_CAMELLIA128,
+	.name		= "camellia128-cts-cmac",
+	.encrypt_name	= "krb5enc(cmac(camellia),cts(cbc(camellia)))",
+	.cksum_name	= "cmac(camellia)",
+	.hash_name	= NULL,
+	.derivation_enc	= "cts(cbc(camellia))",
+	.key_bytes	= 16,
+	.key_len	= 16,
+	.Kc_len		= 16,
+	.Ke_len		= 16,
+	.Ki_len		= 16,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 16,
+	.hash_len	= 16,
+	.prf_len	= 16,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc6803_crypto_profile,
+};
+
+const struct krb5_enctype krb5_camellia256_cts_cmac = {
+	.etype		= KRB5_ENCTYPE_CAMELLIA256_CTS_CMAC,
+	.ctype		= KRB5_CKSUMTYPE_CMAC_CAMELLIA256,
+	.name		= "camellia256-cts-cmac",
+	.encrypt_name	= "krb5enc(cmac(camellia),cts(cbc(camellia)))",
+	.cksum_name	= "cmac(camellia)",
+	.hash_name	= NULL,
+	.derivation_enc	= "cts(cbc(camellia))",
+	.key_bytes	= 32,
+	.key_len	= 32,
+	.Kc_len		= 32,
+	.Ke_len		= 32,
+	.Ki_len		= 32,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 16,
+	.hash_len	= 16,
+	.prf_len	= 16,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc6803_crypto_profile,
+};
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index b8fda81379ab..62d998e62f47 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -35,6 +35,8 @@ struct scatterlist;
 #define KRB5_ENCTYPE_AES256_CTS_HMAC_SHA384_192	0x0014
 #define KRB5_ENCTYPE_ARCFOUR_HMAC		0x0017
 #define KRB5_ENCTYPE_ARCFOUR_HMAC_EXP		0x0018
+#define KRB5_ENCTYPE_CAMELLIA128_CTS_CMAC	0x0019
+#define KRB5_ENCTYPE_CAMELLIA256_CTS_CMAC	0x001a
 #define KRB5_ENCTYPE_UNKNOWN			0x01ff
 
 #define KRB5_CKSUMTYPE_CRC32			0x0001
@@ -47,6 +49,8 @@ struct scatterlist;
 #define KRB5_CKSUMTYPE_HMAC_SHA1_DES3		0x000c
 #define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES128	0x000f
 #define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES256	0x0010
+#define KRB5_CKSUMTYPE_CMAC_CAMELLIA128		0x0011
+#define KRB5_CKSUMTYPE_CMAC_CAMELLIA256		0x0012
 #define KRB5_CKSUMTYPE_HMAC_SHA256_128_AES128	0x0013
 #define KRB5_CKSUMTYPE_HMAC_SHA384_192_AES256	0x0014
 #define KRB5_CKSUMTYPE_HMAC_MD5_ARCFOUR		-138 /* Microsoft md5 hmac cksumtype */
-- 
2.50.1

