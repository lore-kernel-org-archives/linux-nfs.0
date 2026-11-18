Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=AuQOs2ZOIPVMb1+eglMu7JactSIAsQTcy7phcb0Lw9bSn7UrVXl9pNjAKylFlFkVN8tP
	 hGfz9j3p4tYNjTpj0DJ7kQ9XQk7sd9ukemblqpDQUYZqHke/c3kd2rEr4RkjoGbsfx5/O
	 vOphY4R4u2lXSr0tnXNX3KRWkyWA+NLHLgoT04fStU+d+b6sV4IG0yB4I+nLcmTwr1j5h
	 VTyl9PIFENVCsVmx9kjy83pBEc1XGDoMYwVotFbMoEbHw+xtORleCFEfDiT3T2VFUjGHp
	 gS9HKJVY9IhUgGZf+bEcifaIYOOuW37EjpJJYy2MxrTWk3OssyExQfxEMxMuWtLL52Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=kXE7WBMO18v3qtUwqnLO8i0c1Vje0/FeIr0SAQ2LBwU=;
	b=G8C56f8NqPlCcTzFLCUrkIpBZVYQjOlWl3TY5d+WnjKKv/IAKMVyzy+dR8mDnsdaEpbn
	 /EbCph2AGs7T5JBXxjlM1CucxprRcl0iXqLSaK/5rxruXfgrt7wzCXeEdmKVzz1FPLE6w
	 v/kK2M2RfUz3jSf5BCXZ0D//iTBWJL3hNyjwjD9NJGqlL7q5E68XomAOJ3jrzAu4rTwKa
	 0MhKOVtaa+E0tXVgQu9F88oVkQlpMe2ZGkAHxtP3CLHrKbD0qySzj0wOCLr6de9nJ4R9P
	 xkczi2AtYbgpT6KbvVZ+cKCbY8PLZ4zd5+sO1cqACcRZQpJD7qoCUK8DxoWlaq4d3Pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id BF4CA60A2626;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BF4CA60A2626
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id E5D2B2DF33D; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 07/29] crypto/krb5: Implement the Kerberos5 rfc3961 key derivation
Date: Wed, 18 Nov 2026 14:44:56 +0300
Message-ID: <20261118114518.3605222-8-shaba@altlinux.org>
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

Implement the simplified crypto profile for Kerberos 5 rfc3961 with the
pseudo-random function, PRF(), from section 5.3 and the key derivation
function, DK() from section 5.1.

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
(cherry picked from commit c8d8f6af66c3cd7896460da4a0ddd006f391f6d2)
---
 crypto/krb5/Makefile             |   3 +-
 crypto/krb5/internal.h           |   6 +
 crypto/krb5/rfc3961_simplified.c | 407 +++++++++++++++++++++++++++++++
 3 files changed, 415 insertions(+), 1 deletion(-)
 create mode 100644 crypto/krb5/rfc3961_simplified.c

diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
index 8c2050af8fed..8dad8e3bf086 100644
--- a/crypto/krb5/Makefile
+++ b/crypto/krb5/Makefile
@@ -5,6 +5,7 @@
 
 krb5-y += \
 	krb5_kdf.o \
-	krb5_api.o
+	krb5_api.o \
+	rfc3961_simplified.o
 
 obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index 50abda5169c7..7d60977dc0c5 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -5,6 +5,7 @@
  * Written by David Howells (dhowells@redhat.com)
  */
 
