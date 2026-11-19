Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119081;
	b=kFo2reWjPgyLn1+jKei+qKWlfRn8J+KIEj3eABjHL4oY+MoWJ56zXO3KieTMoyFI8Zo0
	 wErefXSHCMR/xXGKjntmo546c7i61X8ks7xa0KUFOOwbn15mDxMjBUNQHLGVRn7hP8pFE
	 i8DOBkEaP7JoZ023lbDOKmeSnacXTWPGL3OWCtxfuP03gKHQLd8Mu58sQ++QD1XfkI4T5
	 A8zvWmJyT00CdG1ROeOxhbrZRXzBglbRMSpTq+V/dTqkniujawMhUU8dDoDkeG+D/1ovX
	 8G7iLcTs2/dxdjYCPlVXgVjc4ubEbZOkAZwuQ0HmpqGavUuCtK9/v09sNfcCV21IqCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119081;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:From:Subject:Date:Message-Id:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:X-B4-Tracking:
	 X-Change-ID:To:Cc:X-Mailer:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:
	 X-Spam-Score;
	bh=uO/73pEQQIy9LNgk43pvXgxG7QnNaIlPQRRcRPUpu9Y=;
	b=P510qtHSG0hgEVSweGD/IHYxefmTNFHsK3qWEfL/T0PRdJ0//Tco61fihGcg+4yxGi98
	 n7RwxRtxbJUSR3WcvXuGewAajVRK6C7VihwiJ2sx2lfUaiGic6wW4xxOYDn4mDGVTnDDU
	 ZaRJmvpANOVgGcywDAGeMo9TaYmQ6qHzivZyzVGQZ9PAtzpCgsc15XjV/FgVTW+QJLr4N
	 mrR/VcZdCAUcbf1Z4YKxrqbeQrTR+nwVzZqRljWO0lJIobOryaOYDdY54sgD6uBP+uQ5v
	 P9ZI9dE66abCRoDpLqNA/8tnJJSbkVQfuYMH6qkmV0sXeu4a0WiXNFmsGffv1YevYww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=wZQwmvk1;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=wnMVpHge;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=wZQwmvk1;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=wnMVpHge;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4188D606A320;
	Thu, 19 Nov 2026 20:11:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4188D606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=wZQwmvk1;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=wnMVpHge;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=wZQwmvk1;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=wnMVpHge
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id DBBA121DE6;
	Thu, 19 Nov 2026 20:11:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119078; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=uO/73pEQQIy9LNgk43pvXgxG7QnNaIlPQRRcRPUpu9Y=;
	b=wZQwmvk1rBkHTOGo0aaJmNHq3PmqE9nd/LDfPHCgQW+ssoFkA7fEGg8LOAZfzZzaDwd6iw
	zxTIboIlb4U8dQIxDYNADVhgO+Of6UaAXJH+3rQ6iLiUXeIDpCVG6VzQWcTpV4vPkw9SCi
	/av7zxFVW2ds8MrBpwky9ITiRW8MB2Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119078;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=uO/73pEQQIy9LNgk43pvXgxG7QnNaIlPQRRcRPUpu9Y=;
	b=wnMVpHgek02PbsETbBVemF6lgfm1Fsk4bBIq9tRzTup6j8Y0Me5JaFXw+2l4lKIx40xr7j
	x//LK/PqLjgitlAQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119078; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=uO/73pEQQIy9LNgk43pvXgxG7QnNaIlPQRRcRPUpu9Y=;
	b=wZQwmvk1rBkHTOGo0aaJmNHq3PmqE9nd/LDfPHCgQW+ssoFkA7fEGg8LOAZfzZzaDwd6iw
	zxTIboIlb4U8dQIxDYNADVhgO+Of6UaAXJH+3rQ6iLiUXeIDpCVG6VzQWcTpV4vPkw9SCi
	/av7zxFVW2ds8MrBpwky9ITiRW8MB2Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119078;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=uO/73pEQQIy9LNgk43pvXgxG7QnNaIlPQRRcRPUpu9Y=;
	b=wnMVpHgek02PbsETbBVemF6lgfm1Fsk4bBIq9tRzTup6j8Y0Me5JaFXw+2l4lKIx40xr7j
	x//LK/PqLjgitlAQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C3C581334C;
	Thu, 19 Nov 2026 20:11:16 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:16 +0000
