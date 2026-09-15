Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.186])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAC0739EF0B
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 14:38:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.186
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789483103; cv=none; b=t5NzSoJuITzFtX1nRXrkVi6Y1NcdgMyx17zSI7GmoyxZO1tX680291tYe7QgvIyHCe3LJAG4uy2vY6SrzoaLWa80uCqcyYeBYR5Bz1Woa+HB/LOu/f9hli3yQwZwVUauPZ9bLSKN+CIeMNhFO0qY6Lk2ZwDetAp8dvWZ4Vr8+Yk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789483103; c=relaxed/simple;
	bh=3sMwBj6EjpnIrW/YR3z/pEEMTvg1+HdBxjrQkcnDtp4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hnJYnWJNFbHNW9/faocYJ05+fRdvf0B7vNaK7tQMjaj0YiS+m5PRmAqphCWfUYCLkpS5zFkH3ICGpdpvEnLl0YkSaaU9YTj91ZAWIcL0dUSr/h+5uqLksM6mT3MmCFDMWMDyDzOZK1FB9yrEIYTEjJSGQnscRp8N/ruxciTDWqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=H6hRwvbC; arc=none smtp.client-ip=195.121.94.186
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="H6hRwvbC"
X-KPN-MessageId: 12677b7b-b113-11f1-bfbc-00505699b430
Received: from smtp.kpnmail.nl (unknown [10.31.155.8])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id 12677b7b-b113-11f1-bfbc-00505699b430;
	Tue, 15 Sep 2026 16:38:09 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:message-id:subject:to:from:date;
	bh=iPBqovkglEv0AxkNg3xAZJuxtCsm++aFDQ+7iUhryAE=;
	b=H6hRwvbCswId+aT1A/vy38KSFElUOfhVJuFPrwOHI3UyM++QkTaDxvnYNBMc04jyS/1uIgGLCb9dW
	 hGCjPoBpgzs+EzHQXwvnyltU+hgyzdwO5iKQPr+04w+T89ndR28MAgEunp/jX2lvlZXHr9ZvKe5/oC
	 aUE/eJ56W2kKmge6Bc4bVTnPU1mUxeK/VHjLCVQsvjg5LLvnj8Z/qmVfvWpOuqID6xbS4lAJP+heCi
	 Rs73G6ROHlzMiohfV7vRxd/xEz9SYHHXl0CO6jfiDj06ifIfu8F+kFLf+xyPiLZ3WEfhJqm2cofXvf
	 NXOa/j+5lT3bfp0KmlR3EFJgT/WEMKQ==
X-KPN-MID: 33|ATKdb7AXREEm7alqU6HuTsDyxI+kHOHxtlCbpw7rhwy84dcZvdBn/7lyupQRHcK
 OSTS7kdpbaI52qLPZiOLMzMrEKj+QnMWj+ERr4awtgA4=
X-KPN-VerifiedSender: Yes
X-CMASSUN: 33|JTvtUtOH1oSL1LiKbqEWSp+1QgWJwXyDMYVvZMj2ow1Vqpo9yaYK2NR+0i5hZRi
 0Wwx8ud9EPu32WrWej1egvg==
Received: from localhost (unknown [178.226.150.234])
	by smtp.xs4all.nl (Halon) with ESMTPSA
	id 11ff81e6-b113-11f1-8ddf-00505699d6e5;
	Tue, 15 Sep 2026 16:38:09 +0200 (CEST)
Date: Tue, 15 Sep 2026 16:38:03 +0200
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
Message-ID: <aqlXZ7Gunepk_4uV@lt-jori.localdomain>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-5-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260910002934.192979-5-neilb@ownmail.net>

On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
> 
> The caller - nfsd - needs to know the type of object found when a
> non-regular file was found to exist.  This is most easily done
> by passing back the dentry.
> 
> So change calling pattern so that the path (now called "path") contains
> the parent dentry on entry and the child dentry on exit.
> vfs_lookup_open() will dput() the parent and caller must dput() the
> child.
> 
> If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> dentry to the dcache we return %NULL in %path->dentry.
> 
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 0c787363b101..30ccc0c2f02f 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
>  
>  /**
>   * vfs_lookup_open - open and possibly create a regular file
> - * @parent: directory to contain file
> + * @path: directory to contain file
>   * @last: final component of file name
>   * @open_flag: O_flags
>   * @mode: initial permissions for file
> @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
>   * If the fs object found is not a regular file then -EFTYPE is
>   * returned.
>   *
> + * @path is updated to contain the dentry that was found if possible.
> + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> + * object that is not a regular file, or %NULL.
> + * Consequently the caller must be prepared for @path.dentry to be
> + * dput(), an it must dput() whatever is in @path.dentry after the call.
> + *
>   * Returns: the opened struct file, or an error.
>   */
> -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
>  			     int open_flag, umode_t mode)
>  {
>  	struct file *file __free(fput) = NULL;
> @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	mode |= S_IFREG;
>  	open_flag |= __O_REGULAR;
>  
> -	error = lookup_noperm_common(last, parent->dentry);
> +	error = lookup_noperm_common(last, path->dentry);
>  	if (error)
>  		return ERR_PTR(error);
>  
> @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	if (IS_ERR(file))
>  		return file;
>  
> -	nd.path = *parent;
> +	nd.path = *path;
>  	nd.last = *last;
>  	nd.flags = LOOKUP_OPEN;
>  	if (open_flag & O_CREAT) {
> @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	op.mode = mode;
>  	dentry = lookup_open(&nd, file, &op);
>  
> -	if (IS_ERR(dentry))
> +	if (IS_ERR(dentry)) {
> +		if (dentry == -EFTYPE) {
> +			/* Try to determine what was found */
> +			struct dentry *child = d_lookup(path->dentry, &nd.last);
> +			dput(path->dentry);
> +			path->dentry = child;
> +			WARN_ON_ONCE(child && d_is_reg(child));
> +		}
>  		return ERR_CAST(dentry);
> -
> +	}
> +	dput(path->dentry);
> +	path->dentry = dentry;
>  	if (d_really_is_negative(dentry)) {
>  		error = -ENOENT;
>  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
> @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	} else if (!d_is_reg(dentry)) {
>  		error = -EFTYPE;
>  	} else if (!(file->f_mode & FMODE_OPENED)) {
> -		nd.path.dentry = dentry;
> -		error = vfs_open(&nd.path, file);
> +		error = vfs_open(path, file);
>  	}
> -	dput(dentry);
>  
>  	if (error)
>  		return ERR_PTR(error);
> -- 
> 2.50.0.107.gf914562f5916.dirty
> 

OK, so if I understand the problem correctly: the current implementation
does not work for the purposes of NFS because ->atomic_open() may return
EFTYPE on O_REGULAR and then you still don't know what that found dentry
was.

An arugument with such specific calling conventions feels kinda yucky
and easier to get wrong. Why not an out enum arg that specifies the
found dentry type? Seems at least a bit cleaner. What do you think?

Best,
Jori.
