Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834846;
	b=OP4j/bcN8PwFtv+luGG7Exopj64EN3Nqxb1x8Nc3JZhJdUkjVP6ldbKdJRjMfBUx/rug
	 r0UWdNpLeoyglbmP9Zc4YUXOu8M16qcQVpeFFp7dtyMFlpk0d3hjzDWOVLyCMxUlXM9Dc
	 18A0g4iyY3Xeu0D/2T2pOVJdRBOeFN6aWsh72sNIxkvtBbQt0JRE7IBQ748QLlWuQTaGY
	 SI8noQDKo20RCj0eFjLk+NepyrKpQ/2XUBmBkL1JXzze+R4Vbs6AAREuDI3F74BHan8Ni
	 6sk6n5Gomxg3qq4Cdr/m93NzCKOFizAjBqcSW+h71fZbpee/t12CSHjEEN1zus8Gszg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834846;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=PFhObvSjr3B4O2wdtH/yQGSD5a72BQl4ILGJIm9KYfw=;
	b=hr//QxhiAx1Aj8NaG0eoqYbwb6w65Ib840EPiIpz2UJPQdiLLq2uEnPc8qRW+bhmocC3
	 68GYiS9KSWQYqJiNlMCbW9ty6dw6VcR0p/Uc0gMwkjbnlOlU+NLK9BzzZayMz44ahNeDm
	 jrLEArmDoj5hmErm5ueIbICxX58+eGolLzb+Oni5MjJUxIqoUugi7cX1uHRzBWtyjy6gp
	 SRgn64WELDWnbLlSamxtFvM4XQ8f4wQfHISHzdCxcJbZk26cHh3VdeyrdxS9QfWNVhVNa
	 dFQDdjXwj9/NmGeFegbknTiBMjEg4oVwW9PCW/mt4YajF1/Zr3EKVoUekcBO/KnFZ1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ge5B3Buh;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/UriHDLT";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ge5B3Buh;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/UriHDLT";
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC1C4606A329;
	Mon, 16 Nov 2026 13:14:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC1C4606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ge5B3Buh;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/UriHDLT;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ge5B3Buh;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/UriHDLT
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 342082227B;
	Mon, 16 Nov 2026 13:14:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834844; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=PFhObvSjr3B4O2wdtH/yQGSD5a72BQl4ILGJIm9KYfw=;
	b=ge5B3BuhYHXLUUA0JptT1fuMmK2fIyQRBlBbkLe5iP1FVc3OEd0ejnKlZc+ceDiibQ0hgM
	SA+sCF4v3SxoT4tA4WXsHvVUWDAjyJ85msUa+4P5Il2eEmHTzYungj9K/MlkGl2tXrvhyH
	+NSZxDcIYvriE/byAr13XLt+bLariQo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834844;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=PFhObvSjr3B4O2wdtH/yQGSD5a72BQl4ILGJIm9KYfw=;
	b=/UriHDLTlNk2T+Cwf4CDo4p9g0KiCUlMtFrs0hPKknPGohUHrw4I4RR6SVZ87yf8Yw7fN7
	/4V5KpFXOweIlRAA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834844; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=PFhObvSjr3B4O2wdtH/yQGSD5a72BQl4ILGJIm9KYfw=;
	b=ge5B3BuhYHXLUUA0JptT1fuMmK2fIyQRBlBbkLe5iP1FVc3OEd0ejnKlZc+ceDiibQ0hgM
	SA+sCF4v3SxoT4tA4WXsHvVUWDAjyJ85msUa+4P5Il2eEmHTzYungj9K/MlkGl2tXrvhyH
	+NSZxDcIYvriE/byAr13XLt+bLariQo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834844;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=PFhObvSjr3B4O2wdtH/yQGSD5a72BQl4ILGJIm9KYfw=;
	b=/UriHDLTlNk2T+Cwf4CDo4p9g0KiCUlMtFrs0hPKknPGohUHrw4I4RR6SVZ87yf8Yw7fN7
	/4V5KpFXOweIlRAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0B16F1334C;
	Mon, 16 Nov 2026 13:14:04 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id +4lPNpsB+2rMGAAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:14:04 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id A700424E0E; Mon, 16 Nov 2026 14:14:03 +0100 (CET)
Date: Mon, 16 Nov 2026 14:14:03 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2 08/17] loop: take freeze protection for discard and
 write zeroes
Message-ID: <mmuho3sjwkzcsibntmqp4phwfo63a2hkzfy34qes6zlhztehgg@e5t5igmvtboa>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
 <20261116-work-fs-frozen_writes-v2-8-ecc4a2aac40e@kernel.org>
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
In-Reply-To: <20261116-work-fs-frozen_writes-v2-8-ecc4a2aac40e@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
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

On Mon 16-11-26 12:03:48, Christian Brauner wrote:
> Discard and write zeroes requests end up in lo_fallocate() which calls
> ->fallocate() of the backing file directly. That skips the freeze
> protection vfs_fallocate() would have taken. So they go straight
> through to a filesystem that is frozen. With the backing file on ext4:
> 
>   WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#3: kworker/u16:1/44
>   Workqueue: loop1 loop_rootcg_workfn
>   Call Trace:
>    <TASK>
>    __ext4_journal_start_sb+0x7a/0x470
>    ext4_dirty_inode+0xa1/0x120
>    __mark_inode_dirty+0x154/0x1110
>    file_update_time_flags+0x3ab/0x4b0
>    ext4_fallocate+0x286/0x3440
>    lo_fallocate+0x13e/0x290
>    loop_process_work+0x486/0xe70
>    process_one_work+0x946/0x1820
>    worker_thread+0x4f1/0xd60
>    kthread+0x364/0x460
>    ret_from_fork+0x525/0x770
>    ret_from_fork_asm+0x1a/0x30
>    </TASK>
> 
> Take freeze protection around ->fallocate() like vfs_fallocate() does.
> 
> Fixes: dfaa2ef68e80 ("loop: add discard support for loop devices")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/block/loop.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index a3325ceab484a..d2f29aadabcc1 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -259,7 +259,8 @@ static int lo_fallocate(struct loop_device *lo, struct request *rq, loff_t pos,
>  	if (!bdev_max_discard_sectors(lo->lo_device))
>  		return -EOPNOTSUPP;
>  
> -	ret = file->f_op->fallocate(file, mode, pos, blk_rq_bytes(rq));
> +	scoped_guard(file_write, file)
> +		ret = file->f_op->fallocate(file, mode, pos, blk_rq_bytes(rq));
>  	if (unlikely(ret && ret != -EINVAL && ret != -EOPNOTSUPP))
>  		return -EIO;
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
