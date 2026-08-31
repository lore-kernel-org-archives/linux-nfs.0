Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FDDB400998;
	Mon, 31 Aug 2026 09:59:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788170392; cv=none; b=kkUq/ktcgKT1euIv10ei66XFUEe11wbBAwBl6OF5EoVip4XuH3shTv8px/BP3e4gbAZ2Wx/8Ei+Xkxcxip0z4wSh/pFFp5pabyahWnWggdt1ypgF8pR+3sszyYSQN7E9rei2ZcEbfGs+cxzzFKhj0m4Q2h124I+Q9dWG3ufhjW0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788170392; c=relaxed/simple;
	bh=PqIa7f4joQ6Ewq8ZNwNRH9LrYTiWA+ynmpnFW7z1oPI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TCOd/wmiUtE5msfJyK9aUb3L5fv1FwgT2enw/D8U+YoW/8uB0K3KQnUIJPUBFxdLJieTQ2kQ1YGUq655PJrWGAlfZVOCuLgt/0WPziLeh25HpelWNgpZAYYx2gWSGPnzwfypcVi/NphEPMSCkXnIJg0fy2e+Qu2wbHtZj0cjYHY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=dW2nKgD/; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=KmcOhO0z; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=r9+5dkfj; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=vayhPUMM; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="dW2nKgD/";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="KmcOhO0z";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="r9+5dkfj";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="vayhPUMM"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id BCE4E1FAAB;
	Mon, 31 Aug 2026 09:59:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170383; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=9NwnR8kMEaTJTYkoxBQW5G3izVgqGS7StBEwaJ2omhE=;
	b=dW2nKgD/72GHfPDPSkIXHWa4TQlW9zo4m5ZJZt18et8r8SpFKwl3fSOhDCUde4WrGHhX1k
	HthafQUnqSZwcZK8Hdcs9U36lkHKEFP7wcuFYQxjwio2w5aV+Vt72W3ZXcuri1mhWwTdMf
	dP+uDJvuZa7oiZHnAx8jWbEbvlydq4E=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170383;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=9NwnR8kMEaTJTYkoxBQW5G3izVgqGS7StBEwaJ2omhE=;
	b=KmcOhO0zo72Y4OHAa8RvceB+zt8rPD1OtYKdTL75AERgXOIdssNGME6lJ09SSLwG+HwP6H
	WPniXvtYYYJ7buDA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170379; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=9NwnR8kMEaTJTYkoxBQW5G3izVgqGS7StBEwaJ2omhE=;
	b=r9+5dkfj5zv2zJtacQf2HZljTAw/25dZVX8yvLicsAhmPie/8z4lpxN7aqnWa4UN22X30z
	VqtIUOoyqHhMMot3U+vyaxuyjejWrLJMumjOQ8E3Br8VcDxJXDazwa4lekbK2hbqemViUC
	LVdcCgmonttzkdd8su0ehz6W1kl120w=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170379;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=9NwnR8kMEaTJTYkoxBQW5G3izVgqGS7StBEwaJ2omhE=;
	b=vayhPUMMZNg3rW2xgsNzuc/IUtzfsyNI4zFxAL3JrlK7XeBEytvIqcNyZdaxkU8YXY20/9
	vR13eZLPIsgFyYDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 98AE413694;
	Mon, 31 Aug 2026 09:59:39 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 2pBAJYtQlWp8cAAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 09:59:39 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 29D40A13B5; Mon, 31 Aug 2026 11:59:35 +0200 (CEST)
Date: Mon, 31 Aug 2026 11:59:35 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/9] mm: Improve memalloc_nofs_save() documentation
Message-ID: <wriwrbwg3sx5kpl6s7yggam5x7ljml2sul5rz4dm7ftbyyoqyu@yqjepgxxtd3g>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-2-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-2-willy@infradead.org>
X-Spam-Level: 
X-Spam-Score: -2.30
X-Spam-Flag: NO
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	TAGGED_RCPT(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[brauner.io,suse.cz,kernel.org,mit.edu,gmail.com,squashfs.org.uk,lists.ozlabs.org,vger.kernel.org,lists.linux.dev,kvack.org];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,imap1.dmz-prg2.suse.org:helo,suse.com:email]

