From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Debian Bug#203077: Locks not released on NFS client
	reboot
Date: Fri, 14 Jan 2005 13:20:49 -0800
Message-ID: <1105737649.13393.42.camel@localhost.localdomain>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	 <20030727163124.GC19877@perlsupport.com>
	 <16164.29864.268358.781865@gargle.gargle.HOWL>
	 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
	 <16871.11926.507904.373575@cse.unsw.edu.au>
	 <1105724840.13393.36.camel@localhost.localdomain>
	 <Pine.LNX.4.60.0501141113230.11608@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fiWp3f1F7dflLBYwiqR4"
Cc: strombrg@dcs.nac.uci.edu, Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net,
	thomas.r.carey@noaa.gov, Mark O Sleeper <Mark.O.Sleeper@noaa.gov>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpYsc-0002gU-5Y
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 13:21:14 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpYsa-0003d0-JR
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 13:21:13 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0501141113230.11608@harp.ngdc.noaa.gov>
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


--=-fiWp3f1F7dflLBYwiqR4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-01-14 at 11:19 -0700, Ara.T.Howard wrote:

> nice!

Why thank you.  :)

> it is showing (mussel=3Dserver, bligh=3Dclient) :
>=20
>    mussel:
>=20
>      ~ > ./rpc-health bligh
>      rpcinfo: can't contact portmapper: RPC: Remote system error - No rou=
te to
>      host

That sounds like your portmapper is blocked somehow.

>    bligh:
>=20
>      ~ > ./rpc-health mussel
>      Program portmapper/100000, Proto tcp, Version 2 is OK
>      Program portmapper/100000, Proto udp, Version 2 is OK
>      Program status/100024, Proto udp, Version 1 is OK
>      Program status/100024, Proto tcp, Version 1 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>      Program rquotad/100011, Proto udp, Version 1 is OK
>      Program rquotad/100011, Proto udp, Version 2 is OK
>      Program rquotad/100011, Proto tcp, Version 1 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>      Program rquotad/100011, Proto tcp, Version 2 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>      Program nfs/100003, Proto udp, Version 2 is OK
>      Program nfs/100003, Proto udp, Version 3 is OK
>      Program nfs/100003, Proto tcp, Version 2 is OK
>      Program nfs/100003, Proto tcp, Version 3 is OK
>      Program nlockmgr/100021, Proto udp, Version 1 is OK
>      Program nlockmgr/100021, Proto udp, Version 3 is OK
>      Program nlockmgr/100021, Proto udp, Version 4 is OK
>      Program nlockmgr/100021, Proto tcp, Version 1 is BAD <=3D=3D=3D=3D=
=3D=3D=3D=3D
>      Program nlockmgr/100021, Proto tcp, Version 3 is BAD <=3D=3D=3D=3D=
=3D=3D=3D=3D
>      Program nlockmgr/100021, Proto tcp, Version 4 is BAD <=3D=3D=3D=3D=
=3D=3D=3D=3D
>      Program mountd/100005, Proto udp, Version 1 is OK
>      Program mountd/100005, Proto tcp, Version 1 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>      Program mountd/100005, Proto udp, Version 2 is OK
>      Program mountd/100005, Proto tcp, Version 2 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>      Program mountd/100005, Proto udp, Version 3 is OK
>      Program mountd/100005, Proto tcp, Version 3 is BAD <=3D=3D=3D=3D=3D=
=3D=3D=3D
>=20
> so apparently our system is severly misconfigured!  i'm guess all the BAD=
's
> for tcp are o.k. but that the 'no route to host' is not a good thing.  so=
und
> accurate?

Those bads are probably instances of services that are registered, but
do not respond to a minimalist, "ping like" RPC procedure.  They may
actually be troublesome.  Or not.  :)

> btw. here is a small patch:

Thanks.  I've incorporated something along these lines now.



--=-fiWp3f1F7dflLBYwiqR4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB6Dexo0feVm00f/8RAkpfAKCIMd6nQP2aQg3Yw8wfTkZrMnTgqQCePEFT
A02xbSdiBhDoSkOyAzSliEY=
=bAB7
-----END PGP SIGNATURE-----

--=-fiWp3f1F7dflLBYwiqR4--



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
