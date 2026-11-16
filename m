Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834917;
	b=Df+kgoLTGAmPUdOuSmpAmClTHwYBQIw6H+wneSvrgVXu2s4VECcrWaT49057DoYSW5+d
	 nii96a7bBZIwLzmbY+W8RfsT2xoUlRG2vgBarDZ2pTDd/OfMf3YbRhfAV6k1vQVcQacaN
	 9aU01mw1CJ1SDwzXxsSmve9w9MGuhR75E1XGqeywtSTloHhNbFtLRMf1u3gByGQPTh0jn
	 qO4gkPnijpMjsv8lqGjgfzU4/w+MPnocLpgooqFpG2ABxcQhx7ni+Ay5H3XFwkv2WUvDV
	 2KMD2qElJYhVHiZ0mJdHGTzhE0VG/C/WfLzDKzBrrzrqDYBG0sZzL4CIWGLPAnrOnSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834917;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=SbQMvuUAaUCJxCyLbgVgjkEvS9uHHmg+wODL5Pb6qqI=;
	b=ySwkove69TCUlGJ7D7EgEG7gMWwo6VYNq4hOAtGlJJOfGb0yUBQ9Voo7+6WxOQrXiZ/2
	 YIV7ww9lI6RQyRvdw4fs7EwUzLwLkEp8i4ssYx1KluHwew/ABjFONkGz6d4uSjAI3nd35
	 z3dWaDi42HqW5DqnE57LylUXPoahtVeRcUXqIc21cdlzKFdAPRE9HtEdpT7UkfLHjUqJT
	 16Y8fg/4dmEDVblBVB//lX8KMBFUfz/aH78+hI1pQSgKitjoriMt4+FVpUsz9H/rubaDn
	 HK09TaZQ2kcCXEJa91nM/JBEEkRBNn6gmYeCEaaZGEgVuA30HbGqZ5ZOFIITAQPYGqg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=k6AeJWlG;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="InXG/Gt7";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=k6AeJWlG;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="InXG/Gt7";
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4B36606A88B;
	Mon, 16 Nov 2026 13:15:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E4B36606A88B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=k6AeJWlG;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=InXG/Gt7;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=k6AeJWlG;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=InXG/Gt7
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 1AEF61F823;
	Mon, 16 Nov 2026 13:15:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834915; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SbQMvuUAaUCJxCyLbgVgjkEvS9uHHmg+wODL5Pb6qqI=;
	b=k6AeJWlGuKY+PJ9SVs/2oQA7jMWAzIoTo9As9NadFRLFkf3Q1YR6EZRGRyT7Xx9zLVfKb/
	KBAb1HvUI8FAWLlb7kRciTf7zcnzB1Zrlw0KNhtadAxoCD5cYgoHC9ATZYBaUOF5x6YSJh
	ejrO2temGndMpnvYLmXBy5eptIoCfDM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834915;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SbQMvuUAaUCJxCyLbgVgjkEvS9uHHmg+wODL5Pb6qqI=;
	b=InXG/Gt7mYuLY+QU/TrCSUyjU6J4SWiLdcnqru3iCszinM7w44qjjuoNww5nmj6MIg38oa
	SVn9a3itcvaURNAA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834915; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SbQMvuUAaUCJxCyLbgVgjkEvS9uHHmg+wODL5Pb6qqI=;
	b=k6AeJWlGuKY+PJ9SVs/2oQA7jMWAzIoTo9As9NadFRLFkf3Q1YR6EZRGRyT7Xx9zLVfKb/
	KBAb1HvUI8FAWLlb7kRciTf7zcnzB1Zrlw0KNhtadAxoCD5cYgoHC9ATZYBaUOF5x6YSJh
	ejrO2temGndMpnvYLmXBy5eptIoCfDM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834915;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SbQMvuUAaUCJxCyLbgVgjkEvS9uHHmg+wODL5Pb6qqI=;
	b=InXG/Gt7mYuLY+QU/TrCSUyjU6J4SWiLdcnqru3iCszinM7w44qjjuoNww5nmj6MIg38oa
	SVn9a3itcvaURNAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E85051334C;
	Mon, 16 Nov 2026 13:15:14 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id VfayMOIB+2rcGQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:15:14 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 8DB2C24E10; Mon, 16 Nov 2026 14:15:10 +0100 (CET)
Date: Mon, 16 Nov 2026 14:15:10 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 15/17] loop: use kiocb_write_iter()
Message-ID: <n2q74w47baqlgngqsmdhodjp4qbkdcaxomjcjpkxojybg6zfhv@qy7ksqfo2z3h>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
 <20261116-work-fs-frozen_writes-v2-15-ecc4a2aac40e@kernel.org>
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
In-Reply-To: <20261116-work-fs-frozen_writes-v2-15-ecc4a2aac40e@kernel.org>
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
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[16];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	URIBL_BLOCKED(0.00)[suse.cz:email,suse.com:email,imap1.dmz-prg2.suse.org:helo];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.com:email]
X-Spam-Score: -12.80

On Mon 16-11-26 12:03:55, Christian Brauner wrote:
> Use the new helpers instead of open-coding freeze protection for writes
> to the backing file.
> 
> No functional changes.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/block/loop.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index d2f29aadabcc1..872d78006b131 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -325,8 +325,7 @@ static void lo_rw_aio_do_completion(struct loop_cmd *cmd)
>  		return;
>  	kfree(cmd->bvec);
>  	cmd->bvec = NULL;
> -	if (req_op(rq) == REQ_OP_WRITE)
> -		kiocb_end_write(&cmd->iocb);
> +	kiocb_end_write_iter(&cmd->iocb);
>  	if (likely(!blk_should_fake_timeout(rq->q)))
>  		blk_mq_complete_request(rq);
>  }
> @@ -395,10 +394,9 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
>  		cmd->iocb.ki_flags = 0;
>  	}
>  
> -	if (rw == ITER_SOURCE) {
> -		kiocb_start_write(&cmd->iocb);
> -		ret = file->f_op->write_iter(&cmd->iocb, &iter);
> -	} else
> +	if (rw == ITER_SOURCE)
> +		ret = kiocb_write_iter(&cmd->iocb, &iter);
> +	else
>  		ret = file->f_op->read_iter(&cmd->iocb, &iter);
>  
>  	lo_rw_aio_do_completion(cmd);
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
