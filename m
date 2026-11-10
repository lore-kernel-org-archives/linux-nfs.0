Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315471;
	b=QV/4j2ZMEo8yT6szYGN63fhGTEYBGC44JSyLgCdD+MXsgyNOI0RSlKm6h7WkkXMxGAZP
	 IH4shiOYYppOn/VISwoXSLHraQiLvc2l95ynnYHKRprbMwfobMwKKCwU68EOUf5DGvEIS
	 sZ4gc0sZvqQSpDGYmk7HtyR4WKa8T0Hd86gq0ZFfIQ8wOhcAXLKiFlIs7fJc3G9ac1xhF
	 IQrIfB6MoDbA67yWKFTfNIsEItNokm6SLjGMVKDr52w7EatTrIWtjBx+kcuFyOcxnLow0
	 G32eldvzl/pf4AMq5FRLcw5u3h7KlXp+xQTw8dkuxgfXRQnyRySBml/XUr6PJA++89A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315471;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=u56kU65NdCHiYegRSOw5kHXRrJdKNRGx+HB56p2MoEM=;
	b=Wlmh04otKa2i6Qc8zh8aLGwfmcBTRVgOTvx+o0PvEpZ4iEdxLRaFVBS1efztQUjId6FB
	 WCSloKgY1ESW9UkXqp2cRfDSY86q5i3I2LXgPrKwSNPRcMJZTvA7Kgh+foK87nI8wt9uB
	 JouiY/drlbMhSCcRwa/nkSlot/23j7FQB9syJC3E+1rEqALEpWq6OeDKGWjiV/xOP9j2M
	 zVoyRXe1SX3ZzqoKUp+MCDUA6DgYBAgd29iujAfWQ7bSqrUn3fMKezn5OliDnTzLkQMcB
	 m47/L4QQFxSlGEhxFT40ikpRKDzQDrC6wkZpgGxoAuo5tddCQlV74/Ine0MCqVPsZmw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nxW9z78u;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=btbulXTV;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=LMpP+dRN;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="W/imUFHl";
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4261D606A7E4;
	Tue, 10 Nov 2026 12:57:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4261D606A7E4
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nxW9z78u;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=btbulXTV;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=LMpP+dRN;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=W/imUFHl
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 3789B21F51;
	Tue, 10 Nov 2026 12:57:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315469; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=u56kU65NdCHiYegRSOw5kHXRrJdKNRGx+HB56p2MoEM=;
	b=nxW9z78uWUgap8irqzft109tSowLMr4YxqMMElh/zotIXCZ4+lW6MJlBctgHBukJBaQMMw
	ruD5MFSAU2ytX9FM/2qdEFvkpAcqNmAdUGNJD859ctCBZZLYcnYQHvqxWygDJTqWEgBDuN
	FRSUFGrVUz2FcxpKnFAjouAxPqqJRpc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315469;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=u56kU65NdCHiYegRSOw5kHXRrJdKNRGx+HB56p2MoEM=;
	b=btbulXTVqM14e5L5WNYafj3Z3UHSl0sJl18esve+b0N+Z+BVeu5oPzl1tx4K7dsDrr9EMi
	JJdXqRlU4e+MyABQ==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=LMpP+dRN;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b="W/imUFHl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315468; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=u56kU65NdCHiYegRSOw5kHXRrJdKNRGx+HB56p2MoEM=;
	b=LMpP+dRNJB15/+GrMldJ9R0BwUcS6G1xXtY1rDaihJtNTBETdDBJaAkh8hGhqQCH7s6YB0
	tFcDW/P4aBjmQ6sQnmuWmvu+3kpvCZtt1W8F7c1sfRRo8cumiNUEJxWWvUWMt2wNi8Ask8
	DFOS+l52XWT5AOjw7COTdCQRmgpJV0o=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315468;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=u56kU65NdCHiYegRSOw5kHXRrJdKNRGx+HB56p2MoEM=;
	b=W/imUFHlH+e4RBFsF2pDXOIMFciuYHtCAibGY2upuW+rQlngot6TeK5i3IQ7jmUQis2+gk
	3YyFbxpDCdXcg8Cw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0A06F1339F;
	Tue, 10 Nov 2026 12:57:48 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id RbAzNssU82qoRQAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:57:48 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id A6FC2224EB; Tue, 10 Nov 2026 13:57:47 +0100 (CET)
Date: Tue, 10 Nov 2026 13:57:47 +0100
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
Subject: Re: [PATCH RFC 11/41] failfs: use fc_init_pseudo()
Message-ID: <inlny744cisamb7juafdkmq2lxdgbzcx7npwt7uekflfzqufjh@wkhlpwlorxew>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-11-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-11-4c998976c6c7@kernel.org>
X-Rspamd-Queue-Id: 3789B21F51
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Score: -13.01

On Tue 10-11-26 10:14:27, Christian Brauner wrote:
> Initialize failfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/failfs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/failfs.c b/fs/failfs.c
> index 437cdc981c2d..f03334f361c0 100644
> --- a/fs/failfs.c
> +++ b/fs/failfs.c
> @@ -3,6 +3,7 @@
>  #include <linux/fs.h>
>  #include <linux/fs/super_types.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include <linux/fs_struct.h>
>  #include <linux/magic.h>
>  #include <linux/mount.h>
> @@ -132,7 +133,7 @@ static int failfs_init_fs_context(struct fs_context *fc)
>  	fc->ops		= &failfs_context_ops;
>  	fc->global	= true;
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
