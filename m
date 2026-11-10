Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315273;
	b=V+L6jiAaA7Vani9rutz5lTm6u5EiXT5QielEbWEIjBj2O3x2cO6BUSrCHCP0e1tkwduA
	 Eg2YrRB2T/4qsaxDp2qBV+8MIVVutG61men8NVHFEdI7e9m78xkItphmqL5JC8188R2mV
	 rKQTSuC7qiMElonasrJotP4xZthiUfeTk8hmj8ij5v2A70EBNvVajKmHD4r7P3BWzs/LP
	 cet9ReADJDWPMfupTSjbMN00hRwSe2jRB+JAtjQBKyj2m0tebPcPEn1Gqv3a34pkVNvCc
	 lwFiqdOI68bEz3+wpOqGTPJHi9ceZZNIe3HsQ/aQWwx7WDdqv7HDw0pPUeYUq/1cqiQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315273;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=OJ/prrn965jMvrgfLjF+vFRorAc5HNvJ6Vj8L/XmMbo=;
	b=lwn2EBfqcPEyb3G3X3pSc6m1tlW55aSS35+kSSHwjGfJtKJ9+vEj1yMU3A1z3CviY8JG
	 462Kyu+DVWLXsj99L538Pr0j+XC9WSIEJNsK7Lnd/ufv80qAFwhUlzMCUZdAkT/SDzyfX
	 qKhcX4X6kkGqrfLX+lKSfpSB07950fcgEpDPC9G+7z4zXeaUss3ODKDSJ8QDbpR05H+jM
	 OiN081MRcht8i302l1w/l9PQsyoaoz9xCIsWkJDnI4dmO5C7MwBXDb9WTJNzge0pz6Hl3
	 MPNi4qadAusWwnaXkI1U/epZdKzh8dqiTORjxBn07W0PA0M5mJ2sFgDiQNrrIGer5Mg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=Q2H6Mk4O;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=29N3zImF;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=Q2H6Mk4O;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=29N3zImF;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F273E60A260E;
	Tue, 10 Nov 2026 12:54:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F273E60A260E
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=Q2H6Mk4O;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=29N3zImF;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=Q2H6Mk4O;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=29N3zImF
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 5BBCB21EC3;
	Tue, 10 Nov 2026 12:54:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315270; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=OJ/prrn965jMvrgfLjF+vFRorAc5HNvJ6Vj8L/XmMbo=;
	b=Q2H6Mk4O1KaxEREOj5DevP2kMmH/Jidslcr1s6/vZIMu9WIDtdkSn5EG2n6fd0LuRLcdyR
	OsFZv9uv7UMWguBVt0RqvpxAGlKN3MHZdrq5jMlTWssQy62BIT2qg2AoLOn1LWDhgCr5PN
	XMWF0Y0SpbRpnTpFBSi/pSKP5wkCCts=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315270;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=OJ/prrn965jMvrgfLjF+vFRorAc5HNvJ6Vj8L/XmMbo=;
	b=29N3zImFuoXZ3FcTPq5PwxpXmvPvhMRlDBfBJL8lW84IsbdkpNdw1G7KrJbgDQqTwApVDr
	s36m1YzU5P2ufNAw==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315270; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=OJ/prrn965jMvrgfLjF+vFRorAc5HNvJ6Vj8L/XmMbo=;
	b=Q2H6Mk4O1KaxEREOj5DevP2kMmH/Jidslcr1s6/vZIMu9WIDtdkSn5EG2n6fd0LuRLcdyR
	OsFZv9uv7UMWguBVt0RqvpxAGlKN3MHZdrq5jMlTWssQy62BIT2qg2AoLOn1LWDhgCr5PN
	XMWF0Y0SpbRpnTpFBSi/pSKP5wkCCts=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315270;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=OJ/prrn965jMvrgfLjF+vFRorAc5HNvJ6Vj8L/XmMbo=;
	b=29N3zImFuoXZ3FcTPq5PwxpXmvPvhMRlDBfBJL8lW84IsbdkpNdw1G7KrJbgDQqTwApVDr
	s36m1YzU5P2ufNAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 2EA8D1339F;
	Tue, 10 Nov 2026 12:54:30 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id LWGGBQYU82p9QQAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:54:30 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id D65A3224DC; Tue, 10 Nov 2026 13:54:25 +0100 (CET)
Date: Tue, 10 Nov 2026 13:54:25 +0100
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
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 03/41] target: fileio: check that the backing file
 supports ->{read,write}_iter
Message-ID: <7gknb2zk5u322p4hwxmbkwko4oqnmtroz6evgxcfgaqv43e2lf@4ys3f4ojdwvu>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-3-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-3-4c998976c6c7@kernel.org>
X-Spamd-Result: default: False [-16.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[31];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:email]
X-Spam-Score: -16.80
X-Spam-Level: 
X-Spam-Flag: NO

On Tue 10-11-26 10:14:19, Christian Brauner wrote:
> With fd_async_io=1 the fileio backend calls ->read_iter() and
> ->write_iter() of the backing file directly. The synchronous path goes
> through vfs_iter_read() and vfs_iter_write() which check for them but
> the aio path doesn't. So a backing file without them calls a NULL
> pointer on its first I/O.
> 
> Refuse such files when configuring the device. On the synchronous path
> every read or write that needed the missing method failed with EINVAL
> anyway.
> 
> Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/target/target_core_file.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
> index ab9824a4852f..a5391e57e9aa 100644
> --- a/drivers/target/target_core_file.c
> +++ b/drivers/target/target_core_file.c
> @@ -144,6 +144,14 @@ static int fd_configure_device(struct se_device *dev)
>  		goto fail;
>  	}
>  	fd_dev->fd_file = file;
> +
> +	if (!file->f_op->read_iter || !file->f_op->write_iter) {
> +		pr_err("FILEIO: %s lacks ->read_iter or ->write_iter\n",
> +		       fd_dev->fd_dev_name);
> +		ret = -EINVAL;
> +		goto fail;
> +	}
> +
>  	/*
>  	 * If using a block backend with this struct file, we extract
>  	 * fd_dev->fd_[block,dev]_size from struct block_device.
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
