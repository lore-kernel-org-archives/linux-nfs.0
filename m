Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CC492DC321;
	Thu, 20 Aug 2026 19:34:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254445; cv=none; b=Up2JbtLLh227vjaG++wgfPhV/LUl94ouZW3lBfx7iEDTSCHJui4Hu8vE2aMpGOAm3z1rmRBmI/k0GASBSlzm03LH4317RAmy0thA9ulL+AZpHnSw0Y0hXB2rLdwQ0vG8C9OBEXnASxUXRbXXrwWz458HwwhA+gdmFeeQxn/pEC4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254445; c=relaxed/simple;
	bh=vSAr1RpfpduBFOTvFwyav8Uq01E0kWFuwocOMX91SGk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MGjvv3DV3PDhmRLC5666oSU+JHk6JN0cTSB7ofyTV5ure6nPM4DmaOFbeL65WgW2rBbxMPne6fbOQ9VjtRiXOLmo3wE3ULrEzDuF5l+ZG3gQWf+uNMbNdhI48P3wDHTxj541F+6GKVH5R9j+4KN9zwYsDEh2pO/769QbqfZk9R4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=tq6Mqh4T; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tq6Mqh4T"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=xKg7WlSpHg8zkU2PKR4Y+r4BI3Zw98IOJ25ILY50rro=; b=tq6Mqh4T48Jf3Da3GNPxAAU609
	LuKgG3yortQBL557VvQ0sNunQjpRfZtt+QegAE0dc+d+LvNeVWyzfh2e35JYjQhHUwCZat4vHDaFZ
	Mq175d4FecV7kkHIQQHXisYFB2pDFA4lHGs6CIhkPlbgFByTKlCG9XaPSne5BGB93pxFBeZAelkRS
	f7trBxy2Y6Se94hlwmYcNmy+BE29xWxRo4bqMWY7cKSNurtRsDUSIsZr8BPgOTVKm0nfmLUZ9YgXC
	SC8rE7xDMkJc0wXq05ny3VSRNhn7SU6zzneE9hRHfidDo/w4gX5cPh9mByyFugpbMkbbybEVMcZc6
	xVxdJkNA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WH-0000000GALh-0i2b;
	Thu, 20 Aug 2026 19:33:45 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <brauner@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>,
	David Sterba <dsterba@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org,
	Pavel Begunkov <asml.silence@gmail.com>
Subject: [PATCH 5/7] orangefs: Use filemap_invalidate_pages()
Date: Thu, 20 Aug 2026 20:33:38 +0100
Message-ID: <20260820193343.3852967-6-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260820193343.3852967-1-willy@infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This pair of calls simply open-codes Use filemap_invalidate_pages(),
so convert it.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/orangefs/file.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/orangefs/file.c b/fs/orangefs/file.c
index 42591252e239..36e3685f7e89 100644
--- a/fs/orangefs/file.c
+++ b/fs/orangefs/file.c
@@ -306,9 +306,7 @@ int orangefs_revalidate_mapping(struct inode *inode)
 	spin_unlock(&inode->i_lock);
 
 	unmap_mapping_range(mapping, 0, 0, 0);
-	ret = filemap_write_and_wait(mapping);
-	if (!ret)
-		ret = invalidate_inode_pages2(mapping);
+	ret = filemap_invalidate_pages(mapping, 0, OFFSET_MAX);
 
 	orangefs_inode->mapping_time = jiffies +
 	    orangefs_cache_timeout_msecs*HZ/1000;
-- 
2.47.3

