Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834819;
	b=COxSG7lsvVdckK/DdZgOuEgU2xIfy5m5b/6nToYgNUX5F4GaOuamJmh2Iof7b7TPY99t
	 8rgUB5GgdBTjKceKM2GVugoTn2gsyJu+mi3XRdNHqDolyjBUcRzHgX34iU67Vc2J5E8S2
	 Mj7h3sXOpfxnQn3NFYqfTXJCC2iSu3NFehnKHONVc38a0BnVVbvBJ3m0z+yvWkhhEf7Nz
	 WHpisTdFPFbIzR452QjY4BP+0sSeZcqcdQNKHs6JkAnNIEDsaAxL8J0iwAzK2UyuLekQw
	 TAI+qIdcLnyq3kCi1ORPMylf69QNuS/6fDx5lc7frMMQK+nSquIj6OEcnSD+19F1PQg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834819;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:
	 X-Spam-Flag:X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=3ebwOHO3DLWDdWRTVfnZ67IZWLbMAWCyYXQa8P8BweM=;
	b=Kcq42bnm9UKyJiXhl0l7v+T0F1WuiXsbfeXmp1V1mhW3zRyBOu/JKIenVlMrgcKQ3BQo
	 yaKme0rYagQa9+gxh/UZY/vyhSjhPEVd4PmvxCpkKDzui6tP++dFm9P/iGLx5oM19U75Z
	 w1IS3x9USapWXSXKinF7169YwmH3m+/0F+NyN8lNoA+F7D+AgXLqCjPtuhQDon70tA/w6
	 RQBbTTPnOWkpyZUVs5Hy8tt4HhvHkzTKGvwliUBj8Jjfd0EKDuKmTSZQPXF/sOMXM7kjH
	 XEcGok32bpJLmVXUvXKTO8XlArOonzFBJUCykQWWQbH6lsGeF1sVEQlQTqm5RX9oWzA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zP0sMLun;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="7QB92/4E";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zP0sMLun;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="7QB92/4E";
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 247B9606A323;
	Mon, 16 Nov 2026 13:13:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 247B9606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zP0sMLun;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=7QB92/4E;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zP0sMLun;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=7QB92/4E
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 0E9211F7D2;
	Mon, 16 Nov 2026 13:13:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834817; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3ebwOHO3DLWDdWRTVfnZ67IZWLbMAWCyYXQa8P8BweM=;
	b=zP0sMLunOdvyn/YjVZq+lqIaHp4Wq9o5qnA+0dqUjY0AUoguLBt5JbRa5zbxUn91U6E+qZ
	P/iOUmmXPeDRWLG4+8WbDhJIUguWe+fw+qv8Z6/0BU6wj8s0VyC3UT5YaTImmwfchAFm91
	k1IYTZjNMu+dVZYt3rDIWOttcoBAtLM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834817;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3ebwOHO3DLWDdWRTVfnZ67IZWLbMAWCyYXQa8P8BweM=;
	b=7QB92/4E7h4LCXz51bGCcCQF8vrtiozlhR649szDzFTLMcBmZ6qSkp/wAtW0jOjQ1fjxad
	iVIEt5Q94mvA5CDw==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=zP0sMLun;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b="7QB92/4E"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794834817; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3ebwOHO3DLWDdWRTVfnZ67IZWLbMAWCyYXQa8P8BweM=;
	b=zP0sMLunOdvyn/YjVZq+lqIaHp4Wq9o5qnA+0dqUjY0AUoguLBt5JbRa5zbxUn91U6E+qZ
	P/iOUmmXPeDRWLG4+8WbDhJIUguWe+fw+qv8Z6/0BU6wj8s0VyC3UT5YaTImmwfchAFm91
	k1IYTZjNMu+dVZYt3rDIWOttcoBAtLM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794834817;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=3ebwOHO3DLWDdWRTVfnZ67IZWLbMAWCyYXQa8P8BweM=;
	b=7QB92/4E7h4LCXz51bGCcCQF8vrtiozlhR649szDzFTLMcBmZ6qSkp/wAtW0jOjQ1fjxad
	iVIEt5Q94mvA5CDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D9E421334C;
	Mon, 16 Nov 2026 13:13:36 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id TD9lLYAB+2ohGAAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:13:36 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 8431524E0C; Mon, 16 Nov 2026 14:13:36 +0100 (CET)
Date: Mon, 16 Nov 2026 14:13:36 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2 03/17] fs: add file_write guard
Message-ID: <alfngelvy6yzzdpudh3mwp3voiwchbtedkczpyitf2lmv2h4oc@jimsorr6fp2t>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
 <20261116-work-fs-frozen_writes-v2-3-ecc4a2aac40e@kernel.org>
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
In-Reply-To: <20261116-work-fs-frozen_writes-v2-3-ecc4a2aac40e@kernel.org>
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:email,suse.cz:dkim];
	RCPT_COUNT_TWELVE(0.00)[17];
	MIME_TRACE(0.00)[0:+];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.cz:dkim]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -13.01
X-Spam-Level: 
X-Rspamd-Queue-Id: 0E9211F7D2

On Mon 16-11-26 12:03:43, Christian Brauner wrote:
> Add a guard for file_start_write() and file_end_write().
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

OK. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 0b66a09fb686a..c156a326e8c89 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2782,6 +2782,11 @@ static inline void file_end_write(struct file *file)
>  	sb_end_write(file_inode(file)->i_sb);
>  }
>  
> +DEFINE_GUARD(file_write,
> +	     struct file *,
> +	     file_start_write(_T),
> +	     file_end_write(_T))
> +
>  /**
>   * kiocb_start_write - get write access to a superblock for async file io
>   * @iocb: the io context we want to submit the write with
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
