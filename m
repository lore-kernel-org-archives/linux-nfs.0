Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=kV1+jxpALKFxphSCpHuDP4UFMrzKEHZDfJf7fVJ23pCZhSqRNVFkdTKdqmxGbX6XNOET
	 2wM5Sxu8EGZUZtTuO/kiq0u2v8Rd7D+atIxHHL/LvGKGgPIYUoM2VvBmRb0m4WrRDZ39d
	 aYz/seva2gKF69CEyb2WTSJjhUpRCRxwVhtZcPXuRY1RHx8mPE2x6TRDt/l9z77gVXSum
	 DXjyfLAW84Y6zNU8JbVVRLcVJRAa6xCD/d5HbcP7KHmh7hppvhkDzrxlnw3/Ur3FksCPu
	 KtXPY6faSbqaAN+4S9yQZVF8jPbStpujhu0NO7Je+KDlMFivriPqksK7xhRfAF117UQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=S28adRf1oFbzkE6QXQDQ41sT8RTsMRp/NYXyPKCgYOc=;
	b=OzD+zjY6QJzLqzN7gqLmLjQW+CKoNIXxMGrXiHogH/qR5vfswNmUsuE/EuyBjWasfoqa
	 dT/tsO3mp8vS/1TTuznCUiegQYg/2Z9p0fS/asPCn1kMvKk4cZyx8aT+PU/LrM+jnOlr1
	 F1Mw5NgyzH7FpNJhxubA4GUzb7q+YUcRD38nAk/x2o9+iYXRDraxeIcGPAs9rZ8WuDr88
	 z51T/WgLiPedMmWawuENXkJAGINr7e/kuO2Gm0go/JAR2TpywANlzakBQ/ts6SURN53Fr
	 ynH24wHf9a/njmVhiGl3uTS8pAYreUiJ8Pqlvx2fn2fnIwLnZz6IXlWOzRMtY1XXp5g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id AC26C60A2620;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AC26C60A2620
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id E96A12DF33F; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 08/29] crypto/krb5: Provide RFC3961 setkey packaging functions
Date: Wed, 18 Nov 2026 14:44:57 +0300
Message-ID: <20261118114518.3605222-9-shaba@altlinux.org>
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

Provide functions to derive keys according to RFC3961 (or load the derived
keys for the selftester where only derived keys are available) and to
package them up appropriately for passing to a krb5enc AEAD setkey or a
hash setkey function.

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
(cherry picked from commit 8bcdbfa89f4fc1ab7b06e784cb9c3346a943955e)
---
 crypto/krb5/internal.h           |  20 +++++
 crypto/krb5/rfc3961_simplified.c | 122 ++++++++++++++++++++++++++++++-
 2 files changed, 138 insertions(+), 4 deletions(-)

diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index 7d60977dc0c5..ae00588619a8 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -136,3 +136,23 @@ int krb5_derive_Ki(const struct krb5_enctype *krb5, const struct krb5_buffer *TK
  * rfc3961_simplified.c
  */
 extern const struct krb5_crypto_profile rfc3961_simplified_profile;
+
+int authenc_derive_encrypt_keys(const struct krb5_enctype *krb5,
+				const struct krb5_buffer *TK,
+				unsigned int usage,
+				struct krb5_buffer *setkey,
+				gfp_t gfp);
+int authenc_load_encrypt_keys(const struct krb5_enctype *krb5,
+			      const struct krb5_buffer *Ke,
+			      const struct krb5_buffer *Ki,
+			      struct krb5_buffer *setkey,
+			      gfp_t gfp);
+int rfc3961_derive_checksum_key(const struct krb5_enctype *krb5,
+				const struct krb5_buffer *TK,
+				unsigned int usage,
+				struct krb5_buffer *setkey,
+				gfp_t gfp);
+int rfc3961_load_checksum_key(const struct krb5_enctype *krb5,
+			      const struct krb5_buffer *Kc,
+			      struct krb5_buffer *setkey,
+			      gfp_t gfp);
diff --git a/crypto/krb5/rfc3961_simplified.c b/crypto/krb5/rfc3961_simplified.c
index 75eafba059c7..335c5bb6904f 100644
--- a/crypto/krb5/rfc3961_simplified.c
+++ b/crypto/krb5/rfc3961_simplified.c
@@ -68,6 +68,8 @@
 
 #include <linux/slab.h>
 #include <linux/lcm.h>
+#include <linux/rtnetlink.h>
+#include <crypto/authenc.h>
 #include <crypto/skcipher.h>
 #include <crypto/hash.h>
 #include "internal.h"
@@ -399,9 +401,121 @@ static int rfc3961_calc_PRF(const struct krb5_enctype *krb5,
 	return ret;
 }
 
+/*
+ * Derive the Ke and Ki keys and package them into a key parameter that can be
+ * given to the setkey of a authenc AEAD crypto object.
+ */
+int authenc_derive_encrypt_keys(const struct krb5_enctype *krb5,
+				const struct krb5_buffer *TK,
+				unsigned int usage,
+				struct krb5_buffer *setkey,
+				gfp_t gfp)
+{
+	struct crypto_authenc_key_param *param;
+	struct krb5_buffer Ke, Ki;
+	struct rtattr *rta;
+	int ret;
+
+	Ke.len  = krb5->Ke_len;
+	Ki.len  = krb5->Ki_len;
+	setkey->len = RTA_LENGTH(sizeof(*param)) + Ke.len + Ki.len;
+	setkey->data = kzalloc(setkey->len, GFP_KERNEL);
+	if (!setkey->data)
+		return -ENOMEM;
+
+	rta = setkey->data;
+	rta->rta_type = CRYPTO_AUTHENC_KEYA_PARAM;
+	rta->rta_len = RTA_LENGTH(sizeof(*param));
+	param = RTA_DATA(rta);
+	param->enckeylen = htonl(Ke.len);
+
+	Ki.data = (void *)(param + 1);
+	Ke.data = Ki.data + Ki.len;
+
+	ret = krb5_derive_Ke(krb5, TK, usage, &Ke, gfp);
+	if (ret < 0) {
+		pr_err("get_Ke failed %d\n", ret);
+		return ret;
+	}
+	ret = krb5_derive_Ki(krb5, TK, usage, &Ki, gfp);
+	if (ret < 0)
+		pr_err("get_Ki failed %d\n", ret);
+	return ret;
+}
+
+/*
+ * Package predefined Ke and Ki keys and into a key parameter that can be given
+ * to the setkey of an authenc AEAD crypto object.
+ */
+int authenc_load_encrypt_keys(const struct krb5_enctype *krb5,
+			      const struct krb5_buffer *Ke,
+			      const struct krb5_buffer *Ki,
+			      struct krb5_buffer *setkey,
+			      gfp_t gfp)
+{
+	struct crypto_authenc_key_param *param;
+	struct rtattr *rta;
+
+	setkey->len = RTA_LENGTH(sizeof(*param)) + Ke->len + Ki->len;
+	setkey->data = kzalloc(setkey->len, GFP_KERNEL);
+	if (!setkey->data)
+		return -ENOMEM;
+
+	rta = setkey->data;
+	rta->rta_type = CRYPTO_AUTHENC_KEYA_PARAM;
+	rta->rta_len = RTA_LENGTH(sizeof(*param));
+	param = RTA_DATA(rta);
+	param->enckeylen = htonl(Ke->len);
+	memcpy((void *)(param + 1), Ki->data, Ki->len);
+	memcpy((void *)(param + 1) + Ki->len, Ke->data, Ke->len);
+	return 0;
+}
+
+/*
+ * Derive the Kc key for checksum-only mode and package it into a key parameter
+ * that can be given to the setkey of a hash crypto object.
+ */
+int rfc3961_derive_checksum_key(const struct krb5_enctype *krb5,
+				const struct krb5_buffer *TK,
+				unsigned int usage,
+				struct krb5_buffer *setkey,
+				gfp_t gfp)
+{
+	int ret;
+
+	setkey->len = krb5->Kc_len;
+	setkey->data = kzalloc(setkey->len, GFP_KERNEL);
+	if (!setkey->data)
+		return -ENOMEM;
+
+	ret = krb5_derive_Kc(krb5, TK, usage, setkey, gfp);
+	if (ret < 0)
+		pr_err("get_Kc failed %d\n", ret);
+	return ret;
+}
+
+/*
+ * Package a predefined Kc key for checksum-only mode into a key parameter that
+ * can be given to the setkey of a hash crypto object.
+ */
+int rfc3961_load_checksum_key(const struct krb5_enctype *krb5,
+			      const struct krb5_buffer *Kc,
+			      struct krb5_buffer *setkey,
+			      gfp_t gfp)
+{
+	setkey->len = krb5->Kc_len;
+	setkey->data = kmemdup(Kc->data, Kc->len, GFP_KERNEL);
+	if (!setkey->data)
+		return -ENOMEM;
+	return 0;
+}
 const struct krb5_crypto_profile rfc3961_simplified_profile = {
-	.calc_PRF	= rfc3961_calc_PRF,
-	.calc_Kc	= rfc3961_calc_DK,
-	.calc_Ke	= rfc3961_calc_DK,
-	.calc_Ki	= rfc3961_calc_DK,
+	.calc_PRF		= rfc3961_calc_PRF,
+	.calc_Kc		= rfc3961_calc_DK,
+	.calc_Ke		= rfc3961_calc_DK,
+	.calc_Ki		= rfc3961_calc_DK,
+	.derive_encrypt_keys	= authenc_derive_encrypt_keys,
+	.load_encrypt_keys	= authenc_load_encrypt_keys,
+	.derive_checksum_key	= rfc3961_derive_checksum_key,
+	.load_checksum_key	= rfc3961_load_checksum_key,
 };
-- 
2.50.1

