Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362170;
	b=JurvepcIm9oJXTFlJR0BLeDGmulI3vdVrb6K1lxIva1ep2rENSi81pPKVBsQgsyF5rW6
	 Rxz1Pif6paAz/i4KFEvhWYYEKPQxkllx6/6U8upp1SGeATRUhLxo8h8eDlLqC80GXKRmH
	 AdnUPiBfq4vkv+iLOpPScQqvLYy1A0ILSoqqnn+f8PwqBHrZdaHvo3ZXGvRKAbOgES4bG
	 kq8SyeYPEBzVzOQaPxXY8P23392Uy0uh9j/oJsYaE2wDH8lLXyTXMwIGq6WnleCKDfdAB
	 llI0TN7sFTSxPJYtmMcxusxrwDAC3B0V/85kUTJRFpke9kEZYggr8CCg2oFinhNDtwA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362170;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=FRT2/+R9YmYPDM76NCkeURQmSSsjMxRjRdu/RF1CsXY=;
	b=sVQSMcTEJzYYYYfsl8uxML+qQXzKIwVjnRwX/NwCewg3Xi34HMv5inFtfH/lptm2nNkX
	 b7kbVYbr5aljzD34kXBNM0HW6Ys2sA2oyaTpWQZrEXtVSB8c1+lxHC8DjC3IH+CRqEYS4
	 NEMKfAhvKovCjvHY1V4FYjyR9raizi33xC4LF8YpbD1D9VdUg5KCwfq2eTnJf+wbR/bMk
	 pINWn6wOeGA3Q0Dar0EYM8h9d0L/JVJvff6mHLPHZCbstesmJ4mfeFnZj9BUo0qZy6Hpe
	 gcEORn85jQinykpOzSJAaYFf+YoMSq1RHQS4YLNWlWj/KOjydHTukySgWmEu5IBwoaw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mpg1UtT6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86D06606A32E;
	Wed, 11 Nov 2026 01:56:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mpg1UtT6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E3341F0089F;
	Wed, 11 Nov 2026 01:56:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362170;
	bh=FRT2/+R9YmYPDM76NCkeURQmSSsjMxRjRdu/RF1CsXY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mpg1UtT6dT9eaqV2X2DduK6rF23aTMOHShI78LRfsnLuawPtMFs+v3lyxU2KCkAzv
	 Me791F2G6OqP0+tNofh5dIhQjU2I8x4j48StC/PnArlXUL/VzochcCJOCszw6Wm472
	 9AL0zDwr2YKGUCkdvckAvakA+O8RVVYaUHZYALq1+V5ypxDT84Q0VCSX374JY6a9n+
	 zAZBylSQOUTdTw6NMgTTdwWCVppy82x/DsFM0wZ10scUCzsQSpNJTNLBubLJaUycri
	 /XEz5ajHgnclAVzbO476rAjiQ+hzBjOcOBCgmKQKR8kpK9cx5wW7wJAgTC2voK6HXa
	 Z4De0bYYEVmdA==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v11 1/7] mm: move clearing the dropbehind flag of a found folio into a helper
Date: Tue, 10 Nov 2026 20:56:01 -0500
Message-ID: <20261111015607.46338-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261111015607.46338-1-snitzer@kernel.org>
References: <20261111015607.46338-1-snitzer@kernel.org>
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

Move the code in __filemap_get_folio_mpol() that clears PG_dropbehind
on a folio found by a cached lookup, and takes the folio off
WB_DONTCACHE_DIRTY, into filemap_clear_dropbehind().  No functional
change.  The next patch changes the helper.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/filemap.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b04be64a5069f..437113addbddf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1956,6 +1956,24 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
+/* Clear the dropbehind flag of a folio that a cached lookup found. */
+static void filemap_clear_dropbehind(struct address_space *mapping,
+				     struct folio *folio)
+{
+	if (!folio_test_clear_dropbehind(folio))
+		return;
+	if (folio_test_dirty(folio) && mapping_can_writeback(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		struct wb_lock_cookie cookie = {};
+		long nr = folio_nr_pages(folio);
+
+		wb = unlocked_inode_to_wb_begin(inode, &cookie);
+		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
+		unlocked_inode_to_wb_end(inode, &cookie);
+	}
+}
+
 /**
  * __filemap_get_folio_mpol - Find and get a reference to a folio.
  * @mapping: The address_space to search.
@@ -2087,19 +2105,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 	if (!folio)
 		return ERR_PTR(-ENOENT);
 	/* not an uncached lookup, clear uncached if set */
-	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_clear_dropbehind(folio)) {
-		if (folio_test_dirty(folio) &&
-		    mapping_can_writeback(mapping)) {
-			struct inode *inode = mapping->host;
-			struct bdi_writeback *wb;
-			struct wb_lock_cookie cookie = {};
-			long nr = folio_nr_pages(folio);
-
-			wb = unlocked_inode_to_wb_begin(inode, &cookie);
-			wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
-			unlocked_inode_to_wb_end(inode, &cookie);
-		}
-	}
+	if (!(fgp_flags & FGP_DONTCACHE))
+		filemap_clear_dropbehind(mapping, folio);
 	return folio;
 }
 EXPORT_SYMBOL(__filemap_get_folio_mpol);
-- 
2.52.0

