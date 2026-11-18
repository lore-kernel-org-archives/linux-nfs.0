Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002329;
	b=XjKaP7jmbcnMfG502h+Pamc67rqI1b3vZdmOXGwz8K4DP9grtMQ3Q3uOjyaLRTUpaUbj
	 TJV/9vbWQkCohcqg3SgbBGAcZj9m+3Mt8zMAWH4M/KCrFnwInDpMp8K29RZOoMU1onkC7
	 6JPRS6A06mWOOck/I6Wzr4+6C7xCvFP6JmOUrDGs9lEZk6LSn8foVvaEnmSgo2hyNEZyu
	 jp1LILwtOQUOFzDzPElC6ctPZT9KJliDQ/emyZTOCVgNjgJX8ZFmtqJIxioyrtRsZD8hL
	 nj6GyU53qCd0v0CvlnEJVHyKzD20vIxsREfeIwtaXnGetsfJ6/eCUQXkFfBUCTWFd1g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002329;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=gbp1mnilChcimpdz8fbHBnZHhJWpRYqIysYeawcQQUo=;
	b=fKTvsYHADlQWsmQCyQirNUIb7a5py9e34sGcH2xMu3lBARtfraGDojoS3s9r8sdU23hw
	 U/B74gUNdI/zNGsXAlm2ceh0IXpKIed8IaDHPnPDS1Tg6gvOTU0MXYickbxpE7sEyBEsD
	 oAa5snM9MPNgFyhNqmJuF7zPs3OsWIpE5mGdSHaRG13ESH+6nHWjtzJACEw0za19PZtPn
	 +kvdisOX41yTAAnoNd2vbMuqDdkysJhl0uf/JgaqMCz+n+xrp0phLzje6SBo91t6+haNT
	 DpUuiIfuZb3C0igyfHBtwk4Os+xSsM8X1k+9LsRzQ0TrayCoc88tPfMo/LrsBdpxopQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id C7E3E60A2627;
	Wed, 18 Nov 2026 11:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C7E3E60A2627
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id F068E2DF343; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 10/29] crypto/krb5: Implement the Kerberos5 rfc3961 get_mic and verify_mic
Date: Wed, 18 Nov 2026 14:44:59 +0300
Message-ID: <20261118114518.3605222-11-shaba@altlinux.org>
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

Add functions that sign and verify a message according to rfc3961 sec 5.4,
using Kc to generate a checksum and insert it into the MIC field in the
skbuff in the sign phase then checksum the data and compare it to the MIC
in the verify phase.

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
(cherry picked from commit 348f5669d1f6c1c210b9017ebb8b82282eca6f25)
---
 crypto/krb5/internal.h           |  10 +++
 crypto/krb5/rfc3961_simplified.c | 130 +++++++++++++++++++++++++++++++
 2 files changed, 140 insertions(+)

diff --git a/crypto/krb5/internal.h b/crypto/krb5/internal.h
index c8deb112b604..07a47ddf3ea9 100644
--- a/crypto/krb5/internal.h
+++ b/crypto/krb5/internal.h
@@ -169,3 +169,13 @@ int krb5_aead_decrypt(const struct krb5_enctype *krb5,
 		      struct crypto_aead *aead,
 		      struct scatterlist *sg, unsigned int nr_sg,
 		      size_t *_offset, size_t *_len);
+ssize_t rfc3961_get_mic(const struct krb5_enctype *krb5,
+			struct crypto_shash *shash,
+			const struct krb5_buffer *metadata,
+			struct scatterlist *sg, unsigned int nr_sg, size_t sg_len,
+			size_t data_offset, size_t data_len);
+int rfc3961_verify_mic(const struct krb5_enctype *krb5,
+		       struct crypto_shash *shash,
+		       const struct krb5_buffer *metadata,
+		       struct scatterlist *sg, unsigned int nr_sg,
+		       size_t *_offset, size_t *_len);
diff --git a/crypto/krb5/rfc3961_simplified.c b/crypto/krb5/rfc3961_simplified.c
index 58323ce5838a..c1dcb0dd3a00 100644
--- a/crypto/krb5/rfc3961_simplified.c
+++ b/crypto/krb5/rfc3961_simplified.c
@@ -653,6 +653,134 @@ int krb5_aead_decrypt(const struct krb5_enctype *krb5,
 	return ret;
 }
 
