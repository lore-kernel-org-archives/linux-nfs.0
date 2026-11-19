Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119083;
	b=ZojOSOyKIRVfexMpoWDSOpWaWDDS4ZB/H/ujJF4f6UP5bZB6XxEGrnnC/I8I6mw/P4pb
	 y12pBMBg4zfTd4Wa3OLJOnjac41GK+qa2d2QZIo+KMa10iYZdQecqJexmxjfMGNhaXhWr
	 I1glhwo6fNXyumrA+GfUyQHlS41PJshPclImumfFNGozfzUMsV/2gmHtrpKfViqwo6d1s
	 X1/+itmgTv5Rhdo4NW5rP5bOafI5vK0nwjS3RVE8EfPROTy0puCZs4cVf3dNFKqr8n4Zt
	 kudThfZ0uP76z0Q/hozcuS4VSie47O9iSrrKL6LaKyeoNoquYmnXEL3tMPou5GeXidA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119083;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:References:
	 In-Reply-To:To:Cc:X-Mailer:X-Spamd-Result:X-Spam-Score:X-Spam-Level:
	 X-Spam-Flag;
	bh=4P5Cb+/gfgFBvqXWLKpYKOVGpUcYfuN40MLcJ/ms72w=;
	b=J7JYltgROSpVm1/SQbFlIdek+d90Mzyy8F49oGxWHGthVmiBCtVGlQAzCeaFEOWBQRJV
	 wAndC4yWpyiMGwluarJ9G7/yQYHL+IpMg6ZNd60HeFRXmHxyplEdkJr4XUeCVHieFXkMJ
	 Y0ZCePgDd9h1Fieq69LWu//DsBkoOB6plKfssygRtdV4E2eqmGqfGF4dGLYLnxODWWwij
	 7b7eclLqmd+LrY0rk6KuqO75QF58Z4qTmXrjaMip/71nvYlMiltFDtOfxw69S+4dt1W4h
	 2oWc+fiW9lKBP7oSXY4LLhQvTC/NCTL8yWZKBgmnsQnWlkYOvpY9jgH6Ef6jzNhEiRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b="sDuz0/k8";
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Ckv9HDGF;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=heYlqDV6;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=TUJeWbF6;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFF4660A2604;
	Thu, 19 Nov 2026 20:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EFF4660A2604
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=sDuz0/k8;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Ckv9HDGF;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=heYlqDV6;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=TUJeWbF6
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id DC3401FCEB;
	Thu, 19 Nov 2026 20:11:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119081; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4P5Cb+/gfgFBvqXWLKpYKOVGpUcYfuN40MLcJ/ms72w=;
	b=sDuz0/k8dN04iladdCn1gPyygaKd0MO/dxStH2IZjsRRA/w5CATIAYcySkadXUYjOwviFc
	3mzhJ+eboRgKsfOV+T2wIdUAyyAxjY0+rroxNyciIdn1GqgB4MEPCaiNwDYd54NGzF/mi/
	reG0ytBYtl/iWXFp6zbR2aKSwZx2QxE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119081;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4P5Cb+/gfgFBvqXWLKpYKOVGpUcYfuN40MLcJ/ms72w=;
	b=Ckv9HDGF4PAjrItC/XomsJDUu5vT0fLYjHvKcgIG4FffcfRNPkM2697Qc1w+/4uKtApvxx
	6QttGd9wgRq6geBw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119080; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4P5Cb+/gfgFBvqXWLKpYKOVGpUcYfuN40MLcJ/ms72w=;
	b=heYlqDV66zR3q53/DcGEzUxq5XDHxwEP5Ctk9fMS48ak8rgF38T8TQwbAs20stNJf1wvqa
	iwPxYnQLqtFeV+PxepBWtsU1mNmLy9l6FhB/53at8XXCOavDNJid1RYQt4EJq4FpvVowUP
	Hba7vzM5zACDa155GUl79PArhsGC+8I=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119080;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4P5Cb+/gfgFBvqXWLKpYKOVGpUcYfuN40MLcJ/ms72w=;
	b=TUJeWbF6iWKkwT3EER10NoYiXdDCviji5x375945ma7CsJdZww9XPuSzdiCGiroyr96b87
	lEDDs8k9n4kb5vAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id CFA1B134F6;
	Thu, 19 Nov 2026 20:11:18 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig:T2
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:18 +0000
From: Pedro Falcato <pfalcato@suse.de>
Date: Thu, 19 Nov 2026 20:10:44 +0000
Subject: [PATCH RFC 1/5] mm/khugepaged: fix filemap_release_folio()
 interaction with GUP dirty
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
Message-Id: <20261119-gup-dirty-what-v1-1-236d69f25c24@suse.de>
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
X-Spamd-Result: default: False [-17.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCPT_COUNT_TWELVE(0.00)[37];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCVD_TLS_ALL(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL8d8xedm6iu8o66torxsk6bwd)];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email]
X-Spam-Score: -17.30
X-Spam-Level: 
X-Spam-Flag: NO

Whether a folio can be "released" (drop attached buffer_heads, iomap
state, etc) is a complicated matter.

Namely, the act of calling pin_user_pages()/get_user_pages(FOLL_WRITE)
and later calling folio_mark_dirty() on these same folios relies on
on these structures to have been set up by ->page_mkwrite() or
->write_begin() elsewhere. ->dirty_folio() implementations usually
cannot set these up themselves, as ->dirty_folio() is not allowed to
block.

    [get_user_pages(), etc]
       ->page_mkwrite() called here, or before
         ->private correctly populated with whatever the filesystem
           expects.
         folio is marked as dirty, initially.
   *write finishes*
   folio_lock();
   folio_mark_dirty();
     ->dirty_folio()
          dirty_folio expects ->private to be populated by
          ->page_mkwrite(), ->write_begin().
   folio_unlock();

