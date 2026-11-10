Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794315544;
	b=bV0f/HW8zV+7Q0eYqDuqSwkc8i5Pka8ktNeQaVT984ojRLipkoeD2NvyS5qCFOHqzT4L
	 AAH10VYrEsr0IdkuoimBBPCCS7jfszt5VXOyNUG49+pBqJpWZP9HvR5t4AIwpKtlRuRcK
	 5BMPe0VKiRM6B0X4CO0STxUhtkXSH06LpWvjweurczqemJfzkHbm18rOqfBZeG2vPArfe
	 V592HYFX+st500q/L7KD1tEOeqHDXc7WY7Xr9mjmMrPdmcsDxLqjV70KFMverHwE4DINO
	 OoeYOQyHbBZWqyJjXrvR2gQxXF0z4kCmlNokIdD0YvBE4BF8MgETzJePklY0WexIecg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794315544;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=uXIEEsQfVTIPoYksjJrq5Bxki7KhKYAms5GVjwoGo8Y=;
	b=dBMSO/pCqdB2kMbK7i5A2mIWY0VvtzZ8wC8weyRa7JLpAIkUvQtaSZ8My94oxWSvAgDg
	 effdv70J6dkQm3O4enigNr407KxFYrZm9A9AUyAj9bIKJvi2UKyPoNm6IA5d6cqCGEWp9
	 nOjNu8JTGY+QjoW4v1GKgh0I3+RHfwaQbL1/tdrZQvwh4ugaMKrHu6OJAGeVNmn8RodX1
	 jOyZd7Jl6EVh/Z6FgZ7daWTRJ8GVX3dR0XquJipLDyIPeimhNYlNW3QlhcpVDutlXI+nh
	 kuwAVAdllMqusmxlmzkWkMnv2OOj5DvODW/LhKy60xq3UB1hOkh+C5FkJiDNKvHs8kQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=c9mE+CRT;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=kal9kkyQ;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=c9mE+CRT;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=kal9kkyQ;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47776606A321;
	Tue, 10 Nov 2026 12:59:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 47776606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=c9mE+CRT;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=kal9kkyQ;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=c9mE+CRT;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=kal9kkyQ
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 96EA721C3C;
	Tue, 10 Nov 2026 12:59:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315541; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uXIEEsQfVTIPoYksjJrq5Bxki7KhKYAms5GVjwoGo8Y=;
	b=c9mE+CRTtVzWwHCARJ1vd96Xho3nI/pS4LksT/7Mtmz/enT3ot6Jv+ishWlr43gZSQip4n
	SM34HuYF7Cvf9TdHqnHerexkyr7m27gwbghlt5kBxleXZTpWWWludIkY/uX/1xq2ZGF1Cl
	84ZWSnV4g+NJIksQj9LF3uDbQvrtb1Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315541;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uXIEEsQfVTIPoYksjJrq5Bxki7KhKYAms5GVjwoGo8Y=;
	b=kal9kkyQ8SEr1Uo3AFh1O8jXLtIAjDTFZiXwnabICsxjbUs+efcLTV1NmhR9cGdyfqXeRJ
	S89Jh74CnobXgdBQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794315541; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uXIEEsQfVTIPoYksjJrq5Bxki7KhKYAms5GVjwoGo8Y=;
	b=c9mE+CRTtVzWwHCARJ1vd96Xho3nI/pS4LksT/7Mtmz/enT3ot6Jv+ishWlr43gZSQip4n
	SM34HuYF7Cvf9TdHqnHerexkyr7m27gwbghlt5kBxleXZTpWWWludIkY/uX/1xq2ZGF1Cl
	84ZWSnV4g+NJIksQj9LF3uDbQvrtb1Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794315541;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uXIEEsQfVTIPoYksjJrq5Bxki7KhKYAms5GVjwoGo8Y=;
	b=kal9kkyQ8SEr1Uo3AFh1O8jXLtIAjDTFZiXwnabICsxjbUs+efcLTV1NmhR9cGdyfqXeRJ
	S89Jh74CnobXgdBQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6DE921339F;
	Tue, 10 Nov 2026 12:59:01 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id B0aKEhUV82qHRgAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 12:59:01 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 0FDA5224EF; Tue, 10 Nov 2026 13:59:01 +0100 (CET)
Date: Tue, 10 Nov 2026 13:59:01 +0100
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
Subject: Re: [PATCH RFC 14/41] debugfs: use fc_init_pseudo()
Message-ID: <tqopv6vbmzwwjyp24wch4hw526xibknezzimun4tniww2dq7wu@ajdlmym5ihdu>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-14-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-14-4c998976c6c7@kernel.org>
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -16.80
X-Spam-Level: 
X-Spam-Flag: NO

On Tue 10-11-26 10:14:30, Christian Brauner wrote:
> Initialize debugfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. debugfs never holds executables or
> device nodes.
> 
> SB_I_NOEXEC also refuses PROT_EXEC mappings. The debugfs files that
> can be mapped, kcov, relay channels and powernv's memtrace, map data.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

OK, makes sense. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> ---
>  fs/debugfs/inode.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
> index b4915551ad31..f163f0bc5703 100644
> --- a/fs/debugfs/inode.c
> +++ b/fs/debugfs/inode.c
> @@ -15,6 +15,7 @@
>  #include <linux/module.h>
>  #include <linux/fs.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include <linux/fs_parser.h>
>  #include <linux/pagemap.h>
>  #include <linux/init.h>
> @@ -317,6 +318,7 @@ static int debugfs_init_fs_context(struct fs_context *fc)
>  	fsi->mode = DEBUGFS_DEFAULT_MODE;
>  
>  	fc->s_fs_info = fsi;
> +	fc_init_pseudo(fc);
>  	fc->ops = &debugfs_context_ops;
>  	return 0;
>  }
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
