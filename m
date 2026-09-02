Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23415493642
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 12:40:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788352859; cv=none; b=U0w9UNDVtZyAvzByJcyGgXh8E1djm1epN9wNtiwxjYikSfpBJYqexywa0prupY613/gzZwRapBFT5g3C2rdbRCaV3aYwxs8JySZWw86VYJ4pTj8CAxGyoi4ludUqydCGVdEA9EhCHk5bhvpxyzUzKxspEAdec+ZvXfXTjEkoahg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788352859; c=relaxed/simple;
	bh=yxGj2Wl0Tzgg9qadszNqRvS0ycDJ+XGCVEfMchMGKGU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=YtG5SHGkJhgVZ7n2/wnzeZjUdp2UaAhJkVZ2qWJWYuMGyRYk6h/rRUvejeW41mgInq+hHhhOu7tUfMhidfOKzhVPfdC7Fjs5U2RgVTJ5NAzcMb7VYG3b0H9Z2kqdagFTTvFnOFAiNAVSicasAWuHBjmKtqRecGhTJAgp4MfLYSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Yvo5OB2j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Yvo5OB2j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 635BB1F00A3A;
	Wed,  2 Sep 2026 12:40:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788352857;
	bh=UUmNrwmO6AKpqtNeD6KjbxQQM4fIdhGvt368xOqmFd4=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Yvo5OB2jlZTUBLH0Z1h2mhnG04ngBGJ3Rj45FoKyz+WYj30bpjuq4qc05biXuuyiZ
	 N3x4u8+0Ust4MorEtWWNbPMMb1SB69TwXFQ2DQDvWYbRuk4Dq5Apw2GsoYsGo3CwB2
	 q0AANjUgiJUJqWVNMSu9IZmIHvphWEV+Rqnl1MoqGrVO5FJeYmYZRg8qN/gmdQRwn8
	 DPekfD5jWdZIVOoQQ9XADT8C20iRGYGUoQi8CQR3u6V4/Z3qkMSnxvYcx/jig6USt7
	 EjukzqOheGWb5LW14tyahk45Rh18RhlGLXT4Ee0ua0+VlqOKIMrcNBeAUM9um6AvV/
	 TJaJzFn3hF7FA==
Message-ID: <35959e0bcd4223ccf8e258962e56bdb1ad6d48f9.camel@kernel.org>
Subject: Re: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>, Chuck Lever <chuck.lever@oracle.com>
Cc: Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org
Date: Wed, 02 Sep 2026 08:40:55 -0400
In-Reply-To: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
References: 
	<178831622346.3510150.10735958308429473076@noble.neil.brown.name>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-09-02 at 12:30 +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>=20
> The functionality that was recently gathered into do_lookup_open() is
> now available from the vfs as vfs_lookup_open().
>=20
> This implementation shares more code with syscall open paths and so uses
> some filesystem interfaces slightly more correctly.  It also takes the
> responsibility for locking out of nfsd so that planned changes can
> happen entirely in VFS code.
>=20
> One difference is that do_lookup_open() would use nfsd_check_obj_isreg()
> to get an error when the name exists but is not a regular file.
> vfs_lookup_open() uses slightly different error code, particularly
> returning -ENODEV when a device-special file is found.  So we need
> to map that error to -EFTYPE.
>=20
> Unfortunately vfs_lookup_open() doesn't allow O_LARGEFILE so we need
> to patch it to avoid a warning.
>=20
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c         |  2 +-
>  fs/nfsd/nfs4proc.c | 66 ++++++++++------------------------------------
>  2 files changed, 15 insertions(+), 53 deletions(-)
>=20
> This patch is against nfsd-test.  I would like it to land there so it
> best good nfsd testing over the coming weeks.
> Thanks,
> NeilBrown
>=20
>=20
> diff --git a/fs/namei.c b/fs/namei.c
> index d95249dd527c..85fd5e8221e2 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
>  	int error =3D 0;
> =20
>  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> +	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_=
LARGEFILE),
>  		  "open_flag has unsupported flags");
> =20
>  	mode |=3D S_IFREG;
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 33dc92d48ce0..ae70f7489d95 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -213,52 +213,6 @@ static inline bool nfsd4_create_is_exclusive(int cre=
atemode)
>  		createmode =3D=3D NFS4_CREATE_EXCLUSIVE4_1;
>  }
> =20
> -static struct file *do_lookup_open(struct path *parent,
> -				   struct qstr *name,
> -				   unsigned int oflags,
> -				   umode_t mode)
> -{
> -	struct file *filp =3D NULL;
> -	struct path path;
> -	struct dentry *child;
> -	int want_write_err =3D 0;
> -
> -	want_write_err =3D mnt_want_write(parent->mnt);
> -
> -	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
> -	if (IS_ERR(child)) {
> -		filp =3D ERR_CAST(child);
> -		goto out;
> -	}
> -	path.mnt =3D parent->mnt;
> -	path.dentry =3D child;
> -
> -	if (d_really_is_positive(child)) {
> -		/*
> -		 * open the file so that we consistently have a valid
> -		 * op_filp and consequently a valid ->f_path.dentry.
> -		 */
> -		int err =3D nfsd_check_obj_isreg(child);
> -
> -		if (err)
> -			filp =3D ERR_PTR(err);
> -		else
> -			filp =3D dentry_open(&path, oflags, current_cred());
> -	} else if (!(oflags & O_CREAT)) {
> -		filp =3D ERR_PTR(-ENOENT);
> -	} else if (want_write_err) {
> -		filp =3D ERR_PTR(want_write_err);
> -	} else {
> -		filp =3D dentry_create(&path, oflags, mode, current_cred());
> -		child =3D path.dentry;
> -	}
> -	end_creating(child);
> -out:
> -	if (!want_write_err)
> -		mnt_drop_write(parent->mnt);
> -	return filp;
> -}
> -
>  /*
>   * Implement NFSv4's unchecked, guarded, and exclusive create
>   * semantics for regular files. Open state for this new file is
> @@ -390,13 +344,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  		/* Might still succeed if no create is needed */
>  		oflags &=3D ~O_CREAT;
> =20
> -	open->op_filp =3D do_lookup_open(&parent,
> -				       &QSTR_LEN(open->op_fname,
> -						 open->op_fnamelen),
> -				       oflags,
> -				       open->op_iattr.ia_mode);
> +	open->op_filp =3D vfs_lookup_open(&parent,
> +					&QSTR_LEN(open->op_fname,
> +						  open->op_fnamelen),
> +					oflags,
> +					open->op_iattr.ia_mode);
>  	if (IS_ERR(open->op_filp)) {
> -		status =3D nfserrno(PTR_ERR(open->op_filp));
> +		int hosterr =3D PTR_ERR(open->op_filp);
> +
> +		/*
> +		 * NFS doesn't differentiate between device files and
> +		 * sock/fifo when reporting an error.
> +		 */
> +		if (hosterr =3D=3D -ENODEV)
> +			hosterr =3D -EFTYPE;
> +		status =3D nfserrno(hosterr);
>  		open->op_filp =3D NULL;
>  		if (status =3D=3D nfserr_noent && create_status)
>  			status =3D create_status;
>=20
> base-commit: f5dc2038906bb0c9627c99bea06dd7786b5ac2d1


This looks good to me, but sashiko noted a lockdep issue you probably
want to address:

    https://sashiko.dev/#/patchset/178831622346.3510150.1073595830842947307=
6%40noble.neil.brown.name

Other than that though, this looks good to me. Much less "fiddly".

Reviewed-by: Jeff Layton <jlayton@kernel.org>
