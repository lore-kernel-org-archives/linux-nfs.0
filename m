Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510561;
	b=2tkdhGf+jxoJVml/QQl1mRoqonvMtIQ9/PIdIqSlGM7qNQTHvWf7ST7ehxkWvV8eRew1
	 9KPxTDQXDxG7t7Hm9sR20fd3PCOF+gqpOUmAyOapkUuvJzq/KAccEwepUX6OEKicRlv/7
	 VYEjmW6K+FLY1D7ztpWRvsps3kNyB9Rd0it0y7PHtUeGz2gKLRGAWZMu7jMTQmeU9aCiG
	 9vlACoHjj4gSm4JdtqrB1xbG9oOblt48KVZLRcY52tGyNVCNclWZRK1jWKtgDOgFdvGRj
	 JdwTbsedevzFJ0/9Gt3sq+moDnUpyejc5nOdpTct4zpv/Pb03cpP0eomKTjr3DQ7xkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510561;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=wPQ8Y1tJWbMJwqCQRFYzmTJx7xn37wY+MUSLgJe0EEA=;
	b=Ir02Jf+2iNzE2iloPAzM3n8xMNFg9aabNAOYlpCGUwn3WLhWlDpvFLCVus+QGQbCb46+
	 m/sJGpoXKaPQtspeyKIMGEi5l74fSZ5DYR69QZotpqz6I+8gvk69F6DQtAiyAJWbRuv0T
	 F9xGKTlAZRj5vx6RmsO8qAi5rXC/5N7SGtrfDs9UBxRhYHExqr9KfCNZlnvuVUlxcEXCq
	 qI6NvLpBNGTDL3A5vmOty4MPBtoZ2RLnmOb8wcf9bh4PBebeFfzbaJDAXYFoBcsS+Z5le
	 XbPPmg+HALFwZYTwJFDSs64UNh8Z8EBVPcarJJ2Vtv2JCZG3iWBJ1TV45Bsh3XYr0EA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VF+IHUbS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 915B2606A882;
	Thu, 12 Nov 2026 19:09:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VF+IHUbS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EE9721F000D4;
	Thu, 12 Nov 2026 19:09:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510561;
	bh=wPQ8Y1tJWbMJwqCQRFYzmTJx7xn37wY+MUSLgJe0EEA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VF+IHUbScSaLRVacGJckMquVnUyYPaCb/piZVssWyyDGWspFF6vPzpYTnxW8MVLea
	 Qc2eSaEmNkF4oO/zzuVs0PMaP5ZLFLDq9WOO+tsOgVrjtGE3Bue7U+wmnzhixVarZJ
	 kGabJeo5njfhO1zwzt97lpVXtMS0H5SEgmH/3LzguT/oaI53FY4/SHoGaUTSmNhIVH
	 rYayNhFbjql5VaCq0nZ+0In1jfVwONKG5v/Q5Nnf7VvqSyCTNbuTuUc2SBllP+AqWG
	 bWqwTApZ6E6vpU7+iy56QRNFpFRHRLOy50lBkzXpJ+9rmIR1VvbSGZsf0hzDqk4N+L
	 6KFAK7AV5cKfA==
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
Subject: [PATCH v12 4/7] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Thu, 12 Nov 2026 14:09:07 -0500
Message-ID: <20261112190911.84702-5-snitzer@kernel.org>
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

WB_DONTCACHE_DIRTY counts the dirty folios that are marked dropbehind.
When a dropbehind folio is dirtied, folio_account_dirtied() adds it to
the counter.  When the folio is cleaned, folio_clear_dirty_for_io() or
folio_account_cleaned() subtracts it again.  This balances only if the
folio is marked before it is dirtied, as it is for the folios that an
RWF_DONTCACHE write creates.

To prepare for NFSD to mark a folio dropbehind once both writes that
share it have written their parts, handle a folio that is already dirty
when it is marked.  folio_set_dropbehind() only sets the flag.  With it,
the clean would subtract the folio from WB_DONTCACHE_DIRTY although it
was never added, and the counter would go negative.

Add folio_mark_dropbehind(), the inverse of filemap_clear_dropbehind().
With the folio locked, it sets PG_dropbehind.  Under the i_pages lock,
it adds the folio to WB_DONTCACHE_DIRTY if both PG_dirty and the dirty
tag are set.  A dirtier that has set PG_dirty but not yet counted the
folio finds the flag set and counts the folio itself.

Leave a mapped folio unmarked.  Through its page table, a mapped folio
can be dirtied without the folio lock: zap_present_folio_ptes() sets
PG_dirty before the folio is counted.  __folio_cancel_dirty() can leave
a stale dirty tag on a folio.  Then PG_dirty and the tag are both set in
that window, and the folio would be counted twice.  The folio lock keeps
an unmapped folio unmapped.  The dirtiers of an unmapped folio hold the
folio lock, except mark_buffer_dirty() on a file system with buffer
heads.  filemap_end_dropbehind() does not drop a mapped folio either, so
nothing is lost.

The name follows folio_set_dirty() and folio_mark_dirty(): the set
variant only sets the flag, the mark variant also accounts for it.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 42 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 73af18a373670..3f5295d6fd73b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -1306,6 +1306,7 @@ void end_page_writeback(struct page *page);
 void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
+void folio_mark_dropbehind(struct folio *folio);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index 98ce955404127..196c385f29801 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1654,6 +1654,48 @@ void folio_end_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_end_dropbehind);
 
+/**
+ * folio_mark_dropbehind - mark an existing folio dropbehind
+ * @folio: the folio, locked by the caller
+ *
+ * Mark @folio so that the writeback that cleans it drops it.  If the folio
+ * is already counted as dirty, which with the i_pages lock held means both
+ * PG_dirty and the dirty tag are set, add it to WB_DONTCACHE_DIRTY so that
+ * the clean that subtracts it leaves the counter balanced.  A mapped folio
+ * is left unmarked.
+ */
+void folio_mark_dropbehind(struct folio *folio)
+{
+	struct address_space *mapping = folio->mapping;
+	unsigned long flags;
+
+	VM_WARN_ON_ONCE_FOLIO(!folio_test_locked(folio), folio);
+
+	if (folio_test_dropbehind(folio))
+		return;
+	/*
+	 * Through its page table, a mapped folio can be dirtied without the
+	 * folio lock, and PG_dirty set before the folio is counted: with a
+	 * stale dirty tag it would be counted twice.  The folio lock keeps
+	 * an unmapped folio unmapped.  filemap_end_dropbehind() does not drop
+	 * a mapped folio either.
+	 */
+	if (folio_mapped(folio))
+		return;
+	if (!mapping || !mapping_can_writeback(mapping)) {
+		folio_set_dropbehind(folio);
+		return;
+	}
+	xa_lock_irqsave(&mapping->i_pages, flags);
+	folio_set_dropbehind(folio);
+	if (folio_test_dirty(folio) &&
+	    xa_get_mark(&mapping->i_pages, folio->index, PAGECACHE_TAG_DIRTY))
+		wb_stat_mod(inode_to_wb(mapping->host), WB_DONTCACHE_DIRTY,
+			    folio_nr_pages(folio));
+	xa_unlock_irqrestore(&mapping->i_pages, flags);
+}
+EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
-- 
2.52.0

