Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46CBC345EB4;
	Thu, 23 Jul 2026 05:47:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784785622; cv=none; b=IulmgPxs7t/16++HTnla5uoIYGrTHqrvl4/0GfJnuDiCFW7lKd69k/3eoCr94VefsprAI28xOfapcAWIoXXlVXUuqM3odjTqc6fuztAb3df12umNUWio8yF2MGspqPp2AngI8fXe+y8bhDw2OVZxLfk1mAdb4Lefa7m6sJ9/cRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784785622; c=relaxed/simple;
	bh=FTQkfC0zufqvzqn5laoJrblWaPGLdxby72XpXgISYOw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rdxKPTLPZZ4EG/e3MPS2R7DTkoQn8snPbLhVybNxNp6Ti49QAXCC/HglOZa6OVv6QiyF8vjL3ov2z/RTSiq1BVe+xnSrqVEMym9b/bTblrbYMMZryu+L7kYP70jQ8JhLC9syPhUAmo2sFen4EYH36Tv9QtkUJSrQ9Li95WFt/fI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=DI6wpV8r; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DI6wpV8r"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description;
	bh=pcRYB9o1CpB5jJsRwr6821KrXtl1M65m2wTd3bP1/Cw=; b=DI6wpV8rEtQVdeWHAke9bjq8wu
	wC0FuZ5lRLAB197Fqglgn5hrmJr7cs35jEo/78WySTb6bEB/SyGU4G6u1rvTxTzrwWX+AukskRf+U
	TuLlBHHb8QyRQBvtQfMqI1mNatec4DzqztCPfvjLAb8JTSDAdGV79JFAnVQAWGtxkPsEr10e6KArw
	nisHmsIa4OX29uUi8ylg2e5r97u312LxvkTAFV3QZoafJXof5R3o68YHVqWVsE21gHdEU0JJy8At3
	o65DkZOCBBJvHgTugEBft4iloJ6qxvVQT+syZ5ASbyxmwbO2fsClDsArCFt3/nX+g8TwsiAzn0xG7
	byqOLwJQ==;
Received: from 217-76-162-32.static.highway.a1.net ([217.76.162.32] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmmGg-0000000DV1N-3y5c;
	Thu, 23 Jul 2026 05:46:51 +0000
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
Date: Thu, 23 Jul 2026 07:46:04 +0200
Message-ID: <20260723054622.3460249-2-hch@lst.de>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260723054622.3460249-1-hch@lst.de>
References: <20260723054622.3460249-1-hch@lst.de>
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

Accommodate that by kicking off writes for synchronous devices for
each iteration.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Usama Arif <usama.arif@linux.dev>
Acked-by: Chris Li <chrisl@kernel.org>
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

