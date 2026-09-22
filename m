Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 048A34F4CFC;
	Tue, 22 Sep 2026 21:55:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790114152; cv=none; b=tlVSOsmNb6M2yznDfVo9WzikivmI+kaQzQNWBDkBnJteZm6iIGdLJ/VTKcs/MJ1UU+YkcMWxAr2SzKyDYggLBbVeypY47Ou11AY4ab6fIzt0uQLvMbkjz7E9lCawi8Hne3TDF6qniVnhIDlaYVBkaDRdRRDY/KAC9BbnvjXlHp4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790114152; c=relaxed/simple;
	bh=Rlq1ydHLjWWDMingCHmssf5UF2zL0z/fg27y2YmYlVE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=fU3VQRXs+lhbyco8aurXXybsGz+wnfV/S0I9RCUiKCmU0gjeQdYR3cyr1ZQp0WbLDLBw5ESWqwN0Mu5JYOeZiZjyyv5nmYbCAq+Fiu2R/oNHjthDf68eaANza2EOwzkR8q89/8T5xtrk0VlsUAAqpl8kzqir56g3dqjiNRnDOI4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=cUZqjAgE; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Mvwx7utn; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="cUZqjAgE";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Mvwx7utn"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id B5DFE7A00E0;
	Tue, 22 Sep 2026 17:55:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Tue, 22 Sep 2026 17:55:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790114134; x=1790200534; bh=9cxMFAZN1rwjMGvRM6WC/pO1geQneeseFMr
	wRTLwy8k=; b=cUZqjAgEkzB2HSn2+Txzn159DVPC5ifbiB63heCrkFfaUvxeYMn
	QKiZgqehGCZbIl0CFUzhy5yJU8wMPl/fN6abEu8tkuFxArZRkcS7Dw0XfcTT/tP6
	A4goKFiphI2wZ4dLh33Yq2BCIip7+UBl8AtmVWn+foMsBWqqq9h4kF+T4tlyvBDv
	xsdexeGMnxPMDUy7wmholXo6Hut1uGErRrv+13aGPaWf7KlmSIXdByQ/tPLRQMsH
	fio/zMrPfuAc4J7IgBTjmLPhKhlYCrId7RY3LghnGLjcMIxuDTNc1e7W64V4jL38
	Niera5VQR/9mDCUI8DwczPkkR6LDMTcnt8w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790114134; x=
	1790200534; bh=9cxMFAZN1rwjMGvRM6WC/pO1geQneeseFMrwRTLwy8k=; b=M
	vwx7utn9is9oh5fVOGR/sSrDTE1zWWRS09ykIfkzr5G3EYXX911dPDNPElczh0sX
	fXk9UgmRRC8dHPCXiFmh72bTFlPnb0E9Hvk1obDvBPHJhepEu414iX2Wo4fAAFBB
	/vmiy6xm9yUWJkDlE+iEwaT7LBOonvcvQQ+jE9aTTqmsAsYuKqF/uaDOWvqGq0B4
	ByFhoy2fiSZUEOMhREIpbc/Sd6gyc0qu88B3WfTeyRVQ52uHdUUkVuG+w1ObwCFI
	C7pl7tyAJkI+nAMphyMxUW3BtXtUdORfY+NN6FYRi3bunf+AyS3+QKYcBiPgapDk
	ZBe/8zkStxnvtV+PwgeiA==
X-ME-Sender: <xms:Vvmyaqb8sNLuh-eyMbjxIAoMZU76tnhq1VdlZujYHdC4O5vBVT4NqA>
    <xme:Vvmyatxqb18A1QwyhtAXr2RJ--BtMuMob-swS4MU-SGoZZF27Bsn8aZDgZzOmVrB5
    chCPknZF3LMrF41Bgskbpyt1i_Dikb-0xMlyP2IQWA5QXq21uGb>
