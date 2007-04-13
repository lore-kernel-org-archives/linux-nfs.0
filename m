From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: /etc/exports continue line
Date: Thu, 12 Apr 2007 20:49:21 -0400
Message-ID: <200704122049.22452.vapier@gentoo.org>
References: <461EA1CC.2050102@cogweb.net>
	<17950.42736.114011.686026@notabene.brown>
	<461EAE48.9020703@cogweb.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0721150253=="
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc9xx-0003YY-K5
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:48:41 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hc9xx-0005Id-01
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:48:44 -0700
In-Reply-To: <461EAE48.9020703@cogweb.net>
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

--===============0721150253==
Content-Type: multipart/signed; boundary="nextPart1996405.dJnbY5bTve";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1996405.dJnbY5bTve
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 12 April 2007, David Liontooth wrote:
> Once you know about this quirk, it's obviously less of an issue.

like everything else in the *nix world ;)

> Could exportfs just filter out TAB characters,=20
> or would you consider that unwanted code clutter?

err, i dont think that's not a good idea ... the expots is whitespace=20
delimited, not space delimited ... that'd break configurations i'd imagine
=2Dmike

--nextPart1996405.dJnbY5bTve
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARh7TkkFjO5/oN/WBAQIfVQ/9EcmFJEXUuv7tyMEsY+oNTuNyObyibBNb
KGRNAbjggKxslP5fZvOFd+KgwVvwRsVxVyXfI+NDO4EIMQfmlH5Ph1N1Npw4pNsj
SsK908t3ZXmEhsH04ttDf5mL4syw+tuZvoWALCa/QAioDoU51AFxRxaoh0hBNEq8
c26wXYfhmK19lC7lE3+CqfBBzr0WCzBCWMYGhsfgZKi3ak7vvPqcjZ8mvDld0XSQ
cqwxSdrZ1AZxgdO1PPDOdXzEqLqyWF2d2E0qbsPv2B5ZUvgTOUERiNp8OAoYfFjK
j3kRvq9IwvVP+CtWxj3wdPkrXVp0KRqS00F51NWKSltRtUZLcozSf1Cl6PJaIKoY
jl9CnodoWOR3KkLgQu1e1Io+8C/PetaZc0OnvOT2QQxYNB1mKxqpPEwMIYjnRYgA
R9pB6pXylvYRztg+4UhTuEK7Q624VL5RfngacJWjSrrVWopv4Fv0DwlNxxFnexEs
HtKjsx2XevSYqorB8he32mxHzjfvtHC6o9st/8v89LbAZZMJRf9FkcKVnJSiwcDC
2UqOd676FHqD/fLtDFFieMyV7puxtWp79nkQfrV3n8QIIU3/JizWvlFYMQC7W984
YQSSCdKDxbKxPQeR0Xmurxt1rfuC4itBy4Bq+ku12rdAgRvjMdH0bHvVrd/NtdTj
2RVagNJ7NII=
=UbaQ
-----END PGP SIGNATURE-----

--nextPart1996405.dJnbY5bTve--


--===============0721150253==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0721150253==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0721150253==--
