Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834796;
	b=B2SEvvQaQ0WvYCNESMxjPUY4e9bUdaOayWvvCWjfGga7SarfjhhY+rXvZyEI72Ujlfpd
	 GHXntusWtWXIoL10qqgB8yp+if25MQaUpJBiHFD5lg36pEygccge5Aq4n7wnHtFI/Ytgu
	 c/4ZnZeWJld/beAmBGRoJfkszPfaBFefLGGa0igbx7yW0ukIqqGouT4/Deo9fnKSlNQsa
	 sl76/XKpe3rdPAlk1Rz/U/0jb7oT9LdzIu+G7CM+ykJfDHxUS1v2T3p0/6APK3nv3692O
	 7xy+5j++gT/1zMtvxhuJdMdjTtAgbdoq5Waxy+FJa8wXOd/5Qnn8S4NEZTPJ0+vo9Fw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834796;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=3rOHcYKDuCkzllIwgWTNHupYKEaBKVPW8ZfJ4jsjsnY=;
	b=CELev9SpfDQTjjzyfl1GkwPn4LMqKlhJEbn+1nxOgtJ25HQW02Ynj61yy5xd4FaIrRAJ
	 k7TGSyTJRoRIww+dEbjZGThDNRBe8M1HD1UiC4HBvI6CjZ2ThsoFPv4LvOJBjeif0lCPT
	 nU1ELcMDLj3dQz6JljWa+YYGcZUDo7R9tro74+kGZsd3TWFjJrrSDXvCENsJr1z7JNA5b
	 Usj+diMZ+5cdSmDcwhdRV9VX+ZS73MfD6AZmd7G4xOoD+bQtUNfskPpCrAZ7V4Ei8RE53
	 vclIpU8gacpYuxM8CxwOKInglOK8LsQw3GtOSpSMLj4WUKDIJ8QpcCLSeY4uePcgDFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="cKZF/ZyB";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=CYpRWt71;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=jCp55ag1;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=p54j3YyA;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3AD2606A329;
	Mon, 16 Nov 2026 13:13:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F3AD2606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=cKZF/ZyB;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=CYpRWt71;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=jCp55ag1;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=p54j3YyA
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 2B59E2227B;
	Mon, 16 Nov 2026 13:13:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834794; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3rOHcYKDuCkzllIwgWTNHupYKEaBKVPW8ZfJ4jsjsnY=;
	b=cKZF/ZyBbJtt7UFcHcCTjKShsPHrX21DEM8i2T8cE7M9ckwnLGFyl/u1dkQaVjeua6ROhJ
	gPFn1bf1D0isbPidzsAbzb4OWFlkRHG0th0aC9Qq16NPeqaAG0uJ/5i61Q5+UCysFfUHxN
	N06r9wT0lmc5RC/YR/931fHQUPj+vg8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834794;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3rOHcYKDuCkzllIwgWTNHupYKEaBKVPW8ZfJ4jsjsnY=;
	b=CYpRWt71Adz8aH4s7dnF8T3DMbwBS0U+6ypL3ScgJtcDPKhzCMVRBaqqBWpqvGnPs8qMMP
	LmzJ1qVSl9GwwSBw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=jCp55ag1;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=p54j3YyA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834793; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3rOHcYKDuCkzllIwgWTNHupYKEaBKVPW8ZfJ4jsjsnY=;
	b=jCp55ag1gZEGkX0JhYiXQzBajJbaPcJ2vqPElOKhfkyuQrRHDlb/o45ccZYcv0FcZDjOY9
	A532D2V+mUonBzk51vLsWu954m5PnQPs7HeIDzworG1DtqqlvixEVZ4fbnKDUuqlxpbnSN
	WLLRpjQ53YKrOOji8XWfa7/hhgYYZBk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834793;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3rOHcYKDuCkzllIwgWTNHupYKEaBKVPW8ZfJ4jsjsnY=;
	b=p54j3YyAIKs0HICegHM6DyMWk53ACB8JQsl7rKblCRzO4I9+kntb80qU2poX5vzyeQrK7y
	sg45YSSK8oBEmGBw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0CCB01334C;
	Mon, 16 Nov 2026 13:13:13 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id JrOpOGgB+2ruFwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:13:13 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id B103224E0A; Mon, 16 Nov 2026 14:13:12 +0100 (CET)
