Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794830291;
	b=4yqD5Jw9KEn8/LCgtHMiHIh0A+kBQJdKEdVyeIj+0tgrPYUXe13Z24cZHsQqGgoFCJSk
	 eh6suYTQ0LSc3knSB+BTTzqShCVj300zErFNHp5z5wHC0HiQiSfQ0hbuVBheNHzY1hP9T
	 DsZbG5j52JxJuX4AQUnBJZCIL1/v3cWZQmnQbJ3BHMo/BGsIZgSY7NudX/gHs/p8unzLO
	 5Pw+wXO/oraKzHD3oRc5OKSNspzwwGBRyQAxhp9Ofhw7U1Rfn+onNLpiXwrWCBXW3RuuB
	 AnrqNRxjQJPu6RzrdCpMpaU5AKOGQm5a5aPT+yAj+jYGjI3Hkeui979EgySuyqPlrmA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794830291;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=O3kyFYNZEO98BGa5AYi7ZBKt28oh7YsdECVSE9jZkTU=;
	b=vBQLIDqsmICSwERhrlVaucOoZtA8Zme5TxY/91iTsD6tII9rvYAJ0NQHlMEqNTNIm29N
	 OclumJIy8ZcamvFmTHJ0JpLIAs3AOJbTOtOZvcZvC2uAR0aIksg8SA4EHUNqPcRcbDE8q
	 eyxA3APlRjPwutau3D/18M7hAOlLoVNDXxuLUDVQ0C9Kmc3Evo+5n5VIvfwcRIa/Xyjkv
	 WPbT7Ld6BipCd5H248U8GY0xpCFwnU6hcZg1Ho6zjCBvzLnbbEkTO75ghzpazvjcvpVxl
	 MtwlXRAYE33m+WQqnDoOBQpPnEYGmCVWmSGS+m4d5I+CXKvEBj3iUQkwfoXBG+xfNnQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=2+ywiZyW;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QNEtN+F7;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=1GgTnund;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=4kJ0IcoK;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B63C8606A31C;
	Mon, 16 Nov 2026 11:58:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B63C8606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=2+ywiZyW;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QNEtN+F7;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=1GgTnund;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=4kJ0IcoK
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id A3E6422262;
	Mon, 16 Nov 2026 11:58:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794830289; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=O3kyFYNZEO98BGa5AYi7ZBKt28oh7YsdECVSE9jZkTU=;
	b=2+ywiZyWPDD66lUhrpPh325/MJEmNQNKxPcFlIf572S72HqpVpHwWTnXh77PlW9IMu4qOQ
	6f08im9gEa6Ry+r2fLmj67zFVOL91dxN69raBB8c+By/I46nrysLLtWOzOLwU4NCTQSLnM
	Roy5P1/Sbj6zQkP/CSi3gDSquZ2ki9I=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794830289;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=O3kyFYNZEO98BGa5AYi7ZBKt28oh7YsdECVSE9jZkTU=;
	b=QNEtN+F7Bw2apRLsIJiYbvvfaZw08vBRO3H2yCKYgvRibrXTVTjkLPTikJmhQ8VutuDxOG
	6Bhl6seErk05ZYAw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=1GgTnund;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=4kJ0IcoK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794830287; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=O3kyFYNZEO98BGa5AYi7ZBKt28oh7YsdECVSE9jZkTU=;
	b=1GgTnunddjz5p25LSqSEj0+KbWLyLPG+Yl1IKKnWGMPCTMnTYVPnozxysh4TySv5TQOpLx
	M0u1BK6eSgfsG7wjdXgKZCez8iL4agiXQZSvfimaJZvWM/3h6EeWT6fjNHA6p2horaTkhQ
	TleuzQ6pOhywOoinZPloBMJe2xPdpyg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794830287;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=O3kyFYNZEO98BGa5AYi7ZBKt28oh7YsdECVSE9jZkTU=;
	b=4kJ0IcoKE9WktJYlwJFcoT0LMqinoXxjDZ/Yj5TzSLNr5LynLDUvTngtqcJFIT/jfTtRvI
	9CrNxifZG8VuzlAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 79CEE1334C;
	Mon, 16 Nov 2026 11:58:07 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id iSbtFc/v+mroRwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 11:58:07 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 2397D24DD4; Mon, 16 Nov 2026 12:57:59 +0100 (CET)
Date: Mon, 16 Nov 2026 12:57:59 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 01/12] fs: add kiocb_start_write_trylock()
Message-ID: <xhmgs4lntq2mnzrj27ec2ldsqsoxx7osvhrrwpmqecp3gotm7m@5pkboz23vwjj>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <20261114-work-fs-frozen_writes-v1-1-f5ae61c898b1@kernel.org>
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
In-Reply-To: <20261114-work-fs-frozen_writes-v1-1-f5ae61c898b1@kernel.org>
X-Rspamd-Queue-Id: A3E6422262
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email];
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

On Sat 14-11-26 11:47:08, Christian Brauner wrote:
> kiocb_start_write() waits until a frozen filesystem is thawed. A
> nonblocking submission can't use it. io_uring open-codes the trylock
> variant for its IOCB_NOWAIT writes.
> 
> Add kiocb_start_write_trylock() next to kiocb_start_write() and use it
> in io_uring. The nvme target's file backend is going to need it as
> well.
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
