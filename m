Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FE9439792C;
	Fri, 18 Sep 2026 02:12:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789697540; cv=none; b=bJYsSb9eK1XRn+XVal/DQyQ8UOggSolCYu/EJs1ETWBhoTcpEpUGgg8Ha9zO7wkfMWavh+BCGmkl2fx1N6z4Fxaqmh/k7J1v+Q6hojTT2W1ZXkJzZjZp8I0anoUEro5cF3WFfAqIqHtuJVo74dcIrkUNgqY3pcPZL2bvBcb4iI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789697540; c=relaxed/simple;
	bh=pZmHX+iGUOdals0irhlgAyqz7F7olznSdB9QVGfd2EA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=GuZRUbKof5GpdBaEdVEV5rpPYR2r8UMOWW8SqcnBFPztk35VgyDlvO+ITOlhFl790X1uDUl33YNYmvPlL06q3GpmqVeG8ELrM4Zqu17yW/tgpTGc8sJU9r+cNBFY2aup0qjxD0GETkrbN8MG8fD42Xvus1V9SB6Ho2x2pUxbeig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YUsvav3W; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=s2rQI6nK; arc=none smtp.client-ip=202.12.124.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YUsvav3W";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="s2rQI6nK"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 455F77A0145;
	Thu, 17 Sep 2026 22:12:16 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Thu, 17 Sep 2026 22:12:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789697536; x=1789783936; bh=h1l8qqHj//2ca6jsg5sKHZQ8GI4Xi5oHcVX
	WUwf4J0Y=; b=YUsvav3W2f8//JHo1E7fXulTOZWGjHf7chuSfG4J/a63b0oEfnL
	eK6tijXPJQ1a1lCFEZ1RqLW50MpLgk+fQQWciDVGvVGCLnWF6lwZNu9ScnyDisZ6
	m4+tePUaBm/zGmMwSeZ7OBf+xOy4/CNfTU0lVb+7U5d2So2OE0VCXBzuROtK1NKv
	QyiJR9KwRkB/p9bU8LME/m+/dClHBU3309+/dXvUjtjLUx+CLi0QQfVy70tkJYZY
	+3UwunynmLh4hXuDo92h8t7+tiduH9kX2apxyhkpvMITxFyIjWBmyo0ggPDRF+EZ
	F8GpS3mPbqJCsoxVotsoCfeNgoAxVle/Obg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789697536; x=
	1789783936; bh=h1l8qqHj//2ca6jsg5sKHZQ8GI4Xi5oHcVXWUwf4J0Y=; b=s
	2rQI6nKf/jpMGlZRkPa7ho6xfVyhE4NUEjvJTyo1+pjsHnLdsdfk/UuRjAmI01YU
	ssz5cu7SV0vP7TRg0KDD376GFZUg5eG3eDedJzPDLzuReAVtw11AHgLrYbeCx5Ng
	H91bqad6CIsr5G/wIepwjLY2gvVZk6kBHAmffUGLjqPQ2pjc5Nev4hu9tE8Qy+48
	hbv2LTK1ynQ2zEOsX0axHxgX1pZa1N/Xj4Qb8UxZLGED75rBHyaWjEX1xB9OAGA7
	rBxLGoN+unJGGNr0uDEY29BgR6F42T6TmR84Kf4JdYpLSSu5Sur6aqYMyC5im959
	PoZ2A20WuQR+B/ef5/hGw==
X-ME-Sender: <xms:_52sapcLqTwg8Jd_tKAT7Djm7ZE8uepmLO5ckslvate04sD4z9R3aA>
    <xme:_52sapedZVRiwfe1Msov47StzGF-rOIox4Hg3AeX3o23JU3e5eQCbKdnXgeYJKwGn
    Tw0NVPHKRmFuq6fR9p3SMU8BYMFEIpY3CEQaa4PQVsEqROUXpE>
