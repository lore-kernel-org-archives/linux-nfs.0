Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0E4E4A64CA
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874978; cv=none; b=RIceUesduAGpA71v55tAG1aX1ozlq5ERx8VB4CBMY9WoFh/3hubdmakNaWllnVfCr2CJI/euCRc6w/HezFk9BaNOMobTtBKeKgghcdsbYhvjsQ7axXt+Bjul4k6LnR/BmNGIqSQnSyEu/kDPiGCoyCUH+rCsaR4eSSd8BeM4kaQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874978; c=relaxed/simple;
	bh=vq1sFO8iKw9TzYm3C1KWEkKCFLW7Q2I/AZZPvbMD9o4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=m63BtNlzDC6hcASE3sc2y9lUnEhJQIgeQm4X78DBTP7wdHfSAAXwhe+XoHYv92WP6g6lbccMQReQsDVmljVu6x2cguhHeqvlC/HRasNOsacgO8rQChRuUb6YcuZ2Byd0LzIIhRDpGk1pLECABeDCihfAk/O/+qe5XmpTg9m9bPY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 54A6B1F00ADB;
	Tue,  8 Sep 2026 13:42:42 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 06/10] SUNRPC: Add svcxdr_decode_opaque_payload()
Date: Tue,  8 Sep 2026 09:42:30 -0400
Message-ID: <20260908134234.512312-7-cel@kernel.org>
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
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/svc.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7950a2ce0a27..24698856eb40 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -643,6 +643,39 @@ static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
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
+ *   %true: @payload describes the item in place and @xdr has advanced
+ *	    past it
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

