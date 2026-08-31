Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A94EA3D093A;
	Mon, 31 Aug 2026 10:07:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788170843; cv=none; b=WeGaHIibnCIV4/5wGsvHySE6W6kdv3PgRSqViOB1OOF1MQM9LzvIamcL22YmYS00mW2PCTm5gEbnOflvIZOChGZbEfhWI5w1GA0mecCjud7WXwjcGULqITHKKFzZ8YujoCdv7Nt2C0tDdm8nvGDb8wSFWBoU6LSKM3RwTe69vx0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788170843; c=relaxed/simple;
	bh=kvaWWRiaaJhiZCDTvexHGQQhayiUnZqOkk4kPsAQCG8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=C1CPezSkColeWMMrlFM0gDb6kmq4l/DCjvYBKYJm9en5x0GFz5DK2P5Crlz4lzO8vwJLap1k7CKhrd9HZ/mlAaW/3lTBpczy9pYOiJpnofTXCrfz00/p/1kFI55yFDSDM0lPacm2doNoso4tdffEyi7LgvWmkmLrXEe1qZtz7LY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=ibv5f5Gl; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=qVXsQE1U; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=GMxYCD3L; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=0qmeRH23; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="ibv5f5Gl";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="qVXsQE1U";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="GMxYCD3L";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="0qmeRH23"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 82F5321D5F;
	Mon, 31 Aug 2026 10:07:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170835; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=VRhEETd/QD3arS4AOP9puZWciLjCr9/ZkGT0N1D6mXg=;
	b=ibv5f5GlLRKMz1Uhp6ulwWFEwjSQYiYK/DTmaEf5F2HTF0I2hlRJJ7vvrYrGocoE5NVFQv
	+pwEe02AgQ0D3AFo2YEMYj6ykews73rfx4vOzlzNmkVVyzzMeU/ASgPpYNo7Lt3WuEhZn0
	ThY6cAelEbb9m+PuLKSBCPkNy8xpVgI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170835;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=VRhEETd/QD3arS4AOP9puZWciLjCr9/ZkGT0N1D6mXg=;
	b=qVXsQE1UY3HnYN02bCfPHOEbsIQuIww49jcY36/Hve7xmVaOdTIEUIcImh59T6iGkPPyJo
	F0a5uwbQJ8jM8zCw==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170831; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=VRhEETd/QD3arS4AOP9puZWciLjCr9/ZkGT0N1D6mXg=;
	b=GMxYCD3LSTusC10mpBMhUNPSuLBDpLNxsHzlBwwrSQtH3lXKtNnD7WY4Amv8RowU98YNcY
	rl40zgPVkDdvBgE31dedH3H2n3gl+M15EZ9ruGd05GuhxMgY+P45QFfou5wgSUC4IJFSYf
	JYZFZ7F4kFMHGUdzr+V3yCufVP0J4YY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170831;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=VRhEETd/QD3arS4AOP9puZWciLjCr9/ZkGT0N1D6mXg=;
	b=0qmeRH239q3ahdU5C6vsri2MusHZcu1kMZz77o3qn7wT51bUKpOcKeK2sgmd5SuJcIZrnM
	YkAivvxBlASrBJCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6322713515;
	Mon, 31 Aug 2026 10:07:11 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id PRAzGE9SlWpgeAAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 10:07:11 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 128EAA13B5; Mon, 31 Aug 2026 12:07:11 +0200 (CEST)
Date: Mon, 31 Aug 2026 12:07:11 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 9/9] filemap: Remove FGP_NOFS
Message-ID: <6vnditkfrebo7ylr6g33kvzefn4iahstd3hlzzjvtcfk36dffq@zw4akv7ga6az>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-10-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-10-willy@infradead.org>
X-Spam-Score: -2.30
X-Spam-Level: 
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo,infradead.org:email]
X-Spam-Flag: NO

On Sun 30-08-26 05:18:56, Matthew Wilcox (Oracle) wrote:
> There are no more users of FGP_NOFS.  Remove it.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/pagemap.h | 10 ++++------
>  mm/filemap.c            |  2 --
>  2 files changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 3974b063a049..bff8b7264fb0 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -697,7 +697,6 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
>   *   folio is already in cache.  If the folio was allocated, unlock it
>   *   before returning so the caller can do the same dance.
>   * * %FGP_WRITE - The folio will be written to by the caller.
> - * * %FGP_NOFS - __GFP_FS will get cleared in gfp.
>   * * %FGP_NOWAIT - Don't block on the folio lock.
>   * * %FGP_STABLE - Wait for the folio to be stable (finished writeback)
>   * * %FGP_DONTCACHE - Uncached buffered IO
> @@ -710,11 +709,10 @@ typedef unsigned int __bitwise fgf_t;
>  #define FGP_LOCK		((__force fgf_t)0x00000002)
>  #define FGP_CREAT		((__force fgf_t)0x00000004)
>  #define FGP_WRITE		((__force fgf_t)0x00000008)
> -#define FGP_NOFS		((__force fgf_t)0x00000010)
> -#define FGP_NOWAIT		((__force fgf_t)0x00000020)
> -#define FGP_FOR_MMAP		((__force fgf_t)0x00000040)
> -#define FGP_STABLE		((__force fgf_t)0x00000080)
> -#define FGP_DONTCACHE		((__force fgf_t)0x00000100)
> +#define FGP_NOWAIT		((__force fgf_t)0x00000010)
> +#define FGP_FOR_MMAP		((__force fgf_t)0x00000020)
> +#define FGP_STABLE		((__force fgf_t)0x00000040)
> +#define FGP_DONTCACHE		((__force fgf_t)0x00000080)
>  #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
>  
>  #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 6afec636881f..e6580291f218 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1994,8 +1994,6 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
>  
>  		if ((fgp_flags & FGP_WRITE) && mapping_can_writeback(mapping))
>  			gfp |= __GFP_WRITE;
> -		if (fgp_flags & FGP_NOFS)
> -			gfp &= ~__GFP_FS;
>  		if (fgp_flags & FGP_NOWAIT) {
>  			gfp &= ~GFP_KERNEL;
>  			gfp |= GFP_NOWAIT;
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
