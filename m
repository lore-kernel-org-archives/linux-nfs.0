Received: from fhigh-a8-smtp.messagingengine.com (fhigh-a8-smtp.messagingengine.com [103.168.172.159])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DE8A369224
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 21:53:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.159
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787003635; cv=none; b=EE8G/OS5IZq0+irdtcUIRLdfLfEfs32th+htrLKCPj9FQxIbaGPmYBU4ugUg4dSqT1RHPw8OWAaiXr9QsKB4YpK1oZ7SEBVZd95nQkMmXFHTb8geh9ImHCvig4Q8em8ZjsjmrZ8CpwK6ivfUqPGVzIfhkF52u1voX4NPGyt5buw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787003635; c=relaxed/simple;
	bh=E0/hZ5CXnYD2wvktBB30En2ZxUe4MZhYSE32/eh/jCs=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=PYew7loHXqJ3v4SCgcq9jgl1QpJzYMtJmeN5ZUyuMZexFDC1bj4WO1GkKX4G26+r7MwzftyHU3um/aEqrDI7Nf8mNP6vE67GDk1XfwnPyj7O897MAxiatQjtO2xuXSWGZWDfUvbrwcGYypizSquKwNjXt+t3PEOoJBWGX6t8JuI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=F1EX00r3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=CVMl0wTi; arc=none smtp.client-ip=103.168.172.159
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="F1EX00r3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CVMl0wTi"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.phl.internal (Postfix) with ESMTP id A89B71400170;
	Mon, 17 Aug 2026 17:53:52 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Mon, 17 Aug 2026 17:53:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787003632; x=1787090032; bh=E9z5ru6Rqp1+/o+Msrmj089eWih3NW1rbEr
	XmhTI7f4=; b=F1EX00r3MnCDiD4NReQvy8mMtd9GFLKuoedoyd8FZgVaeOBiYop
	VlsuwgFBe+BlgcSz9Wq0B4xoDoU2CDYDHgRdIA8uAtvMzgQkMZhT7wiunh+nlAoP
	j0kliqoMWrxeHtGqMmhWlDLk4owjqaHdOYSlYw3Ne/ApWZ7XGyGwqX+103P4h/Fe
	ZO0RZG7LqEnRHBfRfgd6HvpifMi5eruL4pw2cHuRtxIz0D7u5sYJWTYn2ADaSQ9q
	hLsDh0ip7sR/w4hoLHsDT4q8WXk6day2LbmZN0DS1MS9tYMWqVNAH980ohJwdCQm
	37kGDLK647TAjK2RcMVZ85tBZl1pbfHqd3g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787003632; x=
	1787090032; bh=E9z5ru6Rqp1+/o+Msrmj089eWih3NW1rbErXmhTI7f4=; b=C
	VMl0wTiGyBW0Pp7wRclAPYzjCfTjfhNd95OzMcF1MgVnsALcoL288eUpEl3mlmJj
	JF/I3rabuB8Cd8BiGUMEHPw4jbQOWyk+b3ZYMQF9gODEqBfaYQJ+q/HR77FShAEm
	Mo51EysgKDDvZepYijchCpMRa0nYOBFCgbWejVpdcZkd/1rsJiwAskGWndRZD7ix
	wCgmcdflf78b7hqt7bc/MJ6g437VmxiKDJHagCgqgg/z66fjGP553FEUIxY4p7kn
	K5jQPMppPKDMO3sQWFRR2oL/I15B+1EEeVw7FrmUKlOqXyC1L2Q/Clx9l47gqg0I
	CkHI8We/LdZXzaV3Z+efQ==
X-ME-Sender: <xms:8IKDasnLdGYQDMOVLEQkXVy8H5dCbQ-gkz6lBJSgrSCH5HtvVVaxMA>
    <xme:8IKDavibjrEqBwUdH7U-VXvmUwZxiAfDXWnE8U928tuMOBC_OXJshOYmROVji_Vco
    AspPzAolTuvvuFRpgc1JZXmmaCWsOKMBrotBn8dH4LpKEm7mPw>