X-ME-Received: <xmr:VvmyamE1_IX93wrXAUO49tsDh3Alle0kM6TOX6-xrU0RLqrjRdvKDHGn-NcMeDosD3A-mrUbNeBIhupcLAq8Kwx7HchBHE4>
X-ME-Proxy-Cause: dmFkZTGFgSGc4eEkykbaPUU5fXwAoDmB5DvOUipLXkA/zVuom1NI6nCyU04A2n7WfqdDcc
    8L/AWx7/0szO7E6nvpB2K92z9j6LpJ6hF7LnDSWKJX7hpoRhRU/M8C2ZehO543bIk19A4t
    IgrOn5VnEams7G1AYjalz2BGObiNDKmBqO8yT9qf0DR01to1ttBZkkJEFKwwygzKQiaDLU
    fGBtCepX+C5xvKyyWBsPJT5nqvZSQ38SUwTJc2N1n62YecUysO012Ip729iVzN1JqnKKD2
    xuY6uk63K10Ig/sj6tszpGJ3jNtTFzRoqvbiVMrftNQvFtIUG+fXJBBv2Y5LJYHhOah8d0
    vNdXzUIBygG7XhHTWblwfYZ+iEe4CKk1tSBMhiN8bK3vZ1Xirjsbrnh73Pz3dPzzKWru4Q
    17ywvSvrjX9Xxu3ozEi9GVm3VreDLn7mL2rpkTB9hMW5v2YM3v3zb8VpxAZER2Oxhf1DV/
    p0tNRFQ97qGiUDE3ZpxWgXKb25iQuguo+UlQUYKVB/b7dRsPjIDcO7IyRBJFcUNSYEq6l0
    mWovvx1vuSdcENOTD4dRCSsn+rX35JhIMAiO1OtnAmD6qVKJw4eIYi5llYWq5+qBHtGHq4
    Xfj8VBD+i/nxLob2ehyk+hd8G+xvkP88iaq/gN/NS5/taFNdCSacHN8/C+zw
X-ME-Proxy: <xmx:VvmyaoqRlZWr6KXd0eAqf_wkh3DwPMuV0WsU1SEMBSsZnTFWC_QdrQ>
    <xmx:Vvmyakz414OTw_N5buYKu_ji3e3p_KBZlWi3KqYWZf4U9yfp4wi-BA>
    <xmx:Vvmyaiyo1KTQ5dU2TQiTsnF75gOKBXusHXOeVjuBzoGjhqt3W5EuGw>
    <xmx:VvmyajTAWLRhUU9SNlNOimJhtfAf_-eCZ8g-YBaugInJ6BFo4yH16g>
    <xmx:VvmyajMcJHZos82c05soTbYoMutgQn7PcnfR8RBoPsspI-B48CtDtb6j>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 17:55:28 -0400 (EDT)
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
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 12/14] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
In-reply-to: <0b2597f9-2af1-448d-9bff-c9a96a07068b@slotpi15m67>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-13-neilb@ownmail.net>
  <0b2597f9-2af1-448d-9bff-c9a96a07068b@slotpi15m67>
Date: Wed, 23 Sep 2026 07:55:24 +1000
Message-id: <179011412461.37859.5169498575115711178@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 21 Sep 2026, Chuck Lever wrote:
> On Sat, Sep 19, 2026, NeilBrown wrote:
> > The functionality that was recently gathered into do_lookup_open() is
> > now available from the vfs as vfs_lookup_open().  So nfsd4_create_file()
> > can call that, with a few adjustments.
> >
> > This implementation shares more code with syscall open paths and so uses
> > some filesystem interfaces slightly more correctly. Specifically:
> >  - it doesn't call ->lookup before ->atomic_open is called
> >  - it does pass LOOKUP_OPEN to ->d_revalidate
> >  - only gets exclusive lock on parent if name is NOT in dcache
>=20
> Thanks for listing these. Is the third item accurate, though?
> vfs_lookup_open() calls lookup_open() with no lookup_fast() step ahead of
> it, and lookup_open() picks the lock from O_CREAT alone, before it
> consults the dcache:
>=20
> fs/namei.c:lookup_open() {
>     ...
> 	if (open_flag & O_CREAT)
> 		inode_lock(dir_inode);
> 	else
> 		inode_lock_shared(dir_inode);
>     ...
> 	dentry =3D d_lookup(dir, &nd->last);
>     ...
> }
>=20
> AFAICT the parent is locked shared only when nfsd4_create_file() has
> already cleared O_CREAT because the NFSD_MAY_CREATE fh_verify()
> failed.

Yes, I was getting ahead of myself - or maybe thinking of
lookup_fast_for_open(), which we aren't using.
I think my proposed patches for locking changes will avoid the exclusive
lock in lookup_open(), but as you say we are not there yet.
I've dropped that line.

>=20
>=20
> > These are minor.  The main benefit is code-sharing. In particular
> > it takes responsibility for locking out of nfsd so that planned changes
> > can happen entirely in VFS code.
> >
> > We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from
> > break_lease of try_break_deleg() get passed back.
>=20
> "that that" is still here from v1. Also, s/break_lease of/break_lease() or/

