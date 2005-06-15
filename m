From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 18:56:36 -0700
Message-ID: <1118800597.22484.3.camel@seki.nac.uci.edu>
References: <482A3FA0050D21419C269D13989C611308539C89@lavender-fe.eng.netapp.com>
	 <42AF4041.8030504@sohovfx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BQoiYM+jhpLp8RmnPL/H"
Cc: nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiN93-0007CN-HX
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 18:56:45 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DiN92-0004xx-0I
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 18:56:45 -0700
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <42AF4041.8030504@sohovfx.com>
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


--=-BQoiYM+jhpLp8RmnPL/H
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Sorry, I'm coming to the discussion late, but perhaps one of these URL's
will help?

http://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html

http://dcs.nac.uci.edu/~strombrg/network-performance.html

On Tue, 2005-06-14 at 16:38 -0400, M. Todd Smith wrote:
> Charles,
>=20
> I've tried mounting both TCP and UDP and with rwsizes varying from 8k to=20
> 32k, 32k rwsizes are giving us the best performance thus far.
>=20
> Indeed I did skip a level with the ping times didn't I, 200 microseconds=20
> it is.
>=20
> Cheers
> Todd
>=20
>=20
> Lever, Charles wrote:
>=20
> >first place i would look is mount options on the client.  are you
> >mounting with NFS over TCP, or NFS over UDP?
> >
> >(btw, your ping time should be 200 microseconds, not 200 nanoseconds).
> >
> > =20
> >
> >>-----Original Message-----
> >>From: M. Todd Smith [mailto:todd@sohovfx.com]=20
> >>Sent: Tuesday, June 14, 2005 4:18 PM
> >>To: nfs@lists.sourceforge.net
> >>Subject: [NFS] NFS tuning - high performance throughput.
> >>
> >>
> >>Hello all,
> >>
> >>I've been attempting to get a better hold over our NFS performance as=20
> >>our network grows and grows.
> >>
> >>We've recently upgraded our NFS server machine to a dual 3.2ghz Xeon=20
> >>running Fedora Core 3 (kernel 2.6.11-1.14_FC3smp) w/ 4Gb RAM.=20
> >> Coupled=20
> >>with this machine we have a 2 Broadcom NetExtreme 2 Port PCI-X NIC on=20
> >>its own PCI-X bus (133Mhz).  Attached to this machine is our fibre=20
> >>channel SAN, using Seagate fibre-channel drives and an LSI=20
> >>dual channel=20
> >>2gigabit fibre adapter on its own PCI-X bus.  Local RW is=20
> >>~135Mbytes/sec.
> >>=20
> >>The 4 ports are trunked together using bonding (balanced round robin=20
> >>mode), and trunked together on our Extreme Networks Summit=20
> >>400i switch. =20
> >>All the test machines are attached to this switch, making everything=20
> >>within one hop and ping times of less than a 200 nanoseconds.
> >>
> >>Current test machine is running Suse 9.2 and has an Intel 100/1000 XT=20
> >>server adapter (e1000 driver) on a shared but not high=20
> >>traffic PCI bus. =20
> >>Other test machines include some Dell PowerEdge 1850's with onboard=20
> >>Intel NICs, and some Apple G4, G5 and Xserves.
> >>
> >>I have read most of the tuning guides I can find on the net and=20
> >>attempted just about everything I can get my hands on (I have=20
> >>not tried=20
> >>jumbo frames yet, still waiting for some downtime to attempt=20
> >>that).  My=20
> >>problem is that no matter how I tune the machines I can get at max=20
> >>45Mb/ps throughput on NFS.  This was the same throughput we=20
> >>were getting=20
> >>with our old server with PCI cards, moreover this throughput=20
> >>is roughly=20
> >>the same for every machine on our network.  Theoretically we=20
> >>should be=20
> >>able to get much higher values.
> >>
> >>Any idea as to why this is?  I can provide config files and such if=20
> >>needed, but I'm really at a loss as to where to start.
> >>
> >>Cheers
> >>Todd
> >>
> >>--=20
> >>Systems Administrator
> >>----------------------------------
> >>Soho VFX - Visual Effects Studio
> >>99 Atlantic Avenue, Suite 303
> >>Toronto, Ontario, M6K 3J8
> >>(416) 516-7863=20
> >>http://www.sohovfx.com
> >>----------------------------------
> >>
> >>
> >>=20
> >>
> >>
> >>
> >>-------------------------------------------------------
> >>SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> >>from IBM. Find simple to follow Roadmaps, straightforward articles,
> >>informative Webcasts and more! Get everything you need to get up to
> >>speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dcl=
ick
> >>_______________________________________________
> >>NFS maillist  -  NFS@lists.sourceforge.net
> >>https://lists.sourceforge.net/lists/listinfo/nfs
> >>
> >>   =20
> >>
> >
> >
> > =20
> >
>=20
>=20

--=-BQoiYM+jhpLp8RmnPL/H
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCr4rUo0feVm00f/8RAt+2AKCX4gJyBqvDH3HMk7prJAIaPGfX+QCdFnOw
yUk/8kMTcibkp26qmyOlfMg=
=tpo8
-----END PGP SIGNATURE-----

--=-BQoiYM+jhpLp8RmnPL/H--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
