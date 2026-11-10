Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315395;
	b=0iaVo5ZVdMOS2zgCkG2WlUI+LM3nFPf4lI1PCTnlQ/i6wySWrNb3tSyzXwUtEP639PPR
	 PeHJyjAGIRA3cqURlQR+XTHa9hI9qQUI+oMOJ4hFJjQxiHx+aK7RYE1QJjj6t0ppLG1ll
	 xs8cCERKgPwTD6Swh7iqFXQAhc0GCA3EJfTClY1VVoHOlYrufOOV8coA3O6KLZSRQ10DK
	 sdmbLa0zdTbEK10ksF/wbEgNR0AjytvPtMGPgPKoGxf17OzVitssFvpykMi2iuE7lM0Le
	 QOFENc9JvkyCezTZD7PC7HDgE3gF1FQAc4dZ5YhUdpbz080iojBS89W8J8igLxPo1pw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315395;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:
	 X-Spam-Flag:X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=HPonFqTWiUmtrNs+Qb0D36Y6ciEfhMadviiHreNFwYc=;
	b=FBgMzOlEDo/vA4W9a0b1iRMBBcuWSeo0Fyrju9GNAs1E+atEU/Su8RzkFEmgysHH+rd5
	 goJqqDL4KeoNQrPGDxb2Q9ZRKtq5tOg4QQx0y8jdGkg1nhfmn3+hzqY6y6YvNVm38QGjf
	 y8jOQfiFweatczhkaOSYo5k7UCBhkWCx4JbwRU5XzqXjLjjReFjUi6O2oZ/vBv9P4APtj
	 Fkr8C2j970tZI4iOnZN0e/BDZ0jjhon/7bD/hqh6w+6lgg2iKs6btQNoAVWqO3xok4dsF
	 UmVTwXdNBjoNurriwtJJJfO3vviVmzeKW/nmWQJOpksC5fpG28ZZurXwQYrMM+FyaKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=iI7ym2rR;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=d7Rq00c+;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=iI7ym2rR;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=d7Rq00c+;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58D9A606A336;
	Tue, 10 Nov 2026 12:56:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 58D9A606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=iI7ym2rR;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=d7Rq00c+;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=iI7ym2rR;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=d7Rq00c+
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 76D2521F51;
	Tue, 10 Nov 2026 12:56:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315392; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=HPonFqTWiUmtrNs+Qb0D36Y6ciEfhMadviiHreNFwYc=;
	b=iI7ym2rRMMc3VrhaaAlN5WNcqZznLEHDbtpYqtRkG5n1tfi+3M5v/n/1WuSOFedMo1sqbz
	Sc32CgTVFd7/opphYDcFWOT80BR/RRxVs/vkTtWjRDJpkb4OidIs7+B5BXeAuF4BOYbj/J
	KLIaaDFlgWnKom1lHgtRS/Kk0HCzFnQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315392;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=HPonFqTWiUmtrNs+Qb0D36Y6ciEfhMadviiHreNFwYc=;
	b=d7Rq00c+LDwkQJ8CY66ztb5ybwTC8KjmYM3gSgR5ZqtZLmPfIVg22YnOIpbxkR6cuLihJP
	WLfQ9WIdsrYIm9Aw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=iI7ym2rR;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=d7Rq00c+
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315392; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=HPonFqTWiUmtrNs+Qb0D36Y6ciEfhMadviiHreNFwYc=;
	b=iI7ym2rRMMc3VrhaaAlN5WNcqZznLEHDbtpYqtRkG5n1tfi+3M5v/n/1WuSOFedMo1sqbz
	Sc32CgTVFd7/opphYDcFWOT80BR/RRxVs/vkTtWjRDJpkb4OidIs7+B5BXeAuF4BOYbj/J
	KLIaaDFlgWnKom1lHgtRS/Kk0HCzFnQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315392;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=HPonFqTWiUmtrNs+Qb0D36Y6ciEfhMadviiHreNFwYc=;
	b=d7Rq00c+LDwkQJ8CY66ztb5ybwTC8KjmYM3gSgR5ZqtZLmPfIVg22YnOIpbxkR6cuLihJP
	WLfQ9WIdsrYIm9Aw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 4B4391339F;
	Tue, 10 Nov 2026 12:56:32 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 7R2CCoAU82qzQwAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:56:32 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id E835D224E7; Tue, 10 Nov 2026 13:56:27 +0100 (CET)
Date: Tue, 10 Nov 2026 13:56:27 +0100
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
Subject: Re: [PATCH RFC 06/41] proc: use fc_init_pseudo()
Message-ID: <sqdczu46saxh7e2x5d7cuzkfqnlrp2naoqau374n2chx55ylpm@tirkx2qx4uju>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-6-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-6-4c998976c6c7@kernel.org>
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[31];
	RCVD_TLS_LAST(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RLbde8anocd1dffa59fn6d5qp8)];
	MISSING_XM_UA(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,google.com,kernel.org,toxicpanda.com,lst.de,lists.infradead.org,zeniv.linux.org.uk,suse.cz,lists.linux.dev,kvack.org,lists.ubuntu.com,lists.xenproject.org,lists.ozlabs.org,gmail.com];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,suse.cz:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -13.01
X-Spam-Level: 
X-Rspamd-Queue-Id: 76D2521F51

On Tue 10-11-26 10:14:22, Christian Brauner wrote:
> Initialize procfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Makes sense. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/root.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 7fbbe92bf73a..ca0e75081934 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -17,6 +17,7 @@
>  #include <linux/bitops.h>
>  #include <linux/user_namespace.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include <linux/mount.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/fs_parser.h>
> @@ -265,8 +266,6 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
>  	if (ret)
>  		return ret;
>  
> -	/* User space would break if executables or devices appear on proc */
> -	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
>  	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
>  	s->s_blocksize = 1024;
>  	s->s_blocksize_bits = 10;
> @@ -350,6 +349,7 @@ static int proc_init_fs_context(struct fs_context *fc)
>  	put_user_ns(fc->user_ns);
>  	fc->user_ns = get_user_ns(ctx->pid_ns->user_ns);
>  	fc->fs_private = ctx;
> +	fc_init_pseudo(fc);
>  	fc->ops = &proc_fs_context_ops;
>  	return 0;
>  }
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