From: Pedro Falcato <pfalcato@suse.de>
Subject: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
Date: Thu, 19 Nov 2026 20:10:43 +0000
Message-Id: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzNDQ0Mz3fTSAt2UzKKSSt3yjMQS3SRz45REcxOLNNMUQyWgpoKi1LTMCrC
 B0UpBbs5KsRDB4tKkrNTkEpBRSrW1APU/QoF3AAAA
X-Change-ID: 20261116-gup-dirty-what-b73da748f5d1
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
X-Spamd-Result: default: False [-13.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL8d8xedm6iu8o66torxsk6bwd)];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email]
X-Spam-Score: -13.30

Sooo.... It turns out GUP dirty and ->release_folio() interact really
weirdly. This was initially reported by some AI agent, and David let me
know.

The basic issue is:
 - ->dirty_folio() relies on buffers/IFS/etc being attached to the
   folios. It _cannot_ attach them itself, as dirty_folio() cannot
   block.
 - certain MM paths (reclaim, khugepaged, folio split, etc) are very
   trigger-happy when it comes to asking filesystems to release them. In
   most cases, barring any dirty folios, buffers, it will just drop
   them.
 - there is no problem in usual IO submission, but issues start to pop
   up with GUP, where the code flow (roughly) becomes:
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

What happens if any filemap_release_folio() runs (and succeeds) between
the initial dirtying (plus eventually writeback) and the write to the
folio completes? Welp, it's unpredictable. ext4 for example will
WARN_ONCE, and likely drop data (see ext4_dirty_folio()).

So, what can we do about it? It's complicated, hence why this is an RFC.
For the possible solutions:
 - ->dirty_folio() attaching this FS information itself is not really
   possible in many cases. ->dirty_folio() can't block, nor is it even
   guaranteed to hold the folio lock while being called.
 - Can pincount help? Kind of. Things like folio_maybe_dma_pinned() are
   rough, and don't deal with the usage of get_user_pages(FOLL_WRITE).
   pincount itself isn't available in the common order-0 case, and not
   available on order-1 as well on 32-bit, but who cares about that^W^W^W^W^W
 - Could get_user_pages() ban FOLL_WRITE? Mayhaps. I would not be
   opposed to that, but that's probably a larger change than ideal for stable,
   and I'm not familiar enough with GUP requirements to decide to go that way.
   This would require migrating all FOLL_WRITE users to
   pin_user_pages().
 - Can the whole system be reworked? Probably, but not for stable.

This patch series is really rough but kind-of works. Instead of using
folio_maybe_dma_pinned(), which only interacts with pin_user_pages(), I
introduce a new helper that helps places deal with the folio refcount
directly. In that case, we can also deal with GUP. On the other end,
moar problems:
 - NFS private data itself takes refs on folios. Now private data (that
   we could perhaps release if only we tried) is keeping us from
   releasing that same data. What?
 - ext4 data=journal has some funky usage of buffer_heads. Data journalled
   filesystems will not, in any way, dirty BHs. Instead it will,
   *only if it was DMA pinned*, set the checked flag. ext4 skips
   dropping those buffers if the checked flag is set.
 - ext4 move_extents seems to have suspicious usage of
   filemap_release_folio() as well.

Many of these have suspicious Fixes: (which are definitely wrong). I
targeted these patches to complement Jan's original fix. Anything before
that (or which is missing that patch) is hopelessly broken anyway.
Proper Fixes: can be added, but many of them go back quite far.

Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
Pedro Falcato (5):
      mm/khugepaged: fix filemap_release_folio() interaction with GUP dirty
      mm/huge_memory: fix filemap_release_folio() interaction with GUP dirty
      mm/vmscan: avoid releasing FS metadata for !FOLL_PIN gup folios
      mm/vmscan: be more careful when releasing FS metadata if buffer_heads_over_limit
      mm/filemap: refuse releasing maybe_dma_pinned folios

 mm/filemap.c     |  3 +++
 mm/huge_memory.c | 22 +++++++++++-----------
 mm/internal.h    | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/khugepaged.c  | 19 +++++++++++++------
 mm/vmscan.c      | 18 ++++++------------
 5 files changed, 81 insertions(+), 29 deletions(-)
---
base-commit: 9663aa0da7070d958e333477ce0720512e9fa016
change-id: 20261116-gup-dirty-what-b73da748f5d1

-- 

