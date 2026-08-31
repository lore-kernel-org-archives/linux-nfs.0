Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE4FF3CBE6D;
	Mon, 31 Aug 2026 10:08:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788170920; cv=none; b=R7K+aqqnFkj7dr5qiveIJhYOHC61+DxSpLE6vzjvlLGcfSNEMEJTz6o+z6hQpDSQAlplZXCyIjT3tqSinXe9DBxzonz1qRtkXK7nAHpPmVrI9KUO9QO4kiCFHRXhJ/gJbCZ7tvbDk1twx8awZsl8yFTpF2rsXDgGerK/lzicjcU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788170920; c=relaxed/simple;
	bh=zIBA2wVyu5PVLfEr3rdlXXKP/OFIRB1MwGRzMAKjpf0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MUwIbdFUTNJYdXrr5EBfNcGXvf1J/+uTRLspXK4e2QeNDoQsWsDFronUzBSbuqaofADsTPqFPimpRFbu4xw/i+aecSHdE/kKQVcJ/OGImyLU5SkhyhjCShL05p/GocrA5mac8eeJMHMtm7LYf9IjZP8ZkJq1R+JPD3nSAO6/KJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=wvCAPAaO; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=MuNFlc0w; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=Uzb2LIye; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=2QEJLTbQ; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="wvCAPAaO";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="MuNFlc0w";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="Uzb2LIye";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="2QEJLTbQ"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id B04771FAAB;
	Mon, 31 Aug 2026 10:08:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170912; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lA5FCsiRqGndfeMhZtC7v36Drbd7FKDYcliDfcaFBCA=;
	b=wvCAPAaOBjCH6h5DpcGNw20wGJraW6tqmFfCZRE4f0gB9Uldet5NHUI4/7ss0YhFfzjiUi
	Ib3XtHq+lR7ra/rHE57SPzW9JwUbR3boz3K17aubjxatwviLB59gnaatZNB2lS4P54uFl5
	sdLceqjzcCPyhFSxqs0pTeLheSXwxsk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170912;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lA5FCsiRqGndfeMhZtC7v36Drbd7FKDYcliDfcaFBCA=;
	b=MuNFlc0wuVFNREQjM3uDInI1xqoKYuSIku37TCzfZRKnr3m8sObEzSqGZ/FZWxana9tuBh
	plS0E1jvKoMxVDCw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788170908; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lA5FCsiRqGndfeMhZtC7v36Drbd7FKDYcliDfcaFBCA=;
	b=Uzb2LIyeuI2zzZ6PPJCUe3sYzl8wN3xZ45UCQ0bozlLNXU5s9kHegZuYzn+z08Z+iteFb6
	IAyEIvGBGy2dUmap0bFSJPtayw6duO9d0Gh93m8pb5tHjQAEKcvTPK+p8Ey+6liQIPjile
	ketJuKT0EYc9GbdtiBJWDiD3bqZdpJE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788170908;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lA5FCsiRqGndfeMhZtC7v36Drbd7FKDYcliDfcaFBCA=;
	b=2QEJLTbQMarN1cka2KHebxL2wHEsQtXf2BBQREtgNuzIvrRzInPCHYKgZM+PjsOG4QBFeH
	9hQozRRssdd46YCw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8BC1213682;
	Mon, 31 Aug 2026 10:08:28 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id GhsbIpxSlWpOeQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 31 Aug 2026 10:08:28 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 34131A13B5; Mon, 31 Aug 2026 12:08:20 +0200 (CEST)
Date: Mon, 31 Aug 2026 12:08:20 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, 
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 3/9] erofs: Remove redundant FGP_NOFS
Message-ID: <7cb6z6bmqbk3dj7mwew3tiomxstzjigs5tel6qhbxmhej3rd3q@pajlpq7y25og>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-4-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-4-willy@infradead.org>
X-Spam-Score: -2.30
X-Spam-Level: 
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[99.99%];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,infradead.org:email,suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Flag: NO

On Sun 30-08-26 05:18:50, Matthew Wilcox (Oracle) wrote:
> The flags already include FGP_NOWAIT which prohibits all reclaim, not
> just reclaiming from the filesystem.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/erofs/internal.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/erofs/internal.h b/fs/erofs/internal.h
> index 65974e57aebf..84b3cdc8e88f 100644
> --- a/fs/erofs/internal.h
> +++ b/fs/erofs/internal.h
> @@ -327,7 +327,7 @@ static inline struct folio *erofs_grab_folio_nowait(struct address_space *as,
>  						    pgoff_t index)
>  {
>  	return __filemap_get_folio(as, index,
> -			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
> +			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
>  			readahead_gfp_mask(as) & ~__GFP_RECLAIM);
>  }
>  
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
