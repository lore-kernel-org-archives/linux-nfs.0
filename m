From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFSv4 needs restart (permission denied)
Date: Fri, 03 Dec 2004 10:52:26 -0800
Message-ID: <1102099946.3618.10.camel@tesuji.nac.uci.edu>
References: <41B0A7C0.1020209@drzeus.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vKWcxUIssPB3Ln26Ua1S"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaIXn-0003G9-2a
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:52:39 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CaIXm-0003mv-F6
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:52:38 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>
In-Reply-To: <41B0A7C0.1020209@drzeus.cx>
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


--=-vKWcxUIssPB3Ln26Ua1S
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-12-03 at 18:52 +0100, Pierre Ossman wrote:
> Whenever I reboot my file server one of my clients has trouble accessing
> the exports. I just get permission denied. However, when I restart nfsd
> it works fine. The other clients have no problems mounting.
>=20
> The server is a FC2 machine running 2.6.9-1.6_FC2.
> The problem client is a FC3 machine running 2.6.9.
> The working clients are both FC2 machines running 2.6.9-1.6_FC2.
>=20
> Any ideas on what can be wrong or how I can find out what the problem
> is? The server does not say anything during these mount requests.
>=20
> Rgds
> Pierre

We've had much the same problem with linux NFS servers, but not with
NFSv4 - it was either NFSv3 or v2.

These are my notes on the subject:

The difficulty is that we have to exportfs -auv; exportfs -av to get
mounting (both static and auto) to work.  It gives "permission denied"
when trying to do a static mount.  getfh() was failing too, according to
an strace of rpc.mountd.

Jed has an RHEL 3 server having trouble with an FC1 host.

Jed also has an RHEL 3 server having trouble with a Redhat 9 host.

>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-vKWcxUIssPB3Ln26Ua1S
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBsLXqo0feVm00f/8RAkr7AJoCjH32qIZ0O26l+2Fnh6beDJYqPgCfZy9F
6F45se11wpr0GQupd8clvKo=
=udJ1
-----END PGP SIGNATURE-----

--=-vKWcxUIssPB3Ln26Ua1S--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
