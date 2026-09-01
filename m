Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16E33248880;
	Tue,  1 Sep 2026 14:27:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788272876; cv=none; b=r1vwrTjOwBhxmEQPbI6YWwjxhp6gbTBnj30alxI0vAmkQCWIVaBqbe9lAxkA24WEEr6cPnk9IQbwDW8iQyeIgw15zlW1KRvJe7eS2OlSM6cPhrmJ2gthDZzwp4tWapEmv9vNTrYmKmQWMNC7CKFP3sOtJwXCgynFf1XNAeVITLE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788272876; c=relaxed/simple;
	bh=3Pi2wWfe/B8XATiTV+wQhps3hbtFcclQ395AN4b4qhA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=eTBTI1MOUm3QNSWETmVOgEi9voT6hEsuRLOs4pQhmLa304z+79Se15ePT7Gn8N/UPv/n/E3ooAzCZnUkuRi6TQ5oNCXAdm20OaKFGBwQJP245ljXCP9Jl9M024j/1WC9C7vRBxVzm0RQX1s5nzp6ZWZexXx2m+7V0MoCK0xj2c0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=UbwZqe8M; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=enZJ5C/L; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=LsA8xA1p; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=0wkh7VHm; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="UbwZqe8M";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="enZJ5C/L";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="LsA8xA1p";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="0wkh7VHm"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id AF6A61F397;
	Tue,  1 Sep 2026 14:27:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788272868; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=KPK49wVZdID7g9/Zu62nmPqeg16U/FWpi177Sp1FYrI=;
	b=UbwZqe8MQxl8+WVG+cpWWpvqA1IilkP/aK+NohF0wOsHXLqtV1LtM06kTZkS5NI3nz03qx
	s+GkeHvIhe3RYznTkFXu8RI2i7yFUOcnqF1Tc9zPuTJIuqXG38AkUxNhLIQrIZvTKaIlPn
	4Iu24V8a5UYy8T71PdKoZr36EXLJx4k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788272868;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=KPK49wVZdID7g9/Zu62nmPqeg16U/FWpi177Sp1FYrI=;
	b=enZJ5C/LtQrS2x7LiUMPAaEa7LglF2BOKxPyzuhjQygF2lQh6CARXSVgID1gEszSCkGIuI
	lnLobIYMSDpzm2BQ==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=LsA8xA1p;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=0wkh7VHm
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788272864; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=KPK49wVZdID7g9/Zu62nmPqeg16U/FWpi177Sp1FYrI=;
	b=LsA8xA1p2HbQ02wSWqdklX6eO0MmZMBOakWDeWhNVu7I1/YuRzMLQaKBTdCLI4s5YhJ5VY
	ipHTAoIhxakLKC2aUOwJI0mdvmWX+lR9Sacdm+eouSSDMsAPoV6jeNNx9T8TcB5QHjXjl7
	IbeXMnWSwxIIVjFkjxBppZamkWohweA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788272864;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=KPK49wVZdID7g9/Zu62nmPqeg16U/FWpi177Sp1FYrI=;
	b=0wkh7VHmTJ9YLZHWCGHwsGLmpx1vSOPRNuEhZEQ1kU7+RO0T4V3Gdl7WBQ9REDA337jqRc
	kJYUPdYV2XIXkPCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 85F5F1369E;
	Tue,  1 Sep 2026 14:27:44 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 92OuIODglmrQcQAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 01 Sep 2026 14:27:44 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 1668FA13B2; Tue, 01 Sep 2026 16:27:40 +0200 (CEST)
Date: Tue, 1 Sep 2026 16:27:40 +0200
From: Jan Kara <jack@suse.cz>
To: Chuck Lever <cel@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org, Ameer Hamza <ameer.hamza@truenas.com>, 
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v2] splice: emit a single fsnotify access event per NFSD
 READ
