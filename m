Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795113241;
	b=L9QnzEk11OjMMdOs4/lnQP+7FdZYlPJkjlVuTSZFIkYuaRi66fW562kXBrogDw0WMccF
	 hZVFX66P7D40nuZ1WLcA48zPqr4ENF8UJ4Jndqajm8AHqtTGIwNYfJjz2y/Hc8EKXY3sM
	 qn2QzDLpaxuxlpuMSZwfcllynxfN817n5aDmdU2W+NE+VHVNwIEecTvV74rl4q8I88yOW
	 uBMw24El92P5VVHQYhCreQ7GCkBm5HRkD2KPq/crL9hpbwbNZSHjqZ4xGxq36AMa9XN8p
	 Px2TUJPb/gaWa31WYkHae2Pw3xCXB0HHlE0UyrBtmVgCtlUrxB/zGfZXhxUvkwU7SJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113241;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=u6dRFoOI8e0lI+qoZbrEkzl/ZGxEsE2oNX2ez/8NliQ=;
	b=XQ5As4Zz8Dy2eNbVgMlaIrDGVpWHFo94Wxp4uuz9kvC0PFxXwQQWtWyFZfXDkAsY5wWt
	 sz2NnSKPqDI9hNFzlJ3BKxFOixoBTKYyD1Y8relOQMbEPMwBXuu9P/EyT7IVlELHxH4vK
	 CEiD38TM5mgIUWth0i/45b+Ot9usaBfkU0jqHflAsZtsnnlRPypkkJhOsNh4LQP2JwsYc
	 csIu+RBadTAGcU0F164CRr0i0yhqBCDQruXLakD3ZcPLtxjoM4l7EAO/aF3THmm+diI4K
	 +KVn8o/wWJW9hJTnozwY/NKjtxmI311IaNwhKRzE52qgcX1KcVrmP6CU+dRu/CvrXiA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T6RkrzDL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27CFD606A32A
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:34:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T6RkrzDL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B27871F000C5;
	Thu, 19 Nov 2026 18:34:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795113241;
	bh=u6dRFoOI8e0lI+qoZbrEkzl/ZGxEsE2oNX2ez/8NliQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=T6RkrzDLLa0gRvZ/WzLvirw2KHlseT/AfsMXfpQtIpiFBykjjgfpduN4uhyYr+3Wj
	 JZpjK8Ytou4ZgHvxVeIEv4hqWb4GTUQ0iICs3AeCat0799XRx/c8mTfdbK6BizN99m
	 YWHc24ro+n5DpelSExsCmCXgVylffRfeVp5ForND1qT+FEcLGv2dxE0eXOzOF5XIfY
	 kG+C9dgsVQI7fHXa8q+IylxP9zBbyPnzRegYTLMghQ4weU1QwlkFv8/c1I54jSwJs8
	 fZ9QjlAB4R015tHi0ZfCaNQt88/UivsxmTMPnCytlEfRTLwF2S4VYDD7RDqzE33Gmk
	 l9XQ19rc471RQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 19 Nov 2026 13:33:51 -0500
