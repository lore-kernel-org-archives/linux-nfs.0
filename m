From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Help: nfs not able to mount large (loopback) directory
Date: Fri, 03 Jun 2005 22:28:30 -0700
Message-ID: <1117862910.19354.172.camel@seki.nac.uci.edu>
References: <20050604031908.D58E8198C8@medulla.enet.sharplabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6ymLm02C5Wsv0N8iJnRo"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DeRD8-0002I2-DJ
	for nfs@lists.sourceforge.net; Fri, 03 Jun 2005 22:28:42 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DeRD5-0003s0-Kb
	for nfs@lists.sourceforge.net; Fri, 03 Jun 2005 22:28:42 -0700
To: "Dean S. Messing" <deanm@sharplabs.com>
In-Reply-To: <20050604031908.D58E8198C8@medulla.enet.sharplabs.com>
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


--=-6ymLm02C5Wsv0N8iJnRo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I also have found that even small ISO images will lead to problems if
you loopback mount them and NFS export them - EG via NFS v3.

However, if I loopback mount the ISO image, copy it to an ext3 directory
with a tar | tar pipeline, and then NFS export that ext3 directory in
the same way, things work fine.

I'm finding that often userspace->kernel and kernel->userspace work well
in linux, but kernel->kernel interfaces seem to have  codepaths that
aren't always tested that much.

On Fri, 2005-06-03 at 20:19 -0700, Dean S. Messing wrote:
>=20
> I have a large .iso image (4GB) on machine B which I have loopback
> mounted to directory /mnt/disk.
>=20
> When I try to nfs mount B:/mnt/disk to machine A I get a "permission
> denied" error.
>=20
> If I replace the 4GB image on machine B with, say, a 700MB .iso image, I =
have
> no problem with the NFS mount on machine A.
>=20
> I'm running the latest version of MandrivaLinux (2005LE =3D=3D Mandrake 1=
0.2)
> on machine B and MandrakeLinux 10.0 on machine A so the nfs utilites
> on machine B (the server) should be nearly current.
> In fact:
>=20
> [root@neuron ~]# rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   udp  34593  nlockmgr
>     100021    3   udp  34593  nlockmgr
>     100021    4   udp  34593  nlockmgr
>     100021    1   tcp  33635  nlockmgr
>     100021    3   tcp  33635  nlockmgr
>     100021    4   tcp  33635  nlockmgr
>     100005    1   udp    846  mountd
>     100005    1   tcp    849  mountd
>     100005    2   udp    846  mountd
>     100005    2   tcp    849  mountd
>     100005    3   udp    846  mountd
>     100005    3   tcp    849  mountd
>     100024    1   udp    888  status
>     100024    1   tcp    891  status
>=20
>=20
> Is it the case that nfs (mountd?) can't handle "large" files?
>=20
> Any help will be much appreciated.
>=20
> Dean S. Messing
> Sr. Scientist
> Display Algorithms & Visual Optimization Lab
> Sharp Laboratories of America
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

--=-6ymLm02C5Wsv0N8iJnRo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCoTv+o0feVm00f/8RAtk8AJ0dOgHbZofc2Kaxa6iscnO0h2cOqACgijoV
B0IYtSZkdLXwDb1djwbA6dk=
=sSCV
-----END PGP SIGNATURE-----

--=-6ymLm02C5Wsv0N8iJnRo--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
