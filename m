Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794042019;
	b=e2fPw7Y2rRfKFAQfgwC5LjDb0RhR4W31LDr7IxSWb6hORKRWERUu+1WEtFOl92kMR+Zo
	 KghAG8ZirLzfM7O1gCouNZzUt68wkwJV6tgZ3db2UgMcM0W2QqUOf+0rU7XvntFCPDPTH
	 6DoYyeBDsdz0YtWcS2VHIGxLgZ5S5ulHoTuNVuDTsgWQczKtNgnwyeuE7JnG7oBfgc8bB
	 MRbq+6xUakG07XZz2ZBE9I5J17UE1f/LP2TegmIelH/wNPkqoa6dkh2qRke1qcsAe+adS
	 QjuLnrXh/kdciTOZEvHuYPlZFVJTgL6hxN2rk8dC6vB84lMaEuI+53+LWws/WsqcQwQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794042019;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:Message-ID:From:To:Cc:Subject:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:X-Spam-Flag:
	 X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=2pUKIrJSjwOPfwhHfcJFzwrup6gCdhbZ3XgMEjE3Sk8=;
	b=5D5/GGSofHUZCuwGhKeC7U+sxjjoltIbDqU/QjDFsQ2ceMBoFrfaSYU7jb/1Ur+pAwN2
	 4akgWSfdDrLoE000HVYCnn60RmiK0eCIHPypjyVxYdt8JNhTKiEIfkBfRVwH+MAFkhPND
	 ERS+RS4lfKADF/CttTLIpX8/Ad3MYi+RL+VPHI9LVJVgIz192TU4HV7DRen8mHy+lfBja
	 yqu//OkUoKd5MDeSIJZ0cSXHezE/3klqx2NGRqL9RhqqraIv/TIetiP7yEbkhA/FjOkMW
	 /MaRIhfGsrx4+1WO4ZDaqTZ+lEa3tvkeGgxoDgaZ1KojurV2QCO/cdhlAoO0t1CbQLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=AwkH5jyM;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=JTEoL3TZ;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=nvoaJ0mE;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=DZerp02L;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B62B6606A32D;
	Sat,  7 Nov 2026 09:00:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B62B6606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=AwkH5jyM;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=JTEoL3TZ;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=nvoaJ0mE;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=DZerp02L
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 630761F74D;
	Sat,  7 Nov 2026 09:00:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1794042016; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2pUKIrJSjwOPfwhHfcJFzwrup6gCdhbZ3XgMEjE3Sk8=;
	b=AwkH5jyM7t60XRGf7G1aRSt+1A3cbarzW4z/QkvISjLGNPrA/fY2MleEP5q/AQIm+UOa85
	wJkleCWTNZsU7rGkzPqgTOEFser1A2ESxcK9o91TyOKwj1NxwYRnab9MqOSmomM2duqzSM
	4ziRifDlEsg/eNGZ4IfRyZBtKF7+5L4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1794042016;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2pUKIrJSjwOPfwhHfcJFzwrup6gCdhbZ3XgMEjE3Sk8=;
	b=JTEoL3TZlb1DCclunsyxaCbXUYbLeMKEOnsS7PWO9bNheMA+zCRiSp1byJB7A+sAicRsv4
	5OXD2QVrenEMHmAQ==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=nvoaJ0mE;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=DZerp02L
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1794042015; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2pUKIrJSjwOPfwhHfcJFzwrup6gCdhbZ3XgMEjE3Sk8=;
	b=nvoaJ0mEP/zd/0bKFGcoiLmtApr9OQGHZOiEECFWhUq1H30dGD7ZkdmACOX8M4XQGS4NuW
	oB4Mc0g4OfzK2wWf0UF/9cqPMqA/oflypYavZBONS2BSNW+J/B7gdSUDzy/0qA9b4r1pv4
	UXAedxogQW7c2CJkDX8oa4Afmn/sre4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1794042015;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2pUKIrJSjwOPfwhHfcJFzwrup6gCdhbZ3XgMEjE3Sk8=;
	b=DZerp02LRPNT9d5/AecFdQdh+IJlOFhOxwpkpzQNy3DQvQ4hOwgMkZ3mhYuZ46BFCA5rf0
	CaTL33x7XZsPDhBQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E0528132C9;
	Sat,  7 Nov 2026 09:00:13 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 19k0LZ3o7mq9VwAAD6G6ig
	(envelope-from <tiwai@suse.de>); Sat, 07 Nov 2026 09:00:13 +0000
Date: Sat, 07 Nov 2026 10:00:13 +0100
Message-ID: <87jympyq1u.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: Re: [PATCH RESEND v2 03/51] ALSA: cs46xx: hand the region to the region proc files
In-Reply-To: <20261104-work-procfs-bugfixes-v2-3-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
	<20261104-work-procfs-bugfixes-v2-3-021c84d852e0@kernel.org>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) Emacs/30.2 Mule/6.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0 (generated by SEMI-EPG 1.14.7 - "Harue")
Content-Type: text/plain; charset=US-ASCII
X-Spamd-Result: default: False [-11.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	TO_DN_SOME(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:dkim];
	R_RATELIMIT(0.00)[to_ip_from(RLij3mi59gqb8x3hiq1dpi8wgt)];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	RCPT_COUNT_GT_50(0.00)[60];
	RCVD_COUNT_TWO(0.00)[2];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	DKIM_TRACE(0.00)[suse.de:+]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -11.01
X-Spam-Level: 
X-Rspamd-Queue-Id: 630761F74D

On Wed, 04 Nov 2026 20:16:45 +0100,
Christian Brauner wrote:
> 
> snd_cs46xx_proc_init() stores the chip in the private data of the five
> region entries, but snd_cs46xx_io_read() reads that back as the region,
> so a read of /proc/asound/cardN/CS46xx_BA0 and friends copies from
> whatever sits at the region's offset in struct snd_cs46xx instead of
> the mapped registers. Store the region.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Takashi Iwai <tiwai@suse.de>


thanks,

Takashi
