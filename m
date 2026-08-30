Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52673261B8A;
	Sun, 30 Aug 2026 04:19:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063565; cv=none; b=cFYh38BzhobjHOlpfC8O4W0SWMLpV+8RNXvH+IwmmXH/MgHVosh7/WYlSzMJeO/DhGY8ZNDrxBnmt6XMZxUmkZ4C7NPC8h/kBEts+ZEuqFQDknWMQu7qvl+qOJsoYXJkYazYv4eXWLzSS332iVr/tJ/ESsrs2YFmRXzjaea4QI8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063565; c=relaxed/simple;
	bh=drvPQ9zuvtVNEjvfWiGpirm5x1lLi5QfiCnjV5PlNiw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lgUYI4YAksffEsdtMiIACi7VckLvKVZN3vjuRa/MolARPZe1zF7qqReeNWxDbUSqRodrjSryLsUm7ILXG8uCJpopFHfaeJvnVyrskv6+C2N+v1ntCWsgCYsWX/xatJNLqSmhkVKx0vTnn2Q4NLEX1KJbtC/KI3QWCXenumivYSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=St5YwczI; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="St5YwczI"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=/LhwqzyL2tHWHjKBCqUfd5fZsEqJTMNd4JrJ5Ssrbtk=; b=St5YwczIjGD0oycKcDall0vCVj
	B/1aacESJcnXac0qwwdgA/3w7ddFCpbvgsmZ/nlVJWobcV88bxg9CPvLkAGBCmV8ocwJagWRH8n/Q
	F216KC+E/t18eabT9+uXGIANM5zKCAR54zmlgGDg86mc8YESyhqBWaZu0k8XEEXkc7+Ll73JN1N9e
	S0K736Ep457HSJh8byMrQqKhowm2Z2zDnpX+PtHZrMZDRAXNuO8Q2e3KDVtpG2GzHgIXlWZUeiWzt
	KYUd1hZSWA+A5i6//HQpp0cdcprL0TWsBtQFQSGfDQWm31miYDxSCH2g/AIYWfGA5lOLoy0abA+8C
	1XFm7/+Q==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000i5-2UZC;
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
Subject: [PATCH 8/9] filemap: Remove redundant FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:55 +0100
Message-ID: <20260830041901.2668-9-willy@infradead.org>
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
 include/linux/pagemap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0adfa6605653..3974b063a049 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -929,7 +929,7 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 				pgoff_t index)
 {
 	return pagecache_get_page(mapping, index,
-			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
+			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
 			mapping_gfp_mask(mapping));
 }
 
-- 
2.47.3

