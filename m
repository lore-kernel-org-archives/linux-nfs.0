Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794826100;
	b=czb1B2+GgvmP6+jgGYZ8mMHLa3n3rMJ4H9KSdEOE4VpbTNYEg7cNTGfA3iCr4Akgdkhv
	 3YcufCSl9E/nU8OIIRs0voPKMevh5MbZog8Z6V/H/I7PKZmfxijTZyy8gHNQPxtWPRzx3
	 SjcuzUNOxeb7MVtsBNoe3z66mdLnhBomB2zLX8b1fI8cAOFPO8MCCCRG11F3RmUmuyxjW
	 AFjgzrvXvGas/Ag9dBTnUv4vvU6//d5vWu2z5CeI7Ix0AZHPNA/IhMc8+uJ0XV1rln4vw
	 jqpasZ4tY4xjtelCpUgHlpg4Q6sXZ+JRleNOJ0U5RQlFUDZRmBzwm3gWqnPx2462Itw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794826100;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=+g+4dXU+HuELXyVSUIrp/LWRT/qicQKov3vtoMydt5Q=;
	b=dsIoeexSwvCodH5gb6k/9Nxjl4MEQBwtzQ/8hvjc94xgUe+3U4Ph8U8TaMeFG2PGXHH3
	 O853m3F6rP8+GYt4Fdf8qnqleyYFb7zcHy38pL+4XUPF88qXc+ZLItr2zGL/UPBunGSBf
	 Br0NaryJLU3CVPx88La/oF2+HZXc5Erq225piPhI0y7fD4sSeBJBZfVGCH37D4Lk6cy/w
	 Fs04rwI2OJ4bogSNjP8qvZ7M06u1pApi8vOQfpimrycx8Lv34Ci/GrGzt1f8jhX5vNbjw
	 oA7/GleiONpNalsaFDRlm/dHY5AqlYfUXWhutiaYNjuuu5qlm8T9S6gpDT1OPJcjgyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="qA/9s6i/";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=O5umAqWZ;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="qA/9s6i/";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=O5umAqWZ;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4D63606A887;
	Mon, 16 Nov 2026 10:48:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A4D63606A887
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=qA/9s6i/;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=O5umAqWZ;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=qA/9s6i/;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=O5umAqWZ
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id BBB371FD2A;
	Mon, 16 Nov 2026 10:48:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826097; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+g+4dXU+HuELXyVSUIrp/LWRT/qicQKov3vtoMydt5Q=;
	b=qA/9s6i/u7bq2d9GfPfDcYsFHKP2JgbpHR68H1LO2pBAWlZfn21xRmcd0CMR0GkDTqajkT
	wKB/LEMyrMLZBV6vtzo+gf1ATCHX/vgo5ROuh/7CBmSZYOrLXSyuGlN4SCG3QMKLLixp14
	fqAJep5rcTV2yfnoETsdPdH/reX06VQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826097;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+g+4dXU+HuELXyVSUIrp/LWRT/qicQKov3vtoMydt5Q=;
	b=O5umAqWZs5FSuqCVFxNDCA7r3oEFPdQlNVdigiphyohvjI/G/1U2+fH/YzGNu03dmvZvRv
	NiJ2/87ajSRKHbCg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826097; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+g+4dXU+HuELXyVSUIrp/LWRT/qicQKov3vtoMydt5Q=;
	b=qA/9s6i/u7bq2d9GfPfDcYsFHKP2JgbpHR68H1LO2pBAWlZfn21xRmcd0CMR0GkDTqajkT
	wKB/LEMyrMLZBV6vtzo+gf1ATCHX/vgo5ROuh/7CBmSZYOrLXSyuGlN4SCG3QMKLLixp14
	fqAJep5rcTV2yfnoETsdPdH/reX06VQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826097;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+g+4dXU+HuELXyVSUIrp/LWRT/qicQKov3vtoMydt5Q=;
	b=O5umAqWZs5FSuqCVFxNDCA7r3oEFPdQlNVdigiphyohvjI/G/1U2+fH/YzGNu03dmvZvRv
	NiJ2/87ajSRKHbCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 91B231334C;
	Mon, 16 Nov 2026 10:48:17 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id BlLVG3Hf+mrJegAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 10:48:17 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 26AE024DA4; Mon, 16 Nov 2026 11:48:17 +0100 (CET)
