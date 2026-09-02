Received: from fout-b7-smtp.messagingengine.com (fout-b7-smtp.messagingengine.com [202.12.124.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 308FB4399C6
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 22:38:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788388696; cv=none; b=NjG1VhMRHVyatoofkVVckbJoyEnfs07GM/bXlsNzvYDJtyUWOTOxVsdFsfmI2Psoaage1kZIxH2QEOmCO10sLczaNKYy13x8uh/Gx4iBOXRAwD682L/7ZvHDyPbj40gH60KK3POaJ2pDZg+Px5pLpQLhPousjnkzZcHXHrLybTQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788388696; c=relaxed/simple;
	bh=j8+OgxO/xhG2qSX6mKZ6wAWj5LLE9dsS2iU8q/K/7C0=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=UtblXcCQVnnuF65T2rjOdfvigr2+sdy6YEeUkeruNakhlYXd/B3+gLNCAhZ8pNf949yt21sXHa4lFZEhJq/AsX8UGtOFevnzaKnTsBk6Pmp2fUrvuYlPEVSD2Pu7MjeuNi2uH9zEfTKM9U9GHlPXL/Xrb9wdxnBerJBHbmrcjD8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=OH5ABdZE; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=FVYbVlWt; arc=none smtp.client-ip=202.12.124.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="OH5ABdZE";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FVYbVlWt"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id 52EE61D000FA;
	Wed,  2 Sep 2026 18:38:07 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Wed, 02 Sep 2026 18:38:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1788388687; x=1788475087; bh=4CCPY7UxBa2cJalJOTkH36VBLCq0DkCE3QR
	OvVknJjE=; b=OH5ABdZEcJuvrOxWAu0BOprdW5FbrU1FacnptSEgmYRsBpPPwda
	eTPoM9I7MMwLlROwIxY9+yofrXj1v9HUKXlsXtCLRz4eetVLujEn5wko3D5fr6/T
	3KXBsqY0choMdGbNeh7E7q/eqPjdHpcVKRYXQbq34+hJRDf8qpM++zzmuueFOMVm
	JgTqJSCCIbKuHXhRgeAakc50nW2lZRbLUQ1DIEoUEmXJ969eQCk2INGx1QZIQUnU
	Ihl+w5RHV4bWuFIHMfMVPKRaVECzpNeJGWGV21xQFr5ArM43GOnCa8+c5hCOtb8T
	kcwiugnwFramjuFUSUvFgGwHPZcxeZ2Mr+Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1788388687; x=
	1788475087; bh=4CCPY7UxBa2cJalJOTkH36VBLCq0DkCE3QROvVknJjE=; b=F
	VYbVlWtvOONqS2LfIFstMz9G/r9+kNWbk6wSa+3+dCO5WRM7WlXfwX6UC60xDG5W
	GoC0B1wOkkG3zIyitaXOsaaLfx27LMZdBtmRWx0lm8yeCRHV6N9UreQUAOJbQLgh
	775DNFvQ/IJQozPxfwFtTqo3K4mfNOrg8KcS0tLU4Z40FGWkZB64F4Zp4YJwFb2b
	Frl1WMCXq3yvYPH0fk5lwkZWffYrH2JaLUtUiP/iHfir58tXcIS42v49m3AJEiMW
	XHYWU0OHd0J23uFj3XvWtUZLvYHJrL7G4tZ7bpBvkgkR7r+kWc8oLkMCQPSZ/cFv
	GJ6mXNYEHduX3JOpGu52A==
X-ME-Sender: <xms:T6WYat98T3aFhVHOhkzP7PLRPlXZiXa2AIGvgqgFvLFOFfuNmbCTuQ>
    <xme:T6WYaotFy6zBzjvTHjDkjl-E3RUXmMNcdO1Te1L_6daMjm1mmO4dqvgCiCL0RUGWX
    uf1QCKLUZpWAgvhhgU9-naTf64oW8T5awwkBmF_BvLhkQ0V_Qs>
X-ME-Received: <xmr:T6WYagCMFUfeGg91zq3T_LOSwlMMsyM1On_kRugZ2xtVb_vn7Xn51S0jy26hpurTzuXPh8i8f8LUO1qSUR_rJWzoSu7lWFU>
X-ME-Proxy-Cause: dmFkZTEcsLbR0cCbBCkhghL8wXmjRyhCM9+OQMaUvLF/K45Z0dUFmzEUW9jIHTXNz7PkP2
    4+75ezEdKemrtBwOuBQo5LKIKyo3+sPmJFzzN6hPuVujfyoL+STItgdtIf18yVE265DMEm
    daOWQhcGPibYN6tKv3cjhENc86XB3BGun8ecma0M2qXABa9LRc3/MfjQ0TBMUVQZSEym2I
    uWCx+2CjFfkT3Y753aKgnR205j+xy1nRP1At/22hEdSqpE+9w9d05CewrJXEm0w/z6zXlK
    OiMXsZaYVPdVwFr2CfOkM00SD7kJqJ/UrjWt78hbfyM483/FxD2ltpvxppcnArfoS2hvD4
    +3mbIYkABH0fKD1vMd2lnYXq0IVTrfdbsbWHCXyMJnPmLzhyCvb8b0t0IpvSCV8AX+dkym
    TQOoOEV0LCSYUc3ZVMdB+dEaMrOL0qu+4IaWkq0DfXYR2Iyo/hwEsPz0FqQcHQRMujYB0q
    pPhCniFBlqTOq/x0HKqpK/l5vTaN8ehx4X+Yqmwb6rJcV7mwGYvUDrSUGUpMqWaUq5Na6Z
    CjuG+omj8Sf+U/3MaH3shxgqgYQ1L5v125pR6svgkRuEjqiaUxQwUl/juh/5XukujmkoCy
    nE3pqNofQ/+XHFdesyzsf11peyBKQd3G7PoZiW4v5Io3gqTLIJ5lLsBTHnow
X-ME-Proxy: <xmx:T6WYagWqFIl1--sA-e1MMbigJuxu9WWS7w0kcBva0M5yVQT08mdHyg>
    <xmx:T6WYauAXaq74TdcPEOhMfoYDIHS9iLEbf7ZcDTCpYAiosS1x5oAHnw>
    <xmx:T6WYaj-4tSXvXjz4hDJZFTxsVNACCqmb6DVzMWXR_Zd0kayXzgGMbg>
    <xmx:T6WYalEg51WR3xmkfVlvIQb5xHBWD6AqVZAi4fSt-iTpcwGEHM7DdA>
    <xmx:T6WYagLKlh3xDoabw_KU6-843kSgtrul14o6yfYbk3aRuvyBvO2WwfYb>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 2 Sep 2026 18:38:05 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
 "Christian Brauner" <brauner@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
In-reply-to: <35959e0bcd4223ccf8e258962e56bdb1ad6d48f9.camel@kernel.org>
References: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
  <35959e0bcd4223ccf8e258962e56bdb1ad6d48f9.camel@kernel.org>
Date: Thu, 03 Sep 2026 08:38:01 +1000
Message-id: <178838868118.3510150.12439962115074581103@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 02 Sep 2026, Jeff Layton wrote:
> On Wed, 2026-09-02 at 12:30 +1000, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >=20
> > The functionality that was recently gathered into do_lookup_open() is
> > now available from the vfs as vfs_lookup_open().
> >=20
> > This implementation shares more code with syscall open paths and so uses
> > some filesystem interfaces slightly more correctly.  It also takes the
> > responsibility for locking out of nfsd so that planned changes can
> > happen entirely in VFS code.
> >=20
> > One difference is that do_lookup_open() would use nfsd_check_obj_isreg()
> > to get an error when the name exists but is not a regular file.
> > vfs_lookup_open() uses slightly different error code, particularly
> > returning -ENODEV when a device-special file is found.  So we need
> > to map that error to -EFTYPE.
> >=20
> > Unfortunately vfs_lookup_open() doesn't allow O_LARGEFILE so we need
> > to patch it to avoid a warning.
> >=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/namei.c         |  2 +-
> >  fs/nfsd/nfs4proc.c | 66 ++++++++++------------------------------------
> >  2 files changed, 15 insertions(+), 53 deletions(-)
> >=20
> > This patch is against nfsd-test.  I would like it to land there so it
> > best good nfsd testing over the coming weeks.
> > Thanks,
> > NeilBrown
> >=20
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index d95249dd527c..85fd5e8221e2 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
> >  	int error =3D 0;
> > =20
> >  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> > -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> > +	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_=
LARGEFILE),
> >  		  "open_flag has unsupported flags");
> > =20
> >  	mode |=3D S_IFREG;
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 33dc92d48ce0..ae70f7489d95 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -213,52 +213,6 @@ static inline bool nfsd4_create_is_exclusive(int cre=
atemode)
> >  		createmode =3D=3D NFS4_CREATE_EXCLUSIVE4_1;
> >  }
> > =20
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
> > @@ -390,13 +344,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >  		/* Might still succeed if no create is needed */
> >  		oflags &=3D ~O_CREAT;
> > =20
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
> >=20
> > base-commit: f5dc2038906bb0c9627c99bea06dd7786b5ac2d1
>=20
>=20
> This looks good to me, but sashiko noted a lockdep issue you probably
> want to address:
>=20
>     https://sashiko.dev/#/patchset/178831622346.3510150.1073595830842947307=
6%40noble.neil.brown.name

This is of no consequence.
start_creating() doesn't really need I_MUTEX_PARENT as the child will
never be locked.  Only start_removing() and start_renamed() need that.
But it was simpler to use the same subclass for all cases.

lookup_open() could use I_MUTEX_PARENT but doesn't need to as the opened
inode will not be locked, whether it is created or not.

>=20
> Other than that though, this looks good to me. Much less "fiddly".
>=20
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
>=20

Thanks,
NeilBrown
