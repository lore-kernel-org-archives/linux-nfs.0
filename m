Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723553;
	b=zUMuoKuAR1JmVTZ/AWK+Y8sFaHw9ZJHz1l+zK1Q6MSoYeJU4I4Zk+DL40G5KNmt8+naP
	 TbaTVGPUEheKG656fRKza5LjB5J0v3zc7t2sidIvO//uop/yWEPr87CtOWHI7Ge2SUhpy
	 zqgqso6RztLKrsRJiLNqnC+H8JuE1TAUQKeE55ttysGWy1PuE2b4gWqFhqBQEovQXTHEE
	 8JfiNVOqts6q2HBzRY4Y/Fmil3j/Y+9VIhdvfDeEAmLgXSBOOtJdF+kmMhmnO4X99KAm9
	 +oYPa7mR1g3wCB5dke+hI6ch2KG7DlRYaIX2zqtv9RpGH/u6+O6vnKGy5kI+9or78jA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723553;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ab6Sr4GaaDc43At8JZYtLZu8p9QZmk29CqcWKokueoc=;
	b=4JBfVlRwlX0M6TShaPfr/dCFVuuX0QOmN8J4n2lPHAc55gvf2m8Grl62+LTNInQ0MfRw
	 9VuF2rd54DHCQg0Qde1NX5ccRV8lCJSPYFIA8qZ1atNA152pHq84FcXCWaBTiDuU/QPas
	 u7a319P2CMg7rXoTHKbd1RFwrGYFIqhQ5/ST65raeayWpNcMRuKztaT6UCjLauW0DUpVH
	 7bMz8nJhSoI+udOr4rdVj6xTPRnezBhKbh3+BGdxG4g/4pHmMujdxwHhmNKdJLXNAV+UL
	 CAdFyYV/ezaNdKMjISaoJvFqhm847JQ/zrLcp3KfFrFfMpNBI34QoDdyUASIus6Bs4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dOpjgkUW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12841606A330;
	Fri, 23 Oct 2026 02:45:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dOpjgkUW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6F5EB1F01825;
	Fri, 23 Oct 2026 02:45:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723552;
	bh=ab6Sr4GaaDc43At8JZYtLZu8p9QZmk29CqcWKokueoc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dOpjgkUWNv20BI+9ztAAZyN/3F0qcT/fj1FYbSwljuQfllhjwb7cy+ADNwZQsmhAF
	 4BqdGvJ39s+oqiITxKh7kYGLqz97oaLBy5Efn9CWDPXpuVPI3rNwG5nZLmTBP22wNv
	 6R9BLFB5kSoZpQ9CS+XcSJ9Q0bTeyw+l1HFiD4dgF+JCzc1ThhDHCn3oxYg1zHmfop
	 olh4Lp43lWPRbyRmCPbpV9JfCi0/ESNhA11Sn9iIl+MpSKv42px00dLB4iT8tqCkR6
	 EMsBxnid6MLwquOyKxHnxaUKXwzJEhzdioiWeHb1nuxFpdhovjaUCEnBWWtixU7NbQ
	 7erpFEFNNTbLQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v8 2/7] mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
Date: Thu, 22 Oct 2026 22:45:43 -0400
Message-ID: <20261023024548.71123-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261023024548.71123-1-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
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
section that counts it.  So clear the flag with the folio locked,
taking the lock with a trylock for a lookup without FGP_LOCK, and test
the dirty tag rather than PG_dirty under the i_pages lock: the folio
is uncounted only if it was counted.  Under that lock the wb is
inode_to_wb(), as in folio_account_dirtied() and inode_do_switch_wbs(),
which moves the counter by the same tag.  A lookup that finds the
folio locked by another task leaves the flag set, as it would have
been without the lookup.

Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/filemap.c | 54 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 41 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 00fd89cf6f55..1cc28224d547 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1927,6 +1927,45 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
+/*
+ * Clear the uncached flag of a folio a cached lookup found, and take the
+ * folio off WB_DONTCACHE_DIRTY if it is counted there.
+ *
+ * folio_account_dirtied() counts a dropbehind folio under the i_pages lock,
+ * in the section that sets its dirty tag, after PG_dirty has been set
+ * without the folio lock, and every path that uncounts a dirty folio holds
+ * the folio lock.  So with the folio locked and the i_pages lock held, the
+ * dirty tag, not PG_dirty, says whether the folio is counted: a dirtier past
+ * folio_test_set_dirty() but not yet counting finds the flag clear and does
+ * not count it.  A folio another task has locked keeps the flag, as it
+ * would have had this lookup not run.
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
+	if (folio_test_clear_dropbehind(folio) &&
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
@@ -2058,19 +2097,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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

