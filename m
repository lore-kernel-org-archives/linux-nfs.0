From: Mike Frysinger <vapier@gentoo.org>
Subject: librpcsecgss conflicts with clnt libc symbols
Date: Mon, 31 Jul 2006 23:29:32 -0400
Message-ID: <200607312329.33067.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0771140682=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7kwt-0006Li-WC
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 20:29:40 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7kws-0000Do-BK
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 20:29:40 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 10852642CE
	for <nfs@lists.sourceforge.net>; Tue,  1 Aug 2006 03:29:34 +0000 (UTC)
To: nfs@lists.sourceforge.net
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

--===============0771140682==
Content-Type: multipart/signed; boundary="nextPart1458906.uEfQvG1viG";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1458906.uEfQvG1viG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

the librpcsecgss duplicates some functions that the system libc normally=20
provides ... in this case:
clnt_create
clnt_pcreateerror
clnt_perrno
clnt_perror
clntraw_create
clnt_spcreateerror
clnt_sperrno
clnt_sperror
clnttcp_create
clntudp_bufcreate
clntudp_create

is there a reason for this ?  i went through the ChangeLog and couldnt find=
=20
anything ... this stuff was added like between 0.7 and 0.8 but there doesnt=
=20
appear to be any mention of why ...
=2Dmike

--nextPart1458906.uEfQvG1viG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)

iQIVAwUARM7KnEFjO5/oN/WBAQJZMQ/7BCGhTRrmvrnCOLpMwANQkgckAHym7irv
BnKSXJ5+xqu7RpzXrno4bdigJcdga8kNajdv/M34RyJPdhM/ogR0/XwIglwj6w/M
anYCbGxKzJD3FttdJIHFAHl9+TZ4mjPGERAnazR/y+wLZm+hSsnbIY7TDHLnRh0l
cY2q/3cPXt66KUH3yTUgQ7iivsFDBs1/iDWcgawNNvyFwsCKNHvOSomt4I+P/41J
uzvykkMs/mv4CLHfsFw6CuXJLu88HloZ1l/dOjInPDl3nn3Wi7pEKOGVIKcgFbhQ
ITcKLp46hnXzf2/c9lUjiW27rF+CzzQq4S0j5bb6B9cbXa68jAmt3l9hTFQ4Xo7I
B2sGYmgvJo3fCARYBS3NNGuF4NnM0FzOb7vtkNaTMhbTvxbr3ATBYPw5OTOP4goM
e3J9sCVxce+lkSDAyhd3J/5Rddq6CJhAmaC6yDWgq5UDkrdT5Up/DbdrPPKtzA92
B24eWV7Wc62aoCDrv2CMKtT5TphvlwyPfm88UXuvTpjLqUq4No//q56tLC5PCcZ/
y8OR0TKmI7XJ7QreJJTqL2gu3stE4dJtpM/zz4w38oo2uJOv3CwVdj4cPpf5MZJy
nTPZMe0iz4/bZ2dbWAGje2LLkZvCj6onk1jAXBp+aA3ymWEmEox9c4r9BGpVi62B
cDu3Yd/ZPt4=
=hn+U
-----END PGP SIGNATURE-----

--nextPart1458906.uEfQvG1viG--


--===============0771140682==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0771140682==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0771140682==--
