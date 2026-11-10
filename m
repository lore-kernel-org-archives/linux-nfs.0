Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794321775;
	b=zKbYOyvbhRGJOow4z0dtREn9OUmACY2ZlhfN0TcamaRHjpyJoztC6/OIDEl1vzvFER5e
	 sVv64zKZNTGAKKkj4fwoMrP4oBXSJtqVq6MdTZ5zGw0g7hqYkLCJ7dbgj1gfTpitdY1EA
	 jsN/QrjWE5x48ucxVZ/+6MDPyCa12WMfpXWIdmlB2Xv/D+FAadMnPeHckCmBbbUraHGfU
	 IXT9oNk6Nj/LR+V7Oq7lBop39Sq/qbAV+JM+jwL9judk6srKrqWD7+O64suSK4ydqK3xa
	 VuiJrCbjMeXKom06rqZ6PKj5AKZYrfVig/l2oAStpVsQkDOhDv2eqBJoxLTqWv9v9QQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794321775;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=0B4qA1TkglN4OMx2OOtGC+4WxOgjbuwo6ZjpoXcLiI0=;
	b=3kRmgwTVV/T6acYbxPBtt5mu+bAM9FDK7j9zyJsUy6KTSW0lGShfCyZbT4ZMY/IfzKin
	 js/uTbCmeRyPcifM+G4aIhY/b1uTiUtQojshMvTWO1cdwgCJ/RAFRqN6DKktPKsnVRTgn
	 OW8Hb7XZ/KAZvLASVD92NdgqnOKf+rnyeTaixH11nB1C60UJ8virZTBUv7tXl4iHbYpFR
	 /B/htZXAYUb0r+XqHV2tKk4GFqGJU+NfK5Cez0kABoJPnISRNkpHEvkNr1rbsf/5qCGTq
	 aCThOyXTZY8qdUPFm3uyEimVGMcWwNpjLPI0ls6ku0Gu9LlOkH5ZIkPEidAdHtoMdEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="KX3USKj/";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/2pLOUfc";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="KX3USKj/";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/2pLOUfc";
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E75360A260D;
	Tue, 10 Nov 2026 14:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1E75360A260D
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KX3USKj/;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/2pLOUfc;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KX3USKj/;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/2pLOUfc
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 598A91F769;
	Tue, 10 Nov 2026 14:42:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321773; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=0B4qA1TkglN4OMx2OOtGC+4WxOgjbuwo6ZjpoXcLiI0=;
	b=KX3USKj/BuUCPazH8t3noRkhKvNyS5Vl2sfPRRfBrVBNp1j8KEsgjtdwoDEfs+Fi37nQ68
	vnsR7ycg2OeYqigI5LNHLalsHJ9KCDX9IcBSdyT+NAc3WsyWV3FKF78iAL2OBmuxWV0Xwz
	g2i8xSSiqPdjbp3ohRC0gvCg0kyAyjo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321773;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=0B4qA1TkglN4OMx2OOtGC+4WxOgjbuwo6ZjpoXcLiI0=;
	b=/2pLOUfcw4Ranr2A4Pwh/sC+sB848L9X9w962zn/48Fcdt+Sh4cEXY+LMMlgvMsVazsfNO
	Ql9bUyzc9/d9uBDA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794321773; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=0B4qA1TkglN4OMx2OOtGC+4WxOgjbuwo6ZjpoXcLiI0=;
	b=KX3USKj/BuUCPazH8t3noRkhKvNyS5Vl2sfPRRfBrVBNp1j8KEsgjtdwoDEfs+Fi37nQ68
	vnsR7ycg2OeYqigI5LNHLalsHJ9KCDX9IcBSdyT+NAc3WsyWV3FKF78iAL2OBmuxWV0Xwz
	g2i8xSSiqPdjbp3ohRC0gvCg0kyAyjo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794321773;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=0B4qA1TkglN4OMx2OOtGC+4WxOgjbuwo6ZjpoXcLiI0=;
	b=/2pLOUfcw4Ranr2A4Pwh/sC+sB848L9X9w962zn/48Fcdt+Sh4cEXY+LMMlgvMsVazsfNO
	Ql9bUyzc9/d9uBDA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 137DD1339F;
	Tue, 10 Nov 2026 14:42:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id pC/yM2wt82q8MwAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 14:42:53 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 7821722550; Tue, 10 Nov 2026 15:42:48 +0100 (CET)
Date: Tue, 10 Nov 2026 15:42:48 +0100
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
Subject: Re: [PATCH v2 37/51] proc/vmcore: don't let vmcore_cleanup() run
 twice at once
Message-ID: <q4w6yd2pk7g6uzqva7sivfusaavqfwsgh3f4m2y7lbp74dfgvr@unclx56ulwys>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
 <20261104-work-procfs-bugfixes-v2-37-bbf7d5546809@kernel.org>
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
In-Reply-To: <20261104-work-procfs-bugfixes-v2-37-bbf7d5546809@kernel.org>
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -11.30

On Wed 04-11-26 18:47:23, Christian Brauner wrote:
> vmcore_cleanup() has a single caller, fadump's release_mem_store() on
> powerpc. That checks fw_dump.dump_active without a lock and calls
> vmcore_cleanup() without one, and kernfs only serializes the writers of
> one open file. So two tasks that write to
> /sys/kernel/fadump/release_mem through different files run
> vmcore_cleanup() at the same time.
> 
> The first one removes /proc/vmcore and waits for its readers in
> proc_remove(). The second one finds the entry already unlinked, returns
> from proc_remove() right away and frees vmcore_list, the ELF headers
> and the device dumps while those readers still walk them. Or both of
> them free the same lists at once.
> 
> Serialize vmcore_cleanup() with a mutex of its own. It can't be
> vmcore_mutex, removing /proc/vmcore calls release_vmcore() which takes
> it. The second caller then finds nothing left to free.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: b500afff11f6 ("fadump: Invalidate registration and release reserved memory for general use.")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

A bit sad but OK. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/proc/vmcore.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 1fe70c4ecc54..ccb795b85509 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -1764,6 +1764,11 @@ fs_initcall(vmcore_init);
>  /* Cleanup function for vmcore module. */
>  void vmcore_cleanup(void)
>  {
> +	/* Not vmcore_mutex, removing /proc/vmcore calls release_vmcore(). */
> +	static DEFINE_MUTEX(vmcore_cleanup_mutex);
> +
> +	/* Two writers of fadump's release_mem can get here at once. */
> +	guard(mutex)(&vmcore_cleanup_mutex);
>  	if (proc_vmcore) {
>  		proc_remove(proc_vmcore);
>  		proc_vmcore = NULL;
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
