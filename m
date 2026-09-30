Received: from mail.stoffel.org (mail.stoffel.org [172.104.24.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 564AD4D1787;
	Wed, 30 Sep 2026 14:39:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=172.104.24.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790779170; cv=none; b=aFMKUo42pRbAygI7DTcicLLqZGxvQbXVGtUJA4kARImMoETswOFnfygm7kW0prbyPjzAP4dr3se4Ii0BbWXAdMLxVardoK/2dPW/gZuZB12k+I1mb1FLX5oH+Yy3UT8ME6G7D7nsAmk/hsTjEdYM4xdqbJHoTOGq8MRDPrO4VTk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790779170; c=relaxed/simple;
	bh=FFtl3eMz38cKpuS+eUmq9WwFvbvIpsH78hd6U0Jp89c=;
	h=MIME-Version:Content-Type:Message-ID:Date:From:To:Cc:Subject:
	 In-Reply-To:References; b=VFOMEiXazS6ASGb/BdzVwVOfhhIeQn+8/6Wmqjzq9X4TtYTcyCLGb/nWHcp4Qb9wIxnGnYUSiadTsVey22Xsr85m0LTBb9bdjrmt4n4cADdh1qcgImTewA7IKTEwU/czxAe9+2FX4yRjVKaNFh7XPJKryUxAicb7qHwUG3lGiH8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org; spf=pass smtp.mailfrom=stoffel.org; dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b=b/DP49qy; arc=none smtp.client-ip=172.104.24.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stoffel.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b="b/DP49qy"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=stoffel.org;
 i=@stoffel.org; q=dns/txt; s=20250308; t=1790778725; h=mime-version :
 content-type : content-transfer-encoding : message-id : date : from :
 to : cc : subject : in-reply-to : references : from;
 bh=FFtl3eMz38cKpuS+eUmq9WwFvbvIpsH78hd6U0Jp89c=;
 b=b/DP49qyDUoYoN1ftx3i/EVbXMKH3maR4RPJaDB/9baMUoLIeOIo3FLDNdfFyQPUB7ulP
 eYf4eR1Xb8xzcsfHSCWqOkUUIega2+JSsfzZLVo08ad9ATMt/5xWQVoEfevrZusBr8KXTBb
 Vp8U63ERr/Hp2EaEd2DTfjmGXSj/XlA85k9EmL6TlhZjfyil5THZrRc5EqPiuttaBtmZG3L
 a7+X807cTSoAqB+3nTKgTBbgaAyAhhSHxgG0Zl5G/qO3S3fQgQaS0PXy0aQk+Qe11sdUxBE
 xlr92Q6+3hnSeGeFLD672o9Jk/niGfxQ6Y+usQV6oYP8vZg5ex5JUW2b77kw==
Received: from quad.stoffel.org (unknown [24.177.6.168])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by mail.stoffel.org (Postfix) with ESMTPSA id 6A0B31EC9E;
	Wed, 30 Sep 2026 10:32:05 -0400 (EDT)
Received: by quad.stoffel.org (Postfix, from userid 1000)
	id 0D216A3316; Wed, 30 Sep 2026 10:32:05 -0400 (EDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <27325.7525.26178.516077@quad.stoffel.home>
Date: Wed, 30 Sep 2026 10:32:05 -0400
From: "John Stoffel" <john@stoffel.org>
To: NeilBrown <neil@brown.name>
Cc: Trond Myklebust <trondmy@kernel.org>,
    Anna Schumaker <anna@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    Christian Brauner <brauner@kernel.org>,
    Jeff Layton <jlayton@kernel.org>,
    Jan Kara <jack@suse.cz>,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-kernel@vger.kernel.org
X-Clacks-Overhead: GNU Terry Pratchett
Subject: Re: [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 nfs_atomic_open()
In-Reply-To: <20260929022547.1428036-4-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
	<20260929022547.1428036-4-neilb@ownmail.net>
X-Mailer: VM 9.0.0snapshot under GNU Emacs 28.2 (x86_64-pc-linux-gnu)

>>>>> "NeilBrown" == NeilBrown  <neilb@ownmail.net> writes:

> From: NeilBrown <neil@brown.name>
> It is important that two non-create NFS "open"s of a negative dentry
> don't race.  They both have only a shared lock on i_rwsem and so could
> run concurrently, but they might both try to call d_splice_alias() at
> the same time which is confusing at best.

> nfs_atomic_open() currently avoids this by discarding the negative
> dentry and creating a new one using d_alloc_parallel().  Only one thread
> can successfully get the d_in_lookup() dentry, the other will wait for
> the first to finish, and can use the result of that first lookup.

This paragraph is confusing, and I'm not sure which thread can use the
result of the first lookup from this description.  

> A proposed locking change inverts the order between i_rwsem and
> d_alloc_parallel() so it will not be safe to call d_alloc_parallel()
> while holding i_rwsem - even shared.

> We can achieve the same effect by causing ->d_revalidate to invalidate a
> negative dentry when LOOKUP_OPEN is set.  Doing this is consistent with
> the "close to open" caching semantics of NFS which requires the server
> to be queried whenever opening a file - cached information must not be
> trusted.

> With this change to ->d_revaliate (implemented in nfs_neg_need_reval())
> we can be sure that we have exclusive access to any dentry that reaches
> nfs_atomic_open().  Either O_CREAT was requested and so the parent is
> locked exclusively, or the dentry will have DCACHE_PAR_LOOKUP set.
> [Note that when nfs_neg_need_reval() returns 1, ->d_revalidate returns 0].

> This means that the d_drop() and d_alloc_parallel() calls in
> nfs_atomic_lookup() are no longer needed to provide exclusion

> There is still a d_drop() which allowed d_splice_alias() to succeed.
> This will be removed in a future patch.

> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/nfs/dir.c | 30 +++++++-----------------------
>  1 file changed, 7 insertions(+), 23 deletions(-)

> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 4f1bf45b0c70..f219cc1a5fc5 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1656,6 +1656,13 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
>  {
>  	if (flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
>  		return 0;
> +	if (flags & LOOKUP_OPEN)
> +		/* close-to-open semantics require we go to the server
> +		 * on each open.  By invalidating the dentry we
> +		 * also ensure nfs_atomic_open() always has exclusive
> +		 * access to the dentry.
> +		 */
> +		return 1;
>  	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
>  		return 1;
>  	/* Case insensitive server? Revalidate negative dentries */
> @@ -2113,7 +2120,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>  	struct inode *inode;
>  	unsigned int lookup_flags = 0;
>  	unsigned long dir_verifier;
> -	bool switched = false;
>  	int created = 0;
>  	int err;
 
> @@ -2158,17 +2164,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>  		attr.ia_size = 0;
>  	}
 
> -	if (!(open_flags & O_CREAT) && !d_in_lookup(dentry)) {
> -		d_drop(dentry);
> -		switched = true;
> -		dentry = d_alloc_parallel(dentry->d_parent,
> -					  &dentry->d_name);
> -		if (IS_ERR(dentry))
> -			return PTR_ERR(dentry);
> -		if (unlikely(!d_in_lookup(dentry)))
> -			return finish_no_open(file, dentry);
> -	}
> -
>  	ctx = create_nfs_open_context(dentry, open_flags, file);
>  	err = PTR_ERR(ctx);
>  	if (IS_ERR(ctx))
> @@ -2219,10 +2214,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>  	trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
>  	put_nfs_open_context(ctx);
>  out:
> -	if (unlikely(switched)) {
> -		d_lookup_done(dentry);
> -		dput(dentry);
> -	}
>  	return err;
 
>  no_open:
> @@ -2245,13 +2236,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>  			res = ERR_PTR(-EOPENSTALE);
>  		}
>  	}
> -	if (switched) {
> -		d_lookup_done(dentry);
> -		if (!res)
> -			res = dentry;
> -		else
> -			dput(dentry);
> -	}
>  	return finish_no_open(file, res);
>  }
>  EXPORT_SYMBOL_GPL(nfs_atomic_open);
> -- 
> 2.50.0.107.gf914562f5916.dirty


