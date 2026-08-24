Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EA963947AC
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 22:48:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787611722; cv=none; b=V4TXb547t0Vf++OgzQJoQWDUhrTnDMSrHGqhNYxp7o7KKf26Wht/3T6CGOHswHMOYFDF7hN2ewkWpf99/xWIK2QS5vrf9xaCtYv1foOF1IbMuOmZjroKKN0hiUmyev9QCBxinKsDeUQYyVQ7Nh14b3F9QhiPe7QGq0NI7EIqOJ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787611722; c=relaxed/simple;
	bh=b9E/Fd4tGEdVgTYxHYiYTIegRZiKSGKroEi4wBUV+UY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VdcDocqBg5+Ifh0znaAYOMH8qVLr60xRdLGpGcwnOPraYkEtXaxmANYEmuL7vhVkSXr8pL6PlytOiVSe9Z7AERu98+VnaxbqdYNwnh0AZCVPV8+zEIc6//LMOt9vhy18pxGcs90cA6iOMB+fnM9om6XKl1jnVLkRlwplGIS7Klc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ipFI/FkO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ipFI/FkO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CE3DC1F000E9;
	Mon, 24 Aug 2026 22:48:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787611721;
	bh=3OIib/Ow2V+RbWZWsw12xIGBo2eqxl0WJmrWEEUd4Fc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ipFI/FkOb5OPAzss6EHoAZAxjlKUGZUZMRfB7UHJ5VWNVjlbpDPMwnyrfDYt1RpHp
	 p5h8e92pPeZqjAF2rvUsf07V7aWQu8CgWuxTKoYFRipEr+EwTVemRoxh976zSXWUCo
	 rjIda/j/BRT1lC4H+rcLxCkq/jBCHF98munJm1fcya5QIjOvfz5+if+LZ1HLx5PLPj
	 nHcgHg8qXYX60MIIiZfI/HMDu33A/+lccZm6W/e/PO1hJ6goZA9h9T8tCNb63tR3Ff
	 5KGVWny5pw7X4tRbW+9R2u1sdBmIXJxrXxMEVggdMztsZb6cQoIhqkqfEQY/qmTyZv
	 foKOwTmzx9XNw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0502FF40066;
	Mon, 24 Aug 2026 18:48:40 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 24 Aug 2026 18:48:40 -0400
X-ME-Sender: <xms:R8qMalrJzJNEDtvpx39Luz6ksLUuxsThk8OGu1eXVvRYV54myW94dQ>
    <xme:R8qMaidrn3EiyQr-I22F2KQJZN0haUWgFjPKpGbwNWiUjGZlVnkyrE0dVcCerYwCL
    f7kmvQ2tSgl-PhkNyB2IftfYuANdrdx1Cocme1uxCHY2D11PHeK2tQ>
X-ME-Proxy-Cause: dmFkZTFUGVg2vxrlOCfmS2I3eCbnkokAh8zXUQKGRdWKO/Q3P1XtjTLYxaFW7xWWK+IcDE
    uOOAoB7VA+el9S+6/oiq/6YokeyAajb9yQFlr0Z5CrcmvK4+0hP0yz6D6Dd4snr4+QFPru
    GRT9oSGIYppX5VjMSJh8BS+Rhv0iMV+rYzee4NJBFvRAzPg1ry+lMhR/Ca0qVOov8kCceS
    Xl6uGhux5l6F7Faim+wXqOiu8nm2mm1PrB/tTVcUGBaHr6FveLnYSmJ83A/h8xHR8bDfnY
    vIc/meDFHjTc6bA39mUhMDrjYgB6a8pkaoi2EI+sbeCXYxa5ADB6hVWTndXFhyrhUTm6GW
    KqMreUuzm9DVWT6yPXdUQlP0y7+Ql9UbOAq/YBR/r/AELGvQj6V2qx1VenpyDQj9XtAB+q
    NKR8IQyZrvo406t1ul2/K2DzBe27NNOUSkLnmVjJ4I9V9k91YfBzv0FQ+NuAUl9HKKrgyE
    D0D8pxd3V6zjHSrI6Kg8Ge8DjqK1gKb6v5wzPgm8cZxE0a0wf55/+Iv+nTo4acvxifNg+V
    pwJOdZd7Xn3Ec4Ye/0NRrkfhqGFe+S8EN2Q0HfiBuTU2xs3ssWDDszQjn3vD7eWT7IAJDS
    /NjIGhqSKaCIPg+oc6VQDq+5X4hNos62WV19FiyE8cM5bW+MEnFn0dvXSaOQ
