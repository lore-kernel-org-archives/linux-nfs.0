From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 12:13:43 -0700
Message-ID: <1118862823.22484.13.camel@seki.nac.uci.edu>
References: <EXCHG2003xdWGHpPnqN000005d1@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ov+8722qxqvpSNez1bd/"
Cc: "'M. Todd Smith'" <todd@sohovfx.com>, nfs@lists.sourceforge.net,
	strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DidKg-0005Ox-B0
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 12:13:50 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DidKe-0001fR-P8
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 12:13:50 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003xdWGHpPnqN000005d1@EXCHG2003.microtech-ks.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-ov+8722qxqvpSNez1bd/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


A bigger dd test should work - if you use about 3x your physical memory,
you'll probably be fine doing it that way.

Another way that may work better in -some- cases, is to umount the
filesystem and re-mount it - except for warm restartable filesystems.

On Wed, 2005-06-15 at 10:28 -0500, Roger Heflin wrote:
> Make the dd test bigger, with 2x the memory size, 50% will
> be from cache and almost instanteous, with 4x the memory size,
> 25% will be from cache, bigger runs will get closer to actual
> reality, on the tests I do I run things 8x, but if you run
> 2x, 4x, 8x memory you should get a decent graph to give you
> an idea of what the actual value is.
>=20
>                Roger
> 		   Atipa Technologies.=20
>=20
> > -----Original Message-----
> > From: nfs-admin@lists.sourceforge.net=20
> > [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of M. Todd Smith
> > Sent: Wednesday, June 15, 2005 9:47 AM
> > To: nfs@lists.sourceforge.net
> > Subject: Re: [NFS] NFS tuning - high performance throughput.
> >=20
> > Roger Heflin wrote:
> >=20
> > >Are you using the same dd test on the local machine test? =20
> > If so cache=20
> > >will be a major factor.
> > >
> > >Also, raid5 stripe size, bigger is almost always better, I would do=20
> > >some testing with different strip sizes and see how it affects the=20
> > >speed, I have never seen less than 32k be faster than 32k.
> > >
> > >Are you using md for the raid5 setup or something else that has not=20
> > >been mentioned?
> > >
> > >                     Roger
> > > =20
> > >
> > Roger,
> >=20
> > I was told by a consultant we hired to help us with this that=20
> > 5Gb test files should be large enough to blow out the caches.=20
> >  Looking back I realize that must have been when we only had=20
> > 2Gb RAM in the machine ..=20
> > is there a better test I can use to check local rw=20
> > performance, as well is there a formula or recommended way to=20
> > calculate how big a file you should rw to properly check local rw?
> >=20
> > I'll have to ask our soft eng who worked with the consultant=20
> > as to why that particular stripe size was used.  I believe we=20
> > are using md, we attempted to use LVM but ran into some=20
> > problems and had some file inconsistencies that were=20
> > unacceptable so had to back out of it.
> >=20
> > Cheers
> > Todd
> >=20
> > --
> > Systems Administrator
> > ----------------------------------
> > Soho VFX - Visual Effects Studio
> > 99 Atlantic Avenue, Suite 303
> > Toronto, Ontario, M6K 3J8
> > (416) 516-7863
> > http://www.sohovfx.com
> > ----------------------------------
> >=20
> >=20
> > =20
> >=20
> >=20
> >=20
> > -------------------------------------------------------
> > SF.Net email is sponsored by: Discover Easy Linux Migration=20
> > Strategies from IBM. Find simple to follow Roadmaps,=20
> > straightforward articles, informative Webcasts and more! Get=20
> > everything you need to get up to speed, fast.=20
> > http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclick
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net=20
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20
>=20
>=20
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> from IBM. Find simple to follow Roadmaps, straightforward articles,
> informative Webcasts and more! Get everything you need to get up to
> speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-ov+8722qxqvpSNez1bd/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCsH3no0feVm00f/8RAkgGAJ4sm8SHh04J5vcjpIcxDvXxQn6D5wCfZVE8
gZGqRjZfMZ+KN1xe8uKQy4E=
=I54M
-----END PGP SIGNATURE-----

--=-ov+8722qxqvpSNez1bd/--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
