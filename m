Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794826114;
	b=KXnqFUvAHsX25z2PsVAouwyWzQwlmgHBjzl1cBDOt0jDBwqZXKJ7wpkBQm1EZh5Sh9A7
	 nvgEowe6O92StKBXUwOb77tvfDWAhfP1yKHoJeZMCAXmH0gOBFjs2eJmfhJlFBrQO1Wsl
	 besLMrCJExCFbOztoYEwqGsAoPXXYLjau0Auh2A4g+faxP0XJiSzbwtZs0TrjXYCJlvyO
	 rgG8nDMs9GtCqyfgxhZoaD28X25q5WXN5O3yjJGwzd2AVhXYIbybOoWDzZJQgXefERDsX
	 vXCQkyOXXHyBGpZmtq3WSpGTivTmuMS1xbl7mpezT0ZjxnIEgfCCn5d1AGX7hD5oyJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794826114;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=WdV7LfPZ4msOsP2SDeAiTLmjSH9L5rSuovDgUpDr7/o=;
	b=Gc+KfSyj8nt3IdhzvPW+dVOZOz3ix/0Fo0q5nP/Ttl2L51g/pUoUNLUUhQn7OGIekRym
	 ov6LlMFKk9s+tvJePKbMIKqnbpj4olw0F2iCTkoGcE1SGRGxgzM8ChdUh26z8UoqYwGP5
	 7Gvtsb6qq5aINJwP4EjE2Os/uwslyA9qKRwlU2ZfXfC5NKquliSKp3da+Ck2EtsjEZIpV
	 9FnvJJdFYV3cOaJTY2QObzr2qw+N2Xy6Pzp0owRA1WIaY/coXqnOXC45DNe2nFlu8TAtM
	 AAtVQM5DBQTHtv7Q7Qr1tJz4uAuajwGog8J8REIvwiSr8o1xYV+FsZOvg3/hDAeiTFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JAx15jQz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6yuKD6uR;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JAx15jQz;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6yuKD6uR;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D689A606A31C;
	Mon, 16 Nov 2026 10:48:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D689A606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JAx15jQz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6yuKD6uR;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JAx15jQz;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6yuKD6uR
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 4030822290;
	Mon, 16 Nov 2026 10:48:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826112; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WdV7LfPZ4msOsP2SDeAiTLmjSH9L5rSuovDgUpDr7/o=;
	b=JAx15jQzTftUEsIrFEpxbzwWMXmveAo8iHij/8uzgxS3WDfPaepPH8Vik/C1LrWoQEph/+
	iZsdaCrGUdMc6Rpgdo7n5W7StPbBOdfDrcKVBoWc63lMEBDp26q9AuXaO9JZ4VrDMYurnI
	Gnqv9JORJnHmfzlQccTlxqpQkU9lUr8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826112;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WdV7LfPZ4msOsP2SDeAiTLmjSH9L5rSuovDgUpDr7/o=;
	b=6yuKD6uR7WQGQOIBvWjEYpVyQsgPsprYCksV1USMJ2Wrhf53d7sHLjz0lYIP7VomQjEarb
	1tiIDVnYmORGbaCQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826112; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WdV7LfPZ4msOsP2SDeAiTLmjSH9L5rSuovDgUpDr7/o=;
	b=JAx15jQzTftUEsIrFEpxbzwWMXmveAo8iHij/8uzgxS3WDfPaepPH8Vik/C1LrWoQEph/+
	iZsdaCrGUdMc6Rpgdo7n5W7StPbBOdfDrcKVBoWc63lMEBDp26q9AuXaO9JZ4VrDMYurnI
	Gnqv9JORJnHmfzlQccTlxqpQkU9lUr8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826112;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WdV7LfPZ4msOsP2SDeAiTLmjSH9L5rSuovDgUpDr7/o=;
	b=6yuKD6uR7WQGQOIBvWjEYpVyQsgPsprYCksV1USMJ2Wrhf53d7sHLjz0lYIP7VomQjEarb
	1tiIDVnYmORGbaCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 13A2D1334C;
	Mon, 16 Nov 2026 10:48:32 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id ryFUOH/f+moMewAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 10:48:32 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id B066624DA6; Mon, 16 Nov 2026 11:48:31 +0100 (CET)
