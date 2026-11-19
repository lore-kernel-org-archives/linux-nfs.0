Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119087;
	b=puLGSVQasN8aaAMtu4CnTsxL4eLbETn9gfRaSWtx9XYLFbZYt2fQ6piMNeXK8l5pokU/
	 xqkhbez2bTQXScOEGu9/1fFSgfXiusCfg/XpXt79rcGRZHxIMWgdeW5wE6U2cz30nN39f
	 cj7dVJ0CXDa8dMA0OxERqz+fmImwioNNvp8ZvhLhHVhrGT++d1R0E6L/jlSpGF7hJMA/3
	 yxNK38SRgztmdmQDKbY2fLO4A94xvBah62QDUfm1TXGkHuxJ20TZmqpkrpa5c38hnanns
	 qS++/ZcOw3ENPasFdzvi1BEtPhou/9inwL61f4lpMEBijRLwmZzNruw9tSUmdsiO2lw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119087;
	h=DMARC-Filter:Received:Received:Received:From:Date:Subject:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:Message-Id:
	 References:In-Reply-To:To:Cc:X-Mailer:X-Rspamd-Pre-Result:
	 X-Rspamd-Server:X-Spamd-Result:X-Spam-Flag:X-Spam-Score:X-Spam-Level:
	 X-Rspamd-Queue-Id:X-Rspamd-Pre-Result:X-Rspamd-Action;
	bh=/7+jDmw9PPr5XQtRbOeCRcxjCTyR2570BzVPmXYCK3M=;
	b=B1wuAAGdeh6YRQIEksH96ijKbFJj/JxfPeSGPLKLwv5o8MWhkrjlbtzs/+Cnw1yWGx5g
	 7chfFODaptaU9K2RqxtPvLpiqGQoCWI1UMFKr2On3NtcQ0FxK4VDkTcBZhFvQLpsiTs7b
	 eAmu6+2I/TouErPUKFe7tiBXSNpnT7cIl7nLvQGSYtPRRVQtDwPK8wm0a7U71FOjUpXna
	 mLiLZzmTSrKTJnKRzRmgc3+3C9JZhkyhNiBjsafYaHohSOx+It+fz6NBEsK2TnuUCuooK
	 3Bwxskt/4SXl0EgXL4oiAUGio1l40LPT9DIzpD7nFvO18xYoEQGW05F82gXRI9v+0tw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2CA760A263D;
	Thu, 19 Nov 2026 20:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B2CA760A263D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id F2E4B1FCEE;
	Thu, 19 Nov 2026 20:11:24 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E409A134F6;
	Thu, 19 Nov 2026 20:11:22 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig:T4
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:22 +0000
From: Pedro Falcato <pfalcato@suse.de>
Date: Thu, 19 Nov 2026 20:10:46 +0000
Subject: [PATCH RFC 3/5] mm/vmscan: avoid releasing FS metadata for
 !FOLL_PIN gup folios
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261119-gup-dirty-what-v1-3-236d69f25c24@suse.de>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
In-Reply-To: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
To: David Hildenbrand <david@kernel.org>, 
 Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
 Lorenzo Stoakes <ljs@kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
 Peter Xu <peterx@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
 "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
 Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
 Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, 
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>, 
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>, 
 Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>, 
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>, 
 Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, 
 Wei Xu <weixugc@google.com>, Baoquan He <baoquan.he@linux.dev>, 
 Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, 
 Pedro Falcato <pfalcato@suse.de>, stable@vger.kernel.org
X-Mailer: b4 0.15.2
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO
X-Spam-Score: -4.00
X-Spam-Level: 
X-Rspamd-Queue-Id: F2E4B1FCEE
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Action: no action

The check added in commit d824ec2a1546
("mm: do not reclaim private data from pinned page")
is correct. However, it only handles pages pinned for DMA, using
pin_user_pages(). It completely skips any other get_user_pages() user,
that does not pass FOLL_PIN.

Replace the folio_maybe_dma_pinned() check with
filemap_may_release_folio().

Reported-by: David Hildenbrand <david@kernel.org>
Cc: stable@vger.kernel.org
Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
 mm/vmscan.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6a1af9b92349..d80bbb607a15 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1464,16 +1464,6 @@ static unsigned int shrink_folio_list(struct list_head *folio_list,
 			}
 		}
 
-		/*
-		 * Folio is unmapped now so it cannot be newly pinned anymore.
-		 * No point in trying to reclaim folio if it is pinned.
-		 * Furthermore we don't want to reclaim underlying fs metadata
-		 * if the folio is pinned and thus potentially modified by the
-		 * pinning process as that may upset the filesystem.
-		 */
-		if (folio_maybe_dma_pinned(folio))
-			goto activate_locked;
-
 		mapping = folio_mapping(folio);
 		if (folio_test_dirty(folio)) {
 			if (folio_is_file_lru(folio)) {
@@ -1566,7 +1556,8 @@ static unsigned int shrink_folio_list(struct list_head *folio_list,
 		 * the folio on the LRU so it is swappable.
 		 */
 		if (folio_needs_release(folio)) {
-			if (!filemap_release_folio(folio, sc->gfp_mask))
+			if (!filemap_may_release_folio(folio, 1) ||
+			    !filemap_release_folio(folio, sc->gfp_mask))
 				goto activate_locked;
 			if (!mapping && folio_ref_count(folio) == 1) {
 				folio_unlock(folio);

-- 
2.56.1

