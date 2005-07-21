From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: IA64 Server / IA32 Client Problem
Date: Thu, 21 Jul 2005 12:29:13 -0700
Message-ID: <1121974153.8516.131.camel@seki.nac.uci.edu>
References: <42DED21E.4010608@aspsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dAQk/bhYwAguwuFMncC2"
Cc: nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dvgjh-00049s-2q
	for nfs@lists.sourceforge.net; Thu, 21 Jul 2005 12:29:37 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dvgjf-0003Os-Gz
	for nfs@lists.sourceforge.net; Thu, 21 Jul 2005 12:29:37 -0700
To: Brett Petrusek <brettp@aspsys.com>
In-Reply-To: <42DED21E.4010608@aspsys.com>
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


--=-dAQk/bhYwAguwuFMncC2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Well, for starters, how about looking over:

http://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html

http://dcs.nac.uci.edu/~strombrg/network-performance.html

If anyone has any suggestions on how to improve these documents,
-please-do- suggest away.  :)

On Wed, 2005-07-20 at 16:37 -0600, Brett Petrusek wrote:
> I'm not sure if this is a bug or what, but I am experiencing severe=20
> performace problems between an IA64 NFS server and IA32 NFS client. I=20
> have tried every combination of socket buffer sizes as well as many=20
> other nfs options, but none of them seem to have any effect. I have=20
> tried RHEL21 to RHEL3U5 with all of these socket combos and still no=20
> difference. The command I am running is:
>=20
> time dd if=3D/dev/zero of=3D/scratch_dir_across_nfs bs=3D1M count=3D128
>=20
> Between two IA32 machines this takes 4-5 seconds. Between IA64 server=20
> and IA32 client this takes on the order of minutes. Network performance=20
> has been eliminated from the equation as after kernel tuning we have=20
> achieved consistent 94% of peak tcp throughput and 95.7% of peak udp=20
> throughput on our GigE network.  This is both between IA32 and IA64=20
> systems.
>=20
> Let me know if there is an other info I should provide to help=20
> troubleshoot this problem.
>=20
> Any help is appreciated.
> Thanks, Brett P
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

--=-dAQk/bhYwAguwuFMncC2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBC3/eJo0feVm00f/8RAkCXAKCK8gkf/OqXKSghfiZ0orAvzVAQyQCeJuqh
0+QxlCg6HnrWAVyPLnLbIjc=
=i2+/
-----END PGP SIGNATURE-----

--=-dAQk/bhYwAguwuFMncC2--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
