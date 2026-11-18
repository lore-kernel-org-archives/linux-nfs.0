Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002330;
	b=GF0LS0b4X/7V0muzFyTHK6+3Roter0YaaHVdjUbNPCqwFPd96Y7ZtLFAsSuYAAvV/eRa
	 RrfRqNEmNipuYAbyZUGMx/Ik6AAQMrQaHMLmY+bDZdwjpfAbF0Gpn0ceH/LEFxJZQYMzf
	 Be9+cp/IBzh+QeNe/LBlpOIFd9gA8fnZ3gDZj2ROEf5StOdjiUBSuI8rhiKnnSezRz1ml
	 NmVRF2DJPWb2przV3SyUpkFlYKAgKOCsRwAqUja96HVg361M5fusLlaNvlpAKsVLuJG21
	 ieP8CM3hCY4xZTD6EL1qljtSVr7+2no5dbiJgJyuFQnX6zt8dCsP2gxkRfGigKGoqNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002330;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5+zRAV2ghz3Vb4oBlRxta2l5gRkluLNZaNT+jS91sEI=;
	b=x9LTcGBpLq1EJRLbG4slXwhL6Marj0X/Z6WuxJVRENm03OQHVNj4iS9Cg3Z50KKHth2V
	 nGPZrFmDlQg7sn/CfaWjDOvUcqmZntNmoYlsimLtIi4VquLk5h9/gq8KzqSZiDFK691Io
	 RJbZf7NPAFkcDCq65xmrWB4VnOb3t38xEBNTwuh95JyqtgryoXPRvQ1SE4qinfgSgTpz4
	 dDG/PEKdjcZd6BYVbMuapnTvH5scqIGhjoCuxkHfo7rE4c0bcoeSV5FRRgNz7mZX+RLfX
	 VAvfcKBVLNdN7EoJ+yx1WGmxUake6Tkkt7HMb5V4HIVIZTtaKIarIk2okGkoOpi2ISw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id BF45A60A2625;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BF45A60A2625
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id E22462DF33B; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 06/29] crypto/krb5: Provide infrastructure and key derivation
Date: Wed, 18 Nov 2026 14:44:55 +0300
Message-ID: <20261118114518.3605222-7-shaba@altlinux.org>
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

Provide key derivation interface functions and a helper to implement the
PRF+ function from rfc4402.

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
(cherry picked from commit 41cf1d1e8a86c5c675982136f07c519c4b15b157)
---
 crypto/krb5/Makefile   |   1 +
 crypto/krb5/internal.h |  10 +++
 crypto/krb5/krb5_kdf.c | 145 +++++++++++++++++++++++++++++++++++++++++
 include/crypto/krb5.h  |  10 +++
 4 files changed, 166 insertions(+)
 create mode 100644 crypto/krb5/krb5_kdf.c

diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
index c450d0754772..8c2050af8fed 100644
--- a/crypto/krb5/Makefile
+++ b/crypto/krb5/Makefile
@@ -4,6 +4,7 @@
 #
 
 krb5-y += \