So, what happens if filemap_release_folio() is randomly called on
folios?

              T0                             |       T1
    [get_user_pages(), etc]
       ->page_mkwrite() called here
	 ->private is ok
         folio is marked as dirty, initially.
   *write finishes*
					      |   *some op*
					      | filemap_release_folio()
   folio_lock();
   folio_mark_dirty();
     ->dirty_folio()
          dirty_folio expects ->private
   folio_unlock();

In, e.g. ext4's case, this results in a WARN_ON(!folio_buffers(folio))
and very likely data loss, as block_dirty_folio() will not find any
buffers.

Thus, introduce a new helper to help figure out if
filemap_release_folio() can be called. filemap_may_release_folio()
mainly takes into account the refcount to help figure out if it's safe
to release. The NFS ->private refcount funkyness will be handled in a
separate patch.

As a part of this change, move try_to_unmap() back to before calling
filemap_may_release_folio(). This is required for mappings which don't
require write notification, and as such the dirty=1 -> folio dirty=1
transition is actually meaningful.

Reported-by: David Hildenbrand <david@kernel.org>
Cc: stable@vger.kernel.org
Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
 mm/internal.h   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/khugepaged.c | 19 +++++++++++++------
 2 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 85cf7becf858..4c22d27ace96 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -718,6 +718,54 @@ static inline bool folio_needs_release(struct folio *folio)
 		(mapping && mapping_release_always(mapping));
 }
 
+static inline bool filemap_may_release_folio(struct folio *folio, int extra_refs)
+{
+	/*
+	 * Whether we may "release a folio" (drop attached buffers,
+	 * etc) is a bit more complex than what you could be hoping for.
+	 * There are two types of dirtying users in the kernel:
+	 * 1) ones which take the regular page fault/write(2) paths.
+	 * These regular paths (which fall into ->page_mkwrite or ->write_begin)
+	 * take enough care to e.g establish buffers and attach them to the folio.
+	 *
+	 * 2) ones that don't necessarily do that.
+	 * Essentially, the act of writing to a pinned/GUP'd page relies on the
+	 * above (for GUP-like operations, ->page_mkwrite). However, the folio
+	 * does not stay locked all the time. It is released somewhere in between
+	 * get_user_pages() and whatever it is you're doing with the page (e.g IO
+	 * submission). These users rely on the following logic:
+	 *
+	 *    [get_user_pages(), etc]
+	 *       ->page_mkwrite() called here, or before
+	 *         ->private correctly populated with whatever the filesystem
+	 *           expects.
+	 *         folio is marked as dirty, initially.
+	 *   *write finishes*
+	 *   folio_lock();
+	 *   folio_mark_dirty();
+	 *     ->dirty_folio()
+	 *          dirty_folio expects ->private to be populated by
+	 *          ->page_mkwrite(), ->write_begin().
+	 *   folio_unlock();
+	 *
+	 * Thus, it's not possible to call filemap_release_folio() if _anyone_
+	 * has a reference we don't expect, that can plausibly dirty the folio.
+	 * Additionally, we can't have mappings for these. These checks are
+	 * racy, but the folio lock guarantees that whomever is e.g starting IO
+	 * on these pages will inevitably wait for us to finish.
+	 */
+	VM_WARN_ON_FOLIO(!folio_test_locked(folio), folio);
+	if (!folio_needs_release(folio))
+		return true;
+
+	/* There's no way to know whether these are write-mapped, so give up. */
+	if (folio_mapped(folio))
+		return false;
+	if (folio_ref_count(folio) != extra_refs + folio_expected_ref_count(folio))
+		return false;
+	return true;
+}
+
 extern unsigned long highest_memmap_pfn;
 
 /*
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 964f78c3856b..1f1b93371a7e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -2396,6 +2396,15 @@ static enum scan_result collapse_file(struct mm_struct *mm, unsigned long addr,
 			goto out_unlock;
 		}
 
+		if (!folio_isolate_lru(folio)) {
+			result = SCAN_DEL_PAGE_LRU;
+			goto out_unlock;
+		}
+
+		if (folio_mapped(folio))
+			try_to_unmap(folio,
+					TTU_IGNORE_MLOCK | TTU_BATCH_FLUSH);
+
 		if (!is_shmem && (folio_test_dirty(folio) ||
 				  folio_test_writeback(folio))) {
 			/*
@@ -2404,11 +2413,13 @@ static enum scan_result collapse_file(struct mm_struct *mm, unsigned long addr,
 			 * since first write.
 			 */
 			result = SCAN_PAGE_DIRTY_OR_WRITEBACK;
+			folio_putback_lru(folio);
 			goto out_unlock;
 		}
 
-		if (!folio_isolate_lru(folio)) {
-			result = SCAN_DEL_PAGE_LRU;
+		if (!filemap_may_release_folio(folio, 2)) {
+			result = SCAN_PAGE_COUNT;
+			folio_putback_lru(folio);
 			goto out_unlock;
 		}
 
@@ -2418,10 +2429,6 @@ static enum scan_result collapse_file(struct mm_struct *mm, unsigned long addr,
 			goto out_unlock;
 		}
 
-		if (folio_mapped(folio))
-			try_to_unmap(folio,
-					TTU_IGNORE_MLOCK | TTU_BATCH_FLUSH);
-
 		xas_lock_irq(&xas);
 
 		VM_BUG_ON_FOLIO(folio != xa_load(xas.xa, index), folio);

-- 
2.56.1

