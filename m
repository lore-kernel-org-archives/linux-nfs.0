Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F24083812EF
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 21:55:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787608531; cv=none; b=Rf9MQyjLjDGR8L+Nl28E2SyoByr/KFVfdMlyE+jSFet0dWVb2lAEm9N0WA/EATDLh0BqPBwmzr/HdbZIpXQdOqgvksicylobIgtgsxRTg/AhbidFJ1d2kQhJxL82zEg1gkQPO+rl/wX5oe1QA80Q4sxcc0Y57Z00odt53ihqlA4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787608531; c=relaxed/simple;
	bh=IJ2pnyEX8JUHlDlPhajmw9dByandPONFUzVR4bOeOmc=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=OI16I0NB9c4h+8xdb5ULPDEYT5Wu+V1B/k860tdbQWpxUf4j6T7Ymo6IG4VcjBkHAYmuzT698nTpYwFkWuA4r/bkwe4zvrJAB0TtAzgV/TH4IWc8GoI53bgj39UY1ojCgquBVuMEQcyZjUWNRvZTlPHdsEv9ONywrC1eTfz+Yvk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=QtEdXaXR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=M2nipBU3; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="QtEdXaXR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="M2nipBU3"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 2C74E1D00101;
	Mon, 24 Aug 2026 17:55:28 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 24 Aug 2026 17:55:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787608528; x=1787694928; bh=U1NvlQSYsvIXoe2g20BFo6+85fye/OY80/x
	YCER8ydk=; b=QtEdXaXRGCYvIcSEgEebsODdtUHYqg3bBVxplD4erSPX0gWkTBB
	NgujGc2WqXfRZe/Job6sr0HGFr5Bw6lZCt38iTJtOai6qTediUAv84/YVwFeza9V
	2rMGD/aeowJb8L9up5HPvmSbuMWxYv4xc19hZyvxr/ag0OOvOjobn42hbnIfraak
	HW7/SNaItw1ez7DQl7mBe7LYEvxQRYUZAS5w7/fxRrw4J9lOLRW/bqOGC80joR7H
	nqZJcGeLMzoyQUt2ULOLb/5jdc7YD2ONFp7gHa/Y+6oVf/dkRyCp3eznAx8QzqQu
	uRpHBehxzXSCOBLLFuftwXkiG+qVV1tOKgA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787608528; x=
	1787694928; bh=U1NvlQSYsvIXoe2g20BFo6+85fye/OY80/xYCER8ydk=; b=M
	2nipBU3EqZM2WkGzm6jMSa2sgwtjlCLy1Q/N0I7ITQHayK3lq6jzvD2+/yHteotn
	kCUcbDw+mURcSJoQQY9fKF/BydNO6fMDqpcQEOgsjGGmIwN9qPINoKsnnwLHsxaY
	1sNayHYTz8P3/CyOX1FGRr9v2R7/ESM6GGbzPIVNsgeKHLn342joRAsx5J3z18Nh
	ByX0/kQ+kNohMy9lDAr/87ZEsxgrU9lNX4KtLeUr2zrIR8gsQrX9dTjE2Jwgyg9q
	aPg4X1vMd3lwFpCgtb/mWZisUUkksUQ4VBJ+GWnrphSapot5u06KuqgYHYQ0Xt7k
	jeaaFbV0Br3AhtwqsCxhQ==
X-ME-Sender: <xms:z72Mahz-OLJm47WD8ajA0QgZD1ys1LbIHW4YT5ZGmCciY64ROrRZuA>
    <xme:z72Mak-b0pdJu2ZglFZOPSZAErBqLXapXP0CGVgvu_4P4SKfaqpmFxgK8jsGbf3TG
    UnAd7wMEgN-Fvlz91AuH_kDY4Y_SmdXthQ667fPG1o7mtT-6B0>
X-ME-Received: <xmr:z72MalJ1zNP00At1ckyiGp4axkbDp9LMom1ho5SO1KSxlCOKu53iFZfjUWqgdMqCWMg8ebSMjJZXnzpw7WOV7nNLmOiLxcg>
X-ME-Proxy-Cause: dmFkZTFdd3zviOTlAodgqYh3RAPHFVGOWyzBK0HMbq+IDXDw+XDMfiVlvnRsG0P5uUx/r8
    86zSNAqvm+uauybpo1J3zfahZkvh/SCRQQGRUYx4i4Ed0V/Mg+CXkAtSYE/eLT97atydQs
    gQKkZp1C7+inVy/GkLuudCCpp6f1gehXf/vt/xbeaoBRF7TAHNos38jEjTXJvefDetgDPM
    wnO2lbTyc+52Ge8Ze/bqtdupE+2oetnE6AX38BgNn7cDYYpxbiGZgvm61rKcw8ttjM4p0f
    eSii6/VWfeBJogH3fPj0lSrHBt/7B6SMmN0nE1NGyOYyWAXEcBWZCuCxaS/ix5KF6g1WBm
    I/UIJ0xKqq9kDKtdOC90SXH3GJqnjQyYjtT4pbWCkwHM1IpmcYCpwtsutREWYlU2vyJx+/
    gHUp0l818rhYh1oTIOtySO4vYhD/1BlJVW21wOzV6mZk6k9xBPDEml6Z6h9CSi0Ut3+OVq
    DPoRv4uDfSZPmAAuGn7WW3dPrAZUjPz8O0HXt3fhqsJtvtUTPkn0U3393Qb4E/mB4CH5p0
    prsMpKM+NZYCDidyu47xTK/sKAb1ppVWcRuPavg1TgSTsKbsRNcTPKRe0OWgWgD7rrRh7V
    BvXdEa8qyUmcCoUGuvB3vZkXnRl0knIlWgvt85DtOYvlLvt8BYSoxyoVuKRQ