X-ME-Received: <xmr:_52sakyfUV8dtiiKG4FmSJFE8VU1vrfhTD83MbanjNCp0UQCVCoMrh-Wn4_KyPxbZbwSKsq6uEJurnYJCx8ri5VbppEYips>
X-ME-Proxy-Cause: dmFkZTGnx3DEupTZMvV/WjJHfw4nLRxku05LONXfmm60/J6jNWmNNlCzYlynz3uLX7a5EE
    n83NQ54Hm1j9xw5H1xm37OwHBgbMvMB4JXkfP6NC7YIIrhzK3t3ZB6uPr5HLhHg7a04SU6
    rMmz/JjAMg1pJZGMaBSbHdJ4d+PEROLC8wtuUfdESJuoPD6Zgx78aSqrWQUttGQ+kQkHi7
    53LiBglSiqXPXx+85L6cl0wRb8MSue2YUero/uSyenz7D73EbaQBsyhCkmDtr6bfiktIvz
    8izxbVKJUvCCbxuCGGhDsuFCHC5kD6X0Q5wqaCh2HSiV1eN3IdwwaqoeI7O/fsDKCygrea
    N8lndmuC3rUKNXJcjq3fhLBIUKPr6sjl4g8F2hmwxzEdn1KsVpApC7re6ZfSlBr9DGcZGp
    hffAazebzkWtAXxrcrBDUidPmu9QacuXSJL8pKlzHUMjgnbMMUL2DR8HOsgy3L/Ui1jqJU
    m5IJZphQ8GWugI16xvwYHmtjkzuz0rGgN6dZGI8UWjrcsgJH6lAAis+3M6Lr/sn4xIeSH/
    2RqVHioghVnX0Pi3IlOfwgyoANmf/awbJQQMnYoHeUT8O2AWeMdMYS/VWCU7oMIcU4Qrae
    Sv3Ite9cOI+s8Myr8kFBG6a1wBJnVzzka6k/6Sg8T333CmMyBj7EII1jZlzg
X-ME-Proxy: <xmx:_52sao-Jnjshx0Zm159e8WfvlgNHYPGoX6tzljDdXQFvfFaZ3eEdFg>
    <xmx:AJ6sakjgn-s6lNECFxDJeMqfx8h_Go5FCCkWe361u99vmYUF6ERr9A>
    <xmx:AJ6sanGOQHv6GUFmg4kzg-gEoPahhw6b44bo-wgt24tnPgl7eTkDyg>
    <xmx:AJ6sar-HfDyZFKteHrvqrdYEMtzs6XVZ_etymQTLylNONVFVxMY5xw>
    <xmx:AJ6sasIMPgdEQQl3BMSab88aH9_2z6DOMW6rJXHOgmpcq30OJYlajMO3>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 17 Sep 2026 22:12:13 -0400 (EDT)
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
Subject: Re: [PATCH 7/7] nfsd: use vfs_lookup_open() for non-creating open
 requests too.
In-reply-to: <f64c2391-2810-406c-8c31-7f80cdde0832@slotpi15m67>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-8-neilb@ownmail.net>
  <f64c2391-2810-406c-8c31-7f80cdde0832@slotpi15m67>
Date: Fri, 18 Sep 2026 12:12:09 +1000
Message-id: <178969752969.207413.9046602571107252577@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 11 Sep 2026, Chuck Lever wrote:
> On Thu, 10 Sep 2026, NeilBrown wrote:
>=20
> > nfsd: use vfs_lookup_open() for non-creating open requests too.
> >
> > Now that we have vfs_lookup_open() for open requests which create, we
> > can use it for non-creating requests too as vfs_lookup_open() is already
> > able to do that.  nfsd4_create_file() is renamed to nfsd4_open_file()
> > and enhanced to not always create, and is then used for all OPEN
> > requests.
> >
> > The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
> > moved into nfsd4_open_file() so it is closer to fh_full_post_attrs and
> > fh_fill_post_noop calls.
>=20
> fh_full_post_attrs is fh_fill_post_attrs().
>=20

