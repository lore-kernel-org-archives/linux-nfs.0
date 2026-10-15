Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D51DC3EA947
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107201; cv=none; b=ZIkUSiMqwDrSMyM2gA1St4BEJwZOfPH3nla02v+2udxpAbNsRsHavSqOjY9DXiwW32NKusDzfxb9a6gk+BuGwHaoc5M2PBEz6po4BcpPp6G2UJOEfKJhPx+3M+ffONWtM6l8RAFxG09hl2uS5GiXpv7wG3DCfJbfTaLjd30SzHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107201; c=relaxed/simple;
	bh=NDnAnxixoLimel2FFb9zEOOh1HsN7SG32BjklyIkF9w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pzAURjiTvzKt7VEK71xMj+ykjBUD0ZmQi+xq2w/gzbcJlCKAOEarvnvjRyG0yg707fNZ1obFLX1r86EQ0N7XGrW1b3tJgdEgVM4p+xT2FdWfYuYGycjY/2jYoE0FNH2eQxyS8eBsPRrVSXSxGTXu8cKkcGNSh9JQivIOW/4SeLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nzbWYI9v; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nzbWYI9v"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5DAAE1F000C5;
	Thu, 15 Oct 2026 23:33:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107199;
	bh=S7mWB/HkMvRX+27OJfDRqz0u/1c8hcSR7gHODYE36DU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nzbWYI9vKI/tTDUA+H9ofYVeqMcDs9WFXnQxapTZvclGE1hgFml0C4R4jzSpqtKJr
	 4MdQr23HDPHbhPWfOHlpbdkMSfvFW7U7dp2+f+CTrwfw+d+oDEwbQizRruYkFAAI9N
	 L++c8R1O3e4tn4B4d3jkdkEIaq9SlIY9iWicWz52cw1yOyoCe0rzoOifjvAs9tqDLg
	 i7+DCKlkiAafmVZ6c5zcMCHLYwdyxgovbSaDz1YshG92cMXd42jSmBeqSqNpd+WYWV
	 H6h3HVHc637r1NlyaS3HfK5DcRfID+ZcMUio7YjcEJ3XvpvyVzb1GdLt45UNs15Gum
	 7NUjIRr94h+lg==
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
	linux-mm@kvack.org
Subject: [PATCH v4 07/10] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Thu, 15 Oct 2026 19:33:06 -0400
Message-ID: <20261015233309.42999-8-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A folio allocated by an RWF_DONTCACHE write is marked dropbehind before
it is dirtied, so folio_account_dirtied() adds it to WB_DONTCACHE_DIRTY
and folio_clear_dirty_for_io() or folio_account_cleaned() subtracts it
when it is cleaned.  Nothing marks a folio that already exists.  A
caller that sets PG_dropbehind on a folio that is already dirty
unbalances the counter: the clean subtracts what was never added, and
once the counter goes negative, wb_stat_sum() reads it as zero and the
DONTCACHE writeback kick stops writing anything back for every writer
on that bdi_writeback.

Add folio_mark_dropbehind(), the inverse of the clear in
__filemap_get_folio_mpol(): with the folio locked, mark it and, if it is
dirty, add it to WB_DONTCACHE_DIRTY.  The folio lock orders this
against dirtying and against folio_clear_dirty_for_io().  A concurrent
lookup without FGP_DONTCACHE that clears the flag again subtracts what
this added.

The name follows folio_set_dirty() and folio_mark_dirty(): the first
only sets PG_dirty, the second also accounts the dirty folio.
folio_set_dropbehind() likewise only sets PG_dropbehind, and
folio_mark_dropbehind() also accounts it in WB_DONTCACHE_DIRTY.

A later commit uses it in NFSD to drop a page shared by two misaligned
WRITEs once both have written it.

Cc: Jeff Layton <jlayton@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Matthew Wilcox (Oracle) <willy@infradead.org>
Cc: linux-mm@kvack.org
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 31 +++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0adfa6605653d..3012bd95812a1 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -1310,6 +1310,7 @@ void end_page_writeback(struct page *page);
 void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
+void folio_mark_dropbehind(struct folio *folio);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index 00fd89cf6f550..ed7e4dbea653f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1644,6 +1644,37 @@ void folio_end_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_end_dropbehind);
 
+/**
+ * folio_mark_dropbehind - mark an existing folio dropbehind
+ * @folio: the folio, locked by the caller
+ *
+ * Mark @folio so that the writeback that cleans it drops it.  A folio that
+ * is already dirty is added to WB_DONTCACHE_DIRTY, as folio_account_dirtied()
+ * would have added it had it been marked when dirtied, so that the clean
+ * that subtracts it leaves the counter balanced.
+ */
+void folio_mark_dropbehind(struct folio *folio)
+{
+	struct address_space *mapping = folio->mapping;
+
+	VM_WARN_ON_ONCE_FOLIO(!folio_test_locked(folio), folio);
+
+	if (folio_test_dropbehind(folio))
+		return;
+	folio_set_dropbehind(folio);
+	if (mapping && folio_test_dirty(folio) &&
+	    mapping_can_writeback(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		struct wb_lock_cookie cookie = {};
+
+		wb = unlocked_inode_to_wb_begin(inode, &cookie);
+		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, folio_nr_pages(folio));
+		unlocked_inode_to_wb_end(inode, &cookie);
+	}
+}
+EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
-- 
2.52.0

