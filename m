Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795119089;
	b=1CQH/eWKH0PCAaNtedsMgWI0SLovk6TGyhwVXHdOxc8X2N5yX/aLiPYqxbcQ7yEfwDvI
	 h6yQF/8vQQBp0rnMvVg755uGCRMKqgW8jhXRo8TrjHxqz0ZzY/BBKEG6CNPqqiP0GVJAc
	 VC2GBG6bDe6upPNP8NInYwxbl94XXJNt6a7/VXoa/eJCa/m0pTO+KQVKjXfiMA09fdsrL
	 7/ar+gNWdE9/7LIbSLgDCkLhd3MKOPGPQ+7j/GxITeU5zWxFHXt8xm8OnOf14d9RFx1wy
	 U6ArZreHza1RpEb6j988Go/Va6VckP0G8rhnN4INunubgvHHK7wWavFWfqhyAwSf/Lw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795119089;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:References:
	 In-Reply-To:To:Cc:X-Mailer:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:
	 X-Spam-Score;
	bh=krDZt2lyQMLpvzP9eRLAozoK+Qau2jyjNPNf8Y6N1eY=;
	b=1BLkrg94MdxsemGgHyc8JtCr468RpJFHVTs34Q5Bdb18qdJ4/VPLY6G9wewBPGPVHjOF
	 E+ZKSue7bDliq5feTA9wL2FKeiRLVcugy/ds+1OBrdanoaNPKlSm0pe2kPOTxWyFnKiLm
	 lGzckqFX+9G/ls6USS3ywNgpvA8FmSTf6I4TX4Efpf5D/QoVJMKa9I7z5Yv2xwSKc7DE+
	 x5abn1MTPZPM6j7uWh3HGPlISBvHgbBYQHVKZqdVA2TVh6Ukugr8Vl1HdN+MK+E6kdvkg
	 Q421zROFYXJ0IcM6SEM6CgZ4sKK1udFd8Jk74XhBYr/wljhgqq7rWDDtXD4fNRuyWEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=ZbNYpoOa;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=rWB7D58p;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=ZbNYpoOa;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=rWB7D58p;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B991E606A324;
	Thu, 19 Nov 2026 20:11:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B991E606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=ZbNYpoOa;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=rWB7D58p;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=ZbNYpoOa;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=rWB7D58p
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 0CA2F1FCEB;
	Thu, 19 Nov 2026 20:11:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119087; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=krDZt2lyQMLpvzP9eRLAozoK+Qau2jyjNPNf8Y6N1eY=;
	b=ZbNYpoOaGHeZLHdhDXsl/zYnjZ/AdQMk7i/SPEMY0Q10yolOExVKqmC4xS+vyK8DszjFQD
	+wfqfFk0zFqQIPP4rrtwR68RSIviHw868FyVT+LRaikKFObVB0EPO0gkgI5wS5BkL9SSee
	V2Ykgs4Q5J5Ir7RU6b2thZ7aLwdmJqc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119087;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=krDZt2lyQMLpvzP9eRLAozoK+Qau2jyjNPNf8Y6N1eY=;
	b=rWB7D58pv4B4x4q/+Pniaue/ehUunRQRZIy9bTKP+RjVGS0SZswC5zGUcX2yfKsXJqQKXu
	HOQf9AyUfnS6R/CA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795119087; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=krDZt2lyQMLpvzP9eRLAozoK+Qau2jyjNPNf8Y6N1eY=;
	b=ZbNYpoOaGHeZLHdhDXsl/zYnjZ/AdQMk7i/SPEMY0Q10yolOExVKqmC4xS+vyK8DszjFQD
	+wfqfFk0zFqQIPP4rrtwR68RSIviHw868FyVT+LRaikKFObVB0EPO0gkgI5wS5BkL9SSee
	V2Ykgs4Q5J5Ir7RU6b2thZ7aLwdmJqc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795119087;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=krDZt2lyQMLpvzP9eRLAozoK+Qau2jyjNPNf8Y6N1eY=;
	b=rWB7D58pv4B4x4q/+Pniaue/ehUunRQRZIy9bTKP+RjVGS0SZswC5zGUcX2yfKsXJqQKXu
	HOQf9AyUfnS6R/CA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id F09A81334C;
	Thu, 19 Nov 2026 20:11:24 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OqV1JuRX/2pPYQAAD6G6ig:T5
	(envelope-from <pfalcato@suse.de>); Thu, 19 Nov 2026 20:11:24 +0000
From: Pedro Falcato <pfalcato@suse.de>
Date: Thu, 19 Nov 2026 20:10:47 +0000
Subject: [PATCH RFC 4/5] mm/vmscan: be more careful when releasing FS
 metadata if buffer_heads_over_limit
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
Message-Id: <20261119-gup-dirty-what-v1-4-236d69f25c24@suse.de>
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

Namely, don't call ->release_folio() for mapped or referenced folios.
Since this is the active list, there's no actual point in doing
unmapping. In fact, that would be counterproductive for active folios.

So, gate on !mapped && may_release_folio.

Reported-by: David Hildenbrand <david@kernel.org>
Cc: stable@vger.kernel.org
Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
Signed-off-by: Pedro Falcato <pfalcato@suse.de>
---
 mm/vmscan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d80bbb607a15..986742d7fb6a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2217,7 +2217,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		if (unlikely(buffer_heads_over_limit)) {
 			if (folio_needs_release(folio) &&
 			    folio_trylock(folio)) {
-				filemap_release_folio(folio, 0);
+				if (!folio_mapped(folio) &&
+				    filemap_may_release_folio(folio, 1)) {
+					filemap_release_folio(folio, 0);
+				}
 				folio_unlock(folio);
 			}
 		}

-- 
2.56.1

