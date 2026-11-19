Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119085;
	b=BtUl5OLvFY0XRLnfM5EKDJMNX7MdJZg1i41au8Wtl02zPAOMgQ9VzICN29ReRKvCan4x
	 q/P5ebsIOk/WlQ5vEkYQ8aA05jo9g5pO6nnu0jtxOxcCtpqu0NKhni/jCkFKYW+b1rRxh
	 3dTr6Am5bwhZ/yFKdFD/JmbZXALTDwIeA3jyvZauah9v34tFVmDiKOkc242LHrAizUZlf
	 +UlC51MkBD8uZGhVdfaTSwQ4wv5UOgEucJwM7BsaGAZgCppW81nB9EYSX7/02IiR1dR0M
	 zD3TIUiG5SsZrdpRSFyudKVh4nmU7Pvt96hkKO96PV5zRmPLbHoeKLJmNz3CLxEO/Bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119085;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:References:
	 In-Reply-To:To:Cc:X-Mailer:X-Spamd-Result:X-Spam-Score:X-Spam-Level:
	 X-Spam-Flag;
	bh=E0JMQvtIW98t79y2PymOspKrjqnL38s7VvLSlkqXnAQ=;
	b=tzLKJ4Pz1pZlZkeeo9b1LJqC+1fOoagXgpiOjveENHObnOEAns0sMNOtfxQX8eSJw1e+
	 w5JuIOOr51+a2r36H7FZN7YHGrveUEuhVhq+5DKIS2cgelFOo/mIWUrXLyGo1JdtZ5+2Y
	 d70HfmZQ832PJUbVBxpOAswtaoJ3G0ecxPJpbyDsZjDfkfM+S9+6S3RGTq9Ct7iD8EPsb
	 la0fLkJpniu0Ou25yub3GuhDFl2TFWkJ17+NqOOGs2tEoo4rAI4C7RRpBy3V5Dkm62YtW
	 mLYSO1TkTEXyEPfUWc+V0owx/tc9r8KrS4OYwGssVHjPptNnZlFF9WBdVQv0XqwrYGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=fv28Dxji;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=NGvTTjtX;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b="s606/Mk8";
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=NpvJb5ju;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D10B060A2620;
	Thu, 19 Nov 2026 20:11:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D10B060A2620
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=fv28Dxji;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=NGvTTjtX;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=s606/Mk8;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=NpvJb5ju
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id EAA751FCEC;
	Thu, 19 Nov 2026 20:11:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119083; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=E0JMQvtIW98t79y2PymOspKrjqnL38s7VvLSlkqXnAQ=;
	b=fv28DxjiaDhoF5fTY3ws/RkzFL3T6Osh05wt7gSqPfDV8iTwq+B7Lh77BXzt4bLWSxhDms
	ku1/lG5hoel9Tc5NccaLOvOWBDFPny7UqNcLR4QtI2xHffdSbWE/Uyxstkzv8PNf1TYmZT
	KQpadoETaj8kNEbtbYKwYYs8bCywyM8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119083;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=E0JMQvtIW98t79y2PymOspKrjqnL38s7VvLSlkqXnAQ=;
	b=NGvTTjtXt89TF4jydV6cZiMADwXXXcYvq1zBz6q23jI6nooiAxe98ObFpkEG9w+lsxDPif
	hShMQjYPSYnkbFAw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119082; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=E0JMQvtIW98t79y2PymOspKrjqnL38s7VvLSlkqXnAQ=;
	b=s606/Mk8kzgzQVe/0/ZKHA+DlGC/FJ0taZowr7flLw3/RnlbLYn2nbzP3R4+vJ8MPsgGyE
	SvCyoV4LJuAs8qcAePEZss/DEjKE34XMfPAGfuBPr7lHqsiNkIINQ+Yn9swm1JTJj9JUUj
	KJFDP0AHGvt38kY+2yJbiDfWBBln7y0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119082;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=E0JMQvtIW98t79y2PymOspKrjqnL38s7VvLSlkqXnAQ=;
	b=NpvJb5juU2vGru2EPyqmlOidbcwgu6JxZgt9Tme5YBU177SNL6zyh9MymhbC77OoyWoTCy
	fdIg+2ylzDidpfAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D95F51334C;
	Thu, 19 Nov 2026 20:11:20 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig:T3
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:20 +0000
From: Pedro Falcato <pfalcato@suse.de>
Date: Thu, 19 Nov 2026 20:10:45 +0000
Subject: [PATCH RFC 2/5] mm/huge_memory: fix filemap_release_folio()
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
Message-Id: <20261119-gup-dirty-what-v1-2-236d69f25c24@suse.de>
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

