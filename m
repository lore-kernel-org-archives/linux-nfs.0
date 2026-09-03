Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CF9A3EC82A;
	Thu,  3 Sep 2026 09:37:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788428238; cv=none; b=B4PJz+ibJbjWqSVsY0edYB8Th1ZQC1b3qG3XbVKxCpSVzwdSZon1KwJL/jjpCSAkZC6thFRaOWuZRG8yZk4r/925rYuiXl6ogl14OnnfP9gReyGIb+dUR+O82aa/qHBIDoeBA0truPP9vjVGIprB4V29pd9v1nRql+gS1szfS+U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788428238; c=relaxed/simple;
	bh=FPjfhF3k9V3+9UL/NSmwro9U3MXqTrk2tNthB1C1Qs4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pu4tpZhrWuz384/LArQSaZeGOYzS3bBkem85YQJydVtjv4u4Ulm6E0HduKV3Lb5wY1RBwbOILYnxtGHiCrsPRIgEQZy260HzsCdpBCJquQFw8ALzWnoYMWC7ui5ShOE4VyiNP+gZyQYb6/z+FFlu3Zx3RYMJdjoy8QqgVQ2NRjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=iFgBmr8C; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=n/NqC4Fp; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=elwrXNmM; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=Wvmk0PIH; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="iFgBmr8C";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="n/NqC4Fp";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="elwrXNmM";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="Wvmk0PIH"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 2C6491FDEE;
	Thu,  3 Sep 2026 09:37:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788428230; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=B2MzetJdmoKA6BgyFkbvWCTtiNNAt6T9i9NzyJMYtYM=;
	b=iFgBmr8C76UJiRquacdMO/pvI2ggiPLBNcfUM6xdJ+gmPT0n1dc5zlk65K7YvPbuAn2uUT
	Q7O3Bvw8rqcAsSSG3Q1Kb8GY94BDKeiuQrJGqC0hg+NQ6wycjptop9HIbNguHVA80WKbG9
	C5EPYC+HO/I4UWfd1SiVS+9SH0HRbxk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788428230;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=B2MzetJdmoKA6BgyFkbvWCTtiNNAt6T9i9NzyJMYtYM=;
	b=n/NqC4FpYXx8pp/NoBUEEZBuJ+HhgIqgg0WWfCLhsmWVZlyNxYoFZIaiUI7xL6K+T+84Ky
	x0Y6+DjH1fdLXmCg==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=elwrXNmM;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=Wvmk0PIH
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788428226; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=B2MzetJdmoKA6BgyFkbvWCTtiNNAt6T9i9NzyJMYtYM=;
	b=elwrXNmMJR/CfzacpudWQ16+gQB53wlkRUZYSuDYs632LHkBMcu2KdkFPRMBuVuLnzCvXo
	eN+QugG+YSQOGtbTCNuYQlKrTrh4E+Zi2T3RJ+n3BHtfEKxjgQvLubN5n388Hx+AuD7d/p
	/woRpkml8Fg9Ltr494wliR1SnQSuClA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788428226;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=B2MzetJdmoKA6BgyFkbvWCTtiNNAt6T9i9NzyJMYtYM=;
	b=Wvmk0PIHZPS2ffb8fzpiJD8qUKDJIJsvY/I3h89xrvpRUEbovlO5l1dvq/+CCuoyWZRxde
	yTn3eOt06MHh4tCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0B5BB136E6;
	Thu,  3 Sep 2026 09:37:06 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id +prBAsI/mWoibQAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 03 Sep 2026 09:37:06 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 9588CA13AC; Thu, 03 Sep 2026 11:37:05 +0200 (CEST)
Date: Thu, 3 Sep 2026 11:37:05 +0200
From: Jan Kara <jack@suse.cz>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/3] fs: stamp the current time for a stale delegated
 ctime update
Message-ID: <hszc7ektvbypy3thdw4iwh2cpnnjecwt7tu5s54ucay5yikcbg@wmcihhkjay2u>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
 <20260902-delegts-v2-1-383cb289ce88@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260902-delegts-v2-1-383cb289ce88@kernel.org>
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: 2C6491FDEE
X-Spamd-Result: default: False [-4.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.cz:dkim,suse.cz:email];
	ARC_NA(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_TWELVE(0.00)[13];
	MIME_TRACE(0.00)[0:+];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TO_DN_SOME(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	MISSING_XM_UA(0.00)[];
	FREEMAIL_CC(0.00)[kernel.org,brown.name,redhat.com,oracle.com,talpey.com,zeniv.linux.org.uk,suse.cz,gmail.com,vger.kernel.org];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Flag: NO
X-Spam-Score: -4.01

On Wed 02-09-26 14:54:14, Jeff Layton wrote:
> inode_set_ctime_deleg() drops an update that does not advance the ctime.
> That is correct when a client reports a timestamp that it advanced on its
> own. It is wrong when the client moves the timestamp backwards on purpose,
> as utimensat() does.
> 
> Stamp the current time in that case. The ctime still never moves backwards.
> 
> Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
> Assisted-by: LLM
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

Looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/inode.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index ba7da39be4a3..8391814a4016 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2959,11 +2959,17 @@ EXPORT_SYMBOL(inode_set_ctime_current);
>   * inode attributes, including the mtime. When updating the mtime, update
>   * the ctime to a value at least equal to that.
>   *
> - * This can race with concurrent updates to the inode, in which
> - * case the update is skipped.
> + * The ctime never moves backwards. An @update that does not advance the ctime
> + * records the current time instead, so that the delegated change is still
> + * visible in the ctime.
> + *
> + * This can still race with a concurrent update to the inode. That stamp takes
> + * precedence, and is at least as recent as the one it displaces.
>   *
>   * Note that this works even when multigrain timestamps are not enabled,
>   * so it is used in either case.
> + *
> + * Returns the resulting ctime.
>   */
>  struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 update)
>  {
> @@ -2975,9 +2981,12 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
>  	cur_ts.tv_nsec = cur & ~I_CTIME_QUERIED;
>  	cur_ts.tv_sec = inode_get_ctime_sec(inode);
>  
> -	/* If the update is older than the existing value, skip it. */
> +	/*
> +	 * The update does not advance the ctime. Stamp the current time, so
> +	 * that the delegated change is still visible in the ctime.
> +	 */
>  	if (timespec64_compare(&update, &cur_ts) <= 0)
> -		return cur_ts;
> +		return inode_set_ctime_current(inode);
>  
>  	ktime_get_coarse_real_ts64_mg(&now);
>  
> 
> -- 
> 2.55.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