Date: Mon, 16 Nov 2026 11:48:17 +0100
From: Jan Kara <jack@suse.cz>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	linux-mm@kvack.org, Christian Brauner <brauner@kernel.org>, 
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v12 2/7] mm: take a folio off WB_DONTCACHE_DIRTY only if
 it was counted there
Message-ID: <o3eskak6hilkz5kby6w2unwzlwgqk4l7ye35ung5nstovvh3ip@m26252po4ioz>
References: <20261112190911.84702-1-snitzer@kernel.org>
 <20261112190911.84702-3-snitzer@kernel.org>
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
In-Reply-To: <20261112190911.84702-3-snitzer@kernel.org>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCPT_COUNT_SEVEN(0.00)[9];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Thu 12-11-26 14:09:05, Mike Snitzer wrote:
> A cached lookup that finds a dropbehind folio clears the flag and
> subtracts the folio from WB_DONTCACHE_DIRTY if PG_dirty is set.  That
> test races with the dirtying of the folio.  filemap_dirty_folio() sets
> PG_dirty before folio_account_dirtied() counts the folio, so a lookup in
> between subtracts a folio that was never added.  The lookup also does
> not hold the folio lock.  Every other path that subtracts a dirty folio
> from the counter holds it, so the lookup can subtract the folio a second
> time.  Either way the counter drifts, and once it is negative the
> DONTCACHE writeback kick writes nothing.
> 
> Fix this by having filemap_clear_dropbehind() clear the dropbehind flag
> of a folio that a cached lookup found, and take the folio off
> WB_DONTCACHE_DIRTY if it is counted there.  With the folio locked and
> the i_pages lock held, the folio is counted if both PG_dirty and the
> dirty tag are set.  A folio that another task has locked keeps the
> flag.
> 
> Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 42 ++++++++++++++++++++++++++++--------------
>  1 file changed, 28 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 437113addbddf..98ce955404127 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1956,22 +1956,36 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
>  	return folio;
>  }
>  
> -/* Clear the dropbehind flag of a folio that a cached lookup found. */
> +/*
> + * Clear the dropbehind flag of a folio that a cached lookup found, and take
> + * the folio off WB_DONTCACHE_DIRTY if it is counted there.  With the folio
> + * locked and the i_pages lock held, the folio is counted if both PG_dirty and
> + * the dirty tag are set.  A folio that another task has locked keeps the flag.
> + */
>  static void filemap_clear_dropbehind(struct address_space *mapping,
> -				     struct folio *folio)
> +				     struct folio *folio, bool locked)
>  {
> -	if (!folio_test_clear_dropbehind(folio))
> -		return;
> -	if (folio_test_dirty(folio) && mapping_can_writeback(mapping)) {
> -		struct inode *inode = mapping->host;
> -		struct bdi_writeback *wb;
> -		struct wb_lock_cookie cookie = {};
> -		long nr = folio_nr_pages(folio);
> +	unsigned long flags;
>  
> -		wb = unlocked_inode_to_wb_begin(inode, &cookie);
> -		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
> -		unlocked_inode_to_wb_end(inode, &cookie);
> +	if (!locked) {
> +		if (!folio_trylock(folio))
> +			return;
> +		if (unlikely(folio->mapping != mapping))
> +			goto out;
>  	}
> +	if (!mapping_can_writeback(mapping)) {
> +		folio_clear_dropbehind(folio);
> +		goto out;
> +	}
> +	xa_lock_irqsave(&mapping->i_pages, flags);
> +	if (folio_test_clear_dropbehind(folio) && folio_test_dirty(folio) &&
> +	    xa_get_mark(&mapping->i_pages, folio->index, PAGECACHE_TAG_DIRTY))
> +		wb_stat_mod(inode_to_wb(mapping->host), WB_DONTCACHE_DIRTY,
> +			    -folio_nr_pages(folio));
> +	xa_unlock_irqrestore(&mapping->i_pages, flags);
> +out:
> +	if (!locked)
> +		folio_unlock(folio);
>  }
>  
>  /**
> @@ -2105,8 +2119,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
>  	if (!folio)
>  		return ERR_PTR(-ENOENT);
>  	/* not an uncached lookup, clear uncached if set */
> -	if (!(fgp_flags & FGP_DONTCACHE))
> -		filemap_clear_dropbehind(mapping, folio);
> +	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_dropbehind(folio))
> +		filemap_clear_dropbehind(mapping, folio, fgp_flags & FGP_LOCK);
>  	return folio;
>  }
>  EXPORT_SYMBOL(__filemap_get_folio_mpol);
> -- 
> 2.52.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
