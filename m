Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834697;
	b=xrmJn0VAtzdNtYekqYbCu7Q5ieuUCX1/S0SMh3GL5T2sj03uoK2Ph2+uqaqhyoA/9plt
	 Z/xVdPfb8IYOfPw6qBVoC2aF9oe7xjbjJCthdB0tEQjITdPRI6aendmdHAlye+4gX64Ev
	 TrhtlEorAvIWasIpAH7N6aLhwHc1xi6ptdd4HJdRWk9RCzvSvF935H54FnjoBy+oLK1C2
	 5Q9wOZjC9LuRYBIGujnxt5fMoTYEwtCI+8jQC55g9lBSeWZydWFV3jHeYWaXrX6cTAYKa
	 dYFgyI+zNdMddstGwgkMouREULBckC25tvgxbfWjijJ3lLOGQ4RPlmzBppUtshw4wsg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834697;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=aPB7W49SWsBu17qqGr8ORha9SlgtVrvHW1dZhYH+JXU=;
	b=MjPCrdFNjQXG9p5FjIz36u2cbth3hAncGiudhHwMz014piMI5fzSOnZZiz0FCa8swrU1
	 E4Wp5ta9QnvgrFPVtiMiMbcqRO/qhfFmn9O2nIuN9c1xs5V4bCjxcRs2JEIkcjoM/Jty/
	 0vumuN9Y+p0/rSa8Rik8gaJCQJMpvHu84ftKShCcg9Yrapzk6sv0/rwySHRXKYwLQ3v3/
	 ZW9mhHmDc3OqkUFkAzUZTBkQgjyzzNUf2x+B0ib9R6Dqy3XZ9Tl9uwwnS6WefKrux3aEX
	 jIKZPq1OV8e8c8bboFey3/YavKuGvImfWLMl4B+oQQgfvnLG+CcXGSGc6KdF9N9ovOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=I8euH6Il;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=qwmTbebB;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=pSgqltap;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=BfFSlZfG;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13E40606A31C;
	Mon, 16 Nov 2026 13:11:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 13E40606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=I8euH6Il;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=qwmTbebB;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=pSgqltap;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=BfFSlZfG
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 1F84D1F7E2;
	Mon, 16 Nov 2026 13:11:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834695; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=aPB7W49SWsBu17qqGr8ORha9SlgtVrvHW1dZhYH+JXU=;
	b=I8euH6IlQMpNAUEBl1FpKwvTnQyWvu1d5+pITe3P72DU+tp+gRy3yicid9gtfdxU+lTbso
	Rrz3qgHiixhF9J8sjk7Kr6zIsO6GAfI+Kit/XpLmeD6+To5mA70BV+ae75eUL4PIOtGDas
	ID7BPgofKV5nJHkFndl5+q+9Dx4f4mg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834695;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=aPB7W49SWsBu17qqGr8ORha9SlgtVrvHW1dZhYH+JXU=;
	b=qwmTbebBt6+Ox2iRA4n3FoLPk+UPdfPnrf/tIxR6+SCZLGOy4hZrC4IuRMoNCFiEItFAZJ
	A2HXJbkHSifMqdAQ==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834694; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=aPB7W49SWsBu17qqGr8ORha9SlgtVrvHW1dZhYH+JXU=;
	b=pSgqltapJr03XTCLjGW//WA6uIDKKTGVD3CwoLmHAZISAvGZkIdxS1Xl7gNXhUqPhRDYbY
	e4aTeNazuxGRaY74LPU14CkzuSlRplbk6TElZmtmOEZ9MpDAKMCHU97HrSaGKjNVYHBctK
	+97v9dTWy3e7emRU/5RPEMzMl2O0quM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834694;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=aPB7W49SWsBu17qqGr8ORha9SlgtVrvHW1dZhYH+JXU=;
	b=BfFSlZfGF/FsSOuZel6GvoytLZpzlS/wgikjcS8HGyKwKUTr9Vci7wNDJUSW5lawF9m1by
	w3iqpct4CYOGmGDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E91841334C;
	Mon, 16 Nov 2026 13:11:33 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id cqV9MAUB+2rHFQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:11:33 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 7A8AA24E08; Mon, 16 Nov 2026 14:11:33 +0100 (CET)
Date: Mon, 16 Nov 2026 14:11:33 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2 01/17] fs: add kiocb_start_write_trylock()
Message-ID: <6dnk35xcsruinjvqrgi2tfl3i63rbfs7bs3qxodw2joumqu6vn@zewmqpvkbbwk>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
 <20261116-work-fs-frozen_writes-v2-1-ecc4a2aac40e@kernel.org>
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
In-Reply-To: <20261116-work-fs-frozen_writes-v2-1-ecc4a2aac40e@kernel.org>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[17];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Mon 16-11-26 12:03:41, Christian Brauner wrote:
> kiocb_start_write() waits until a frozen filesystem is thawed. A
> nonblocking submission can't use it. io_uring open-codes the trylock
> variant for its IOCB_NOWAIT writes.
> 
> Add kiocb_start_write_trylock() next to kiocb_start_write() and use it
> in io_uring. kiocb_write_iter() is going to need it as well.
> 
> No functional changes.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h | 22 ++++++++++++++++++++++
>  io_uring/rw.c      |  9 +--------
>  2 files changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 99caef43ff3c4..eefc2c9d4af19 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2801,6 +2801,28 @@ static inline void kiocb_start_write(struct kiocb *iocb)
>  	__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
>  }
>  
> +/**
> + * kiocb_start_write_trylock - try to get write access to a superblock for
> + *			       async file io
> + * @iocb: the io context we want to submit the write with
> + *
> + * This is kiocb_start_write() for a submission that must not wait until a
> + * frozen filesystem is thawed. Should be matched with a call to
> + * kiocb_end_write() if it succeeds.
> + *
> + * Return: true if write access was acquired, false if it wasn't.
> + */
> +static inline bool kiocb_start_write_trylock(struct kiocb *iocb)
> +{
> +	struct inode *inode = file_inode(iocb->ki_filp);
> +
> +	if (!sb_start_write_trylock(inode->i_sb))
> +		return false;
> +	/* Fool lockdep just like kiocb_start_write() does. */
> +	__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
> +	return true;
> +}
> +
>  /**
>   * kiocb_end_write - drop write access to a superblock after async file io
>   * @iocb: the io context we sumbitted the write with
> diff --git a/io_uring/rw.c b/io_uring/rw.c
> index 3a8559ff4dc66..a0a16fc521455 100644
> --- a/io_uring/rw.c
> +++ b/io_uring/rw.c
> @@ -1095,9 +1095,6 @@ int io_read_mshot(struct io_kiocb *req, unsigned int issue_flags)
>  
>  static bool io_kiocb_start_write(struct io_kiocb *req, struct kiocb *kiocb)
>  {
> -	struct inode *inode;
> -	bool ret;
> -
>  	if (!(req->flags & REQ_F_ISREG))
>  		return true;
>  	if (!(kiocb->ki_flags & IOCB_NOWAIT)) {
> @@ -1105,11 +1102,7 @@ static bool io_kiocb_start_write(struct io_kiocb *req, struct kiocb *kiocb)
>  		return true;
>  	}
>  
> -	inode = file_inode(kiocb->ki_filp);
> -	ret = sb_start_write_trylock(inode->i_sb);
> -	if (ret)
> -		__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
> -	return ret;
> +	return kiocb_start_write_trylock(kiocb);
>  }
>  
>  int io_write(struct io_kiocb *req, unsigned int issue_flags)
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
