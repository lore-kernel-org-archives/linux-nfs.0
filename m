Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47720 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121Ab3IDX37 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 19:29:59 -0400
Date: Thu, 5 Sep 2013 09:29:47 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] make nfs_flush_incompatible more forgiving.
Message-ID: <20130905092947.248a80e6@notabene.brown>
In-Reply-To: <1378305214.3527.10.camel@leira.trondhjem.org>
References: <20130904113632.1a1eb337@notabene.brown>
	<1378305214.3527.10.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/wTXS9eYbqrcXrder+V7yITP"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/wTXS9eYbqrcXrder+V7yITP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Sep 2013 14:33:35 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-09-04 at 11:36 +1000, NeilBrown wrote:
> > Hi,
> >  we have a customer who has noticed a significant regression in NFS
> >  performance between SLES10 (2.6.16+) and SLES11 (3.0+).
> >=20
> >  The use case involves two different processes on the same client mmapp=
ing a
> >  file and making changes.
> >=20
> >  In 2.6.16, all these changes would be cached on the client until a flu=
sh or
> >  close or other normal process flushed the changes out - much the same =
as if
> >  just one process was accessing the file.
> >=20
> >  In 3.0 the file is flushed out every time a different process performs=
 an
> >  update. So if they interleave accesses, you get a flush-to-the-server =
on
> >  every access.
> >=20
> >  This is caused by nfs_flush_incompatible.  It deems access through dif=
ferent
> >  file descriptors to be incompatible.  However I don't think this is
> >  justified.  Accessed using different credentials can reasonably be see=
n as
> >  incompatible(*), but if two processes with identical credentials open =
the
> >  same file there there should be not need to differentiate between them.
> >=20
> >  The patch below changes the test in nfs_flush_incompatible to just tes=
t the
> >  credentials (and the dentry, though that might be superfluous - it see=
ms
> >  safer).
> >=20
> > (*) In this specific customer's case the process do currently have slig=
htly
> >  different credentials.  In one, the primary gid is included in the lis=
t of
> >  auxiliary gids.  In the other the primary gid is excluded.  This is en=
ough
> >  to make the credentials appear different so this patch doesn't help in=
 that
> >  case.  They are looking at being more consistent in their setgroups us=
age
> >  but it would help them if we only actually compared the credentials th=
at
> >  were important.  In this case there is no important difference.
> >  Would it make sense to treat a more broad credential as compatible wit=
h a
> >  more narrow credential?  So a write from a process with a given
> >  uid,gid,grouplist could ultimately be sent to the server with same uid=
/gid,
> >  but a subset of the group list?
> > =20
> >=20
> >  Thoughts?
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 7816801..b0d4e47 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -860,7 +860,12 @@ int nfs_flush_incompatible(struct file *file, stru=
ct page *page)
> >  		if (req =3D=3D NULL)
> >  			return 0;
> >  		l_ctx =3D req->wb_lock_context;
> > -		do_flush =3D req->wb_page !=3D page || req->wb_context !=3D ctx;
> > +		do_flush =3D req->wb_page !=3D page;
> > +		if (req->wb_context !=3D ctx) {
> > +			do_flush |=3D
> > +				req->wb_context->dentry !=3D ctx->dentry ||
> > +				req->wb_context->cred !=3D ctx->cred;
> > +		}
> >  		if (l_ctx) {
> >  			do_flush |=3D l_ctx->lockowner.l_owner !=3D current->files
> >  				|| l_ctx->lockowner.l_pid !=3D current->tgid;
>=20
> Hi Neil,
>=20
> Won't this cause any write errors to be propagated to the wrong process?

I'm not sure what this means.

For a local filesystem, the only error that isn't synchronous is EIO and an
application can only be sure of getting that if it uses 'fsync'.  An
application can get EIO from fsync even if it didn't write to the page which
is causing the problem.  All apps should be able to see the EIO if they
bother to fsync.

For NFS, EDQUOT and ENOSPC are also asynchronous, and they can also come in
through close().  I think every app should still see every error whether  it
dirtied the page which triggered the error or not.

??

Thanks,
NeilBrown

--Sig_/wTXS9eYbqrcXrder+V7yITP
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUifCaznsnt1WYoG5AQLUjg//aMDC2pr3m1t2a/vtSkhALUKlgquqeztl
Z7e3g44CfEiOhJXBsnyMZjDSUzbd4i9fVqO8yzbc7tEC2JqkAcwYHinsY8Ui8CgM
lUjTSAH3v9HZakSsxgIaC0BvlLsE9GWq8XxC0k0ZlKddIlD4eAdqLc7ZuHX3EII3
fRd6c5GbmoORGnK9Sg9NCbMOVUECxbEPjwRJa5o9fIqD3p0lc8+v8Zq6wtV9QbnL
ZdZ4AHAbxeKggUS9gY6RrpPnqelmlnLKVeL7lpFwku7XqUTKcqUxO+oNsU1U2zAy
8uA31wEuF7iT186Zh8B6Ti8ZO3ZR79IFH5TKmoJR+lnxYdtxn/2LF7y5eQqIMuFD
E3Kn8gL4CBO9Mh32FrLkthhvLE5PAlRyl2I9nayzzSN7p+lJ04AkVuRRYu0tgUJF
C/r1KwfsFu76kji3vzPQS+z+MUK/eMq8ZxjJTM1/B4zAkMCaKq06iEzsojsW45nH
uIk5M/Tp/3qKhqbe2Q+ivCg9isSpVSyyTME5GOpm+G1KMeYiM6tzBj8BpJg7R62X
xQeINz+Idk1J+cRby59obwwoNmKuxm46IhVgv3kzrOTP/FG1s2FOa0wLnam+x3Mx
RUpax/53PQBVBW9NTIEIPAGo2tdyYCrqBAgZnxi+mjVu/PkDXafkI4C8hwvGYQf5
J++9/VHj8sk=
=MbUu
-----END PGP SIGNATURE-----

--Sig_/wTXS9eYbqrcXrder+V7yITP--
