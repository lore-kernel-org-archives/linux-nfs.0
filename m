Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723552;
	b=RTgNMoyqp1OlvNTPMHJSt4AeCVUA8lNzNe2+uL4qMh0OZfeV13DsAPrZ8+4F6Ds9tR+q
	 ey1t2QNhklCjeVh8YegCKcf0i6rgz35GJlcoHTrOKUbCCUCUsvopsrrD5b92ALk/QLrVm
	 ll25wbY6cKH2ud5NuNp74erN9+XVfoz8vTdwI8VtjymKAEBbWPs3l6C91kMeQkeBOpE5o
	 6m/WmJ1dsNNfZ7WJc6Y8XgOl/iDltOfz0KIS91d0EQV/sr/MoqO40np+HOStDxVr7ipFe
	 T2KOxhZkpg3I1Qu69hjbk28UxO2ALpQkBgDxsM7mZAu5o6E+USDMTMnU1wGtcWQ21lA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723552;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=EChwTQ/BOLQr1g03ftMuDlTlHMg8QkSEgwBc0qrp/YE=;
	b=RtZoAVOuBHBsnJyWHyD6KCP2euikkbU6rOh3fzxw1TK74eKaQ0uzGnwSWg5RwhcRVfDf
	 n2p/7GS7UdvbH36hC3b2K5jiew5GjYX7JP5V4J6PvDL0KdgfP6aW7GMAzuUCHSpEErqtl
	 B1ukgMsspJzhA0VoJPHKVXh7n54ohFFSeN8mqglRGq4ET+REso43XcZkS0WIIzvjvEUO6
	 j4jWOUYuEXSLPL048YvO9sJnjx4J3MXdNZS55y+fSHcNdKAxKvr/yDNuMggzF+8LwOyxX
	 taaHtLVWJvReGbpW7lI43GIL8g5ZOws2TbmqQi8gI4EXoNu5235WNOEeTh0AOxpKKxA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b9ngfcOS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CECF7606A324;
	Fri, 23 Oct 2026 02:45:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b9ngfcOS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D5151F01825;
	Fri, 23 Oct 2026 02:45:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723551;
	bh=EChwTQ/BOLQr1g03ftMuDlTlHMg8QkSEgwBc0qrp/YE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=b9ngfcOSCrXa0gUiYxpzl/xSX0WV3YUeZYQTe4WoAdp1pmTRv5o9Zh5nso7HOmKrh
	 xs8zLoDIvejBesgyW14q/YXCuZ2c7It95Hp0AZwuMZWz97QLg7HStud1leTLXsrT9F
	 J5jIAMrzF3MTcCQFsaq0QP+ccFWQe7U+P3q6hBodL4VCXLzjb9lVERmiaRpdX5nk1u
	 vXFwQcQb6Ga2mzOSw+XiIg4nZTw0dCmgZH2Ff9TZ3mGaGb4Ibdy8zVM5q6So1/0Mi4
	 0DiRCfEPdADoa3pQN9P1oLHC8yz7TqKiWsRcdTf6ggb8gRPiuAMZIfj6+jjASsvYn6
	 nwkdjpK+deB/w==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v8 1/7] NFSD: cut a misaligned direct-mode WRITE at the mapping's smallest folio
Date: Thu, 22 Oct 2026 22:45:42 -0400
Message-ID: <20261023024548.71123-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261023024548.71123-1-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
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

nfsd_write_dio_iters_init() cuts a misaligned end of a direct-mode
WRITE at a multiple of the larger of offset_align and PAGE_SIZE, so
that the direct middle, which invalidates the page cache over its
range, never shares a page with a buffered end.  But where the
mapping's minimum folio order makes the smallest folio a block larger
than a page, the page cache holds that block as one folio: an end cut
on a page boundary inside a block leaves the middle and the buffered
end in the same folio.  The middle's invalidation then drops the folio
the end wrote, and whichever of the two neighbouring WRITEs comes second
reads the block back.

Cut a misaligned end at a multiple of the smallest folio the mapping
allows as well.  Where that is a page, nothing changes.

Fixes: 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at page boundaries")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/vfs.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9219f8eb386d..ade00dabef18 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1452,13 +1452,15 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	/*
 	 * The direct middle invalidates the page cache over its range, so it
-	 * must not share a page with a buffered end.  An aligned end needs no
-	 * buffered segment; a misaligned one is cut on a page boundary even
-	 * where the offset alignment is finer than a page.  A WRITE may end
-	 * at OFFSET_MAX, so the prefix is sized as a distance rather than
-	 * by rounding @offset up, which could wrap.
+	 * must not share a folio with a buffered end.  An aligned end needs no
+	 * buffered segment; a misaligned one is cut on a boundary of the
+	 * smallest folio the mapping allows, a page or, where the block is
+	 * larger, a block, even where the offset alignment is finer.  A WRITE
+	 * may end at OFFSET_MAX, so the prefix is sized as a distance rather
+	 * than by rounding @offset up, which could wrap.
 	 */
-	cut = max_t(u32, offset_align, PAGE_SIZE);
+	cut = max3(offset_align, PAGE_SIZE,
+		   mapping_min_folio_nrbytes(nf->nf_file->f_mapping));
 	prefix_end = offset;
 	if (!IS_ALIGNED(offset, offset_align))
 		prefix_end += min_t(loff_t, cut - (offset & (cut - 1)), total);
-- 
2.52.0

