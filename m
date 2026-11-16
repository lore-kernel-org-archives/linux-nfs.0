Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794826062;
	b=U9fJ0NKNrqKYrZM09UiMAOoMp5kMERqb5vEjOa4+wqHL0rowFTnieblhVdyy1/vmlqF0
	 YIjUSEZp+JFNrDgf2UGJ1rMCRzGVEFuqOu3RenfY13ib9XEHSrKmVKwsfg6rNvK+DUfI6
	 WN8i6bJVvt7x/JpmIPQ/pVfP1qoCiSOIRIdGBUnyVKlx15YwXwyyN03qnPnv5E3K6uZYa
	 KCnh+h07FUhKHNkn2OhTp8EpnvtI3nZXoqO/LIUkLs2AY0LioPklPgvXuhqz99KESQxF8
	 CRSN+MwVygd+XWf+Dx77gxlpIwEMSuemLBOzsuU29OcxJPRCuVTTclx3jHTZDXFAlPw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794826062;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=XTTKVSXYOeC94N9rF1eBh/d2Q5pkxmY2099mbwBlcHc=;
	b=jMz29guEXIL8LOK4/MimKDwVqPv9fdQKFrGHTPj5VFNfcz8pcP3pUiY4GQtPfItDxqNI
	 luOeUfIMe9i6ygcBN5TFy0/kGsU9FyHBW9R53mh3+CWN6q0W5xNd9dEKKkZGANTHJ9TkC
	 wsFIuQq0cdoyJTENsevE+0UlXG8TF2/3F/IPaGh/Xf6pKsU+yr8fSlEjNSKOfviZhTXq+
	 0dgJFsjnvJ4IJz9paihI+cyXSf5cKTqu/jhyEW5qjOeaPdzRNwXyMarR/GtQn/ObAj/WM
	 xE9pRKIm9/EwQEQdR3Cj9jfqbNgJZMKQx1WFHvmWjfSrA9qYtnyfXiMqv12p0PMKwFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="GQ8MT/a3";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=tSvqMv6N;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=OHoLwwQ0;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=cFtLglZc;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32762606A31C;
	Mon, 16 Nov 2026 10:47:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 32762606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=GQ8MT/a3;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=tSvqMv6N;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=OHoLwwQ0;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=cFtLglZc
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id EED2222290;
	Mon, 16 Nov 2026 10:47:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826060; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=XTTKVSXYOeC94N9rF1eBh/d2Q5pkxmY2099mbwBlcHc=;
	b=GQ8MT/a3HQjVMr4dqMSlvqNqSJW41G+GZ5j/3EGKRKzyxebiOCeVZMDjWeFrZ8G+XCZD1r
	L2qx01GWsmVBzJF1h6EHSCXt9pXZTiMeyl3pi+bz86Bx35NQpQb8Ivz4nACPp2qx8rWlaA
	yQDtYpW4HmjrU+LLF3hHx5i9TPGb7GA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826060;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=XTTKVSXYOeC94N9rF1eBh/d2Q5pkxmY2099mbwBlcHc=;
	b=tSvqMv6Nqy8Zkuk+n90WOu9Ru6DolzbE1N8Yir4OL89YR6Gv+DMh6pQr96+MzNx2/ngjt6
	1lV/HvRFTgcxP0Ag==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=OHoLwwQ0;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=cFtLglZc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826058; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=XTTKVSXYOeC94N9rF1eBh/d2Q5pkxmY2099mbwBlcHc=;
	b=OHoLwwQ0OTXXk+IuVBwvtezKOCIe3+R8Zb6YmRs0CFCFMWIGSj+xAMC78ZZvuiFJe+icj9
	6s0ERiZCsBbMy4pPuEj+EY5kJv9fmWpsN1eUrELL/sV4aZzxzUQVVuWp2MQSMlYTZQV+Z5
	skLcu9BtCKFjlvxrF46KGo0JMfTGst8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826058;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=XTTKVSXYOeC94N9rF1eBh/d2Q5pkxmY2099mbwBlcHc=;
	b=cFtLglZcWyzJKbynjhd0va5QG5ivPkZI+KtyYInk6FzPqsbplQMpbdaZxe3wJIl7xVCAB6
	/Y55bcydBuRG7VDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C796E1334C;
	Mon, 16 Nov 2026 10:47:38 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id eAZJKErf+moaegAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 10:47:38 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 59B4724DA2; Mon, 16 Nov 2026 11:47:38 +0100 (CET)
