Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0642B3CFF60
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 13:45:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775655957; cv=none; b=nzIS3BoDoRkcm3yhJG5rSrXdgnDQWMk7/g3k3R23N6OO1yU70IsdvpeBETXJ3p16CPQDXtU9/tCzM4oiU4LfoGjXg0zbucp3bdyFMmeFJ5q9rWxXKx65+KbEw/3Z8sTbc7/CAYF0qB7J16k0PS6wjhQFReaO1CnYTsbr02+WF8E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775655957; c=relaxed/simple;
	bh=rZ0duswfBdUhkusiv4tADdSMnN38HqNLb6wTtRuYR1A=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HgB1NsMoTY518vwX59f1Ohd9P68ME+mESQcv8mQjcCcJI9y29ZJdJYpvqzNeLaH7i1c092g3lT+sMmC2ljyXz0GrgRvg85NoVC3ExHovRhCVtl1IWer92wZ+aAbKoG+Ia6iXq7YWYjWIEHfYuGTCv4hYXHjNFX1mHpH93BJCj2g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=tg6tb3UY; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=cew9A90C; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=tg6tb3UY; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=cew9A90C; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="tg6tb3UY";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="cew9A90C";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="tg6tb3UY";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="cew9A90C"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 6E0324E9EF;
	Wed,  8 Apr 2026 13:45:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1775655953; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=guUl31ZUjxckt3Htiuc/TyOB8T15D5Nl2LWqFUhvEMQ=;
	b=tg6tb3UY7faz5Ffb1PsBx8JVOA4rS5DOc/FPbt91cpCG/Y0C4BrqlMWcAUBYOcl2bcbxuP
	djprqB9dd2xObulO9eN5LSSBbuCi0m4Q6ptFVF4ay/CnEFauTNHIF9Gib1MgbDgqYqyaPs
	Gb26p7ys5bFPZzbQLrmhnL7NT/TQJtI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1775655953;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=guUl31ZUjxckt3Htiuc/TyOB8T15D5Nl2LWqFUhvEMQ=;
	b=cew9A90CdH7GyDzQpj75Fq7kJ4Tx+ouCBZsaxHGiyAvTKUn3Qvw4Xvvi8auaebSDap2MRN
	ZepDb7OE2t/Az7BQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1775655953; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=guUl31ZUjxckt3Htiuc/TyOB8T15D5Nl2LWqFUhvEMQ=;
	b=tg6tb3UY7faz5Ffb1PsBx8JVOA4rS5DOc/FPbt91cpCG/Y0C4BrqlMWcAUBYOcl2bcbxuP
	djprqB9dd2xObulO9eN5LSSBbuCi0m4Q6ptFVF4ay/CnEFauTNHIF9Gib1MgbDgqYqyaPs
	Gb26p7ys5bFPZzbQLrmhnL7NT/TQJtI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1775655953;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=guUl31ZUjxckt3Htiuc/TyOB8T15D5Nl2LWqFUhvEMQ=;
	b=cew9A90CdH7GyDzQpj75Fq7kJ4Tx+ouCBZsaxHGiyAvTKUn3Qvw4Xvvi8auaebSDap2MRN
	ZepDb7OE2t/Az7BQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 637174A0B3;
	Wed,  8 Apr 2026 13:45:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id vrJTGBFc1mlQNwAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 08 Apr 2026 13:45:53 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 2D681A0A7E; Wed,  8 Apr 2026 15:45:53 +0200 (CEST)
Date: Wed, 8 Apr 2026 15:45:53 +0200
From: Jan Kara <jack@suse.cz>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Chuck Lever <chuck.lever@oracle.com>, 
	Alexander Aring <alex.aring@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Masami Hiramatsu <mhiramat@kernel.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, Calum Mackay <calum.mackay@oracle.com>, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/24] filelock: add a tracepoint to start of
 break_lease()
Message-ID: <7r75tbhyr3wckzdruut4smhu66gp7imbmktss2iaentoctc7ik@d2u2rdkykgsu>
References: <20260407-dir-deleg-v1-0-aaf68c478abd@kernel.org>
 <20260407-dir-deleg-v1-2-aaf68c478abd@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260407-dir-deleg-v1-2-aaf68c478abd@kernel.org>
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	ARC_NA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[24];
	TAGGED_RCPT(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	R_RATELIMIT(0.00)[to_ip_from(RL63fqwwx8ot6gmekemcs76f9d)];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[zeniv.linux.org.uk,kernel.org,suse.cz,oracle.com,gmail.com,goodmis.org,efficios.com,lwn.net,linuxfoundation.org,brown.name,redhat.com,talpey.com,vger.kernel.org];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Flag: NO
X-Spam-Score: -2.30
X-Spam-Level: 

On Tue 07-04-26 09:21:15, Jeff Layton wrote:
> ...mostly to show the LEASE_BREAK_* flags.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

OK. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/locks.c                      |  2 ++
>  include/trace/events/filelock.h | 33 +++++++++++++++++++++++++++++++++
>  2 files changed, 35 insertions(+)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index dafa0752fdce..5af6dca2d46c 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1654,6 +1654,8 @@ int __break_lease(struct inode *inode, unsigned int flags)
>  	bool want_write = !(flags & LEASE_BREAK_OPEN_RDONLY);
>  	int error = 0;
>  
> +	trace_break_lease(inode, flags);
> +
>  	if (flags & LEASE_BREAK_LEASE)
>  		type = FL_LEASE;
>  	else if (flags & LEASE_BREAK_DELEG)
> diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
> index ef4bb0afb86a..fff0ee2d452d 100644
> --- a/include/trace/events/filelock.h
> +++ b/include/trace/events/filelock.h
> @@ -120,6 +120,39 @@ DEFINE_EVENT(filelock_lock, flock_lock_inode,
>  		TP_PROTO(struct inode *inode, struct file_lock *fl, int ret),
>  		TP_ARGS(inode, fl, ret));
>  
> +#define show_lease_break_flags(val)					\
> +	__print_flags(val, "|",						\
> +		{ LEASE_BREAK_LEASE,		"LEASE" },		\
> +		{ LEASE_BREAK_DELEG,		"DELEG" },		\
> +		{ LEASE_BREAK_LAYOUT,		"LAYOUT" },		\
> +		{ LEASE_BREAK_NONBLOCK,		"NONBLOCK" },		\
> +		{ LEASE_BREAK_OPEN_RDONLY,	"OPEN_RDONLY" },	\
> +		{ LEASE_BREAK_DIR_CREATE,	"DIR_CREATE" },		\
> +		{ LEASE_BREAK_DIR_DELETE,	"DIR_DELETE" },		\
> +		{ LEASE_BREAK_DIR_RENAME,	"DIR_RENAME" })
> +
> +TRACE_EVENT(break_lease,
> +	TP_PROTO(struct inode *inode, unsigned int flags),
> +
> +	TP_ARGS(inode, flags),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, i_ino)
> +		__field(dev_t, s_dev)
> +		__field(unsigned int, flags)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->s_dev = inode->i_sb->s_dev;
> +		__entry->i_ino = inode->i_ino;
> +		__entry->flags = flags;
> +	),
> +
> +	TP_printk("dev=0x%x:0x%x ino=0x%lx flags=%s",
> +		  MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
> +		  __entry->i_ino, show_lease_break_flags(__entry->flags))
> +);
> +
>  DECLARE_EVENT_CLASS(filelock_lease,
>  	TP_PROTO(struct inode *inode, struct file_lease *fl),
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
