Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:46787 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbaGNXrk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 19:47:40 -0400
Received: by mail-qc0-f179.google.com with SMTP id r5so3549777qcx.10
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 16:47:40 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 14 Jul 2014 19:47:38 -0400
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140714194738.5aafaf25@tlielax.poochiereds.net>
In-Reply-To: <20140715085727.6fa12272@notabene.brown>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
	<20140714223513.47807c98@notabene.brown>
	<20140714090028.6f04fd2c@tlielax.poochiereds.net>
	<20140715085727.6fa12272@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/sKBE9bq8WCDMS1WLANaz_uV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/sKBE9bq8WCDMS1WLANaz_uV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Jul 2014 08:57:27 +1000
NeilBrown <neilb@suse.de> wrote:

> On Mon, 14 Jul 2014 09:00:28 -0400 Jeff Layton <jeff.layton@primarydata.c=
om>
> wrote:
>=20
> > On Mon, 14 Jul 2014 22:35:13 +1000
> > NeilBrown <neilb@suse.de> wrote:
> >=20
> > > On Mon, 14 Jul 2014 08:14:55 -0400 Jeff Layton <jeff.layton@primaryda=
ta.com>
> > > wrote:
> > >=20
> > > > On Mon, 14 Jul 2014 15:14:05 +1000
> > > > NeilBrown <neilb@suse.de> wrote:
> > > >=20
> > > > >=20
> > > > > If an 'open' of a file in an NFSv4 filesystem finds that the dent=
ry is
> > > > > in cache, but the inode is stale (on the server), the dentry will=
 not
> > > > > be re-validated immediately and may cause ESTALE to be returned to
> > > > > user-space.
> > > > >=20
> > > > > For a non-create 'open', do_last() calls lookup_fast() and on suc=
cess
> > > > > will eventually call may_open() which calls into nfs_permission().
> > > > > If nfs_permission() makes the ACCESS call to the server it will g=
et
> > > > > NFS4ERR_STALE, resulting in ESTALE from may_open() and thence from
> > > > > do_last().
> > > > > The retry-on-ESTALE in filename_lookup() will repeat exactly the =
same
> > > > > process because nothing in this path will invalidate the dentry d=
ue to
> > > > > the inode being stale, so the ESTALE will be returned.
> > > > >=20
> > > > > lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFSv4
> > > > > filesystem, that will succeed for regular files:
> > > > > 	/* Let f_op->open() actually open (and revalidate) the file */
> > > > >=20
> > > > > Unfortunately in the case of a STALE inode, f_op->open() never ge=
ts
> > > > > called.  If we teach nfs4_lookup_revalidate() to report a failure=
 on
> > > > > NFS_STALE() inodes, then the dentry will be invalidated and a full
> > > > > lookup will be attempted.  The ESTALE errors go away.
> > > > >=20
> > > > >=20
> > > > > While I think this fix is correct, I'm not convinced that it is
> > > > > sufficient, particularly if lookupcache=3Dnone.
> > > > > The current code will fail an "open" is nfs_permission() fails,
> > > > > without having performed a LOOKUP. i.e. it will use the cache.
> > > > > nfs_lookup_revalidate will force a lookup before the permission c=
heck
> > > > > if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will n=
ot.
> > > > >=20
> > > >=20
> > > > This patch should make the code fall through to nfs_lookup_revalida=
te,
> > > > which would then force the lookup, right?
> > >=20
> > > Yes ... though maybe that's not what I really want to do.  I really w=
anted to
> > > just return '0', though I would need to check that is right in all ca=
ses.
> > >=20
> > > >=20
> > > > Also, I'm a little unclear...
> > > >=20
> > > > Why would may_open fail with ESTALE after the v4 OPEN succeeds? The
> > > > OPEN should be returning a filehandle and attributes for the inode
> > > > actually opened. It seems like we ought to be doing any permission
> > > > checks vs. that inode, not anything we had in cache. Presumably the
> > > > server is then holding it open so it shouldn't be stale.
> > >=20
> > > may_open is called *before* and v4 OPEN.
> > >=20
> > > In do_last, if the inode is already in cache, then
> > >   lookup_fast is called, which calls d_revalidate
> > >   then may_open (calls ->permission)
> > >   then finish_open which calls f_op->open
> > >=20
> > > Yes, we should be doing permission checking against whatever 'open' f=
inds.
> > > But the VFS is structured to the the permission check after d_revalid=
ate and
> > > before ->open.  So maybe d_revalidate needs to do the NFS open??
> > >=20
> >=20
> > Ok, I see. Ugh, having the revalidate do the open sounds...messy.
>=20
> Having the VFS call into the file system in dribs and drabs, rather than =
just
> asking the filesystem to "open" and  letting it call back to VFS libraries
> for name lookup etc it what is really messy (IMO).
>=20
> So yes - definite mess.  Not entirely sure where the mess is.
>=20

Yeah, that might have been cleaner overall. I'm not sure how we can get
there from where the code is today though...

> >=20
> > A simpler fix might be to fix it so that an -ESTALE return from
> > may_open triggers a retry. Something like this maybe (probably
> > whitespace damaged, so just for discussion purposes):
>=20
> Nice idea but doesn't work.
> We get back to retry_lookup and call lookup_open().
> lookup_dcache calls d_revalidate which reports that everything is fine, s=
o it
> tells lookup_open which jumps to out_no_open and does nothing useful.
> So we end up in may_open() again which returns ESTALE again but now we've
> used up all our extra lives...
>=20

Ahh right, so you'd probably need to pair that with the patch you
already have. Regardless, it seems like getting back an ESTALE from
may_open should trigger a retry rather than just erroring out.

