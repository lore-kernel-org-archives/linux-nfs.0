From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: /etc/exports continue line
Date: Thu, 12 Apr 2007 17:37:09 -0400
Message-ID: <200704121737.09818.vapier@gentoo.org>
References: <461EA1CC.2050102@cogweb.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1374705778=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc6xw-0001RX-Ds
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:36:29 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hc6xx-0006Ej-Q5
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:36:30 -0700
In-Reply-To: <461EA1CC.2050102@cogweb.net>
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

--===============1374705778==
Content-Type: multipart/signed; boundary="nextPart2087355.CZUma6vrfK";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2087355.CZUma6vrfK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 12 April 2007, David Liontooth wrote:
> I've been using \ to continue a line in /etc/exports, and ran into an
> odd problem -- if you accidentally hit the TAB key after the continue
> line and save, the entry becomes invalid. Since the TAB key is
> invisible, it can be difficult to figure out what's going on.

is there any file out there that does not exhibit this same behavior ?  see=
ms=20
like the behavior you're seeing is pretty standard and imho expected ...

also, many editors have the ability to "show" whitespace ...
=2Dmike

--nextPart2087355.CZUma6vrfK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARh6mhUFjO5/oN/WBAQIzEA//d8C/HPtwbCEMMi/46QA5Rl/E9H3/c51T
JsIQV+62zdn+y2y1YzJ8ZhWdylSpjWUq1wjtyq+pUEC3lZMcahJua7/Trc/nqWhI
O3BcWFYTcXqfRVNmqDDmvdPLEM1UL2UEjE8+r9D6G3+iz6NCnMIrRdu47yCSANMl
ERDThKt2ZrbKfqXI8dSdX4robh+dT9MmPb1nseykehxwWXOaIUZQ9zXoF7CsMrht
nkcUExDGulnLtu0UOJtki4ehQitztX80QE/DhdcTygyy5sWQhHPgtCTACFLUIYsP
0tMmLd2RQBpcR9REzUUJHqfL/+fbdw6YYbxgQNQmfPk08i0AYoTFfiysJxuqMpqo
o4lBLEkh+Gakw9f/hlSQVrU+tNs+85mzVEu70Ovsid59eQpz4q+eE8kiU0YInkLA
7aWYdajyxcTMgY7pEQGhld2iN8zwmBfjk1aOK0imCee870ADwQwkhzQiC8nofQ3s
0Akf0rmc1CIoD5RlTcbaizJ18dAr7zSblQNOInClmoxBGC6f4on434DddM30OJTa
9jSdj/+7UcN/eQxiV3+cE9L+Pr7tzhfPWTT5pTi4yim8f4iJFDBvLNfQ826WLi9L
a/V3FEgzkl5+xD5bwOLeihKdOHGv905rhkO8znu25GFuF63OADcy3Ro1nPBqKZO2
XxRSZforIiA=
=UoH4
-----END PGP SIGNATURE-----

--nextPart2087355.CZUma6vrfK--


--===============1374705778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1374705778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1374705778==--
