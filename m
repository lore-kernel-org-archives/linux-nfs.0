Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 620A6470128
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 17:12:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786554771; cv=none; b=n9S63LMnOfcflq4w5tIzlLGrELtbhj42MdjbftWzav/tZBAHetVGDs5JxD+SlnZQaSx6hAWP783fjy5AGKAYN25/gVP3xKw0kOy0X0SnmL/5Px14bxkBy/HGL9OKUV7wiWoaOis9g2eGpwCbiWgX6+Jz68WURCIVjpNH1dxAT6c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786554771; c=relaxed/simple;
	bh=SutH1+UlxkFpxbPBlzK9gtrn6D3YmnGDscPvJZaHvJE=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=H+FcpO1Cmi3Lg9Z3mTHU45s/PTRovEQYrN8jVb3Q6bY0MnHSfwpccDygRBjoQ96LwwXkUJRbOT+GLU+VLB0zUI4/vTV0KpgcmDL2HsDoylSreiUc4FBYJSMyNRHcEyZ7fiUj744V9tqLerxeqz0K0iV583Zx36Gsa4Vmt/V6A/8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NzyGbPSb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NzyGbPSb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B69C21F000E9;
	Wed, 12 Aug 2026 17:12:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786554769;
	bh=uTB7o6HQ0tL1G1EpvDnE33+EHoi52MTp8KEjnxP1Kxg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=NzyGbPSbLBbNlhXbnIbIdrTbrysWNIojiyMZSBC0r9az6mUfOSOUO1QhX43N1xwa7
	 UVSI4x6OFdMGPMLEa1rD7/QyQ9AHwooyz1otwnyR3YX/uQmpc4tT+ioj2gcp0nv68o
	 qFN9cyyeYkKXV+6k778bYlRdRuBEHFni0wsCRskme6IhLQgbc4xNTly8e5gHMXYFaM
	 /UVlXI4ZCJmfGu4AxKw5HkvfJQ+HI8sH8uSrQElS5q6+BNTzKD1CbXgIZvb3SAF+2v
	 ibbFbdXkso1gJPZtm3KYGhlPyR7M/ZievBnk7Nh5rJ6y+u9nmm5K2H4dUCGMULofky
	 TmAgrd0aDOCGw==