Date: Mon, 16 Nov 2026 11:47:38 +0100
From: Jan Kara <jack@suse.cz>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	linux-mm@kvack.org, Christian Brauner <brauner@kernel.org>, 
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v12 1/7] mm: move clearing the dropbehind flag of a found
 folio into a helper
Message-ID: <t7kkd2xt36h74bc5zihmbmaofkxi74nuca6ku7kyora6mq3jqi@qgwmzgc6tnav>
References: <20261112190911.84702-1-snitzer@kernel.org>
 <20261112190911.84702-2-snitzer@kernel.org>
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
In-Reply-To: <20261112190911.84702-2-snitzer@kernel.org>
X-Rspamd-Queue-Id: EED2222290
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:dkim,suse.cz:email,lst.de:email];
	TO_DN_SOME(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCVD_COUNT_THREE(0.00)[3];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_SEVEN(0.00)[10];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[lst.de:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:dkim,suse.cz:email]
X-Spam-Score: -13.01

On Thu 12-11-26 14:09:04, Mike Snitzer wrote:
> Move the code in __filemap_get_folio_mpol() that clears PG_dropbehind
> on a folio found by a cached lookup, and takes the folio off
> WB_DONTCACHE_DIRTY, into filemap_clear_dropbehind().  No functional
> change.  The next patch changes the helper.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 33 ++++++++++++++++++++-------------
>  1 file changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b04be64a5069f..437113addbddf 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1956,6 +1956,24 @@ void *filemap_get_entry(struct address_space *mapping, pgoff_t index)
>  	return folio;
>  }
>  
> +/* Clear the dropbehind flag of a folio that a cached lookup found. */
> +static void filemap_clear_dropbehind(struct address_space *mapping,
> +				     struct folio *folio)
> +{
> +	if (!folio_test_clear_dropbehind(folio))
> +		return;
> +	if (folio_test_dirty(folio) && mapping_can_writeback(mapping)) {
> +		struct inode *inode = mapping->host;
> +		struct bdi_writeback *wb;
> +		struct wb_lock_cookie cookie = {};
> +		long nr = folio_nr_pages(folio);
> +
> +		wb = unlocked_inode_to_wb_begin(inode, &cookie);
> +		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
> +		unlocked_inode_to_wb_end(inode, &cookie);
> +	}
> +}
> +
>  /**
>   * __filemap_get_folio_mpol - Find and get a reference to a folio.
>   * @mapping: The address_space to search.
> @@ -2087,19 +2105,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
>  	if (!folio)
>  		return ERR_PTR(-ENOENT);
>  	/* not an uncached lookup, clear uncached if set */
> -	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_clear_dropbehind(folio)) {
> -		if (folio_test_dirty(folio) &&
> -		    mapping_can_writeback(mapping)) {
> -			struct inode *inode = mapping->host;
> -			struct bdi_writeback *wb;
> -			struct wb_lock_cookie cookie = {};
> -			long nr = folio_nr_pages(folio);
> -
> -			wb = unlocked_inode_to_wb_begin(inode, &cookie);
> -			wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
> -			unlocked_inode_to_wb_end(inode, &cookie);
> -		}
> -	}
> +	if (!(fgp_flags & FGP_DONTCACHE))
> +		filemap_clear_dropbehind(mapping, folio);
>  	return folio;
>  }
>  EXPORT_SYMBOL(__filemap_get_folio_mpol);
> -- 
> 2.52.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
