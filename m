Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.43.10.250
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795002328;
	b=sbybTf6RmTJPTyOyPHdmb0Pp34i5G+wVGrGSdKTNoqtZiJoytMolZHcpqpuc8OoWxl0m
	 yoo8yidgM/HqfD8oNGp2BO9jl6eHOa99STjGvPepL95Udlfl2DsLyzdopSMGI4Hj+EOFk
	 AhA17noLUXWryPKGj+f4beyWlRIkyBXDdJOInx30WhbtM7D+pgjvqCH14AilTcbMi3YRY
	 4u3LYcUmrK0/UPrtShgM38QiTaofDHSVIL/N9rsfu+XgqgB6z38JL7u6jrQSrCo6n1kWZ
	 T8Uz9t7hXEMJOYB0Ae8QwiGNH9/MwT34IAP75o/d573Oxe2zxcZGklP2+6hQfX/+6gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795002328;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=TNr17IsDH3CMJAsBddlI8ulC9BfuyexkixP3yKX5G7k=;
	b=RmWl3FpW+1kNAE1jxET9Q8xJXThaZRtxcWGkoHze9bdo+DZR7rqPHxSqb8WeftrS+WrE
	 zjl7weVO/UT+X0e0+TzA06IFW5eI9ojlfpxh6uJ97w00of4/RV5b2o2nBAr4C3dofZSVv
	 XHTpXKjljyCt44OGOejxUYac5EBf2JuID1zNrAZTN2pXKV6TdZKA6QMppD/tpa0ptm9Jp
	 BezR/ez6f6HR+87Gj4X+OYaImRAc/yQ/uaAvrJcrZjHwMScwN+r2iI0xfQqsb1l+DYfv0
	 NyZEpJ6A55UKLns7+wlQ/XprB/Jo1onF+FUW0QemBijfTa3ZRO9s1+kI5GtJ87sJUCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=altlinux.org;
	spf=fail smtp.mailfrom=altlinux.org;
	arc=none smtp.remote-ip=193.43.10.250
Received: from basalt.external.altlinux.org (unknown [193.43.10.250])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 83985606A32C;
	Wed, 18 Nov 2026 11:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 83985606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=altlinux.org
Received: by basalt.external.altlinux.org (Postfix, from userid 1137)
	id D76372DF335; Wed, 18 Nov 2026 14:45:18 +0300 (MSK)
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
Subject: [PATCH 6.12/sisyphus 03/29] crypto/krb5: Add an API to query the layout of the crypto section
Date: Wed, 18 Nov 2026 14:44:52 +0300
Message-ID: <20261118114518.3605222-4-shaba@altlinux.org>
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

Provide some functions to allow the called to find out about the layout of
the crypto section:

 (1) Calculate, for a given size of data, how big a buffer will be
     required to hold it and where the data will be within it.

 (2) Calculate, for an amount of buffer, what's the maximum size of data
     that will fit therein, and where it will start.

 (3) Determine where the data will be in a received message.

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
(cherry picked from commit 025ac491f4eeb48c03353719f0de20a6db36b826)
---
 crypto/krb5/krb5_api.c | 108 +++++++++++++++++++++++++++++++++++++++++
 include/crypto/krb5.h  |   9 ++++
 2 files changed, 117 insertions(+)

diff --git a/crypto/krb5/krb5_api.c b/crypto/krb5/krb5_api.c
index 5c1cd5d07fc3..f6d1bc813daa 100644
--- a/crypto/krb5/krb5_api.c
+++ b/crypto/krb5/krb5_api.c
@@ -40,3 +40,111 @@ const struct krb5_enctype *crypto_krb5_find_enctype(u32 enctype)
 	return NULL;
 }
 EXPORT_SYMBOL(crypto_krb5_find_enctype);
