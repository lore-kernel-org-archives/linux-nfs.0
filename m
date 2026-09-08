Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C528854EEA8
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874969; cv=none; b=AHWhJ7tX3Nogguj6Az+DRGOfRNt8TGcA4sxgvjdxmw6o7YQ0qik2ZWbe29v5PuWQ3LHaGYVigX80Xn5pg4YGbTH9jmeR57E2KrXGugpNI37sbphfq/EMxnpPOLsrg26n+B804iWjfcVYBkdg/AoMlERXaApgDyupTX72Hxey0ZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874969; c=relaxed/simple;
	bh=tiPQRXJXepFS7Wwezf/LZGEOgECpEXCZuGRugVWRFYE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=W74SWvkqdeu+OTKl7zFYnVCE3spnMiPjDT5MjUMLc/dUzC2q+vQ3R+PMELr7L4DvlN5y9QQ+HSdZ1UkdImGFOdoM9sXTs5s70ysIZfDFjqROQKwkxtkJD7/GEcJdm7QUHwNhI1oAXPOLSRD6qXoEMIHMCbgR7Wh8xxKxT7l4AvA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C6181F00AC4;
	Tue,  8 Sep 2026 13:42:39 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 03/10] SUNRPC: Add svcxdr_encode_opaque_payload()
Date: Tue,  8 Sep 2026 09:42:27 -0400
Message-ID: <20260908134234.512312-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260908134234.512312-1-cel@kernel.org>
References: <20260908134234.512312-1-cel@kernel.org>
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
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/svc.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e69aeb864a8d..7950a2ce0a27 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -608,6 +608,41 @@ static inline void svcxdr_encode_opaque_pages(struct svc_rqst *rqstp,
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
+ *   %false: The reply head cannot hold the length prefix and XDR
+ *   padding, or the transport could not accommodate the result payload
+ */
+static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
+{
+	struct svc_rqst *rqstp = svcxdr_rqst(xdr);
+	struct xdr_buf *buf = xdr->buf;
+
+	/*
+	 * The length prefix and any pad word must land in the reply
+	 * head. A prefix that spills into the first Reply page lands
+	 * on the payload itself, and xdr_write_pages() BUGs when the
+	 * pad word does not fit.
+	 */
+	if ((xdr->end - xdr->p) * XDR_UNIT < XDR_UNIT + xdr_pad_size(len))
+		return false;
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

