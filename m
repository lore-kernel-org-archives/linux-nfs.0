Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793881272;
	b=GrOilbdOtQpmJCYD6zNmiS8orXdDCEPoLswcwsVKFmSMBHUFfgJ83MKwydAZbT+lDwWw
	 0RxnFaDbR1CuBVCjNeWq5gmZ/y6jjjqSWAZGAB6bmNAbZM7loOCi9gyI4dSY+mJnf+ruT
	 wu6qKyYCINgXMiL3XoKxQ0+O19cvrlrl/ctLY61I8qZSUoh2wShoW3DuGO7I9Ha6oSigs
	 RhK0e+sp6plgZdoFbG9q01qRI/f3USNwedPGEVqWo5BOm9077E6dW/nOcevnFwJkuD2e2
	 AAiFVGo3uvfCs0/15sU1m53Em8TZYZdKyHQrGTAkUE+wzJJm8lCUL/ztXF0i1XNdTyQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793881272;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:
	 X-Spam-Flag:X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=qLuvYgtpasAKkOVBQjswAHWXysKN7cRsF9p74hK2S2g=;
	b=x8A8egmCVprwVmaP6TKoEbHQSkWxE7ch1EwooTyriKIl4Byn10U6dVfI31J0M0vyMVwg
	 qLpuzorHjFoCa6kXdaBvvvxBhDZxoX8SfBwT+V53TkzXUdgEFhf2vGkbSc2UnWGeTuY8h
	 ToOtyAispZrhKd+j4kZhaqCswWDLrgX3QGj0CgEEfUTy/sSXEHl5xUp9amYpTbarkLOSN
	 xwDg+HMMuDuB47QutlciT58uDhygQ27wCgK0ZgI/OhusTpi5DZaEOXkbAqCiBkV18p4GY
	 yccKCnhR5L/S7QNi/EbNSKWPbvB/fAMPIk1XyzTrQYZwO9nen/Bv6wZN0EZdLXc5RpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KhcIIhhy;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6n5z2yLa;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=TFuQlAZ+;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=IYRGa8XW;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C93B4606D804;
	Thu,  5 Nov 2026 12:21:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C93B4606D804
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KhcIIhhy;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=6n5z2yLa;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=TFuQlAZ+;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=IYRGa8XW
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id D5C3D1F458;
	Thu,  5 Nov 2026 12:21:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793881270; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qLuvYgtpasAKkOVBQjswAHWXysKN7cRsF9p74hK2S2g=;
	b=KhcIIhhyXURXrxsFKNrS5/KQBWOxVAoWljoB38cQtiYrDrFV8sed3xw/zXNPMim53TtxIA
	7ZbhM5diXv9jAcO7L3DVJNrAZi+K4lsRTnJWaMYMlYugOK16bRU+y/fGzxnSLhmlcVsvyG
	csbL8slrND45GD1FIeOECoj0f7hJMwQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793881270;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qLuvYgtpasAKkOVBQjswAHWXysKN7cRsF9p74hK2S2g=;
	b=6n5z2yLaHgAEN7/Tcd0WzA7lHAxJSKkismyyu/ILXPkdtd7h0WOyyJxNx+8962qMQ9rlAn
	/2Drg5p7a9P7WmBA==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=TFuQlAZ+;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=IYRGa8XW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793881269; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qLuvYgtpasAKkOVBQjswAHWXysKN7cRsF9p74hK2S2g=;
	b=TFuQlAZ+5WF2YAdSPtrseTWbdG8rKLEqW19DJvUMZa96SoqlsHphdrzQTVaeQPeOfbKMve
	vRvg45whLPGgBVqZinymhyPdhVasORALEjL7ZX6GmXX/o3Zhkt8KhhIcC5N1tdRheYHdXR
	b1H4KWKbL93llPPXVmqHJ4S/SUjD100=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793881269;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qLuvYgtpasAKkOVBQjswAHWXysKN7cRsF9p74hK2S2g=;
	b=IYRGa8XWDYOBq7+hiG0V0rUlmwe1TyUTdwZG614Lw3QLxr1E6xwKO0uuM9xtMm5Wn4Th8n
	Jk1SsJkUbIlOijDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 9880B133F6;
	Thu,  5 Nov 2026 12:21:09 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 38udGrV07Gp0IAAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 05 Nov 2026 12:21:09 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 1B713B6D8; Thu, 05 Nov 2026 13:21:05 +0100 (CET)
Date: Thu, 5 Nov 2026 13:21:05 +0100
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
Subject: Re: [PATCH RFC 33/38] proc: sysctl: copy to and from userspace
 without holding the table
