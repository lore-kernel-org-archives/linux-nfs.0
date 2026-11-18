Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002327;
	b=eBaYSVR5/lrM69+5nM7Cr231hcaG3+4f9/U7Cq/AhUJ0HUwxa5/hcwB2rlzaUnpux2bb
	 yJvauCYK52VvFhIheP9Z9QJLMMaHVghii8PBKDd0XAqLPuPFni1TO4XO5G1mZlCfVRhpg
	 QA1pG1WjmtijwxMgbjJFFoaya+An7xJCZBglvyrz9zs4mylnQAKCX/KzNw199X/pi1CtQ
	 DaELbUP0p4T2ieiAIrib7zmWXKWHyAfB0K0UaA4K9QXjrbFO/bNI51J//CAaj0rYmjO/f
	 +y9GF4nSOKqQsu/Y3Qmz0terVYY6E21vhppQeZ/tcjJJ+QoDla8m0L1Qnz1/uWdBSyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002327;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=SQchx3CaXGNfI45uXdKJrWSri9ZeI8DH+qpCjQS5SzY=;
	b=Ph3oRiiDNRrmGejV6oL9ZSh8r5t4kTTaoxMy1z3RoJx7HvSJEWEhyRTq+j4blAOanTLE
	 nucj1lzNj0rz45t439e73YvdotB2B9i43HxIjL/EAuRNpu/6KZ38CJ3rIfLaHkjNC/xWu
	 vr+DA14IA1DiSlTvWiWa3OKbmGGx2nRArqQ3mhjSVP8phrcEKgFeHSYjdb+xdGVGEQyq9
	 Yzka2PiQ/5HwssBQpQF8tbg02dnlyz+2N7TSjvCaTXAdduZ1wyxHnP0PZvUxvss3KemuR
	 YFNqpsZPXpivfmknU3iqSBnOtHNtU4/DP5e/HSMgQmg+Mk+NaoAGUqwIdnbH1rAaXoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 836F5606A31C;
	Wed, 18 Nov 2026 11:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 836F5606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id D3D382DF333; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 02/29] crypto/krb5: Implement Kerberos crypto core
Date: Wed, 18 Nov 2026 14:44:51 +0300
Message-ID: <20261118114518.3605222-3-shaba@altlinux.org>
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

Provide core structures, an encoding-type registry and basic module and
config bits for a generic Kerberos crypto library.

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
(cherry picked from commit 3936f02bf2d3308a7359dd37dd96cd60603d8170)
---
 crypto/Kconfig         |   1 +
 crypto/Makefile        |   2 +
 crypto/krb5/Kconfig    |  14 ++++++
 crypto/krb5/Makefile   |   9 ++++
 crypto/krb5/internal.h | 112 +++++++++++++++++++++++++++++++++++++++++
 crypto/krb5/krb5_api.c |  42 ++++++++++++++++
 include/crypto/krb5.h  |  54 ++++++++++++++++++++
 7 files changed, 234 insertions(+)
 create mode 100644 crypto/krb5/Kconfig
 create mode 100644 crypto/krb5/Makefile
 create mode 100644 crypto/krb5/internal.h
 create mode 100644 crypto/krb5/krb5_api.c

diff --git a/crypto/Kconfig b/crypto/Kconfig
index a997e97937e0..ee4f6e3f11ad 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -1477,5 +1477,6 @@ endif
 source "drivers/crypto/Kconfig"
 source "crypto/asymmetric_keys/Kconfig"
 source "certs/Kconfig"
+source "crypto/krb5/Kconfig"
 
 endif	# if CRYPTO
diff --git a/crypto/Makefile b/crypto/Makefile
index 6e9facde76a0..90744fec0b6c 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -213,3 +213,5 @@ obj-$(CONFIG_CRYPTO_SIMD) += crypto_simd.o
 # Key derivation function
 #
 obj-$(CONFIG_CRYPTO_KDF800108_CTR) += kdf_sp800108.o
