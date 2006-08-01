From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: librpcsecgss conflicts with clnt libc symbols
Date: Tue, 1 Aug 2006 10:32:32 -0400
Message-ID: <200608011032.33097.vapier@gentoo.org>
References: <200607312329.33067.vapier@gentoo.org>
	<4d569c330608010631m70adbb7ft6b60f5c19bde64a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0639068835=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7vIT-0005U1-AU
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 07:32:37 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7vIS-0002fK-KI
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 07:32:37 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 93809648C5
	for <nfs@lists.sourceforge.net>; Tue,  1 Aug 2006 14:32:34 +0000 (UTC)
To: "Kevin Coffman" <kwc@citi.umich.edu>
In-Reply-To: <4d569c330608010631m70adbb7ft6b60f5c19bde64a5@mail.gmail.com>
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

--===============0639068835==
Content-Type: multipart/signed; boundary="nextPart1226954.CXbJl3UD3k";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1226954.CXbJl3UD3k
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 01 August 2006 09:31, Kevin Coffman wrote:
> They were added in 0.8:
> > Changes since librpcsecgss-0.7:
> >
> > -- From Olga Kornievskaia: add new prep_refresh function to clean up
> >    context information before trying to refresh a context
> > -- From Olga Kornievskaia: add new function to access retry count
> >    for a context.
> > -- Adds back clnt_ files which have the necessary calls needed for
> >    privacy.
>
> The libc versions of the clnt*_call functions do not call the
> AUTH_WRAP and AUTH_UNWRAP functions needed for privacy.

ok, so that answers the first question (should they be there) ...

next is, should they be hidden for internal use only ?  or all consumers of=
=20
librpcsecgss supposed to call the clnt_* funcs in there ?

the problem i'm trying to deal with is glibc may call the clnt funcs in som=
e=20
auth scenarios and the versions in librpcsecgss are used instead of the one=
s=20
in libc (like when libnsl enters the picture)

i'll prob have to go through this user's bug report and try to reproduce it=
=20
myself ... last time i tried to use nfs4 it just totally didnt work ;)
=2Dmike

--nextPart1226954.CXbJl3UD3k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)

iQIVAwUARM9mAEFjO5/oN/WBAQLBsw/9FPhtlBVDDB0BNaCa4aImzwntBefOCES+
Cc2JQV8XUdHZl6DexTso90S1t9cFKFVLJbf90lp30O4OkMUOS778uW7Jm7yNaHkd
csotjdddI7bYyKEmS6uGDwC0JLwNb6B5QduJBZNKQlx/IjJ+sgxr7JpewBP0zwZ0
kR9lm9sctT/q/myulSJQ4ciz77w1oN9rrSljSJsDTKcDLm2k9B91XuA5G0SBiq9t
xbnAqnlbWYZTf1RmRL3q7x39q1uQDrjXOWjXbYFuWWGuuOt8mVt5F7DRNUApqcYa
gi/2ZZIg+ZkJS0NZZUUgjauky1gDVjsn4i2/+2tMkHPAh94iKizvszgzwiQgN/la
0dU+fT3CexvksZbceANG3wh9RRimsL5U2PdjFqNjdgVzu/QdLHTlyKcn5M0G7u6z
bbluw3V7gV1g5qzvQ0Q4hX54n+Bd4j78sebLlZyXUFq4mtFUDwfEOiM+LkFa+kve
ipbaSdSsgnBjHZFWYu44Dr3Qx1CcOdoryTXTfLXmD8d5tsgAatjyr1NSWWLXfidv
YqSYuONrmtbQJPYJTtN/4714BrluooxHYSahQGQnjmXV9Oqkw5i4N7kLtHodbZf/
XNl8idS0rtlcIYzjCpxXpHfyVPQBYUDr/MSwEHOs6sodQobr7CGVVWcCYxHcbfVh
rpPbkxQb5fU=
=0A6d
-----END PGP SIGNATURE-----

--nextPart1226954.CXbJl3UD3k--


--===============0639068835==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0639068835==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0639068835==--
