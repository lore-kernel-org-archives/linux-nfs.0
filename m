Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B4873B9929
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540658; cv=none; b=DFIqFk1bsY5jKqiWtsKP4dioieFvL8X+cEVKBbC3GzMtQFl5Y+UkJLov8bpc7XuS171afuBFweqtfTWEITg0MKlfgjWC2OuqEd90rNSqWwaoHISf9jRhKPaz5mdkvvVgKwg+pC4KfKOVKFkAcI73N9snQfvasznXrw2xkXFBIRk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540658; c=relaxed/simple;
	bh=/0TTz4I1rnrrv4i+uAbrGv54BbjGP80zxzF5+E8ATMI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ueiURdf7a1LnEAM124ldWAvjabDZiwFQRRJokOPICcBRsMysT/PNC9tIyhEUBxXD8BRoxnfxiik2kB0yYwv73SuKrbxqHD+CS7Yqyxs5OL+f1w5AP5K+QtooOfmyaubVucyM6J0QewdZGPv2xeBAStF9IamLj/C+3YC/sQyRZ1Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Irdj42gY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Irdj42gY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 14EB51F00A3F;
	Fri,  4 Sep 2026 16:50:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540656;
	bh=UZA9Oz9eqLyHrAa+oSb3lMUhrge6tC47PpgXmrG15HI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Irdj42gYp/kDo7dDnJ13nH04wZ4Hugk14eTvha4ShY8X7/fKTwyYaNXHhnrl87sCv
	 mccaBg+QutwpzzFQYalo/qoEHTIZFHOAi/p9i5mhX/DZkeGAply/onmA0Be85qbw7i
	 bUlTr7se/X6nuuqTnUYJxwyPHmCryc8+umafcxn1Bt1VIRT68GVB6EuC97YyrrhGbm
	 TXpZ6Nq2cs8NHwJ6klFLMr9Khx2mMvg9J1284LGZpC+dljywJHmGvKx1f/A9xB5M/I
	 CNpC7ky8A07w89yd3ZBhaYf7QHcfrHQ6zod2wO1+hwCxTDGgX1JVaXHkz1jPKnT1cB
	 mnqR2jkOAAzMg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 03/10] SUNRPC: Add svcxdr_encode_opaque_payload()
Date: Fri,  4 Sep 2026 12:50:45 -0400
Message-ID: <20260904165052.153327-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260904165052.153327-1-cel@kernel.org>
References: <20260904165052.153327-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The encoder functions that xdrgen emits handle a variable-length
opaque with xdr_stream_encode_opaque(), which copies the opaque
content into the RPC buffer. On the server, an NFS READ payload
already resides in the pages of rqstp->rq_res, placed there by an
underlying file system read. Copying that payload into the RPC
Reply buffer adds a data copy on every READ and prevents a
transport capable of direct data placement from conveying the
payload separately from the rest of the Reply.

Add a helper that encodes a page-resident opaque by reference: it
encodes the length, inserts the payload pages into the XDR stream,
then marks the byte range as a result payload.

Generated code calls this helper, so its parameters are limited to
the xdr_stream and the payload length. It recovers the svc_rqst
with svcxdr_rqst(), and takes the reply's page array from the
stream's buffer.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e69aeb864a8d..93b980439159 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -608,6 +608,33 @@ static inline void svcxdr_encode_opaque_pages(struct svc_rqst *rqstp,
 	xdr->page_ptr = rqstp->rq_next_page - 1;
 }
 
+/**
+ * svcxdr_encode_opaque_payload - Encode a page-resident opaque data item
+ * @xdr: xdr_stream to be updated
+ * @len: number of octets of content in the data item
+ *
+ * Context: Process context. @xdr must have been initialized by
+ *	    svcxdr_init_encode() and still be positioned in the reply
+ *	    head.
+ *
+ * Return:
+ *   %true: Success
+ *   %false: The length prefix would overrun the buffer, or the
+ *   transport could not accommodate the result payload
+ */
+static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
+{
+	struct svc_rqst *rqstp = svcxdr_rqst(xdr);
+	struct xdr_buf *buf = xdr->buf;
+
+	if (xdr_stream_encode_u32(xdr, len) < 0)
+		return false;
+	svcxdr_encode_opaque_pages(rqstp, xdr, buf->pages, buf->page_base, len);
+	if (svc_encode_result_payload(rqstp, buf->head->iov_len, len) < 0)
+		return false;
+	return true;
+}
+
 /**
  * svcxdr_set_auth_slack -
  * @rqstp: RPC transaction
-- 
2.55.0

