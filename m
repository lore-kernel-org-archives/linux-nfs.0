Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792879915;
	b=kulWH/v3BdM7tgy1Syb1JTbSmxOYJmWxnEQTh3qBheuo2faSirCTV1K/hd+Bfme/oLRq
	 SDTVcoIoDz6a6BlLpGuLMXSzfQ1LV3OkhUQaIOdDbpye0p6+x5vKG1nFCKJdRSl6ex1Eg
	 GZW3Zf7vc4X+vGea3/5TcWgknExbrA2VYhbvX+lSD9NX9QuKd76FQRhbtQz8XZNcIvSiE
	 qUxLeQRee241vC+ZwCJh0lDa5DztopwhsGsofzGARRpeIvBJLf1TG/aQ7um8VNQ7fJJpG
	 EfUbWSkC+xnk1TY+BcBxWou5HxqjoKvKrMlcviRWLK+S8a7FovVb5w38+tB4voyfSNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792879915;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=tUgGIcvDGljs6JV92kTmhIbZKtK+itmmn1A1LPaiDgk=;
	b=giMwVen0WMkOGQkB9Sk74v7LuRi8sZJaRP/UuLv2flExlP2wpRDma/d/ANtuzJcyMp8Q
	 oR+/qWienTl6ux7LSTY5xrXH8m9W60Y1qmB7EY9GjoEp6Ln3P1eCp/R2AM4mp4Bc2rLl6
	 ogannCWziS1CC8timfDOoQ1C7WgwKdRULlVihar+JWBOpBi+abrxz80sMMWAr5XXvbQgC
	 r5mCnWC2CSZuFxLXylv576jmFbzP0nnPd9xRvqk3kX3YijAQmK1v2xV2Dg2frVL1u0krZ
	 XcoR5y090eA5mpff6J0ZsjBV4YPG2NTbxwhTOBW3YxvGH6axM9tUb8MUVuxHxy+4DMw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CuREB7IO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3655606A321;
	Sat, 24 Oct 2026 22:11:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CuREB7IO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58AB91F01825;
	Sat, 24 Oct 2026 22:11:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792879914;
	bh=tUgGIcvDGljs6JV92kTmhIbZKtK+itmmn1A1LPaiDgk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CuREB7IOMN2NKpDY3nvb9Hvprvj3hmwqsWwP16ef3jlFr3t7Ur0mgRRzuskFM/06C
	 lXufNJ+/AxmsuNX9pO6POW7tgjYBTtwvuuz8GZcfhUjT3D9uIDjMXIvLv+ep+H4043
	 jH0e469PlREwwW3jh+khoWs3UwUZI/ozw2yLkjssEeNNMSb7eNIvWjtuLMDsmc8FY+
	 mFoqZRv1lSTZIEeSK0lV7n9yWlZhDch4yn20LHDBJdP4nPJOMtS5uD0jUCjTkJhQWc
	 hVG7SK9N/emvItxZBOEn7afRFx2qtePEP6IRa0Xe3cKvhRRz0+YIGxB2hS3Rdgbbfy
	 kkm7MGxyCcnng==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: [PATCH v9 1/6] mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
Date: Sat, 24 Oct 2026 18:11:47 -0400
Message-ID: <20261024221152.6965-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261024221152.6965-1-snitzer@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
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

A cached lookup in __filemap_get_folio_mpol() that finds a folio marked
dropbehind clears the flag, and subtracts the folio from
WB_DONTCACHE_DIRTY if PG_dirty is set.  But filemap_dirty_folio() sets
PG_dirty before folio_account_dirtied() counts the folio, under the
i_pages lock and without the folio lock.  A lookup between the two
subtracts a folio that was never added, and folio_account_dirtied(),
finding the flag clear, does not add it either, so the counter the
DONTCACHE writeback kick reads falls short and can go negative.  A
lookup without FGP_LOCK also races with the paths that uncount a dirty
folio, which hold the folio lock: folio_clear_dirty_for_io() clears
PG_dirty and then tests the flag, so a lookup between the two leaves
the folio counted with no one to uncount it.

