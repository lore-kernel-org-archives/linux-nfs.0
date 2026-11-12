Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510558;
	b=GvCf+eqdMI2R8vn7lEhIYi1QZWCcALSl/f/+tIy13Y83KxkKTGP7mndSBZx69zBBNVuX
	 +yDMTDu2TftnWgZst+ZvxMGHVWI8/iqQC28NP771/g02wi5lbiJO024P1et4tdRhUKXyP
	 sDwMZouWPZZ2YwBhJ8pWvBV74mrmMBJq3cc/HWrAWMF9HS8kJjGI0H8KqNNgule6delhu
	 Qhdzg9L6qw3GOEfpZrOinOiro48pBOfGVHVahKOHNk97NIMpTUMshj82x+AmaZk+GTTb8
	 hEkA2dETqIaQ5eAVj2R1Y553ALbRmYx2Pa+V4DtMMOdqOJOlR0D+IkEX+FFi5IVtwjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510558;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=tnDCs+7uPBjV4AWzwRSdGW/2w1/1J5xqMVOU9/AJamg=;
	b=d3fgV+UGdeBh3YkqfM/grOzhDxD+88Bs74Dr9G/u69oZixRI1W/9MUrIYzhm0bW13XjJ
	 6W7hnFDjayqin+Z4JjeBWNtzFkhpDysIwmoTgyRGQDt3N3ct53Sjktm8fQFt/S8Ovk8B4
	 J/IqSV25mtsQsF2/aMs/bYi0B/kK9+/mfKiMPacdVHggyVXbaBccFF2enIlIhzkeA885p
	 vXrHtElCH4Eygncy/8yRY+JLuCmsKW0UCchAo1DMXKEFUt57dor2oYKHvY+8AupMBsloB
	 OwbvFZ7vao7tGbKc/w17cXZpl7/9IZDpCl31KSyBY/UrgzG9pbiiYC2Ynsgse902v/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="bRB/Zcj5";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA949606A880;
	Thu, 12 Nov 2026 19:09:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bRB/Zcj5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 704B21F000D0;
	Thu, 12 Nov 2026 19:09:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510558;
	bh=tnDCs+7uPBjV4AWzwRSdGW/2w1/1J5xqMVOU9/AJamg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bRB/Zcj5tBHqofQ1FhMUoIae7WIVhuFumByqTXTwNMROaKdkdEhhKzAuo3L+PSEWA
	 jsmvOP0LuwA7NC8AL+y1lWWToofAEXl93LpuN75PVTgKPV0WvznroS38D72xnXOnbX
	 +fbeYmyTbMfQsXaKotTl/AuXa9s/f7GKkoexAcW3GSEotWqMizZhL0w1w8wQq7KDO6
	 qgN4rCP16V3UPJuz06vZOKsPFl/ik1T/wHkd6XdoRqJ0V0ujf6qYEmO2ukYrYkP17k
	 5/2grxcRwprHDzvjJ2sykwsEZZz9voqXZp7xNxwQiHimSRA/Tgla+WWWzB2/4pHdeS
	 MHztBApi+OluQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v12 2/7] mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
Date: Thu, 12 Nov 2026 14:09:05 -0500
Message-ID: <20261112190911.84702-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261112190911.84702-1-snitzer@kernel.org>
References: <20261112190911.84702-1-snitzer@kernel.org>
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

A cached lookup that finds a dropbehind folio clears the flag and
subtracts the folio from WB_DONTCACHE_DIRTY if PG_dirty is set.  That
test races with the dirtying of the folio.  filemap_dirty_folio() sets
PG_dirty before folio_account_dirtied() counts the folio, so a lookup in
between subtracts a folio that was never added.  The lookup also does
not hold the folio lock.  Every other path that subtracts a dirty folio
from the counter holds it, so the lookup can subtract the folio a second
time.  Either way the counter drifts, and once it is negative the
DONTCACHE writeback kick writes nothing.

Fix this by having filemap_clear_dropbehind() clear the dropbehind flag
of a folio that a cached lookup found, and take the folio off
WB_DONTCACHE_DIRTY if it is counted there.  With the folio locked and
the i_pages lock held, the folio is counted if both PG_dirty and the
dirty tag are set.  A folio that another task has locked keeps the
flag.

Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/filemap.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 437113addbddf..98ce955404127 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1956,22 +1956,36 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
-/* Clear the dropbehind flag of a folio that a cached lookup found. */
+/*
+ * Clear the dropbehind flag of a folio that a cached lookup found, and take
+ * the folio off WB_DONTCACHE_DIRTY if it is counted there.  With the folio
+ * locked and the i_pages lock held, the folio is counted if both PG_dirty and
+ * the dirty tag are set.  A folio that another task has locked keeps the flag.
+ */
 static void filemap_clear_dropbehind(struct address_space *mapping,
-				     struct folio *folio)
+				     struct folio *folio, bool locked)
 {
-	if (!folio_test_clear_dropbehind(folio))
-		return;
-	if (folio_test_dirty(folio) && mapping_can_writeback(mapping)) {
-		struct inode *inode = mapping->host;
-		struct bdi_writeback *wb;
-		struct wb_lock_cookie cookie = {};
-		long nr = folio_nr_pages(folio);
+	unsigned long flags;
 
-		wb = unlocked_inode_to_wb_begin(inode, &cookie);
-		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
-		unlocked_inode_to_wb_end(inode, &cookie);
+	if (!locked) {
+		if (!folio_trylock(folio))
+			return;
+		if (unlikely(folio->mapping != mapping))
+			goto out;
 	}
+	if (!mapping_can_writeback(mapping)) {
+		folio_clear_dropbehind(folio);
+		goto out;
+	}
+	xa_lock_irqsave(&mapping->i_pages, flags);
+	if (folio_test_clear_dropbehind(folio) && folio_test_dirty(folio) &&
+	    xa_get_mark(&mapping->i_pages, folio->index, PAGECACHE_TAG_DIRTY))
+		wb_stat_mod(inode_to_wb(mapping->host), WB_DONTCACHE_DIRTY,
+			    -folio_nr_pages(folio));
+	xa_unlock_irqrestore(&mapping->i_pages, flags);
+out:
+	if (!locked)
+		folio_unlock(folio);
 }
 
 /**
@@ -2105,8 +2119,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 	if (!folio)
 		return ERR_PTR(-ENOENT);
 	/* not an uncached lookup, clear uncached if set */
-	if (!(fgp_flags & FGP_DONTCACHE))
-		filemap_clear_dropbehind(mapping, folio);
+	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_dropbehind(folio))
+		filemap_clear_dropbehind(mapping, folio, fgp_flags & FGP_LOCK);
 	return folio;
 }
 EXPORT_SYMBOL(__filemap_get_folio_mpol);
-- 
2.52.0

