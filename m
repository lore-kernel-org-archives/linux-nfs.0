From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 14:29:42 -0800
Message-ID: <1102631382.3784.20.camel@tesuji.nac.uci.edu>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
	 <41B74551.5040908@sun.com>  <20041209113107.GE15055@suse.de>
	 <1102620880.3784.3.camel@tesuji.nac.uci.edu>
	 <1102628037.10668.86.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-YTC/DC0lFcfxCbEMTKNI"
Cc: strombrg@dcs.nac.uci.edu, Olaf Kirch <okir@suse.de>,
        Mike Waychison <Michael.Waychison@sun.com>,
        Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWnN-0005KQ-L6
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:29:57 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CcWnK-0006dH-M8
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:29:57 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102628037.10668.86.camel@lade.trondhjem.org>
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


--=-YTC/DC0lFcfxCbEMTKNI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-09 at 16:33 -0500, Trond Myklebust wrote:
> to den 09.12.2004 Klokka 11:34 (-0800) skreiv Dan Stromberg:
>=20
> > It'd probably be worthwhile to have options to make NFS (and my
> > printsystem) generate any port (not just reserved ones), and accept onl=
y
> > reserved ports - but the default probably should be to accept any port,
> > and send only reserved ports - not because reserved ports are effective
> > at all, but because it'll avoid never ending questions about why NFS
> > isn't working.
>=20
> Sure. The questions will no longer read "why isn't NFS working". They'll
> read "why can any Tom, Dick and Harry suddenly read my private email
> directly from the NFS server?". 8-)
>=20
> The standard AUTH_SYS/AUTH_UNIX authentication scheme only checks the
> source IP address, and trusts the client 100% when it comes to supplying
> the correct uid/gid/.... (see RFC1831). By placing the additional
> requirement that the source must be a privileged port, one is at least
> able to prevent ordinary users on an authorized client from being able
> to spoof NFS requests.
>=20
> Cheers,
>   Trond

I bow before your superior geekiness.  :)



--=-YTC/DC0lFcfxCbEMTKNI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBuNHWo0feVm00f/8RAoHFAJ9h90/QTIYI3nUFU78b3nBNi01NiwCfRSbj
EXfy2AlmTVkmuzP8gJY4NM8=
=NZoT
-----END PGP SIGNATURE-----

--=-YTC/DC0lFcfxCbEMTKNI--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