+#include <linux/scatterlist.h>
 #include <crypto/krb5.h>
 
 /*
@@ -130,3 +131,8 @@ int krb5_derive_Ke(const struct krb5_enctype *krb5, const struct krb5_buffer *TK
 		   u32 usage, struct krb5_buffer *key, gfp_t gfp);
 int krb5_derive_Ki(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
 		   u32 usage, struct krb5_buffer *key, gfp_t gfp);
+
+/*
+ * rfc3961_simplified.c
+ */
+extern const struct krb5_crypto_profile rfc3961_simplified_profile;
diff --git a/crypto/krb5/rfc3961_simplified.c b/crypto/krb5/rfc3961_simplified.c
new file mode 100644
index 000000000000..75eafba059c7
--- /dev/null
+++ b/crypto/krb5/rfc3961_simplified.c
@@ -0,0 +1,407 @@
+// SPDX-License-Identifier: BSD-3-Clause
+/* rfc3961 Kerberos 5 simplified crypto profile.
+ *
+ * Parts borrowed from net/sunrpc/auth_gss/.
+ */
+/*
+ * COPYRIGHT (c) 2008
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ *
+ * All rights reserved.
+ *
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+/*
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/slab.h>
+#include <linux/lcm.h>
+#include <crypto/skcipher.h>
+#include <crypto/hash.h>
+#include "internal.h"
+
+/* Maximum blocksize for the supported crypto algorithms */
+#define KRB5_MAX_BLOCKSIZE  (16)
+
+static int rfc3961_do_encrypt(struct crypto_sync_skcipher *tfm, void *iv,
+			      const struct krb5_buffer *in, struct krb5_buffer *out)
+{
+	struct scatterlist sg[1];
+	u8 local_iv[KRB5_MAX_BLOCKSIZE] __aligned(KRB5_MAX_BLOCKSIZE) = {0};
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	int ret;
+
+	if (WARN_ON(in->len != out->len))
+		return -EINVAL;
+	if (out->len % crypto_sync_skcipher_blocksize(tfm) != 0)
+		return -EINVAL;
+
+	if (crypto_sync_skcipher_ivsize(tfm) > KRB5_MAX_BLOCKSIZE)
+		return -EINVAL;
+
+	if (iv)
+		memcpy(local_iv, iv, crypto_sync_skcipher_ivsize(tfm));
+
+	memcpy(out->data, in->data, out->len);
+	sg_init_one(sg, out->data, out->len);
+
+	skcipher_request_set_sync_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, out->len, local_iv);
+
+	ret = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
+	return ret;
+}
+
+/*
+ * Calculate an unkeyed basic hash.
+ */
+static int rfc3961_calc_H(const struct krb5_enctype *krb5,
+			  const struct krb5_buffer *data,
+			  struct krb5_buffer *digest,
+			  gfp_t gfp)
+{
+	struct crypto_shash *tfm;
+	struct shash_desc *desc;
+	size_t desc_size;
+	int ret = -ENOMEM;
+
+	tfm = crypto_alloc_shash(krb5->hash_name, 0, 0);
+	if (IS_ERR(tfm))
+		return (PTR_ERR(tfm) == -ENOENT) ? -ENOPKG : PTR_ERR(tfm);
+
+	desc_size = crypto_shash_descsize(tfm) + sizeof(*desc);
+
+	desc = kzalloc(desc_size, gfp);
+	if (!desc)
+		goto error_tfm;
+
+	digest->len = crypto_shash_digestsize(tfm);
+	digest->data = kzalloc(digest->len, gfp);
+	if (!digest->data)
+		goto error_desc;
+
+	desc->tfm = tfm;
+	ret = crypto_shash_init(desc);
+	if (ret < 0)
+		goto error_digest;
+
+	ret = crypto_shash_finup(desc, data->data, data->len, digest->data);
+	if (ret < 0)
+		goto error_digest;
+
+	goto error_desc;
+
+error_digest:
+	kfree_sensitive(digest->data);
+error_desc:
+	kfree_sensitive(desc);
+error_tfm:
+	crypto_free_shash(tfm);
+	return ret;
+}
+
+/*
+ * This is the n-fold function as described in rfc3961, sec 5.1
+ * Taken from MIT Kerberos and modified.
+ */
+static void rfc3961_nfold(const struct krb5_buffer *source, struct krb5_buffer *result)
+{
+	const u8 *in = source->data;
+	u8 *out = result->data;
+	unsigned long ulcm;
+	unsigned int inbits, outbits;
+	int byte, i, msbit;
+
+	/* the code below is more readable if I make these bytes instead of bits */
+	inbits = source->len;
+	outbits = result->len;
+
+	/* first compute lcm(n,k) */
+	ulcm = lcm(inbits, outbits);
+
+	/* now do the real work */
+	memset(out, 0, outbits);
+	byte = 0;
+
+	/* this will end up cycling through k lcm(k,n)/k times, which
+	 * is correct.
+	 */
+	for (i = ulcm-1; i >= 0; i--) {
+		/* compute the msbit in k which gets added into this byte */
+		msbit = (
+			/* first, start with the msbit in the first,
+			 * unrotated byte
+			 */
+			((inbits << 3) - 1) +
+			/* then, for each byte, shift to the right
+			 * for each repetition
+			 */
+			(((inbits << 3) + 13) * (i/inbits)) +
+			/* last, pick out the correct byte within
+			 * that shifted repetition
+			 */
+			((inbits - (i % inbits)) << 3)
+			 ) % (inbits << 3);
+
+		/* pull out the byte value itself */
+		byte += (((in[((inbits - 1) - (msbit >> 3)) % inbits] << 8) |
+			  (in[((inbits)     - (msbit >> 3)) % inbits]))
+			 >> ((msbit & 7) + 1)) & 0xff;
+
+		/* do the addition */
+		byte += out[i % outbits];
+		out[i % outbits] = byte & 0xff;
+
+		/* keep around the carry bit, if any */
+		byte >>= 8;
+	}
+
+	/* if there's a carry bit left over, add it back in */
+	if (byte) {
+		for (i = outbits - 1; i >= 0; i--) {
+			/* do the addition */
+			byte += out[i];
+			out[i] = byte & 0xff;
+
+			/* keep around the carry bit, if any */
+			byte >>= 8;
+		}
+	}
+}
+
+/*
+ * Calculate a derived key, DK(Base Key, Well-Known Constant)
+ *
+ * DK(Key, Constant) = random-to-key(DR(Key, Constant))
+ * DR(Key, Constant) = k-truncate(E(Key, Constant, initial-cipher-state))
+ * K1 = E(Key, n-fold(Constant), initial-cipher-state)
+ * K2 = E(Key, K1, initial-cipher-state)
+ * K3 = E(Key, K2, initial-cipher-state)
+ * K4 = ...
+ * DR(Key, Constant) = k-truncate(K1 | K2 | K3 | K4 ...)
+ * [rfc3961 sec 5.1]
+ */
+static int rfc3961_calc_DK(const struct krb5_enctype *krb5,
+			   const struct krb5_buffer *inkey,
+			   const struct krb5_buffer *in_constant,
+			   struct krb5_buffer *result,
+			   gfp_t gfp)
+{
+	unsigned int blocksize, keybytes, keylength, n;
+	struct krb5_buffer inblock, outblock, rawkey;
+	struct crypto_sync_skcipher *cipher;
+	int ret = -EINVAL;
+
+	blocksize = krb5->block_len;
+	keybytes = krb5->key_bytes;
+	keylength = krb5->key_len;
+
+	if (inkey->len != keylength || result->len != keylength)
+		return -EINVAL;
+	if (!krb5->random_to_key && result->len != keybytes)
+		return -EINVAL;
+
+	cipher = crypto_alloc_sync_skcipher(krb5->derivation_enc, 0, 0);
+	if (IS_ERR(cipher)) {
+		ret = (PTR_ERR(cipher) == -ENOENT) ? -ENOPKG : PTR_ERR(cipher);
+		goto err_return;
+	}
+	ret = crypto_sync_skcipher_setkey(cipher, inkey->data, inkey->len);
+	if (ret < 0)
+		goto err_free_cipher;
+
+	ret = -ENOMEM;
+	inblock.data = kzalloc(blocksize * 2 + keybytes, gfp);
+	if (!inblock.data)
+		goto err_free_cipher;
+
+	inblock.len	= blocksize;
+	outblock.data	= inblock.data + blocksize;
+	outblock.len	= blocksize;
+	rawkey.data	= outblock.data + blocksize;
+	rawkey.len	= keybytes;
+
+	/* initialize the input block */
+
+	if (in_constant->len == inblock.len)
+		memcpy(inblock.data, in_constant->data, inblock.len);
+	else
+		rfc3961_nfold(in_constant, &inblock);
+
+	/* loop encrypting the blocks until enough key bytes are generated */
+	n = 0;
+	while (n < rawkey.len) {
+		rfc3961_do_encrypt(cipher, NULL, &inblock, &outblock);
+
+		if (keybytes - n <= outblock.len) {
+			memcpy(rawkey.data + n, outblock.data, keybytes - n);
+			break;
+		}
+
+		memcpy(rawkey.data + n, outblock.data, outblock.len);
+		memcpy(inblock.data, outblock.data, outblock.len);
+		n += outblock.len;
+	}
+
+	/* postprocess the key */
+	if (!krb5->random_to_key) {
+		/* Identity random-to-key function. */
+		memcpy(result->data, rawkey.data, rawkey.len);
+		ret = 0;
+	} else {
+		ret = krb5->random_to_key(krb5, &rawkey, result);
+	}
+
+	kfree_sensitive(inblock.data);
+err_free_cipher:
+	crypto_free_sync_skcipher(cipher);
+err_return:
+	return ret;
+}
+
+/*
+ * Calculate single encryption, E()
+ *
+ *	E(Key, octets)
+ */
+static int rfc3961_calc_E(const struct krb5_enctype *krb5,
+			  const struct krb5_buffer *key,
+			  const struct krb5_buffer *in_data,
+			  struct krb5_buffer *result,
+			  gfp_t gfp)
+{
+	struct crypto_sync_skcipher *cipher;
+	int ret;
+
+	cipher = crypto_alloc_sync_skcipher(krb5->derivation_enc, 0, 0);
+	if (IS_ERR(cipher)) {
+		ret = (PTR_ERR(cipher) == -ENOENT) ? -ENOPKG : PTR_ERR(cipher);
+		goto err;
+	}
+
+	ret = crypto_sync_skcipher_setkey(cipher, key->data, key->len);
+	if (ret < 0)
+		goto err_free;
+
+	ret = rfc3961_do_encrypt(cipher, NULL, in_data, result);
+
+err_free:
+	crypto_free_sync_skcipher(cipher);
+err:
+	return ret;
+}
+
+/*
+ * Calculate the pseudo-random function, PRF().
+ *
+ *      tmp1 = H(octet-string)
+ *      tmp2 = truncate tmp1 to multiple of m
+ *      PRF = E(DK(protocol-key, prfconstant), tmp2, initial-cipher-state)
+ *
+ *      The "prfconstant" used in the PRF operation is the three-octet string
+ *      "prf".
+ *      [rfc3961 sec 5.3]
+ */
+static int rfc3961_calc_PRF(const struct krb5_enctype *krb5,
+			    const struct krb5_buffer *protocol_key,
+			    const struct krb5_buffer *octet_string,
+			    struct krb5_buffer *result,
+			    gfp_t gfp)
+{
+	static const struct krb5_buffer prfconstant = { 3, "prf" };
+	struct krb5_buffer derived_key;
+	struct krb5_buffer tmp1, tmp2;
+	unsigned int m = krb5->block_len;
+	void *buffer;
+	int ret;
+
+	if (result->len != krb5->prf_len)
+		return -EINVAL;
+
+	tmp1.len = krb5->hash_len;
+	derived_key.len = krb5->key_bytes;
+	buffer = kzalloc(round16(tmp1.len) + round16(derived_key.len), gfp);
+	if (!buffer)
+		return -ENOMEM;
+
+	tmp1.data = buffer;
+	derived_key.data = buffer + round16(tmp1.len);
+
+	ret = rfc3961_calc_H(krb5, octet_string, &tmp1, gfp);
+	if (ret < 0)
+		goto err;
+
+	tmp2.len = tmp1.len & ~(m - 1);
+	tmp2.data = tmp1.data;
+
+	ret = rfc3961_calc_DK(krb5, protocol_key, &prfconstant, &derived_key, gfp);
+	if (ret < 0)
+		goto err;
+
+	ret = rfc3961_calc_E(krb5, &derived_key, &tmp2, result, gfp);
+
+err:
+	kfree_sensitive(buffer);
+	return ret;
+}
+
+const struct krb5_crypto_profile rfc3961_simplified_profile = {
+	.calc_PRF	= rfc3961_calc_PRF,
+	.calc_Kc	= rfc3961_calc_DK,
+	.calc_Ke	= rfc3961_calc_DK,
+	.calc_Ki	= rfc3961_calc_DK,
+};
-- 
2.50.1