Thanks.

>=20
>=20
> > We need to mask any type out of "mode" else vfs_lookup_open() will warn.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
>=20
> [ ... ]
>=20
> > @@ -412,11 +366,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >  		/* Might still succeed if no create is needed */
> >  		oflags &=3D ~O_CREAT;
> >
> > -	open->op_filp =3D do_lookup_open(&parent,
> > -				       &QSTR_LEN(open->op_fname,
> > -						 open->op_fnamelen),
> > -				       oflags,
> > -				       open->op_iattr.ia_mode);
> > +	open->op_filp =3D vfs_lookup_open(&parent,
> > +					&QSTR_LEN(open->op_fname,
> > +						  open->op_fnamelen),
> > +					oflags,
> > +					open->op_iattr.ia_mode & S_IALLUGO);
>=20
> Can this fail an OPEN that nfsd_permission() would have allowed?

Yes.  As you explain in detail (thanks) this is a problem.

This highlights a problem with using nfsv4 to re-export a remote filesystem.

Any non-standard permission checking we do in nfsd to handle reading
execute-only files, or opening recently created files without the
requested access, also needs to be performed on the server for a
re-exported filesystem.

Re-exporting NFS is probably safe because nfsd is already relaxed about
these permissions, with NFSD_MAY_OWNER_OVERRIDE and NFSD_MAY_READ_IF_EXEC.
But other filesystems may not be.

I wonder if we should communicate this through the VFS so we can at
least tell ->atomic_open and ->permission that it can be a little
relaxed about certain permission checks...

I don't know what is best, but will dwell on if for a while.

Thanks,
NeilBrown


>=20
> With 09/14 applied, an existing file that ->atomic_open did not open goes
> through vfs_lookup_open()->do_open()->may_open(), which does:
>=20
> 	error =3D inode_permission(idmap, inode, MAY_OPEN | acc_mode);
>=20
> do_open() zeroes acc_mode only when FMODE_CREATED is set. The removed
> do_lookup_open() used dentry_open() for a positive dentry, which makes no
> permission check, the same as __nfsd_open(). The permission decision was
> left to do_open_lookup()->do_open_permission()->nfsd_permission(), which
> runs after nfsd4_create_file() returns. Now may_open() fails first, and
> the two relaxations in nfsd_permission() are never consulted.
>=20
> The case I am most concerned about is a replayed exclusive create. An
> NFSv4.0 EXCLUSIVE4 OPEN carries no attributes, so:
>=20
> fs/nfsd/nfs4proc.c:nfsd4_create_file() {
>     ...
> 	if (!(iap->ia_valid & ATTR_MODE))
> 		iap->ia_mode =3D 0;
>     ...
> }
>=20
> and the file is created with mode 0000 until the client's SETATTR
> arrives. If the client resends the OPEN in that window (after a server
> restart, say), the dentry is positive and FMODE_CREATED is clear, so
> may_open() returns -EACCES for a non-root owner. The verifier comparison
> further down:
>=20
> 	if (!open->op_created &&
> 	    nfsd4_create_is_exclusive(open->op_createmode) &&
> 	    inode_get_mtime_sec(d_inode(child)) =3D=3D v_mtime &&
> 	    inode_get_atime_sec(d_inode(child)) =3D=3D v_atime &&
> 	    d_inode(child)->i_size =3D=3D 0)
> 		open->op_created =3D true;
>=20
> is never reached, so do_open_lookup() never gets to add
> NFSD_MAY_OWNER_OVERRIDE, and the retry gets NFS4ERR_ACCESS where it
> used to succeed.
>=20
> The other relaxation is NFSD_MAY_READ_IF_EXEC, which do_open_permission()
> always sets. An UNCHECKED create for read that finds an existing mode
> 0111 file now fails in may_open() with -EACCES. That is rare for a
> creating OPEN, but would 14/14 not make it the common case, since a
> client reading an execute-only binary sends a non-creating OPEN?
>=20
> Also, vfs_lookup_open() calls do_open() only when FMODE_OPENED is clear.
> Does that mean the result differs by exported filesystem? ext4, xfs,
> btrfs and tmpfs have no ->atomic_open and get the new may_open() check,
> while a re-exported NFS or a fuse export skips it.
>=20
> Would it work to let this caller reach do_open() with an acc_mode of
> zero, so that nfsd_permission() stays the only authority for NFS
> requests? If the new check is wanted on the nfsd side, the patch
> description needs to say so and explain how the exclusive replay case
> is handled.
>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20