Fixed.

>=20
> > As ->op_create_mode isn't defined when op_create is zero, we need a
> > local create_mode which is -1 (illegal value) when op_create is zero.
>=20
> The field is ->op_createmode and the local is createmode.
>=20

Fixed.

>=20
> > The non-create path now doesn't use nfsd_lookup().  As mount-point
> > crossing including nfsd_check_access() is already included for existing
> > names, this does not lose us anything.
>=20
> The function is check_nfsd_access(), reached through nfsd_cross_mnt().
>=20
> Is "already included for existing names" accurate? The only mount-point
> crossing left in nfsd4_open_file() is the try_lookup_noperm() block,
> and that consults only the dcache. More on that below.

It is now!

>=20
>=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/nfsd/nfs4proc.c | 109 ++++++++++++++++++++++++++---------------------=
------
> >  1 file changed, 53 insertions(+), 56 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index a6ba7618a307..1f3096486565 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -251,29 +251,30 @@ static inline bool nfsd4_create_is_exclusive(int cr=
eatemode)
> >  }
> >
> >  /*
> > - * Implement NFSv4's unchecked, guarded, and exclusive create
> > - * semantics for regular files. Open state for this new file is
> > - * subsequently fabricated in nfsd4_process_open2().
> > - *
> > + * Implement NFSv4's open semantics for regular files.
> > + * Both create (unchecked, guarded, and exclusive) and non-create.
> > + * Open state for this new file is subsequently fabricated in
> > + * nfsd4_process_open2().
> >   * Upon return, caller must release @fhp and @resfhp.
> >   */
>=20
> "Both create ... and non-create." is a fragment, and "this new file" no
> longer fits when the file may already exist. Perhaps:

Thanks.

