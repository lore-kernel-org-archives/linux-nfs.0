Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0B4B470E89
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 12:33:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791808439; cv=none; b=JmTslojM3twBZV0LsE3T7MWsbcX8UKZmrfnurTa597hY4s15TBiQEFdnVWov4LEfXD2m3fe176rtTtp6Ts1gvJ9uSEfw3GSkgsUNN+jShxsHXqpDzOwcbUldnY3AjG3Wl3xGoC5I4BWa61tcCsq8x7BvEPKd+fnwNryyuiM9eNk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791808439; c=relaxed/simple;
	bh=EWqgEuJffnPXJ2k+lPXWGYoX6RIvYLpg+S7uYPovy2E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kgHEgTWPqU0w/wEDMNWQU1yrLMkStfEoIGuhS+EgO9Avz9SpMNYYg7Y0dnI3DhGBQQxmSn8lKzvA4EdezIpg+vPM5B0qZWGsog3lVJxzDqfSU3b7cPfdZGavjuG8076C7WnjK55FOAXp10lp9X1l9JCyjjnsc7xL8+ZPWIrPgQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WslOa0dB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WslOa0dB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 033061F0089D;
	Mon, 12 Oct 2026 12:33:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791808438;
	bh=6PfWNmZ9Sb3E/GCjzpyDmFkcdMr+ug5xs52fcjXECX0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WslOa0dBH/n4KDVI2YdFBWld/J1VZnpLUaP7TBexF4I6BoLIENTNuWzoqtkTsalaJ
	 SiKBtrAY8Vx/uHkwMEpiDStoIo0y1PDJdmic1JmiFuN3eMaXcac/sUGIfkoY86LLX9
	 yp4ZtxV5+uaQpcU+sJwVnqq0fzMj6olcd3ICDZRcvh7d6jhRXtv+GXmcw3eUFB4UZo
	 m/n1x53SitbwSFEL3Hy56mPBnN+n1mv0QBdlpnoODWTN1SxNIYfcimFKbRgEcbmArW
	 FOxWJwGxzkZ7yooS6a1sJne9+mZNPmxa8NwsGtU0/yOlb5THhTisfzd6gdAS5QNAAV
	 b/7PbscHmE5pA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 3/3] NFS: Modernize decode_getdevinfo() bitmap decoding
Date: Mon, 12 Oct 2026 08:33:46 -0400
Message-ID: <20261012123346.123126-4-anna@kernel.org>
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

Use the decode_bitmap4() function for decoding notification bitmaps.
This function calls xdr_stream_decode_uint32_array() to do proper bounds
and overflow checking.

Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/nfs4xdr.c | 22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4d12b97f423e..c0971af20154 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6064,7 +6064,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 {
 	struct pnfs_device *pdev = res->pdev;
 	__be32 *p;
-	uint32_t len, type;
+	uint32_t type;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETDEVICEINFO);
@@ -6099,26 +6099,8 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		return -EIO;
 
 	/* Parse notification bitmap, verifying that it is zero. */
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
+	if (decode_bitmap4(xdr, &res->notification, 1) < 0)
 		return -EIO;
-	len = be32_to_cpup(p);
-	if (len) {
-		uint32_t i;
-
-		p = xdr_inline_decode(xdr, 4 * len);
-		if (unlikely(!p))
-			return -EIO;
-
-		res->notification = be32_to_cpup(p++);
-		for (i = 1; i < len; i++) {
-			if (be32_to_cpup(p++)) {
-				dprintk("%s: unsupported notification\n",
-					__func__);
-				return -EIO;
-			}
-		}
-	}
 	return 0;
 }
 
-- 
2.56.0

