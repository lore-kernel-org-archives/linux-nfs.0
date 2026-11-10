Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794321715;
	b=wYl4/BTMQnCuijeK87WVred2f952dv3aCzdRashVEobzk/CebnrfbttmO9j37QzRpgn4
	 jvM3fQL6/513Fv7CQxy985puNw0NhDJy19EH7FGKOkY3ypa+1QSTm4uMrWYTpyFLyd9JW
	 VeLgHkNkTPnlyabTJXt8f7S7VLF6yHJMy+9jyJ+0ZuYPXoqK3L42vDHCUPuUy6LvCySap
	 CRxYZfB8euxsiLluBOdqfPtrZ5SdkgQG/VI1/CkzJaADT8RP5/EujAo/xWo7Qd+qaSCNK
	 PRUYGR0qt15k65IhUz3c6ipt0q0B9SxpuVNhL17ia9wv9O8Q0rTJOstGugvhIAiZ4Cw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794321715;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=qDtnp52mCOLGIeKAoTkP/VE9bDmOCKAJNKVe/si6vCg=;
	b=kfqzpcnMzF18HLcCkV9wtVJf4bb26yzF6qhFdGhCFGgYEXQeEF71Ki+Bwfl9lovAF7KQ
	 TJ0h/mdebVcAJNWcWWosOqOXnad1OIFz6NJUM8n4Hv/KdSk0Ztwafhhc2wINCr7Tgr7Ee
	 q71TadvFHUsyXONJaiq35ouFwRL6oq/380LuBHzo0cJK2d5VWABdVJviY3bbIefWUIhaW
	 1/PAUTa7iP2OUNXkcuslJwKkzj6qc+9xW9H+olpk+NzdfkqosqSLojaM/V1d/hi2gKJfZ
	 sCWTlnyo3ZjpM2tN4uL61ZLN9XriwXwL46pPl5stMnB9w87NykaOcugPTAE9WWdmBfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KPH4ZA4O;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nAwA4w5o;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KPH4ZA4O;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nAwA4w5o;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C625660A263C;
	Tue, 10 Nov 2026 14:41:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C625660A263C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KPH4ZA4O;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nAwA4w5o;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KPH4ZA4O;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nAwA4w5o
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 1F9C621EF0;
	Tue, 10 Nov 2026 14:41:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321713; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qDtnp52mCOLGIeKAoTkP/VE9bDmOCKAJNKVe/si6vCg=;
	b=KPH4ZA4OCUNQteAlThJVSMdVv+b5CITqUYVDYv0DTYGBh3lYfp14gNkrIBhN3QW8TrZ5Zu
	8cw3fegXEqyg//sIFlGsygW3ZNppe5S6nwsQ0jNmzUxBYyv0WNVveJumfvFkFKzmvKemzb
	QpaqM/pVXZxp2ljdJnBPVJc1vEVX1cQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321713;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qDtnp52mCOLGIeKAoTkP/VE9bDmOCKAJNKVe/si6vCg=;
	b=nAwA4w5op91jEWjfS+enW+W0YGrrCz6iJT8kEaFIkP6kTQL1V7Xx/i770Qaf/dBHb75kNs
	cnRMKm7wWkaGMFCQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321713; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qDtnp52mCOLGIeKAoTkP/VE9bDmOCKAJNKVe/si6vCg=;
	b=KPH4ZA4OCUNQteAlThJVSMdVv+b5CITqUYVDYv0DTYGBh3lYfp14gNkrIBhN3QW8TrZ5Zu
	8cw3fegXEqyg//sIFlGsygW3ZNppe5S6nwsQ0jNmzUxBYyv0WNVveJumfvFkFKzmvKemzb
	QpaqM/pVXZxp2ljdJnBPVJc1vEVX1cQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321713;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qDtnp52mCOLGIeKAoTkP/VE9bDmOCKAJNKVe/si6vCg=;
	b=nAwA4w5op91jEWjfS+enW+W0YGrrCz6iJT8kEaFIkP6kTQL1V7Xx/i770Qaf/dBHb75kNs
	cnRMKm7wWkaGMFCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id EE948134F4;
	Tue, 10 Nov 2026 14:41:52 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id jkRDMDAt82pyMgAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 14:41:52 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 80FD72254E; Tue, 10 Nov 2026 15:41:48 +0100 (CET)
