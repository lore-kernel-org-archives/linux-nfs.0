Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60712 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113AbaGNMf0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2014 08:35:26 -0400
Date: Mon, 14 Jul 2014 22:35:13 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140714223513.47807c98@notabene.brown>
In-Reply-To: <20140714081455.69f55224@tlielax.poochiereds.net>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/dZWtfWH1iTJwqtK2b5s7vxi"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/dZWtfWH1iTJwqtK2b5s7vxi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 Jul 2014 08:14:55 -0400 Jeff Layton <jeff.layton@primarydata.com>
wrote:

> On Mon, 14 Jul 2014 15:14:05 +1000
> NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > If an 'open' of a file in an NFSv4 filesystem finds that the dentry is
> > in cache, but the inode is stale (on the server), the dentry will not
> > be re-validated immediately and may cause ESTALE to be returned to
> > user-space.
> >=20
> > For a non-create 'open', do_last() calls lookup_fast() and on success
> > will eventually call may_open() which calls into nfs_permission().
> > If nfs_permission() makes the ACCESS call to the server it will get
> > NFS4ERR_STALE, resulting in ESTALE from may_open() and thence from
> > do_last().
> > The retry-on-ESTALE in filename_lookup() will repeat exactly the same
> > process because nothing in this path will invalidate the dentry due to
> > the inode being stale, so the ESTALE will be returned.
> >=20
> > lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFSv4
> > filesystem, that will succeed for regular files:
> > 	/* Let f_op->open() actually open (and revalidate) the file */
> >=20
> > Unfortunately in the case of a STALE inode, f_op->open() never gets
> > called.  If we teach nfs4_lookup_revalidate() to report a failure on
> > NFS_STALE() inodes, then the dentry will be invalidated and a full
> > lookup will be attempted.  The ESTALE errors go away.
> >=20
> >=20
> > While I think this fix is correct, I'm not convinced that it is
> > sufficient, particularly if lookupcache=3Dnone.
> > The current code will fail an "open" is nfs_permission() fails,
> > without having performed a LOOKUP. i.e. it will use the cache.
> > nfs_lookup_revalidate will force a lookup before the permission check
> > if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will not.
> >=20
>=20
> This patch should make the code fall through to nfs_lookup_revalidate,
> which would then force the lookup, right?

Yes ... though maybe that's not what I really want to do.  I really wanted =
to
just return '0', though I would need to check that is right in all cases.

>=20
> Also, I'm a little unclear...
>=20
> Why would may_open fail with ESTALE after the v4 OPEN succeeds? The
> OPEN should be returning a filehandle and attributes for the inode
> actually opened. It seems like we ought to be doing any permission
> checks vs. that inode, not anything we had in cache. Presumably the
> server is then holding it open so it shouldn't be stale.

may_open is called *before* and v4 OPEN.

In do_last, if the inode is already in cache, then
  lookup_fast is called, which calls d_revalidate
  then may_open (calls ->permission)
  then finish_open which calls f_op->open

Yes, we should be doing permission checking against whatever 'open' finds.
But the VFS is structured to the the permission check after d_revalidate and
before ->open.  So maybe d_revalidate needs to do the NFS open??


>=20
> Are we not properly updating the dcache (and attrcache) after the OPEN
> reply?

I think so, yes.  But in the problem case, we don't even send an OPEN reque=
st.


>=20
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >=20
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 4a3d4ef76127..4f7414afca27 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1563,6 +1563,8 @@ static int nfs4_lookup_revalidate(struct dentry
> > *dentry, unsigned int flags) /* We cannot do exclusive creation on a
> > positive dentry */ if (flags & LOOKUP_EXCL)
> >  		goto no_open_dput;
> > +	if (NFS_STALE(inode))
> > +		goto no_open_dput;
> > =20
> >  	/* Let f_op->open() actually open (and revalidate) the file
> > */ ret =3D 1;
>=20
> Looks legit to me too, but it seems like the inode could go stale w/o
> us knowing after this point.
>=20
> Acked-by: Jeff Layton <jlayton@primarydata.com>

Thanks,
NeilBrown

--Sig_/dZWtfWH1iTJwqtK2b5s7vxi
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8POgTnsnt1WYoG5AQKnpQ//T8BKPiKeYctHLdydKTZb3HKVLEQsQugp
NWjKUK3xiT2JqYBv5uaBVw5/WGLQ65rgkDhCJgQHUNLegzYoTMI43zqNou4lpjom
fRibdN7eYmHHd5rud09is0KL5bPHf7eXrj6JonXAs4EDS2m+MvtUGpRlBCKvsHkg
/10h+7zWGyE1+33ER8KXnDIyWEoIANpcS8dDWLESNhZSLH3svFYDXyRaEpt5RXEM
LW8SQOnD8kE0iIPCK2eL8/K1ybnU2eOcmE/9z0oR1pIZmVRdgEKlu74F+a67rn17
x45O78LNtb8/Xk8d5r8y7wpy6jEs/tebXBD9npnziLf/UH/xjIEO6JRugjOPYw3q
0kFQ8bjDfCeB5gmKoEdBonMaptJg/Qj7NJvxT/MWhY7vydvm7m6qFsoRt966utss
ER9FTXX9qhRXCX5i7GO2ZIoK2oF5/zYNQLl3GOQSOFQter97OB2lu+H+mtyywdeG
2Ia+tzm70UKKHRBjwO8+3ER2zFQd0C0MWDlmorHouj16rv0L2pLYMZXv8A8gIAXp
QyWPFmcnTWo/LUvRmU7nOExnn+NCG+Z+SmBqxExpprvsVPAhdmx37LmXMBQs3m3R
LO4Ix3hFi4uVed/oDUvTxdI5bDamFKZS0pi9JdhY0GLUxA5186mOGVvYpFC6NgLf
A+Akid2RVfg=
=d096
-----END PGP SIGNATURE-----

--Sig_/dZWtfWH1iTJwqtK2b5s7vxi--
