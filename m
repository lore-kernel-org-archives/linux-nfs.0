Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36ACE318B96;
	Wed, 22 Jul 2026 13:06:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784725598; cv=none; b=oZY4bwuVjrBY7OE7suPlyjp35QwvujdjhPxtjuiyfYb4Bgzx47HFXDIsUou/JBzgU1QJUxFv4tftryjquJrCzGK133/LTgDm22tPdGlk2MN4YeDLxe71QFPkOMe9UNARUD6WiFOHmRRcqGrW9BFgxZ79lyaI9A8KNX/eNGBfLLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784725598; c=relaxed/simple;
	bh=RMcLe3jTWKFGFa9IVqxwfPPI+7jFd86EJoFCKxW/v44=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QGIEJyDukuKUYFbhzIIYvufP0OpVT+nrtEqO619d9pmTp/p4RjwmNSpi5HiZAU06VpV/tVTepQPy459mhn4z4ufAqp783lE5eDH3RFb84Bdzl5xHvzJ3TVW9wtUyZ6zljVl95cBQgdqjX4mBbabcXjQyFr6Rpqw22SEaN+2s5Gs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=wBCFQGFL; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="wBCFQGFL"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description;
	bh=AJu6W+cDK+vrIV3o8PwkdnGRy2RqYD0RDxVBwAOMbr8=; b=wBCFQGFLFtCcB4Yaw6R2yS+bIU
	FxxTWZwNsSFVLylygCqH0P18xh6Ze4pD7kroAlyDWFMmHdnjc2RcJBmsetsW1+JGn3UNElSoAU3Yr
	YjpfKOJn/E6cZhxNBDDYtDDc6iAdfOlwFAHb9Ksn5I9Qj140vLAqwLyIijhTCQx5GPtV8AUnVgLTq
	dkWRzH/FsDoqmj8wfiq8p9oDQrppLLtr+wKlv4zq/ln4GAV749HYf3HtzqimYXqgNG6QLYKOnOJoS
	j0z7EfPPmR3OhHDFVfjuqPD4Fj08ESri1FXeYHCxasSGF80m78yzbewf0uCRx4W9y/hmKAj5Ib8jr
	hnmijh2g==;
Received: from [2001:4bb8:2d6:3a78:eb21:714c:af4c:ee7d] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmWea-0000000Bpp9-1eNe;
	Wed, 22 Jul 2026 13:06:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: 
Cc: baoquan.he@linux.dev,
	akpm@linux-foundation.org,
	chrisl@kernel.org,
	usama.arif@linux.dev,
	kasong@tencent.com,
	nphamcs@gmail.com,
	shikemeng@huaweicloud.com,
	youngjun.park@lge.com,
	ryncsn@gmail.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	linux-mm@kvack.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] mm/swap: revert to single-folio writes for synchronous swap devices
Date: Wed, 22 Jul 2026 15:06:07 +0200
Message-ID: <20260722130615.3163560-2-hch@lst.de>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260722130615.3163560-1-hch@lst.de>
References: <20260722130615.3163560-1-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Kairui Song reported that zram benefits from submitting each folio
directly instead of batching up I/O because the classic LRU scanning
benefits from clearing the folio writeback bit in the scan loop.

Accommodate that by kicking off reads for synchronous devices for
each iteration.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/page_io.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index e4fa7ffffe8b..c984a4023a65 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -358,7 +358,16 @@ static void swap_add_folio(struct swap_io_ctx *ctx, struct folio *folio, int rw)
 	}
 	bvec_set_folio(&sio->bvecs[sio->nr_bvecs], folio, folio_size(folio), 0);
 	sio->len += folio_size(folio);
-	if (++sio->nr_bvecs == ARRAY_SIZE(sio->bvecs)) {
+
+	/*
+	 * Write out the iocb if we filled it, or if the device is synchronous.
+	 *
+	 * The latter is to work around expectations in the classic LRU code
+	 * which make synchronous clearing of the folio writeback flag in the
+	 * reclaim path beneficial.
+	 */
+	if (++sio->nr_bvecs == ARRAY_SIZE(sio->bvecs) ||
+	    (rw == WRITE && (sis->flags & SWP_SYNCHRONOUS_IO))) {
 		if (rw == WRITE)
 			swap_write_submit(ctx);
 		else
-- 
2.53.0