X-ME-Proxy: <xmx:R8qMalXUpdcTSS3p6EC3Jj9UbD73MaX6goIh0I2IH7UmLvdyuHlgKg>
    <xmx:R8qMau41qSYPBcOMWpDtXRKsGmRBgU8ngEP2PR9w4-Lf4qLNMD_2EA>
    <xmx:R8qMaoqZXf5G0tiLvBkrEEItuHISAut1XoQClmZ_JVJXZMObfDh9Pg>
    <xmx:R8qMapl6NCwlhr0IoDCmlMKgKZpw-GBtTBYx_VNcfuIHcUcdPwag2Q>
    <xmx:SMqMasMfkrkhLWb4ewbkv2fgN2HorGpcz9N59tf0umQ4XTfGwgI8-QQZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CE6FF7811F0; Mon, 24 Aug 2026 18:48:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Mon, 24 Aug 2026 18:48:19 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Message-Id: <91af721c-a6a9-4f34-adb0-8d5982a87efa@app.fastmail.com>
In-Reply-To: <178760852225.3510150.8856836572675365165@noble.neil.brown.name>
References: <20260717093001.1972119-1-neilb@ownmail.net>
 <20260717093001.1972119-19-neilb@ownmail.net>
 <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
 <00464c46-a4e1-417e-8169-e3b73a6b0717@app.fastmail.com>
 <178700362567.2852630.944834641016567369@noble.neil.brown.name>
 <178760852225.3510150.8856836572675365165@noble.neil.brown.name>