+
+/**
+ * crypto_krb5_how_much_buffer - Work out how much buffer is required for an amount of data
+ * @krb5: The encoding to use.
+ * @mode: The mode in which to operated (checksum/encrypt)
+ * @data_size: How much data we want to allow for
+ * @_offset: Where to place the offset into the buffer
+ *
+ * Calculate how much buffer space is required to wrap a given amount of data.
+ * This allows for a confounder, padding and checksum as appropriate.  The
+ * amount of buffer required is returned and the offset into the buffer at
+ * which the data will start is placed in *_offset.
+ */
+size_t crypto_krb5_how_much_buffer(const struct krb5_enctype *krb5,
+				   enum krb5_crypto_mode mode,
+				   size_t data_size, size_t *_offset)
+{
+	switch (mode) {
+	case KRB5_CHECKSUM_MODE:
+		*_offset = krb5->cksum_len;
+		return krb5->cksum_len + data_size;
+
+	case KRB5_ENCRYPT_MODE:
+		*_offset = krb5->conf_len;
+		return krb5->conf_len + data_size + krb5->cksum_len;
+
+	default:
+		WARN_ON(1);
+		*_offset = 0;
+		return 0;
+	}
+}
+EXPORT_SYMBOL(crypto_krb5_how_much_buffer);
+
+/**
+ * crypto_krb5_how_much_data - Work out how much data can fit in an amount of buffer
+ * @krb5: The encoding to use.
+ * @mode: The mode in which to operated (checksum/encrypt)
+ * @_buffer_size: How much buffer we want to allow for (may be reduced)
+ * @_offset: Where to place the offset into the buffer
+ *
+ * Calculate how much data can be fitted into given amount of buffer.  This
+ * allows for a confounder, padding and checksum as appropriate.  The amount of
+ * data that will fit is returned, the amount of buffer required is shrunk to
+ * allow for alignment and the offset into the buffer at which the data will
+ * start is placed in *_offset.
+ */
+size_t crypto_krb5_how_much_data(const struct krb5_enctype *krb5,
+				 enum krb5_crypto_mode mode,
+				 size_t *_buffer_size, size_t *_offset)
+{
+	size_t buffer_size = *_buffer_size, data_size;
+
+	switch (mode) {
+	case KRB5_CHECKSUM_MODE:
+		if (WARN_ON(buffer_size < krb5->cksum_len + 1))
+			goto bad;
+		*_offset = krb5->cksum_len;
+		return buffer_size - krb5->cksum_len;
+
+	case KRB5_ENCRYPT_MODE:
+		if (WARN_ON(buffer_size < krb5->conf_len + 1 + krb5->cksum_len))
+			goto bad;
+		data_size = buffer_size - krb5->cksum_len;
+		*_offset = krb5->conf_len;
+		return data_size - krb5->conf_len;
+
+	default:
+		WARN_ON(1);
+		goto bad;
+	}
+
+bad:
+	*_offset = 0;
+	return 0;
+}
+EXPORT_SYMBOL(crypto_krb5_how_much_data);
+
+/**
+ * crypto_krb5_where_is_the_data - Find the data in a decrypted message
+ * @krb5: The encoding to use.
+ * @mode: Mode of operation
+ * @_offset: Offset of the secure blob in the buffer; updated to data offset.
+ * @_len: The length of the secure blob; updated to data length.
+ *
+ * Find the offset and size of the data in a secure message so that this
+ * information can be used in the metadata buffer which will get added to the
+ * digest by crypto_krb5_verify_mic().
+ */
+void crypto_krb5_where_is_the_data(const struct krb5_enctype *krb5,
+				   enum krb5_crypto_mode mode,
+				   size_t *_offset, size_t *_len)
+{
+	switch (mode) {
+	case KRB5_CHECKSUM_MODE:
+		*_offset += krb5->cksum_len;
+		*_len -= krb5->cksum_len;
+		return;
+	case KRB5_ENCRYPT_MODE:
+		*_offset += krb5->conf_len;
+		*_len -= krb5->conf_len + krb5->cksum_len;
+		return;
+	default:
+		WARN_ON_ONCE(1);
+		return;
+	}
+}
+EXPORT_SYMBOL(crypto_krb5_where_is_the_data);
diff --git a/include/crypto/krb5.h b/include/crypto/krb5.h
index 8fa6715ab35b..b414141b8b42 100644
--- a/include/crypto/krb5.h
+++ b/include/crypto/krb5.h
@@ -101,5 +101,14 @@ struct krb5_enctype {
  * krb5_api.c
  */
 const struct krb5_enctype *crypto_krb5_find_enctype(u32 enctype);
+size_t crypto_krb5_how_much_buffer(const struct krb5_enctype *krb5,
+				   enum krb5_crypto_mode mode,
+				   size_t data_size, size_t *_offset);
+size_t crypto_krb5_how_much_data(const struct krb5_enctype *krb5,
+				 enum krb5_crypto_mode mode,
+				 size_t *_buffer_size, size_t *_offset);
+void crypto_krb5_where_is_the_data(const struct krb5_enctype *krb5,
+				   enum krb5_crypto_mode mode,
+				   size_t *_offset, size_t *_len);
 
 #endif /* _CRYPTO_KRB5_H */
-- 
2.50.1

