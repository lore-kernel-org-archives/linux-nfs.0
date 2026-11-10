Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794309340;
	b=Pl14JcVKMudtQF3q/ET2QmJ4MAKZrIyYtISgGOQyLtq7Rv5QEj31FqvCdX2GZKyyNRvJ
	 HUBqwLsijSofXTvF/+rf3lV2c1CG1nwcf91CNrslOjmineoMa7bFB8rDSlJ/vKRby3/TG
	 2jQe3L3NcN5EZ2tLBW/a04NTDLgdpQPx3W0AEumy+A6hjzHSnoMl5oynI3BEqpXysu141
	 AyPDG4yronFkV9w1xIlnOs8d5KLyv3oD58QcyPPpio70YIERFFdzPYl++u6NK2jd2qw8I
	 22X0bef8T4UXmwZqC0K11Q7Jo5x+ypBobJ0guN8/rpj4mp28WA5iMHZUzcTjLPQ312w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794309340;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=dFY0jRQZRrBQMsSUIeZUMPnBOTgjy9MxfM4UelySjNI=;
	b=DSWikWVgvfXZFkv+Mb9+iuB6N3KHRfoIcTzQSngPxWx5XueYTUUfCUC4cUTeZDiAc50s
	 l/StHV4+qDoAamWjbpWnz6tLVOXB0O9XuLZF02dH01qRoBg5NLej5G+KAlRQrdvTAEY4R
	 S8jJhVKx/WrGTOCtqGP9OVTf4A7qb6LTx2PrAdB5lfKHmCQk2S7uyx2eAjs+/xgjFaFCm
	 LVnTfqquJqOC0xiu+BClMnkE9VE9pUCdURbBIKRZJmkopC40L1xp2CDhTupdj2RJkNiGR
	 a/MeX86J6gqHHIJWNFwM9CNjfNihOWsDYrVlO9sxa6djyIwPfDpNrkmr6s+QmesA5fQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=bAYas9dc;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="XJ4/qVJi";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sTUG0pN6;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=knVRNCiS;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB2D8606A31C;
	Tue, 10 Nov 2026 11:15:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CB2D8606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=bAYas9dc;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=XJ4/qVJi;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=sTUG0pN6;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=knVRNCiS
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id E97B321F18;
	Tue, 10 Nov 2026 11:15:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794309338; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=dFY0jRQZRrBQMsSUIeZUMPnBOTgjy9MxfM4UelySjNI=;
	b=bAYas9dcZLrgsPmE0806WhTQz3ND0ixhvXxGwL7i6ABmAwO0+tsx2vRD3zt0F92M6X2j1C
	Ik3uDhN3+9Um8mEjHyCwzUBOo08QY8CaUmBfwm42mkUXmJQnA28PIUHvKdVlLtl1oxSOlE
	7qi7e187v1Rc0/40nE21rsn6VstFikM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794309338;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=dFY0jRQZRrBQMsSUIeZUMPnBOTgjy9MxfM4UelySjNI=;
	b=XJ4/qVJidWIR/xJdkI/qdo3jzINKfTpZ7aZJc5IuKyvFDewylcRuH6vt5L7udqGzny+VCY
	sYehvhue0qjAgCAw==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794309337; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=dFY0jRQZRrBQMsSUIeZUMPnBOTgjy9MxfM4UelySjNI=;
	b=sTUG0pN6ERvuSjvhybqSmD+y4o69xtc+0POMXrc5wUjQWvCM0L0Gingd0+jbTYXINkDWfi
	DoKEPRxoylNUag355PSKSQ0r7ui7HDDzlwNx6QPvMlrzq9k6J+Aox956T2uk4Vd4/mMvKM
	CLGD8eilA5zOP0lnXRq6hvkR28Kbq64=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794309337;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=dFY0jRQZRrBQMsSUIeZUMPnBOTgjy9MxfM4UelySjNI=;
	b=knVRNCiS3ifAYzlkim2P1KeLLQHsh8J3gn2UNUYw0Qsy1zKN0yRxBBhPo68hnpmLQ8aYMn
	jZZTWj9kO/3HOXAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id BD49013479;
	Tue, 10 Nov 2026 11:15:37 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id Ce75Jdn88mqJWwAAD6G6ig
	(envelope-from <jack@suse.cz>); Tue, 10 Nov 2026 11:15:37 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 4CE7E2249D; Tue, 10 Nov 2026 12:15:29 +0100 (CET)
Date: Tue, 10 Nov 2026 12:15:29 +0100
From: Jan Kara <jack@suse.cz>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v3 6/8] fs: check a fine-grained time before clamping a
 delegated ctime
Message-ID: <l7cl7zdjmxc6gwlh2dxenkqdkdusllyf2npgohtuejdjxg5vue@ct7o4oth6mwy>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
 <20261109-deleg-cb-getattr-times-v3-6-710c7244a6ea@kernel.org>
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
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-6-710c7244a6ea@kernel.org>
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
	RCPT_COUNT_TWELVE(0.00)[13];
	RCVD_COUNT_THREE(0.00)[3];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[kernel.org,brown.name,redhat.com,oracle.com,talpey.com,zeniv.linux.org.uk,suse.cz,gmail.com,vger.kernel.org];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -12.80

On Mon 09-11-26 15:36:47, Jeff Layton wrote:
> inode_set_ctime_deleg() clamps an update later than the coarse time
> (or mg floor) to that time. An NFS client holding a timestamp delegation
> stamps at least 1ns after the fine-grained ctime the server last
> reported. If the delegation comes back within the same coarse tick,
> that stamp looks like it's in the future: ctime is clamped back, and
> the ctime the client reported while holding the delegation changes
> after DELEGRETURN.
> 
> When the update is past the coarse time, take a fine-grained time with
> ktime_get_real_ts64_mg() and clamp only if the update is past that too.
> That also raises the floor to at least the update, so later coarse
> stamps can't land before it. This works for non-multigrain filesystems
> too: their stamps also read the floor.
> 
> Fixes: 7f2c86cba3c5 ("fs: handle delegated timestamps in setattr_copy_mgtime")
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

Looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/inode.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index f63535ee3629..dc744fa39b75 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2991,9 +2991,19 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
>  
>  	ktime_get_coarse_real_ts64_mg(&now);
>  
> -	/* Clamp the update to "now" if it's in the future */
> -	if (timespec64_compare(&update, &now) > 0)
> -		update = now;
> +	/*
> +	 * Clamp the update to "now" if it's in the future. The coarse time
> +	 * can trail an update just past a fine-grained ctime handed out in
> +	 * the current tick, so check a fine-grained time before clamping.
> +	 * That also raises the floor past the update, so later coarse
> +	 * stamps can't land before it.
> +	 */
> +	if (timespec64_compare(&update, &now) > 0) {
> +		ktime_get_real_ts64_mg(&now);
> +		mgtime_counter_inc(mg_fine_stamps);
> +		if (timespec64_compare(&update, &now) > 0)
> +			update = now;
> +	}
>  
>  	update = timestamp_truncate(update, inode);
>  
> 
> -- 
> 2.56.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
