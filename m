Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315480;
	b=z1L2qsJnPsy+EeBxAd6k3hKz6LrG+IYq7qMng0vGKSSg1oPv0KUxCHc2KGHBarCX0eaI
	 R06udtkfEBwnbul/pWH09EM1ngaH4w0J0GCba9S5TRC8Ff+INNzG8JTmQG5bZ52itGaJ/
	 uQ+IHiGZN4HYjNfzgmYIdnzeZDJ+V2dcYlDNng1HSE/GhEztldqkirbE41esI0+5llx7G
	 AqtzKj6zN1JNVuZUsmt1VcZGJf3v4NTMd6Y6yf5Q5dglllGoVxxOTF2MQeI7AwNrFHDsz
	 jbHGrNlUtFPDncNaa7RekUUQEHoAACNsm44JlxgAtsFn6VPL99CPgrJsbwCyf5gqvaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315480;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=7u2HJ+t6im2/188SWjC78CxpZGXhauj6sAa+Bj5Q2xU=;
	b=slYdwHVLEXGCW73495Uf8NBuC92HLbP+/BApKgUFSJzsydTPOfyKJ3mOhN+rNIz2yOPp
	 BnRSXh4tFR8nWzRQ10kZdpIINs2S5QzMl6fu20hQaRkoIKehPRl5/bzTAhdQwVuBTWA6u
	 Td5PKGpNJ3eugdilpYT8Y6p2sAbBwV3+8HrLzZA41PxhI6cK5JSA3/u4uR04QYCYlkr1J
	 0jnp7Dyap7gL0ffOgL/Yi+A4BSaKNZS7BDh19JKRd3vwvMdVhrMshHWVV0XgQA5ChAFpU
	 18+Si9teebkVsiU5ltkKlXAoKy5x6+HZX3+/aLDz38ZmOjD/YkESrf3dhBx6SKSI/pQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xph88wH+;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=3cVo9nCM;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xph88wH+;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=3cVo9nCM;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5ABE5606B2D6;
	Tue, 10 Nov 2026 12:58:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5ABE5606B2D6
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xph88wH+;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=3cVo9nCM;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=xph88wH+;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=3cVo9nCM
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 9B25E1F387;
	Tue, 10 Nov 2026 12:57:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315478; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7u2HJ+t6im2/188SWjC78CxpZGXhauj6sAa+Bj5Q2xU=;
	b=xph88wH+Cy4MXPY3pDS5PKcSUzHmc+SEQP8d3AyFmCy2YYggWiv8xaF2611c3F4yHIaS3n
	dOTrXXIx6QtAs+h+dq6T4SaRrTqgpHek+kx6gSsXXKEhEsdSk6oTrIEhb22EzUz/Ph4jEi
	GJqUWg2KgmeP3xzrUh4+nn9lwCWSLr8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315478;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7u2HJ+t6im2/188SWjC78CxpZGXhauj6sAa+Bj5Q2xU=;
	b=3cVo9nCMZ1HraZx1ANnHnRX3eVA0FntbrI5ij7LYl/xiVKi3TDwJJMtHtmc9R005dJKVoZ
	492ApFvso7WI9fDw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315478; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7u2HJ+t6im2/188SWjC78CxpZGXhauj6sAa+Bj5Q2xU=;
	b=xph88wH+Cy4MXPY3pDS5PKcSUzHmc+SEQP8d3AyFmCy2YYggWiv8xaF2611c3F4yHIaS3n
	dOTrXXIx6QtAs+h+dq6T4SaRrTqgpHek+kx6gSsXXKEhEsdSk6oTrIEhb22EzUz/Ph4jEi
	GJqUWg2KgmeP3xzrUh4+nn9lwCWSLr8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315478;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7u2HJ+t6im2/188SWjC78CxpZGXhauj6sAa+Bj5Q2xU=;
	b=3cVo9nCMZ1HraZx1ANnHnRX3eVA0FntbrI5ij7LYl/xiVKi3TDwJJMtHtmc9R005dJKVoZ
	492ApFvso7WI9fDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6FF141339F;
	Tue, 10 Nov 2026 12:57:58 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id FK6SEtYU82qxRQAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:57:58 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 15B65224ED; Tue, 10 Nov 2026 13:57:58 +0100 (CET)
Date: Tue, 10 Nov 2026 13:57:58 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, apparmor@lists.ubuntu.com, 
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
	linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 10/41] nullfs: use fc_init_pseudo()
Message-ID: <josp5gwkmm4f6pk572b564xfjk77wz7jk24pajp5pr3qfdtljh@ihi2c3w4mpp4>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-16.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[31];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	R_RATELIMIT(0.00)[to_ip_from(RLdu9otajk16idfrkma9mbkf9b)];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,google.com,kernel.org,toxicpanda.com,lst.de,lists.infradead.org,zeniv.linux.org.uk,suse.cz,lists.linux.dev,kvack.org,lists.ubuntu.com,lists.xenproject.org,lists.ozlabs.org,gmail.com];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.com:email]
X-Spam-Score: -16.80

On Tue 10-11-26 10:14:26, Christian Brauner wrote:
> Initialize nullfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/nullfs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nullfs.c b/fs/nullfs.c
> index 319c2f5c5a67..2fe24cb97160 100644
> --- a/fs/nullfs.c
> +++ b/fs/nullfs.c
> @@ -2,6 +2,7 @@
>  /* Copyright (c) 2026 Christian Brauner <brauner@kernel.org> */
>  #include <linux/fs/super_types.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include <linux/magic.h>
>  #include <linux/splice.h>
>  #include <linux/uio.h>
> @@ -174,7 +175,7 @@ static int nullfs_init_fs_context(struct fs_context *fc)
>  {
>  	fc->ops		= &nullfs_fs_context_ops;
>  	fc->sb_flags	|= SB_NOUSER;
> -	fc->s_iflags	|= SB_I_NOEXEC | SB_I_NODEV;
> +	fc_init_pseudo(fc);
>  	return 0;
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
