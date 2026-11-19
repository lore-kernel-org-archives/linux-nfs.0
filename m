Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119091;
	b=ZespSNrTOI8Qe5FKISWsVI2h5t3ySym/onbdTqb9tW9hfG4iOSiOssDvvwWbC6WHgsdK
	 mIKhS0q1gAgDb1btlaj+y7Ya6TBXJLC0E/q83ScbLsmpYd1YnNIdS3lMdKDRR7oH4VXuE
	 99Ntg0H1+bQhRBYGLIEDpxnd84q+7MVtW3md6KM5QcwHGefgLuOyzh+DJQtyQAyr30PxD
	 eYT3xhDf/Hk3g/coIMjGguoQrK6LSssYL3KTRxnSvhhi71BPU14bTHCA/wVOYYHth3pXZ
	 23ZFcAF5/RjuXOAQKt9PijJuzvhJKVFLBAQeHabjyvjAyc9rMVstUXbp+jY9LvUjzRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119091;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:References:
	 In-Reply-To:To:Cc:X-Mailer:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:
	 X-Spam-Score;
	bh=Uo8Olo98zjikgX57G69RkSYYgroY5lrc04l+gH4JzoI=;
	b=0PojVmwh6CZJYw9B1X5I/fTUnPC91q3Wq8fD2AaFI9vLmwSw6C4Bl2xARHENQXsrf6Wj
	 KCHr2qTepXdRLVoAuOQY70qDAsVaCzqZ+P2gmYvbSw4w7UBYO59qcEPq81uNMnF17+tDI
	 nCD4m+TV/Pe9MHh7jQykAYDZZFBkWzk3WZk71rWHLbGa60rOeyCDjZL8K4nsvckdqOn1H
	 H6jAZmCPDOt3ArCQE5ZUbVWW2zAJmwsIpWReZiOiYANdn5aHu5iGR1gEmQP+Wke36sjCW
	 t4rJdZG6jMIMezwmTYjENEvk4WK3HyYD20DQFzHEMeaHECTgwKsAMsyLzYIm08Turxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=eUas+9Ii;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=9uOMWgZ7;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=eUas+9Ii;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=9uOMWgZ7;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C510E60A2615;
	Thu, 19 Nov 2026 20:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C510E60A2615
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=eUas+9Ii;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=9uOMWgZ7;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=eUas+9Ii;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=9uOMWgZ7
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 157D521DE6;
	Thu, 19 Nov 2026 20:11:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119089; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Uo8Olo98zjikgX57G69RkSYYgroY5lrc04l+gH4JzoI=;
	b=eUas+9Ii0hUYbJmdigy5WcIR6MFLbDG4Q9+MkKg469E/fJUfE5s9LcwEWCZ3ugZSzJbQ5E
	G227ThVtEgjDER5qFmK1F/+icKCjUX8+0fRswIRqHMGNAHJfdWh4NdyBomb3k1h29ogcpA
	wLvJ+2nCJSl6+n/ZHpjZrYGuTlwOUM4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119089;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Uo8Olo98zjikgX57G69RkSYYgroY5lrc04l+gH4JzoI=;
	b=9uOMWgZ7LG+LRni/R/J6QJ0QU42oZZHseqFgpO9phvi749VDZI6fswGtgIFGlShqu3eqYu
	vCHCaUFOxZdKZxAg==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119089; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Uo8Olo98zjikgX57G69RkSYYgroY5lrc04l+gH4JzoI=;
	b=eUas+9Ii0hUYbJmdigy5WcIR6MFLbDG4Q9+MkKg469E/fJUfE5s9LcwEWCZ3ugZSzJbQ5E
	G227ThVtEgjDER5qFmK1F/+icKCjUX8+0fRswIRqHMGNAHJfdWh4NdyBomb3k1h29ogcpA
	wLvJ+2nCJSl6+n/ZHpjZrYGuTlwOUM4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119089;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Uo8Olo98zjikgX57G69RkSYYgroY5lrc04l+gH4JzoI=;
	b=9uOMWgZ7LG+LRni/R/J6QJ0QU42oZZHseqFgpO9phvi749VDZI6fswGtgIFGlShqu3eqYu
	vCHCaUFOxZdKZxAg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0B280134F6;
	Thu, 19 Nov 2026 20:11:26 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig:T6
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:26 +0000
From: Pedro Falcato <pfalcato@suse.de>
Date: Thu, 19 Nov 2026 20:10:48 +0000
Subject: [PATCH RFC 5/5] mm/filemap: refuse releasing maybe_dma_pinned
 folios
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
Message-Id: <20261119-gup-dirty-what-v1-5-236d69f25c24@suse.de>
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
X-Spam-Flag: NO
X-Spam-Level: 
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -17.30

Some callers, like folio_unmap_invalidate(), call filemap_release_folio()
without any care for folio refcounts. This is on purpose. As
folio_unmap_invalidate() states, invalidate_inode_pages2() needs stronger
guarantees, and "can't afford to leave folios behind because
shrink_folio_list() has a temp ref on them". Ok.

Use folio_maybe_dma_pinned() universally, in filemap_release_folio(). This
has a much lower false positive rate, and should be ok enough for most
serious cases.

While here, properly assert that no folio passed to release_folio is
mapped.

Cc: stable@vger.kernel.org
Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
 mm/filemap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index f9e34144c53c..4fa75663b7f3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -4571,8 +4571,11 @@ bool filemap_release_folio(struct folio *folio, gfp_t gfp)
 	struct address_space * const mapping = folio->mapping;
 
 	BUG_ON(!folio_test_locked(folio));
+	VM_WARN_ON_FOLIO(folio_mapped(folio), folio);
 	if (!folio_needs_release(folio))
 		return true;
+	if (folio_maybe_dma_pinned(folio))
+		return false;
 	if (folio_test_writeback(folio))
 		return false;
 

-- 
2.56.1

