Received: from mail-wm2-f12.google.com (mail-wm2-f12.google.com [74.125.225.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B17D61FC0EA
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 15:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789312546; cv=none; b=PUAo/dny5RmsPSLTvP1dO8ttSjlmzs/OL0WkroYfL1TenR6jZW8z4uQJzIXZoEXyrojtzKdD8nCdNvoS5f0m/6Q4Lm8A6TUfk7M77vM1yUwushmmramb2SrnROr1Q9/vPbwQ1K3mHZweGJj+2u06ZgfgeQSHyAOs4trPUAPFV4I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789312546; c=relaxed/simple;
	bh=dEKz0PzGiux9Qf8eTTrPhDJKNcQFepLZ/wXcnPI5k1Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=APvRsMcDXe6vhu4NA4OqKqeD5NL9nSv+c68jAmyeursKdXx9FuOCEuwTMyMKpO76K+JBCQBtl5vNDHHKQHUMTrtv5tSza1Vgx2W+DqT10vizlIJ18mQjJAjT8gIgUT68lONmCpUu/aG9BjpH51E6j1QXEL69vnQq/1IiP/vpovo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=BpT3cc5+; arc=none smtp.client-ip=74.125.225.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BpT3cc5+"
Received: by mail-wm2-f12.google.com with SMTP id 5b1f17b1804b1-49e69b9e16aso10678135e9.1
        for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 08:15:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789312543; x=1789917343; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=K65DQ7/mv19GPFstsuzavHNy0KooVpltR7HBiL1fu1w=;
        b=BpT3cc5+4bbaDzeVXEyIgHZLqMLad7+6W70gxJM7xfIVtYK8ohIG3JNi8bt6sBYOD1
         nShect9D72clDLIj9XV1CdvufcC9Drt/kPafLHzS93AGgEkB6GNhBpmrvoUBETuxEWpz
         qTIQmZtQMTSHuAHBDl1u6it7fveCvdrsImmZYh/Hx8rRSujCDPDshDeBnhXeAJ/b2Uj8
         pHCwI9Qvm7NSJbhVZ3Z/l4ARZiDJQw9oz9CGObmk71R1GiPo0GThrxdImFQQh/SrBRy5
         QRSx5z0+8uISpvUf7+RouevVSp0vageSF/qbB8WaL+N2EsC67nfVIvt5hHSooCg7HUE9
         ShQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789312543; x=1789917343;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=K65DQ7/mv19GPFstsuzavHNy0KooVpltR7HBiL1fu1w=;
        b=Jfknogfg9TCn8iajO0GKR8i+CSGKRE3ZWcbwrZ8GaFZlHjOVsZtvMgki4+iI85jV32
         eoUP5+TSTAZbJmHbc7ROFFMeTZD1YLkh+p+qnF68VqIFPUHDp7So4b3pc900WweJ0JTi
         XjwRBzgC11SxjnzRPMtFgyN36Pr26CxP0tlrILTRqIf8ONhDcsLP5GlDUrKPSRODMvSL
         UVG9HY78dMIAVYHlPyHdTJAof3nrZYwEOABAK0KLJySRrJtDWUIeW+0RyldYlNZsE5l0
         /XPN060GzbZiwlAPVQyhCSNmAI2zG6q9x8rQD05TiA43/uVgvBFpOxzQmypl5+ggJ4El
         yAbA==
X-Forwarded-Encrypted: i=1; AKwUvBwKbhcJMajudLDDOwlKmUk+ds2ghvxbPqkC4MhTLxZmBk9Db/EJ9S/HCycjSUT1J8ufisGGrU4vhkc=@vger.kernel.org
X-Gm-Message-State: AFuF++lTfibKk4DY0GmHU1yVY44fP7KfpKW237ot7DNJ1vLDW28m56If
	Z54s2wJKhgechrSdO0rSz9uqHh6upB9OhKgt4XZ957u8kfYxGaXA9OWQ
X-Gm-Gg: AYBFou0UnmC46+q53i60NW3xxfPezhWlAV7k9LsyjA4bSHVJDKsBTt1QIPdm6NqK2mn
	xjCT6hhKjWK+McF1oeGWwZd6kNgRO9nZgx8ntSXhMvYb+JW7JtBsTf5X4hCC+lqtP059DlXMvmk
	1hBi2umMTQO/0llMSOqq0PAgTGr2WtdQOfn7j/83Qid5QGWhxrguVt6fsY62x7z64sR/A4JsGop
	++LWVSxD8O9pkltYFmdsp3ouQdeLs+reNTPtG47FxCC6e3Nipe9s5w8F6sqpHj/0rAylEZJzCPh
	ij5QazWXV0nhoL5LrX0h6nAaxgaAzGOGl8TajC5gP+g0rItQc9liX7c7CLQaW37IkBhudGZf4Px
	BpdLb0oeOhDQ8raPZL2MxLG3FWorSEG+HnlirkPnV1DteoJajOK09Qp4hDy/TSZk9dr3ynxSSHj
	RYIeyBHW9FkAaQ7m4Yxpb91x4vhIJDDg5+sCJbM/Ab83AlUNy1Yy2g2E+gq8DLukkr7ooCon9xQ
	NtezIQlYneCpDpBAqivRIgS2t6Xmj2+rrIzmpT3
X-Received: by 2002:a05:600c:3554:b0:49c:fa21:1c81 with SMTP id 5b1f17b1804b1-49e6cbfbfb1mr62189835e9.22.1789312542853;
        Sun, 13 Sep 2026 08:15:42 -0700 (PDT)
Received: from f (cst-prg-84-1.cust.vodafone.cz. [46.135.84.1])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49e60acff8bsm244462855e9.9.2026.09.13.08.15.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 13 Sep 2026 08:15:42 -0700 (PDT)
Date: Sun, 13 Sep 2026 17:15:33 +0200
From: Mateusz Guzik <mjguzik@gmail.com>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
Message-ID: <2mr6afww7r67o2hjblafhdwqffg3zicsqjkddnquunfaalolpd@yq54r5nlqftm>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-5-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
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

Does anything prevent the child from flipping over to regular?

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


I would say this is the wrong approach to the API. The path dentry
switching is a massive hack and should be avoidable. So happens I was
working on cleaning up the overall handling and you convinced me to post
the patchset early, see:

https://lore.kernel.org/linux-fsdevel/20260913144918.1606123-1-mjguzik@gmail.com/

On top of that the routine as is has avoidable refcount traffic and it
seems you are adding to it. Instead it can switch to vfs_open_consume.

On cursory reading of the nfs patch, the following should do the trick instead: split the
helper into 2 parts (say vfs_open_lookup + vfs_open_lookup_finish, maybe add
vfs_open_lookup_abort should the caller decide to not go through with
the open).

Then in nfsd you could have something like this:
struct vfs_open_lookup_arg v;

vfs_open_lookup(&v, parent_path, ....);
[ child dentry is in v->path->dentry, do arbitrary work with it]
if (ok)
	file = vfs_open_lookup_finish(&v);
else
	vfs_open_lookup_abort(&v);

The new struct would hide 'struct file' and whatever else
vfs_open_lookup might want to allocate first.
