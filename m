Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7265017B425
	for <linux-nfs@vger.kernel.org>; Sun,  6 Sep 2026 04:53:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788670386; cv=none; b=grh4Yer9Eli+YAeEI4eBUFM+4S5r5c5LB+Nmjuj4yKhFUTtCOg3REtQwmKzEle3YUNqTWwlhRsSGcswWG6OyV0KmFHC6G6tFnheHAbiVJyU/G5Rk8LiTuyh+GS+tkjnURdxrlIE/d7/A+//nzzyADvxvxMiKpgxIQfajzSfjJKo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788670386; c=relaxed/simple;
	bh=29rKqpKNCOVtv2JzZTpXRZoOChdNILgBL5KLLYrguLE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=NcayePx0u9UjafURHY6/w26ee3N/DJ0zID+clg7t3d/DlY+VG8Ee1pKAo/se8ua//zVzRwP/fyyGxvpCNcZtVMn6qnskSv7stvfv1IobGzqty9toJrixStmN0W0L8Pzw8+1JbIQKnaDwaMocoLvWOMCsMiweiemkxqx/97ZThQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=nbgzicYZ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=I3b+OupT; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="nbgzicYZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="I3b+OupT"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7F9BE7A00A4;
	Sun,  6 Sep 2026 00:53:02 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Sun, 06 Sep 2026 00:53:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1788670382; x=1788756782; bh=F8iLOhqAT44WQKwiCa8B97nE8kM1eXCjGJx
	HiYNDv1I=; b=nbgzicYZNY3j29NSPSpkZL4dvJfa7KGyKcoxVw4R5UA76aUvfB5
	0DhwI2b8Imm2rMGUhzxIrQdD/WaoR3SoazmAwDT6dv7rKbQ1gt0iCfwEXCPicJFs
	SHsvR5KH6j8SS3FdUd5TK8bDJaRvRG7eR3VydJEQp2grGDATJi4lXgM84NC5s1En
	hEGRiQh471mfXW5bxeWbOjSkLWwdqJI2O81Tw6sPXRakqB7Y1GDM37OzuIGN8Blj
	v/LQqB6iceijZvUkruA3vK+42MlSXapmiBc4xoORam2bEfbCkefm0mYRJ+F5kDqR
	ayLjnOhGwSnVJczPXsyUBOIpEbzS8vRHYNQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1788670382; x=
	1788756782; bh=F8iLOhqAT44WQKwiCa8B97nE8kM1eXCjGJxHiYNDv1I=; b=I
	3b+OupTs+S6JCY14QDhzqQ8AaqvWmLO3sKamZzdECFjNI0y8J/rB2ooAA4HlMq8U
	Prgy1WHxSKnQEVzdTfpUBn56a6fiStoVvo+0dTU3u/YvUJix0i7xkrpP4QOwZlEZ
	uXTH4FTSzD3kk0zpZ2jmax8+/1olS9PmGkWPdH4hLIsXyvHU58BpygiJiM5vNaNw
	yISrlMt6GWL2PZNb907oHW8T0tLOxx46W0Ehq9uhbHj+47N2apc8XZwNIESeyEsI
	pwR67aofMwP9K+eTwbwiRGv19qJupNkJxStaFZDxMBjWFZrqHh0knwgfuQoZHpx7
	vZiwTnFWhLrHeL1kGww0w==
X-ME-Sender: <xms:rvGcal2-wnL0ef3jkp0tu0lhZanpvndNSz4jEW3UXEi2tanG-SIQHA>
    <xme:rvGcai-C2xIpYiP0yoHc-oi3OgyagMbor31emO3jbdQqYdDLU_hgYJs-CMXOKo5Vc
    9YrUMxYaAPUk_pIKj8xCfHPGJjAUnyAMGQQFliWRXEYH1IkMg>
X-ME-Received: <xmr:rvGcauM606aaafhz2nF5aRbJCfKkX2KLXd1EtSuVc13CaMh0cS4RIMVn7f0XhuDfiw>
X-ME-Proxy-Cause: dmFkZTE7pImLZmTKliB5wNj+lVNcDNnYImvdHzCLWsXS8xaNaFvvKYXCzCY/lXMiFUoI+F
    ON72OEYhqiGtlMgynn0Ghax8PYkp/Wn497hp8oc6+DMdhldkyehjtQb5u63Cd/9bNMESVi
    q1fniAaNMMXjBQ2y8XL6CLT2G9hjy3CZp56Gj2OOrgWZyLwu9cokU2i1wUMsAX94RsM+Ie
    hD7IUJLsw6uI/zyXpwWpgc+ldSylcUpPa/lz85DTBUOr1NEmiTAfWC1BXt4xvXbMHT2zcN
    IYqeZoRbWzpu/RrYhqb9BYnT+iDwFeoD/Yy5+npTbFnZhy87sklUp6wWhqqTPXeIO4NELv
    lo5RrTgDdQQtj9PzZwsOIXu36ss4xIGd4btgbW378nHWM2mqDsOUn8OrbQUhT/UdyarImr
    PCJCwFEEmn/j5qUMMrql0mUuzao4tBD1P6txjcML2T8u0+sSvAxrQvhmEVu2BPIFPW+B5K
    llJzrwoipbMNvsaGiW48kX/G742g6vgBf8B+UDxptNspb9F/WXuuooCxIL212r4yiGQYAu
    u3ZG/mmfCuZw357CCHe0LjfFpBr2DZbQLE0doed1QKa54BDSJDX/lv1rwU91yTP4Rv9BCt
    WnoXZi72ejMa+P6ea2GtUJCmteWGRkqiZpiPoaaw/Chil6sMdXYMNOvsUgqg