+	krb5_kdf.o \
 	krb5_api.o
 
 obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index b542d24e5fa5..50abda5169c7 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -120,3 +120,13 @@ struct crypto_aead *krb5_prepare_encryption(const struct krb5_enctype *krb5,
 struct crypto_shash *krb5_prepare_checksum(const struct krb5_enctype *krb5,
 					   const struct krb5_buffer *Kc,
 					   gfp_t gfp);
+
+/*
+ * krb5_kdf.c
+ */
+int krb5_derive_Kc(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp);
+int krb5_derive_Ke(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp);
+int krb5_derive_Ki(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp);
diff --git a/crypto/krb5/krb5_kdf.c b/crypto/krb5/krb5_kdf.c
new file mode 100644
index 000000000000..6699e5469d1b
--- /dev/null
+++ b/crypto/krb5/krb5_kdf.c
@@ -0,0 +1,145 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/* Kerberos key derivation.
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/export.h>
+#include <linux/slab.h>
+#include <crypto/skcipher.h>
+#include <crypto/hash.h>
+#include "internal.h"
+
+/**
+ * crypto_krb5_calc_PRFplus - Calculate PRF+ [RFC4402]
+ * @krb5: The encryption type to use
+ * @K: The protocol key for the pseudo-random function
+ * @L: The length of the output
+ * @S: The input octet string
+ * @result: Result buffer, sized to krb5->prf_len
+ * @gfp: Allocation restrictions
+ *
+ * Calculate the kerberos pseudo-random function, PRF+() by the following
+ * method:
+ *
+ *      PRF+(K, L, S) = truncate(L, T1 || T2 || .. || Tn)
+ *      Tn = PRF(K, n || S)
+ *      [rfc4402 sec 2]
+ */
+int crypto_krb5_calc_PRFplus(const struct krb5_enctype *krb5,
+			     const struct krb5_buffer *K,
+			     unsigned int L,
+			     const struct krb5_buffer *S,
+			     struct krb5_buffer *result,
+			     gfp_t gfp)
+{
+	struct krb5_buffer T_series, Tn, n_S;
+	void *buffer;
+	int ret, n = 1;
+
+	Tn.len = krb5->prf_len;
+	T_series.len = 0;
+	n_S.len = 4 + S->len;
+
+	buffer = kzalloc(round16(L + Tn.len) + round16(n_S.len), gfp);
+	if (!buffer)
+		return -ENOMEM;
+
+	T_series.data = buffer;
+	n_S.data = buffer + round16(L + Tn.len);
+	memcpy(n_S.data + 4, S->data, S->len);
+
+	while (T_series.len < L) {
+		*(__be32 *)(n_S.data) = htonl(n);
+		Tn.data = T_series.data + Tn.len * (n - 1);
+		ret = krb5->profile->calc_PRF(krb5, K, &n_S, &Tn, gfp);
+		if (ret < 0)
+			goto err;
+		T_series.len += Tn.len;
+		n++;
+	}
+
+	/* Truncate to L */
+	memcpy(result->data, T_series.data, L);
+	ret = 0;
+
+err:
+	kfree_sensitive(buffer);
+	return ret;
+}
+EXPORT_SYMBOL(crypto_krb5_calc_PRFplus);
+
+/**
+ * krb5_derive_Kc - Derive key Kc and install into a hash
+ * @krb5: The encryption type to use
+ * @TK: The base key
+ * @usage: The key usage number
+ * @key: Prepped buffer to store the key into
+ * @gfp: Allocation restrictions
+ *
+ * Derive the Kerberos Kc checksumming key.  The key is stored into the
+ * prepared buffer.
+ */
+int krb5_derive_Kc(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp)
+{
+	u8 buf[5] __aligned(CRYPTO_MINALIGN);
+	struct krb5_buffer usage_constant = { .len = 5, .data = buf };
+
+	*(__be32 *)buf = cpu_to_be32(usage);
+	buf[4] = KEY_USAGE_SEED_CHECKSUM;
+
+	key->len = krb5->Kc_len;
+	return krb5->profile->calc_Kc(krb5, TK, &usage_constant, key, gfp);
+}
+
+/**
+ * krb5_derive_Ke - Derive key Ke and install into an skcipher
+ * @krb5: The encryption type to use
+ * @TK: The base key
+ * @usage: The key usage number
+ * @key: Prepped buffer to store the key into
+ * @gfp: Allocation restrictions
+ *
+ * Derive the Kerberos Ke encryption key.  The key is stored into the prepared
+ * buffer.
+ */
+int krb5_derive_Ke(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp)
+{
+	u8 buf[5] __aligned(CRYPTO_MINALIGN);
+	struct krb5_buffer usage_constant = { .len = 5, .data = buf };
+
+	*(__be32 *)buf = cpu_to_be32(usage);
+	buf[4] = KEY_USAGE_SEED_ENCRYPTION;
+
+	key->len = krb5->Ke_len;
+	return krb5->profile->calc_Ke(krb5, TK, &usage_constant, key, gfp);
+}
+
+/**
+ * krb5_derive_Ki - Derive key Ki and install into a hash
+ * @krb5: The encryption type to use
+ * @TK: The base key
+ * @usage: The key usage number
+ * @key: Prepped buffer to store the key into
+ * @gfp: Allocation restrictions
+ *
+ * Derive the Kerberos Ki integrity checksum key.  The key is stored into the
+ * prepared buffer.
+ */
+int krb5_derive_Ki(const struct krb5_enctype *krb5, const struct krb5_buffer *TK,
+		   u32 usage, struct krb5_buffer *key, gfp_t gfp)
+{
+	u8 buf[5] __aligned(CRYPTO_MINALIGN);
+	struct krb5_buffer usage_constant = { .len = 5, .data = buf };
+
+	*(__be32 *)buf = cpu_to_be32(usage);
+	buf[4] = KEY_USAGE_SEED_INTEGRITY;
+
+	key->len = krb5->Ki_len;
+	return krb5->profile->calc_Ki(krb5, TK, &usage_constant, key, gfp);
+}
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index 81739e9828d3..b12f012cf354 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -139,4 +139,14 @@ int crypto_krb5_verify_mic(const struct krb5_enctype *krb5,
 			   struct scatterlist *sg, unsigned int nr_sg,
 			   size_t *_offset, size_t *_len);
 
+/*
+ * krb5_kdf.c
+ */
+int crypto_krb5_calc_PRFplus(const struct krb5_enctype *krb5,
+			     const struct krb5_buffer *K,
+			     unsigned int L,
+			     const struct krb5_buffer *S,
+			     struct krb5_buffer *result,
+			     gfp_t gfp);
+
 #endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

