Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002328;
	b=vplznaVJe6jJFoFMeXzt+nCy43LzdyugNMeb4OHPl2BayPo5iwoy53H070hMRW17krRw
	 zc8GavvhTO/Xk4OBOw7oGwAjCSC8ywPK3KPFVJtZphDl7F3xitcZK3Ix7j07+gOwzmN4Y
	 JdYTUqVuKacm7HXmO85CaOzr/3OkJMuoNhThvThFxZ5ZE1XZgPCzRVjbpaHzmJgsv0GP9
	 PIiY1CEMlTUKLYwp1/z3eBCYFwAFiNY0wzJlUxkFdHVyDStgohA9zz+JkbFtzhXVSBP8Q
	 6qyDtsrBx9ufK6iWzbLydu3swOHX83tR6aKsHFNGsWOWyVKQUuV1QilCUePBlTCoscQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002328;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=eEEYHofTJddEyOiZB5wjpRaqUZPqyp1VwwRDUW9Lw0U=;
	b=0q3I91vBWQgXN7uZnHLk9qGPQUHemFpXvEk4B6VbtWj4ileJkSsyTYjmPVB8VPim87mO
	 qTd04HlgEY6B1/MfdxqaNMafWbkMh8vXUbZBxTaT2ma0awCo2VYBrqM8XGyF2lboO8/Nc
	 XgB/kFev1xd0BAMfpbY7yFmVpL3w3Urr3c+kZ4DLW+DQoifJ6rQ3p8OubB0DukVygZzno
	 NkTuZKOtmDRC/4TNum4KJezR1+PBxw8v/d/X6LMmnUMCrY5fC2+2aovu65IV8qnWxyCPO
	 d54pT/D3zx/5qghQhTv90H857+cODzrhW6+2ZfFaSIixE04iVpTPTbMDHbbqalJ8Ogw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 83799606A325;
	Wed, 18 Nov 2026 11:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 83799606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id DE8412DF339; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 05/29] crypto/krb5: Add an API to perform requests
Date: Wed, 18 Nov 2026 14:44:54 +0300
Message-ID: <20261118114518.3605222-6-shaba@altlinux.org>
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

Add an API by which users of the krb5 crypto library can perform crypto
requests, such as encrypt, decrypt, get_mic and verify_mic.  These
functions take the previously prepared crypto objects to work on.

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
(cherry picked from commit 0392b110ccaf543b31842b04c8142f4f8ce7bdec)
---
 crypto/krb5/krb5_api.c | 141 +++++++++++++++++++++++++++++++++++++++++
 include/crypto/krb5.h  |  21 ++++++
 2 files changed, 162 insertions(+)

diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index f7f2528b3895..8fc3a1b9d4ad 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -292,3 +292,144 @@ struct crypto_shash *crypto_krb5_prepare_checksum(const struct krb5_enctype *krb
 	return ERR_PTR(ret);
 }
 EXPORT_SYMBOL(crypto_krb5_prepare_checksum);
