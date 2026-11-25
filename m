Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795596474;
	b=3O7hxHH3sc3F6g3kx5bI9OjU4dLpsk4upeTeEbfqS0aTRTQII81Te8qKRFwDZ/hKhqQe
	 QIA3BCp8N+CPTnFkXddym49ZQ3aa5tI8zzBOTWGL0e3sD4HHrC9TrzYPbRIruEvsYxxBc
	 pbgBpDliFapRpSMm6Bh2Z2vwwOO+XiZCMP5EYcBjHlD1rdX4S/boq1PbQjB+hp2jVWDZu
	 CkptBj8zE4/0OdIfd3q+thljiwQh7NmsQvelcE2K9ODNUZuwLdh/RnU+zzvVGitliow6d
	 5oDJqjSExjQ7eNnQD85adUR4F53ITLcHfdSJlIA4BSMa43W5nh2Du2spclPFpoBz3WA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795596474;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=WLw5iSLUAmy5ESjmbTA6ThiW5AF9rDmQb0R0/WJ6aCs=;
	b=Y0dShPuusIhpNOUnvKwFuE2p/wQhTwKADJexhb0SMhhjumWtxTmTaqpKLQeF/31+VPfl
	 M809BhDlMZJ6Rxx8iHi9Rm8YuZiUB8aNLvm1hepp/5ctr7D06QlEEmYDPQOzAbtyFjjFK
	 KRnCIHWLNv0oerpEJgMm2UjBHPmz9izfTT3QAPu1hKHmt+U3TE+7qKk4Nyui8QC6EcEo/
	 Do8OrsGKR3BG5uxZdXC2mJnDhay41r5C0h1V55F5kpExlKosnstmSnkCkQ219suzQ8TXY
	 FWcuZLURZ217Jkht/nrvMoqjMaNJekUJGdTYY6DUIP+6YBp+qyOxi+egYQG7DZF1Mfw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xWfccdjs;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=OO3e4siu;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="G5/pHpGg";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=uThUAfA+;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4354606A327;
	Wed, 25 Nov 2026 08:47:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A4354606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xWfccdjs;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=OO3e4siu;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=G5/pHpGg;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=uThUAfA+
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id BA8D221F6C;
	Wed, 25 Nov 2026 08:47:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795596465; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WLw5iSLUAmy5ESjmbTA6ThiW5AF9rDmQb0R0/WJ6aCs=;
	b=xWfccdjs+1brj5kF+U2+aXs2cxkUEyD9UIBRARlzVvl9saKhVrlGVeG2182x+XRHh74x4L
	30ISI2+aHO20dRWdE5nYT7+NRhq0mYp8xn9klblBfquFqjIwNfnnZuxyxjGaW4tqecXeGt
	WzDf6SwJBfcMUEHQhMU7A+wf52Seuso=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795596465;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WLw5iSLUAmy5ESjmbTA6ThiW5AF9rDmQb0R0/WJ6aCs=;
	b=OO3e4siu057blVR7oduuGttVRQ6uVbk+AYp0GveOXc/5mOKgZ2gVhEscpe/X8sc4cmWVPx
	11du91yR2QjGURAQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795596463; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WLw5iSLUAmy5ESjmbTA6ThiW5AF9rDmQb0R0/WJ6aCs=;
	b=G5/pHpGgJ+KX/BAPyqrfkORLpvZZ2w2sPOsdSr9Aa6d/S0BTaAsj041hgU6q8Xx7Es/HO4
	vCWtNLkkgWw69gT3KFSZkNdF4TImelbmEdC00v6oGMOc5Mhe2eGGphFvBf5ZxMVhq2WwUS
	/kZAgJWDINutbQZW2YZaZV5zvw8ht9A=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795596463;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WLw5iSLUAmy5ESjmbTA6ThiW5AF9rDmQb0R0/WJ6aCs=;
	b=uThUAfA+mQDqsC3uBXC/kZ6qobt/aiXkG2wPdqYaV56ahkHKu4SUllbMGqyh6QdYUxnTHe
	76GoEn2qMIcPHnCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 90A7F134CA;
	Wed, 25 Nov 2026 08:47:43 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 0yVvG6+gBmvGfQAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 25 Nov 2026 08:47:43 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 2440E27BBD; Wed, 25 Nov 2026 09:47:39 +0100 (CET)
Date: Wed, 25 Nov 2026 09:47:39 +0100
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
Subject: Re: [PATCH RFC 5/5] mm/filemap: refuse releasing maybe_dma_pinned
 folios
Message-ID: <fsmnfotflgrddrlak24cve7vkcjkellsgb3xbei5ysxvmqnul6@byvxblm4dtqm>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <20261119-gup-dirty-what-v1-5-236d69f25c24@suse.de>
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
In-Reply-To: <20261119-gup-dirty-what-v1-5-236d69f25c24@suse.de>
X-Spam-Flag: NO
X-Spam-Level: 
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -12.80

On Thu 19-11-26 20:10:48, Pedro Falcato wrote:
> Some callers, like folio_unmap_invalidate(), call filemap_release_folio()
> without any care for folio refcounts. This is on purpose. As
> folio_unmap_invalidate() states, invalidate_inode_pages2() needs stronger
> guarantees, and "can't afford to leave folios behind because
> shrink_folio_list() has a temp ref on them". Ok.
> 
> Use folio_maybe_dma_pinned() universally, in filemap_release_folio(). This
> has a much lower false positive rate, and should be ok enough for most
> serious cases.
> 
> While here, properly assert that no folio passed to release_folio is
> mapped.
> 
> Cc: stable@vger.kernel.org
> Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
> Signed-off-by: Pedro Falcato <pfalcato@suse.de>

Looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

and we'll see whether there's some path which actually required private
data on pinned page to be freed in some cornercase :)

								Honza

> ---
>  mm/filemap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index f9e34144c53c..4fa75663b7f3 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -4571,8 +4571,11 @@ bool filemap_release_folio(struct folio *folio, gfp_t gfp)
>  	struct address_space * const mapping = folio->mapping;
>  
>  	BUG_ON(!folio_test_locked(folio));
> +	VM_WARN_ON_FOLIO(folio_mapped(folio), folio);
>  	if (!folio_needs_release(folio))
>  		return true;
> +	if (folio_maybe_dma_pinned(folio))
> +		return false;
>  	if (folio_test_writeback(folio))
>  		return false;
>  
> 
> -- 
> 2.56.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
