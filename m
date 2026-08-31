Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77EA13E5A03;
	Mon, 31 Aug 2026 10:12:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788171124; cv=none; b=MKNhlRnKMS9m091Jt9zTzHXcKXGhdrdkOn6Y+MRj3q2L0zsQlRJoJmGcN3pe6kqzwt+xdZTJos77pfGZpedWF8Y5SW+U74VjfYZOTI/votqggGDmMvoiHizAX9/PeF7piqFEkSKvkYinim7phWoFchkAg965zPA6x5F98K/2q30=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788171124; c=relaxed/simple;
	bh=Iq0d5n6IlO3NBhdFk5UBLPgwEZU19VrtosRUfUZtQ4E=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=B42i1tlQjOegYK5KDL912vTybTD6gs+bdel/DcC5VvxmUst3/sArW91QN8FXxiizrYwmP6VOc4WDRvcsZbs/ge2ofPX7K3eePz/QjsJSweeHf80K0vedoTpLOVH5qCsxwgzBH2iVdvzc6TEtMeg2/dvZfPGBh6RjLlmEDAL2yCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=A1cs8iP+; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=xjG79jMA; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=F+W7yegO; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=o4nK9Cvo; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="A1cs8iP+";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="xjG79jMA";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="F+W7yegO";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="o4nK9Cvo"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 481B11FB86;
	Mon, 31 Aug 2026 10:11:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788171116; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=L58Z7+BXjdSqb3Vh9n8TDNy2pZxNZI0wP+OuP60u9BQ=;
	b=A1cs8iP+Nvyyux++q0vtbMa3kH8cI64Ua+JXZ3doMv37YUyN6i6MUwvKScUqv4zGOiMkI7
	0asjHhByYIBYKrlmWDoiALVvUNpDsELSmrdS1USnP8/tEalHdoZi5+h6Z24vA9kyVtLcpV
	rNxkPYv1HgsK/oxX4nBFrN3DA0IXaOQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788171116;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=L58Z7+BXjdSqb3Vh9n8TDNy2pZxNZI0wP+OuP60u9BQ=;
	b=xjG79jMAZv7ON1n3tUBENQUqE/7TTqLmTnH+VeBN7NN4zMK43kKnRIFXyBdPEaRq12IcEl
	Fpi9bK3txwfCOEDg==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=F+W7yegO;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=o4nK9Cvo
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788171112; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=L58Z7+BXjdSqb3Vh9n8TDNy2pZxNZI0wP+OuP60u9BQ=;
	b=F+W7yegO8lF8Zxf8amh5VWl6oahxp5Hh6GwJLyL/oKyRWViCy1g0WLDkRWUrSGrEiVOZiY
	RYWcFc0LIHfuMC+s0ovTElTgB1fzA0qhPB52C0MwARE0f/73BFUC3CtiFoe0jMzqytECQL
	QDjGbU1OEohAUkq3r3ybPCcbLXaawVs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788171112;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=L58Z7+BXjdSqb3Vh9n8TDNy2pZxNZI0wP+OuP60u9BQ=;
	b=o4nK9Cvoz6WVPfkrCSBPa+eFBQwLBoRiLh9TgJmTbXQL+N79z47Fy4WidY40CcLTKJEZ7X
	T8j1Yzcrdhfiv3Dw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 2891C13682;
	Mon, 31 Aug 2026 10:11:52 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id bZnlCWhTlWoXfQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 10:11:52 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id B8034A13B5; Mon, 31 Aug 2026 12:11:51 +0200 (CEST)
Date: Mon, 31 Aug 2026 12:11:51 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 7/9] squashfs: Remove use of FGP_NOFS
Message-ID: <kg2pupprlig5gqaqgjydpxfkrsi42bu2li6cingcmu3aidqhyp@afi5wxdrauk6>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-8-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-8-willy@infradead.org>
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: 481B11FB86
X-Spamd-Result: default: False [-2.51 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MIME_TRACE(0.00)[0:+];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	TAGGED_RCPT(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	MISSING_XM_UA(0.00)[];
	FREEMAIL_CC(0.00)[brauner.io,suse.cz,kernel.org,mit.edu,gmail.com,squashfs.org.uk,lists.ozlabs.org,vger.kernel.org,lists.linux.dev,kvack.org];
	DBL_BLOCKED_OPENRESOLVER(0.00)[infradead.org:email,suse.cz:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Flag: NO
X-Spam-Score: -2.51

On Sun 30-08-26 05:18:54, Matthew Wilcox (Oracle) wrote:
> Since we can allocate memory while holding a folio locked, we cannot
> allow page reclaim to call into the filesystem and attempt to compact
> the folio we're currently holding locked.  Use memalloc_nofs_save()
> instead of FGP_NOFS here.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  fs/squashfs/file.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
> index d83594ce91d2..34c550a266bc 100644
> --- a/fs/squashfs/file.c
> +++ b/fs/squashfs/file.c
> @@ -398,6 +398,7 @@ void squashfs_copy_cache(struct folio *folio,
>  	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
>  	int i, mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
>  	int start_index = folio->index & ~mask, end_index = start_index | mask;
> +	unsigned int nofs = memalloc_nofs_save();

Why do you need this? The only allocation I can see is the one using
FGP_NOWAIT below...

								Honza

>  
>  	/*
>  	 * Loop copying datablock into pages.  As the datablock likely covers
> @@ -415,7 +416,7 @@ void squashfs_copy_cache(struct folio *folio,
>  
>  		push_folio = (i == folio->index) ? folio :
>  			__filemap_get_folio(mapping, i,
> -					FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
> +					FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
>  					mapping_gfp_mask(mapping));
>  
>  		if (IS_ERR(push_folio))
> @@ -430,6 +431,8 @@ void squashfs_copy_cache(struct folio *folio,
>  		if (i != folio->index)
>  			folio_put(push_folio);
>  	}
> +
> +	memalloc_nofs_restore(nofs);
>  }
>  
>  /* Read datablock stored packed inside a fragment (tail-end packed block) */
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