Message-ID: <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
Subject: Re: [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating
 open requests too.
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>, Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org
Date: Wed, 12 Aug 2026 13:12:46 -0400
In-Reply-To: <20260717093001.1972119-19-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
	 <20260717093001.1972119-19-neilb@ownmail.net>
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

On Fri, 2026-07-17 at 19:28 +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>=20
> Now that we have do_lookup_open() for creating open requests, we can use
> it for non-creating too as do_lookup_open() is already able to do that.
>=20
> This prepares for switching to vfs_lookup_open() once the VFS provides
> that.  This will ensure consistent code and fs-interaction with VFS open(=
).
>=20
> The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
> moved into nfsd4_open_file() (renamed from nfsd4_create_file()) so it is
> closer to fh_full_post_attrs and fh_fill_post_noop calls.
>=20
> As ->op_create_mode isn't defined when op_create is zero, we need a
> local create_mode which is -1 (illegal value) when op_create is zero.
>=20
> The non-create path now doesn't use nfsd_lookup().  As mount-point
> crossing including nfsd_check_access() is already included for existing
> names, this does not lose us anything.
>=20
> We now only call mnt_want_write() is there is a flag which indicates we
> might want write access - previously O_CREAT was always set.
>=20
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++-----------------------
>  1 file changed, 56 insertions(+), 57 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b7fdc75c4b81..11d0411dec08 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct path *pare=
nt,
>  	struct file *filp =3D NULL;
>  	struct path path;
>  	struct dentry *child;
> -	int want_write_err =3D 0;
> +	int want_write_err =3D -ENOENT;
> =20
> -	want_write_err =3D mnt_want_write(parent->mnt);
> +	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
> +		want_write_err =3D mnt_want_write(parent->mnt);
> =20
>  	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
>  	if (IS_ERR(child)) {
> @@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct path *par=
ent,
>  }
> =20
>  /*
> - * Implement NFSv4's unchecked, guarded, and exclusive create
> - * semantics for regular files. Open state for this new file is
> - * subsequently fabricated in nfsd4_process_open2().
> - *
> + * Implement NFSv4's open semantics for regular files.
> + * Both create (unchecked, guarded, and exclusive) and non-create.
> + * Open state for this new file is subsequently fabricated in
> + * nfsd4_process_open2().
>   * Upon return, caller must release @fhp and @resfhp.
>   */
>  static __be32
> -nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> -		  struct svc_fh *resfhp, struct nfsd4_open *open)
> +nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct svc_fh *resfhp, struct nfsd4_open *open)
>  {
>  	struct iattr *iap =3D &open->op_iattr;
>  	struct nfsd_attrs attrs =3D {
>  		.na_iattr	=3D iap,
>  		.na_seclabel	=3D &open->op_label,
>  	};
> -	int oflags =3D O_CREAT | O_LARGEFILE;
> +	int oflags =3D O_LARGEFILE;
>  	struct dentry *child =3D ERR_PTR(-EINVAL);
>  	struct path parent =3D {
>  		.mnt =3D fhp->fh_export->ex_path.mnt,
>  		.dentry =3D fhp->fh_dentry,
>  	};
>  	__u32 v_mtime, v_atime;
> -	__be32 status, create_status;
> +	int createmode =3D -1;
> +	__be32 status, create_status =3D 0;
>  	int want_write_err;
> =20
>  	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
> @@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
>  	if (status !=3D nfs_ok)
>  		return status;
> =20
> +	status =3D fh_fill_pre_attrs_unlocked(fhp);
> +	if (status)
> +		return status;
> +
>  	if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>  		/*
>  		 * If name is already in dcache we need to check for mountpoints
> @@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  	if (!IS_POSIXACL(d_inode(parent.dentry)))
>  		iap->ia_mode &=3D ~current_umask();
> =20
> +	if (open->op_create) {
> +		createmode =3D open->op_createmode;
> +		oflags |=3D O_CREAT;
> +	}
>  	/*
>  	 * For the EXCLUSIVE modes we do our own uniqueness tests
>  	 * so don't want O_EXCL.
>  	 */
> -	if (open->op_createmode =3D=3D NFS4_CREATE_GUARDED)
> +	if (createmode =3D=3D NFS4_CREATE_GUARDED)
>  		oflags |=3D O_EXCL;
> =20
>  	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
> @@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
> =20
>  	v_mtime =3D 0;
>  	v_atime =3D 0;
> -	if (nfsd4_create_is_exclusive(open->op_createmode)) {
> +	if (nfsd4_create_is_exclusive(createmode)) {
>  		u32 *verifier =3D (u32 *)open->op_verf.data;
> =20
>  		/*
> @@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  		iap->ia_atime.tv_nsec =3D 0;
>  	}
> =20
> -	create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> -	if (create_status)
> -		/* Might still succeed if no create is needed */
> -		oflags &=3D ~O_CREAT;
> -
> +	if (oflags & O_CREAT) {
> +		create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> +		if (create_status)
> +			oflags &=3D ~O_CREAT;
> +	}
>  	open->op_filp =3D do_lookup_open(&parent,
>  				       &QSTR_LEN(open->op_fname,
>  						 open->op_fnamelen),
> @@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  		goto out;
> =20
>  	if (!open->op_created &&
> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
> +	    nfsd4_create_is_exclusive(createmode) &&
>  	    inode_get_mtime_sec(d_inode(child)) =3D=3D v_mtime &&
>  	    inode_get_atime_sec(d_inode(child)) =3D=3D v_atime &&
>  	    d_inode(child)->i_size =3D=3D 0)
>  		open->op_created =3D true;
> =20
>  	if (!open->op_created) {
> -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> +		if (open->op_create =3D=3D NFS4_OPEN_NOCREATE ||
> +		    createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>  			/* NFSv4 protocol requires change attributes
>  			 * even though no change happened.
>  			 */
> @@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4=
_compound_state *cstate, stru
>  	fh_init(*resfh, NFS4_FHSIZE);
>  	open->op_truncate =3D false;
> =20
> -	status =3D fh_fill_pre_attrs_unlocked(current_fh);
> -	if (status)
> -		goto out;
> -	if (open->op_create) {
> -		/* FIXME: check session persistence and pnfs flags.
> -		 * The nfsv4.1 spec requires the following semantics:
> -		 *
> -		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> -		 * Reply Cache  | server |                 |
> -		 * -------------+--------+-----------------+--------------------
> -		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> -		 *              |        |                 | (SHOULD)
> -		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> -		 *              |        |                 | (SHOULD NOT)
> -		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> -		 * yes          | no     | GUARDED4        | GUARDED4
> -		 * yes          | yes    | GUARDED4        | GUARDED4
> -		 */
> +	/* FIXME: check session persistence and pnfs flags.
> +	 * The nfsv4.1 spec requires the following semantics:
> +	 *
> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> +	 * Reply Cache  | server |                 |
> +	 * -------------+--------+-----------------+--------------------
> +	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> +	 *              |        |                 | (SHOULD)
> +	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> +	 *              |        |                 | (SHOULD NOT)
> +	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> +	 * yes          | no     | GUARDED4        | GUARDED4
> +	 * yes          | yes    | GUARDED4        | GUARDED4
> +	 */
> =20
> -		current->fs->umask =3D open->op_umask;
> -		status =3D nfsd4_create_file(rqstp, current_fh, *resfh, open);
> -		current->fs->umask =3D 0;
> +	current->fs->umask =3D open->op_umask;
> +	status =3D nfsd4_open_file(rqstp, current_fh, *resfh, open);
> +	current->fs->umask =3D 0;
> =20
> -		/*
> -		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> -		 * use the returned bitmask to indicate which attributes
> -		 * we used to store the verifier:
> -		 */
> -		if (nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D 0)
> -			open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> -						FATTR4_WORD1_TIME_MODIFY);
> -	} else {
> -		status =3D nfsd_lookup(rqstp, current_fh,
> -				     open->op_fname, open->op_fnamelen, *resfh);
> -		/*
> -		 * NFSv4 protocol requires change attributes even though
> -		 * no change happened.
> -		 */
> -		fh_fill_post_noop(current_fh);
> -	}
> +	/*
> +	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> +	 * use the returned bitmask to indicate which attributes
> +	 * we used to store the verifier:
> +	 */
> +	if (open->op_create &&
> +	    nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D 0)
> +		open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> +				      FATTR4_WORD1_TIME_MODIFY);
>  	if (status)
>  		goto out;
>  	status =3D nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));

This patch is making the pynfs DELEG8 test fail. It seems like this
patch breaks the behavior where the server sends back NFS4ERR_DELAY on
an OPEN while waiting for a DELEGRETURN. The server just doesn't send a
reply until the delegation times out with it.

--=20
Jeff Layton <jlayton@kernel.org>
