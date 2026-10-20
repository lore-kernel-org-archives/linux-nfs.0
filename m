Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792514302;
	b=5IM5ZLJUnuqVZgv9utzQOco13FFathXK7YYK5/s0G97EBDbFDDTqLgOa0MBFVWUeQQuG
	 VrJCLiEyxFFtOzO4yGp0UDh/py9pRuwxO6hl7j1UX0w6qj7vscI71wufcM8VWZ8AXasxy
	 t8s7eGku4fIA08cGhKZg2ZPidPVt0t6/JNhsibwjq24OvxKrK4bA5agkRqExjCOLIvinE
	 UE6g9h6rn+Mr7VHPzMY7YXDu69uLKfZQ2qW2ustCX/d1FrVGUA2UG2ihdUpb8fQXrW8Dq
	 /owix70/iRhMW4XkrVXqCPWCqmUUpMnkZLhlAOglOxeSFpb07u68JuHwoz/wBWF47Ww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792514302;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=eBFboD9PLUf2VoucD8hHa/hcfv5C8KHPaeBif8ozEoY=;
	b=N0xGec2wGV5UHBUfACKkP0LbbnbTAjaZw85t61uZQpG5RV+xxVnV0rJri2D12vcKvlj5
	 EZOcZ+QxnVL09dQHiHMMrmRSS81PTqv8R35bqAvsRtilcb8pQe98KgL2YF1Xtmfs6HFJH
	 a1uwS5ca44+TgiWiZKuL245yyaapaar1ERBPz0XiHJK95GjZ+ibPC25bKO0wT7UnQ2hDH
	 vGw1t+9aWbzRUjslYS5pu/lnlmAzod7pxowEbjcxmdvZcQcOBQPLJst2ui1Osi5T6ky0+
	 e9O5wXU7CkI7pC42xrmqh7W1KSE8E0SHC12NcFRgPB6Um1yE/PcpesY13gEErgJIfEQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 007D7606D508
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 16:38:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 93B5E1F000C5;
	Tue, 20 Oct 2026 16:38:21 +0000 (UTC)
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 2/3] NFS: Modernize the callback decode_bitmap() function
Date: Tue, 20 Oct 2026 12:37:48 -0400
Message-ID: <20261020163749.262930-3-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261020163749.262930-1-anna@kernel.org>
References: <20261020163749.262930-1-anna@kernel.org>
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

From: Anna Schumaker <anna.schumaker@hammerspace.com>

The sunrpc function xdr_stream_decode_uint32_array() is already designed
to decode arrays of integers with all necessary bounds checking. Update
the decode_bitmap() function to call this and map the return value into
something the callback handler expects.

Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5a1f05469268..25c18e505c60 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -100,24 +100,16 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
 	return 0;
 }
 
-static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
+static __be32 decode_bitmap(struct xdr_stream *xdr, __u32 *bitmap,
+			    size_t bitmap_size)
 {
-	__be32 *p;
-	unsigned int attrlen;
+	ssize_t status;
 
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
+	status = xdr_stream_decode_uint32_array(xdr, bitmap, bitmap_size);
+	if (unlikely(status == -EMSGSIZE))
+		return 0;
+	if (unlikely(status < 0))
 		return htonl(NFS4ERR_RESOURCE);
-	attrlen = ntohl(*p);
-	p = xdr_inline_decode(xdr, attrlen << 2);
-	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
-	if (likely(attrlen > 0))
-		bitmap[0] = ntohl(*p++);
-	if (attrlen > 1)
-		bitmap[1] = ntohl(*p++);
-	if (attrlen > 2)
-		bitmap[2] = ntohl(*p);
 	return 0;
 }
 
@@ -182,7 +174,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp,
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		return status;
-	return decode_bitmap(xdr, args->bitmap);
+	return decode_bitmap(xdr, args->bitmap, ARRAY_SIZE(args->bitmap));
 }
 
 static __be32 decode_recall_args(struct svc_rqst *rqstp,
@@ -458,7 +450,7 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 	args->craa_objs_to_keep = ntohl(*p++);
-	status = decode_bitmap(xdr, bitmap);
+	status = decode_bitmap(xdr, bitmap, ARRAY_SIZE(bitmap));
 	if (unlikely(status))
 		return status;
 	args->craa_type_mask = bitmap[0];
-- 
2.56.0

