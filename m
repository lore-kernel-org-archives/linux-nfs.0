Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362171;
	b=V+Ib7wisQPq1EniKg25s3ztmdKwdIViDm5G1IPVfDPm8LKpJcMuYMfMDsb05i0oHSgm0
	 1Sd8Gp0h7S0+TJYR1MH/c1NcBad4EjlksvBqj+pRJkkrLS8RwioEQhX+QQeek+pvxYZ3X
	 +ErPE4LdQ1FDpuHHP065VqQg+t6KTKNAyLU541nVq2z2MSpqURpyyI5aq//nk0zXOKU6w
	 4uSjjqkuPvLCUICJc+3Lw3oDUzGRDbQn0NUUjZoTIodjVAOrlHvj1I2RLaqgepcSJ0cgQ
	 L0+2r+Q2fS22SNzn2nSVZaO1wZiDIE6OaXT2IO7Ge3BiBitrusgxOqcmK4kIhfms5aw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362171;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=tnDCs+7uPBjV4AWzwRSdGW/2w1/1J5xqMVOU9/AJamg=;
	b=BhT7qNpkxRrboLRxYjw3QuQe9eYLfOi5UHtilJEvmtjv44NIx2ozChKacFI8GEJaJP8C
	 /PIvFOrt0lzl7tqjqLGamcOfV4YLzLmVZ0hbgr1l/jF+b+QtZHpXsn9c7lnWO9ppHRb1D
	 IE+x5d5ni/zSoNcGGP8xiyZvqwJLpJLXGYJTjnP1q82EvL8j1GpbU0MxucmeZHlT/hliX
	 KQEA+U+JXBdSd2yVwx7E+ML9sch3OBRG/cKKYvPqEeRxVtXgJ5mCCESonIijCkedpBImm
	 I4Cd5nJObgqknME4nGM6KAkpZAc49RSBEumQSpoLUD7tsZjAzcygsTSSfsaGrC99kCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=itp0oXEf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B995F606A32E;
	Wed, 11 Nov 2026 01:56:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=itp0oXEf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6292C1F0089F;
	Wed, 11 Nov 2026 01:56:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362171;
	bh=tnDCs+7uPBjV4AWzwRSdGW/2w1/1J5xqMVOU9/AJamg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=itp0oXEfchQuxyVTQgHfLH3S90MLaAoZA5X2/d0kX5lDDas4YJK5T4vozbrzLNfpz
	 tryNN9EzJz3tpWsQvXrF9fS6ABhvRXaOtkVSMJEpZjPjBkl9nIkc3PB4gPu4oC1dWP
	 VZKBE/2Sq2SvOBrATM26VzSwJccjHwdrPFFroKHIRhtqetdb0iEpviFLPStr+igjSj
	 sJugrMg6zAR37DnLZl84Fr5ZoEpHw3CFNvaoy6HraT6UBLjb6aTYtimpg/X5GN4MV1
	 jZf199wif6A2IuLSjkZ765v6SEgidSQsnW2tuB4Kp2dhbsQNB0/8gJgO19zSyNYeyX
	 DKQtW64TwMUCw==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v11 2/7] mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
Date: Tue, 10 Nov 2026 20:56:02 -0500
Message-ID: <20261111015607.46338-3-snitzer@kernel.org>
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

