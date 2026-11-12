Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510557;
	b=vwlMGx4gr5uCcZEZG3PEMhPsXYp7uePTUh/ox5gTU0kWwX3tmpBTSIWr5vgA7LZ4AsG1
	 vgVrc8QFDUT+s8k0rRQmvD5u9ezJS1AhRwCQqaZbo2izSrMTcrTt3m6PBWwtQ38rqykQm
	 huB3LXzN4FRe9kZ0hr90SN0D/NDcNXqQ8tiTGvgwCT39nbnw9qCwURbBx9NeaXKUx9iU5
	 IT9qm15WoNal1my5tMGVf2xPYHfqX6Hn2NJfRzFJaMfop5vVoJYfekE1NYoFeXmumBf0j
	 66QbC42qBfUUKoK28CY9EIZ4lM9qjfkhDB3Cziqge6szcHADrA0zzR57yIzAFXYyHBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510557;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=FRT2/+R9YmYPDM76NCkeURQmSSsjMxRjRdu/RF1CsXY=;
	b=DyIht2HUFkYQZ40c12UxDl1H+eHjTkAzcKcWW9Yp1J5r8CIGLhqkZu8Hsj80TEAq9Uga
	 IZ7e2KfcDX8O7OK8kciH5CzvilnavOHzQN4bJ6Y1ERlx1VCRYuVWvJ++O2grmKNYuifT4
	 nsM1aOBm+ewwCTc9aob+rS67l40XiCqkiRSr+L/3cwVQjKnCxkURIn7aqN4QLyJwwefXW
	 k9IpNBY4G5OP2Hj+KbOcwceRmZRAqA4BpJJB6SM30uC9rqd+xrPgtWhwgMd7gWqkV9mhi
	 wNqWkSWwpN1c1Pio+6tur0wSzwTGUgoqRT4+lnrXaFSiB8KLsVDBnDnQ2Kcjc2UUDZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R8hk5Dwv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5683606A332;
	Thu, 12 Nov 2026 19:09:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R8hk5Dwv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 35EDE1F000C8;
	Thu, 12 Nov 2026 19:09:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510557;
	bh=FRT2/+R9YmYPDM76NCkeURQmSSsjMxRjRdu/RF1CsXY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=R8hk5Dwv9vAwELb2ZJKK7TvMFh4spMzUdEtBRAfSLVwWI/st5fWdQZo/N2LJEdCdA
	 hKyPNrDt8bff1GXsVM37dh6jqyKzp6nd45paYHdsJxDGdmk7I23AabomXADvcP34e1
	 HIjqnxLbu6n2/vIjpn9rbIJ7ZUNze2NaYRiLvZk74KLZZDNzx9eX2GqkfoAyKVwlfO
	 vUSRv57dQiUwMr5xwh4UZJWUcd0r9Vg9QUelmaesJNPoQVEc/eA+6ihplO7DpSeEb5
	 kM6Wt9D4f7Kjs0+cOuCF/n9OrOCIBHtdIj63g+qDA35uBc3g4X9VTbI9RE5nilt0d1
	 1J6ILoemZz8aw==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v12 1/7] mm: move clearing the dropbehind flag of a found folio into a helper
Date: Thu, 12 Nov 2026 14:09:04 -0500
Message-ID: <20261112190911.84702-2-snitzer@kernel.org>
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

Move the code in __filemap_get_folio_mpol() that clears PG_dropbehind
on a folio found by a cached lookup, and takes the folio off
WB_DONTCACHE_DIRTY, into filemap_clear_dropbehind().  No functional
change.  The next patch changes the helper.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/filemap.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b04be64a5069f..437113addbddf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1956,6 +1956,24 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
+/* Clear the dropbehind flag of a folio that a cached lookup found. */
+static void filemap_clear_dropbehind(struct address_space *mapping,
+				     struct folio *folio)
+{
+	if (!folio_test_clear_dropbehind(folio))
+		return;
+	if (folio_test_dirty(folio) && mapping_can_writeback(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		struct wb_lock_cookie cookie = {};
+		long nr = folio_nr_pages(folio);
+
+		wb = unlocked_inode_to_wb_begin(inode, &cookie);
+		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
+		unlocked_inode_to_wb_end(inode, &cookie);
+	}
+}
+
 /**
  * __filemap_get_folio_mpol - Find and get a reference to a folio.
  * @mapping: The address_space to search.
@@ -2087,19 +2105,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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
+	if (!(fgp_flags & FGP_DONTCACHE))
+		filemap_clear_dropbehind(mapping, folio);
 	return folio;
 }
 EXPORT_SYMBOL(__filemap_get_folio_mpol);
-- 
2.52.0

