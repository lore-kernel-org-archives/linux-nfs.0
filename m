Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=Imn9XfA1rRgdGKstq1xhgs4vt5Lo4MWKIeJ7ylR3z0UyPGONZGSw9cbX17dP7IHteIA7
	 kuD3Qc+tPPtDod5Emil8ADgipLRday1ipAVSmiTOIfsfmcRlLMN9O8fP2iYU95T+hPcLl
	 rHF7qgXRL1msl/e71KMVMPmpe2GLXAIz6arJDLABEc9BbiWTGNo+tjm+qcX8tiE5IFX7r
	 LAAO7VxKKxQO0qPXRPHxnjqGfvjuzZbK8EuqSs3ODrdZJVPEur7KH4/uZG8awwBxOzhy7
	 XOhrU7Pf5sM0akf03af3VXAIJj+FN+2wE3qIyFL1KZaMIh75tfKgIO4s0CADQ1mkLsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=tc5ZdEvcuXQuXynPAUFr9RDALnggzL7BTBT5IgSsgJE=;
	b=Btdnvn/ZpJK+L2fl6uw4mm4RzyAJqIE3W8SpuaROrQpsRP3/OV7up4QKu7K3J4Jlb05n
	 unLiaWHxbBEMmEzWUQ3dkWo1hid2piqiD3oP8ruSWgt1vC543+DQCmPModNTc3CEfioAA
	 SlOv5XFGUsG4jgEGu9cybMHvj6w1fA2K3nZ3XjPpsbsNzwOnmZzvTQ9fCsefdclR6NA2v
	 TBh8i1np6HGbyMqy3auszkoLbcTTCSjzRptf9MDksJszo7TVltTTy8+CBTK5ubyNLbT3V
	 vQ3MQwZJNqgXbx4jQF9ZtG1zi/Zl+LwmGQYNC8wEtU5rUkBOkJP9vYStBTz2LLko6Zg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id BF41560A2624;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BF41560A2624
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id F401B2DF345; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 11/29] crypto/krb5: Implement the AES enctypes from rfc3962
Date: Wed, 18 Nov 2026 14:45:00 +0300
Message-ID: <20261118114518.3605222-12-shaba@altlinux.org>
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

Implement the aes128-cts-hmac-sha1-96 and aes256-cts-hmac-sha1-96 enctypes
from rfc3962, using the rfc3961 kerberos 5 simplified crypto scheme.

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
(cherry picked from commit 7c164b66b276c49b3888d3280e1b70a85732a38c)
---
 crypto/krb5/Kconfig       |   1 +
 crypto/krb5/Makefile      |   3 +-
 crypto/krb5/internal.h    |   6 ++
 crypto/krb5/krb5_api.c    |   2 +
 crypto/krb5/rfc3962_aes.c | 115 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 126 insertions(+), 1 deletion(-)
 create mode 100644 crypto/krb5/rfc3962_aes.c

diff --git a/crypto/krb5/Kconfig b/crypto/krb5/Kconfig
index 079873618abf..2ad874990dc8 100644
--- a/crypto/krb5/Kconfig
+++ b/crypto/krb5/Kconfig
@@ -5,6 +5,7 @@ config CRYPTO_KRB5
 	select CRYPTO_AUTHENC
 	select CRYPTO_SKCIPHER
 	select CRYPTO_HASH_INFO
+	select CRYPTO_HMAC
 	select CRYPTO_SHA1
 	select CRYPTO_CBC
 	select CRYPTO_CTS
diff --git a/crypto/krb5/Makefile b/crypto/krb5/Makefile
index 8dad8e3bf086..35f21411abf8 100644
--- a/crypto/krb5/Makefile
+++ b/crypto/krb5/Makefile
@@ -6,6 +6,7 @@
 krb5-y += \
 	krb5_kdf.o \
 	krb5_api.o \
-	rfc3961_simplified.o
+	rfc3961_simplified.o \
+	rfc3962_aes.o
 
 obj-$(CONFIG_CRYPTO_KRB5) += krb5.o
diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index 07a47ddf3ea9..43f904a69e32 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -179,3 +179,9 @@ int rfc3961_verify_mic(const struct krb5_enctype *krb5,
 		       const struct krb5_buffer *metadata,
 		       struct scatterlist *sg, unsigned int nr_sg,
 		       size_t *_offset, size_t *_len);
+
+/*
+ * rfc3962_aes.c
+ */
+extern const struct krb5_enctype krb5_aes128_cts_hmac_sha1_96;
+extern const struct krb5_enctype krb5_aes256_cts_hmac_sha1_96;
diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index 8fc3a1b9d4ad..ecc6655953d5 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -17,6 +17,8 @@ MODULE_AUTHOR("Red Hat, Inc.");
 MODULE_LICENSE("GPL");
 
 static const struct krb5_enctype *const krb5_supported_enctypes[] = {
+	&krb5_aes128_cts_hmac_sha1_96,
+	&krb5_aes256_cts_hmac_sha1_96,
 };
 
 /**
diff --git a/crypto/krb5/rfc3962_aes.c b/crypto/krb5/rfc3962_aes.c
new file mode 100644
index 000000000000..5cbf8f4638b9
--- /dev/null
+++ b/crypto/krb5/rfc3962_aes.c
@@ -0,0 +1,115 @@
+// SPDX-License-Identifier: BSD-3-Clause
+/* rfc3962 Advanced Encryption Standard (AES) Encryption for Kerberos 5
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
+#include "internal.h"
+
+const struct krb5_enctype krb5_aes128_cts_hmac_sha1_96 = {
+	.etype		= KRB5_ENCTYPE_AES128_CTS_HMAC_SHA1_96,
+	.ctype		= KRB5_CKSUMTYPE_HMAC_SHA1_96_AES128,
+	.name		= "aes128-cts-hmac-sha1-96",
+	.encrypt_name	= "krb5enc(hmac(sha1),cts(cbc(aes)))",
+	.cksum_name	= "hmac(sha1)",
+	.hash_name	= "sha1",
+	.derivation_enc	= "cts(cbc(aes))",
+	.key_bytes	= 16,
+	.key_len	= 16,
+	.Kc_len		= 16,
+	.Ke_len		= 16,
+	.Ki_len		= 16,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 12,
+	.hash_len	= 20,
+	.prf_len	= 16,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc3961_simplified_profile,
+};
+
+const struct krb5_enctype krb5_aes256_cts_hmac_sha1_96 = {
+	.etype		= KRB5_ENCTYPE_AES256_CTS_HMAC_SHA1_96,
+	.ctype		= KRB5_CKSUMTYPE_HMAC_SHA1_96_AES256,
+	.name		= "aes256-cts-hmac-sha1-96",
+	.encrypt_name	= "krb5enc(hmac(sha1),cts(cbc(aes)))",
+	.cksum_name	= "hmac(sha1)",
+	.hash_name	= "sha1",
+	.derivation_enc	= "cts(cbc(aes))",
+	.key_bytes	= 32,
+	.key_len	= 32,
+	.Kc_len		= 32,
+	.Ke_len		= 32,
+	.Ki_len		= 32,
+	.block_len	= 16,
+	.conf_len	= 16,
+	.cksum_len	= 12,
+	.hash_len	= 20,
+	.prf_len	= 16,
+	.keyed_cksum	= true,
+	.random_to_key	= NULL, /* Identity */
+	.profile	= &rfc3961_simplified_profile,
+};
-- 
2.50.1