Subject: [PATCH 1/4] NFSD: Reject layoutupdate extent counts that wrap the
 length check
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261119-blocklayout-decode-stream-v1-1-d71322f42c28@kernel.org>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
In-Reply-To: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
To: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 Konstantin Evtushenko <koevtushenko@yandex.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2426; i=cel@kernel.org;
 h=from:subject:message-id; bh=66HeAAEqKl684zL6DvKcWQ2pjgIMOXJh9wGSsmfQZUk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/0EXq3kic61w1uLq41bDBsGmzm4hnnDemiBF2
 H927NtobtuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCav9BFwAKCRAzarMzb2Z/
 l8RID/0cmFpNm2oTiSiWaxjGtY2AYlvzOriEzaw7JrjThIQhWsge0BN5sZiihPY3/Wo1oN0uJF/
 Phna3lR8xyGMFts6ES/7kNxOI/8y/LIGp8OGrqtSkCn1l8wRSBgZM8B2031ICycAXg+eDkxSlnS
 AB5F6toHKLM2uPWKFw53UvtQ43yKnnGlbc+KyP00n8qFzA6v7XZhiVsYlyx3+OyNg5CvKjJzYFg
 ffFcpFj5+gerOiclJdNfkmCz+u7nlfd7/MGF7H985WEyLYdonzgDVufWxQt7SH4sPNH8OMoUT7L
 LyGKIjUVErwPoiPkG0Grojb2HOk1hrDNu/jQ1KcoUuySSeWNEeSAeyvBWtXol6tAH41r4Gkcqnb
 CyVu15MKFCpSMnsAzDCr0i8B3miBYzSSWLMIT8qx0LaZCT9K0hxDNtX5sMNQ1Z0rxjtt8iAattr
 kd47XAnr51Lhz3nJ+clnHhqJnaiQ6ky5lWdG5v3y+7hbzZTXGApuTlSlxJaMF0TFPzJPFewes+d
 sqKh00EldMXJWpDwRKci5HV4iOEOwQiJmHs1ICVwFgCSbQ0HswkxVZeWD5vur1M5riZoJR9NGNE
 pFSZlBM7+OqtPc1jZJU89jHGqehpWmH7Jb4UeQ16Xp9VTm+czS2AEHx7Me+lKRAfjg30fV91ruv
 I19aXqEix0oodWg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_block_decode_layoutupdate() and nfsd4_scsi_decode_layoutupdate()
validate the extent count in a layoutupdate4 body by multiplying the
count by the size of one extent and comparing the product to the
length of the body. The product is stored in a u32, so a count of
0x40000000 block extents or 0x10000000 SCSI ranges wraps to zero and
matches a body that carries no extents at all. Both decoders then
pass the count to kzalloc_objs(). The request exceeds
KMALLOC_MAX_SIZE, so the allocation fails with a warning. NFSD then
returns NFS4ERR_DELAY for a LAYOUTCOMMIT it should reject with
NFS4ERR_BADXDR.

Fixes: f963cf2b91a3 ("NFSD: Implement large extent array support in pNFS")
Fixes: f99d4fbdae67 ("nfsd: add SCSI layout support")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayoutxdr.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index a6589f5c878a..ea9a3f04a560 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -164,15 +164,15 @@ nfsd4_block_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 		int *nr_iomapsp, u32 block_size)
 {
 	struct iomap *iomaps;
-	u32 nr_iomaps, expected, len, i;
+	u32 nr_iomaps, len, i;
 	__be32 nfserr;
 
 	if (xdr_stream_decode_u32(xdr, &nr_iomaps))
 		return nfserr_bad_xdr;
 
-	len = sizeof(__be32) + xdr_stream_remaining(xdr);
-	expected = sizeof(__be32) + nr_iomaps * PNFS_BLOCK_EXTENT_SIZE;
-	if (len != expected)
+	len = xdr_stream_remaining(xdr);
+	if (len % PNFS_BLOCK_EXTENT_SIZE ||
+	    nr_iomaps != len / PNFS_BLOCK_EXTENT_SIZE)
 		return nfserr_bad_xdr;
 
 	iomaps = kzalloc_objs(*iomaps, nr_iomaps);
@@ -258,15 +258,15 @@ nfsd4_scsi_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 		int *nr_iomapsp, u32 block_size)
 {
 	struct iomap *iomaps;
-	u32 nr_iomaps, expected, len, i;
+	u32 nr_iomaps, len, i;
 	__be32 nfserr;
 
 	if (xdr_stream_decode_u32(xdr, &nr_iomaps))
 		return nfserr_bad_xdr;
 
-	len = sizeof(__be32) + xdr_stream_remaining(xdr);
-	expected = sizeof(__be32) + nr_iomaps * PNFS_SCSI_RANGE_SIZE;
-	if (len != expected)
+	len = xdr_stream_remaining(xdr);
+	if (len % PNFS_SCSI_RANGE_SIZE ||
+	    nr_iomaps != len / PNFS_SCSI_RANGE_SIZE)
 		return nfserr_bad_xdr;
 
 	iomaps = kzalloc_objs(*iomaps, nr_iomaps);

-- 
2.56.0