>=20
>  * Implement NFSv4 OPEN semantics for regular files, both non-creating
>  * and creating (unchecked, guarded, and exclusive). Open state for the
>  * file is subsequently fabricated in nfsd4_process_open2().
>  *
>  * Upon return, caller must release @fhp and @resfhp.
>=20
>=20
> > @@ -285,6 +286,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
> >  	if (status !=3D nfs_ok)
> >  		return status;
> >
> > +	status =3D fh_fill_pre_attrs_unlocked(fhp);
> > +	if (status)
> > +		return status;
> > +
> >  	if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> >  		/*
> >  		 * If name is already in dcache we need to check for mountpoints
>=20
> First, the test reads open->op_createmode, which the commit message says
> is undefined when op_create is zero. It works because
> nfsd4_decode_open() zeroes the whole struct, so a non-creating OPEN
> sees NFS4_CREATE_UNCHECKED here. Could the op_create test that sets
> createmode be hoisted above this block, and the condition become

oops. Fixed.

>=20
> 	if (!open->op_create || createmode =3D=3D NFS4_CREATE_UNCHECKED) {
>=20
> so the non-create path does not depend on that zero?
>=20
> Second, nfsd_lookup_dentry() did a real lookup and then called
> nfsd_cross_mnt() whenever nfsd_mountpoint() was true. try_lookup_noperm()
> returns NULL when the name is not cached. In that case vfs_lookup_open()
> opens whatever it finds on the parent's mount and fh_compose() uses the
> parent's export.
>=20
> For a referral junction (a regular file carrying the junction xattr),
> nfsd_cross_mnt() would have swapped in the referral export. On a cold
> dcache the client instead gets an ordinary filehandle for the junction
> file, and a second OPEN of the same name, now cached, takes the
> crossing path. The same applies to a bind-mounted file whose mount
> target has its own export.
>=20
> The Linux client sends OPEN by name without a preceding LOOKUP, so the
> first access after a server reboot reaches this. Could the block do a
> real lookup of the name, as nfsd_lookup_dentry() does, before deciding
> whether to cross?

I don't think we want a real lookup.  I think we want to stick with the
the vfs_open_lookup() call, but if it says it didn't create the file,
then we need to check for a mountpoint.  I think this might be a
long-standing buglet.  I've addressed for my next posting.

>=20
>=20
> > @@ -373,11 +382,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >  		iap->ia_atime.tv_nsec =3D 0;
> >  	}
> >
> > -	create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> > -	if (create_status)
> > -		/* Might still succeed if no create is needed */
> > -		oflags &=3D ~O_CREAT;
> > -
> > +	if (oflags & O_CREAT) {
>=20
> Nit: O_CREAT is set only from open->op_create a few lines up. Would
> testing open->op_create here read more directly?

As the guarded code clears O_CREAT if there is an error, I think it
works well to test for O_CREAT.  So I'd prefer to leave this one as-is.

>=20
>=20
> > +		create_status =3D fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> > +		if (create_status)
> > +			oflags &=3D ~O_CREAT;
> > +	}
> >  	dget(parent.dentry);
> >  	open->op_filp =3D vfs_lookup_open(&parent,
> >  					&QSTR_LEN(open->op_fname,
>=20
> This changes when a delegation is recalled relative to the access
> check. oflags carries O_WRONLY or O_RDWR from op_share_access, and
> vfs_lookup_open() opens the child with those flags. do_dentry_open()
> does no permission check of its own and calls break_lease() on the
> inode, so a conflicting delegation held by another client is recalled
> here. Only afterwards does do_open_lookup() call do_open_permission()
> and return NFS4ERR_ACCESS.
>=20
> Before this patch a non-creating OPEN went through nfsd_lookup() and
> do_open_permission() first, and the open that breaks the lease
> happened later in nfsd_file_do_acquire(), where fh_verify() precedes
> nfsd_open_break_lease(). So a client that can search the directory
> but has no write permission on the file can now recall other clients'
> write delegations on it by sending OPEN with SHARE_ACCESS_WRITE.
>=20
> The create path has had this ordering since nfsd4_create_file() started
> opening the file itself, but it was limited to opens that pass
> NFSD_MAY_CREATE on the directory. Extending it to every OPEN makes it
> reachable from any client with lookup access.
>=20
> Could the access check move ahead of the open for the non-creating
> case, or could the open be done O_RDONLY for the type check and the
> share-access open deferred to the filecache as before?

Yes.  vfs_lookup_open() really should be doing an access check before
calling vfs_open() - calling do_open() there has the desired effect.
I've added a patch.

>=20
>=20
> > @@ -387,7 +396,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
> >  	if (IS_ERR(open->op_filp)) {
> >  		status =3D nfserrno(PTR_ERR(open->op_filp));
> >  		if (status =3D=3D nfserr_wrong_type) {
> > -			if (nfsd4_create_is_exclusive(open->op_createmode))
> > +			if (nfsd4_create_is_exclusive(createmode))
> >  				status =3D nfserr_exist;
> >  			else
> >  				status =3D nfsd_check_obj_isreg(parent.dentry);
>=20
> On a re-export this arm changes the status a non-creating OPEN of a
> directory returns. nfsd_check_obj_isreg(NULL) returns
> nfserr_wrong_type, where nfsd_lookup() used to return nfserr_isdir.

I've changed this code a lot - there is no longer a chance of this
problem occurring.

>=20
> The Linux client has no mapping for NFS4ERR_WRONG_TYPE, so
> nfs4_map_errors() turns it into EIO. A "cat" of a re-exported directory
> that is not yet in the server's dcache now fails with EIO instead of
> EISDIR. NFSv4.0 clients are covered by the nfserr_symlink conversion in
> do_open_lookup() and recover through a LOOKUP; v4.1 and later see the
> change. Ceph splices before returning -EFTYPE, so it is not affected,
> but nfs, gfs2 and smb all return -EFTYPE before instantiating anything.

I've decide to fix the various atomic_open implementations so they
consistently do what I want them too :-) I've even added
NFS4ERR_WRONG_TYPE handling for nfs.

Thanks for the awesome review!

NeilBrown


>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20

