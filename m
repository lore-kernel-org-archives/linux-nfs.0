Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=L7ybL6ezROpSQrOZ09WBY1eGiZIbWHtmEKSceOXzJ0WqFifAeBInGICa/HcISZwnsl6F
	 tFCwwTAMXOZ3zjXAKAjJyQrHPJ+QS75S2sAsWoUXwLeaPZI0xegNISfSxQUA7rwZseSyx
	 6jzYPpGbLX6ppg6f73TsR93at4vV0owP9qRW84crwmWgT3qQkE+W5NNI/zZMUpTBlik67
	 zbJKv2isHFZPJCX4kSqEmcxzgpnHKVsabxMAJCYmsIO4RucXeY2RDxEx0Gvr6DpOgAD7x
	 VK0LH69MiXdFwjQ8IVRWcjTVMU/UzXlY0PTBSc8TDxI7ph4IL0NjCxRUHdgGwxSUrtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=57DCJfKKIZNpGAZHSpwLu7Su48SvUvq0fIMxihoe/y8=;
	b=JXzrXhyPqxVVC2h/hDaygBcxJR60Vpu36mK0tuv907VfK6R2oWtMaypW90i9neq+nnoK
	 bFjnjYS4tWLhij/mLyd91bXVap0tnsVcApOEntYDFBad8LqWQgUtFaW71FhG7dHM1+GPi
	 FLxEVKEt+ghpxjkyUCFVlMQVYXp59PGfk3HU4/zNVRc/aYp/XYRIJStodyUDe9ifkRyTY
	 bFWA09aEPxdLgmuToHDAWKHQtxx8gs1rckqjqkzJYG1vvXt4ZmS1yq/uElKPmI81bVimG
	 QydVdZM7/seSQNzoaha8yqFPcieIEc6jat8UoptiWqSB2TRESIU5mWHjw2+bSAcEzaw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id BF3F660A2623;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BF3F660A2623
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id EBE902DF341; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 09/29] crypto/krb5: Implement the Kerberos5 rfc3961 encrypt and decrypt functions
Date: Wed, 18 Nov 2026 14:44:58 +0300
Message-ID: <20261118114518.3605222-10-shaba@altlinux.org>
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

Add functions that encrypt and decrypt a message according to rfc3961 sec
5.3, using Ki to checksum the data to be secured and Ke to encrypt it
during the encryption phase, then decrypting with Ke and verifying the
checksum with Ki in the decryption phase.

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
(cherry picked from commit 00244da40f7821b242c4612428d4192230dba27f)
---
 crypto/krb5/internal.h           |  13 +++
 crypto/krb5/rfc3961_simplified.c | 146 +++++++++++++++++++++++++++++++
 2 files changed, 159 insertions(+)

diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index ae00588619a8..c8deb112b604 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -7,6 +7,8 @@
 
 #include <linux/scatterlist.h>
 #include <crypto/krb5.h>
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 
 /*
  * Profile used for key derivation and encryption.
@@ -137,6 +139,8 @@ int krb5_derive_Ki(const struct krb5_enctype *krb5, const struct krb5_buffer *TK
  */
 extern const struct krb5_crypto_profile rfc3961_simplified_profile;
 
