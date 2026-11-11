Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362174;
	b=M3peo68xAZZsu/ZQxQRVy/euJQx2+zQEMLu6izR+9kJ1327JgGYfO5wcX6hwXfsOOeYN
	 ZEtCrVsswK9VdbYuppavcaVBFyDQqo6CnZB5bUa78BW2wpqPpydkfpYrZM/0DRn1+96wx
	 d+BBp6zUZf5oGFRylAl0VOH0Dltxt6hCTPGiaX9SVQ0Nf0UrgBt2Ox5eFBuZY32OYzG/7
	 LoUZZ8kwgJn0CW9KH+Evy8rE3bFCVfZT51ruShN+kJXN2pSrixFk8PM3YcE6YMehtbNhr
	 avpv6hue3tJBweeK2iHnrE95+RlPVC3XASQRzjqjcoYINqIFGoUoZuZfvwVo1+XurOw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362174;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=FO9EVH1vboVesivdtHaC4oHP+QvByQsuc9tAfFRd1cs=;
	b=qyW28xdBwywIvCXVODodBq/D56iz6lkVR449mBsVv6F0fqwhKQ+NYNPMt0NzAeuAoQd2
	 BVHzl8jMEP9MbcDnwU5XQ+4A/jfTkNX9O1Uy6T4087aBfXXOCexxe+HK+uvl9zNXDrcD/
	 /Esf3iNlDsoQIKZJ1Y/KTVpaJ7ZJug5e9qK6eo0xtO9GMGt2NMQuPVSesqS+UrS15oOlw
	 TVhdy6+2/c83rF0xJu2c0pY5q20FN6PQatjkCvkDzBkcL+ldhjW1MHrgHmCDkZHgl9nq2
	 RXWhenCrdK9m24c72UvWl19JA3TQV4fU1hhs2CnZFnhH56dL3zPCcgT+ADnUp4iIgUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Nb9+nB6a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 873D1606A320;
	Wed, 11 Nov 2026 01:56:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Nb9+nB6a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D92AA1F0089F;
	Wed, 11 Nov 2026 01:56:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362174;
	bh=FO9EVH1vboVesivdtHaC4oHP+QvByQsuc9tAfFRd1cs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Nb9+nB6aRZWS+S6IFgOz5cLkH9/xjbELLeESlrJs0i/rdpYbDCRNvcds+kdyGev8d
	 2BwgmTejaL5H3uVCYwd1vgkNqzIWxNHIAJgQp7wIwZpEveD5HV10UZ47btuxRVHx6P
	 zqP7kGmEBkPTQI/6sMUzOnYDBvgQnbU8zY90spr/gHyCNupyN5VWzofhBfsNH6h5yt
	 fcj+gbhHZr+e1aUNV1hcMfLqxIoH0I01JJyO3rUmaOYBc86TDIjh4nT6eRRshCNIp2
	 iy6N/rsb2YZ6F96qy42GBK+7aeb5StJQ+wKXcYZdsrOLRAy8yMM9/AyZQiVe97YpjQ
	 QsofTWMKIvfQA==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v11 4/7] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Tue, 10 Nov 2026 20:56:04 -0500
Message-ID: <20261111015607.46338-5-snitzer@kernel.org>
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
index 98ce955404127..a54d0fbd37222 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1654,6 +1654,38 @@ void folio_end_dropbehind(struct folio *folio)
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