X-ME-Proxy: <xmx:z72MaqcP-wagExihrizYRN14HIgpLxnj2LiuwiCN74Ilf4OBys1qaQ>
    <xmx:z72Mak-DXy9-rapRZ9ITufV_YyBrZ_n6AFLO8Il1Rp3BY7rsrmkOog>
    <xmx:z72ManoBqBmppbBrLN2o0_mLEt3D0JB2oESoRsVKLX3gxovY8p_AFw>
    <xmx:z72MapCzXBRmO-oB6JChKr3oS9obXTOfxdFfY5eWFktYmkSKkNtW6w>
    <xmx:0L2MajQK5UtPxHJ8JfPYnpqzxPpOswVxCGdoUBfxZsAXgUyYBGs5oRtE>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 24 Aug 2026 17:55:25 -0400 (EDT)
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
In-reply-to: <178700362567.2852630.944834641016567369@noble.neil.brown.name>
References: <20260717093001.1972119-1-neilb@ownmail.net>
  <20260717093001.1972119-19-neilb@ownmail.net>
  <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
  <00464c46-a4e1-417e-8169-e3b73a6b0717@app.fastmail.com>
  <178700362567.2852630.944834641016567369@noble.neil.brown.name>
Date: Tue, 25 Aug 2026 07:55:22 +1000
Message-id: <178760852225.3510150.8856836572675365165@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 18 Aug 2026, NeilBrown wrote:
> On Tue, 18 Aug 2026, Chuck Lever wrote:
> >=20
> > On Wed, Aug 12, 2026, at 1:12 PM, Jeff Layton wrote:
> > > On Fri, 2026-07-17 at 19:28 +1000, NeilBrown wrote:
> > >> From: NeilBrown <neil@brown.name>
> > >>=20
> > >> Now that we have do_lookup_open() for creating open requests, we can u=
se
> > >> it for non-creating too as do_lookup_open() is already able to do that.
> > >>=20
> > >> This prepares for switching to vfs_lookup_open() once the VFS provides
> > >> that.  This will ensure consistent code and fs-interaction with VFS op=
en().
> > >>=20
> > >> The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
> > >> moved into nfsd4_open_file() (renamed from nfsd4_create_file()) so it =
is
> > >> closer to fh_full_post_attrs and fh_fill_post_noop calls.
> > >>=20
> > >> As ->op_create_mode isn't defined when op_create is zero, we need a
> > >> local create_mode which is -1 (illegal value) when op_create is zero.
> > >>=20
> > >> The non-create path now doesn't use nfsd_lookup().  As mount-point
> > >> crossing including nfsd_check_access() is already included for existing
> > >> names, this does not lose us anything.
> > >>=20
> > >> We now only call mnt_want_write() is there is a flag which indicates we
> > >> might want write access - previously O_CREAT was always set.
> > >>=20
> > >> Signed-off-by: NeilBrown <neil@brown.name>
> > >> ---
> > >>  fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++-----------------------
> > >>  1 file changed, 56 insertions(+), 57 deletions(-)
> > >>=20
> > >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > >> index b7fdc75c4b81..11d0411dec08 100644
> > >> --- a/fs/nfsd/nfs4proc.c
> > >> +++ b/fs/nfsd/nfs4proc.c
> > >> @@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct path *p=
arent,
> > >>  	struct file *filp =3D NULL;
> > >>  	struct path path;
> > >>  	struct dentry *child;
> > >> -	int want_write_err =3D 0;
> > >> +	int want_write_err =3D -ENOENT;
> > >> =20
> > >> -	want_write_err =3D mnt_want_write(parent->mnt);
> > >> +	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
> > >> +		want_write_err =3D mnt_want_write(parent->mnt);
> > >> =20
> > >>  	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
> > >>  	if (IS_ERR(child)) {
> > >> @@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct path *=
parent,
> > >>  }
> > >> =20
> > >>  /*
> > >> - * Implement NFSv4's unchecked, guarded, and exclusive create
> > >> - * semantics for regular files. Open state for this new file is
> > >> - * subsequently fabricated in nfsd4_process_open2().
> > >> - *
> > >> + * Implement NFSv4's open semantics for regular files.
> > >> + * Both create (unchecked, guarded, and exclusive) and non-create.
> > >> + * Open state for this new file is subsequently fabricated in
> > >> + * nfsd4_process_open2().
> > >>   * Upon return, caller must release @fhp and @resfhp.
> > >>   */
> > >>  static __be32
> > >> -nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > >> -		  struct svc_fh *resfhp, struct nfsd4_open *open)
> > >> +nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > >> +		struct svc_fh *resfhp, struct nfsd4_open *open)
> > >>  {
> > >>  	struct iattr *iap =3D &open->op_iattr;
> > >>  	struct nfsd_attrs attrs =3D {
> > >>  		.na_iattr	=3D iap,
> > >>  		.na_seclabel	=3D &open->op_label,
> > >>  	};
> > >> -	int oflags =3D O_CREAT | O_LARGEFILE;
> > >> +	int oflags =3D O_LARGEFILE;
> > >>  	struct dentry *child =3D ERR_PTR(-EINVAL);
> > >>  	struct path parent =3D {
> > >>  		.mnt =3D fhp->fh_export->ex_path.mnt,
> > >>  		.dentry =3D fhp->fh_dentry,
> > >>  	};
> > >>  	__u32 v_mtime, v_atime;
> > >> -	__be32 status, create_status;
> > >> +	int createmode =3D -1;
> > >> +	__be32 status, create_status =3D 0;
> > >>  	int want_write_err;
> > >> =20
> > >>  	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
> > >> @@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct =
svc_fh *fhp,
> > >>  	if (status !=3D nfs_ok)
> > >>  		return status;
> > >> =20
> > >> +	status =3D fh_fill_pre_attrs_unlocked(fhp);
> > >> +	if (status)
> > >> +		return status;
> > >> +
> > >>  	if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> > >>  		/*
> > >>  		 * If name is already in dcache we need to check for mountpoints
> > >> @@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct=
 svc_fh *fhp,
> > >>  	if (!IS_POSIXACL(d_inode(parent.dentry)))
> > >>  		iap->ia_mode &=3D ~current_umask();
> > >> =20
> > >> +	if (open->op_create) {
> > >> +		createmode =3D open->op_createmode;
> > >> +		oflags |=3D O_CREAT;
> > >> +	}
> > >>  	/*
> > >>  	 * For the EXCLUSIVE modes we do our own uniqueness tests
> > >>  	 * so don't want O_EXCL.
> > >>  	 */
> > >> -	if (open->op_createmode =3D=3D NFS4_CREATE_GUARDED)
> > >> +	if (createmode =3D=3D NFS4_CREATE_GUARDED)
> > >>  		oflags |=3D O_EXCL;
> > >> =20
> > >>  	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
> > >> @@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
> > >> =20
> > >>  	v_mtime =3D 0;
> > >>  	v_atime =3D 0;
> > >> -	if (nfsd4_create_is_exclusive(open->op_createmode)) {
> > >> +	if (nfsd4_create_is_exclusive(createmode)) {
> > >>  		u32 *verifier =3D (u32 *)open->op_verf.data;
> > >> =20
> > >>  		/*
> > >> @@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct=
 svc_fh *fhp,
> > >>  		iap->ia_atime.tv_nsec =3D 0;
> > >>  	}
> > >> =20
> > >> -	create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> > >> -	if (create_status)
> > >> -		/* Might still succeed if no create is needed */
> > >> -		oflags &=3D ~O_CREAT;
> > >> -
> > >> +	if (oflags & O_CREAT) {
> > >> +		create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> > >> +		if (create_status)
> > >> +			oflags &=3D ~O_CREAT;
> > >> +	}
> > >>  	open->op_filp =3D do_lookup_open(&parent,
> > >>  				       &QSTR_LEN(open->op_fname,
> > >>  						 open->op_fnamelen),
> > >> @@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct=
 svc_fh *fhp,
> > >>  		goto out;
> > >> =20
> > >>  	if (!open->op_created &&
> > >> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
> > >> +	    nfsd4_create_is_exclusive(createmode) &&
> > >>  	    inode_get_mtime_sec(d_inode(child)) =3D=3D v_mtime &&
> > >>  	    inode_get_atime_sec(d_inode(child)) =3D=3D v_atime &&
> > >>  	    d_inode(child)->i_size =3D=3D 0)
> > >>  		open->op_created =3D true;
> > >> =20
> > >>  	if (!open->op_created) {
> > >> -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> > >> +		if (open->op_create =3D=3D NFS4_OPEN_NOCREATE ||
> > >> +		    createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> > >>  			/* NFSv4 protocol requires change attributes
> > >>  			 * even though no change happened.
> > >>  			 */
> > >> @@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nf=
sd4_compound_state *cstate, stru
> > >>  	fh_init(*resfh, NFS4_FHSIZE);
> > >>  	open->op_truncate =3D false;
> > >> =20
> > >> -	status =3D fh_fill_pre_attrs_unlocked(current_fh);
> > >> -	if (status)
> > >> -		goto out;
> > >> -	if (open->op_create) {
> > >> -		/* FIXME: check session persistence and pnfs flags.
> > >> -		 * The nfsv4.1 spec requires the following semantics:
> > >> -		 *
> > >> -		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> > >> -		 * Reply Cache  | server |                 |
> > >> -		 * -------------+--------+-----------------+--------------------
> > >> -		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> > >> -		 *              |        |                 | (SHOULD)
> > >> -		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> > >> -		 *              |        |                 | (SHOULD NOT)
> > >> -		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> > >> -		 * yes          | no     | GUARDED4        | GUARDED4
> > >> -		 * yes          | yes    | GUARDED4        | GUARDED4
> > >> -		 */
> > >> +	/* FIXME: check session persistence and pnfs flags.
> > >> +	 * The nfsv4.1 spec requires the following semantics:
> > >> +	 *
> > >> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> > >> +	 * Reply Cache  | server |                 |
> > >> +	 * -------------+--------+-----------------+--------------------
> > >> +	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> > >> +	 *              |        |                 | (SHOULD)
> > >> +	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> > >> +	 *              |        |                 | (SHOULD NOT)
> > >> +	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> > >> +	 * yes          | no     | GUARDED4        | GUARDED4
> > >> +	 * yes          | yes    | GUARDED4        | GUARDED4
> > >> +	 */
> > >> =20
> > >> -		current->fs->umask =3D open->op_umask;
> > >> -		status =3D nfsd4_create_file(rqstp, current_fh, *resfh, open);
> > >> -		current->fs->umask =3D 0;
> > >> +	current->fs->umask =3D open->op_umask;
> > >> +	status =3D nfsd4_open_file(rqstp, current_fh, *resfh, open);
> > >> +	current->fs->umask =3D 0;
> > >> =20
> > >> -		/*
> > >> -		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> > >> -		 * use the returned bitmask to indicate which attributes
> > >> -		 * we used to store the verifier:
> > >> -		 */
> > >> -		if (nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D=
 0)
> > >> -			open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> > >> -						FATTR4_WORD1_TIME_MODIFY);
> > >> -	} else {
> > >> -		status =3D nfsd_lookup(rqstp, current_fh,
> > >> -				     open->op_fname, open->op_fnamelen, *resfh);
> > >> -		/*
> > >> -		 * NFSv4 protocol requires change attributes even though
> > >> -		 * no change happened.
> > >> -		 */
> > >> -		fh_fill_post_noop(current_fh);
> > >> -	}
> > >> +	/*
> > >> +	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
> > >> +	 * use the returned bitmask to indicate which attributes
> > >> +	 * we used to store the verifier:
> > >> +	 */
> > >> +	if (open->op_create &&
> > >> +	    nfsd4_create_is_exclusive(open->op_createmode) && status =3D=3D =
0)
> > >> +		open->op_bmval[1] |=3D (FATTR4_WORD1_TIME_ACCESS |
> > >> +				      FATTR4_WORD1_TIME_MODIFY);
> > >>  	if (status)
> > >>  		goto out;
> > >>  	status =3D nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
> > >
> > > This patch is making the pynfs DELEG8 test fail. It seems like this
> > > patch breaks the behavior where the server sends back NFS4ERR_DELAY on
> > > an OPEN while waiting for a DELEGRETURN. The server just doesn't send a
> > > reply until the delegation times out with it.
> >=20
> > Neil, I need a response from you. How soon do you intend to address this
> > issue? Can this patch be dropped safely from the series, or do I need to
> > drop the whole series?
> >=20
>=20
> Hi,
>  sorry for not getting to this sooner.
>  I can see the problem.  To fix it we need to somehow get logic similar
>  to nfsd_open_break_lease() into the vfs_lookup_open() path.  I think
>  that'll be possible though not trivial.
>=20
>  It is safe to drop just that patch for now.  I don't need it for the
>  locking work that I am doing.  I think it is still good to have and I
>  will try to rehabilitate it, but not in a hurry.
>=20
>  I'm confident the rest of the series is not implicated in this problem
>  so there is no need to drop the whole series.

Hi Chuck,
 I notice this series wasn't in your recent pull request and they seem
 to have disappeared from your tree.
 What do you understand the status of these patches to be?
 I was hoping they would land this merge window.

Thanks,
NeilBrown
