From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS High Availability Cluster
Date: Mon, 13 Jun 2005 11:10:15 -0700
Message-ID: <1118686215.25437.19.camel@seki.nac.uci.edu>
References: <42AD5820.4060109@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-KvMDhBgyXCGImy7IJbsx"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhtOH-0004TN-1h
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 11:10:29 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DhtOG-0007g8-Gd
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 11:10:28 -0700
To: Oded Maimon <oded.maimon@gmail.com>
In-Reply-To: <42AD5820.4060109@gmail.com>
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


--=-KvMDhBgyXCGImy7IJbsx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I'm told that the current generation of automounter should be able to
failover readonly versions of the same data.

What we've been doing so far with linux, though, is to have a script
that, instead of using fstab, instead traceroute's each of the replica
servers and statically NFS mounts from the one that is up, and shows the
lowest number of router hops.

The autofs failover should obviate reboots, at least to some extent.

The script I've described, which I'd be happy to share, makes it so
endusers can just reboot to come up mounting from a different replica.

On Mon, 2005-06-13 at 11:55 +0200, Oded Maimon wrote:
> Hi,
>=20
> Is it possible to set an NFS HA cluster?
>=20
> That means, that several servers will share the same disks in a SAN and=20
> will provide an NFS service for
>=20
> all my other servers?
>=20
>=20
> I need that when one NFS server will fail (or the network connection to=20
> it)  then no server using the NFS will be affected and will continue to
>=20
> work with one of the other NFS servers.
>=20
>=20
> Is it possible?
>=20
>=20
> Thanks,
>=20
> Oded.
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you sho=
tput
> a projector? How fast can you ride your desk chair down the office luge t=
rack?
> If you want to score the big prize, get to know the little guy. =20
> Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=3D20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-KvMDhBgyXCGImy7IJbsx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCrcwHo0feVm00f/8RAnUUAJ93e+CyszDI+sAIzFhR/v2veC40EwCfZY8F
bKkBJ1lI8QVSg85uQpe6j/0=
=DNQh
-----END PGP SIGNATURE-----

--=-KvMDhBgyXCGImy7IJbsx--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
