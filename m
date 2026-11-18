Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=vVHts+3sh2FxxUte3HUUB0hXq4qIwfdjueGPRDVkmTW7nCcSqxgiYmRs5/VHl0EmpXGr
	 U1pSnuWMiI4TIG3/InMldBFQ30FLoXqXuFjfPrtrpFknMyaXdgs0ANbUUaTFTddipgywn
	 F4HXhBBjFg1cDvKIJF3CjnC6ElR/Qe0/Zb4xcK2YmkrqQqKssNgTwWJIMvkLck9Zf9Dwx
	 u6TE5PFH4tZw+kyHHOv6GiSwBmyGs2Nnn1r/i4PtXRVxLU0aXqG7P8rzUBQHLJ+5XO5Ov
	 ByR7wf00a2/U+zKOXWaz+z9HU9JapXfFCvF2JudHhLttk1j3ZY8y5qo/vzfLU88ddSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5ZMYu4mQzr5k24NEjgotAtJz+vr+l89zz4PGKfMIu1U=;
	b=dDmH93HcMzdLsrzAl8Lv1vyIeUpXWzLXzjNW+zN3zzalKz45EzHQeKSJTL/lKtrWSyhF
	 W71+8SOyWjVemVo/1deHW+55QfREpS+d+ppDPAtpU4R9JVjGKup923499A+p3G8Kr4XjO
	 4ASUzA8PhXdUrnSNvH6eFtiV/XrQWm9s5xJKTFm4EM+kesFzdouVcKfP/p1kSwoRJtI0L
	 mA4kFzEy6k9tSuK4WPieOfyOKsnkd8mn3JgIknKmAtYMcCqnxGvn9MVHx7eyYpKDQ6F/R
	 QZJk516W+LjAwlcn7oXaIGf8pYtfIMJds6Cj0g7f/LYHa0rIShodmI0rsJSiZbpgMTQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id EDB2B60A262E;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EDB2B60A262E
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id 038522DF347; Wed, 18 Nov 2026 14:45:19 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 12/29] crypto/krb5: Implement the AES enctypes from rfc8009
Date: Wed, 18 Nov 2026 14:45:01 +0300
Message-ID: <20261118114518.3605222-13-shaba@altlinux.org>
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

Implement the aes128-cts-hmac-sha256-128 and aes256-cts-hmac-sha384-192
enctypes from rfc8009, overriding the rfc3961 kerberos 5 simplified crypto
scheme.

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
(cherry picked from commit 6c3c0e86c2acf53bf67c095c67335a0bec2a16af)
---
 crypto/krb5/Kconfig        |   2 +
 crypto/krb5/Makefile       |   3 +-
 crypto/krb5/internal.h     |   6 +
 crypto/krb5/krb5_api.c     |   2 +
 crypto/krb5/rfc8009_aes2.c | 362 +++++++++++++++++++++++++++++++++++++
 include/crypto/krb5.h      |   4 +
 6 files changed, 378 insertions(+), 1 deletion(-)
 create mode 100644 crypto/krb5/rfc8009_aes2.c

diff --git a/crypto/krb5/Kconfig b/crypto/krb5/Kconfig
index 2ad874990dc8..52f0ed2d7820 100644
--- a/crypto/krb5/Kconfig
+++ b/crypto/krb5/Kconfig
@@ -7,6 +7,8 @@ config CRYPTO_KRB5
 	select CRYPTO_HASH_INFO
 	select CRYPTO_HMAC
 	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	select CRYPTO_SHA512
 	select CRYPTO_CBC
 	select CRYPTO_CTS
 	select CRYPTO_AES
diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
index 35f21411abf8..7fd215ec3a85 100644
--- a/crypto/krb5/Makefile
+++ b/crypto/krb5/Makefile
@@ -7,6 +7,7 @@ krb5-y += \
 	krb5_kdf.o \
 	krb5_api.o \
 	rfc3961_simplified.o \
