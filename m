From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Debian Bug#203077: Locks not released on NFS client
	reboot
Date: Fri, 14 Jan 2005 09:47:20 -0800
Message-ID: <1105724840.13393.36.camel@localhost.localdomain>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	 <20030727163124.GC19877@perlsupport.com>
	 <16164.29864.268358.781865@gargle.gargle.HOWL>
	 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
	 <16871.11926.507904.373575@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZYkizCQCH89KDGhXM3JY"
Cc: strombrg@dcs.nac.uci.edu, "Ara.T.Howard" <Ara.T.Howard@noaa.gov>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpVXn-0002J6-GB
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 09:47:31 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpVXm-00060G-2T
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 09:47:31 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16871.11926.507904.373575@cse.unsw.edu.au>
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


--=-ZYkizCQCH89KDGhXM3JY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-01-14 at 13:29 +1100, Neil Brown wrote:
> On Thursday January 13, Ara.T.Howard@noaa.gov wrote:
> >=20
> > i am seeing problems here on my system (which has rebooted and now has =
stale
> > locks on server)
> >=20
> ..
> >    server:
> >=20
> >      mussel:~ > rpcinfo -u bligh status
> >      rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
> >      program 100024 is not available
> ...
> >=20
> >    client:
> >=20
> >      bligh:~ > rpcinfo -p
> >         program vers proto   port
> >          100000    2   tcp    111  portmapper
> >          100000    2   udp    111  portmapper
> >          100024    1   udp  32768  status
> >          100024    1   tcp  32768  status
> ...
>=20
>=20
> So bligh, the client, is running statd (the "status" service), but
> mussel can not talk to it.  This is a problem.
>=20
> It would appear that some for of firewall is blocking access to
> bligh's statd from mussel, or that  bligh's statd is ignoring requests
> from mussel.  I don't know which.
>=20
> NeilBrown

I'm actually seeing a lot of problems on *ix systems were a service is
registered, but then the corresponding daemon doesn't actually service
requests.

My rpc-health script allowed me to identify a lot of such problems
fairly quickly:

http://dcs.nac.uci.edu/~strombrg/rpc-health.html

...so I guess the upshot is "It isn't necessarily a firewall problem".


--=-ZYkizCQCH89KDGhXM3JY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB6AWoo0feVm00f/8RAmn2AJ0QO7B2sjPfrg+Qb2y1osRP/0Ui4gCggZIU
cBWup+gf4o7SrJ2zxkBcNGM=
=Vkms
-----END PGP SIGNATURE-----

--=-ZYkizCQCH89KDGhXM3JY--



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
