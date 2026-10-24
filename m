Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792879917;
	b=mu2t49uXBAS7A8y7WEJpaYQjxI4vKaP/s0Rfg8C5q3J88LMI6QfpZifhwEjzrIvqZudW
	 KFSqDcp2tNThPnwMHZTLUsBzScjknELEx+6E8ZoM8Dltfup4VBbdZ6tU6ruRXu2xluV4j
	 qlVAA9gmGwWeFP51ni9BEwvoVybP2owd1zquo9a63VAo74TJr32+g9wIrCST0mbR3dS5M
	 ijEtRt1ClvL6pKw02ffokoqSiI55Al50xStf9P8YwnfLs8kimAHlzl8KDUC5eI85emSxc
	 VAJiZ118sLO9zrno43mbpoGuIu9zPHcjKDvSMjnIIvinr2Vfv+2TRk1rF5agkSMB8Fw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792879917;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Tg09X6titA7IGP1wR7K2/LkATJk9RajWO5q1G+Mz+ok=;
	b=ISD2o+idxLP4yG3tn15Sq5rIEhpe4ClSYzuR0P3pT5FBvZP4Qlr2HdAP3Yt/iinW1XUg
	 c0SzPQeCqWlF9fX/RZc76OkVPir0ZyL4pYNEmzvaWG5JD4PaMwpdxPmw5V0dxHYuHQfwS
	 Dl72bf1/PbSflSp1hkJvJmaIhd1OVnk49EbtSVt3DBFDVEwmjRxBrUPqQVQkMw0rC9XUT
	 ATY2HLd31TSb7CYb3WL4OcHw+Y+895Cxng8DPKVljZahp6bnxQPwaZeU6AVWk8UjtQ/QE
	 w8zUDz8kUEnUCEN8a7B07ujMSk7AV/CVmEKyvDA+kxCKoazlZB2uZOovHSU1+3wO2gw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FM6OzY+4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E624606A32E;
	Sat, 24 Oct 2026 22:11:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FM6OzY+4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B9FEF1F01825;
	Sat, 24 Oct 2026 22:11:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792879917;
	bh=Tg09X6titA7IGP1wR7K2/LkATJk9RajWO5q1G+Mz+ok=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FM6OzY+4R5MRFe4kccmBrjSptjtO2q6yIh7M18lDvED4ncBUN3HO6pmiT//00Sej1
	 X9hv+Qsi1D2URlzZ5QLGcU5CJPNDwsnBy+Vmge/Ck7+hIGyyf4wlr4Qgaiay1dng5X
	 VxBBUvDJ5Fu9/R1XWoDR9LTv74L1IFMydFREoztbs1z6quf1rH9Tjnncz1z6Angf4l
	 Ng4MzZMZtg1TWjiA4XYVRjy38ySUy/ZNtscey+JUvKZAG9s42ZkJ39q2aQ0PM6ItVi
	 ILoVHvgyY6UyXq2iOk2GzH79g9cid0x+1wUznYGdMO4MHL+UE+d8H5NK2EHOUbPczW
	 tugql5zuCH8Ww==
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
Subject: [PATCH v9 3/6] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Sat, 24 Oct 2026 18:11:49 -0400
Message-ID: <20261024221152.6965-4-snitzer@kernel.org>
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
__filemap_get_folio_mpol(): with the folio locked, mark it and, if it
has been counted as dirty, add it to WB_DONTCACHE_DIRTY.  Neither
PG_dirty nor the dirty tag alone says that the folio is counted.
filemap_dirty_folio() sets PG_dirty before folio_account_dirtied()
counts the folio, under the i_pages lock and without the folio lock.  A
folio marked between the two would be counted twice.
__folio_cancel_dirty() uncounts a folio and clears PG_dirty, but leaves
the tag until writeback or truncation clears it.  A folio marked with
that stale tag would be counted and never uncounted.
folio_account_dirtied() sets the tag in the same i_pages section that
counts the folio, and every path that uncounts a dirty folio holds the
folio lock.  So set the flag and test both under the i_pages lock, and
count the folio only when both are set.  A dirtier not yet counting the
folio finds the flag set and counts it itself.  Under that lock the wb
is inode_to_wb(),
as in folio_account_dirtied().  A concurrent lookup without
FGP_DONTCACHE that clears the flag again subtracts what this added.

The name follows folio_set_dirty() and folio_mark_dirty(): the first
only sets PG_dirty, the second also accounts the dirty folio.
folio_set_dropbehind() likewise only sets PG_dropbehind, and
folio_mark_dropbehind() also accounts it in WB_DONTCACHE_DIRTY.

A later commit uses it in NFSD to drop a page shared by two misaligned
WRITEs once both have written it.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on the v8 review questions, with the code that answers each:
    
    - Counting rule.  The same rule as filemap_clear_dropbehind() in
      1/6:  folio_mark_dropbehind() counts the folio only when
      folio_test_dirty() and PAGECACHE_TAG_DIRTY are both true.  The
      test is under the folio lock (VM_WARN_ON_ONCE_FOLIO checks it) and
      the i_pages lock.  A stale tag on a clean folio does not add a
      count.
    - Double count.  A folio that has PG_dropbehind returns at the first
      test, before it changes the count.
    - No writeback.  A mapping without writeback gets only the flag.
      folio_account_dirtied() does not count such a folio either
      (mapping_can_writeback()).

 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 42 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

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
index 5176c4125a4db..d0e4d1788fd40 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1644,6 +1644,48 @@ void folio_end_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_end_dropbehind);
 
+/**
+ * folio_mark_dropbehind - mark an existing folio dropbehind
+ * @folio: the folio, locked by the caller
+ *
+ * Mark @folio so that the writeback that cleans it drops it.  A folio
+ * already counted as dirty is added to WB_DONTCACHE_DIRTY, as
+ * folio_account_dirtied() would have added it had it been marked when
+ * dirtied, so that the clean that subtracts it leaves the counter balanced.
+ *
+ * folio_account_dirtied() counts a folio under the i_pages lock, in the
+ * section that sets its dirty tag, after PG_dirty has been set without the
+ * folio lock.  Every path that uncounts a dirty folio holds the folio lock.
+ * So with the folio locked and the i_pages lock held, the folio is counted
+ * when both PG_dirty and the dirty tag are set.  PG_dirty alone is not
+ * enough: a dirtier past folio_test_set_dirty() but not yet counting finds
+ * the flag set and adds the folio itself.  The tag alone is not enough
+ * either: __folio_cancel_dirty() uncounts a folio and clears PG_dirty, but
+ * leaves the tag until writeback or truncation clears it.
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