Message-ID: <cbocsd4qe254dc7mgzk3jkieahrp5kfxpnfh5owopkulg5oo6l@jd5sw3l4nw5c>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-33-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-33-59422ed3e465@kernel.org>
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
	RCVD_TLS_LAST(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCVD_COUNT_THREE(0.00)[3];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FROM_HAS_DN(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	R_RATELIMIT(0.00)[to_ip_from(RLpnapcpkwxdkc5mopt1ezhhna)];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_GT_50(0.00)[60];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:email,suse.cz:dkim]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -11.51
X-Spam-Level: 
X-Rspamd-Queue-Id: D5C3D1F458

On Mon 02-11-26 15:21:48, Christian Brauner wrote:
> proc_sys_call_handler() grabs the table, copies in what is written,
> calls the handler and copies what it produced out to userspace before
> it lets go of the table again. Unregistering a table waits until nobody
> uses it anymore. So a reader or writer whose copy faults for as long as
> it wants, with userfaultfd or a stalled FUSE mapping, keeps
> unregister_sysctl_table() waiting, and its callers like to hold locks
> while they do that. addrconf unregisters the ipv6 sysctls of a device
> with RTNL held, so a stalled read of /proc/sys/net/ipv6/conf/<dev>/mtu
> holds up every RTNL user until the reader gives up.
> 
> Copy in before grabbing the table and copy out after letting go of it,
> like procfs and kernfs do for their files. The buffer is ours, nothing
> needs the table for the copies.
> 
> That moves the allocation and the copy in before the permission check.
> A write that can't be copied in, or a request that is too large, now
> fails with -EFAULT or -ENOMEM where it used to fail with -EPERM.
> 
> Fixes: 330d57fb98a9 ("[PATCH] Fix sysctl unregistration oops (CVE-2005-2709)")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/proc_sysctl.c | 50 ++++++++++++++++++++++++++++----------------------
>  1 file changed, 28 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index 38b61887b59c..2150cf842919 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -602,14 +602,36 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
>  		int write)
>  {
>  	struct inode *inode = file_inode(iocb->ki_filp);
> -	struct ctl_table_header *head = grab_header(inode);
>  	const struct ctl_table *table = PROC_I(inode)->sysctl_entry;
> +	struct ctl_table_header *head;
>  	size_t count = iov_iter_count(iter);
>  	char *kbuf;
>  	ssize_t error;
>  
> -	if (IS_ERR(head))
> -		return PTR_ERR(head);
> +	/* don't even try if the size is too large */
> +	if (count >= KMALLOC_MAX_SIZE)
> +		return -ENOMEM;
> +	kbuf = kvzalloc(count + 1, GFP_KERNEL);
> +	if (!kbuf)
> +		return -ENOMEM;
> +
> +	/*
> +	 * Copy in before grabbing the table and copy out after letting go of
> +	 * it. Unregistering the table waits for us and a copy that faults can
> +	 * take as long as userspace wants.
> +	 */
> +	if (write) {
> +		error = -EFAULT;
> +		if (!copy_from_iter_full(kbuf, count, iter))
> +			goto out_free_buf;
> +		kbuf[count] = '\0';
> +	}
> +
> +	head = grab_header(inode);
> +	if (IS_ERR(head)) {
> +		error = PTR_ERR(head);
> +		goto out_free_buf;
> +	}
>  
>  	/*
>  	 * At this point we know that the sysctl was not unregistered
> @@ -624,28 +646,15 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
>  	if (!table->proc_handler)
>  		goto out;
>  
> -	/* don't even try if the size is too large */
> -	error = -ENOMEM;
> -	if (count >= KMALLOC_MAX_SIZE)
> -		goto out;
> -	kbuf = kvzalloc(count + 1, GFP_KERNEL);
> -	if (!kbuf)
> -		goto out;
> -
> -	if (write) {
> -		error = -EFAULT;
> -		if (!copy_from_iter_full(kbuf, count, iter))
> -			goto out_free_buf;
> -		kbuf[count] = '\0';
> -	}
> -
>  	error = BPF_CGROUP_RUN_PROG_SYSCTL(head, table, write, &kbuf, &count,
>  					   &iocb->ki_pos);
>  	if (error)
> -		goto out_free_buf;
> +		goto out;
>  
>  	/* careful: calling conventions are nasty here */
>  	error = table->proc_handler(table, write, kbuf, &count, &iocb->ki_pos);
> +out:
> +	sysctl_head_finish(head);
>  	if (error)
>  		goto out_free_buf;
>  
> @@ -658,9 +667,6 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
>  	error = count;
>  out_free_buf:
>  	kvfree(kbuf);
> -out:
> -	sysctl_head_finish(head);
> -
>  	return error;
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
