Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315776;
	b=bFyDcZwWiGl24ReJgOp9De4Lv0fvtFWoX+pvPKzsBAy3qlVSJw1a6K3+hXAUNzm7kprX
	 +dO1MDwqf1Sctg1q501vT5ugPJzjEJaCqYaxCtktDwwte2GmthLLAlhg9qDfqXlnbjuzm
	 9dxiINvYd0oq40OpEunpCJYhVFgqvHa59yPcRKE2ZrqwJJedaNG++1EhebLVGTDicNfNy
	 aiVcmYDs6pO+a2dQDVj6K/mHBGf16xaFbPTJOavGicJm+ys4HfDdZmMJW5OyXPfFWV9S4
	 K/6/nDPFR1TliuQ8L8dledHsxeQQLnsTPCht2tcxIkUlviPVrHlL0zZeZJrFjK/5AEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315776;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=USDR2iE5M2UEpaP+1GfJYI3TDuWZn3GdzCTDZovKwBI=;
	b=3sa8A+HEosPJBhzcx76XgGWELLYAnxhdfYzfjeLwf1ry3vJF4rNuAnT/MsbgmJhNjkfH
	 Q1dmPaCz8DXWq240QbqzXHm2wRmEJRjb6NjVXCpGlRlnQuYOMxH2C2IYGz/JnBwxmiINy
	 U5/7bxgv7SA5a4xhqrJm4plIDKafB5GoUfQn9HjAOH/BTJ4yi2qUGczIcXHaWa8SfGKoG
	 EpjAiFzWgWiLXz5QkhZlHQzO1DxFQCM9bxs2hB8yuVTluux9GyU1ie0bX3Bgofpd7zAP/
	 R78VVTT5bzvcWKenN4gqreUQPPbMAI/SiKUku9I2G6PON8KLIkjCGm3vVXfXE7yqyZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=WWtetnZD;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=yu1DhDEP;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=WWtetnZD;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=yu1DhDEP;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8745606A334;
	Tue, 10 Nov 2026 13:02:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E8745606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=WWtetnZD;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=yu1DhDEP;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=WWtetnZD;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=yu1DhDEP
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 4CBE01F461;
	Tue, 10 Nov 2026 13:02:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315773; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=USDR2iE5M2UEpaP+1GfJYI3TDuWZn3GdzCTDZovKwBI=;
	b=WWtetnZDdpY3CtAQ5P1ACc9FV+Q/S+5upWrfSvOHBVg/CDxzET4BPczhpbK/0nKTIvhIK1
	bJoSZBBd6xKzhenae5FUv3Cjcv6lVOt9c7qqlxsD1mkbGXiYDtk869K+0cd3OPJSH5NxR+
	UXFonm344KX222leLjP7xQc612byqXU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315773;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=USDR2iE5M2UEpaP+1GfJYI3TDuWZn3GdzCTDZovKwBI=;
	b=yu1DhDEPEx3W2fYEUxbPsnXt4QMtwAIEJLkOMN58QZdMiOL9l/WrEOFLFJ9XB9CeUk/K09
	vhBCY/lPsE57BEAg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315773; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=USDR2iE5M2UEpaP+1GfJYI3TDuWZn3GdzCTDZovKwBI=;
	b=WWtetnZDdpY3CtAQ5P1ACc9FV+Q/S+5upWrfSvOHBVg/CDxzET4BPczhpbK/0nKTIvhIK1
	bJoSZBBd6xKzhenae5FUv3Cjcv6lVOt9c7qqlxsD1mkbGXiYDtk869K+0cd3OPJSH5NxR+
	UXFonm344KX222leLjP7xQc612byqXU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315773;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=USDR2iE5M2UEpaP+1GfJYI3TDuWZn3GdzCTDZovKwBI=;
	b=yu1DhDEPEx3W2fYEUxbPsnXt4QMtwAIEJLkOMN58QZdMiOL9l/WrEOFLFJ9XB9CeUk/K09
	vhBCY/lPsE57BEAg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 1C287134F4;
	Tue, 10 Nov 2026 13:02:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id Nyb9LPwV82qMSgAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 13:02:53 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 7F6C6224F5; Tue, 10 Nov 2026 14:02:48 +0100 (CET)
Date: Tue, 10 Nov 2026 14:02:48 +0100
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
Subject: Re: [PATCH RFC 33/41] fs: add file_is_pseudo()
Message-ID: <xy7rgmmpufyq4ls4obs5te3y4mrzblqst7heachjo7rrkmvhot@x5kxqkbsw247>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-33-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-33-4c998976c6c7@kernel.org>
X-Spamd-Result: default: False [-16.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
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
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,google.com,kernel.org,toxicpanda.com,lst.de,lists.infradead.org,zeniv.linux.org.uk,suse.cz,lists.linux.dev,kvack.org,lists.ubuntu.com,lists.xenproject.org,lists.ozlabs.org,gmail.com];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -16.80
X-Spam-Level: 
X-Spam-Flag: NO

On Tue 10-11-26 10:14:49, Christian Brauner wrote:
> Add a helper to check whether a file is a regular file on a pseudo
> filesystem. Only regular files count. Device nodes on pseudo filesystems
> such as devpts, binderfs or the block devices on bdevfs are what they
> are.
> 
> Look at the inode that actually provides the data via d_real_inode().
> overlayfs accepts sysfs, cgroup2, debugfs, tracefs, configfs and
> securityfs as lower layers and reads of such an overlayfs file are
> served by the file on the pseudo filesystem. Checking the overlayfs
> inode would miss that.
> 
> No functional changes.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 99caef43ff3c..407ffb6342ec 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2553,6 +2553,18 @@ static inline const struct inode *file_user_inode(const struct file *f)
>  	return file_inode(f);
>  }
>  
> +/*
> + * Regular files on pseudo filesystems are kernel interfaces and must not be
> + * used as storage. Look through stacking filesystems at the inode that
> + * provides the data.
> + */
> +static inline bool file_is_pseudo(const struct file *file)
> +{
> +	const struct inode *inode = d_real_inode(file->f_path.dentry);
> +
> +	return S_ISREG(inode->i_mode) && (inode->i_sb->s_iflags & SB_I_PSEUDO);
> +}
> +
>  static inline struct file *file_clone_open(struct file *file)
>  {
>  	return dentry_open(&file->f_path, file->f_flags, file->f_cred);
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
