Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315213;
	b=cOATsLTEcpsSTvJlb3roeQuEb6VQc0HUNnbhDgbUqlKF3soEpdByh+EDXN2Q7Sd3Jd6P
	 kNEnfptX/zhCNUFPd2pK7R7ZmKaoWvNWsmC+AxARS9GCrfOWkhFQ5EZ/SPh0PRfbvPKe4
	 npVn65vNkfA82VOYfcsge0/vBhDgatWVi/nP9+7G9AY803CkjjGWVbMETv+EZ6dGtMr72
	 eNMSbi0SEHOsgEGHIZ8H8pDVVBdN2CfGsZeQzTikW/J13BeuxMRkDYhtYVZZnMXHK3tqZ
	 EROUzIeKbUI7uzTIFsu2OWxNf4attzw93XiZF1WVZ+jLHQM6ffkGpWtlYzQmEIWMw7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315213;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=5gAW8eIWGI8HOfwWvZQs68yC+wpRbirnAYyZ2bTJ9+E=;
	b=sQVVHnfkGWb1RN+IqVuDeJZQNxrKjwPrm0gQDDA4hGQTJU17ZJ+oCMzms/aZtdRW8ikt
	 +9AAs1z+YZ8D82f5Pm0ZAD1WqkC1Q/hbWS2Qh4QUkp0P5CwWnMOhH9jDjTC+BFMI3vMgg
	 MD6smJvCy4fA1pdw9GOU+d3/zQc9eO9tRsOPlchw5gdvCOrFW3TdlBmwzPPYzbVSPuHdZ
	 t1YrHmf63oL/eHw6scUlsO7lJTDNJcAjH8YPuEkxFI+o78xLsJvkXzgwewJ50GSH7gV/1
	 vnC8K7Moh+hGq8BHuKGhGTQJoE1JcfX3UJjRQOdWgJoic2SeBGJY3wZlw3S18PaG04g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KXGDllpg;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=02akHxQo;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KXGDllpg;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=02akHxQo;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EA11606A321;
	Tue, 10 Nov 2026 12:53:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0EA11606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KXGDllpg;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=02akHxQo;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=KXGDllpg;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=02akHxQo
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 470B421F57;
	Tue, 10 Nov 2026 12:53:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315211; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5gAW8eIWGI8HOfwWvZQs68yC+wpRbirnAYyZ2bTJ9+E=;
	b=KXGDllpgGiBBAdkJ+94+hx57x3NvF+B6wVf1VJPhzu/vdFL2qD1xN8ea3AfxZRuIEQrDNG
	h6ARgN9r6E1Tp0L3/IOetfpivMPJgdCx8gDCmnuEUwvvykOGvRJ3e4L8lAmSVM7Bzl5Sdl
	8yjrsZoBB4KbKRgxMsQEsJpHPQKPfVY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315211;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5gAW8eIWGI8HOfwWvZQs68yC+wpRbirnAYyZ2bTJ9+E=;
	b=02akHxQolbaeDkTqzMuoQ9qEenO8KZzqbD3pshHw2P9mLxjD414sxUGp3r+0OsfEjYG8bh
	6lagVVxrNyrhB8AQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315211; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5gAW8eIWGI8HOfwWvZQs68yC+wpRbirnAYyZ2bTJ9+E=;
	b=KXGDllpgGiBBAdkJ+94+hx57x3NvF+B6wVf1VJPhzu/vdFL2qD1xN8ea3AfxZRuIEQrDNG
	h6ARgN9r6E1Tp0L3/IOetfpivMPJgdCx8gDCmnuEUwvvykOGvRJ3e4L8lAmSVM7Bzl5Sdl
	8yjrsZoBB4KbKRgxMsQEsJpHPQKPfVY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315211;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5gAW8eIWGI8HOfwWvZQs68yC+wpRbirnAYyZ2bTJ9+E=;
	b=02akHxQolbaeDkTqzMuoQ9qEenO8KZzqbD3pshHw2P9mLxjD414sxUGp3r+0OsfEjYG8bh
	6lagVVxrNyrhB8AQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 197071339F;
	Tue, 10 Nov 2026 12:53:31 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id HDDqOMoT82qhQAAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:53:31 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 94F1F224D8; Tue, 10 Nov 2026 13:53:26 +0100 (CET)
Date: Tue, 10 Nov 2026 13:53:26 +0100
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
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org, 
	stable@vger.kernel.org
Subject: Re: [PATCH RFC 01/41] loop: refuse backing files that aren't open
 for reading
Message-ID: <yiiin5howot4r3fgcqkqfnreblloazpfatuuqzpjpqshpvphit@zirpwlmklj3d>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-1-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-1-4c998976c6c7@kernel.org>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[32];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	R_RATELIMIT(0.00)[to_ip_from(RLdu9otajk16idfrkma9mbkf9b)];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,google.com,kernel.org,toxicpanda.com,lst.de,lists.infradead.org,zeniv.linux.org.uk,suse.cz,lists.linux.dev,kvack.org,lists.ubuntu.com,lists.xenproject.org,lists.ozlabs.org,gmail.com];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Tue 10-11-26 10:14:17, Christian Brauner wrote:
> loop_configure() takes any file as long as it implements ->read_iter().
> Loop itself never checked whether the file was actually opened for
> reading. Buffered I/O went through vfs_iter_read() which refuses files
> without FMODE_READ. Direct I/O has called ->read_iter() of the backing
> file directly ever since loop grew support for it.
> 
> Since commit f2fed441c69b ("loop: stop using vfs_iter_{read,write} for
> buffered I/O") buffered I/O calls ->read_iter() directly as well. That
> commit was about O_DIRECT handling and the FMODE_READ check went away
> as a side effect.
> 
> So whoever can set up a loop device can read a file it was only allowed
> to open for writing. Open the file O_WRONLY, configure a loop device
> with it and read the contents through the loop device.
> 
> Refuse backing files that aren't open for reading. Loop always reads
> from its backing file so a write-only backing file never made sense in
> the first place.
> 
> Fixes: bc07c10a3603 ("block: loop: support DIO & AIO")
> Fixes: f2fed441c69b ("loop: stop using vfs_iter_{read,write} for buffered I/O")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/block/loop.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index a3325ceab484..c96e35c3ef42 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -528,6 +528,9 @@ static void loop_assign_backing_file(struct loop_device *lo, struct file *file)
>  
>  static int loop_check_backing_file(struct file *file)
>  {
> +	if (!(file->f_mode & FMODE_READ))
> +		return -EBADF;
> +
>  	if (!file->f_op->read_iter)
>  		return -EINVAL;
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
