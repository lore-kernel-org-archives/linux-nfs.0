Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 397E33ECBFE
	for <linux-nfs@vger.kernel.org>; Mon, 25 May 2026 16:19:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779725987; cv=none; b=VyeaqZ6O7HlNEMjp4TSaO+yt8Y7YpLqf6sDCTZe1ZuUPpEDrGMi++7YQcZmxNYScOi2300W3zI3VhxW86lndKreEAZGNUQ2al+bp/srYCwo6/jfW2GCi00qasY898QFxfsPsNAmCwgN4S8M5KeuO2gTBHe+xLvP8Ano60G5H7hc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779725987; c=relaxed/simple;
	bh=MeKHTFUo0nA5wXIT4zoU97SmA7lKMl7f4DD1WyQfG+k=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=o/unmAvXOOSVVX1J0HG1xKP7bq1UBxVJMu0U/sDPZfWG3WCcOYfbjye/VUFefMoFlfcS3D9Xjd/427rMhSton6HAJj39iA0dIdlHYOwdP3hAJfhu99g3hn001b9LVIIaH4J85kcR2lmskMnGzjNiqKzopoJmWy6tYR7FYIX2Oqk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=Vao39Koc; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=X+iqXEgu; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=Vao39Koc; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=X+iqXEgu; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="Vao39Koc";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="X+iqXEgu";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="Vao39Koc";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="X+iqXEgu"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 8363D67D6A;
	Mon, 25 May 2026 16:19:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1779725984; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=q0bzF8+BTIPG9AapbSXflhyEvFRKzijZ8O5Qxt+U1yc=;
	b=Vao39Koc19S3W9vSa6fHGtrHU/f1z+4hFz3tzWjes36lSH4XTdS7NPuFi6KnTjjKDR6Iuj
	xN+dp4CaS6hVf8pzDt9r7/Mc2xY3Qy1hjw7vPIfVv2GNNhvDLOQeYktnfp7551tq5SWTDq
	0iDqw3Zql16Ez+5T4jz8WSBOr1eYarE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1779725984;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=q0bzF8+BTIPG9AapbSXflhyEvFRKzijZ8O5Qxt+U1yc=;
	b=X+iqXEgu/pq8XEDQKnLjwQ093zBBjPeH5v3oL08rHlxIn4hAPKgllEeo8opirLG+WJB0Ed
	LrK2oQ7z7ltNADBA==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=Vao39Koc;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=X+iqXEgu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1779725984; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=q0bzF8+BTIPG9AapbSXflhyEvFRKzijZ8O5Qxt+U1yc=;
	b=Vao39Koc19S3W9vSa6fHGtrHU/f1z+4hFz3tzWjes36lSH4XTdS7NPuFi6KnTjjKDR6Iuj
	xN+dp4CaS6hVf8pzDt9r7/Mc2xY3Qy1hjw7vPIfVv2GNNhvDLOQeYktnfp7551tq5SWTDq
	0iDqw3Zql16Ez+5T4jz8WSBOr1eYarE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1779725984;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=q0bzF8+BTIPG9AapbSXflhyEvFRKzijZ8O5Qxt+U1yc=;
	b=X+iqXEgu/pq8XEDQKnLjwQ093zBBjPeH5v3oL08rHlxIn4hAPKgllEeo8opirLG+WJB0Ed
	LrK2oQ7z7ltNADBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 70FD159D27;
	Mon, 25 May 2026 16:19:44 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id MSSuGqB2FGpuIQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 25 May 2026 16:19:44 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 13460A08D7; Mon, 25 May 2026 18:19:44 +0200 (CEST)
Date: Mon, 25 May 2026 18:19:44 +0200
From: Jan Kara <jack@suse.cz>
To: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Cc: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>, 
	Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, 
	Ryusuke Konishi <konishi.ryusuke@gmail.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>, 
	Miklos Szeredi <miklos@szeredi.hu>, Andreas Hindborg <a.hindborg@kernel.org>, 
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>, 
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	jfs-discussion@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 13/17] fs/select: replace __get_free_page() with kmalloc()
Message-ID: <flztdmhjmz5zp4podujx7ekdxa7qbx4pp2iz37ji2tltyyhzn3@jsikvofbhtbu>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-13-275e36a83f0e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260523-b4-fs-v1-13-275e36a83f0e@kernel.org>
X-Spam-Score: -2.51
X-Spam-Level: 
X-Rspamd-Queue-Id: 8363D67D6A
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-2.51 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	ARC_NA(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_TWELVE(0.00)[33];
	MIME_TRACE(0.00)[0:+];
	RCVD_TLS_LAST(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	internal_greylist_whitelist(0.00)[2a07:de40:b281:104:10:150:64:97];
	TAGGED_RCPT(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RLpnapcpkwxdkc5mopt1ezhhna)];
	MISSING_XM_UA(0.00)[];
	FREEMAIL_CC(0.00)[suse.com,fasheh.com,evilplan.org,linux.alibaba.com,gmail.com,dubeyko.com,kernel.org,oracle.com,brown.name,redhat.com,talpey.com,zeniv.linux.org.uk,suse.cz,mit.edu,szeredi.hu,debian.org,vger.kernel.org,lists.linux.dev,lists.sourceforge.net,kvack.org];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,suse.cz:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Flag: NO

On Sat 23-05-26 20:54:25, Mike Rapoport (Microsoft) wrote:
> poll_get_entry() allocates new memory for poll_table entries using
> __get_free_page().
> 
> kmalloc() is a better API for such use and it also provides better
> scalability and more debugging possibilities.
> 
> Replace use of __get_free_page() with kmalloc().
> 
> Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/select.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/select.c b/fs/select.c
> index 75978b18f48f..6fa63e48cdee 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -150,7 +150,7 @@ void poll_freewait(struct poll_wqueues *pwq)
>  		} while (entry > p->entries);
>  		old = p;
>  		p = p->next;
> -		free_page((unsigned long) old);
> +		kfree(old);
>  	}
>  }
>  EXPORT_SYMBOL(poll_freewait);
> @@ -165,7 +165,7 @@ static struct poll_table_entry *poll_get_entry(struct poll_wqueues *p)
>  	if (!table || POLL_TABLE_FULL(table)) {
>  		struct poll_table_page *new_table;
>  
> -		new_table = (struct poll_table_page *) __get_free_page(GFP_KERNEL);
> +		new_table = kmalloc(PAGE_SIZE, GFP_KERNEL);
>  		if (!new_table) {
>  			p->error = -ENOMEM;
>  			return NULL;
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
