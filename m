From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Debian Bug#203077: Locks not released on NFS client
	reboot
Date: Fri, 21 Jan 2005 11:05:49 -0800
Message-ID: <1106334349.21404.259.camel@localhost.localdomain>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	 <20030727163124.GC19877@perlsupport.com>
	 <16164.29864.268358.781865@gargle.gargle.HOWL>
	 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
	 <16871.11926.507904.373575@cse.unsw.edu.au>
	 <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
	 <1106268738.30991.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0501211118380.15036@harp.ngdc.noaa.gov>
	 <1106332841.21404.253.camel@localhost.localdomain>
	 <Pine.LNX.4.60.0501211157450.15036@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XMRM8uVd9Roi44s6Y1ck"
Cc: strombrg@dcs.nac.uci.edu,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>, Chip Salzenberg <chip@pobox.com>,
	nfs@lists.sourceforge.net, Mark O Sleeper <Mark.O.Sleeper@noaa.gov>,
	thomas.r.carey@noaa.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs46a-0006CH-VT
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 11:06:00 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cs46Z-0006yq-Km
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 11:06:00 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0501211157450.15036@harp.ngdc.noaa.gov>
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


--=-XMRM8uVd9Roi44s6Y1ck
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-01-21 at 11:59 -0700, Ara.T.Howard wrote:
> >>    on the server - where ip is the client's ip
> >>
> >>      -A INPUT -s 10.1.186.71/32 -j ACCEPT
> >>
> >>    on the client, where ip is the server's ip
> >>
> >>      -A INPUT -s 10.1.186.54/32 -j ACCEPT
>=20
> we effictively did NOT firewall ANYTHING between client and server so
> portmapping shouldn't have made any difference right?

Likely, but the sniffer should give you an empirical indication, which
is better than what our theoretical discussion might give you.


--=-XMRM8uVd9Roi44s6Y1ck
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB8VKNo0feVm00f/8RAguiAJ9ftscHx4xlhhuMe7W22lt5oXcy3wCgpA7M
T5n+LDdt+ok7lhw2r3X2bVQ=
=S2M/
-----END PGP SIGNATURE-----

--=-XMRM8uVd9Roi44s6Y1ck--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
