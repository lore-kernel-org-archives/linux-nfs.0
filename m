Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 807CD3B27CF;
	Thu, 23 Jul 2026 05:46:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784785614; cv=none; b=ATMo7w6Nyz1TLTBNFYk021o91iCTRPqbRCaRIDNknMC7ppPGqfDWhb6siC9vY+G4KS+4+/RXEerPLjEssyQuGFqqquswQBfj2KJV77PAjWvZ5kx5yvZEr11c5iY4oPUx6j6dKqcHAb083CB/kEbkHOSuVE2IN1Vd4jsHAg/lJvI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784785614; c=relaxed/simple;
	bh=daZ+KdPxbJpDYJDpIw1FWZT3nkO90XbYBaZSx8K6yj8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=WDFo/ZoBBPOLeL026epVwtk7NP+US4lqZMHrjjn68b9psKFW7f4o1IWg11hyiGxwF9EXfJJhI9oy2bk1HUwc1HFEuA1oVNbaV3dvC1nQJk0LnFKxabQfayVVAP0QvFLKOTGICKz0ZQhxXIDEdNIHeEKK7yItUeYHLgSIogw2nBw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=NZkM7sAA; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NZkM7sAA"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:In-Reply-To:References;
	bh=K+PZXaq32U3TufEyMUaewYZwMLMqHIERdn548N0cTs0=; b=NZkM7sAALmaobWAaZMJplx7y/U
	LsQ4OswQChA5sGRNqjILzHGzJNfueRIJzfJiHrxA/A+i4KtkMZN1LC6dUHc2nNqb8E+TZmKnf1UP0
	vqjBmd0GbYY6wOcyRT0GVmHFid1Vnrd6LhzUcohsHGgOkQC3666hydey0r0M64SVtPvY+7E48xR1+
	wiqDDdv9V0HWS43BMJC3K7VH9H2VD87W97flsH57GEEhkd5ge4SmeKn6cmRh1cFICRBJkPxCH5GL0
	qqqWBp9GhJ2QyQy5j3WKSTyDPaxOKlc7AbaR7QLPhu2q4PXfjbuXBl3W0SSvknPasBcW5m3gN+M2U
	DTdTtc2A==;
Received: from 217-76-162-32.static.highway.a1.net ([217.76.162.32] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmmGV-0000000DV0i-2isy;
	Thu, 23 Jul 2026 05:46:40 +0000
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
Subject: swap_ops updates v2
Date: Thu, 23 Jul 2026 07:46:03 +0200
Message-ID: <20260723054622.3460249-1-hch@lst.de>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Hi all,

this series is a follow on to the swap ops series now in mm-unstable.

The first patch reintroduces direct folio writes for synchronous
swap files, the other two remove the double indirect for file
system based swap.

Changes since v1:
 - include swap_ops.h in zswap.c
 - fix a commit message typo
 - add a commit log blurb to mention there are not functional changes in
   patch 2