X-ME-Received: <xmr:8IKDakeTPNsHlkv5JNRMZH7bKisJla_nadF59L_kbOy2VaHoNhXVNTnC53hcZro8e_1XUzJxHj8PRg1ZzLvUK7flIo58UG0>
X-ME-Proxy-Cause: dmFkZTGAIhDFrG3aTctQvJkhlGDwHCm5IIumo08M0ziHaCpoT+0UHcKNVrzeW3SJJdYHFu
    Avg2oV9U3Khm50A3yiMWhhtM2JKD8Yj48wD6NjptI0mTFvFlnCBcQFlv3LnFjf46GRdP4d
    7dJCJSc2hbjE02RStUs0pcCzPgtmUo+z9kbY/vrbHbAT10QcNGTOzr8qxtab9pE/KRejws
    5JkHXjt6XGu8mPcHIdFnFqXSTNpy9GOMZnwnerwUIESmK7JYHaHWHeVpckl+tdpJnGfUJj
    St9Fw+cEniTxEkTLIkzim8hvzV6AyCBOB4LjNSOfBIPiV/Lad9PscVVumYxGV77+trL3bV
    tDx5p40xLG87i2Ow07ftRO/59QsyQZErSLBtaOfAI4hombhC5j5a+wgPkURkv/VdaTKlmm
    eEemibJfB43iZQEnKtOSftd2bOGikI8xwqJpWcu6O0WsoWyHL3MpjYpyxZto2ydlbv5Dp3
    Qvr+7zQT5l0ISq5aL2/HnsNDSvOP0AXKLALXp/2apGzhgSfYJJ5Brkpq2+q5coaiSQF9NJ
    tq08PxBT/HDhpMkLnTko2sPWNI2+BBi8SFO6oNn9jvsVkTjzEFtjFffLauuuf2HdvXeRww
    v13BbRvEMBvrrJaWq9sCeIxD5ba6sImNQgz6oo+1BQeto/Cb0NjvlyW3ZTLw
X-ME-Proxy: <xmx:8IKDavjufQD_gwEeBlFShkElqaCD5nP45iTQCErX9GghaD34GDymig>
    <xmx:8IKDasxeZx0SRwoQGHbwGGEC3dU3O5Z8YtcgeX_h6olbTsh9vVkrWQ>
    <xmx:8IKDarPDbj8sieHoY2GtzYc0TKhHL9mIQGooDXRXQLlrGLiUdooJNw>
    <xmx:8IKDatWbCDePWBkpNTGIML__ingGveJw26qdOGT6KpY0x2T1FCeiLg>
    <xmx:8IKDaiHS_J8BiY8o3vmSYBmuFh7izeXRao5-M0V4OD4sXgI8j7E23GuK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 17 Aug 2026 17:53:49 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating open
 requests too.
In-reply-to: <00464c46-a4e1-417e-8169-e3b73a6b0717@app.fastmail.com>
References: <20260717093001.1972119-1-neilb@ownmail.net>
  <20260717093001.1972119-19-neilb@ownmail.net>
  <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
  <00464c46-a4e1-417e-8169-e3b73a6b0717@app.fastmail.com>
