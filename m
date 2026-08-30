Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54FA942A80;
	Sun, 30 Aug 2026 04:19:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063555; cv=none; b=UMPf8gGM8wZF7alBBsT+QFlysjE6brV136tZkYoaMNI5r8ht1PmCLkS4NIRwuE1jcSPP/VS+AxK48kKxRFQQDim9X+oUY+c/VYFUbAR+S/HvF16fpUq6GKsO18hNTx7cB3J/6iBqfIR0XKx3aXqrr6ouRr7T2BwNJJA4oxIUPcQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063555; c=relaxed/simple;
	bh=Moci7V+P1zPT6tbrwh3rkPHgeiAFL932fyc34PPL1O8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=asdcRWkq3kxbQ7ztes/FNs/b8JsXQCYuqnejrpl3XtOwe3HTSbS7EWsFhdOsA+9nZMP8ddvSubCdCbcAkPVOovyhKQOKAXAjLpSTsb/7pGIjnxAicZrqBi1Pc/7KJQOpgLZwxiN5uPSHoiJu8pwcHhQX7Fmfzny3AgX6yVM2wv0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=TisMTFuh; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TisMTFuh"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=17KDooFJoYeOcgqtwlU5ofiBDQP57dVuWi84LFJRoDU=; b=TisMTFuhPCehbA7/9nutMd5vZd
	dGAVseYx9yVTpk//u4fNFf54zujpuIxBHFGc46tKpAUpq1GZxXRPYSn7FYTAklF/bfAtpWBCIi0oC
	1J3BDbE+FEpcCaXt3JF9blBGINHRtNtYhss61eG4phR8MkG4W5HyPetKV9dWjA59icSHtWvcNRJGN
	GiKLqnHuePZ0aPQJE7gGK8fblo+0p7PB2bv+IKL2GOeSR7hWHlnEOEqpTCSnX98Tgprf0NJ7dTnYt
	1ZXY+Z4uZeCw3nVDigJ0ICzRwqLlMVt5EZEKarX+tOuSAxr98ZRt2QwuDcnBtoKP22oJ8qCVci5uH
	unmVDQ0g==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000hO-0BzY;
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
Subject: [PATCH 2/9] ext4: Remove uses of FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:49 +0100
Message-ID: <20260830041901.2668-3-willy@infradead.org>
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

Both of these locations are called while a transaction is in progress.
Starting a transaction uses memalloc_nofs_save(), so we are already
prevented from recursing into the filesystem and using GFP_NOFS was
unnecessary.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/ext4/inline.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index ceee69a66482..1884abb09614 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -601,9 +601,7 @@ static int ext4_convert_inline_data_to_extent(struct address_space *mapping,
 		goto out;
 	}
 
-	/* We cannot recurse into the filesystem as the transaction is already
-	 * started */
-	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN | FGP_NOFS,
+	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN,
 			mapping_gfp_mask(mapping));
 	if (IS_ERR(folio)) {
 		ret = PTR_ERR(folio);
@@ -734,7 +732,7 @@ int ext4_generic_write_inline_data(struct address_space *mapping,
 		goto out_release_bh;
 	}
 
-	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN | FGP_NOFS,
+	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN,
 					mapping_gfp_mask(mapping));
 	if (IS_ERR(folio)) {
 		ret = PTR_ERR(folio);
-- 
2.47.3