X-ME-Proxy: <xmx:rvGcaucuvXfkYVDSluXahVBrzjtNciL-tQLAYfcqZbuGxg4rFbuDXA>
    <xmx:rvGcalU_urceD9ocPup0XrjqIWw33gXUGRh7UN-fkdNs2hGCMSjH1g>
    <xmx:rvGcauiui6tk11Vt38mALtq2o_S3xIrDpk19vqHb3AhO1n8rG5J3RQ>
    <xmx:rvGcas8wt01CSCOCdEq5PoYKUf3FRD6sBEDN-yeFsVZQGxur5us1-A>
    <xmx:rvGcahi3i21z0t1svG0DmCbGZZsDLHb7y3DktdrxEkjdfxglPvLeU9rn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 6 Sep 2026 00:53:00 -0400 (EDT)
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
Cc: "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Christian Brauner" <brauner@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
In-reply-to: <8212e77c-fced-476b-ba64-3b8defcc65ad@app.fastmail.com>
References: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
  <8212e77c-fced-476b-ba64-3b8defcc65ad@app.fastmail.com>
Date: Sun, 06 Sep 2026 14:52:56 +1000
Message-id: <178867037632.207413.7103786340154818903@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 03 Sep 2026, Chuck Lever wrote:
> =E2=80=9Cnfsd: switch nfsd4_open() =E2=80=A6=E2=80=9D
>=20
> IIUC the patch modifies nfsd4_create_file(), not nfsd4_open() ?
>=20
> Several more issues below.
>=20
> On Tue, Sep 1, 2026, at 10:30 PM, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >
> > The functionality that was recently gathered into do_lookup_open() is
> > now available from the vfs as vfs_lookup_open().
> >
> > This implementation shares more code with syscall open paths and so uses
> > some filesystem interfaces slightly more correctly.  It also takes the
> > responsibility for locking out of nfsd so that planned changes can
> > happen entirely in VFS code.
> >
> > One difference is that do_lookup_open() would use nfsd_check_obj_isreg()
> > to get an error when the name exists but is not a regular file.
> > vfs_lookup_open() uses slightly different error code, particularly
> > returning -ENODEV when a device-special file is found.  So we need
> > to map that error to -EFTYPE.
> >
> > Unfortunately vfs_lookup_open() doesn't allow O_LARGEFILE so we need
> > to patch it to avoid a warning.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/namei.c         |  2 +-
> >  fs/nfsd/nfs4proc.c | 66 ++++++++++------------------------------------
> >  2 files changed, 15 insertions(+), 53 deletions(-)
> >
> > This patch is against nfsd-test.  I would like it to land there so it
> > best good nfsd testing over the coming weeks.
>=20
> Since it touches fs/namei.c, Christian will want to take this through
> the VFS tree. To get the testing you requested, I=E2=80=99ll have to merge =
the
> VFS tree into nfsd-next / nfsd-testing when it is ready for exposure.
> That might be a while.
>=20
>=20
> > Thanks,
> > NeilBrown
> >
> >
> > diff --git a/fs/namei.c b/fs/namei.c
> > index d95249dd527c..85fd5e8221e2 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent,=20
> > struct qstr *last,
> >  	int error =3D 0;
> >=20
> >  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> > -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> > +	WARN_ONCE(open_flag &=20
> > ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_LARGEFILE),
> >  		  "open_flag has unsupported flags");
>=20
> Two subtle behavior changes here. Were these intentional?
>=20
> A client sending mode 0040755 gets an inode created with S_IFSOCK|0755 and
> trips this WARN_ONCE. The old code clamped the incoming mode with S_IALLUGO.

Thanks for catching that - easily fixed.
Though maybe it should be caught earlier - at xdr time?=20
RFC8881 section 18.16.3 says
    The set of attributes may include any writable attribute valid for
    regular files