Date: Mon, 16 Nov 2026 14:13:12 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2 02/17] fs: add kiocb_write_iter() and
 kiocb_end_write_iter()
Message-ID: <pypknyxrb7k5faks3ygujfalm55c2diua5jqfvryawnhsi5iry@fahmwbeatcur>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
 <20261116-work-fs-frozen_writes-v2-2-ecc4a2aac40e@kernel.org>
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
In-Reply-To: <20261116-work-fs-frozen_writes-v2-2-ecc4a2aac40e@kernel.org>
X-Rspamd-Queue-Id: 2B59E2227B
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
	MIME_TRACE(0.00)[0:+];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[17];
	DBL_BLOCKED_OPENRESOLVER(0.00)[lst.de:email,suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	DKIM_TRACE(0.00)[suse.cz:+]
X-Spam-Score: -13.01

On Mon 16-11-26 12:03:42, Christian Brauner wrote:
> Calling ->write_iter() with a kiocb of your own means taking freeze
> protection, calling ->write_iter() and dropping freeze protection again
> unless the write was queued. The completion callback then has to know
> whether it completes a write that still holds freeze protection. loop
> open-codes this and keys the completion on the request op. zloop, the
> nvme target and target fileio need the same. Christoph pointed out that
> open-coding this everywhere is fragile (cf. [1]).
> 
> Add kiocb_write_iter(). It takes freeze protection, marks the kiocb
> with IOCB_WRITE like aio, io_uring and cachefiles do and calls
> ->write_iter(). If the write wasn't queued freeze protection is dropped
> right away. With IOCB_NOWAIT it only tries to get freeze protection and
> fails with -EAGAIN instead of waiting for the thaw.
> 
> kiocb_end_write_iter() drops freeze protection if the kiocb still holds
> it and clears IOCB_WRITE. So a completion callback can call it for any
> I/O. That matters for drivers that complete I/O that wasn't queued
> through the same callback and for drivers that reuse their kiocbs.
> 
> [1]: https://lore.kernel.org/r/20261116064654.GA2964@lst.de
> 
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 48 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index eefc2c9d4af19..0b66a09fb686a 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2840,6 +2840,54 @@ static inline void kiocb_end_write(struct kiocb *iocb)
>  	sb_end_write(inode->i_sb);
>  }
>  
> +/**
> + * kiocb_end_write_iter - drop write access after kiocb_write_iter()
> + * @iocb: the io context the write was submitted with
> + *
> + * Drop write access if @iocb still holds it and clear IOCB_WRITE. This
> + * does nothing for reads and for writes kiocb_write_iter() already
> + * finished. So the completion callback can call it for any I/O.
> + */
> +static inline void kiocb_end_write_iter(struct kiocb *iocb)
> +{
> +	if (!(iocb->ki_flags & IOCB_WRITE))
> +		return;
> +	iocb->ki_flags &= ~IOCB_WRITE;
> +	kiocb_end_write(iocb);
> +}
> +
> +/**
> + * kiocb_write_iter - submit a write with write access to the superblock
> + * @iocb: the io context to submit the write with
> + * @iter: the data to write
> + *
> + * Get write access, mark @iocb with IOCB_WRITE and call ->write_iter().
> + * A write that wasn't queued drops write access before this returns. A
> + * queued write keeps it until the completion callback calls
> + * kiocb_end_write_iter(). With IOCB_NOWAIT this fails with -EAGAIN
> + * instead of waiting for a frozen filesystem.
> + *
> + * Return: On success the number of bytes written or -EIOCBQUEUED is
> + *         returned. On failure a negative error code is returned.
> + */
> +static inline ssize_t kiocb_write_iter(struct kiocb *iocb,
> +				       struct iov_iter *iter)
> +{
> +	ssize_t ret;
> +
> +	if (iocb->ki_flags & IOCB_NOWAIT) {
> +		if (!kiocb_start_write_trylock(iocb))
> +			return -EAGAIN;
> +	} else {
> +		kiocb_start_write(iocb);
> +	}
> +	iocb->ki_flags |= IOCB_WRITE;
> +	ret = iocb->ki_filp->f_op->write_iter(iocb, iter);
> +	if (ret != -EIOCBQUEUED)
> +		kiocb_end_write_iter(iocb);
> +	return ret;
> +}
> +
>  /*
>   * This is used for regular files where some users -- especially the
>   * currently executed binary in a process, previously handled via
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