On Sun 30-08-26 05:18:48, Matthew Wilcox (Oracle) wrote:
> Talk about why someone should call this function instead of
> what this function does.  This makes the long comment in mm/readahead.c
> obsolete; replace it with a comment about which case we're protecting
> against.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Yeah, I think the documentation is better. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/sched/mm.h | 31 +++++++++++++++++++++++--------
>  mm/readahead.c           | 14 ++------------
>  2 files changed, 25 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
> index d7c6a942aa7e..f76be1141b06 100644
> --- a/include/linux/sched/mm.h
> +++ b/include/linux/sched/mm.h
> @@ -372,13 +372,26 @@ static inline void memalloc_noio_restore(unsigned int flags)
>  }
>  
>  /**
> - * memalloc_nofs_save - Marks implicit GFP_NOFS allocation scope.
> + * memalloc_nofs_save - Prevent recursion into the filesystem.
>   *
> - * This functions marks the beginning of the GFP_NOFS allocation scope.
> - * All further allocations will implicitly drop __GFP_FS flag and so
> - * they are safe for the FS critical section from the allocation recursion
> - * point of view. Use memalloc_nofs_restore to end the scope with flags
> - * returned by this function.
> + * All memory allocations between calling this function and calling
> + * memalloc_nofs_restore() will be prevented from calling into filesystems
> + * to reclaim memory.  Clean page cache memory can still be reclaimed,
> + * but (for example) inodes will not be.
> + *
> + * The primary reason to do this is that the caller has taken a lock
> + * which would be needed by FS reclaim.  While we could theoretically
> + * call into a different filesystem in this case, it can be a deep call
> + * stack so it is better to avoid all filesystems.
> + *
> + * Filesystems often choose to incorporate a call to this function as part
> + * of starting a journal transaction.  While not a lock in the normal
> + * sense, it has much the same effect as nested journal transactions
> + * are either prohibited or expensive.
> + *
> + * Also call this function if you need to allocate memory while holding
> + * a file folio locked.  High order allocations (such as those requested
> + * by slab) can trigger compaction which will attempt to lock the folio.
>   *
>   * Context: This function is safe to be used from any context.
>   * Return: The saved flags to be passed to memalloc_nofs_restore.
> @@ -389,10 +402,12 @@ static inline unsigned int memalloc_nofs_save(void)
>  }
>  
>  /**
> - * memalloc_nofs_restore - Ends the implicit GFP_NOFS scope.
> + * memalloc_nofs_restore - End filesystem reclaim scope.
>   * @flags: Flags to restore.
>   *
> - * Ends the implicit GFP_NOFS scope started by memalloc_nofs_save function.
> + * Ends the implicit memory allocation scope started by
> + * memalloc_nofs_save().  This may not enable access to filesystem reclaim
> + * if it was already disabled at the time memalloc_nofs_save() was called.
>   * Always make sure that the given flags is the return value from the
>   * pairing memalloc_nofs_save call.
>   */
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 6e5563290287..9c116d4ba963 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -227,17 +227,7 @@ void page_cache_ra_unbounded(struct readahead_control *ractl,
>  	gfp_t gfp_mask = readahead_gfp_mask(mapping);
>  	unsigned long mark = ULONG_MAX, i = 0;
>  	unsigned int min_nrpages = mapping_min_folio_nrpages(mapping);
> -
> -	/*
> -	 * Partway through the readahead operation, we will have added
> -	 * locked pages to the page cache, but will not yet have submitted
> -	 * them for I/O.  Adding another page may need to allocate memory,
> -	 * which can trigger memory reclaim.  Telling the VM we're in
> -	 * the middle of a filesystem operation will cause it to not
> -	 * touch file-backed pages, preventing a deadlock.  Most (all?)
> -	 * filesystems already specify __GFP_NOFS in their mapping's
> -	 * gfp_mask, but let's be explicit here.
> -	 */
> +	/* Allocating with locked folios */
>  	unsigned int nofs = memalloc_nofs_save();
>  
>  	lockdep_assert_held(&mapping->invalidate_lock);
> @@ -512,7 +502,7 @@ void page_cache_ra_order(struct readahead_control *ractl,
>  
>  	ra->order = new_order;
>  
> -	/* See comment in page_cache_ra_unbounded() */
> +	/* Allocating with locked folios */
>  	nofs = memalloc_nofs_save();
>  	filemap_invalidate_lock_shared(mapping);
>  	/*
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
