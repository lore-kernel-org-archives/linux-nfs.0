From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: librpcsecgss conflicts with clnt libc symbols
Date: Tue, 1 Aug 2006 19:02:36 -0400
Message-ID: <200608011902.36612.vapier@gentoo.org>
References: <200607312329.33067.vapier@gentoo.org>
	<200608011032.33097.vapier@gentoo.org>
	<4d569c330608010755s21d6bc6bv6a0ec3d8668aa3db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0593696943=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G83G3-0001ss-7N
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 16:02:39 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G83G2-0006O8-F5
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 16:02:39 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 07C6A646E3
	for <nfs@lists.sourceforge.net>; Tue,  1 Aug 2006 23:02:36 +0000 (UTC)
To: "Kevin Coffman" <kwc@citi.umich.edu>
In-Reply-To: <4d569c330608010755s21d6bc6bv6a0ec3d8668aa3db@mail.gmail.com>
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

--===============0593696943==
Content-Type: multipart/signed; boundary="nextPart14441387.CM4ZKTGkqb";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart14441387.CM4ZKTGkqb
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 01 August 2006 10:55, Kevin Coffman wrote:
> I've seen this with authenticated NIS.  Can you point me at the bug report?

http://bugs.gentoo.org/141959

> I'm working on a patch right now for librpcsecgss that hides our
> versions of these functions by renaming them to rpcsecgss_*.  It may
> require some configure changes to the nfs-utils code to make it happy
> with the new names...

thanks !
-mike

--nextPart14441387.CM4ZKTGkqb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)

iQIVAwUARM/djEFjO5/oN/WBAQJV/A//V6FbdHr5PrznAFggUJn1LpkINWglbrmb
4ywje6GrK4OW+S3WKImrcZFTvxlrR3RaO+R901nTdwC59f4xMRKogv2ufy6eMAgv
k98hxJjGqovcWz7Lq0t76vnBroeWUtI31I0mamMlhxzyQtj6Z+QT57/7ZSgUtOvT
44QlhYN48OoEYAuagEEpx/6lOZLc+DHY1FWsJw3Zo5C2qhRF06pQYMLTTLK4+G0z
Hyctycl6KHGo1P8FqiPlv2xsaEW1UjiZkyf35fwvOaac6p+vQ76/jT55XReLk9IK
ZgVN/z6c+beK4ZweJ+oxAEaDBUtRIUYL04p4WojQqR+V6P+zcdh8UT1pLGtASRT2
axxUgGSqx60sPt40o13y8UY1qfRCNFl97sRReOd6IXoNTGQRbmsFax5uNaAZv9RB
u56p6w6mSk7ExXJTx0jIQKhiIKPRRrWgFEF29U30ADZIw8pg6VX9yfN/6xj2+RDF
/VEbLja4MN3wRZcO7voJJdxkBxDZCjt4+xr/qYzxl0bEyFoiZY6pfSKQQbxzuHw5
IR5R1sa0pqaPgON0PMGzoBNyPk6Hqe51Zzwpe5rUHqc56ai0UIh7LboigDdceka8
q5Mfam+LyVNx8Sk0r5R99PKnyeEkE1edUWIdHZr07IJlSHycjvHO29gHxvRHBTNq
6kdcf4xCxzw=
=o+S1
-----END PGP SIGNATURE-----

--nextPart14441387.CM4ZKTGkqb--


--===============0593696943==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0593696943==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0593696943==--
