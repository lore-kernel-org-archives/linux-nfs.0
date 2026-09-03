Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA82D4C8FF4
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:03:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447837; cv=none; b=nWkJVPfYA0RDZOX0byrWoP32Q1Zfk9PKfTRIFMXsh3PjSEolmgx5EznBIYlOfEqEA649ID/pZ6bglFk6ApxpHx+tE3zih6GFjaAsKVr2uNDtwV+PbqwlgtIzilpC4dU6JhmI/YrnYUFaCBf57Pl82z4e8+11IviVt+MM8f56ogI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447837; c=relaxed/simple;
	bh=/0TTz4I1rnrrv4i+uAbrGv54BbjGP80zxzF5+E8ATMI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uvNSOFdJWJ/3M/o+GRdBzIFY30oeT2gezGFB+tpfwsWuQtQlNDoro3GV95vuKZwp1NwVky9DRRc26+SHOUernuNmXaWNb1OeOULvCSB+4UpdBE8vtApDGyGDMw1Z74P/gBCmXzPHl3Ph7l9+fluY+jVmkQl/8mZJTNmsG64tnKg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ifQH4Xfs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ifQH4Xfs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 075C71F000E9;
	Thu,  3 Sep 2026 15:03:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447835;
	bh=UZA9Oz9eqLyHrAa+oSb3lMUhrge6tC47PpgXmrG15HI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ifQH4XfslIFomL5CUD0G4JEGoIxwdob8Lly7sh4t7J3PuBTsmdVExZBEXkboM+aSV
	 NYll0uekzMua1s/vgKaUzs9bFrH0uJcxT/xgFuo7HIDwezVyc/4695t9TitcXelqLk
	 ztVYg2XtWX5rX/iTAC6HryjQZopprhMxapLMaP4zhCtPrQuM2bvMnMi6GoG6usjmSI
	 cAe48RFE7QIOB8q7pG42181n0lM9lm/+TaVKvUFXRBzUCkeXqg7PfGF869242bCY7G
	 dNCnTp7ZE3/CKyBHpTySN2e7J1E1HtrEC+QfAeiEMDUUeEYjpuov46pyHMDYH/r5iF
	 kEpdjoxqjUhIg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 03/10] SUNRPC: Add svcxdr_encode_opaque_payload()
Date: Thu,  3 Sep 2026 11:03:44 -0400
Message-ID: <20260903150351.9572-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260903150351.9572-1-cel@kernel.org>
References: <20260903150351.9572-1-cel@kernel.org>
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