filemap_release_folio() can only be called safely on:
 - folios that are unmapped and
 - folios are not dirty and
 - folios that don't have elevated refcounts

Anything else can plausibly be pinned for DMA/writing, which interacts
very poorly with ->release_folio().

Fix it by adding a filemap_may_release_folio() check, plus move unmap_folio()
outside the i_mmap_read_lock(). unmap_folio() does not need the
i_mmap_read_lock, since the folio is locked anyway.

Reported-by: David Hildenbrand <david@kernel.org>
Cc: stable@vger.kernel.org
Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
 mm/huge_memory.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 79d400ea9553..7c619c45cceb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3630,13 +3630,13 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
  * still have failed, but remap_anon_folio() must be called afterwards,
  * for anon folios.
  */
-static int unmap_folio(struct folio *folio)
+static int unmap_folio(struct folio *folio, bool locked)
 {
-	enum ttu_flags ttu_flags = TTU_RMAP_LOCKED | TTU_SYNC |
-		TTU_BATCH_FLUSH;
+	enum ttu_flags ttu_flags = TTU_SYNC | TTU_BATCH_FLUSH;
 
 	VM_BUG_ON_FOLIO(!folio_test_large(folio), folio);
-
+	if (locked)
+		ttu_flags |= TTU_RMAP_LOCKED;
 	/* Racy check if we can split the page, before we split PMDs */
 	if (folio_expected_ref_count(folio) != folio_ref_count(folio) - 1)
 		return -EAGAIN;
@@ -4170,7 +4170,7 @@ static int __folio_freeze_split_anon(struct folio *folio,
 		if (!anon_vma)
 			return -EBUSY;
 		anon_vma_lock_write(anon_vma);
-		ret = unmap_folio(folio);
+		ret = unmap_folio(folio, true);
 		if (ret)
 			goto out_unlock;
 	}
@@ -4271,8 +4271,13 @@ static int __folio_freeze_split_file(struct folio *folio,
 	memcg = get_mem_cgroup_from_folio(folio);
 	old_memcg = set_active_memcg(memcg);
 
+	ret = unmap_folio(folio, false);
+	if (ret)
+		goto fail_free;
+
 	gfp = current_gfp_context(mapping_gfp_mask(mapping) & GFP_RECLAIM_MASK);
-	if (!filemap_release_folio(folio, gfp)) {
+	if (!filemap_may_release_folio(folio, 1) ||
+	    !filemap_release_folio(folio, gfp)) {
 		ret = -EBUSY;
 		goto fail_free;
 	}
@@ -4306,10 +4311,6 @@ static int __folio_freeze_split_file(struct folio *folio,
 	if (shmem_mapping(mapping))
 		end = shmem_fallocend(mapping->host, end);
 
-	ret = unmap_folio(folio);
-	if (ret)
-		goto fail_mmap_unlock;
-
 	xas_lock_irq(&xas);
 
 	/*
@@ -4384,7 +4385,6 @@ static int __folio_freeze_split_file(struct folio *folio,
 	lruvec_unlock(lruvec);
 fail:
 	xas_unlock_irq(&xas);
-fail_mmap_unlock:
 	if (nr_shmem_dropped)
 		shmem_uncharge(mapping->host, nr_shmem_dropped);
 	/*

-- 
2.56.1

