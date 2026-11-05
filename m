Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793878887;
	b=kAcLaNmr9OowEUuKY34K7bElUicRgl0Z8aPEgJOlGUrWQ4Q5ywX4JZQqNUgQe6S1Wtez
	 EWteHWF39iF8mDnZRXR9FLcxPZ85mQCY8VG55/8yo+cblxARqj7DF4Vl7atqY/jTCPObM
	 g2sndOfLquoVQmVu3hFWblnuCKI/DNNP54LtPrk9Yjop4l4jx3kWi21Npe7wBc13reSjL
	 YXsuZJMM5J+lpnf/RZZGSNTsRiDjs/pO4xxordlxhf7nQjR8fZrPDObXaecmvQQozWj9y
	 THbzJM8xGrI0yYRIVs4SfOP2otV3bJDnkqv5OuEwkYlImIRdK8TVdTt2uO2ru/zgZ6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793878887;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=lCeU7WqtPlFL0u28tAWE4TptrCsWoJqXXac/H5Y8UUQ=;
	b=mMZmgQgfX21J7V70Ucr/ox5EmRmv+mbtU853kjdKat9y8t02a4tXzPcQ1vpUuRSc7Zet
	 ZgiwL0QCdX6D2KRk5SfdDvtayJPo0cnnXwv0DJOCLTPfVmLmVQO1zp3oC942caCaecRqg
	 4VDw4l66QWAiKl5uzrfLgT950MCqHS+OJGkvph3BTYMta7hTHzNR+5BvNgHTjtJIB3CBv
	 ffd9vZDroVEJcKRFEgeRZ+2GS5VFub1VqazP+zYpSwOcKvGWsiDk863y6abkwc5WbfRAF
	 +Eyg492oY36Q6daxl3EVBYdCphMo1MywWWZ4iqHG0LKgaNJ38o7HYXHADrqOsiOwpng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sVeVtJRH;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vuwkzsBE;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sVeVtJRH;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vuwkzsBE;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE8AC606A328;
	Thu,  5 Nov 2026 11:41:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DE8AC606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sVeVtJRH;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vuwkzsBE;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sVeVtJRH;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vuwkzsBE
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 0FD6521EC6;
	Thu,  5 Nov 2026 11:41:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793878885; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lCeU7WqtPlFL0u28tAWE4TptrCsWoJqXXac/H5Y8UUQ=;
	b=sVeVtJRHmCez1LTgkgxlC7ymMIoqBUxHEcpbPuiTw+LbDT4oPlHADz2Nup5Y4XkVnbVoDk
	it5vmGnaVZfno1DYDqX11TE+/cZqz+5DBii4SNDMZd47SSrwV/j/qOrqaptU0Cbv8IOz2R
	SNKUKTm79wLZzIjQ8Z0k9Nr+vLNViV0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793878885;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lCeU7WqtPlFL0u28tAWE4TptrCsWoJqXXac/H5Y8UUQ=;
	b=vuwkzsBEcCG36qlub78Ir05oWJttjLgL1QqDCsASqboi7pG0u6LKGZy4KCtzu9Qqsj7mam
	/axyOJZeWj8zunDA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793878885; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lCeU7WqtPlFL0u28tAWE4TptrCsWoJqXXac/H5Y8UUQ=;
	b=sVeVtJRHmCez1LTgkgxlC7ymMIoqBUxHEcpbPuiTw+LbDT4oPlHADz2Nup5Y4XkVnbVoDk
	it5vmGnaVZfno1DYDqX11TE+/cZqz+5DBii4SNDMZd47SSrwV/j/qOrqaptU0Cbv8IOz2R
	SNKUKTm79wLZzIjQ8Z0k9Nr+vLNViV0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793878885;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lCeU7WqtPlFL0u28tAWE4TptrCsWoJqXXac/H5Y8UUQ=;
	b=vuwkzsBEcCG36qlub78Ir05oWJttjLgL1QqDCsASqboi7pG0u6LKGZy4KCtzu9Qqsj7mam
	/axyOJZeWj8zunDA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C5448134F4;
	Thu,  5 Nov 2026 11:41:24 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id CwQAKmRr7Go1dQAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 05 Nov 2026 11:41:24 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 60CBBB6BA; Thu, 05 Nov 2026 12:41:20 +0100 (CET)
Date: Thu, 5 Nov 2026 12:41:20 +0100
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
Subject: Re: [PATCH RFC 16/38] proc: don't walk through a non-directory when
 resolving a name
Message-ID: <xhnd2xzehnh35nmgphm2euuyulbwoz2fbxf7zmfn3hvdbcualr@ltehycoskzll>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-16-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-16-59422ed3e465@kernel.org>
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
X-Spam-Level: 
X-Spam-Flag: NO

On Mon 02-11-26 15:21:31, Christian Brauner wrote:
> __xlate_proc_name() walks the components of a name like "a/b/c" and
> takes whatever it finds for "a" and "b" as the directory to go on in.
> It never checks that they actually are directories. So
> proc_create("file/x") hangs x into the subdir tree of the regular file
> "file". Nobody can look x up there, but remove_proc_subtree() on the
> file removes and frees x along with it, behind the back of whoever
> registered x.
> 
> pktgen passes the name the writer of "add_device" picks to
> proc_create_data(), and only the part in front of the '@' has to name
> a network device:
> 
>   echo "add_device lo@"   > /proc/net/pktgen/kpktgend_0
>   echo "add_device lo@/x" > /proc/net/pktgen/kpktgend_1
>   echo "rem_device_all"   > /proc/net/pktgen/kpktgend_0
>   echo "rem_device_all"   > /proc/net/pktgen/kpktgend_1
> 
> The third write frees both entries and the fourth one makes kpktgend_1
> call proc_remove() on the freed second one:
> 
>   BUG: KASAN: slab-use-after-free in proc_remove+0x8f/0xa0
>   Read of size 8 at addr ff110001134c8e70 by task kpktgend_1/243
>   Call Trace:
>    proc_remove+0x8f/0xa0
>    pktgen_remove_device.isra.0+0x118/0x500
>    pktgen_rem_all_ifs+0xeb/0x1a0
>    pktgen_thread_worker+0x1b42/0x7280
> 
> The files of a network namespace belong to the root of its user
> namespace and these writes don't require a capability. So once pktgen
> is loaded an unprivileged user can do this in namespaces of its own.
> 
> Treat a component that isn't a directory like one that doesn't exist.
> All names with a '/' that the tree passes in as literals only walk
> through directories. pktgen is fixed separately to not pass such names
> in the first place.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/generic.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index 2b1971da4a85..c560c96a64eb 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -170,7 +170,7 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,
>  	de = *ret ?: &proc_root;
>  	while ((next = strchr(cp, '/')) != NULL) {
>  		de = pde_subdir_find(de, cp, next - cp);
> -		if (!de) {
> +		if (!de || !S_ISDIR(de->mode)) {
>  			WARN(1, "name '%s'\n", name);
>  			return -ENOENT;
>  		}
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
