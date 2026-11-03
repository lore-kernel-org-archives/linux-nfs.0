Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740681;
	b=FczNtmaDxU6mJ/DohrhRGXM+R/xbea0O6wl3mcDNLntQyxCTfLABVZbIkfuBRDajcANf
	 qGMnZ9VpdHRFnBbyMUioHa1bu4BVlxtFc+xZJYFDAX/hTXG77ZvDHOBXyEAAhbIOcplTu
	 9OqLiasP+qhzvUsTVAWuOg+6x4ZKxKqW8rxpx93+cI18SP1cMThPAg9Uewqj9KF7UQX4w
	 7cdN+yPV1oWR/diEkrNLEX1xeiUUWeZzlzj03nipDQ/JUen2TZsB3MWHmkwTMazBlCqn4
	 CZvphc2fjl/C2vEgoWSIHqlxXCC5JNA43PMl990of312ChgtOjsps4zanHyB+HcpB6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740681;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=DI89KFBg08cV0NMoZcQe793KHlTmMZi7dlrFBwSyZaw=;
	b=x4PzAF40GYmR9wgDFgpJ4Cj5ITbTzqjBZkrLcSBG70tcrHv1tX7kAdg0MLBAllYyVLri
	 zNVbHe8iuV9O2wNhnM7YY5YWz5jrvSvPoF0g03+8dahdSaIv9f1EpKmuXnmaBWafCPLWq
	 VyOffbHqjNwuXC/gCzF2FGaNwVkINz1pdhvG6QxYuBO5lzZGOyNMQhbIHz3oADf+UUdM8
	 72R+LPZxo2OZfdXcOe1w83XZ6Nv0NE4el8CQ13vNoB//ORu9SDDsWOMGt43zeZj3COATD
	 a9DxQNodjuQSPpv7cajMG3UH3YpaUnLs082IfoKuVGK9BbwCwhIZ8Ea0P5pMm3MgUFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aUSE2kt3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0164606A334;
	Tue,  3 Nov 2026 21:18:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aUSE2kt3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 738351F00A1A;
	Tue,  3 Nov 2026 21:18:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740680;
	bh=DI89KFBg08cV0NMoZcQe793KHlTmMZi7dlrFBwSyZaw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aUSE2kt3f6UaFdPxcLV4ZJIDjVzGjYBMNsGVkFaf1jo9LkWqkjrz4yl4GpX3IBkTw
	 zIG7m/fXJrWMSoMHe9SSopQykRMeM6LMaz55t+/MiJj59pPWz5CaTQEEj4XQ4bpziT
	 F+/t8qLzhHwcFXI8UlXRZhEFGmUFPGd+rLAGri/sx+ni91puKPc3WwkuMoaG1Rrwt0
	 RdtCnNy0Wj8Lnmw/tsSI5hd+T40vgO/UWTIKJ78LTF2A/YP0dCnbkWkLSBKJkuXv8/
	 /5dmqlkK76mQyL7x72g9ixA1r8WLpTD3pq2tzfCeFl5gr6iwl3abwQbWHWcBz2wFSK
	 oZOpn5JeHMc2g==
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
Subject: [PATCH v10 4/7] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Tue,  3 Nov 2026 16:17:51 -0500
Message-ID: <20261103211754.35352-5-snitzer@kernel.org>
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

The name follows folio_set_dirty() and folio_mark_dirty(): the set
variant only sets the flag, the mark variant also accounts for it.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on questions from earlier reviews, with the code that answers each:
    
    - Counting rule.  The same rule as filemap_clear_dropbehind() in
      2/7: folio_mark_dropbehind() counts the folio only when
      folio_test_dirty() and PAGECACHE_TAG_DIRTY are both true.  The
      test runs under the folio lock (VM_WARN_ON_ONCE_FOLIO checks it)
      and the i_pages lock.  A stale tag on a clean folio adds no count.
    - Double count.  A folio that has PG_dropbehind returns at the first
      test, before it changes the count.
    - No writeback.  A mapping without writeback gets only the flag.
      folio_account_dirtied() does not count such a folio either
      (mapping_can_writeback()).
    - Known window.  As in 2/7: a stale tag together with an unlocked
      dirtier that has set PG_dirty but not yet taken the i_pages lock
      can make this count a folio that the dirtier then counts again.
      Only the counter is affected.

 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

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
index 3a13289c07dc4..5134227ba3a23 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1643,6 +1643,38 @@ void folio_end_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_end_dropbehind);
 
+/**
+ * folio_mark_dropbehind - mark an existing folio dropbehind
+ * @folio: the folio, locked by the caller
+ *
+ * Mark @folio so that the writeback that cleans it drops it.  If the folio
+ * is already counted as dirty, which with the i_pages lock held means both
+ * PG_dirty and the dirty tag are set, add it to WB_DONTCACHE_DIRTY so that
+ * the clean that subtracts it leaves the counter balanced.
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

