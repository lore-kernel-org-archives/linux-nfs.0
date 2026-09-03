Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 078074C8FED
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:03:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447840; cv=none; b=XC/yx6QzbKZhP+FKX6lb1dwbTg+6ud3WqGQuTKw0nkd59i/lTTmFIMsBASxRkJSZ0vXwS3z4yNRGgdWWL57CUbJbR92taN+ZtWOf8m0G7peBD0EnAC7ie8StjOMzYNPGjwu3IALzBPFNeMKoJu0gjTYXYQ1GMs3giPQBos2R8A4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447840; c=relaxed/simple;
	bh=p4HXAEeUIfGUB5YfSeJFsWuqqQc3kMPGcOtwzhbLo2s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MKpREKAjjyZ4fLz9Y0sMTsQjZVeW/Mb7tWPdeo500NAioR5TP1VaSqqqCL0AtbkHJlFyOw2eQQ5m/ry2oCb4ml4GagzgTj1T7w0a+UIqyvo+1eVhh6QzvSqDsHLtVH31xcU/pLkOaN+6sSgvpPxraPH0zFHD+H3A2LjjTWjYpEQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VJDJQdEv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VJDJQdEv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5867F1F00A3F;
	Thu,  3 Sep 2026 15:03:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447837;
	bh=+g+5bdli9T3gCZ59nE+5n1eRdR+RfxIMZRFsvzeEh7s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VJDJQdEv816i2HQ4yktM0RigPVANDSchFwIsSfHrrY4/AX48ujc8cIixKK8GVrzUC
	 DFNqf3L1xvTZmOyw7ikAj9pEpsZTFFU2ywnSoIiPSAOa+aIbNZBRrsj4aFlSUJzyYz
	 aUtGMwghWNgxLZXH/xUjR3pHNDnH4hI0WrkWoptIudBPN95MKTzaRR4ijAhbX+GssV
	 YEoSNTSDqHaJUTCzf9Ja6kabF3oKzANbrBMoksG0mkVQnsHGhmnQl6tOBidGuDKisj
	 mLqoEn5PMTvE21CVzDrDuI8Cot0TWJBp154Ktm0mApqnnm/n9Lg63VgxZKMXFgzGuV
	 tmkAzrULI/nSQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 06/10] SUNRPC: Add svcxdr_decode_opaque_payload()
Date: Thu,  3 Sep 2026 11:03:47 -0400
Message-ID: <20260903150351.9572-7-cel@kernel.org>
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

A bulk argument payload such as the content of an NFS WRITE request
arrives in the pages of the server's Receive buffer. Copying it into
a contiguous data pointer wastes memory bandwidth and defeats a
transport capable of direct data placement, so a server decodes such
an item in place: it reads the length prefix and captures the payload
octets by reference in an xdr_buf that later stages hand to the VFS.

svcxdr_encode_opaque_payload() already provides the encode-side
counterpart for a page-resident result payload. Add the decode-side
helper so a generated decoder can express the same in-place handling
for a page-resident argument.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 93b980439159..7bdb0b5fd3e3 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -635,6 +635,38 @@ static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
 	return true;
 }
 
+/**
+ * svcxdr_decode_opaque_payload - Decode a page-resident opaque data item
+ * @xdr: xdr_stream to be decoded
+ * @payload: on success, describes the octets of the data item's content
+ * @maxlen: largest data item length the caller will accept, or zero for
+ *	    no limit
+ *
+ * A bulk payload such as the content of an NFS WRITE request resides in
+ * the pages of the Receive buffer. Rather than copy it, set @payload to
+ * describe the item's content in place.
+ *
+ * Context: Process context. @xdr must have been initialized by
+ *	    svcxdr_init_decode().
+ *
+ * Return:
+ *   %true: @payload has been initialized and @xdr advanced past the item
+ *   %false: a bounds error occurred, or the length prefix exceeds
+ *	     @maxlen; @payload is undefined
+ */
+static inline bool svcxdr_decode_opaque_payload(struct xdr_stream *xdr,
+						struct xdr_buf *payload,
+						u32 maxlen)
+{
+	u32 len;
+
+	if (xdr_stream_decode_u32(xdr, &len) < 0)
+		return false;
+	if (maxlen && len > maxlen)
+		return false;
+	return xdr_stream_subsegment(xdr, payload, len);
+}
+
 /**
  * svcxdr_set_auth_slack -
  * @rqstp: RPC transaction
-- 
2.55.0

