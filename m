Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723555;
	b=bhTfgaB/NTNHgAKM3fGCCz6PDJ2JCd9gBT5eKZuH0o1NJGS0TX0utubRtJ0fgXpu4PJZ
	 GffFkCx0dUgM9p3KByS2g5mETEXQkcLKIxfEz5MbjWtiTqug8rdamXtkPxCOW6hSG6r+1
	 sxVA/hwq+nAUDR5HV2yHm4HOhquD+LZgp+5gADZmmUVByhDGs4cTLXvyauNYVS13bOPOd
	 hrhI1T28TVY5g1RQ23YIJMInkkahovvpc40vaDGFWdhaicYAj6gpq0afaIbUdCpWMTsds
	 HQQPFjzLyWM778dJp0DM/PNIuVCTaLojHpDQfCnTy0rqbJWhkMO/z67bBTjcYKfyMXg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723555;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=FJcW7KrcbrxzeDpcYuSEOOuTzC9YVEEotXFe5+tYCuw=;
	b=3VE8PBXRsMnTUdjEkcLkMPJcxZJ+INsxCfUb2X/cmLdnw7REJaWiFYh7BfJwciuFtdb3
	 Vi/BT2mgzS2pbjE/bpbEiyQ4jN3bkGGzWvavkeMWq9HSbgGfbpfE8P32wybFgjVQ57aVS
	 YGx7ItiJ4jwSsmCuIDxryMkYzBeR6y6xC/hnUb8sthVrQhpZ79U6Y++RAY/SeWsfpb24T
	 bkS9iHh0wWP4It4IsTZRYgKVvIKOB+er0CALbg6uqKqmI+kQh1fwkA9w54VFK2WiQQTPd
	 HI/CIIjlWx6t/GX+fAdaOw/DVRH/ZIi3a9WVXPOR3VcIr4ZSBj5y5tpzN4RVRsEHjJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WKPlSc4e;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99FDD606A320;
	Fri, 23 Oct 2026 02:45:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WKPlSc4e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 088FD1F01828;
	Fri, 23 Oct 2026 02:45:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723555;
	bh=FJcW7KrcbrxzeDpcYuSEOOuTzC9YVEEotXFe5+tYCuw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WKPlSc4eioB0oO3aBYZ34PcGIQYEKGjZPiCkmZXHv0ybz0jpmEUuR3XoYr2iluB3/
	 xpWsohlCYSIuZuJJ60AwyyLO/vlOVrHugMBonjkv+8u9y7o84ecGANPK8r9zEgkWG/
	 YkT8DJyRRDNCVuHZuIFHqoTeZ7IpurQKnCLem/22qTeiSAHCVRL8wHJmskNh71qzz+
	 hB4wKkHPX9fIaOHvOlVl9hU7KU/2WKFfamVZ2KcuHE+71TAgVURbzJq/AtDcu1Do3j
	 dT/c7AQonI7+AlDhZ6t0Gibipt29hWGfnIoSk+InLrQptQrn9niZhUcnIeB/GJZPjH
	 ANRPELDTH4Z7w==
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
Subject: [PATCH v8 4/7] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Thu, 22 Oct 2026 22:45:45 -0400
Message-ID: <20261023024548.71123-5-snitzer@kernel.org>
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
has been counted as dirty, add it to WB_DONTCACHE_DIRTY.  PG_dirty is
not the test for that: filemap_dirty_folio() sets it before
folio_account_dirtied() counts the folio, under the i_pages lock and
without the folio lock, so a folio marked between the two would be
counted twice.  folio_account_dirtied() sets the folio's dirty tag in
the same i_pages section that counts it, and every path that uncounts a
dirty folio holds the folio lock, so set the flag and test the dirty tag
under the i_pages lock: a dirtier not yet counting the folio finds the
flag set and counts it itself.  Under that lock the wb is inode_to_wb(),
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
 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0adfa6605653..3012bd95812a 100644
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
index 1cc28224d547..0c76ee5750b3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1644,6 +1644,45 @@ void folio_end_dropbehind(struct folio *folio)
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
+ * folio lock, and every path that uncounts a dirty folio holds the folio
+ * lock.  So with the folio locked and the i_pages lock held, the dirty tag,
+ * not PG_dirty, says whether the folio has been counted: a dirtier past
+ * folio_test_set_dirty() but not yet counting finds the flag set and adds
+ * the folio itself.
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
+	if (xa_get_mark(&mapping->i_pages, folio->index, PAGECACHE_TAG_DIRTY))
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

