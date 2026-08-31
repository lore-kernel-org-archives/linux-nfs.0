Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49B5E3E6394;
	Mon, 31 Aug 2026 10:08:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788170885; cv=none; b=Jv07jLG/qoJyBfG1xTyhqcd71J6YoE/oTLXquuZrs0cgPrNdgPtN5IXjEEeUzKlrNQOn85U1riM4/P+5mLpHdNgi63QVLTvC7kPK2jrZskCtnuO3/WOGFBur23A/TLly6Qk5lM/6/Vo67A3nO+lBf+jY5UTl/tRNEK2U4rN16W4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788170885; c=relaxed/simple;
	bh=FLZrLAVX3QjsoTAX93eGV3hYHIDUF6lzvReBHdrgG6w=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=gAHmDEeQ2xz/j+dDOVvP60IKP9kCl44CkCXlBF8foQ0IeOBcUS82CbyEm2DZBjyG2CWD6ZFFz/RlFgSop0HwG7qxUVPS1/Sl8SHmx3iizoJAVfc4i9HoC+ML4CfbiL37KI+F8eYQRmmFWciQIZKPNpjk1RbUelotp6WX9GXsoAI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=aNRfX8vx; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=C2FBLfRx; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=bYP23/Jw; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=HJyZzCAq; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="aNRfX8vx";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="C2FBLfRx";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="bYP23/Jw";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="HJyZzCAq"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id D72481FB3C;
	Mon, 31 Aug 2026 10:07:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170878; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kgcS0o3Xgc0q06A194A0nwAi34yqPqnCWzQ7aKp6YgU=;
	b=aNRfX8vxxjM3odxsdfJV6wO0jG1NqkuTD9HoFNIODpmSWjCxeNfMdMYvhmzKQjujswSnS/
	rsw2myUH73slSIpAbHyQIpFfxod/SQ2iQvVYWJoq5Caq6Mw/C9sC61t5fOi17IYtnepOde
	7PSGZ/7EJG/gjRtw+IKV6ViVMkT9ZzI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170878;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kgcS0o3Xgc0q06A194A0nwAi34yqPqnCWzQ7aKp6YgU=;
	b=C2FBLfRx5w0FhBlYmUEqJBJeiO+tYeVwOm3uAqGwG+EH4A/5oSH+COi7OpJf0RrTmcyy3Y
	+8lyiHRF5PTrfjCA==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b="bYP23/Jw";
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=HJyZzCAq
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170873; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kgcS0o3Xgc0q06A194A0nwAi34yqPqnCWzQ7aKp6YgU=;
	b=bYP23/JwEC8Iz5BXzI8ktYpWIGLxXVJ+2iWwruUdHZ9/LPZaqgfV59aDVFEPG5i3JOTaks
	2uIp7s/5M7c+SLxJsp+nlM5EyOiFQZtnegZ12+DPLgrtIOdAQeUPZb/CMSXHltIUiRLDts
	FI0VoUMNgmd+3o2uc4+mgVVrJDfjYtY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170873;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kgcS0o3Xgc0q06A194A0nwAi34yqPqnCWzQ7aKp6YgU=;
	b=HJyZzCAqmkoMNCvobtYJW6f9ASXIDXGTYKAyP3rU5YD/8sFndO8X/CKnGEI4bW/Uok/xuJ
	kiVj+Hpb5awsiaBQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A253D13682;
	Mon, 31 Aug 2026 10:07:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id vNCfJ3lSlWobeQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 10:07:53 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 39461A13B5; Mon, 31 Aug 2026 12:07:45 +0200 (CEST)
Date: Mon, 31 Aug 2026 12:07:45 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 4/9] nfs: Remove redundant FGP_NOFS
Message-ID: <qabnsbfd2jknm6g6h2jqlavbpxiem3f2rfu6lwozmlt264aknw@6vxajyigvkaz>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-5-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-5-willy@infradead.org>
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: D72481FB3C
X-Spamd-Result: default: False [-2.51 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	RCPT_COUNT_TWELVE(0.00)[18];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TAGGED_RCPT(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_CC(0.00)[brauner.io,suse.cz,kernel.org,mit.edu,gmail.com,squashfs.org.uk,lists.ozlabs.org,vger.kernel.org,lists.linux.dev,kvack.org];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,infradead.org:email,suse.com:email,suse.cz:dkim,suse.cz:email]
X-Spam-Flag: NO
X-Spam-Score: -2.51

On Sun 30-08-26 05:18:51, Matthew Wilcox (Oracle) wrote:
> The flags already include FGP_NOWAIT which prohibits all reclaim, not
> just reclaiming from the filesystem.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Obvious enough :) feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/nfs/dir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 49394123bd09..e34125a8a2e2 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -447,7 +447,7 @@ static struct folio *nfs_readdir_folio_get_next(struct address_space *mapping,
>  	struct folio *folio;
>  
>  	folio = __filemap_get_folio(mapping, index,
> -			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
> +			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
>  			mapping_gfp_mask(mapping));
>  	if (IS_ERR(folio))
>  		return NULL;
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
