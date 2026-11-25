Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795596309;
	b=Z6DzYoWOPJ2/SXY8XI5dufxUVRiCEDBtW5RWVNd3KOsBqn7Adg9PpteMRagqk5BK1kV1
	 A/mROJ3yGB4pAhqdzG5G/h+lgi1uWSH7sTuOOraGADXKJBilUtOLDVJsv+4nnCKnYVqma
	 ks43Nne22hBAG8Oa6sl+S+LXQtSz3twOt2GJVeXldT7OlBRFSIiDzRmP/vzIJaakGyleI
	 JWSBwu/t6JcnQWLqvAZO/tGlYjqZlrdS872PRTNrm9i0ZlseRhVJct85c4H0gkYGSyTxa
	 alwNrG2C1/VPD+dmy7YOW/Rr73xUdkC5ZBEHoIyP3XHlgV75e52O6R8kO6g47oV+RAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795596309;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=xIQGPFCJd67xaKCihbcJC3tux5xClyxULhK31mQOmgA=;
	b=iLErAtVwGgrTgjfqugaWCc+QyxkoAgMtIFs9OhXxiPmrFPR/VjnOlHMmp/TkoCOqWEFN
	 z2C9g3eVsgg47DxyZzpWe0YFMIJ/4AhNQVTE/SGqXhwFCNqpdyKppafpdUhhm27DGgHiX
	 K4zbiixJlEfmOfHlJTwy2JF4IgV2TIhL+Ap4eEapLqhEpmjJbqBndcHjaBPY42h3hweh8
	 DWwL4KUSKXcfWfZW8ABTmaUAjRTQ90pwEKoXIeGXZXpkUE1m0ybtJu6Yi/EwBXnYaiH8W
	 ro+7LeryYxu9lbKDzAQboexir5eZoBWwXPX+I4rflFrd/wCjm5reVZxaXYPNJ3w1yuQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="1R4oRQ/i";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xseqmy5b;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="1R4oRQ/i";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xseqmy5b;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A81AE606A31E;
	Wed, 25 Nov 2026 08:45:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A81AE606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=1R4oRQ/i;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xseqmy5b;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=1R4oRQ/i;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xseqmy5b
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 78AE61F747;
	Wed, 25 Nov 2026 08:45:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795596306; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=xIQGPFCJd67xaKCihbcJC3tux5xClyxULhK31mQOmgA=;
	b=1R4oRQ/iWiVF3GfygHgPI9xqm0DU0PL/33RSEd0kAHFOjj03JbHnGcDeKjPUuZVKUfQ/C3
	se0iiVMXGurVPeKjOHJAJnk/StmPKNjpbtuFJjiXHDzF2B6Iiqw2/KkYzF02DFKI3odKHe
	4PRjahV3Nz4geMoybs+TdWwUp9oQtfo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795596306;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=xIQGPFCJd67xaKCihbcJC3tux5xClyxULhK31mQOmgA=;
	b=Xseqmy5b9lVtcOfm6N7qVKeOgqlUYxNKD7bCD3QFJ2Xcfd0l+ZHy35FU1NbGLHKMQyqpAk
	Kdvq0lCqAMg4XqBg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795596306; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=xIQGPFCJd67xaKCihbcJC3tux5xClyxULhK31mQOmgA=;
	b=1R4oRQ/iWiVF3GfygHgPI9xqm0DU0PL/33RSEd0kAHFOjj03JbHnGcDeKjPUuZVKUfQ/C3
	se0iiVMXGurVPeKjOHJAJnk/StmPKNjpbtuFJjiXHDzF2B6Iiqw2/KkYzF02DFKI3odKHe
	4PRjahV3Nz4geMoybs+TdWwUp9oQtfo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795596306;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=xIQGPFCJd67xaKCihbcJC3tux5xClyxULhK31mQOmgA=;
	b=Xseqmy5b9lVtcOfm6N7qVKeOgqlUYxNKD7bCD3QFJ2Xcfd0l+ZHy35FU1NbGLHKMQyqpAk
	Kdvq0lCqAMg4XqBg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 4D533134CA;
	Wed, 25 Nov 2026 08:45:06 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id FrpCChKgBmvYegAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 25 Nov 2026 08:45:06 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id C7C0F27BBB; Wed, 25 Nov 2026 09:45:01 +0100 (CET)
Date: Wed, 25 Nov 2026 09:45:01 +0100
From: Jan Kara <jack@suse.cz>
To: Pedro Falcato <pfalcato@suse.de>
Cc: David Hildenbrand <david@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, Lorenzo Stoakes <ljs@kernel.org>, 
	John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
	Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>, 
	Barry Song <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>, 
	Usama Arif <usama.arif@linux.dev>, Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>, Qi Zheng <qi.zheng@linux.dev>, 
	Shakeel Butt <shakeel.butt@linux.dev>, Axel Rasmussen <axelrasmussen@google.com>, 
	Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>, Baoquan He <baoquan.he@linux.dev>, 
	Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 4/5] mm/vmscan: be more careful when releasing FS
 metadata if buffer_heads_over_limit
Message-ID: <wm57zjtvdpexvbfygmdggw2ytsazelyds4rt3mtx6oy6u72mke@rhviuzp26rt6>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <20261119-gup-dirty-what-v1-4-236d69f25c24@suse.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261119-gup-dirty-what-v1-4-236d69f25c24@suse.de>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	ARC_NA(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	R_RATELIMIT(0.00)[to_ip_from(RLc5chj8mdhigtayhgqted7wkp)];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo,suse.de:email]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Thu 19-11-26 20:10:47, Pedro Falcato wrote:
> Namely, don't call ->release_folio() for mapped or referenced folios.
> Since this is the active list, there's no actual point in doing
> unmapping. In fact, that would be counterproductive for active folios.
> 
> So, gate on !mapped && may_release_folio.
> 
> Reported-by: David Hildenbrand <david@kernel.org>
> Cc: stable@vger.kernel.org
> Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
> Signed-off-by: Pedro Falcato <pfalcato@suse.de>

This is OK with me but so feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

Just given buffer_heads_over_limit is a HIGHMEM thing and given how much we
care (not) about HIGHMEM, maybe just completely ripping out the whole
buffer_heads_over_limit logic is a better "solution"? I mean it's a crude
heuristic anyway and for struct buffer_head to occupy significant portion
of ZONE_NORMAL, you'd have to have several GB of pagecache with buffers
which means the machine has to have quite some highmem which makes the
setup even more dubious...

								Honza 

> ---
>  mm/vmscan.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d80bbb607a15..986742d7fb6a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2217,7 +2217,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  		if (unlikely(buffer_heads_over_limit)) {
>  			if (folio_needs_release(folio) &&
>  			    folio_trylock(folio)) {
> -				filemap_release_folio(folio, 0);
> +				if (!folio_mapped(folio) &&
> +				    filemap_may_release_folio(folio, 1)) {
> +					filemap_release_folio(folio, 0);
> +				}
>  				folio_unlock(folio);
>  			}
>  		}
> 
> -- 
> 2.56.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
