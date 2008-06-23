From: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Subject: [NFS] NFS performance debuggins
Date: Mon, 23 Jun 2008 16:59:57 +0200
Message-ID: <200806231659.58158@fortytwo.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1623425367=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36505 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677AbYFWPAN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 11:00:13 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KAnWd-0000oE-06
	for linux-nfs@vger.kernel.org; Tue, 24 Jun 2008 01:00:11 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1623425367==
Content-Type: multipart/signed; boundary="nextPart6924612.xJZJZVSRS2";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart6924612.xJZJZVSRS2
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

Environment:

several Debian based clients (Debian etch and etchnhalf kernels, this means=
=20
2.6.18 or 2.6.24); Debian etch (2.6.18 kernel) NFS (v3) server.  Network=20
seems basically ok ("ping -f -s 3000" works without losses, ifconfig and=20
switch monitoring shows no errors) with no noticeable load.  Disks seem to=
=20
have very little load either, NFS server has no other tasks.

Performance is sluggish :-(  Basically works, though -- no spurious errors.

tcpdump shows many "reply ERR 1448" etc. msgs whenever NFS activitiy is=20
going on (both stat like with "find /home" or read/write with dd)

+++
16:49:24.778560 IP 10.0.1.2.2049 > 10.0.0.209.809066834: reply ERR 1448
16:49:24.790304 IP 10.0.1.2.2049 > 10.0.0.209.943279929: reply ERR 1448
16:49:24.801380 IP 10.0.1.2.2049 > 10.0.0.209.2001885801: reply ERR 1448
16:49:24.802173 IP 10.0.1.2.2049 > 10.0.0.209.860835666: reply ERR 1448
16:49:24.805286 IP 10.0.1.2.2049 > 10.0.0.209.1479697199: reply ERR 1332
16:49:24.807679 IP 10.0.1.2.2049 > 10.0.0.209.1096249460: reply ERR 1448
16:49:24.808358 IP 10.0.1.2.2049 > 10.0.0.209.2000902760: reply ERR 1332
16:49:24.809097 IP 10.0.1.2.2049 > 10.0.0.209.926298420: reply ERR 1448
16:49:24.809100 IP 10.0.1.2.2049 > 10.0.0.209.25105411: reply ERR 1332
16:49:24.817923 IP 10.0.1.2.2049 > 10.0.0.209.1366504235: reply ERR 1448
16:49:24.817927 IP 10.0.1.2.2049 > 10.0.0.209.352525071: reply ERR 1332
16:49:24.820397 IP 10.0.1.2.2049 > 10.0.0.209.269848846: reply ERR 1332
16:49:24.822097 IP 10.0.1.2.2049 > 10.0.0.209.1345540144: reply ERR 1448
16:49:24.822856 IP 10.0.1.2.2049 > 10.0.0.209.944780599: reply ERR 1448
16:49:24.825109 IP 10.0.1.2.2049 > 10.0.0.209.1395668559: reply ERR 1448
16:49:24.825112 IP 10.0.1.2.2049 > 10.0.0.209.1999335795: reply ERR 1332
16:49:24.827813 IP 10.0.1.2.2049 > 10.0.0.209.1685677906: reply ERR 1332
16:49:24.829439 IP 10.0.1.2.2049 > 10.0.0.209.1666084982: reply ERR 1448
16:49:24.829443 IP 10.0.1.2.2049 > 10.0.0.209.1415656037: reply ERR 1332
16:49:24.839013 IP 10.0.1.2.2049 > 10.0.0.209.911226680: reply ERR 1448
16:49:24.839017 IP 10.0.1.2.2049 > 10.0.0.209.1735414852: reply ERR 1332
16:49:24.841325 IP 10.0.1.2.2049 > 10.0.0.209.911358287: reply ERR 1332
16:49:24.842092 IP 10.0.1.2.2049 > 10.0.0.209.1364284211: reply ERR 1448
16:49:24.842800 IP 10.0.1.2.2049 > 10.0.0.209.258643250: reply ERR 1332
16:49:24.844256 IP 10.0.1.2.2049 > 10.0.0.209.1666017882: reply ERR 1448
16:49:24.844996 IP 10.0.1.2.2049 > 10.0.0.209.808595513: reply ERR 1448
16:49:24.845674 IP 10.0.1.2.2049 > 10.0.0.209.2000779112: reply ERR 1448
16:49:24.845677 IP 10.0.1.2.2049 > 10.0.0.209.1652175121: reply ERR 1332
16:49:24.847120 IP 10.0.1.2.2049 > 10.0.0.209.944722769: reply ERR 1448
16:49:24.847123 IP 10.0.1.2.2049 > 10.0.0.209.1682657874: reply ERR 1332
16:49:24.849334 IP 10.0.1.2.2049 > 10.0.0.209.944714835: reply ERR 1448
16:49:24.850873 IP 10.0.1.2.2049 > 10.0.0.209.1345861938: reply ERR 1448
16:49:24.918710 IP 10.0.1.2.2049 > 10.0.0.179.1936680564: reply ERR 1448
16:49:24.918719 IP 10.0.1.2.2049 > 10.0.0.179.1698508838: reply ERR 1448
16:49:24.921911 IP 10.0.1.2.2049 > 10.0.0.179.1633904741: reply ERR 1448
+++

Mount options: "rw,noatime,rsize=3D8192,wsize=3D8192,intr,hard,addr=3D10.0.=
1.2",=20
it seems to pick tcp by default.  I had problems with UDP from some of the=
=20
clients due to a strangely buggy VDSL switch in the path, so I haven't=20
tried that again (I want to keep the DSL clients and the non-DSL clients=20
identical if this is at all possible, so I can switch equipment around=20
without reconfiguration.)

That performance is not optimal whith todays desktop environments (tons of=
=20
small configuration files in both oo.org and kde) at login/program start on=
=20
cold caches is one thing, but performance

Now where do I start debugging this?

=2D-=20
Development costs of average proprietary and free software don't differ
radically because the methods are pretty much the same.  The huge
difference lies in the way the developers try to recoup their costs, not
in the costs they have to compensate.
        -- Florian Weimer on debian-security

--nextPart6924612.xJZJZVSRS2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: get my key from http://fortytwo.ch/gpg/92082481

iKcEABECAGcFAkhfum5gGmh0dHA6Ly9mb3J0eXR3by5jaC9sZWdhbC9ncGcvZW1h
aWwuMjAwMjA4MjI/dmVyc2lvbj0xLjUmbWQ1c3VtPTVkZmY4NjhkMTE4NDMyNzYw
NzFiMjVlYjcwMDZkYTNlAAoJECqqZti935l6CzIAoJogBkUgRq5o3aeLBkfUrb2P
QGo2AKCkFmIuQJoKOuNEx6GviUqi0fWVsQ==
=LYRd
-----END PGP SIGNATURE-----

--nextPart6924612.xJZJZVSRS2--


--===============1623425367==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1623425367==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1623425367==--