and it would be hard to argue that S_IFSOCK is valid for regular files.
Maybe it isn't worth doing that sort of validation in xdr-decode.

>=20
> Looks like a GUARDED4 create over a non-regular name now returns NFS4ERR_EX=
IST.
> The old code returned ISDIR or SYMLINK. Does this match NFSv3=E2=80=99s beh=
avior? Should
> the commit message provide a rational that this is intended, or is a type
> check needed?

NFSv3 return NFS3ERR_EXIST.  NFSv4 used to return NFS4ERR_EXIST.  But I
broke it in
   nfsd: (almost) always open file in nfsd4_create_file()
so I'll need to fix that and following patches.
Would you like to drop the whole series and I'll resend, or just from
that error onwards?

>=20
>=20
> >  	mode |=3D S_IFREG;
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 33dc92d48ce0..ae70f7489d95 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -213,52 +213,6 @@ static inline bool nfsd4_create_is_exclusive(int=20
> > createmode)
> >  		createmode =3D=3D NFS4_CREATE_EXCLUSIVE4_1;
> >  }
> >=20
> > -static struct file *do_lookup_open(struct path *parent,
> > -				   struct qstr *name,
> > -				   unsigned int oflags,
> > -				   umode_t mode)
> > -{
> > -	struct file *filp =3D NULL;
> > -	struct path path;
> > -	struct dentry *child;
> > -	int want_write_err =3D 0;
> > -
> > -	want_write_err =3D mnt_want_write(parent->mnt);
> > -
> > -	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
> > -	if (IS_ERR(child)) {
> > -		filp =3D ERR_CAST(child);
> > -		goto out;
> > -	}
> > -	path.mnt =3D parent->mnt;
> > -	path.dentry =3D child;
> > -
> > -	if (d_really_is_positive(child)) {
> > -		/*
> > -		 * open the file so that we consistently have a valid
> > -		 * op_filp and consequently a valid ->f_path.dentry.
> > -		 */
> > -		int err =3D nfsd_check_obj_isreg(child);
> > -
> > -		if (err)
> > -			filp =3D ERR_PTR(err);
> > -		else
> > -			filp =3D dentry_open(&path, oflags, current_cred());
> > -	} else if (!(oflags & O_CREAT)) {
> > -		filp =3D ERR_PTR(-ENOENT);
> > -	} else if (want_write_err) {
> > -		filp =3D ERR_PTR(want_write_err);
> > -	} else {
> > -		filp =3D dentry_create(&path, oflags, mode, current_cred());
> > -		child =3D path.dentry;
> > -	}
> > -	end_creating(child);
> > -out:
> > -	if (!want_write_err)
> > -		mnt_drop_write(parent->mnt);
> > -	return filp;
> > -}
> > -
> >  /*
> >   * Implement NFSv4's unchecked, guarded, and exclusive create
> >   * semantics for regular files. Open state for this new file is
> > @@ -390,13 +344,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct=20
> > svc_fh *fhp,
> >  		/* Might still succeed if no create is needed */
> >  		oflags &=3D ~O_CREAT;
> >=20
> > -	open->op_filp =3D do_lookup_open(&parent,
> > -				       &QSTR_LEN(open->op_fname,
> > -						 open->op_fnamelen),
> > -				       oflags,
> > -				       open->op_iattr.ia_mode);
> > +	open->op_filp =3D vfs_lookup_open(&parent,
> > +					&QSTR_LEN(open->op_fname,
> > +						  open->op_fnamelen),
> > +					oflags,
> > +					open->op_iattr.ia_mode);
> >  	if (IS_ERR(open->op_filp)) {
> > -		status =3D nfserrno(PTR_ERR(open->op_filp));
> > +		int hosterr =3D PTR_ERR(open->op_filp);
> > +
> > +		/*
> > +		 * NFS doesn't differentiate between device files and
> > +		 * sock/fifo when reporting an error.
> > +		 */
> > +		if (hosterr =3D=3D -ENODEV)
> > +			hosterr =3D -EFTYPE;
> > +		status =3D nfserrno(hosterr);
> >  		open->op_filp =3D NULL;
> >  		if (status =3D=3D nfserr_noent && create_status)
> >  			status =3D create_status;
> >
>=20
> Since NFSD threads now sleep on directory delegation recalls, if lookup_ope=
n()
> passes a real delegated_inode, it waits in break_deleg_wait() and retries f=
or
> up to lease_break_time.
>=20
> The old path called vfs_create(..., NULL), so the client got NFS4ERR_DELAY
> instead. NFSD needs to continue to work this way, otherwise a client can
> cause all the NFSD threads to block.

Clearly I haven't been thinking about delegations enough.
I will probably add a LOOKUP_whatever flag to say "Don't wait for a
delegation".

Thanks,
NeilBrown


>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20

