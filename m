Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740678;
	b=wlzOXT7l/qax5l9xVGY5OX3v18ztEu27E6GDjczy4CAa1Rq8Qtn1jWDFeaEuN4lEhelk
	 kvor4TtLK5tigM8VTkvV0NbyezkAdeZifhAb5MQ5umDneI+KT4/GRXnqavSVvgLpHCHyD
	 oHfnPkv9HZvRBnrAE1dXwsGWLC0leKongTdRsbeP2Kik45BqE1xk89/RHhm8jr1oSO2kK
	 FurIhRXwiJ9Jr8T6VP5lETd839mI78H1WSKGZPom51JfcOc28yhiV9ySIIwXdiW9fE03P
	 Upy/BMYAsiZKVVchDhpkfokXh91M4nqtr/gCE+xugKMpcFy5RmbXi3U2pOHe6oszSEQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740678;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=gVJkWNRH/ZOu7EDyRusj1WUhQq2Egy1weSR/EP5J5Ds=;
	b=Wb9pSSvizFbQAmXp7jIr0VlZLQcoTCUIjPtWPnEk3WUeHES4nmA6bW/dKEFYRMFWHHCg
	 yYpRosZONe6E4P576YMpuafiCFThZWBS0GnMnwB2Ndx24YPPibtnNG7D2AEpCd5YtrVjG
	 Fx+YfQ0fLmz+7jPMrc+EVyNdcrxNkLqwEVlY9u0dQlOASp3Or7cwYaT8JUR9r3ABdxheL
	 pmW8CbMljgcc3mNqOPV6yUq/U3cBjQa7B+r7fWypfi9K5AhCWBa6nXPIR5l7zpBYTRYPP
	 YekWqvyhNP3mm53TEcfNUK501vBVyuyuvYZ89QOJO1DYjhJwyOZDyybZmZxD13/EPqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T0o7vKa+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27C9D606A331;
	Tue,  3 Nov 2026 21:17:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T0o7vKa+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDA2E1F000C1;
	Tue,  3 Nov 2026 21:17:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740678;
	bh=gVJkWNRH/ZOu7EDyRusj1WUhQq2Egy1weSR/EP5J5Ds=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=T0o7vKa+UViT2kW4nUff14L2tAlAy17Fk4EuqAbYYcAsmVvxZLyN+Tkx2kcVu6m5G
	 7VCiLUxxVY46mpw99qJct2peaQJ3tRJNVG/bmhc3/7y2d7/3dMxh+wR9iTyDBRe2k6
	 /koNMdftwLAgxjQVmjsnBR/velQhVyfN94fsYFwJsq07a4zY0cYyeyhcrgB+VZcnwn
	 AmEhTDdoajDx9TMTa1ssvcBgFCdCHSbQP4KxrrwxCTMxN11VZRH05KU58aibY4pwd/
	 zxxfslS6AQ0mlkro4y8K5T+lUztrdHX3R9an1nLwvt0i7YnWwa1tWvV6G5HjuKkR/H
	 5xDQEcyHtw7Uw==
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
Subject: [PATCH v10 2/7] mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
Date: Tue,  3 Nov 2026 16:17:49 -0500
Message-ID: <20261103211754.35352-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261103211754.35352-1-snitzer@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
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

Fix this by having filemap_clear_dropbehind() clear the uncached flag of
a folio that a cached lookup found, and take the folio off
WB_DONTCACHE_DIRTY if it is counted there.  With the folio locked and
the i_pages lock held, the folio is counted if both PG_dirty and the
dirty tag are set.  A folio that another task has locked keeps the
flag.

Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on questions from earlier reviews, with the code that answers each:
    
    - Stale dirty tag.  __folio_cancel_dirty() clears PG_dirty and takes
      the folio off the counter in folio_account_cleaned(), but leaves
      PAGECACHE_TAG_DIRTY set.  filemap_clear_dropbehind() subtracts the
      folio only when folio_test_dirty() and the tag are both true, so a
      stale tag does not subtract it a second time.
    - Locks.  filemap_clear_dropbehind() holds the folio lock (FGP_LOCK,
      or folio_trylock() and a check of folio->mapping) and the i_pages
      lock.  __folio_mark_dirty() counts the folio in
      folio_account_dirtied() and sets the tag under the i_pages lock.
      The paths that subtract a dirty folio (__folio_cancel_dirty(),
      folio_clear_dirty_for_io(), filemap_unaccount_folio(), the folio
      split) hold the folio lock.  inode_do_switch_wbs() moves the count
      under the i_pages lock.  inode_to_wb() accepts the i_pages lock in
      its lockdep check.
    - Trylock failure.  The folio keeps PG_dropbehind, as if the lookup
      did not occur.  The count does not change.
    - Known window.  A folio can be clean with a stale tag (for example
      after iomap_writeback_handle_eof() skips a folio beyond EOF), and
      an unlocked dirtier can set PG_dirty before it takes the i_pages
      lock.  A lookup between the two sees both bits and subtracts a
      folio that is not counted yet.  The two states look the same in
      these bits.  Only the counter, and so the size of a DONTCACHE
      writeback kick, is affected; data and page state are not.

 mm/filemap.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c75f49563b74b..3a13289c07dc4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1945,22 +1945,36 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
-/* Clear the uncached flag of a folio that a cached lookup found. */
+/*
+ * Clear the uncached flag of a folio that a cached lookup found, and take the
+ * folio off WB_DONTCACHE_DIRTY if it is counted there.  With the folio locked
+ * and the i_pages lock held, the folio is counted if both PG_dirty and the
+ * dirty tag are set.  A folio that another task has locked keeps the flag.
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
@@ -2094,8 +2108,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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