+int crypto_shash_update_sg(struct shash_desc *desc, struct scatterlist *sg,
+			   size_t offset, size_t len);
 int authenc_derive_encrypt_keys(const struct krb5_enctype *krb5,
 				const struct krb5_buffer *TK,
 				unsigned int usage,
@@ -156,3 +160,12 @@ int rfc3961_load_checksum_key(const struct krb5_enctype *krb5,
 			      const struct krb5_buffer *Kc,
 			      struct krb5_buffer *setkey,
 			      gfp_t gfp);
+ssize_t krb5_aead_encrypt(const struct krb5_enctype *krb5,
+			  struct crypto_aead *aead,
+			  struct scatterlist *sg, unsigned int nr_sg, size_t sg_len,
+			  size_t data_offset, size_t data_len,
+			  bool preconfounded);
+int krb5_aead_decrypt(const struct krb5_enctype *krb5,
+		      struct crypto_aead *aead,
+		      struct scatterlist *sg, unsigned int nr_sg,
+		      size_t *_offset, size_t *_len);
diff --git a/crypto/krb5/rfc3961_simplified.c b/crypto/krb5/rfc3961_simplified.c
index 335c5bb6904f..58323ce5838a 100644
--- a/crypto/krb5/rfc3961_simplified.c
+++ b/crypto/krb5/rfc3961_simplified.c
@@ -66,7 +66,10 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/random.h>
+#include <linux/skbuff.h>
 #include <linux/slab.h>
+#include <linux/highmem.h>
 #include <linux/lcm.h>
 #include <linux/rtnetlink.h>
 #include <crypto/authenc.h>
@@ -77,6 +80,31 @@
 /* Maximum blocksize for the supported crypto algorithms */
 #define KRB5_MAX_BLOCKSIZE  (16)
 
+int crypto_shash_update_sg(struct shash_desc *desc, struct scatterlist *sg,
+			   size_t offset, size_t len)
+{
+	do {
+		int ret;
+
+		if (offset < sg->length) {
+			struct page *page = sg_page(sg);
+			void *p = kmap_local_page(page);
+			void *q = p + sg->offset + offset;
+			size_t seg = min_t(size_t, len, sg->length - offset);
+
+			ret = crypto_shash_update(desc, q, seg);
+			kunmap_local(p);
+			if (ret < 0)
+				return ret;
+			len -= seg;
+			offset = 0;
+		} else {
+			offset -= sg->length;
+		}
+	} while (len > 0 && (sg = sg_next(sg)));
+	return 0;
+}
+
 static int rfc3961_do_encrypt(struct crypto_sync_skcipher *tfm, void *iv,
 			      const struct krb5_buffer *in, struct krb5_buffer *out)
 {
@@ -509,6 +537,122 @@ int rfc3961_load_checksum_key(const struct krb5_enctype *krb5,
 		return -ENOMEM;
 	return 0;
 }
+
+/*
+ * Apply encryption and checksumming functions to part of a scatterlist.
+ */
+ssize_t krb5_aead_encrypt(const struct krb5_enctype *krb5,
+			  struct crypto_aead *aead,
+			  struct scatterlist *sg, unsigned int nr_sg, size_t sg_len,
+			  size_t data_offset, size_t data_len,
+			  bool preconfounded)
+{
+	struct aead_request *req;
+	ssize_t ret, done;
+	size_t bsize, base_len, secure_offset, secure_len, pad_len, cksum_offset;
+	void *buffer;
+	u8 *iv;
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
+		krb5_aead_ivsize(aead);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
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
+	/* Hash and encrypt the message. */
+	req = buffer;
+	iv = buffer + krb5_aead_size(aead);
+
+	aead_request_set_tfm(req, aead);
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_crypt(req, sg, sg, secure_len, iv);
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
+ * Apply decryption and checksumming functions to a message.  The offset and
+ * length are updated to reflect the actual content of the encrypted region.
+ */
+int krb5_aead_decrypt(const struct krb5_enctype *krb5,
+		      struct crypto_aead *aead,
+		      struct scatterlist *sg, unsigned int nr_sg,
+		      size_t *_offset, size_t *_len)
+{
+	struct aead_request *req;
+	size_t bsize;
+	void *buffer;
+	int ret;
+	u8 *iv;
+
+	if (WARN_ON(*_offset != 0))
+		return -EINVAL; /* Can't set offset on aead */
+
+	if (*_len < krb5->conf_len + krb5->cksum_len)
+		return -EPROTO;
+
+	bsize = krb5_aead_size(aead) +
+		krb5_aead_ivsize(aead);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
+
+	/* Decrypt the message and verify its checksum. */
+	req = buffer;
+	iv = buffer + krb5_aead_size(aead);
+
+	aead_request_set_tfm(req, aead);
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_crypt(req, sg, sg, *_len, iv);
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
 const struct krb5_crypto_profile rfc3961_simplified_profile = {
 	.calc_PRF		= rfc3961_calc_PRF,
 	.calc_Kc		= rfc3961_calc_DK,
@@ -518,4 +662,6 @@ const struct krb5_crypto_profile rfc3961_simplified_profile = {
 	.load_encrypt_keys	= authenc_load_encrypt_keys,
 	.derive_checksum_key	= rfc3961_derive_checksum_key,
 	.load_checksum_key	= rfc3961_load_checksum_key,
+	.encrypt		= krb5_aead_encrypt,
+	.decrypt		= krb5_aead_decrypt,
 };
-- 
2.50.1

