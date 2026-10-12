Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5F0948C402
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 12:33:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791808438; cv=none; b=NKuq2OWCiyF/3gQ3HvoxvAytPZsZVttaiZ8tMyvNdjCoyAbRVIIRe+sDAAld+w8GhcyLEWNjr9ygsgAoE8ih0UfTWKY86CXQ9RwB1VnP9+g4g5+D8C1qLn9hJKNaQ93soc3aPQElx7LATHyPI+4bG7liByUzKBCEl05qD8kLuiQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791808438; c=relaxed/simple;
	bh=zxsrDgKFNfPcKrIMVNkib/pYnHv/tY8ywqpRRqTb6QQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GuCso5lWVzDZIZ1NYzBke53j8iQgrl4DDkdSspXr4p9ulKn0NkfYyMtB7UIiXWljst3rrAE+nPI5lYO+T0zVdFD6G/2oSF/v6bjNMYpbHspJr9JLc2VqLhTIkBJolqsY6vtJFeNNs/QyowbamBUJuCglQQ6V0nZnrXWiKTgbErQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RcOfHrJV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RcOfHrJV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 41D5C1F0089E;
	Mon, 12 Oct 2026 12:33:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791808437;
	bh=3TVBXFcAOSGWgbgaGAy7UrVXq9+mRjH/0oNWZrTNU6A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RcOfHrJVf0lTI9aT71WxPq1+TM3mYtNStXIFlqLnX3H7RAI9czZoSp+CG2fhTtVXw
	 aPuH2V+U8r5sChQ+cDVA6wI/cKRUJeEWfuIYiy+L/t2J6oveSPXYCzC1nlUeZNqzda
	 mGP1YW5pRSxp2sEGEnVsvL5jVW9qMqY0qYarS0vjhI+Db64yXmZ3LZWeA5SiNNxVZG
	 bs3b6+mnNHhPzMxRgadelrqctr2naoBeJKLAe/Zuvw/1arJmT3MnTULli/8yg4419R
	 jM1KjpqkZYtzE0WCxdGVep6iHSeAoKqyCP+lV55EUm7xqNt34peLMYw6Mtw2KZFBOu
	 qqJeq3xgDUe7g==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 2/3] NFS: Modernize the callback decode_bitmap() function
Date: Mon, 12 Oct 2026 08:33:45 -0400
Message-ID: <20261012123346.123126-3-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261012123346.123126-1-anna@kernel.org>
References: <20261012123346.123126-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

The sunrpc function xdr_stream_decode_uint32_array() is already designed
to decode arrays of integers with all necessary bounds checking. Update
the decode_bitmap() function to call this and map the return value into
something the callback handler expects.

Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5a1f05469268..b6ecfb73d850 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -100,24 +100,14 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
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
 
@@ -182,7 +172,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp,
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		return status;
-	return decode_bitmap(xdr, args->bitmap);
+	return decode_bitmap(xdr, args->bitmap, ARRAY_SIZE(args->bitmap));
 }
 
 static __be32 decode_recall_args(struct svc_rqst *rqstp,
@@ -458,7 +448,7 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
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

