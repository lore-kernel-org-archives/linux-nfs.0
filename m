Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793880502;
	b=tSRjzOOcLpqIDmWoYPTS9j9y4S4P2KBHkY3KhZHd9DmZPek3EbS04UWCTv6+BncIDYSp
	 enLVLeHStrlC5g1IdwXB9BPV2N4h8VJWFvLo0ehrmxUQV0zhLO3thjUG1B4dopay2IqLI
	 koGmSSPS6tQMz3Xpbx9GyOVmcvDRZmE2FT45m+GwSfxLa/3nE8nPg1sqyLkksuy04mGaP
	 95Chgf3zMKsWOxELiYk0oCvAITSziv076Yv0aM9rBSLJNBmEZrzoEOcHtGMB6nSMaLHRs
	 IHEwy6D3STSeEYSJz6kdwHy4AhT5aiKio2rAE4e//crH/oSKK7r6QYvRhL77XwCtfZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793880502;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=+AscXsLOMvfsFvCViguJi+L1fCFKAfWK/UhUpwog254=;
	b=UsvuFWr0/DtAebETQrgle4XjF8vwhtM1PLLbqEsxDuV0c3FMiTAFhLq0GMvySGkA4YT3
	 qIUlF38SOJHadPonVmU4ggJ30F5/Kb9RFosv27SL++VUB69Rn1tKTSx3KUUJTs+jzYRAm
	 G3YAW0sJhhHo84+jLUPmL6dJQ/WzYGtLvU2f5zfJgVHMnDgiy5lMyIqXbPouglFE8kHWr
	 2yaILWLqYU5OV4hPs+SzG3GwxwpGqjcuAtc5IhHM/A4HKamhnVDeNBycQl/Tzkgesvtjo
	 juMAxY++4zYYyWdOTKboJ6C3cEeO39pNXCieG6BICNe/1waVnyJt+KT0DH2fyQwMV6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=duEJD6LP;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nEuQ44sk;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=muH5tH8X;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="Twh/XSEi";
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C006D606A31B;
	Thu,  5 Nov 2026 12:08:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C006D606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=duEJD6LP;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=nEuQ44sk;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=muH5tH8X;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Twh/XSEi
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id E09301F7A8;
	Thu,  5 Nov 2026 12:08:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793880500; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+AscXsLOMvfsFvCViguJi+L1fCFKAfWK/UhUpwog254=;
	b=duEJD6LPekOEhn61R53kKb81GPHaXPGJIngKUTQX9WEfL8ykFAMPfmr3OERdgYmnfr5bEr
	no/QUoCTwr2IM6pfVyWZvbGB+kH7jg6VMI0t/BL5piRkhHqFijSOo3qTB/uJ7xYzQrEyBs
	gOFq7XIKvrhTvOnsUSKrNoDYiDAIbok=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793880500;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+AscXsLOMvfsFvCViguJi+L1fCFKAfWK/UhUpwog254=;
	b=nEuQ44skKENyJxG2nI0WEya/Z6UeAf8j7o1gUA14jvXxD5ttTBDmJR+hSpD3AjkE27erIs
	22RVTyoAXPvvBVDA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793880499; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+AscXsLOMvfsFvCViguJi+L1fCFKAfWK/UhUpwog254=;
	b=muH5tH8XGabU7XsT+4HLUn0YWyclJMbdrP8YC6jbblzcOUCNg6bIn+AZUHE8jVHVN8jliF
	hdBtv4Gwr4LOd7CEkfIcFH+Z/XWj4sxlIWVLYY8yjERT78lqpfyk0ziLE47S7PXtNzHXyJ
	8uq8NljKVjD/sxwntTPUE8trLhX/m8Y=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793880499;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+AscXsLOMvfsFvCViguJi+L1fCFKAfWK/UhUpwog254=;
	b=Twh/XSEinlJ2UHBYu888sP3yxbsAvwQL1/rVLh+t/1fyMiI6SbhSYK2ev17aVQ6HLXKdNo
	dDP1A3DjZ6h02FAg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id AC4C6134F4;
	Thu,  5 Nov 2026 12:08:19 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id LbztIbNx7GrJEgAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 05 Nov 2026 12:08:19 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 3E083B6CC; Thu, 05 Nov 2026 13:08:15 +0100 (CET)
Date: Thu, 5 Nov 2026 13:08:15 +0100
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
Subject: Re: [PATCH RFC 21/38] proc: let proc_remove() remove the entry it
 was given
