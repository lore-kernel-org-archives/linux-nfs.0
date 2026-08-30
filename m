Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9D8525B090;
	Sun, 30 Aug 2026 04:19:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063565; cv=none; b=m1cF1CatlepV0EuwzgDuMN6AZAOHvru+z1B756M/suxEmctGrBnQDWzLI7LARc0/aL++FyUL4tA0CZEzdRebEW/K5NNV/etkbxyraBgQkHMFoWbXfXztrh+UCI4fMUDufYqZzCDUDz4C1YwSNST1A+0SfZzHWgOr6yD/r5M8a1c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063565; c=relaxed/simple;
	bh=mBJBVACiLTDSzt30yuy5vMYTlu5/Pc66RyndQwm240o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WPCUR4cA6S6NSkuG48p82vlpQ/k6qVqEj7tZ/RF7yihxBe2E9nxT4BFl0DzmsOgk9+i2D9WhyGB5BsvSjW9ieq4fvhNTyyz6HKiaBQHHSAVEb2/1mbvELfBefkXeHfztFOdNPDW/Bni8gNwKqgD5/G4Fm262CN6lE24GlQUKbZI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=dl4JOhdj; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dl4JOhdj"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=E9PhFISLskt0G9jrpDuqAu5vcSeLsmZLZhXWQ4ku/eI=; b=dl4JOhdjy5Ky53MMIMMBSBjxka
	GMyBrCs+KW2T06hsemYTZsbViVEsYqH6IaNoiFeMIOs23zFgdkh5S85D4oEtrKsHkfOgxzhps21Kh
	6NpoQaSvy8g3bfy7JVTIHe7QClXeT/eCwfxNkZomI5FDA1vK8kOFGCVOXEqBcAIU07qbwq64YXybZ
	ZYvDvIoj6CbhKrL2AetEuVzCnYNaBocvwGaeqPf/lQS+EcUHCgTIgf/W9rTKkkPkc/ba67HcDVp4Q
	9CgcYBOQTK5Du77A8ZYIfso3emJlI1o86I2tmoE58/7/o6UdqqDwrPtwAXs6hbhhEd6NkD7c8n0Yi
	CDA201oA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000i7-30zs;
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
Subject: [PATCH 9/9] filemap: Remove FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:56 +0100
Message-ID: <20260830041901.2668-10-willy@infradead.org>
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

There are no more users of FGP_NOFS.  Remove it.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/pagemap.h | 10 ++++------
 mm/filemap.c            |  2 --
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3974b063a049..bff8b7264fb0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -697,7 +697,6 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
  *   folio is already in cache.  If the folio was allocated, unlock it
  *   before returning so the caller can do the same dance.
  * * %FGP_WRITE - The folio will be written to by the caller.
- * * %FGP_NOFS - __GFP_FS will get cleared in gfp.
  * * %FGP_NOWAIT - Don't block on the folio lock.
  * * %FGP_STABLE - Wait for the folio to be stable (finished writeback)
  * * %FGP_DONTCACHE - Uncached buffered IO
@@ -710,11 +709,10 @@ typedef unsigned int __bitwise fgf_t;
 #define FGP_LOCK		((__force fgf_t)0x00000002)
 #define FGP_CREAT		((__force fgf_t)0x00000004)
 #define FGP_WRITE		((__force fgf_t)0x00000008)
-#define FGP_NOFS		((__force fgf_t)0x00000010)
-#define FGP_NOWAIT		((__force fgf_t)0x00000020)
-#define FGP_FOR_MMAP		((__force fgf_t)0x00000040)
-#define FGP_STABLE		((__force fgf_t)0x00000080)
-#define FGP_DONTCACHE		((__force fgf_t)0x00000100)
+#define FGP_NOWAIT		((__force fgf_t)0x00000010)
+#define FGP_FOR_MMAP		((__force fgf_t)0x00000020)
+#define FGP_STABLE		((__force fgf_t)0x00000040)
+#define FGP_DONTCACHE		((__force fgf_t)0x00000080)
 #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
 
 #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
diff --git a/mm/filemap.c b/mm/filemap.c
index 6afec636881f..e6580291f218 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1994,8 +1994,6 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 
 		if ((fgp_flags & FGP_WRITE) && mapping_can_writeback(mapping))
 			gfp |= __GFP_WRITE;
-		if (fgp_flags & FGP_NOFS)
-			gfp &= ~__GFP_FS;
 		if (fgp_flags & FGP_NOWAIT) {
 			gfp &= ~GFP_KERNEL;
 			gfp |= GFP_NOWAIT;
-- 
2.47.3

