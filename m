Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5428B2EEE86;
	Sun, 30 Aug 2026 04:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063569; cv=none; b=CxLBGGmmJApiNNm/9AcQHyyuVX74CCI+ax+8XbI3ZgTgFibb39nAnul60B1mdqJ4aJ5iyqSqrmlJ4WvHQ9DIlQNTHwTlRf8HABXA83Jo90CMFHShVhXikRvcTIa8dnHAbqSt/T7PDm2ShRSDHswPM+CcCALl9yyfxZavglYhEoQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063569; c=relaxed/simple;
	bh=JeraOrinGK6TEbRIavBIgntacVnb1B5D7qODMS5lJ1s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QdazyZ0Nrp8Af03MYijBB7cdK5NLNzXcp81Ur8MTYkO0N1JDEvWHDA8uI3L161YhIxXezyNN1bMp29sXFidZ6rIJ6qBB/XCnV3rtFJTMsoMVeTajEKn1+ntnmHFb7efi819qAtVjbNCYk8mpVESf6h4ZlnJnEZVzhrJppXx/S94=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=L037xD86; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="L037xD86"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=iOsUEQiX5hPPz6sUPul1Vy0rSyJQxXGSiFeQvRVO8q0=; b=L037xD86tbRevrRc914UOatghV
	p+tn3zXNS1KjRC7ubVd5/qGwTQYn67z7oD8fyhA7G9ULdUFo+SleMrRPBP2CXoDSeI/7al9q9nIBh
	bmvFtG3Y5i5bMroPMma4KLePX0fwM4bTu9I2VJ5gXVLsypFk64Gnc/qCG7u567/hwq8yGZliK/Zvc
	mp+qCjf6x5LPR33alJLx9+FDr9EgLfA9qOEQWikc5b8t/EBAvvRKPq/rfyqVNKKFKh6WXwWwv2OGf
	vwRlTrodbR9EbM/Z0xfKyBR0cszGGhcIfowJ6uc6nEYVcihEAwYLp019cM9AJ+pEp5IabkI6qHXVM
	QYpBsLrA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000i3-26Vc;
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
Subject: [PATCH 7/9] squashfs: Remove use of FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:54 +0100
Message-ID: <20260830041901.2668-8-willy@infradead.org>
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

Since we can allocate memory while holding a folio locked, we cannot
allow page reclaim to call into the filesystem and attempt to compact
the folio we're currently holding locked.  Use memalloc_nofs_save()
instead of FGP_NOFS here.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/squashfs/file.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
index d83594ce91d2..34c550a266bc 100644
--- a/fs/squashfs/file.c
+++ b/fs/squashfs/file.c
@@ -398,6 +398,7 @@ void squashfs_copy_cache(struct folio *folio,
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
 	int i, mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
 	int start_index = folio->index & ~mask, end_index = start_index | mask;
+	unsigned int nofs = memalloc_nofs_save();
 
 	/*
 	 * Loop copying datablock into pages.  As the datablock likely covers
@@ -415,7 +416,7 @@ void squashfs_copy_cache(struct folio *folio,
 
 		push_folio = (i == folio->index) ? folio :
 			__filemap_get_folio(mapping, i,
-					FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
+					FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
 					mapping_gfp_mask(mapping));
 
 		if (IS_ERR(push_folio))
@@ -430,6 +431,8 @@ void squashfs_copy_cache(struct folio *folio,
 		if (i != folio->index)
 			folio_put(push_folio);
 	}
+
+	memalloc_nofs_restore(nofs);
 }
 
 /* Read datablock stored packed inside a fragment (tail-end packed block) */
-- 
2.47.3