Message-ID: <4woxjrofo67qve236jz54znbp74hk34ouesbpgh46g5lfb7bwn@v7dnw5ixlgff>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-21-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-21-59422ed3e465@kernel.org>
X-Spamd-Result: default: False [-11.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:email];
	RCVD_COUNT_THREE(0.00)[3];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL63fqwwx8ot6gmekemcs76f9d)];
	MISSING_XM_UA(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCPT_COUNT_GT_50(0.00)[59];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -11.30
X-Spam-Level: 
X-Spam-Flag: NO

On Mon 02-11-26 15:21:36, Christian Brauner wrote:
> proc_remove() looks the entry up by its name in its parent and removes
> whatever it finds there:
> 
>   remove_proc_subtree(de->name, de->parent);
> 
> If the entry was removed already, say along with its parent, that is
> either nothing or a different entry that got the same name in the
> meantime, and de->parent may well be gone. Two removals of the same
> entry are a bug in the caller, but going by the name turns it into
> removing an entry that belongs to somebody else.
> 
> Since commit 895b4c0c79b0 ("fs/proc: fix uaf in proc_readdir_de()")
> an entry that was unlinked has an empty rb node. So check for that
> under proc_subdir_lock and otherwise remove the entry itself, with the
> loop of remove_proc_subtree() moved into a helper both of them use.
> Nothing can help a caller that passes an entry that has been freed
> already.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: a8ca16ea7b0a ("proc: Supply a function to remove a proc entry by PDE")
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

One nitpick below. Otherwise feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

> -int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
> +/*
> + * Remove @root, already erased from its parent, and everything below it.
> + * Called with proc_subdir_lock held for writing, returns with it dropped.
> + */
> +static int __remove_proc_subtree(struct proc_dir_entry *root)
>  {
> -	struct proc_dir_entry *root = NULL, *de, *next;
> -	const char *fn = name;
> -	unsigned int len;
> -
> -	write_lock(&proc_subdir_lock);
> -	if (__xlate_proc_name(name, &parent, &fn) != 0) {
> -		write_unlock(&proc_subdir_lock);
> -		return -ENOENT;
> -	}
> -	len = strlen(fn);
> +	struct proc_dir_entry *de = root, *next;
>  
> -	root = pde_subdir_find(parent, fn, len);
> -	if (!root) {
> -		write_unlock(&proc_subdir_lock);
> -		return -ENOENT;
> -	}
> -	if (unlikely(pde_is_permanent(root))) {
> -		write_unlock(&proc_subdir_lock);
> -		WARN(1, "removing permanent /proc entry '%s/%s'",
> -			root->parent->name, root->name);
> -		return -EINVAL;
> -	}
> -	pde_erase(root, parent);
> -
> -	de = root;
>  	while (1) {
>  		next = pde_subdir_first(de);
>  		if (next) {
> @@ -871,6 +852,34 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
>  	pde_put(root);
>  	return 0;
>  }
> +
> +int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
> +{
> +	struct proc_dir_entry *root = NULL;
> +	const char *fn = name;
> +	unsigned int len;
> +
> +	write_lock(&proc_subdir_lock);
> +	if (__xlate_proc_name(name, &parent, &fn) != 0) {
> +		write_unlock(&proc_subdir_lock);
> +		return -ENOENT;
> +	}
> +	len = strlen(fn);
> +
> +	root = pde_subdir_find(parent, fn, len);
> +	if (!root) {
> +		write_unlock(&proc_subdir_lock);
> +		return -ENOENT;
> +	}
> +	if (unlikely(pde_is_permanent(root))) {
> +		write_unlock(&proc_subdir_lock);
> +		WARN(1, "removing permanent /proc entry '%s/%s'",
> +			root->parent->name, root->name);
> +		return -EINVAL;
> +	}
> +	pde_erase(root, parent);
> +	return __remove_proc_subtree(root);
> +}
>  EXPORT_SYMBOL(remove_proc_subtree);
>  
>  void *proc_get_parent_data(const struct inode *inode)
> @@ -882,8 +891,23 @@ EXPORT_SYMBOL_GPL(proc_get_parent_data);
>  
>  void proc_remove(struct proc_dir_entry *de)
>  {
> -	if (de)
> -		remove_proc_subtree(de->name, de->parent);
> +	if (!de)
> +		return;
> +
> +	write_lock(&proc_subdir_lock);
> +	/* Removed already, maybe along with its parent. */
> +	if (RB_EMPTY_NODE(&de->subdir_node)) {
> +		write_unlock(&proc_subdir_lock);
> +		return;
> +	}
> +	if (unlikely(pde_is_permanent(de))) {
> +		write_unlock(&proc_subdir_lock);
> +		WARN(1, "removing permanent /proc entry '%s/%s'",
> +		     de->parent->name, de->name);
> +		return;
> +	}
> +	pde_erase(de, de->parent);
> +	__remove_proc_subtree(de);

I'd move the RB_EMPTY_NODE() and pde_is_permanent() along with pde_erase()
call back to __remove_proc_subtree(). Both callers need them (so it is
unnecessary duplication) and also logically it makes sense there.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