+
+/**
+ * crypto_krb5_encrypt - Apply Kerberos encryption and integrity.
+ * @krb5: The encoding to use.
+ * @aead: The keyed crypto object to use.
+ * @sg: Scatterlist defining the crypto buffer.
+ * @nr_sg: The number of elements in @sg.
+ * @sg_len: The size of the buffer.
+ * @data_offset: The offset of the data in the @sg buffer.
+ * @data_len: The length of the data.
+ * @preconfounded: True if the confounder is already inserted.
+ *
+ * Using the specified Kerberos encoding, insert a confounder and padding as
+ * needed, encrypt this and the data in place and insert an integrity checksum
+ * into the buffer.
+ *
+ * The buffer must include space for the confounder, the checksum and any
+ * padding required.  The caller can preinsert the confounder into the buffer
+ * (for testing, for example).
+ *
+ * The resulting secured blob may be less than the size of the buffer.
+ *
+ * Returns the size of the secure blob if successful, -ENOMEM on an allocation
+ * failure, -EFAULT if there is insufficient space, -EMSGSIZE if the confounder
+ * is too short or the data is misaligned.  Other errors may also be returned
+ * from the crypto layer.
+ */
+ssize_t crypto_krb5_encrypt(const struct krb5_enctype *krb5,
+			    struct crypto_aead *aead,
+			    struct scatterlist *sg, unsigned int nr_sg,
+			    size_t sg_len,
+			    size_t data_offset, size_t data_len,
+			    bool preconfounded)
+{
+	if (WARN_ON(data_offset > sg_len ||
+		    data_len > sg_len ||
+		    data_offset > sg_len - data_len))
+		return -EMSGSIZE;
+	return krb5->profile->encrypt(krb5, aead, sg, nr_sg, sg_len,
+				      data_offset, data_len, preconfounded);
+}
+EXPORT_SYMBOL(crypto_krb5_encrypt);
+
+/**
+ * crypto_krb5_decrypt - Validate and remove Kerberos encryption and integrity.
+ * @krb5: The encoding to use.
+ * @aead: The keyed crypto object to use.
+ * @sg: Scatterlist defining the crypto buffer.
+ * @nr_sg: The number of elements in @sg.
+ * @_offset: Offset of the secure blob in the buffer; updated to data offset.
+ * @_len: The length of the secure blob; updated to data length.
+ *
+ * Using the specified Kerberos encoding, check and remove the integrity
+ * checksum and decrypt the secure region, stripping off the confounder.
+ *
+ * If successful, @_offset and @_len are updated to outline the region in which
+ * the data plus the trailing padding are stored.  The caller is responsible
+ * for working out how much padding there is and removing it.
+ *
+ * Returns the 0 if successful, -ENOMEM on an allocation failure; sets
+ * *_error_code and returns -EPROTO if the data cannot be parsed, or -EBADMSG
+ * if the integrity checksum doesn't match).  Other errors may also be returned
+ * from the crypto layer.
+ */
+int crypto_krb5_decrypt(const struct krb5_enctype *krb5,
+			struct crypto_aead *aead,
+			struct scatterlist *sg, unsigned int nr_sg,
+			size_t *_offset, size_t *_len)
+{
+	return krb5->profile->decrypt(krb5, aead, sg, nr_sg, _offset, _len);
+}
+EXPORT_SYMBOL(crypto_krb5_decrypt);
+
+/**
+ * crypto_krb5_get_mic - Apply Kerberos integrity checksum.
+ * @krb5: The encoding to use.
+ * @shash: The keyed hash to use.
+ * @metadata: Metadata to add into the hash before adding the data.
+ * @sg: Scatterlist defining the crypto buffer.
+ * @nr_sg: The number of elements in @sg.
+ * @sg_len: The size of the buffer.
+ * @data_offset: The offset of the data in the @sg buffer.
+ * @data_len: The length of the data.
+ *
+ * Using the specified Kerberos encoding, calculate and insert an integrity
+ * checksum into the buffer.
+ *
+ * The buffer must include space for the checksum at the front.
+ *
+ * Returns the size of the secure blob if successful, -ENOMEM on an allocation
+ * failure, -EFAULT if there is insufficient space, -EMSGSIZE if the gap for
+ * the checksum is too short.  Other errors may also be returned from the
+ * crypto layer.
+ */
+ssize_t crypto_krb5_get_mic(const struct krb5_enctype *krb5,
+			    struct crypto_shash *shash,
+			    const struct krb5_buffer *metadata,
+			    struct scatterlist *sg, unsigned int nr_sg,
+			    size_t sg_len,
+			    size_t data_offset, size_t data_len)
+{
+	if (WARN_ON(data_offset > sg_len ||
+		    data_len > sg_len ||
+		    data_offset > sg_len - data_len))
+		return -EMSGSIZE;
+	return krb5->profile->get_mic(krb5, shash, metadata, sg, nr_sg, sg_len,
+				      data_offset, data_len);
+}
+EXPORT_SYMBOL(crypto_krb5_get_mic);
+
+/**
+ * crypto_krb5_verify_mic - Validate and remove Kerberos integrity checksum.
+ * @krb5: The encoding to use.
+ * @shash: The keyed hash to use.
+ * @metadata: Metadata to add into the hash before adding the data.
+ * @sg: Scatterlist defining the crypto buffer.
+ * @nr_sg: The number of elements in @sg.
+ * @_offset: Offset of the secure blob in the buffer; updated to data offset.
+ * @_len: The length of the secure blob; updated to data length.
+ *
+ * Using the specified Kerberos encoding, check and remove the integrity
+ * checksum.
+ *
+ * If successful, @_offset and @_len are updated to outline the region in which
+ * the data is stored.
+ *
+ * Returns the 0 if successful, -ENOMEM on an allocation failure; sets
+ * *_error_code and returns -EPROTO if the data cannot be parsed, or -EBADMSG
+ * if the checksum doesn't match).  Other errors may also be returned from the
+ * crypto layer.
+ */
+int crypto_krb5_verify_mic(const struct krb5_enctype *krb5,
+			   struct crypto_shash *shash,
+			   const struct krb5_buffer *metadata,
+			   struct scatterlist *sg, unsigned int nr_sg,
+			   size_t *_offset, size_t *_len)
+{
+	return krb5->profile->verify_mic(krb5, shash, metadata, sg, nr_sg,
+					 _offset, _len);
+}
+EXPORT_SYMBOL(crypto_krb5_verify_mic);
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index 94af2c558fa1..81739e9828d3 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -117,5 +117,26 @@ struct crypto_aead *crypto_krb5_prepare_encryption(const struct krb5_enctype *kr
 struct crypto_shash *crypto_krb5_prepare_checksum(const struct krb5_enctype *krb5,
 						  const struct krb5_buffer *TK,
 						  u32 usage, gfp_t gfp);
+ssize_t crypto_krb5_encrypt(const struct krb5_enctype *krb5,
+			    struct crypto_aead *aead,
+			    struct scatterlist *sg, unsigned int nr_sg,
+			    size_t sg_len,
+			    size_t data_offset, size_t data_len,
+			    bool preconfounded);
+int crypto_krb5_decrypt(const struct krb5_enctype *krb5,
+			struct crypto_aead *aead,
+			struct scatterlist *sg, unsigned int nr_sg,
+			size_t *_offset, size_t *_len);
+ssize_t crypto_krb5_get_mic(const struct krb5_enctype *krb5,
+			    struct crypto_shash *shash,
+			    const struct krb5_buffer *metadata,
+			    struct scatterlist *sg, unsigned int nr_sg,
+			    size_t sg_len,
+			    size_t data_offset, size_t data_len);
+int crypto_krb5_verify_mic(const struct krb5_enctype *krb5,
+			   struct crypto_shash *shash,
+			   const struct krb5_buffer *metadata,
+			   struct scatterlist *sg, unsigned int nr_sg,
+			   size_t *_offset, size_t *_len);
 
 #endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

