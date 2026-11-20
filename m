Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795169888;
	b=pLlO1aJP7r5R/+HovGXPhwfVjM6rS5NrSAbf7PJhgsKrQ4UvHACiOPd52QhK72r6gfUP
	 KqdBfOkfsqWfhHI/sZvz6sfK8atBhxEHg4v3dYXcvRNB5l+MRozt7GN5hjEJ89wv1iAiv
	 04vnx+vMbQaq/AMrTDVKLYRVixikrBMjioFRt2dzsB+ZZzxpmPgvuqBqCd46j2cdPx2+f
	 yio7ejiUDxzIpGJ39xp9OKPCxvwPYU5ipusq00uQvOlJU1Klk2bvfZPPU8gPhKPhoQIJh
	 p53yF58CHW0mK0J5b9joYNRA9w1U+YVAjTz6b8qT0LMJcBpjCYOz6KUK1AjGu73E0Tg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795169888;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=cShgqmEjCIaFniANx893GoDW4eS9/ac+wxBefCqedZI=;
	b=QP7Do5PI9b8M59GF+DWRwrBUbXkBZp9csGWvZ/90JqFGFHBzvT0sRWnvtmBB6mJ0tCdk
	 3bgivDnQ1vzr3+SmI2EO5gkQv3lAmPgf4v0UdrJ2H8yqZamm7zk9sCzdLdy53f7i7U6+Z
	 CwXWF5V+lJS73k/XuwfY/PPgVdPFJ5UmDP+BQk2r0Mt0E0Nml1oZ7T2VX0UQaVZptw9R/
	 L8W18o99eXo9tayWjBRwaii8mUKPuuVJpqiGk6lOHtQgjo+yn5INuxxTO3bkbEh4N70oY
	 1eEQ1em85xOw9jrK2AVB4oxUznJ9Z5m8Z2WMpGUR9hxdjPivhjvHxxqQFDVKCnDYo4g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=S6bDxjvB;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=CnEkxrKg;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=BmnUXvbM;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mqh1WGjT;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95EB5606A320;
	Fri, 20 Nov 2026 10:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 95EB5606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=S6bDxjvB;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=CnEkxrKg;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=BmnUXvbM;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Mqh1WGjT
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id D840E2260C;
	Fri, 20 Nov 2026 10:18:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795169885; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cShgqmEjCIaFniANx893GoDW4eS9/ac+wxBefCqedZI=;
	b=S6bDxjvBi7+R/U4akBuwBpoA4dXLBfKuAtHO6Pr1QL02FTL5imzg5FRcmATdCjQpfaDnPo
	HHT2rkeZBgOb/98QgcH34lWsFKhjM/3lYqMjEgWhAtTLy8UrzLYt8JTmMwGtbU2TRfoYMM
	QKfdPaSZF1b/eJ98re111vXMggTXcqE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795169885;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cShgqmEjCIaFniANx893GoDW4eS9/ac+wxBefCqedZI=;
	b=CnEkxrKg5VdRVSs+ZtqzIm+Jv57L64yBSqtl4nKhsjqCNFfMCkApJbVZAUkh+N/hwLChG+
	DRrJ1WSJxkvFHDDA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795169884; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cShgqmEjCIaFniANx893GoDW4eS9/ac+wxBefCqedZI=;
	b=BmnUXvbMttNIQUuIdX6FiQK8d8JzJdnXX+R7wj9JTPGWysEcj8LeJsIX9fYFPYaey8+egz
	e53vmqGbkhzwLEj5MDNYsV6TfLUCoIm2/NQxVb4bU4sRZZvjYyUdA4WMRmDLx+3VciDMK9
	uroYl+DzcIo4NHoNerfUU7LgWtcMOP4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795169884;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cShgqmEjCIaFniANx893GoDW4eS9/ac+wxBefCqedZI=;
	b=Mqh1WGjTY4av+oDCW45wGueaYhnkD8vSV8ALYCV/G7oy75uKe5rBbE7053g6X0NdwpVL3G
	YW/U7qx7uT6F2tAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id AA04E1348F;
	Fri, 20 Nov 2026 10:18:04 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id eI48IVweAGsXKwAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 20 Nov 2026 10:18:04 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 3A13225F06; Fri, 20 Nov 2026 11:18:04 +0100 (CET)