-	rfc3962_aes.o
+	rfc3962_aes.o \
+	rfc8009_aes2.o
 
 obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index 43f904a69e32..f537f6eb86eb 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -185,3 +185,9 @@ int rfc3961_verify_mic(const struct krb5_enctype *krb5,
  */
 extern const struct krb5_enctype krb5_aes128_cts_hmac_sha1_96;
 extern const struct krb5_enctype krb5_aes256_cts_hmac_sha1_96;
+
+/*
+ * rfc8009_aes2.c
+ */
+extern const struct krb5_enctype krb5_aes128_cts_hmac_sha256_128;
+extern const struct krb5_enctype krb5_aes256_cts_hmac_sha384_192;
diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index ecc6655953d5..5b94cc5db461 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -19,6 +19,8 @@ MODULE_LICENSE("GPL");
 static const struct krb5_enctype *const krb5_supported_enctypes[] = {
 	&krb5_aes128_cts_hmac_sha1_96,
 	&krb5_aes256_cts_hmac_sha1_96,
+	&krb5_aes128_cts_hmac_sha256_128,
+	&krb5_aes256_cts_hmac_sha384_192,
 };
 
 /**
diff --git a/crypto/krb5/rfc8009_aes2.c b/crypto/krb5/rfc8009_aes2.c
new file mode 100644
index 000000000000..d39851fc3a4e
--- /dev/null
+++ b/crypto/krb5/rfc8009_aes2.c
@@ -0,0 +1,362 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/* rfc8009 AES Encryption with HMAC-SHA2 for Kerberos 5
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/slab.h>
+#include <crypto/authenc.h>
+#include "internal.h"
+
+static const struct krb5_buffer rfc8009_no_context = { .len = 0, .data = "" };
+
+/*
+ * Calculate the key derivation function KDF-HMAC-SHA2(key, label, [context,] k)
+ *
+ *	KDF-HMAC-SHA2(key, label, [context,] k) = k-truncate(K1)
+ *
+ *	Using the appropriate one of:
+ *		K1 = HMAC-SHA-256(key, 0x00000001 | label | 0x00 | k)
+ *		K1 = HMAC-SHA-384(key, 0x00000001 | label | 0x00 | k)
+ *		K1 = HMAC-SHA-256(key, 0x00000001 | label | 0x00 | context | k)
+ *		K1 = HMAC-SHA-384(key, 0x00000001 | label | 0x00 | context | k)
+ *	[rfc8009 sec 3]
+ */
+static int rfc8009_calc_KDF_HMAC_SHA2(const struct krb5_enctype *krb5,
+				      const struct krb5_buffer *key,
+				      const struct krb5_buffer *label,
+				      const struct krb5_buffer *context,
+				      unsigned int k,
+				      struct krb5_buffer *result,
+				      gfp_t gfp)
+{
+	struct crypto_shash *shash;
+	struct krb5_buffer K1, data;
+	struct shash_desc *desc;
+	__be32 tmp;
+	size_t bsize;
+	void *buffer;
+	u8 *p;
+	int ret = -ENOMEM;
+
+	if (WARN_ON(result->len != k / 8))
+		return -EINVAL;
+
+	shash = crypto_alloc_shash(krb5->cksum_name, 0, 0);
+	if (IS_ERR(shash))
+		return (PTR_ERR(shash) == -ENOENT) ? -ENOPKG : PTR_ERR(shash);
+	ret = crypto_shash_setkey(shash, key->data, key->len);
+	if (ret < 0)
+		goto error_shash;
+
+	ret = -EINVAL;
+	if (WARN_ON(crypto_shash_digestsize(shash) * 8 < k))
+		goto error_shash;
+
+	ret = -ENOMEM;
+	data.len = 4 + label->len + 1 + context->len + 4;
+	bsize = krb5_shash_size(shash) +
+		krb5_digest_size(shash) +
+		crypto_roundup(data.len);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		goto error_shash;
+
+	desc = buffer;
+	desc->tfm = shash;
+	ret = crypto_shash_init(desc);
+	if (ret < 0)
+		goto error;
+
+	p = data.data = buffer +
+		krb5_shash_size(shash) +
+		krb5_digest_size(shash);
+	*(__be32 *)p = htonl(0x00000001);
+	p += 4;
+	memcpy(p, label->data, label->len);
+	p += label->len;
+	*p++ = 0;
+	memcpy(p, context->data, context->len);
+	p += context->len;
+	tmp = htonl(k);
+	memcpy(p, &tmp, 4);
+	p += 4;
+
+	ret = -EINVAL;
+	if (WARN_ON(p - (u8 *)data.data != data.len))
+		goto error;
+
+	K1.len = crypto_shash_digestsize(shash);
+	K1.data = buffer +
+		krb5_shash_size(shash);
+
+	ret = crypto_shash_finup(desc, data.data, data.len, K1.data);
+	if (ret < 0)
+		goto error;
+
+	memcpy(result->data, K1.data, result->len);
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
+ *	PRF = KDF-HMAC-SHA2(input-key, "prf", octet-string, 256)
+ *	PRF = KDF-HMAC-SHA2(input-key, "prf", octet-string, 384)
+ *
+ *      The "prfconstant" used in the PRF operation is the three-octet string
+ *      "prf".
+ *      [rfc8009 sec 5]
+ */
+static int rfc8009_calc_PRF(const struct krb5_enctype *krb5,
+			    const struct krb5_buffer *input_key,
+			    const struct krb5_buffer *octet_string,
+			    struct krb5_buffer *result,
+			    gfp_t gfp)
+{
+	static const struct krb5_buffer prfconstant = { 3, "prf" };
+
+	return rfc8009_calc_KDF_HMAC_SHA2(krb5, input_key, &prfconstant,
+					  octet_string, krb5->prf_len * 8,
+					  result, gfp);
+}
+
+/*
+ * Derive Ke.
+ *	Ke = KDF-HMAC-SHA2(base-key, usage | 0xAA, 128)
+ *	Ke = KDF-HMAC-SHA2(base-key, usage | 0xAA, 256)
+ *      [rfc8009 sec 5]
+ */
+static int rfc8009_calc_Ke(const struct krb5_enctype *krb5,
+			   const struct krb5_buffer *base_key,
+			   const struct krb5_buffer *usage_constant,
+			   struct krb5_buffer *result,
+			   gfp_t gfp)
+{
+	return rfc8009_calc_KDF_HMAC_SHA2(krb5, base_key, usage_constant,
+					  &rfc8009_no_context, krb5->key_bytes * 8,
+					  result, gfp);
+}
+
+/*
+ * Derive Kc/Ki
+ *	Kc = KDF-HMAC-SHA2(base-key, usage | 0x99, 128)
+ *	Ki = KDF-HMAC-SHA2(base-key, usage | 0x55, 128)
+ *	Kc = KDF-HMAC-SHA2(base-key, usage | 0x99, 192)
+ *	Ki = KDF-HMAC-SHA2(base-key, usage | 0x55, 192)
+ *      [rfc8009 sec 5]
+ */
+static int rfc8009_calc_Ki(const struct krb5_enctype *krb5,
+			   const struct krb5_buffer *base_key,
+			   const struct krb5_buffer *usage_constant,
+			   struct krb5_buffer *result,
+			   gfp_t gfp)
+{
+	return rfc8009_calc_KDF_HMAC_SHA2(krb5, base_key, usage_constant,
+					  &rfc8009_no_context, krb5->cksum_len * 8,
+					  result, gfp);
+}
+
+/*
+ * Apply encryption and checksumming functions to a message.  Unlike for
+ * RFC3961, for RFC8009, we have to chuck the starting IV into the hash first.
+ */
+static ssize_t rfc8009_encrypt(const struct krb5_enctype *krb5,
+			       struct crypto_aead *aead,
+			       struct scatterlist *sg, unsigned int nr_sg, size_t sg_len,
+			       size_t data_offset, size_t data_len,
+			       bool preconfounded)
+{
+	struct aead_request *req;
+	struct scatterlist bsg[2];
+	ssize_t ret, done;
+	size_t bsize, base_len, secure_offset, secure_len, pad_len, cksum_offset;
+	void *buffer;
+	u8 *iv, *ad;
+
+	if (WARN_ON(data_offset != krb5->conf_len))
+		return -EINVAL; /* Data is in wrong place */
+
+	secure_offset	= 0;
+	base_len	= krb5->conf_len + data_len;
+	pad_len		= 0;
+	secure_len	= base_len + pad_len;
+	cksum_offset	= secure_len;
+	if (WARN_ON(cksum_offset + krb5->cksum_len > sg_len))
+		return -EFAULT;
+
+	bsize = krb5_aead_size(aead) +
+		krb5_aead_ivsize(aead) * 2;
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
+
+	req = buffer;
+	iv = buffer + krb5_aead_size(aead);
+	ad = buffer + krb5_aead_size(aead) + krb5_aead_ivsize(aead);
+
+	/* Insert the confounder into the buffer */
+	ret = -EFAULT;
+	if (!preconfounded) {
+		get_random_bytes(buffer, krb5->conf_len);
+		done = sg_pcopy_from_buffer(sg, nr_sg, buffer, krb5->conf_len,
+					    secure_offset);
+		if (done != krb5->conf_len)
+			goto error;
+	}
+
+	/* We may need to pad out to the crypto blocksize. */
+	if (pad_len) {
+		done = sg_zero_buffer(sg, nr_sg, pad_len, data_offset + data_len);
+		if (done != pad_len)
+			goto error;
+	}
+
+	/* We need to include the starting IV in the hash. */
+	sg_init_table(bsg, 2);
+	sg_set_buf(&bsg[0], ad, krb5_aead_ivsize(aead));
+	sg_chain(bsg, 2, sg);
+
+	/* Hash and encrypt the message. */
+	aead_request_set_tfm(req, aead);
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_ad(req, krb5_aead_ivsize(aead));
+	aead_request_set_crypt(req, bsg, bsg, secure_len, iv);
+	ret = crypto_aead_encrypt(req);
+	if (ret < 0)
+		goto error;
+
+	ret = secure_len + krb5->cksum_len;
+
+error:
+	kfree_sensitive(buffer);
+	return ret;
+}
+
+/*
+ * Apply decryption and checksumming functions to a message.  Unlike for
+ * RFC3961, for RFC8009, we have to chuck the starting IV into the hash first.
+ *
+ * The offset and length are updated to reflect the actual content of the
+ * encrypted region.
+ */
+static int rfc8009_decrypt(const struct krb5_enctype *krb5,
+			   struct crypto_aead *aead,
+			   struct scatterlist *sg, unsigned int nr_sg,
+			   size_t *_offset, size_t *_len)
+{
+	struct aead_request *req;
+	struct scatterlist bsg[2];
+	size_t bsize;
+	void *buffer;
+	int ret;
+	u8 *iv, *ad;
+
+	if (WARN_ON(*_offset != 0))
+		return -EINVAL; /* Can't set offset on aead */
+
+	if (*_len < krb5->conf_len + krb5->cksum_len)
+		return -EPROTO;
+
+	bsize = krb5_aead_size(aead) +
+		krb5_aead_ivsize(aead) * 2;
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
+
+	req = buffer;
+	iv = buffer + krb5_aead_size(aead);
+	ad = buffer + krb5_aead_size(aead) + krb5_aead_ivsize(aead);
+
+	/* We need to include the starting IV in the hash. */
+	sg_init_table(bsg, 2);
+	sg_set_buf(&bsg[0], ad, krb5_aead_ivsize(aead));
+	sg_chain(bsg, 2, sg);
+
+	/* Decrypt the message and verify its checksum. */
+	aead_request_set_tfm(req, aead);
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_ad(req, krb5_aead_ivsize(aead));
+	aead_request_set_crypt(req, bsg, bsg, *_len, iv);
+	ret = crypto_aead_decrypt(req);
+	if (ret < 0)
+		goto error;
+
+	/* Adjust the boundaries of the data. */
+	*_offset += krb5->conf_len;
+	*_len -= krb5->conf_len + krb5->cksum_len;
+	ret = 0;
+
+error:
+	kfree_sensitive(buffer);
+	return ret;
+}
+
+static const struct krb5_crypto_profile rfc8009_crypto_profile = {
+	.calc_PRF		= rfc8009_calc_PRF,
+	.calc_Kc		= rfc8009_calc_Ki,
+	.calc_Ke		= rfc8009_calc_Ke,
+	.calc_Ki		= rfc8009_calc_Ki,
+	.derive_encrypt_keys	= authenc_derive_encrypt_keys,
+	.load_encrypt_keys	= authenc_load_encrypt_keys,
+	.derive_checksum_key	= rfc3961_derive_checksum_key,
+	.load_checksum_key	= rfc3961_load_checksum_key,
+	.encrypt		= rfc8009_encrypt,
+	.decrypt		= rfc8009_decrypt,
+	.get_mic		= rfc3961_get_mic,
+	.verify_mic		= rfc3961_verify_mic,
+};
+
+const struct krb5_enctype krb5_aes128_cts_hmac_sha256_128 = {
+	.etype		= KRB5_ENCTYPE_AES128_CTS_HMAC_SHA256_128,
+	.ctype		= KRB5_CKSUMTYPE_HMAC_SHA256_128_AES128,
+	.name		= "aes128-cts-hmac-sha256-128",
+	.encrypt_name	= "authenc(hmac(sha256),cts(cbc(aes)))",
+	.cksum_name	= "hmac(sha256)",
+	.hash_name	= "sha256",
+	.derivation_enc	= "cts(cbc(aes))",
+	.key_bytes	= 16,
+	.key_len	= 16,
+	.Kc_len		= 16,
+	.Ke_len		= 16,
+	.Ki_len		= 16,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 16,
+	.hash_len	= 20,
+	.prf_len	= 32,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc8009_crypto_profile,
+};
+
+const struct krb5_enctype krb5_aes256_cts_hmac_sha384_192 = {
+	.etype		= KRB5_ENCTYPE_AES256_CTS_HMAC_SHA384_192,
+	.ctype		= KRB5_CKSUMTYPE_HMAC_SHA384_192_AES256,
+	.name		= "aes256-cts-hmac-sha384-192",
+	.encrypt_name	= "authenc(hmac(sha384),cts(cbc(aes)))",
+	.cksum_name	= "hmac(sha384)",
+	.hash_name	= "sha384",
+	.derivation_enc	= "cts(cbc(aes))",
+	.key_bytes	= 32,
+	.key_len	= 32,
+	.Kc_len		= 24,
+	.Ke_len		= 32,
+	.Ki_len		= 24,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 24,
+	.hash_len	= 20,
+	.prf_len	= 48,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc8009_crypto_profile,
+};
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index b12f012cf354..b8fda81379ab 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -31,6 +31,8 @@ struct scatterlist;
 #define KRB5_ENCTYPE_DES3_CBC_SHA1		0x0010
 #define KRB5_ENCTYPE_AES128_CTS_HMAC_SHA1_96	0x0011
 #define KRB5_ENCTYPE_AES256_CTS_HMAC_SHA1_96	0x0012
+#define KRB5_ENCTYPE_AES128_CTS_HMAC_SHA256_128	0x0013
+#define KRB5_ENCTYPE_AES256_CTS_HMAC_SHA384_192	0x0014
 #define KRB5_ENCTYPE_ARCFOUR_HMAC		0x0017
 #define KRB5_ENCTYPE_ARCFOUR_HMAC_EXP		0x0018
 #define KRB5_ENCTYPE_UNKNOWN			0x01ff
@@ -45,6 +47,8 @@ struct scatterlist;
 #define KRB5_CKSUMTYPE_HMAC_SHA1_DES3		0x000c
 #define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES128	0x000f
 #define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES256	0x0010
+#define KRB5_CKSUMTYPE_HMAC_SHA256_128_AES128	0x0013
+#define KRB5_CKSUMTYPE_HMAC_SHA384_192_AES256	0x0014
 #define KRB5_CKSUMTYPE_HMAC_MD5_ARCFOUR		-138 /* Microsoft md5 hmac cksumtype */
 
 /*
-- 
2.50.1

