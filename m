Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5469933FE0A;
	Sat, 12 Sep 2026 03:22:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789183367; cv=none; b=pv4h9hAxMoe65q84ZAbUWSDCqN4XRY55zhkY71E23xNB9HwCj2W5yXr0sR1wNXd79hDfVMnsjnYqVtrL7FYGAGSMFtQ5a8hIsUFu+/oNc86Smblb1yjOZo2KmZggARugWb+vzxuM0brBx0i/bYqyBTW+FL9PN4Z+diW2ultf60M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789183367; c=relaxed/simple;
	bh=rHyj8nq9SdrAr2DUo80gEqH/12gyneM1TuNITgfQrTs=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=mIWUnAs7aWOP2LgHXRVwc3oYHlsXKcUJPhsdSfPDImaINouYxFHjIENmUgkVQ+QF3RMBO/271OnaSp74Va10uJ5339o0RQOGVmoOCxge3EeiF4Za5Zctt0AROnKBkH0Y9sNAqqDefzpWuaOat7GRCN1midOlM69nlackJuB4LEA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=I9/6UaqO; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ayFVm+5c; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="I9/6UaqO";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ayFVm+5c"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 5EFF27A00F8;
	Fri, 11 Sep 2026 23:22:44 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-08.internal (MEProxy); Fri, 11 Sep 2026 23:22:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789183364; x=1789269764; bh=Jvxm21li6FThkcO5YWEXqyyO/3eSjsqM6Kr
	qScf4LbE=; b=I9/6UaqOsTyZVMRNip2KQma9PpgNBBe53waVm2ujlEOE6e2HC2Z
	imYEUeuFCd4KDhNOuYzRhcrjG/F+Ph9aALvqy/VKHfrAiOp9UOceCsSeX6L2yfck
	aTIwnCCxTAgixc9CbftEUYFkniMI97o/Gr95GT6RyEg8VRo7ZLnmNUEe2pbq1IbS
	N4Lz4pd4V2owOQkTkR/TI1XH42ABd5v20injcoUmlTO11CfTdnS+jXDVZmtUfnvt
	j6HsqYZqD2VGrVeJwdHLsmzvhOQu2/yp60yHSqJiUPbki6b9YzGldJ18gE9VTY25
	xO+G0wLlIUNajDHVx/kH0Xlf1Wy4rLikhmQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789183364; x=
	1789269764; bh=Jvxm21li6FThkcO5YWEXqyyO/3eSjsqM6KrqScf4LbE=; b=a
	yFVm+5cCrvRnOM8KSK2pdPLq7peJZPq0vZmEq83q1Cv9vrdHriErv/lSDu7iDfx9
	4vLCHoyIuGEKQObF7J1aXaDiEm0WtWzdfIGqvNie38oDxQyxs5xsNySeQxBeMlz+
	o1i62ZdGNVC3rDsz2UeHjMPAtF9lCg8UiL8pIl63vxNEQO3DmzzGC4rvh62HRP0X
	YyDOOu6h0hstiDSYo0F/AyBiK9phkDtMbLIy8Z975gTvJ6tt68Bh657F8VaF1AGE
	qPvrE/tR0SOvTIydNPjrh51bnkR1ivRsiclXyp/cjMkgc8GiRtobLRddxI1pALy9
	FQklsQVugzTVdZO+RJKhA==
X-ME-Sender: <xms:hMWkaq2WFov-FWp3NNAxTSTairZfIZ9Rg0OFiSdVEi5hAtK0m7F9MA>
    <xme:hMWkavWZR3DcyhvnUYYDTBo59NMzUYvrp7GTwI2zHB_aA0st24NG2gqJOB5nWYk2U
    EpgyQQeOSb_aMgO5XH4jXgUwQgj5ANsPihzCVk8eJ1QkC6_jfY>
X-ME-Received: <xmr:hMWkalKH7nHAKEU-5j6X_K2j9X_X_R_p0VE3uHQyR6qZXn-lBFNl5oTGc04F7yM5mAdAwNyccG9siXTUfcX4OyxR7CHZOI0>
X-ME-Proxy-Cause: dmFkZTFhrcs22ggi7R9L8CbrlUewdX7Wk0XephWPGw7sKWHxPvm2UjXaKqLMcd/yfhxTGp
    rKasg2mk9G6xr2uy6ePW3iEjCkbeRxg69FpCj08fvXcFNcRLGR+K5iXS7Ok8M5hRt+Pehc
    NNt9Sp1TTrrdLj+zoWZXOU6uQuZgHxgtnW9B5ArTgvWyCqytfEUYASZtwcipBDyETB4TiZ
    jCYQcHEMybYP4D0dnVO8Lsw4ZkrW2IEp3TWGv5eHOW7AbOVt9r9AyciKAhcSDi6ucOKs6u
    wH4F0lOwu9fhQJTUnabq16Sn4yd5d0BNjQRROweD9KB2LSp0UPDWXB0iU4PQLVRqYAdCgY
    brE4lFHXDNFU1JeIytY9yLNVTN9xYpKNimvwmQubYRC8rs564wnLBftNiu1fDGeuq8nRMD
    TzNsGIK8mueCvA+VIltKb65xoU/IrbO554p3vn0o2SxCOx33/qKOzhIUn4xTkNtaVsdf0A
    6kV+2BY4oKj2gI2qn0tJTLE4pAAVf3u5JfuRGz8MNm1YlDiCuyFGMfw3rseHYAGqhfYgMU
    uhE3ZN1IkcYWCvOSEx51d8uBrZPMl1SVPUI3rB4NSnx2zWgMDOU3XKToGnRGLCYhnts962
    1x/BfCFfcVPMeQVEGEbYHKqqSXNGV+gV3pVfhFAZ0QaFOEccS3vH6+Ap8RXQ