Date: Fri, 20 Nov 2026 11:18:04 +0100
From: Jan Kara <jack@suse.cz>
To: Dominik Maier <dmnk@google.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, dmnk+artist@google.com
Subject: Re: [PATCH 1/2] fs: export may_linkat() for nfsd
Message-ID: <oulbcydtyizbuup2eu3sigyx7dto7kjlap25sgjodyop2pr3ey@64zs5utv3vry>
References: <20261119192311.2684978-1-dmnk@google.com>
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
In-Reply-To: <20261119192311.2684978-1-dmnk@google.com>
X-Spamd-Result: default: False [-11.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MISSING_XM_UA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[13];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TAGGED_RCPT(0.00)[artist];
	RCVD_TLS_LAST(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -11.30
X-Spam-Level: 
X-Spam-Flag: NO

On Thu 19-11-26 20:23:10, Dominik Maier wrote:
> vfs_link() expects its callers to enforce protected hardlink policy via
> may_linkat() prior to creating a hardlink. Move the declaration of
> may_linkat() from fs/internal.h to include/linux/fs.h and export it with
> EXPORT_SYMBOL_GPL() so modular in-kernel file servers such as NFSD can
> invoke it before calling vfs_link().
> 
> This prepares for fixing missing hardlink restrictions in nfsd_link(),
> which was discovered by an AI-assisted code review tool (ARTIST),
> validated in QEMU without kernel modifications or error injection, and
> verified with kernel builds and checkpatch.pl.
> 
> Fixes: 800179c9b8a1 ("fs: add link restrictions")
> Cc: stable@vger.kernel.org
> Signed-off-by: Dominik Maier <dmnk@google.com>

Looks good. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/internal.h      | 1 -
>  fs/namei.c         | 1 +
>  include/linux/fs.h | 1 +
>  3 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/internal.h b/fs/internal.h
> index 3f2fbac..7c30669 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -54,7 +54,6 @@ extern int filename_lookup(int dfd, struct filename *name, unsigned flags,
>  			   struct path *path, const struct path *root);
>  int filename_rmdir(int dfd, struct filename *name);
>  int filename_unlinkat(int dfd, struct filename *name);
> -int may_linkat(const struct mnt_idmap *idmap, const struct path *link);
>  int filename_renameat2(int olddfd, struct filename *oldname, int newdfd,
>  		 struct filename *newname, unsigned int flags);
>  int filename_mkdirat(int dfd, struct filename *name, umode_t mode);
> diff --git a/fs/namei.c b/fs/namei.c
> index 925aeb6..8f7c2dc 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1385,6 +1385,7 @@ int may_linkat(const struct mnt_idmap *idmap, const struct path *link)
>  	audit_log_path_denied(AUDIT_ANOM_LINK, "linkat");
>  	return -EPERM;
>  }
> +EXPORT_SYMBOL_GPL(may_linkat);
>  
>  /**
>   * may_create_in_sticky - Check whether an O_CREAT open in a sticky directory
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 5b3a100..c165f27 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2740,6 +2740,7 @@ int may_delete_dentry(const struct mnt_idmap *idmap, struct inode *dir,
>  		      struct dentry *victim, bool isdir);
>  int may_create_dentry(const struct mnt_idmap *idmap,
>  		      struct inode *dir, struct dentry *child);
> +int may_linkat(const struct mnt_idmap *idmap, const struct path *link);
>  
>  static inline bool execute_ok(struct inode *inode)
>  {
> -- 
> 2.56.1.750.gf70dc682cf-goog
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
