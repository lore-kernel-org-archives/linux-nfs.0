Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D86FA3E3D98;
	Mon, 31 Aug 2026 10:06:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788170792; cv=none; b=teurUiRfxzsMpQQo7EHQJPX6upEZwUNT94d5K5W+mnWVBKrvoOF5cdPSx1Ip+0g5NEPCc+FmMcO6K3MLk0IU+C8aNa6As9hkLDnS7t0Cd/KH5wDtUrm6fyEzXAqZ81LaDTWOSrJHuMgMvShDlcOwbjHtxTzxDdrKHqjO6CjbOTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788170792; c=relaxed/simple;
	bh=Zd1I1rzGLjNP5UHFN8ObvHcchBTEBO14g7z2JtxlA6U=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WipoBEKfkz/UjLtCRtwj+xtjTcwHdU5e4G5YTxqHjAevR0azLN0+QbepOiE007tNYnwsH1H9KZvyTWeZtcHTWs+EIbrzRV89daNi9Lw4yD8woxrSt9NCRYlswJ5XN9awijx4zIKaJzyQz/g4m/wiOB7gDEnpedFBnbYrKvJXj4A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=jKwu2asG; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=yIyma6zn; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=hmYbXGPh; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=NxsPq1pR; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="jKwu2asG";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="yIyma6zn";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="hmYbXGPh";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="NxsPq1pR"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id BFE4A22347;
	Mon, 31 Aug 2026 10:06:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170785; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SUNwtZYE0BZEojiBC/c0w28QoGhVaGYNfF8bWOZe0J0=;
	b=jKwu2asGObmXrCsHXGJTde/JBaodQf9kqgWIndpdOxVluroTDfauMTBO87hFsi47W9KcoG
	jTgX2l/rLJlcsCTFRacAZ2K+zTVb5Ooi78ojcnFceF6jE/F3XQrDGXyyTV6GSINgRdKdUj
	IGjwvAFewJgqf5MAhcrCXoZPYAYhKWc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170785;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SUNwtZYE0BZEojiBC/c0w28QoGhVaGYNfF8bWOZe0J0=;
	b=yIyma6znJVeJA846qMD4dW9M6BkaUTMQadp7YwBU7cxzIj4+DotGWnUz5DXezz9prWZN7K
	fKkGBq2AfP44yZCA==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=hmYbXGPh;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=NxsPq1pR
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170780; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SUNwtZYE0BZEojiBC/c0w28QoGhVaGYNfF8bWOZe0J0=;
	b=hmYbXGPhmUjtMThBiWN66fg3p2akpd1bjj3OoOiVFs9FqqACy6WhIHqVFhAJTkl1C9V1+q
	4nQmI7fdTVlE1EMLQLRBwvK+u5HOeSd+xpKRCs3tU7rsnpdEWJiPkZ77htZDfLDb0/QQZQ
	fcH0uzgkh6yNv79d9TeAp2ZjkITPx4Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170780;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SUNwtZYE0BZEojiBC/c0w28QoGhVaGYNfF8bWOZe0J0=;
	b=NxsPq1pRW+nFN8R1t1REtUrjBb1pfxdB/lVWZH7awRQ22iz9nXcNbdcQkRu+rVA5x1pYaz
	Zl45bp/pNmdh+iDA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 9D1FC13682;
	Mon, 31 Aug 2026 10:06:20 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id Li5UJhxSlWoodwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 10:06:20 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 2C9C8A13B5; Mon, 31 Aug 2026 12:06:20 +0200 (CEST)
Date: Mon, 31 Aug 2026 12:06:20 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 8/9] filemap: Remove redundant FGP_NOFS
Message-ID: <d3w3bedhmbl7d2ssfq2ov43safj7hynj7rpwztdiu22fkasrhm@e4qjbeohazgv>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-9-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-9-willy@infradead.org>
X-Spam-Score: -2.51
X-Rspamd-Queue-Id: BFE4A22347
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-2.51 / 50.00];
	BAYES_HAM(-3.00)[99.99%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_TWELVE(0.00)[18];
	ARC_NA(0.00)[];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns,infradead.org:email]
X-Spam-Flag: NO

On Sun 30-08-26 05:18:55, Matthew Wilcox (Oracle) wrote:
> The flags already include FGP_NOWAIT which prohibits all reclaim, not
> just reclaiming from the filesystem.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/pagemap.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 0adfa6605653..3974b063a049 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -929,7 +929,7 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>  				pgoff_t index)
>  {
>  	return pagecache_get_page(mapping, index,
> -			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
> +			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
>  			mapping_gfp_mask(mapping));
>  }
>  
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
