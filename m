Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315802;
	b=uCLByQljC/l08kH9TfWom6cjwV8PUXQI96SZL4kmTvEU+USMswxkiwcJGa8MMDrYoDqz
	 dyG2oGVBnkR51sxAmC0I7Z+szOCVGYg3EDi65D5xqyc9B2kV3AvFvLDHqInWy4wCeoATY
	 fIrxI6rykQq6X3d7OOXtJGAkXzSxz8BgvXADU6AcZH1NiWQ8TiK1rNR1w3gepktwokKn1
	 u9LeFc4op7Uw5CIjTh16gVIIC3ZZpXHpBYweTkyZ2PL3fVdal2Sxb5fbL2ZTnsMBzC2Zn
	 SZX0Sq2sDZGx1AAdtyXJZAHctd04/Hx/gKtUBiZ8ymI2v0sTfRx3y40yZKligA0gsjw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315802;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=l0P34w8QQvLO5YW5vCLMJ84QpfDMX9/Bu1FrRmyy2v8=;
	b=DFbQ+mz6Xx6CA3XASYaFPM6Yn6qN9Ub78vKEXY6qCm8Y0mdL/kLpahcnw+wk2hrJMdZw
	 ia0qgYyFJaV4i9JOTeBVZZicZ0tm4VFaBIGta7Nv4XnzjF/rIH2iPXB717S13KbjHdV78
	 B8h/yr/w5T8DrD+yiubMM8+Mh3vxXbu/3P4iuDboF03h+LwQtFJe/f3UNHp+69C4TblzO
	 /0Zr4Aw+5dw8zTMvt1W9p6CgCAriSYFVjAXcjFtZ29PxNclgFC/RyJK4hqae4oKSyqjlV
	 IAAqXRsqOhm+zwHCrjrnlvui3jAm7tCBmxfhXq7PwxrFvl3W6+MccduJGwGwMO9G6FQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nU4XxgAL;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mnc4QrSZ;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nU4XxgAL;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mnc4QrSZ;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88A0C606A74B;
	Tue, 10 Nov 2026 13:03:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 88A0C606A74B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nU4XxgAL;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mnc4QrSZ;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=nU4XxgAL;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mnc4QrSZ
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id C0D9421F77;
	Tue, 10 Nov 2026 13:03:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315799; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=l0P34w8QQvLO5YW5vCLMJ84QpfDMX9/Bu1FrRmyy2v8=;
	b=nU4XxgALhU6j4K3Mxr5ngQH1kaedGJkQyEqwlGUplEx9hMxQ3fo4McMmOwr1ERv3Mkpxw3
	gLCfI+EWYKzq/l9mRzhXb6GJ0h3nlI+5tsg9MpjQ2PJDBC1XC/U5s6EqGl5dlEXIEKPAnz
	BBcKQlac9Q1+gcOvfNs3dKHhhfnARxs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315799;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=l0P34w8QQvLO5YW5vCLMJ84QpfDMX9/Bu1FrRmyy2v8=;
	b=Mnc4QrSZrRmpafaJe4iOnLi1RuOTcqJe/GGSNdftVub9UNeD+cHjavH2Su/fUJ6PuunSLs
	aVyAWefkY3MWbuCw==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315799; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=l0P34w8QQvLO5YW5vCLMJ84QpfDMX9/Bu1FrRmyy2v8=;
	b=nU4XxgALhU6j4K3Mxr5ngQH1kaedGJkQyEqwlGUplEx9hMxQ3fo4McMmOwr1ERv3Mkpxw3
	gLCfI+EWYKzq/l9mRzhXb6GJ0h3nlI+5tsg9MpjQ2PJDBC1XC/U5s6EqGl5dlEXIEKPAnz
	BBcKQlac9Q1+gcOvfNs3dKHhhfnARxs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315799;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=l0P34w8QQvLO5YW5vCLMJ84QpfDMX9/Bu1FrRmyy2v8=;
	b=Mnc4QrSZrRmpafaJe4iOnLi1RuOTcqJe/GGSNdftVub9UNeD+cHjavH2Su/fUJ6PuunSLs
	aVyAWefkY3MWbuCw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 960C61339F;
	Tue, 10 Nov 2026 13:03:19 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id e3rfGxcW82q6SgAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 13:03:19 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 35CB1224F7; Tue, 10 Nov 2026 14:03:15 +0100 (CET)
Date: Tue, 10 Nov 2026 14:03:15 +0100
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
Subject: Re: [PATCH RFC 34/41] loop: refuse files on pseudo filesystems as
 backing files
Message-ID: <xlql7gc5uyvehjvin4ls3okfnv32xxdj45bjvamf2vdkrakvjx@u4iwy4ydmphs>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-34-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-34-4c998976c6c7@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[31];
	RCVD_COUNT_THREE(0.00)[3];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,google.com,kernel.org,toxicpanda.com,lst.de,lists.infradead.org,zeniv.linux.org.uk,suse.cz,lists.linux.dev,kvack.org,lists.ubuntu.com,lists.xenproject.org,lists.ozlabs.org,gmail.com];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -12.80

On Tue 10-11-26 10:14:50, Christian Brauner wrote:
> Currently loop accepts any regular file that implements ->read_iter() as
> a backing file and any that also implements ->write_iter() as a writable
> one. That includes files on procfs, sysfs and other pseudo filesystems.
> For example, /proc/kcore attaches read-only as a loop device the size of
> the kernel's virtual address space, 64 PiB with 5-level paging. sysfs
> attributes attach read-write as 4096 byte loop devices. Writing a block
> to the loop device of /sys/kernel/mm/transparent_hugepage/enabled
> changes the THP setting.
> 
> That's not just nonsensical, it can be abused. Loop calls ->read_iter()
> and ->write_iter() of the backing file directly from its worker which
> runs with kernel credentials. But pseudo files enforce part of their
> access rules at read and write time against current. Dozens of sysfs
> ->show() and ->store() methods call capable(). Behind a loop device all
> of these checks are done against the loop worker instead of the task
> that opened the file. And setting up a loop device requires no
> capabilities, only access to the device nodes. So on v7.4-rc1:
> 
> - uid 0 without any capabilities can't write to /sys/kernel/reboot/mode
>   as mode_store() requires CAP_SYS_BOOT. Writing "warm" through a loop
>   device works.
> 
> - uid 0 without any capabilities can't read the files in
>   /sys/firmware/dmi/entries/*/ as dmi_sysfs_attr_show() requires
>   CAP_SYS_ADMIN. Reading them through a loop device works.
> 
> - An unprivileged container that was handed a loop device can't change
>   gro_flush_timeout of its own network devices as
>   gro_flush_timeout_store() requires CAP_NET_ADMIN in the initial user
>   namespace. Writing it through a loop device works.
> 
> The same goes for hard_offline_page, the md and sd attributes, rfkill
> and others.
> 
> Refuse files on pseudo filesystems as loop backing files. Note that
> file_is_pseudo() looks through overlayfs so stacking overlayfs on top of
> sysfs doesn't get around this.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/block/loop.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index c96e35c3ef42..1482580a1979 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -537,6 +537,9 @@ static int loop_check_backing_file(struct file *file)
>  	if ((file->f_mode & FMODE_WRITE) && !file->f_op->write_iter)
>  		return -EINVAL;
>  
> +	if (file_is_pseudo(file))
> +		return -EINVAL;
> +
>  	return 0;
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