>=20
> One thing I noticed while exploring this is that do_last calls "may_open"
> *before* finish_open() while atomic_open() calls "may_open" *after*
> finish_open() (which it calls by virtual of the fact that all ->atomic_op=
en
> methods call finish_open()).
>=20
> I was very tempted to just move the 'may_open' call in 'do_last' to after=
 the
> 'finish_open' call.  That fixed the problem, but I'm not sure it is "righ=
t".
>=20
> I think the real core messiness here is that permission checking should be
> neither before nor after finish_open, but should be an integral part of
> finish_open with the filesystem doing the permission check in f_op->open(=
).
>=20
> I'm currently thinking this is the best patch for now:
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 4f7414afca27..5c40cfd3ae29 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1563,9 +1563,10 @@ static int nfs4_lookup_revalidate(struct dentry *d=
entry, unsigned int flags)
>  	/* We cannot do exclusive creation on a positive dentry */
>  	if (flags & LOOKUP_EXCL)
>  		goto no_open_dput;
> =20
> -	/* Let f_op->open() actually open (and revalidate) the file */
> -	ret =3D 1;
> +	if (!NFS_STALE(inode))
> +		/* Let f_op->open() actually open (and revalidate) the file */
> +		ret =3D 1;
> =20
>  out:
>  	dput(parent);
>=20
>=20
> Thanks,
> NeilBrown
>=20

That looks fine too, but I think you probably will also want to pair it
with making may_open retry the open on an ESTALE return.

The problem with the above check alone is that it's only going to fire
if you previously found the inode to be stale. It may be stale on the
server, but the client doesn't realize it yet, or could go stale after
this check and before the ACCESS call. In that case, you'll still end
up getting back an ESTALE once you hit may_open (unless I'm missing
something) and that won't trigger a reattempt either.

>=20
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 985c6f368485..c1657deea52c 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -3045,8 +3045,13 @@ finish_open:
> >         }
> >  finish_open_created:
> >         error =3D may_open(&nd->path, acc_mode, open_flag);
> > -       if (error)
> > +       if (error) {
> > +               if (error =3D=3D -ESTALE)
> > +                       goto stale_open;
> >                 goto out;
> > +       }
> >         file->f_path.mnt =3D nd->path.mnt;
> >         error =3D finish_open(file, nd->path.dentry, NULL, opened);
> >         if (error) {
> >=20
> >=20
> > ...though might need to convert the ESTALE to EOPENSTALE there too, not
> > sure...
> >=20
> > >=20
> > > >=20
> > > > Are we not properly updating the dcache (and attrcache) after the
> > > > OPEN reply?
> > >=20
> > > I think so, yes.  But in the problem case, we don't even send an OPEN
> > > request.
> > >=20
> > >=20
> > > >=20
> > > > >=20
> > > > > Signed-off-by: NeilBrown <neilb@suse.de>
> > > > >=20
> > > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > > > index 4a3d4ef76127..4f7414afca27 100644
> > > > > --- a/fs/nfs/dir.c
> > > > > +++ b/fs/nfs/dir.c
> > > > > @@ -1563,6 +1563,8 @@ static int nfs4_lookup_revalidate(struct
> > > > > dentry *dentry, unsigned int flags) /* We cannot do exclusive
> > > > > creation on a positive dentry */ if (flags & LOOKUP_EXCL)
> > > > >  		goto no_open_dput;
> > > > > +	if (NFS_STALE(inode))
> > > > > +		goto no_open_dput;
> > > > > =20
> > > > >  	/* Let f_op->open() actually open (and revalidate) the
> > > > > file */ ret =3D 1;
> > > >=20
> > > > Looks legit to me too, but it seems like the inode could go stale
> > > > w/o us knowing after this point.
> > > >=20
> > > > Acked-by: Jeff Layton <jlayton@primarydata.com>
> > >=20
> > > Thanks,
> > > NeilBrown
> >=20
> >=20
>=20


--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/sKBE9bq8WCDMS1WLANaz_uV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTxGwaAAoJEAAOaEEZVoIV1JcQAKYiTAkEkWUXlegL5QZQzPKm
RBl3xspsntl53PPofu1nsDuFLOEClnT46OPz2akFE29KfZYE+JoVMAtExMTIzWQh
VLMmqmIW9GXGW7wr7oQ4qHcdqc8pfudc9ZV/V6e23k1DOWSkCdBTBhl8VwRiLhcj
nIjt3LDLEqkcH1wpkgBVVkyJQIoOkAlNDxMiwsLjWtVJ4HpL1tkzD8QE1HLSCId6
NYbgb7Lddlgyj96ObBdLNrbNaA2GAd+aWDEdQ6HQ76u8huBXZi0/4gP2dUy14V/1
GST1XRdktjyst+a/1uBKX4WHxEK5s51cTrbmmVk+ipQenJTH+52R8iKwpJ9js+xw
fF2ZdZlJ0zl2NwOK02P4lF9K0fKdr8tMrLEF4uYEsvys9bB2FDfILnBeakThlrD0
tcI48Oo67b0uMwOf9FNbvPxuVzZIymJx08dqRJs2iXC7vVev7nAmRTYkqnvgWaqt
DWJcDXjD8QCmpj+P6gvIzmjDdvXTdg62IHN3VoJG6c06jD349czAk/gexcdepj8l
khFBW4vPdN/GDqWcDZiNJkVcoWCi4VGlYEXfFIAYurMx664QYSBbu1fkf2Zfi8P3
OXMH55kq1xZTB87vsSh/t2qwR9LIOxvsWSa5kzipZAikSTd1jE4FcSWYS2K1Gk8R
KdxmGn6F+u6S6UtKbzHi
=Vb1u
-----END PGP SIGNATURE-----

--Sig_/sKBE9bq8WCDMS1WLANaz_uV--