+
+obj-$(CONFIG_CRYPTO_KRB5) += krb5/
diff --git a/crypto/krb5/Kconfig b/crypto/krb5/Kconfig
new file mode 100644
index 000000000000..079873618abf
--- /dev/null
+++ b/crypto/krb5/Kconfig
@@ -0,0 +1,14 @@
+config CRYPTO_KRB5
+	tristate "Kerberos 5 crypto"
+	select CRYPTO_MANAGER
+	select CRYPTO_KRB5ENC
+	select CRYPTO_AUTHENC
+	select CRYPTO_SKCIPHER
+	select CRYPTO_HASH_INFO
+	select CRYPTO_SHA1
+	select CRYPTO_CBC
+	select CRYPTO_CTS
+	select CRYPTO_AES
+	help
+	  Provide a library for provision of Kerberos-5-based crypto.  This is
+	  intended for network filesystems to use.
diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
new file mode 100644
index 000000000000..c450d0754772
--- /dev/null
+++ b/crypto/krb5/Makefile
@@ -0,0 +1,9 @@
+# SPDX-License-Identifier: GPL-2.0
+#
+# Makefile for asymmetric cryptographic keys
+#
+
+krb5-y += \
+	krb5_api.o
+
+obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
new file mode 100644
index 000000000000..3ede858be4f7
--- /dev/null
+++ b/crypto/krb5/internal.h
@@ -0,0 +1,112 @@
+/* SPDX-License-Identifier: GPL-2.0-or-later */
+/* Kerberos5 crypto internals
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#include <crypto/krb5.h>
+
+/*
+ * Profile used for key derivation and encryption.
+ */
+struct krb5_crypto_profile {
+	 /* Pseudo-random function */
+	int (*calc_PRF)(const struct krb5_enctype *krb5,
+			const struct krb5_buffer *protocol_key,
+			const struct krb5_buffer *octet_string,
+			struct krb5_buffer *result,
+			gfp_t gfp);
+
+	/* Checksum key derivation */
+	int (*calc_Kc)(const struct krb5_enctype *krb5,
+		       const struct krb5_buffer *TK,
+		       const struct krb5_buffer *usage_constant,
+		       struct krb5_buffer *Kc,
+		       gfp_t gfp);
+
+	/* Encryption key derivation */
+	int (*calc_Ke)(const struct krb5_enctype *krb5,
+		       const struct krb5_buffer *TK,
+		       const struct krb5_buffer *usage_constant,
+		       struct krb5_buffer *Ke,
+		       gfp_t gfp);
+
+	 /* Integrity key derivation */
+	int (*calc_Ki)(const struct krb5_enctype *krb5,
+		       const struct krb5_buffer *TK,
+		       const struct krb5_buffer *usage_constant,
+		       struct krb5_buffer *Ki,
+		       gfp_t gfp);
+
+	/* Derive the keys needed for an encryption AEAD object. */
+	int (*derive_encrypt_keys)(const struct krb5_enctype *krb5,
+				   const struct krb5_buffer *TK,
+				   unsigned int usage,
+				   struct krb5_buffer *setkey,
+				   gfp_t gfp);
+
+	/* Directly load the keys needed for an encryption AEAD object. */
+	int (*load_encrypt_keys)(const struct krb5_enctype *krb5,
+				 const struct krb5_buffer *Ke,
+				 const struct krb5_buffer *Ki,
+				 struct krb5_buffer *setkey,
+				 gfp_t gfp);
+
+	/* Derive the key needed for a checksum hash object. */
+	int (*derive_checksum_key)(const struct krb5_enctype *krb5,
+				   const struct krb5_buffer *TK,
+				   unsigned int usage,
+				   struct krb5_buffer *setkey,
+				   gfp_t gfp);
+
+	/* Directly load the keys needed for a checksum hash object. */
+	int (*load_checksum_key)(const struct krb5_enctype *krb5,
+				 const struct krb5_buffer *Kc,
+				 struct krb5_buffer *setkey,
+				 gfp_t gfp);
+
+	/* Encrypt data in-place, inserting confounder and checksum. */
+	ssize_t (*encrypt)(const struct krb5_enctype *krb5,
+			   struct crypto_aead *aead,
+			   struct scatterlist *sg, unsigned int nr_sg,
+			   size_t sg_len,
+			   size_t data_offset, size_t data_len,
+			   bool preconfounded);
+
+	/* Decrypt data in-place, removing confounder and checksum */
+	int (*decrypt)(const struct krb5_enctype *krb5,
+		       struct crypto_aead *aead,
+		       struct scatterlist *sg, unsigned int nr_sg,
+		       size_t *_offset, size_t *_len);
+
+	/* Generate a MIC on part of a packet, inserting the checksum */
+	ssize_t (*get_mic)(const struct krb5_enctype *krb5,
+			   struct crypto_shash *shash,
+			   const struct krb5_buffer *metadata,
+			   struct scatterlist *sg, unsigned int nr_sg,
+			   size_t sg_len,
+			   size_t data_offset, size_t data_len);
+
+	/* Verify the MIC on a piece of data, removing the checksum */
+	int (*verify_mic)(const struct krb5_enctype *krb5,
+			  struct crypto_shash *shash,
+			  const struct krb5_buffer *metadata,
+			  struct scatterlist *sg, unsigned int nr_sg,
+			  size_t *_offset, size_t *_len);
+};
+
+/*
+ * Crypto size/alignment rounding convenience macros.
+ */
+#define crypto_roundup(X) ((unsigned int)round_up((X), CRYPTO_MINALIGN))
+
+#define krb5_aead_size(TFM) \
+	crypto_roundup(sizeof(struct aead_request) + crypto_aead_reqsize(TFM))
+#define krb5_aead_ivsize(TFM) \
+	crypto_roundup(crypto_aead_ivsize(TFM))
+#define krb5_shash_size(TFM) \
+	crypto_roundup(sizeof(struct shash_desc) + crypto_shash_descsize(TFM))
+#define krb5_digest_size(TFM) \
+	crypto_roundup(crypto_shash_digestsize(TFM))
+#define round16(x) (((x) + 15) & ~15)
diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
new file mode 100644
index 000000000000..5c1cd5d07fc3
--- /dev/null
+++ b/crypto/krb5/krb5_api.c
@@ -0,0 +1,42 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/* Kerberos 5 crypto library.
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/export.h>
+#include <linux/kernel.h>
+#include "internal.h"
+
+MODULE_DESCRIPTION("Kerberos 5 crypto");
+MODULE_AUTHOR("Red Hat, Inc.");
+MODULE_LICENSE("GPL");
+
+static const struct krb5_enctype *const krb5_supported_enctypes[] = {
+};
+
+/**
+ * crypto_krb5_find_enctype - Find the handler for a Kerberos5 encryption type
+ * @enctype: The standard Kerberos encryption type number
+ *
+ * Look up a Kerberos encryption type by number.  If successful, returns a
+ * pointer to the type tables; returns NULL otherwise.
+ */
+const struct krb5_enctype *crypto_krb5_find_enctype(u32 enctype)
+{
+	const struct krb5_enctype *krb5;
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(krb5_supported_enctypes); i++) {
+		krb5 = krb5_supported_enctypes[i];
+		if (krb5->etype == enctype)
+			return krb5;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(crypto_krb5_find_enctype);
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index 44a6342471d7..8fa6715ab35b 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -8,6 +8,12 @@
 #ifndef _CRYPTO_KRB5_H
 #define _CRYPTO_KRB5_H
 
+#include <linux/crypto.h>
+#include <crypto/aead.h>
+
+struct crypto_shash;
+struct scatterlist;
+
 /*
  * Per Kerberos v5 protocol spec crypto types from the wire.  These get mapped
  * to linux kernel crypto routines.
@@ -48,4 +54,52 @@
 #define KEY_USAGE_SEED_ENCRYPTION       (0xAA)
 #define KEY_USAGE_SEED_INTEGRITY        (0x55)
 
+/*
+ * Mode of operation.
+ */
+enum krb5_crypto_mode {
+	KRB5_CHECKSUM_MODE,	/* Checksum only */
+	KRB5_ENCRYPT_MODE,	/* Fully encrypted, possibly with integrity checksum */
+};
+
+struct krb5_buffer {
+	unsigned int	len;
+	void		*data;
+};
+
+/*
+ * Kerberos encoding type definition.
+ */
+struct krb5_enctype {
+	int		etype;		/* Encryption (key) type */
+	int		ctype;		/* Checksum type */
+	const char	*name;		/* "Friendly" name */
+	const char	*encrypt_name;	/* Crypto encrypt+checksum name */
+	const char	*cksum_name;	/* Crypto checksum name */
+	const char	*hash_name;	/* Crypto hash name */
+	const char	*derivation_enc; /* Cipher used in key derivation */
+	u16		block_len;	/* Length of encryption block */
+	u16		conf_len;	/* Length of confounder (normally == block_len) */
+	u16		cksum_len;	/* Length of checksum */
+	u16		key_bytes;	/* Length of raw key, in bytes */
+	u16		key_len;	/* Length of final key, in bytes */
+	u16		hash_len;	/* Length of hash in bytes */
+	u16		prf_len;	/* Length of PRF() result in bytes */
+	u16		Kc_len;		/* Length of Kc in bytes */
+	u16		Ke_len;		/* Length of Ke in bytes */
+	u16		Ki_len;		/* Length of Ki in bytes */
+	bool		keyed_cksum;	/* T if a keyed cksum */
+
+	const struct krb5_crypto_profile *profile;
+
+	int (*random_to_key)(const struct krb5_enctype *krb5,
+			     const struct krb5_buffer *in,
+			     struct krb5_buffer *out);	/* complete key generation */
+};
+
+/*
+ * krb5_api.c
+ */
+const struct krb5_enctype *crypto_krb5_find_enctype(u32 enctype);
+
 #endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

