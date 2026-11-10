Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794321680;
	b=qamPRb65Cqu+k96KhgXpo+aozC1EFRDV4zuOlQNzvB0gW6T1KfzDp2KEWB/Q9yGrlUSk
	 E4Q5hpmQ8zQsAdYxbDlRJSyQQUiKZmzdwctoLyKDmKb+qogTH0hZVRE6siazxEmyTBk35
	 zyqfklAJXKK6MTmAsKkt+vgXO9FaqIxXOaSob0HBeLlTYThCatVL3YvLNk6GDoSH94Ypw
	 N6qH5CSYyH9haefnNVhwLpoJZ+LU726GgbsOhevIvUGFVCxBsFHFapzFnmovXr00WowNF
	 Ff8bryIu0jXU0tRTn2ZOweeKr3aVI5bsAMZXp4occj3RRhRVa41yGqm3yA7derCE3rw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794321680;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=n9Z1w4YYO/lfKbwO0/Zyyv0ODPBk2vg1/mG8PGnweiw=;
	b=ayY+DLL+3Mmi5q7xXGhHt+NDjdRyAjKHKsBaWXf4cT+6l1gw5GCnRFE+6+dxneRSycQd
	 wlsQt/c4C2TNFrNCYT138VG1WxdBsnMniv/LmA1nBqr1XLJRJwTcpZ0MHj4FOD7n7Kr7V
	 tH1+1FSKvU2vy4d+TKe1Jjjk/qD3lD6sdqUcqlYVSErYiu7QangpkYT8eTPjMCKMa1AFq
	 ukEL/AmQCWaXjQiAjiO8rugpE1TemTKBll4Dxnn+Ji4aQGswTLRkZeYXOKGpb9uqdx4k3
	 XIV30G9m8CtaXU5jxMXlgpMxBuiB/gCL0lqA7yrtk6Hi7COMn/rZAX7/9HRVTDRgxdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zgDVyhh8;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=369eyxEs;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zgDVyhh8;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=369eyxEs;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38B7C60A262B;
	Tue, 10 Nov 2026 14:41:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 38B7C60A262B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zgDVyhh8;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=369eyxEs;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zgDVyhh8;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=369eyxEs
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 5C15521EA9;
	Tue, 10 Nov 2026 14:41:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321678; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=n9Z1w4YYO/lfKbwO0/Zyyv0ODPBk2vg1/mG8PGnweiw=;
	b=zgDVyhh8pCYegE1kzm5xIANNPglMEgeuZuIQhodg3Iqv/wmt77lmYCRPxvkovOojFne6ow
	xYY18x6DlFzq3ln+FuD7YcKaRbr9DnDPAC2XyRl48GG8goA6gsBhUKpVrrgGwTQE9D6lAy
	YLWLP+bL+HAY3ZU8JGWkN/YRjQArPjo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321678;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=n9Z1w4YYO/lfKbwO0/Zyyv0ODPBk2vg1/mG8PGnweiw=;
	b=369eyxEsAFmpmDiuBidhIEN7pEn7fzlKO8/ywBH2pvsXDNxLEXvezP0hQQ7rW/b6nD06GK
	hdXtKW5t/c3G3NDw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=zgDVyhh8;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=369eyxEs
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321678; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=n9Z1w4YYO/lfKbwO0/Zyyv0ODPBk2vg1/mG8PGnweiw=;
	b=zgDVyhh8pCYegE1kzm5xIANNPglMEgeuZuIQhodg3Iqv/wmt77lmYCRPxvkovOojFne6ow
	xYY18x6DlFzq3ln+FuD7YcKaRbr9DnDPAC2XyRl48GG8goA6gsBhUKpVrrgGwTQE9D6lAy
	YLWLP+bL+HAY3ZU8JGWkN/YRjQArPjo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321678;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=n9Z1w4YYO/lfKbwO0/Zyyv0ODPBk2vg1/mG8PGnweiw=;
	b=369eyxEsAFmpmDiuBidhIEN7pEn7fzlKO8/ywBH2pvsXDNxLEXvezP0hQQ7rW/b6nD06GK
	hdXtKW5t/c3G3NDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0C9731339F;
	Tue, 10 Nov 2026 14:41:18 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id HT40MQ0t82qpMQAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 14:41:18 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id EF45D2254C; Tue, 10 Nov 2026 15:41:12 +0100 (CET)
Date: Tue, 10 Nov 2026 15:41:12 +0100
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
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH v2 35/51] proc: warn about entries left in /proc/net of a
 dying namespace
Message-ID: <redzyadnsedot7ckkbzf5wi3zqlwtujbbupudri6riwxxt3hka@w32wugbs5mdf>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
 <20261104-work-procfs-bugfixes-v2-35-bbf7d5546809@kernel.org>
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
In-Reply-To: <20261104-work-procfs-bugfixes-v2-35-bbf7d5546809@kernel.org>
X-Rspamd-Queue-Id: 5C15521EA9
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
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
	RCPT_COUNT_GT_50(0.00)[59];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:dkim,suse.cz:email]
X-Spam-Score: -11.51

On Wed 04-11-26 18:47:21, Christian Brauner wrote:
> proc_net_ns_exit() runs after all the other pernet exits and frees
> net->proc_net right after removing "stat" from it. An entry that some
> pernet exit forgot to remove is left with a freed ->parent, and so
> PDE_NET() hands seq_open_net() and single_open_net() a freed struct net
> when the entry is opened through a file descriptor that someone kept.
> 
> There is no such entry in the tree that we know of, but nothing would
> tell us about one either. So warn about it like remove_proc_entry()
> does for a directory that isn't empty.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: e9720acd728a ("[NET]: Make /proc/net a symlink on /proc/self/net (v3)")
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Makes sense. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/proc_net.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index dbcf87a257e1..df5484813d5d 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -410,7 +410,13 @@ out:
>  
>  static __net_exit void proc_net_ns_exit(struct net *net)
>  {
> +	struct proc_dir_entry *left;
> +
>  	remove_proc_entry("stat", net->proc_net);
> +	/* Whatever is left still points at net->proc_net and so at net. */
> +	left = rb_entry_safe(rb_first(&net->proc_net->subdir),
> +			     struct proc_dir_entry, subdir_node);
> +	WARN(left, "/proc/net: leaking at least '%s'\n", left->name);
>  	pde_free(net->proc_net);
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