Date: Mon, 16 Nov 2026 11:48:31 +0100
From: Jan Kara <jack@suse.cz>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	linux-mm@kvack.org, Christian Brauner <brauner@kernel.org>, 
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v12 3/7] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs
 stats
Message-ID: <6npuytxjyfa75iypcnwvu4ayu3puysipkqjyrtssng4cieibue@sdkb62hjosuq>
References: <20261112190911.84702-1-snitzer@kernel.org>
 <20261112190911.84702-4-snitzer@kernel.org>
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
In-Reply-To: <20261112190911.84702-4-snitzer@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_HAS_DN(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:email];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCPT_COUNT_SEVEN(0.00)[9];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -12.80

On Thu 12-11-26 14:09:06, Mike Snitzer wrote:
> The per-bdi_writeback WB_DONTCACHE_DIRTY counter drives how much the
> flusher writes back in response to an IOCB_DONTCACHE kick, but it is
> not reported anywhere, so the DONTCACHE dirty backlog can only be
> inferred from MemFree/Cached movement.
> 
> Report it as BdiDontcacheDirty in /sys/kernel/debug/bdi/<dev>/stats
> and as WbDontcacheDirty in the per-wb stats, next to the
> Reclaimable line.  Use wb_stat_sum() rather than wb_stat() to fold in
> the per-cpu batches: the flusher targets the summed value and small
> backlogs would otherwise read as zero.
> 
> Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/backing-dev.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index fad1495d3b200..a09c21759fb9f 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -46,6 +46,7 @@ struct wb_stats {
>  	unsigned long nr_dirty_time;
>  	unsigned long nr_writeback;
>  	unsigned long nr_reclaimable;
> +	unsigned long nr_dontcache_dirty;
>  	unsigned long nr_dirtied;
>  	unsigned long nr_written;
>  	unsigned long dirty_thresh;
> @@ -78,6 +79,7 @@ static void collect_wb_stats(struct wb_stats *stats,
>  
>  	stats->nr_writeback += wb_stat(wb, WB_WRITEBACK);
>  	stats->nr_reclaimable += wb_stat(wb, WB_RECLAIMABLE);
> +	stats->nr_dontcache_dirty += wb_stat_sum(wb, WB_DONTCACHE_DIRTY);
>  	stats->nr_dirtied += wb_stat(wb, WB_DIRTIED);
>  	stats->nr_written += wb_stat(wb, WB_WRITTEN);
>  	stats->wb_thresh += wb_calc_thresh(wb, stats->dirty_thresh);
> @@ -125,6 +127,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  	seq_printf(m,
>  		   "BdiWriteback:       %10lu kB\n"
>  		   "BdiReclaimable:     %10lu kB\n"
> +		   "BdiDontcacheDirty:  %10lu kB\n"
>  		   "BdiDirtyThresh:     %10lu kB\n"
>  		   "DirtyThresh:        %10lu kB\n"
>  		   "BackgroundThresh:   %10lu kB\n"
> @@ -139,6 +142,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  		   "state:              %10lx\n",
>  		   K(stats.nr_writeback),
>  		   K(stats.nr_reclaimable),
> +		   K(stats.nr_dontcache_dirty),
>  		   K(stats.wb_thresh),
>  		   K(dirty_thresh),
>  		   K(background_thresh),
> @@ -163,6 +167,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
>  		   "WbCgIno:           %10lu\n"
>  		   "WbWriteback:       %10lu kB\n"
>  		   "WbReclaimable:     %10lu kB\n"
> +		   "WbDontcacheDirty:  %10lu kB\n"
>  		   "WbDirtyThresh:     %10lu kB\n"
>  		   "WbDirtied:         %10lu kB\n"
>  		   "WbWritten:         %10lu kB\n"
> @@ -179,6 +184,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
>  #endif
>  		   K(stats->nr_writeback),
>  		   K(stats->nr_reclaimable),
> +		   K(stats->nr_dontcache_dirty),
>  		   K(stats->wb_thresh),
>  		   K(stats->nr_dirtied),
>  		   K(stats->nr_written),
> -- 
> 2.52.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
