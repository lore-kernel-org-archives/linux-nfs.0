From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [patch] provide non-standard getgrouplist() in
	libnfsidmap when need be
Date: Mon, 26 Mar 2007 13:40:08 -0400
Message-ID: <200703261340.08640.vapier@gentoo.org>
References: <200703250329.03353.vapier@gentoo.org>
	<1174915365.6838.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0767267844=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVtBY-0001zE-Vi
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 10:40:49 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HVtBY-0004BW-4r
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 10:40:51 -0700
Received: from home.wh0rd.org (pool-151-203-195-204.bos.east.verizon.net
	[151.203.195.204])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 8C1DA6504E
	for <nfs@lists.sourceforge.net>; Mon, 26 Mar 2007 17:40:33 +0000 (UTC)
In-Reply-To: <1174915365.6838.6.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0767267844==
Content-Type: multipart/signed; boundary="nextPart2004344.7VFD4YH2BX";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2004344.7VFD4YH2BX
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 26 March 2007, Trond Myklebust wrote:
> On Sun, 2007-03-25 at 03:29 -0400, Mike Frysinger wrote:
> > libnfsidmap uses the non-standard function getgrouplist() ... the
> > attached patch takes code from FreeBSD to implement the function based =
on
> > POSIX functions when the system libc is not sufficient
>
> Why not just modify libnfsidmap to directly use the posix functions?

tbh, it doesnt matter to me how it gets fixed ... whether the direction is =
to=20
not use getgrouplist() at all and just use the POSIX funcs, or to use the=20
patch i posted, or ... my motivation here is purely from a distro package=20
maintainer, i dont actually use libnfsidmap ;)
=2Dmike

--nextPart2004344.7VFD4YH2BX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARggFeEFjO5/oN/WBAQIjTRAA2tF47e0NoqMhdKY4FX7GLTIcFI5057rd
3YdzFrkKBmYS1TtoBnZgMUvZgNL93ITscJ2YOORwuzAK0CRE9rwkJPmnRw//jMtg
/MAAEn6tMCWPSO5BLLEx2LaAjH3xgxNV689k4u1vYdbLlO1ky+1+ygbs+/xKrLgA
QrmdobdsDZc2wdf+GR8Y4t2FyFB7i/AWg1i1W9oBbwdlrlu4NI+09raK57HF4cJi
97lr8vgqMtV4fhFvLu4Mv/hqLcjeLQbRiVLCnIZAwTI+4h+gcT0H0zScu9RthWGm
Zi+NmC+kPq2vkpB465C9YGkkUxznG5E0NgdfxFPd/cD4VT0Anmj2RZaY6l3lVPQa
lg61VpMt/tJxS8FwSWwUjv8Gs5lmDKJKmNC7PUNICg8v7dSHwldnJDAeVMrCXGrK
J0qYxqBGUCnr1LotiDTgW955US/1TCmXS2tv8CwKujPbDnbfqZ+DVopRfWeh4+8O
yq7oBODERU67anrnfQzlUNvNTJQMeI6CuOFcHHrQvv7X3o7y73TVbF5kqrcr8+ZM
iyHTPct9/5qZ6RRAoPSTT105QTCqo7+wWTSCWZdGAQ3BIyunM2STGzb4kICFlKWw
A7A9um5LbN0H//UUOyp8U0WN5EkLHPujesOQvm9FZI/HEdZSiAUsYbuqjdpEbAeW
tTcrO9r8K4k=
=QyV1
-----END PGP SIGNATURE-----

--nextPart2004344.7VFD4YH2BX--


--===============0767267844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0767267844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0767267844==--
