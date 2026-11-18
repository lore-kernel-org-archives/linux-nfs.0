Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002327;
	b=yec0r0KSWLMMjQzedbIV1yy/0YTLkoiwlEuvr7PA5Yat6zWs7buXe96bam9VbQ/K0ekw
	 rs1zj730HOF6t2xvMYj9Ltt52CPUKXMtP1Oljf/XkQ1NYCvwSCWgwqwqm6ivTVCNikull
	 BR3aLnp5hMoGS+w9dNvTGSKOD486fpIbIfC/G0s7jQZPvA/tUUOymozDvWs3Dxn2T6NTU
	 yiMjZX3ToPc+eis4tsfTIsXxcFNNPT+nnNyiKA4oEGLEaXwqnhesJQlc8vN0JGT1zSPOm
	 v7hntlR8JnTL3kVR0nwCWT1Pbcfh31xBHbjDKYXZ0oPRxlw8SWdZ1v01UogrBUVpQXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002327;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=d2YzJMGjD36BqLK6y+MeSoyRtWUtr/ZRkUuGKtqal7o=;
	b=loTIAof8Oed29YGgsizRMqZp0WWxSwQqgqfzGZOFxQUBaVLNGDs7FqWdkr1RmbLcA5BY
	 y0KUhxLQ3CofnTEJnuvIAwBBBRxCpSLRIf90sHdIu6AOjzuqxK7lPKjOzx++V0Pjyou3k
	 xhVGIkLWbp7zjnfPcOUdImTZhLT9N1LwuxdcayLFWyOIHgmyYpxA+qiBd6RaqC13YxoPL
	 HMVz8hDuLef+xDNKU9Oqf6ddtFT8RliX+uBUDI1QWpQ6c78VVHth5wMFlzwI04JY8zsFv
	 Vedf0m7RY6z5jZ9A+xx0dJlhnY7eYVHyWUbLEog3RAp/7spzcbPws760laJsMdlQhHg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 838C4606A32A;
	Wed, 18 Nov 2026 11:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 838C4606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id D05032DF331; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 01/29] crypto/krb5: Add some constants out of sunrpc headers
Date: Wed, 18 Nov 2026 14:44:50 +0300
Message-ID: <20261118114518.3605222-2-shaba@altlinux.org>
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

Add some constants from the sunrpc headers.

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
(cherry picked from commit 2ac92fedb6369a1a17ff995198b8e84ec0cf7a4e)
---
 include/crypto/krb5.h | 51 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)
 create mode 100644 include/crypto/krb5.h

diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
new file mode 100644
index 000000000000..44a6342471d7
--- /dev/null
+++ b/include/crypto/krb5.h
@@ -0,0 +1,51 @@
+/* SPDX-License-Identifier: GPL-2.0-or-later */
+/* Kerberos 5 crypto
+ *
+ * Copyright (C) 2025 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#ifndef _CRYPTO_KRB5_H
+#define _CRYPTO_KRB5_H
+
+/*
+ * Per Kerberos v5 protocol spec crypto types from the wire.  These get mapped
+ * to linux kernel crypto routines.
+ */
+#define KRB5_ENCTYPE_NULL			0x0000
+#define KRB5_ENCTYPE_DES_CBC_CRC		0x0001	/* DES cbc mode with CRC-32 */
+#define KRB5_ENCTYPE_DES_CBC_MD4		0x0002	/* DES cbc mode with RSA-MD4 */
+#define KRB5_ENCTYPE_DES_CBC_MD5		0x0003	/* DES cbc mode with RSA-MD5 */
+#define KRB5_ENCTYPE_DES_CBC_RAW		0x0004	/* DES cbc mode raw */
+/* XXX deprecated? */
+#define KRB5_ENCTYPE_DES3_CBC_SHA		0x0005	/* DES-3 cbc mode with NIST-SHA */
+#define KRB5_ENCTYPE_DES3_CBC_RAW		0x0006	/* DES-3 cbc mode raw */
+#define KRB5_ENCTYPE_DES_HMAC_SHA1		0x0008
+#define KRB5_ENCTYPE_DES3_CBC_SHA1		0x0010
+#define KRB5_ENCTYPE_AES128_CTS_HMAC_SHA1_96	0x0011
+#define KRB5_ENCTYPE_AES256_CTS_HMAC_SHA1_96	0x0012
+#define KRB5_ENCTYPE_ARCFOUR_HMAC		0x0017
+#define KRB5_ENCTYPE_ARCFOUR_HMAC_EXP		0x0018
+#define KRB5_ENCTYPE_UNKNOWN			0x01ff
+
+#define KRB5_CKSUMTYPE_CRC32			0x0001
+#define KRB5_CKSUMTYPE_RSA_MD4			0x0002
+#define KRB5_CKSUMTYPE_RSA_MD4_DES		0x0003
+#define KRB5_CKSUMTYPE_DESCBC			0x0004
+#define KRB5_CKSUMTYPE_RSA_MD5			0x0007
+#define KRB5_CKSUMTYPE_RSA_MD5_DES		0x0008
+#define KRB5_CKSUMTYPE_NIST_SHA			0x0009
+#define KRB5_CKSUMTYPE_HMAC_SHA1_DES3		0x000c
+#define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES128	0x000f
+#define KRB5_CKSUMTYPE_HMAC_SHA1_96_AES256	0x0010
+#define KRB5_CKSUMTYPE_HMAC_MD5_ARCFOUR		-138 /* Microsoft md5 hmac cksumtype */
+
+/*
+ * Constants used for key derivation
+ */
+/* from rfc3961 */
+#define KEY_USAGE_SEED_CHECKSUM         (0x99)
+#define KEY_USAGE_SEED_ENCRYPTION       (0xAA)
+#define KEY_USAGE_SEED_INTEGRITY        (0x55)
+
+#endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