Every path that uncounts a dirty folio holds the folio lock, and
folio_account_dirtied() sets the folio's dirty tag in the same i_pages
section that counts it.  So clear the flag with the folio locked.  A
lookup without FGP_LOCK takes the lock with a trylock.  Under the
i_pages lock, test both PG_dirty and the dirty tag: the folio is
uncounted only when both are set.  Neither alone says that the folio
is counted.  A dirtier past folio_test_set_dirty() but not yet counting
has set PG_dirty, not the tag.  __folio_cancel_dirty() uncounts a folio
and clears PG_dirty, but leaves the tag until writeback or truncation
clears it.  Under that lock the wb is
inode_to_wb(), as in folio_account_dirtied() and inode_do_switch_wbs(),
which moves the counter by the same tag.  A lookup that finds the
folio locked by another task leaves the flag set, as it would have
been without the lookup.

Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on the v8 review questions, with the code that answers each:
    
    - Stale dirty tag.  __folio_cancel_dirty() clears PG_dirty and
      uncounts the folio in folio_account_cleaned(), but leaves
      PAGECACHE_TAG_DIRTY set.  filemap_clear_dropbehind() uncounts only
      when folio_test_dirty() and the tag are both true, so a stale tag
      does not uncount twice.
    - Locks.  filemap_clear_dropbehind() holds the folio lock (FGP_LOCK,
      or folio_trylock() and a check of folio->mapping) and the i_pages
      lock.  __folio_mark_dirty() counts in folio_account_dirtied() and
      sets the tag under the i_pages lock.  The uncount paths
      (__folio_cancel_dirty(), folio_clear_dirty_for_io(),
      filemap_unaccount_folio(), the folio split) hold the folio lock.
      inode_do_switch_wbs() moves the count under the i_pages lock.
      inode_to_wb() accepts the i_pages lock in its lockdep check.
    - Trylock failure.  The folio keeps PG_dropbehind, as if the lookup
      did not occur.  The count does not change.

 mm/filemap.c | 57 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 44 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 00fd89cf6f550..5176c4125a4db 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1927,6 +1927,48 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
+/*
+ * Clear the uncached flag of a folio a cached lookup found, and take the
+ * folio off WB_DONTCACHE_DIRTY if it is counted there.
+ *
+ * folio_account_dirtied() counts a dropbehind folio under the i_pages lock,
+ * in the section that sets its dirty tag, after PG_dirty has been set
+ * without the folio lock.  Every path that uncounts a dirty folio holds the
+ * folio lock.  So with the folio locked and the i_pages lock held, the folio
+ * is counted when both PG_dirty and the dirty tag are set.  PG_dirty alone
+ * is not enough: a dirtier past folio_test_set_dirty() but not yet counting
+ * finds the flag clear and does not count the folio.  The tag alone is not
+ * enough either: __folio_cancel_dirty() uncounts a folio and clears
+ * PG_dirty, but leaves the tag until writeback or truncation clears it.  A
+ * folio another task has locked keeps the flag, as it would have had this
+ * lookup not run.
+ */
+static void filemap_clear_dropbehind(struct address_space *mapping,
+				     struct folio *folio, bool locked)
+{
+	unsigned long flags;
+
+	if (!locked) {
+		if (!folio_trylock(folio))
+			return;
+		if (unlikely(folio->mapping != mapping))
+			goto out;
+	}
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
+}
+
 /**
  * __filemap_get_folio_mpol - Find and get a reference to a folio.
  * @mapping: The address_space to search.
@@ -2058,19 +2100,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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
+	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_dropbehind(folio))
+		filemap_clear_dropbehind(mapping, folio, fgp_flags & FGP_LOCK);
 	return folio;
 }
 EXPORT_SYMBOL(__filemap_get_folio_mpol);
-- 
2.52.0

