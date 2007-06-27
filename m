From: Andre Noll <maan@systemlinux.org>
Subject: 2.6.21.x kernel panic (tg3 and nfs related)
Date: Wed, 27 Jun 2007 12:16:08 +0200
Message-ID: <20070627101608.GQ22589@skl-net.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0600623770=="
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3UhW-0005gE-He
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 03:24:42 -0700
Received: from systemlinux.org ([83.151.29.59] helo=m18s25.vlinux.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3UhX-0007uN-LT
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 03:24:46 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============0600623770==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eBTWNsZZiigckDWV"
Content-Disposition: inline


--eBTWNsZZiigckDWV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi

Our nfs server recently paniced under heavy nfs load. The backtrace
indicates that this might be a problem with the tigon3 network driver
which drives the onboard chips of the machine.

The first crash under 2.6.21.1 happened after about 4 days of uptime,=20
2.6.21.5 already crashed after 15 Minutes.

Screenshots of the resulting kernel panics are available at

	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.1.png
and
	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.5.png

We're now running 2.6.18.6 again which happens to be rock solid for our
workload. However, this kernel now spits out zillons of messages like

	[55122.674290] RPC: bad TCP reclen 0x00010094 (large)

I'm sure it didn't do that half a year ago when it was running for
several months. The 2.6.21.x kernels did not print these messages
either, but from what I understand this is due to a patch which went
in somewhere between 2.6.18 and 2.6.21 and which just ratelimited
the message.

So something weird seems to be going on in our network and this might
well be related to the 2.6.21.x crashes we are seeing.

Thanks
Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--eBTWNsZZiigckDWV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFGgjjoWto1QDEAkw8RAvaKAJ9zSErbii7/q3BWzxVrKbXDXbP5WQCfRO3a
pBdoip/KNTMfzhUiCGEHm+s=
=Uu70
-----END PGP SIGNATURE-----

--eBTWNsZZiigckDWV--


--===============0600623770==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0600623770==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0600623770==--