X-ME-Proxy: <xmx:hMWkah24ajoV5JkmzsVIuq2AnslfpTxhohna7wZFlvQrKoRSxUbq3Q>
    <xmx:hMWkar5GS-mYgptDvM2bvywqvGYGEOxWQHhXehh_G5-vpq4MYce2wQ>
    <xmx:hMWkaq8yEUQqO_IfbQj5e-g2h-JDrP2nXe7fPQepjFY5ja4jC53gFA>
    <xmx:hMWkaiUqCl7qUzz5cAh1t_AeDsiJwg-vSQhQkbSonohVkW2DHyjc-A>
    <xmx:hMWkakg9VAE2VWOT5u0A4KJzin2dSZKeoei7e6nl4SYQ0xvP3b-IDrhl>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 11 Sep 2026 23:22:41 -0400 (EDT)
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
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/7] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
In-reply-to: <e36532d5-e37f-4d71-b83a-c8d19d87811f@slotpi15m67>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-6-neilb@ownmail.net>
  <e36532d5-e37f-4d71-b83a-c8d19d87811f@slotpi15m67>
Date: Sat, 12 Sep 2026 13:22:38 +1000
Message-id: <178918335830.207413.5617836439117097761@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 11 Sep 2026, Chuck Lever wrote:
> >     This implementation shares more code with syscall open paths and so u=
ses
> >     some filesystem interfaces slightly more correctly.  It also takes the
>=20
> Which interfaces? The concrete difference I can see is that lookup_open()
> honors ->atomic_open, which do_lookup_open() never called. Naming that
> would be clearer than "slightly more correctly".

It is more subtle than that.
do_lookup_open() calls dentry_create() which calls ->lookup_open().
But do_lookup_open() calls start_creating() first, which might call
->lookup.

So a NFSv4 OPEN for name that isn't in cache will (before this change)
call ->lookup() and if that fails, will call ->atomic_open().
After this change the ->lookup() will be skipped because it isn't
needed, ->atomic_open will do the equivalent.

Also the start_creating() in do_lookup_open() doesn't pass LOOKUP_OPEN
to d_revalidate so that revalidate does more work (I think).

Also do_lookup_open() will always exclusively lock the directory, while
vfs_lookup_open() will only do that if the name isn't in the dcache

So they are subtle differences, and only slight.  And I might have
missed some.  Maybe I could summarise them better.  The main point,
though, is to use the same code path as syscalls.=20

>=20
>=20
> >     We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from
>=20
> Repeated word: "that that".
>=20
>=20
> >     vfs_lookup_open() always returns -EFTYPE if a non-regular-file was
> >     found, and provides the dentry in parent.dentry.  We can use
> >     nfsd_check_obj_is_reg() to turn this into an error.
> >
> >     As parent.dentry could be NULL, we enhance nfsd_check_obj_is_reg() to
> >     cope with that.
>=20
> The function is nfsd_check_obj_isreg(), in both places.
>=20
>=20
> >     vfs_lookup_open() will return -EEXIST if required for
> >     NFS_CREATE_GUARDED4 as O_EXCL is passed in.  Other checks for
> >     and existing object need only test for nfsd4_create_is_exclusive().
>=20
> s/and existing/an existing/, and the identifier is NFS4_CREATE_GUARDED.
>=20
> The -EEXIST claim holds only on the path through the tail of
> vfs_lookup_open(), where the O_EXCL test runs before the d_is_reg()
> test. When lookup_open() itself returns -EFTYPE, vfs_lookup_open()
> returns before either test. See below.
>=20
>=20
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 3a82af381a8d..0fd5a6411ed3 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
>=20
> [ ... ]
>=20
> > @@ -312,7 +269,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
> >  		.na_iattr	=3D iap,
> >  		.na_seclabel	=3D &open->op_label,
> >  	};
> > -	int oflags =3D O_CREAT | O_LARGEFILE;
> > +	int oflags =3D O_CREAT | O_LARGEFILE | O_NONBLOCK;
>=20
> Nit: do_dentry_open() strips O_CREAT, O_EXCL and O_TRUNC from f_flags
> and leaves O_NONBLOCK in place, so op_filp now carries O_NONBLOCK into
> the filecache entry that nfsd_file_acquire_opened() builds from it.
> Files opened through __nfsd_open() do not. Is that divergence
> intended?

