Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4.gandi.net ([217.70.183.210]:50040 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934453Ab3IDJTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 05:19:49 -0400
Date: Wed, 4 Sep 2013 11:19:42 +0200
From: William Dauchy <william@gandi.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: William Dauchy <william@gandi.net>, William Dauchy <wdauchy@gmail.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: Re: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to
 complete
Message-ID: <20130904091942.GG22430@gandi.net>
References: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
 <1378234234.6410.36.camel@leira.trondhjem.org>
 <20130903204431.GF22430@gandi.net>
 <1378241254.6410.52.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ahP6B03r4gLOj5uD"
In-Reply-To: <1378241254.6410.52.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ahP6B03r4gLOj5uD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep03 20:47, Myklebust, Trond wrote:
> On Tue, 2013-09-03 at 22:44 +0200, William Dauchy wrote:
> > On Sep03 18:50, Myklebust, Trond wrote:
> > > Thanks again for testing! Does the following fixup on top of the 'v2'
> > > patch also help?
> > > --- a/fs/nfs/unlink.c
> > > +++ b/fs/nfs/unlink.c
> > > @@ -211,7 +211,7 @@ void nfs_wait_on_sillyrename(struct dentry *dentr=
y)
> > >  {
> > >  	struct nfs_inode *nfsi =3D NFS_I(dentry->d_inode);
> > > =20
> > > -	wait_event(nfsi->waitqueue, atomic_read(&nfsi->silly_count) =3D=3D =
1);
> > > +	wait_event(nfsi->waitqueue, atomic_read(&nfsi->silly_count) <=3D 1);
> > >  }
> > > =20
> > >  void nfs_block_sillyrename(struct dentry *dentry)
> >=20
> > hmmm I just realized your v2 version had `=3D=3D 1`; in fact I tested y=
our v1
> > with `=3D=3D 0`. Let me some time to retest the v2.

After some more testing the v2 was ok with `=3D=3D 1`; I tested the v1 too
fast without seeing a v2 has been resent. I guess you can revert `<=3D 1`

Tested-by: William Dauchy <william@gandi.net>

Sorry for the noise,
--=20
William

--ahP6B03r4gLOj5uD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlIm+y4ACgkQ1I6eqOUidQGL0gCgiQV5oxDhPklP51u8V+2DLWkP
q3AAn22loaZxVjuI9Mfh5UK0bkbluizQ
=IPuc
-----END PGP SIGNATURE-----

--ahP6B03r4gLOj5uD--