Date: Tue, 10 Nov 2026 15:41:48 +0100
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
Subject: Re: [PATCH v2 36/51] proc: don't let NOMMU map procfs files
Message-ID: <shez4l3sx2gonaj5peho6rtfckgiqom7cennfitxv34oceq4qf@csr6sjmey2yy>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
 <20261104-work-procfs-bugfixes-v2-36-bbf7d5546809@kernel.org>
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
In-Reply-To: <20261104-work-procfs-bugfixes-v2-36-bbf7d5546809@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-11.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL63fqwwx8ot6gmekemcs76f9d)];
	RCVD_TLS_LAST(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCPT_COUNT_GT_50(0.00)[60];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Score: -11.30

On Wed 04-11-26 18:47:22, Christian Brauner wrote:
> Every procfs file has a ->mmap since commit 786d7e1612f0 ("Fix
> rmmod/read/write races in /proc entries"), whether the entry has a
> ->proc_mmap or not. On NOMMU validate_mmap_request() takes that to mean
> the file can be mapped. procfs has no ->mmap_capabilities so a regular
> file gets NOMMU_MAP_COPY, and a private mapping never calls ->mmap at
> all. Instead do_mmap() takes nommu_region_sem for writing and
> do_mmap_private() reads the file into the copy with kernel_read().
> 
> Reading /proc/maps takes nommu_region_sem as well:
> 
>   mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, open("/proc/maps", O_RDONLY), 0)
> 
>   do_mmap()                          // down_write(&nommu_region_sem)
>   -> do_mmap_private()
>      -> kernel_read()
>         -> seq_read_iter()
>            -> nommu_region_list_start()   // down_read()
> 
> The task hangs for good, holding nommu_region_sem and its own mmap_lock,
> and every mmap(), munmap() and exit after that hangs behind it.
> /proc/maps is 0444 so any user can do that.
> 
> Give the procfs files a ->mmap_capabilities on NOMMU that allows
> nothing. That covers every entry and not just /proc/maps, procfs can't
> know which entry's read takes nommu_region_sem. Mapping a procfs file
> then fails with -ENODEV, like mapping a file without ->mmap did before
> 786d7e1612f0. NOMMU never called ->proc_mmap() for a regular file
> anyway, procfs never offered NOMMU_MAP_DIRECT.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: 786d7e1612f0 ("Fix rmmod/read/write races in /proc entries")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/inode.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index b7634f975d98..9933f03ab9fb 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -466,6 +466,18 @@ proc_reg_get_unmapped_area(struct file *file, unsigned long orig_addr,
>  	return rv;
>  }
>  
> +#ifndef CONFIG_MMU
> +/*
> + * NOMMU never calls ->proc_mmap() for a regular file. It reads the file into
> + * a private copy instead, with nommu_region_sem held for writing, which
> + * reading /proc/maps takes as well. Don't map procfs files at all.
> + */
> +static unsigned int proc_reg_mmap_capabilities(struct file *file)
> +{
> +	return 0;
> +}
> +#endif
> +
>  static int proc_reg_open(struct inode *inode, struct file *file)
>  {
>  	struct proc_dir_entry *pde = PDE(inode);
> @@ -559,6 +571,9 @@ static const struct file_operations proc_reg_file_ops = {
>  	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
>  	.mmap		= proc_reg_mmap,
>  	.get_unmapped_area = proc_reg_get_unmapped_area,
> +#ifndef CONFIG_MMU
> +	.mmap_capabilities = proc_reg_mmap_capabilities,
> +#endif
>  	.open		= proc_reg_open,
>  	.release	= proc_reg_release,
>  };
> @@ -572,6 +587,9 @@ static const struct file_operations proc_iter_file_ops = {
>  	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
>  	.mmap		= proc_reg_mmap,
>  	.get_unmapped_area = proc_reg_get_unmapped_area,
> +#ifndef CONFIG_MMU
> +	.mmap_capabilities = proc_reg_mmap_capabilities,
> +#endif
>  	.open		= proc_reg_open,
>  	.release	= proc_reg_release,
>  };
> @@ -586,6 +604,9 @@ static const struct file_operations proc_reg_file_ops_compat = {
>  	.compat_ioctl	= proc_reg_compat_ioctl,
>  	.mmap		= proc_reg_mmap,
>  	.get_unmapped_area = proc_reg_get_unmapped_area,
> +#ifndef CONFIG_MMU
> +	.mmap_capabilities = proc_reg_mmap_capabilities,
> +#endif
>  	.open		= proc_reg_open,
>  	.release	= proc_reg_release,
>  };
> @@ -600,6 +621,9 @@ static const struct file_operations proc_iter_file_ops_compat = {
>  	.compat_ioctl	= proc_reg_compat_ioctl,
>  	.mmap		= proc_reg_mmap,
>  	.get_unmapped_area = proc_reg_get_unmapped_area,
> +#ifndef CONFIG_MMU
> +	.mmap_capabilities = proc_reg_mmap_capabilities,
> +#endif
>  	.open		= proc_reg_open,
>  	.release	= proc_reg_release,
>  };
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