Date: Tue, 18 Aug 2026 07:53:45 +1000
Message-id: <178700362567.2852630.944834641016567369@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 18 Aug 2026, Chuck Lever wrote:
>=20
> On Wed, Aug 12, 2026, at 1:12 PM, Jeff Layton wrote:
> > On Fri, 2026-07-17 at 19:28 +1000, NeilBrown wrote:
> >> From: NeilBrown <neil@brown.name>
> >>=20
> >> Now that we have do_lookup_open() for creating open requests, we can use
> >> it for non-creating too as do_lookup_open() is already able to do that.
> >>=20
> >> This prepares for switching to vfs_lookup_open() once the VFS provides
> >> that.  This will ensure consistent code and fs-interaction with VFS open=
().
> >>=20
> >> The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
> >> moved into nfsd4_open_file() (renamed from nfsd4_create_file()) so it is
> >> closer to fh_full_post_attrs and fh_fill_post_noop calls.
> >>=20
> >> As ->op_create_mode isn't defined when op_create is zero, we need a
> >> local create_mode which is -1 (illegal value) when op_create is zero.
> >>=20
> >> The non-create path now doesn't use nfsd_lookup().  As mount-point
> >> crossing including nfsd_check_access() is already included for existing
> >> names, this does not lose us anything.
> >>=20
> >> We now only call mnt_want_write() is there is a flag which indicates we
> >> might want write access - previously O_CREAT was always set.
> >>=20
> >> Signed-off-by: NeilBrown <neil@brown.name>
> >> ---
> >>  fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++-----------------------
> >>  1 file changed, 56 insertions(+), 57 deletions(-)
> >>=20
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index b7fdc75c4b81..11d0411dec08 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct path *par=
ent,
> >>  	struct file *filp =3D NULL;
> >>  	struct path path;
> >>  	struct dentry *child;
> >> -	int want_write_err =3D 0;
> >> +	int want_write_err =3D -ENOENT;
> >> =20
> >> -	want_write_err =3D mnt_want_write(parent->mnt);
> >> +	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
> >> +		want_write_err =3D mnt_want_write(parent->mnt);
> >> =20
> >>  	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
> >>  	if (IS_ERR(child)) {
> >> @@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct path *pa=
rent,
> >>  }
> >> =20
> >>  /*
> >> - * Implement NFSv4's unchecked, guarded, and exclusive create
> >> - * semantics for regular files. Open state for this new file is
> >> - * subsequently fabricated in nfsd4_process_open2().
> >> - *
> >> + * Implement NFSv4's open semantics for regular files.
> >> + * Both create (unchecked, guarded, and exclusive) and non-create.
> >> + * Open state for this new file is subsequently fabricated in
> >> + * nfsd4_process_open2().
> >>   * Upon return, caller must release @fhp and @resfhp.
> >>   */
> >>  static __be32
> >> -nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >> -		  struct svc_fh *resfhp, struct nfsd4_open *open)
> >> +nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >> +		struct svc_fh *resfhp, struct nfsd4_open *open)
> >>  {
> >>  	struct iattr *iap =3D &open->op_iattr;
> >>  	struct nfsd_attrs attrs =3D {
> >>  		.na_iattr	=3D iap,
> >>  		.na_seclabel	=3D &open->op_label,
> >>  	};
> >> -	int oflags =3D O_CREAT | O_LARGEFILE;
> >> +	int oflags =3D O_LARGEFILE;
> >>  	struct dentry *child =3D ERR_PTR(-EINVAL);
> >>  	struct path parent =3D {
> >>  		.mnt =3D fhp->fh_export->ex_path.mnt,
> >>  		.dentry =3D fhp->fh_dentry,
> >>  	};
> >>  	__u32 v_mtime, v_atime;
> >> -	__be32 status, create_status;
> >> +	int createmode =3D -1;
> >> +	__be32 status, create_status =3D 0;
> >>  	int want_write_err;
> >> =20
> >>  	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
> >> @@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >>  	if (status !=3D nfs_ok)
> >>  		return status;
> >> =20
> >> +	status =3D fh_fill_pre_attrs_unlocked(fhp);
> >> +	if (status)
> >> +		return status;
> >> +
> >>  	if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> >>  		/*
> >>  		 * If name is already in dcache we need to check for mountpoints
> >> @@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
> >>  	if (!IS_POSIXACL(d_inode(parent.dentry)))
> >>  		iap->ia_mode &=3D ~current_umask();
> >> =20
> >> +	if (open->op_create) {
> >> +		createmode =3D open->op_createmode;
> >> +		oflags |=3D O_CREAT;
> >> +	}
> >>  	/*
> >>  	 * For the EXCLUSIVE modes we do our own uniqueness tests
> >>  	 * so don't want O_EXCL.
> >>  	 */
> >> -	if (open->op_createmode =3D=3D NFS4_CREATE_GUARDED)
> >> +	if (createmode =3D=3D NFS4_CREATE_GUARDED)
> >>  		oflags |=3D O_EXCL;
> >> =20
> >>  	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
> >> @@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
> >> =20
> >>  	v_mtime =3D 0;
> >>  	v_atime =3D 0;
> >> -	if (nfsd4_create_is_exclusive(open->op_createmode)) {
> >> +	if (nfsd4_create_is_exclusive(createmode)) {
> >>  		u32 *verifier =3D (u32 *)open->op_verf.data;
> >> =20
> >>  		/*
> >> @@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
> >>  		iap->ia_atime.tv_nsec =3D 0;
> >>  	}
> >> =20
> >> -	create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> >> -	if (create_status)
> >> -		/* Might still succeed if no create is needed */
> >> -		oflags &=3D ~O_CREAT;
> >> -
> >> +	if (oflags & O_CREAT) {
> >> +		create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> >> +		if (create_status)
> >> +			oflags &=3D ~O_CREAT;
> >> +	}
> >>  	open->op_filp =3D do_lookup_open(&parent,
> >>  				       &QSTR_LEN(open->op_fname,
> >>  						 open->op_fnamelen),
> >> @@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
> >>  		goto out;
> >> =20
> >>  	if (!open->op_created &&
> >> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
> >> +	    nfsd4_create_is_exclusive(createmode) &&
> >>  	    inode_get_mtime_sec(d_inode(child)) =3D=3D v_mtime &&
> >>  	    inode_get_atime_sec(d_inode(child)) =3D=3D v_atime &&
> >>  	    d_inode(child)->i_size =3D=3D 0)
> >>  		open->op_created =3D true;
> >> =20
> >>  	if (!open->op_created) {
> >> -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> >> +		if (open->op_create =3D=3D NFS4_OPEN_NOCREATE ||
> >> +		    createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> >>  			/* NFSv4 protocol requires change attributes
> >>  			 * even though no change happened.
> >>  			 */
> >> @@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd=
4_compound_state *cstate, stru
> >>  	fh_init(*resfh, NFS4_FHSIZE);
> >>  	open->op_truncate =3D false;
> >> =20
> >> -	status =3D fh_fill_pre_attrs_unlocked(current_fh);
> >> -	if (status)
> >> -		goto out;
> >> -	if (open->op_create) {
> >> -		/* FIXME: check session persistence and pnfs flags.
> >> -		 * The nfsv4.1 spec requires the following semantics:
> >> -		 *
> >> -		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> >> -		 * Reply Cache  | server |                 |
> >> -		 * -------------+--------+-----------------+--------------------
> >> -		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> >> -		 *              |        |                 | (SHOULD)
> >> -		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> >> -		 *              |        |                 | (SHOULD NOT)
> >> -		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> >> -		 * yes          | no     | GUARDED4        | GUARDED4
> >> -		 * yes          | yes    | GUARDED4        | GUARDED4
> >> -		 */
> >> +	/* FIXME: check session persistence and pnfs flags.
> >> +	 * The nfsv4.1 spec requires the following semantics:
> >> +	 *
> >> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> >> +	 * Reply Cache  | server |                 |
> >> +	 * -------------+--------+-----------------+--------------------
> >> +	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> >> +	 *              |        |                 | (SHOULD)
> >> +	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> >> +	 *              |        |                 | (SHOULD NOT)
> >> +	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> >> +	 * yes          | no     | GUARDED4        | GUARDED4
> >> +	 * yes          | yes    | GUARDED4        | GUARDED4
> >> +	 */
> >> =20
> >> -		current->fs->umask =3D open->op_umask;
> >> -		status =3D nfsd4_create_file(rqstp, current_fh, *resfh, open);
> >> -		current->fs->umask =3D 0;
> >> +	current->fs->umask =3D open->op_umask;
> >> +	status =3D nfsd4_open_file(rqstp, current_fh, *resfh, open);
> >> +	current->fs->umask =3D 0;
> >> =20
> >> -		/*
> >> -		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> >> -		 * use the returned bitmask to indicate which attributes
> >> -		 * we used to store the verifier:
> >> -		 */
> >> -		if (nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D 0)
> >> -			open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> >> -						FATTR4_WORD1_TIME_MODIFY);
> >> -	} else {
> >> -		status =3D nfsd_lookup(rqstp, current_fh,
> >> -				     open->op_fname, open->op_fnamelen, *resfh);
> >> -		/*
> >> -		 * NFSv4 protocol requires change attributes even though
> >> -		 * no change happened.
> >> -		 */
> >> -		fh_fill_post_noop(current_fh);
> >> -	}
> >> +	/*
> >> +	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> >> +	 * use the returned bitmask to indicate which attributes
> >> +	 * we used to store the verifier:
> >> +	 */
> >> +	if (open->op_create &&
> >> +	    nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D 0)
> >> +		open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> >> +				      FATTR4_WORD1_TIME_MODIFY);
> >>  	if (status)
> >>  		goto out;
> >>  	status =3D nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
> >
> > This patch is making the pynfs DELEG8 test fail. It seems like this
> > patch breaks the behavior where the server sends back NFS4ERR_DELAY on
> > an OPEN while waiting for a DELEGRETURN. The server just doesn't send a
> > reply until the delegation times out with it.
>=20
> Neil, I need a response from you. How soon do you intend to address this
> issue? Can this patch be dropped safely from the series, or do I need to
> drop the whole series?
>=20

Hi,
 sorry for not getting to this sooner.
 I can see the problem.  To fix it we need to somehow get logic similar
 to nfsd_open_break_lease() into the vfs_lookup_open() path.  I think
 that'll be possible though not trivial.

 It is safe to drop just that patch for now.  I don't need it for the
 locking work that I am doing.  I think it is still good to have and I
 will try to rehabilitate it, but not in a hurry.

 I'm confident the rest of the series is not implicated in this problem
 so there is no need to drop the whole series.

Thanks,
NeilBrown
