Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794830233;
	b=cvnB5fYIqf25/k4xxgf+dlN/NBSV+3Ua+nFHJTe5vGnvMwgqC2LNNn+OLcNWG2ij8nah
	 CE1Ot3Wmew+Zq2NXeBhuCOdHn58bciZINSXzbvxdNji+uHFasDV8hTeR/gZrS3inrYpOp
	 ngDmzRZQG2Ck8hdm60CmccDZBi26EAj6Mt07RvtWyUoU8Dy4lMZlnVOx3mPCMpHcE0zPZ
	 OE2iVpA5rJjZ5FNVUXLpufrn4baClxXBYbYn9fQ7pCAE8+apshHN/dX3NdYxz42aWcwtc
	 jNzjKrC/JXlwIzBWaUcZK0x/0Ge2/YKHFKj77BRWYxGN3f4M3RuLRvO+ynK1eFQ6W3Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794830233;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=5dd3gaWnxyGYmLDfQYceg41vjRMRWzOvPs+gvBjx0cg=;
	b=r98DS9vnLPZYTlcMhC2MAzhoDZnHyVtGOF+701Os5s/3ANjybPTlpouCWP8DcoQTfpKX
	 YLKFF+3yd4zYuhvfQ04QK5jJmXROtiEjC3peSbHEmfGYMUrQGqJPqz7eUyVwbWxti8Z70
	 7iircKWRa1wWA4QgjuzWvzTOz50SIrzYNlzN1nwGlNmbWRVggzUAyUpcLUQBn2lHNb80f
	 SGJ6TUUgG57CLQZNQIedFKG3n3v+8AoaCkqVI3UXCPetRKTlG0kd7Fq0eXD7Pz2mFHUho
	 sBMixxanBtyt10EIe2HPhUcJhjwXf9OWBGRWY/fiDmZVte+IeswGGJ2SbrQeZx7YYNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=hi+7am1n;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=a6HFcYZg;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=hi+7am1n;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=a6HFcYZg;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75063606A323;
	Mon, 16 Nov 2026 11:57:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 75063606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=hi+7am1n;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=a6HFcYZg;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=hi+7am1n;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=a6HFcYZg
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 3807522288;
	Mon, 16 Nov 2026 11:57:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794830230; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5dd3gaWnxyGYmLDfQYceg41vjRMRWzOvPs+gvBjx0cg=;
	b=hi+7am1nCU82xuxgxJ3x1Q+7twFUxXAhmtRKgkw6ZHdNS0IPvLhLiKC4uDUbqqjUxfkO5R
	W97VxwcpFF+tseH9CD1RRAyGXq8JSTyz0/nX2329JtfEtKrNBYUzeqWDsD6xweP7U60+YB
	dY8nblDInaXxv4tg/Q6CKtOsryKRVzk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794830230;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5dd3gaWnxyGYmLDfQYceg41vjRMRWzOvPs+gvBjx0cg=;
	b=a6HFcYZg6dz08eQi4ySHauPik6itTK+HROwVhnt3GP6fnnvjX+Fg7ABd1cgQn+qcp9xGL/
	+OcAb3Ppbz5loJCg==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794830230; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5dd3gaWnxyGYmLDfQYceg41vjRMRWzOvPs+gvBjx0cg=;
	b=hi+7am1nCU82xuxgxJ3x1Q+7twFUxXAhmtRKgkw6ZHdNS0IPvLhLiKC4uDUbqqjUxfkO5R
	W97VxwcpFF+tseH9CD1RRAyGXq8JSTyz0/nX2329JtfEtKrNBYUzeqWDsD6xweP7U60+YB
	dY8nblDInaXxv4tg/Q6CKtOsryKRVzk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794830230;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5dd3gaWnxyGYmLDfQYceg41vjRMRWzOvPs+gvBjx0cg=;
	b=a6HFcYZg6dz08eQi4ySHauPik6itTK+HROwVhnt3GP6fnnvjX+Fg7ABd1cgQn+qcp9xGL/
	+OcAb3Ppbz5loJCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 09F471334C;
	Mon, 16 Nov 2026 11:57:10 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id C6ISNpXv+mqcRgAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 11:57:10 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 9090E24DD2; Mon, 16 Nov 2026 12:57:09 +0100 (CET)
Date: Mon, 16 Nov 2026 12:57:09 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jan Kara <jack@suse.cz>, 
	Shakeel Butt <shakeel.butt@linux.dev>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
	io-uring@vger.kernel.org, linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, 
	bpf@vger.kernel.org, linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 07/12] zloop: take freeze protection when recording write
 pointers
Message-ID: <t73376p7ip4bvetjbqijzugvglhi2rdxsqt62l3uuqtmt3tqgk@2rlkkdy33hwk>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org>
 <20261116064820.GB2964@lst.de>
 <20261116-biegen-flaute-flanke-cebddae97444@brauner>
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
In-Reply-To: <20261116-biegen-flaute-flanke-cebddae97444@brauner>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[17];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Mon 16-11-26 10:41:49, Christian Brauner wrote:
> Fwiw, the check can't go into __vfs_setxattr(), __vfs_setxattr_noperm()
> or __vfs_removexattr(). cap_inode_killpriv(), IMA and EVM call those
> from ->write_iter() via file_remove_privs() and kiocb_start_write()
> hides the freeze protection from lockdep for aio and io_uring. I have
> not bothered to figure out why. Maybe you already know? In any case,
> until that's fixed we can't place it there which means this doesn't
> catch IMA/EVM at which point this patch becomes pointless.

It's because of AIO and io_uring - if you don't hide the protection from
lockdep, it will complain about it when returning to userspace while IO is
still in flight (and thus protection is held). Sadly lockdep does not
support releasing resources by anybody else than the process which acquired
it so we fool it in this way...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
