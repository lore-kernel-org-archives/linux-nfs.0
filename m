Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740677;
	b=Oc3fw9hSNEMBeKW/FstmxyZNDoXjlgtwcMrgkS9RQpX/a/ovQAahAWbijb64CtwfmF3x
	 MDqdyixK58LKmrwFDE1xC6Mys7ZVKAhXSCdVJZUeNJk2aEAu7ocNthi/1ElhFMex1qkI9
	 Dzzh7CvUBoxi8plZqi9yMGxk2r9l/biOcQwyPkic2wnRfR+hFYEFCmjU9tUP1Py9YH74P
	 4OYejs+GFcODGspMRuHuaakmaBikG7s7foltmT6LMqSZhKh2N+Fg496k2P4YyWTm1QOD2
	 aREb6gI5IejeuwC33sl1CAiAYMZvOudZ7KwWoluRBcDnxaWxc1lLzyGhj+r/qVwDc2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740677;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=6HFvT67o+TI6VMILL8krBuuNC43u0v42N0ht6ClypRA=;
	b=FWImY2hr5yoIGcgw2cBhHxx8Zdz1nXdqaYJbM9ZueLgjwlYktbXnR19jHVN9isVg83wo
	 JY+wMkdWBu7NI+JWA8EqFnh24Ehaq5OtHJX3KhXcR1S7aMbhHgeGUIZVq3EDXKteEQFTs
	 y1tyD/LSVOY/MgD57M2DcV2Hq7JJLc15ST7vUl3It+bYsdNFFiqSjTQyaLaz1Tm9GoAun
	 vTONSTVisc4n1UiVE58m9h3zU4OGMrS5HanRhu8cAL0jPO2LNqXx6OQAVgUn09ReLurfc
	 XRCBNmEy3DDDEkwZUVxZKnE+DW8M3YLurSLiToOu7QXgB6SftcySoL4Lmn3QMh2nmHA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R6xv9O18;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27BF4606A32F;
	Tue,  3 Nov 2026 21:17:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R6xv9O18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 84C361F000C1;
	Tue,  3 Nov 2026 21:17:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740676;
	bh=6HFvT67o+TI6VMILL8krBuuNC43u0v42N0ht6ClypRA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=R6xv9O189toZnNtMOFLE7eGtRnp6nZKcRayCIILy1wQl8VBsjFzP1XLms8CplwP2l
	 MLC1vq4UQ0Ls+BesRL7C6QcIuzlM3tSnJz6TSdc0xHnRT+d0LFrfv9hnbSXlET2MGv
	 Mp8Fbzt9jGqeDWOYVuD5a9gZsDzoTpT1ZKPN1kn31e9M0KaBFMi6Z5UhsbCOK9kyp8
	 uwKJHuJkzNoWtqUt1d4Dq+2NwJD8vK/yJub2UDLLqbDlblS1jajahTlMVj82lO/nvz
	 A9M1McdlB56pXOUMRltRAppTRIc1sEuhw6hbd8vqk3tSpLxv0fxAm4PlXikeTPVhFf
	 rAXX7h22u8yTg==
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
Subject: [PATCH v10 1/7] mm: move clearing the uncached flag of a found folio into a helper
Date: Tue,  3 Nov 2026 16:17:48 -0500
Message-ID: <20261103211754.35352-2-snitzer@kernel.org>
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

Move the code in __filemap_get_folio_mpol() that clears PG_dropbehind
on a folio found by a cached lookup, and takes the folio off
WB_DONTCACHE_DIRTY, into filemap_clear_dropbehind().  No functional
change.  The next patch changes the helper.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/filemap.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b74bc1e5015c6..c75f49563b74b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1945,6 +1945,24 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
 	return folio;
 }
 
+/* Clear the uncached flag of a folio that a cached lookup found. */
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
@@ -2076,19 +2094,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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