Subject: Re: [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating open requests
 too.
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Mon, Aug 24, 2026, at 5:55 PM, NeilBrown wrote:
> On Tue, 18 Aug 2026, NeilBrown wrote:
>> On Tue, 18 Aug 2026, Chuck Lever wrote:
>> >=20
>> > On Wed, Aug 12, 2026, at 1:12 PM, Jeff Layton wrote:
>> > > On Fri, 2026-07-17 at 19:28 +1000, NeilBrown wrote:
>> > >> From: NeilBrown <neil@brown.name>
>> > >>=20
>> > >> Now that we have do_lookup_open() for creating open requests, we=
 can use
>> > >> it for non-creating too as do_lookup_open() is already able to d=
o that.
>> > >>=20
>> > >> This prepares for switching to vfs_lookup_open() once the VFS pr=
ovides
>> > >> that.  This will ensure consistent code and fs-interaction with =
VFS open().
>> > >>=20
>> > >> The resulting simplification allows fh_fill_pre_attrs_unlocked()=
 to be
>> > >> moved into nfsd4_open_file() (renamed from nfsd4_create_file()) =
so it is
>> > >> closer to fh_full_post_attrs and fh_fill_post_noop calls.
>> > >>=20
>> > >> As ->op_create_mode isn't defined when op_create is zero, we nee=
d a
>> > >> local create_mode which is -1 (illegal value) when op_create is =
zero.
>> > >>=20
>> > >> The non-create path now doesn't use nfsd_lookup().  As mount-poi=
nt
>> > >> crossing including nfsd_check_access() is already included for e=
xisting
>> > >> names, this does not lose us anything.
>> > >>=20
>> > >> We now only call mnt_want_write() is there is a flag which indic=
ates we
>> > >> might want write access - previously O_CREAT was always set.
>> > >>=20
>> > >> Signed-off-by: NeilBrown <neil@brown.name>
>> > >> ---
>> > >>  fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++----------------=
-------
>> > >>  1 file changed, 56 insertions(+), 57 deletions(-)
>> > >>=20
>> > >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> > >> index b7fdc75c4b81..11d0411dec08 100644
>> > >> --- a/fs/nfsd/nfs4proc.c
>> > >> +++ b/fs/nfsd/nfs4proc.c
>> > >> @@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct p=
ath *parent,
>> > >>  	struct file *filp =3D NULL;
>> > >>  	struct path path;
>> > >>  	struct dentry *child;
>> > >> -	int want_write_err =3D 0;
>> > >> +	int want_write_err =3D -ENOENT;
>> > >> =20
>> > >> -	want_write_err =3D mnt_want_write(parent->mnt);
>> > >> +	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
>> > >> +		want_write_err =3D mnt_want_write(parent->mnt);
>> > >> =20
>> > >>  	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
>> > >>  	if (IS_ERR(child)) {
>> > >> @@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct =
path *parent,
>> > >>  }
>> > >> =20
>> > >>  /*
>> > >> - * Implement NFSv4's unchecked, guarded, and exclusive create
>> > >> - * semantics for regular files. Open state for this new file is
>> > >> - * subsequently fabricated in nfsd4_process_open2().
>> > >> - *
>> > >> + * Implement NFSv4's open semantics for regular files.
>> > >> + * Both create (unchecked, guarded, and exclusive) and non-crea=
te.
>> > >> + * Open state for this new file is subsequently fabricated in
>> > >> + * nfsd4_process_open2().
>> > >>   * Upon return, caller must release @fhp and @resfhp.
>> > >>   */
>> > >>  static __be32
>> > >> -nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> > >> -		  struct svc_fh *resfhp, struct nfsd4_open *open)
>> > >> +nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> > >> +		struct svc_fh *resfhp, struct nfsd4_open *open)
>> > >>  {
>> > >>  	struct iattr *iap =3D &open->op_iattr;
>> > >>  	struct nfsd_attrs attrs =3D {
>> > >>  		.na_iattr	=3D iap,
>> > >>  		.na_seclabel	=3D &open->op_label,
>> > >>  	};
>> > >> -	int oflags =3D O_CREAT | O_LARGEFILE;
>> > >> +	int oflags =3D O_LARGEFILE;
>> > >>  	struct dentry *child =3D ERR_PTR(-EINVAL);
>> > >>  	struct path parent =3D {
>> > >>  		.mnt =3D fhp->fh_export->ex_path.mnt,
>> > >>  		.dentry =3D fhp->fh_dentry,
>> > >>  	};
>> > >>  	__u32 v_mtime, v_atime;
>> > >> -	__be32 status, create_status;
>> > >> +	int createmode =3D -1;
>> > >> +	__be32 status, create_status =3D 0;
>> > >>  	int want_write_err;
>> > >> =20
>> > >>  	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
>> > >> @@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, s=
truct svc_fh *fhp,
>> > >>  	if (status !=3D nfs_ok)
>> > >>  		return status;
>> > >> =20
>> > >> +	status =3D fh_fill_pre_attrs_unlocked(fhp);
>> > >> +	if (status)
>> > >> +		return status;
>> > >> +
>> > >>  	if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>> > >>  		/*
>> > >>  		 * If name is already in dcache we need to check for mountpoi=
nts
>> > >> @@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>> > >>  	if (!IS_POSIXACL(d_inode(parent.dentry)))
>> > >>  		iap->ia_mode &=3D ~current_umask();
>> > >> =20
>> > >> +	if (open->op_create) {
>> > >> +		createmode =3D open->op_createmode;
>> > >> +		oflags |=3D O_CREAT;
>> > >> +	}
>> > >>  	/*
>> > >>  	 * For the EXCLUSIVE modes we do our own uniqueness tests
>> > >>  	 * so don't want O_EXCL.
>> > >>  	 */
>> > >> -	if (open->op_createmode =3D=3D NFS4_CREATE_GUARDED)
>> > >> +	if (createmode =3D=3D NFS4_CREATE_GUARDED)
>> > >>  		oflags |=3D O_EXCL;
>> > >> =20
>> > >>  	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
>> > >> @@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, st=
ruct svc_fh *fhp,
>> > >> =20
>> > >>  	v_mtime =3D 0;
>> > >>  	v_atime =3D 0;
>> > >> -	if (nfsd4_create_is_exclusive(open->op_createmode)) {
>> > >> +	if (nfsd4_create_is_exclusive(createmode)) {
>> > >>  		u32 *verifier =3D (u32 *)open->op_verf.data;
>> > >> =20
>> > >>  		/*
>> > >> @@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>> > >>  		iap->ia_atime.tv_nsec =3D 0;
>> > >>  	}
>> > >> =20
>> > >> -	create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREA=
TE);
>> > >> -	if (create_status)
>> > >> -		/* Might still succeed if no create is needed */
>> > >> -		oflags &=3D ~O_CREAT;
>> > >> -
>> > >> +	if (oflags & O_CREAT) {
>> > >> +		create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CRE=
ATE);
>> > >> +		if (create_status)
>> > >> +			oflags &=3D ~O_CREAT;
>> > >> +	}
>> > >>  	open->op_filp =3D do_lookup_open(&parent,
>> > >>  				       &QSTR_LEN(open->op_fname,
>> > >>  						 open->op_fnamelen),
>> > >> @@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>> > >>  		goto out;
>> > >> =20
>> > >>  	if (!open->op_created &&
>> > >> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
>> > >> +	    nfsd4_create_is_exclusive(createmode) &&
>> > >>  	    inode_get_mtime_sec(d_inode(child)) =3D=3D v_mtime &&
>> > >>  	    inode_get_atime_sec(d_inode(child)) =3D=3D v_atime &&
>> > >>  	    d_inode(child)->i_size =3D=3D 0)
>> > >>  		open->op_created =3D true;
>> > >> =20
>> > >>  	if (!open->op_created) {
>> > >> -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>> > >> +		if (open->op_create =3D=3D NFS4_OPEN_NOCREATE ||
>> > >> +		    createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>> > >>  			/* NFSv4 protocol requires change attributes
>> > >>  			 * even though no change happened.
>> > >>  			 */
>> > >> @@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, str=
uct nfsd4_compound_state *cstate, stru
>> > >>  	fh_init(*resfh, NFS4_FHSIZE);
>> > >>  	open->op_truncate =3D false;
>> > >> =20
>> > >> -	status =3D fh_fill_pre_attrs_unlocked(current_fh);
>> > >> -	if (status)
>> > >> -		goto out;
>> > >> -	if (open->op_create) {
>> > >> -		/* FIXME: check session persistence and pnfs flags.
>> > >> -		 * The nfsv4.1 spec requires the following semantics:
>> > >> -		 *
>> > >> -		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
>> > >> -		 * Reply Cache  | server |                 |
>> > >> -		 * -------------+--------+-----------------+-----------------=
---
>> > >> -		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> > >> -		 *              |        |                 | (SHOULD)
>> > >> -		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
>> > >> -		 *              |        |                 | (SHOULD NOT)
>> > >> -		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> > >> -		 * yes          | no     | GUARDED4        | GUARDED4
>> > >> -		 * yes          | yes    | GUARDED4        | GUARDED4
>> > >> -		 */
>> > >> +	/* FIXME: check session persistence and pnfs flags.
>> > >> +	 * The nfsv4.1 spec requires the following semantics:
>> > >> +	 *
>> > >> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
>> > >> +	 * Reply Cache  | server |                 |
>> > >> +	 * -------------+--------+-----------------+------------------=
--
>> > >> +	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> > >> +	 *              |        |                 | (SHOULD)
>> > >> +	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
>> > >> +	 *              |        |                 | (SHOULD NOT)
>> > >> +	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> > >> +	 * yes          | no     | GUARDED4        | GUARDED4
>> > >> +	 * yes          | yes    | GUARDED4        | GUARDED4
>> > >> +	 */
>> > >> =20
>> > >> -		current->fs->umask =3D open->op_umask;
>> > >> -		status =3D nfsd4_create_file(rqstp, current_fh, *resfh, open);
>> > >> -		current->fs->umask =3D 0;
>> > >> +	current->fs->umask =3D open->op_umask;
>> > >> +	status =3D nfsd4_open_file(rqstp, current_fh, *resfh, open);
>> > >> +	current->fs->umask =3D 0;
>> > >> =20
>> > >> -		/*
>> > >> -		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
>> > >> -		 * use the returned bitmask to indicate which attributes
>> > >> -		 * we used to store the verifier:
>> > >> -		 */
>> > >> -		if (nfsd4_create_is_exclusive(open->op_createmode) && status =
=3D=3D 0)
>> > >> -			open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
>> > >> -						FATTR4_WORD1_TIME_MODIFY);
>> > >> -	} else {
>> > >> -		status =3D nfsd_lookup(rqstp, current_fh,
>> > >> -				     open->op_fname, open->op_fnamelen, *resfh);
>> > >> -		/*
>> > >> -		 * NFSv4 protocol requires change attributes even though
>> > >> -		 * no change happened.
>> > >> -		 */
>> > >> -		fh_fill_post_noop(current_fh);
>> > >> -	}
>> > >> +	/*
>> > >> +	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
>> > >> +	 * use the returned bitmask to indicate which attributes
>> > >> +	 * we used to store the verifier:
>> > >> +	 */
>> > >> +	if (open->op_create &&
>> > >> +	    nfsd4_create_is_exclusive(open->op_createmode) && status =3D=
=3D 0)
>> > >> +		open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
>> > >> +				      FATTR4_WORD1_TIME_MODIFY);
>> > >>  	if (status)
>> > >>  		goto out;
>> > >>  	status =3D nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
>> > >
>> > > This patch is making the pynfs DELEG8 test fail. It seems like th=
is
>> > > patch breaks the behavior where the server sends back NFS4ERR_DEL=
AY on
>> > > an OPEN while waiting for a DELEGRETURN. The server just doesn't =
send a
>> > > reply until the delegation times out with it.
>> >=20
>> > Neil, I need a response from you. How soon do you intend to address=
 this
>> > issue? Can this patch be dropped safely from the series, or do I ne=
ed to
>> > drop the whole series?
>> >=20
>>=20
>> Hi,
>>  sorry for not getting to this sooner.
>>  I can see the problem.  To fix it we need to somehow get logic simil=
ar
>>  to nfsd_open_break_lease() into the vfs_lookup_open() path.  I think
>>  that'll be possible though not trivial.
>>=20
>>  It is safe to drop just that patch for now.  I don't need it for the
>>  locking work that I am doing.  I think it is still good to have and I
>>  will try to rehabilitate it, but not in a hurry.
>>=20
>>  I'm confident the rest of the series is not implicated in this probl=
em
>>  so there is no need to drop the whole series.
>
> Hi Chuck,
>  I notice this series wasn't in your recent pull request and they seem
>  to have disappeared from your tree.

I see them in nfsd-testing, where they=E2=80=99ve been since August 10.


>  What do you understand the status of these patches to be?
>  I was hoping they would land this merge window.

Jeff and I discussed this, and we=E2=80=99d like these to get another mo=
nth
or two in linux-next because they modify common paths. When v7.3-rc1
opens, they will be at the first patches in nfsd-next for v7.4.


--=20
Chuck Lever