+/*
+ * Generate a checksum over some metadata and part of an skbuff and insert the
+ * MIC into the skbuff immediately prior to the data.
+ */
+ssize_t rfc3961_get_mic(const struct krb5_enctype *krb5,
+			struct crypto_shash *shash,
+			const struct krb5_buffer *metadata,
+			struct scatterlist *sg, unsigned int nr_sg, size_t sg_len,
+			size_t data_offset, size_t data_len)
+{
+	struct shash_desc *desc;
+	ssize_t ret, done;
+	size_t bsize;
+	void *buffer, *digest;
+
+	if (WARN_ON(data_offset != krb5->cksum_len))
+		return -EMSGSIZE;
+
+	bsize = krb5_shash_size(shash) +
+		krb5_digest_size(shash);
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
+
+	/* Calculate the MIC with key Kc and store it into the skb */
+	desc = buffer;
+	desc->tfm = shash;
+	ret = crypto_shash_init(desc);
+	if (ret < 0)
+		goto error;
+
+	if (metadata) {
+		ret = crypto_shash_update(desc, metadata->data, metadata->len);
+		if (ret < 0)
+			goto error;
+	}
+
+	ret = crypto_shash_update_sg(desc, sg, data_offset, data_len);
+	if (ret < 0)
+		goto error;
+
+	digest = buffer + krb5_shash_size(shash);
+	ret = crypto_shash_final(desc, digest);
+	if (ret < 0)
+		goto error;
+
+	ret = -EFAULT;
+	done = sg_pcopy_from_buffer(sg, nr_sg, digest, krb5->cksum_len,
+				    data_offset - krb5->cksum_len);
+	if (done != krb5->cksum_len)
+		goto error;
+
+	ret = krb5->cksum_len + data_len;
+
+error:
+	kfree_sensitive(buffer);
+	return ret;
+}
+
+/*
+ * Check the MIC on a region of an skbuff.  The offset and length are updated
+ * to reflect the actual content of the secure region.
+ */
+int rfc3961_verify_mic(const struct krb5_enctype *krb5,
+		       struct crypto_shash *shash,
+		       const struct krb5_buffer *metadata,
+		       struct scatterlist *sg, unsigned int nr_sg,
+		       size_t *_offset, size_t *_len)
+{
+	struct shash_desc *desc;
+	ssize_t done;
+	size_t bsize, data_offset, data_len, offset = *_offset, len = *_len;
+	void *buffer = NULL;
+	int ret;
+	u8 *cksum, *cksum2;
+
+	if (len < krb5->cksum_len)
+		return -EPROTO;
+	data_offset = offset + krb5->cksum_len;
+	data_len = len - krb5->cksum_len;
+
+	bsize = krb5_shash_size(shash) +
+		krb5_digest_size(shash) * 2;
+	buffer = kzalloc(bsize, GFP_NOFS);
+	if (!buffer)
+		return -ENOMEM;
+
+	cksum = buffer +
+		krb5_shash_size(shash);
+	cksum2 = buffer +
+		krb5_shash_size(shash) +
+		krb5_digest_size(shash);
+
+	/* Calculate the MIC */
+	desc = buffer;
+	desc->tfm = shash;
+	ret = crypto_shash_init(desc);
+	if (ret < 0)
+		goto error;
+
+	if (metadata) {
+		ret = crypto_shash_update(desc, metadata->data, metadata->len);
+		if (ret < 0)
+			goto error;
+	}
+
+	crypto_shash_update_sg(desc, sg, data_offset, data_len);
+	crypto_shash_final(desc, cksum);
+
+	ret = -EFAULT;
+	done = sg_pcopy_to_buffer(sg, nr_sg, cksum2, krb5->cksum_len, offset);
+	if (done != krb5->cksum_len)
+		goto error;
+
+	if (memcmp(cksum, cksum2, krb5->cksum_len) != 0) {
+		ret = -EBADMSG;
+		goto error;
+	}
+
+	*_offset += krb5->cksum_len;
+	*_len -= krb5->cksum_len;
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
@@ -664,4 +792,6 @@ const struct krb5_crypto_profile rfc3961_simplified_profile = {
 	.load_checksum_key	= rfc3961_load_checksum_key,
 	.encrypt		= krb5_aead_encrypt,
 	.decrypt		= krb5_aead_decrypt,
+	.get_mic		= rfc3961_get_mic,
+	.verify_mic		= rfc3961_verify_mic,
 };
-- 
2.50.1

