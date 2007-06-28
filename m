From: Malte =?UTF-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Subject: Re: Kernel NFS nfs_update_inode Oops in 2.6.20.11
Date: Thu, 28 Jun 2007 19:08:07 +0200
Message-ID: <20070628190807.14e9b9ab@highlander.home.lan>
References: <20070623153345.GA22117@ligo.caltech.edu>
	<1182615064.5859.2.camel@heimdal.trondhjem.org>
	<20070623215131.GC27551@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1764420871=="
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Stuart Anderson <anderson@ligo.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3xTc-00070m-7G
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 10:08:17 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1I3xTc-0000tO-Nt
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 10:08:19 -0700
In-Reply-To: <20070623215131.GC27551@ligo.caltech.edu>
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

--===============1764420871==
Content-Type: multipart/signed; boundary="Sig_rJd14RU/uXeu.c5bJ6RXx4i";
	protocol="application/pgp-signature"; micalg=PGP-SHA1

--Sig_rJd14RU/uXeu.c5bJ6RXx4i
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sat, 23 Jun 2007 14:51:31 -0700
Stuart Anderson <anderson@ligo.caltech.edu> wrote:

> Malte,
> 	I suggest you give this patch a try as well to see if it solves your
> similar/identical(?) Oops posted on lkml.

I did not encounter problems with this patch yet. I will report if this
changes.

--=20
---------------------------------------
Malte Schr=C3=B6der
MalteSch@gmx.de
ICQ# 68121508
---------------------------------------


--Sig_rJd14RU/uXeu.c5bJ6RXx4i
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGg+r44q3E2oMjYtURAg6LAKCpBwMqqaL8Uiaz0hpuCPiZqonMMgCggGzk
/uQayF8jMhQJa6nREqDCv9s=
=zQRA
-----END PGP SIGNATURE-----

--Sig_rJd14RU/uXeu.c5bJ6RXx4i--


--===============1764420871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1764420871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1764420871==--
