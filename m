Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793882195;
	b=Ou+2wGsVzn7Z6SNv9XPpgKZIcN4U1wCJG1VpAOKi1SmWp5onJbrGNZdJEvozkLm2NwVJ
	 NpHGpQsTMZGRHi4ADPfAKQvrcEhKQbFjGBaVmg1JUtGEWMo2zu+h7AxBN+gLL1mWAtDDT
	 169ZyhpNwZYSCnh9w9AiiHBx6AM90dRM8ZOFb7WcqSSKl7PemKOC32SkSFDGSU3Jxuf1h
	 voH4dC8CwY92b2w589oImM1bTcipbX2SpeFWKVYazstzKprfDt/nRMwE2QKBXGWoiSoHQ
	 DPDcrbPHjRjb+VR/9vTr7B4zZVy8Af+/UEMlBYa8Fk8LBTLMI2aHlZYbImZez4Fkj8Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793882195;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:
	 X-Spam-Flag:X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=DpjKnWhAHhajlU0N8yPm40hOORTtvriSHlYmNC33ga8=;
	b=RbwwUhaA/Pii3DB2MbvmPooi4HQozb4wv93GyhL9w+1mnuIb53SNMAUg1+J7Ub9sdHaz
	 pKeQzuU9CADjko+4nANGHQ+oWT1OMVqSmE/H8rCk/pQbYNq2eh8m6mBcktqa35lqVWxU2
	 HVATF+zwWkgiWxoBSE9V06eqXPQaE3KdYT0l53Kigfxn7K4fBiLDDn8NTPA3fOgsOhUBn
	 2lKQgpfotvuXrQW3D/mdYxVIawB0R2ayTyO0b865LzEdAMWEa0BKdq7QlcUZqqUj8yBim
	 JLj5dZhvsnMzJlrvWJ6eVT9JgUbWlKqPC8I9E8pOYhvCiV1AjB5e8AQj49ftC74O7cQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JZx76L+g;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="8/5XD6W9";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=T3Jse+8w;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=BYgAZw+U;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 212C9606A32F;
	Thu,  5 Nov 2026 12:36:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 212C9606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=JZx76L+g;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=8/5XD6W9;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=T3Jse+8w;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=BYgAZw+U
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 2C5F621E5A;
	Thu,  5 Nov 2026 12:36:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793882193; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=DpjKnWhAHhajlU0N8yPm40hOORTtvriSHlYmNC33ga8=;
	b=JZx76L+ggOq++v50JrM+txlftOOqxJaKF/tK8uhPwld5Q9GnNQfLXM1whyLb1DsMeHXH/C
	/uTr5WEx4MoDADem0Lt2IRl8UnJCEvNjej74YyT5VZBSM782Vk2aNTEZTgyxnuBLnPZ/fS
	Mhf/U17g3frl5lC6gN/6C/6ftmbFF2E=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793882193;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=DpjKnWhAHhajlU0N8yPm40hOORTtvriSHlYmNC33ga8=;
	b=8/5XD6W9JBZBD7IT0Gng8T7errG+mfSR55zIjyH58gQPHLQ3a+6mBXLPeQK6OumZ9O/ASJ
	a0+wPfZoC8vZgnDQ==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=T3Jse+8w;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=BYgAZw+U
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793882192; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=DpjKnWhAHhajlU0N8yPm40hOORTtvriSHlYmNC33ga8=;
	b=T3Jse+8wWvU2m0agalLdcO3u4gc4aSPygpqteqhLhNd/aBjFrhyiDCC1i0Lv+iYh3z1s6e
	fnA2+Jf6Yg0jKvkbvYGo3ERh6eFq09U2ijwb8SlUT+DSbyddzL3tu06qm3Tz++uFh8zr+9
	+TrYzUca/b6bladItMQ0Kk0+pK0H3fw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793882192;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=DpjKnWhAHhajlU0N8yPm40hOORTtvriSHlYmNC33ga8=;
	b=BYgAZw+Ujm4L/dnuxqWK1yrVNISlV/1cL+J702exe7XcXF17FVJLhwkbWz39x0ZpRyHhhI
	iDaH9TFqNTx9SSCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 05AD3133F6;
	Thu,  5 Nov 2026 12:36:32 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id AKP0Nk947Go1MAAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 05 Nov 2026 12:36:32 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 9532FB6E6; Thu, 05 Nov 2026 13:36:31 +0100 (CET)
Date: Thu, 5 Nov 2026 13:36:31 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Eric Dumazet <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
	Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
	Greg Kroah-Hartman <gregkh@suse.de>, Joel Granados <joel.granados@kernel.org>, 
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	netdev@vger.kernel.org, ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
	coreteam@netfilter.org, kexec@lists.infradead.org, linux-pci@vger.kernel.org, 
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
	ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org, 
	linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
	sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, 
	linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net, 
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH RFC 37/38] proc: don't pin a symlink's entry while
 readlink() copies it out
Message-ID: <krgvwwpug6brspfpubssohr6cknwd2wtkrxo6uqaoalfi2ay4v@3dtbsctwca3n>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-37-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-37-59422ed3e465@kernel.org>
X-Spamd-Result: default: False [-11.51 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	MIME_TRACE(0.00)[0:+];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	FROM_HAS_DN(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	R_RATELIMIT(0.00)[to_ip_from(RLpnapcpkwxdkc5mopt1ezhhna)];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_GT_50(0.00)[60];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,suse.cz:dkim,suse.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -11.51
X-Spam-Level: 
X-Rspamd-Queue-Id: 2C5F621E5A

On Mon 02-11-26 15:43:28, Christian Brauner wrote:
> proc_get_link() pins the entry with use_pde() and the delayed call
> unpins it. vfs_readlink() copies the link to userspace in between. So a
> page fault in that copy holds up remove_proc_entry() just like the
> copies of reads and writes do, and the callers hold locks while they
> wait. /proc/asound/<id> is removed with snd_card_mutex and info_mutex
> held when a card changes its id.
> 
> The pin doesn't keep anything alive. proc_symlink() copies the target
> and pde_free() frees it with the entry, and the inode holds a reference
> to the entry. What the pin does is keep a removed symlink from being
> followed. So check ->in_use instead and drop the delayed call. That
> also takes an atomic pair off every traversal of /proc/net and
> /proc/mounts.
> 
> Fixes: 7e0e953bb0cf ("procfs: fix race between symlink removals and traversals")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/inode.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index 9933f03ab9fb..2d65f3c8ec03 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -629,19 +629,19 @@ static const struct file_operations proc_iter_file_ops_compat = {
>  };
>  #endif
>  
> -static void proc_put_link(void *p)
> -{
> -	unuse_pde(p);
> -}
> -
>  static const char *proc_get_link(struct dentry *dentry,
>  				 struct inode *inode,
>  				 struct delayed_call *done)
>  {
>  	struct proc_dir_entry *pde = PDE(inode);
> -	if (!use_pde(pde))
> +
> +	/*
> +	 * No pin. The link lives with the entry, which the inode holds, and a
> +	 * reader could fault while vfs_readlink() copies it out. Just don't
> +	 * follow a removed one.
> +	 */
> +	if (unlikely(atomic_read(&pde->in_use) < 0))
>  		return ERR_PTR(-EINVAL);
> -	set_delayed_call(done, proc_put_link, pde);
>  	return pde->data;
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
