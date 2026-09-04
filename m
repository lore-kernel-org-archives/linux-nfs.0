Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 220C34FECF4
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540660; cv=none; b=TaQJ5PfOny1Sj6MjpdjZBOzujccKYiF2J23bKjlSwipcXTnhkAlz7PnCrhiby5pDsZJG3bjDuBL5H9PYGNNr2Qtrh9joe02mNO+7JLUU+qXYPTQyhzCd3NQPrDG3U/+NgfqC/sIQ2yUYessP8c9XbnT+u3miGehZGeZeR3xmRfc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540660; c=relaxed/simple;
	bh=p4HXAEeUIfGUB5YfSeJFsWuqqQc3kMPGcOtwzhbLo2s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FVW97i0UOL8WJEM35+ZSbvMXXuRpT7IY2rZt774ihiQ2rJiVwbqp68w1E9h4Hghg8xpJqHNJB2713D6NRyp08P90FRME4bXard1xLeRQhR6kEN84HKHGq0kN73E94MKUpRvJvmT+bDD9Sl2C1R95Wl3YJsaQa7bp1n1JpYmesaM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WmYSLrD3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WmYSLrD3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74D371F00A3E;
	Fri,  4 Sep 2026 16:50:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540659;
	bh=+g+5bdli9T3gCZ59nE+5n1eRdR+RfxIMZRFsvzeEh7s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WmYSLrD3BsQXxoL/ojD76WFdX9iOTWQCxU+SceVT3YXF82b7ucDSLTkeMSlNpuJ8V
	 TN4OrvasdnbC8X4ktKOMJwUclS6Z/ttUFpQ4lDYn6FQKqOEI/o+gZ8vEoVaSqDKfUQ
	 3auzW/l1/VRxgjeuk1ie2eQlKY1XDttFzmueis25rrv58CQHCuFXqr+s+lFJEq1zq1
	 M6wjqaUWF0HUp7iX9D5/CnulcS77OsSUpuRnIRIwXaE+iD1u88boOj2jBRJluqWX8m
	 8YBKY3FtaXwqKTlI+bogqo8pZ5VJE39dWAtQgHu7mPJblxSdRCJd2tG3yi4Zo5zCn0
	 9SQ+a7NDaGuBA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 06/10] SUNRPC: Add svcxdr_decode_opaque_payload()
Date: Fri,  4 Sep 2026 12:50:48 -0400
Message-ID: <20260904165052.153327-7-cel@kernel.org>
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