Message-ID: <wvcczks7hv3ks7xfavizwszge3ncy36ceupk42owzjvpjnie2t@uo4rphyxlwry>
References: <20260901135329.487666-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260901135329.487666-1-cel@kernel.org>
X-Spam-Score: -4.01
X-Rspamd-Queue-Id: AF6A61F397
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	MIME_TRACE(0.00)[0:+];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	ARC_NA(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	FREEMAIL_CC(0.00)[zeniv.linux.org.uk,kernel.org,suse.cz,vger.kernel.org,truenas.com,gmail.com];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from,2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_SEVEN(0.00)[8];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[truenas.com:email,suse.cz:dkim,suse.cz:email,suse.com:email,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns]
X-Spam-Flag: NO

On Tue 01-09-26 09:53:29, Chuck Lever wrote:
> nfsd_finish_read() calls fsnotify_access() on both NFSD read paths,
> because splice_direct_to_actor() does not emit the event itself. The
> iterator path reaches nfsd_finish_read() from vfs_iocb_iter_read(),
> which has already emitted one. A READ served without splice therefore
> emits two access events.
> 
> NFSD does not use splice for the GSS integrity and privacy services, so
> a READ on a sec=krb5i or sec=krb5p mount takes the iterator. An inotify
> watch on that file sees the READ twice.
> 
> Reported-by: Ameer Hamza <ameer.hamza@truenas.com>
> Closes: https://lore.kernel.org/linux-nfs/20260818225715.572140-1-ameer.hamza@truenas.com/
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> Link: https://lore.kernel.org/linux-nfs/CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com/
> Signed-off-by: Chuck Lever <cel@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
> Changes in v2:
> - Rename the new helper to vfs_splice_to_actor()
> - Take pos, count, and actor data, not a splice_desc
> - Link to v1: https://lore.kernel.org/r/20260824161021.245575-1-cel@kernel.org
> ---
>  fs/nfsd/vfs.c          | 13 ++--------
>  fs/splice.c            | 58 +++++++++++++++++++++++++++++++-----------
>  include/linux/splice.h |  4 +--
>  3 files changed, 47 insertions(+), 28 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f9131827d391..4789f2ec2078 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1046,7 +1046,6 @@ static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		nfsd_stats_io_read_add(nn, fhp->fh_export, host_err);
>  		*eof = nfsd_eof_on_read(file, offset, host_err, *count);
>  		*count = host_err;
> -		fsnotify_access(file);
>  		trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
>  		return 0;
>  	} else {
> @@ -1071,19 +1070,11 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  			struct file *file, loff_t offset, unsigned long *count,
>  			u32 *eof)
>  {
> -	struct splice_desc sd = {
> -		.len		= 0,
> -		.total_len	= *count,
> -		.pos		= offset,
> -		.u.data		= rqstp,
> -	};
>  	ssize_t host_err;
>  
>  	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
> -	host_err = rw_verify_area(READ, file, &offset, *count);
> -	if (!host_err)
> -		host_err = splice_direct_to_actor(file, &sd,
> -						  nfsd_direct_splice_actor);
> +	host_err = vfs_splice_to_actor(file, offset, *count,
> +				       nfsd_direct_splice_actor, rqstp);
>  	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
>  }
>  
> diff --git a/fs/splice.c b/fs/splice.c
> index 9d8f63e2fd1a..96cff31d97e1 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1009,21 +1009,14 @@ ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
>  }
>  EXPORT_SYMBOL_GPL(vfs_splice_read);
>  
> -/**
> - * splice_direct_to_actor - splices data directly between two non-pipes
> - * @in:		file to splice from
> - * @sd:		actor information on where to splice to
> - * @actor:	handles the data splicing
> - *
> - * Description:
> - *    This is a special case helper to splice directly between two
> - *    points, without requiring an explicit pipe. Internally an allocated
> - *    pipe is cached in the process, and reused during the lifetime of
> - *    that process.
> - *
> +/*
> + * This is a special case helper to splice directly between two
> + * points, without requiring an explicit pipe. Internally an allocated
> + * pipe is cached in the process, and reused during the lifetime of
> + * that process.
>   */
> -ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
> -			       splice_direct_actor *actor)
> +static ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
> +				      splice_direct_actor *actor)
>  {
>  	struct pipe_inode_info *pipe;
>  	ssize_t ret, bytes;
> @@ -1147,7 +1140,42 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
>  
>  	goto done;
>  }
> -EXPORT_SYMBOL(splice_direct_to_actor);
> +
> +/**
> + * vfs_splice_to_actor - call an actor on data read from a file
> + * @in:		file to read from
> + * @pos:	file offset
> + * @count:	maximum number of bytes to read
> + * @actor:	callback to process a pipe's worth of data
> + * @private:	private data passed to @actor
> + *
> + * Read up to @count worth of data from @in at @pos, and call @actor
> + * when the hidden pipe used to buffer the data is full. Ensures the
> + * read is allowed using rw_verify_area() and emits fsnotify access
> + * events. @in must be seekable (FMODE_LSEEK).
> + *
> + * Return: The number of bytes spliced, or a negative errno.
> + */
> +ssize_t vfs_splice_to_actor(struct file *in, loff_t pos, size_t count,
> +			    splice_direct_actor *actor, void *private)
> +{
> +	struct splice_desc sd = {
> +		.total_len	= count,
> +		.pos		= pos,
> +		.u.data		= private,
> +	};
> +	ssize_t ret;
> +
> +	ret = rw_verify_area(READ, in, &sd.pos, sd.total_len);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = splice_direct_to_actor(in, &sd, actor);
> +	if (ret >= 0)
> +		fsnotify_access(in);
> +	return ret;
> +}
> +EXPORT_SYMBOL(vfs_splice_to_actor);
>  
>  static int direct_splice_actor(struct pipe_inode_info *pipe,
>  			       struct splice_desc *sd)
> diff --git a/include/linux/splice.h b/include/linux/splice.h
> index 9dec4861d09f..0e6c955dc6ff 100644
> --- a/include/linux/splice.h
> +++ b/include/linux/splice.h
> @@ -79,8 +79,8 @@ ssize_t add_to_pipe(struct pipe_inode_info *pipe, struct pipe_buffer *buf);
>  ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
>  			struct pipe_inode_info *pipe, size_t len,
>  			unsigned int flags);
> -ssize_t splice_direct_to_actor(struct file *file, struct splice_desc *sd,
> -			       splice_direct_actor *actor);
> +ssize_t vfs_splice_to_actor(struct file *file, loff_t pos, size_t count,
> +			    splice_direct_actor *actor, void *private);
>  ssize_t do_splice(struct file *in, loff_t *off_in, struct file *out,
>  		  loff_t *off_out, size_t len, unsigned int flags);
>  ssize_t do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
> -- 
> 2.55.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
