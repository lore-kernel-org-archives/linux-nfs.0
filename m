Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F28AD2DEA68;
	Sun, 30 Aug 2026 04:19:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063577; cv=none; b=TNFHOSY5JQGr5sOGY26avbCbMDCE/667RRrzF0j9n3QdFfPMtYjBoKSbogxnx+QKorTVPOfmr3hCIJU3fYvyjzCkaIr1MgobaN+pBnH9qMQcjov5jRl5htjUMrcQbwF1FXhc9mB01J3Mlr3W5hTMBKGjxGX9kmZ1/YjqaUwWOOc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063577; c=relaxed/simple;
	bh=WL/B100/GmCmY95cHZGZ96sF5d7nwV/mGfptUmKPP7A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CD3GbcMEc7p7nqJiSDPHy3BQU1Hn8D1dgfd6YfuQ4y03YOa6id2VNJeapV8hNIg6SbzVdCvmXUtkuKQFLGYMC40PT0VXOEO5JPh9hHq7oM5asvYtdlOQPuWLotkEYlTiBGPQ0l08BW8YC1kukKNAC43rbgE2StXmtDEiciJPnzk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ZYfiTFLB; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZYfiTFLB"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=yrBK9zAVRuWrfCGTpwW8HiqL2BzA7MjQTeYnO4XWRqM=; b=ZYfiTFLBbqpdaWTdAiqc0+5xJO
	44XPrYZU6F4MGY/PtsCU8/I8FsN60fK+PLVNyFLOolQBLhPVG4oAy5ghiGXh3XA6i/J8LrLNlo1gS
	nRD1GPEqKKMUK1wKAK3kF8msLk4fxe0AnMcFu6iWeHAQ/J+5S2aFm/tnFPN7QjjcMKL2r40t93fJO
	iZEBXKfJRTsrPd1dKa/7324uldDA6fT9fizmRe62wSkq1l2cgf5cGHSNieSrJSrGjzuHeudQfxZwe
	36jH284GDJM01IX/0tCWU5I0AQj8pu6NkuPaA+ZB5fcN6kKlOk0Z0pCzUTrAL+zeI8fN6sy5EkstX
	GOyKOdMA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000hQ-0aEV;
	Sun, 30 Aug 2026 04:19:03 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <christian@brauner.io>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Gao Xiang <xiang@kernel.org>,
	Chao Yu <chao@kernel.org>,
	"Theodore Tso" <tytso@mit.edu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	linux-erofs@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ntfs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 3/9] erofs: Remove redundant FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:50 +0100
Message-ID: <20260830041901.2668-4-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260830041901.2668-1-willy@infradead.org>
References: <20260830041901.2668-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The flags already include FGP_NOWAIT which prohibits all reclaim, not
just reclaiming from the filesystem.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/erofs/internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/erofs/internal.h b/fs/erofs/internal.h
index 65974e57aebf..84b3cdc8e88f 100644
--- a/fs/erofs/internal.h
+++ b/fs/erofs/internal.h
@@ -327,7 +327,7 @@ static inline struct folio *erofs_grab_folio_nowait(struct address_space *as,
 						    pgoff_t index)
 {
 	return __filemap_get_folio(as, index,
-			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
+			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
 			readahead_gfp_mask(as) & ~__GFP_RECLAIM);
 }
 
-- 
2.47.3