No, but it should be harmless.  O_NONBLOCK doesn't affect IO to regular
files, only the act of opening them.  This new behaviour is the same
outcome as opening a regular file with O_NONBLOCK from user-space, and
consistency is good.

>=20
>=20
> >  	struct dentry *child =3D ERR_PTR(-EINVAL);
> >  	struct path parent =3D {
> >  		.mnt =3D fhp->fh_export->ex_path.mnt,
> > @@ -424,28 +381,29 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >  		/* Might still succeed if no create is needed */
> >  		oflags &=3D ~O_CREAT;
> > =20
> > -	open->op_filp =3D do_lookup_open(&parent,
> > -				       &QSTR_LEN(open->op_fname,
> > -						 open->op_fnamelen),
> > -				       oflags,
> > -				       open->op_iattr.ia_mode);
> > +	dget(parent.dentry);
> > +	open->op_filp =3D vfs_lookup_open(&parent,
> > +					&QSTR_LEN(open->op_fname,
> > +						  open->op_fnamelen),
> > +					oflags,
> > +					open->op_iattr.ia_mode & S_IALLUGO);
>=20
> Nit: after this call "parent.dentry" is the child (or NULL), while a
> few lines up IS_POSIXACL(d_inode(parent.dentry)) reads the same
> expression as the parent directory. The VFS patch renamed its parameter
> to @path for this reason. Would renaming the local here avoid the same
> trap?

Probably sensible - yes.

>=20
>=20
> >  	if (IS_ERR(open->op_filp)) {
> >  		int hosterr =3D PTR_ERR(open->op_filp);
> > =20
> > -		if (open->op_createmode !=3D NFS4_CREATE_UNCHECKED) {
> > -			switch (hosterr) {
> > -			case -EISDIR:
> > -			case -ELOOP:
> > -			case -EFTYPE:
> > +		if (hosterr =3D=3D -EFTYPE) {
> > +			if (nfsd4_create_is_exclusive(open->op_createmode))
> >  				hosterr =3D -EEXIST;
> > -			}
> > +			else
> > +				hosterr =3D nfsd_check_obj_isreg(parent.dentry);
> >  		}
>=20
> Does this drop the NFS4ERR_EXIST mapping for GUARDED4?

GUARDED4 causes O_EXCL to be set so we never get -EFTYPE, only -EEXIST.

>=20
> The old test covered GUARDED as well as the two EXCLUSIVE modes.
> nfsd4_create_is_exclusive() covers only EXCLUSIVE4 and EXCLUSIVE4_1, so
> a GUARDED open that finds a non-regular object now takes the else arm
> and returns NFS4ERR_ISDIR, NFS4ERR_WRONG_TYPE, and so on. RFC 8881
> section 18.16.3 says a GUARDED4 duplicate is NFS4ERR_EXIST.
>=20
> Keeping "open->op_createmode !=3D NFS4_CREATE_UNCHECKED" here would
> restore the old mapping without depending on the ordering of checks
> inside each filesystem's ->atomic_open.

I would argue that returned -EFTYPE when O_EXCL was given is not just an
ordering issue, it is an error.

Maybe defensive programming is more sensible - but I didn't like the
noise of testing multiple cases...

>=20
> Separately, can this arm return nfs_ok? nfsd_check_obj_isreg() returns
> 0 for a regular file, and vfs_lookup_open() can leave a regular file in
> parent.dentry when the d_lookup() it does after an -EFTYPE races with a
> rename (the VFS marks that case with a WARN_ON_ONCE rather than
> excluding it). nfserrno(0) is nfs_ok, op_filp is then set to NULL, and
> nfsd4_create_file() returns success with resfhp never composed. It only
> fails safely today because do_open_lookup() then calls
> nfsd_check_obj_isreg() on the NULL fh_dentry. Something like
>=20
> 		if (!hosterr)
> 			hosterr =3D -EFTYPE;
>=20
> would address that.
>=20
>=20
> >  		status =3D nfserrno(hosterr);
> >  		open->op_filp =3D NULL;
> >  		if (status =3D=3D nfserr_noent && create_status)
> >  			status =3D create_status;
> > +		dput(parent.dentry);
> >  		goto out;
> >  	}
> > +	dput(parent.dentry);
> > =20
> >  	child =3D open->op_filp->f_path.dentry;
> >  	open->op_created =3D open->op_filp->f_mode & FMODE_CREATED;
> > @@ -462,7 +420,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
> >  		open->op_created =3D true;
> > =20
> >  	if (!open->op_created) {
> > -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> > +		if (nfsd4_create_is_exclusive(open->op_createmode)) {
> > +			status =3D nfserr_exist;
> > +		} else {
>=20
> Same question here. GUARDED used to get nfserr_exist from this branch
> and now gets the "no change happened" arm. It is unreachable for GUARDED
> today only because vfs_lookup_open() returns -EEXIST whenever O_EXCL is
> set and nothing was created. Should this also stay as
> "!=3D NFS4_CREATE_UNCHECKED" so the protocol rule is enforced here rather
> than relying on that ordering?

I'll think more on this...

Thanks,
NeilBrown


>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20

