From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: identify fs using a particular port
Date: Fri, 08 Oct 2004 14:31:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097271075.8133.126.camel@tesuji.nac.uci.edu>
References: <20041008210212.GO7742@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Pqxet4OdIi4eohi/zoQ8"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG2Ke-0002GQ-VI
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:31:20 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CG2Kc-0008Kf-Cp
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:31:20 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20041008210212.GO7742@polop.usc.edu>
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


--=-Pqxet4OdIi4eohi/zoQ8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If it's an rpc service, you can likely get what's using the port from
rpcinfo -p.

If it's not an rpc service, you may be able to get it from
/etc/services.

Also check out netstat -p.

On Fri, 2004-10-08 at 14:02, Garrick Staples wrote:
> Silly question that I can't find the answer to... is it possible to ident=
ify
> which mounted filesystem is using a particular port?
>=20
> $ netstat -an | grep :782
> tcp        0      0 10.125.0.200:782        10.125.0.193:2049       ESTAB=
LISHED=20
>                                  ^^^ I need this port for another daemon
>=20
> I have a 14 filesystems mounted from that machine, all busy with user
> processes.  So I'm trying to figure out which filesystem needs to be unmo=
unted
> to free port 782.
--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-Pqxet4OdIi4eohi/zoQ8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBZwcio0feVm00f/8RAgjPAJ472xfVBIdJPIa+95b4RtK3RA0UxwCgiXAE
fxMcs2m1eSpYOej9bc4PvPw=
=tI5k
-----END PGP SIGNATURE-----

--=-Pqxet4OdIi4eohi/zoQ8--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
