From: Marcel de Riedmatten <mdr@dotforge.ch>
Subject: Re: Function not implemented
Date: 10 Sep 2003 16:49:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063205379.15976.184.camel@galadriel>
References: <LOBBJFHFAIJCHENJILKBOEJDMAAA.robert@pawlowicz.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DBiwMHOx7ZQW0QeetbGO"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19x6I6-0007bd-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Sep 2003 07:49:54 -0700
Received: from [62.2.181.77] (helo=smtp.nofida.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19x6I5-000513-NM
	for nfs@lists.sourceforge.net; Wed, 10 Sep 2003 07:49:54 -0700
To: Robert Pawlowicz <robert@pawlowicz.com>
In-Reply-To: <LOBBJFHFAIJCHENJILKBOEJDMAAA.robert@pawlowicz.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-DBiwMHOx7ZQW0QeetbGO
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Le mer 10/09/2003 =E0 14:57, Robert Pawlowicz a =E9crit :
> Hello
> I have been pulling my hair out over this because I can't find a
> solution to the problem.
> =20
> I have a fresh install of debian linux and debian as you may already
> know includes NFS as part of its standard packages. This includes
> kernel NFS server support as well as the other usual packages that
> come with NFS.
> =20
> All the daemons start up fine except for nfsd which doesn't start &
> gives me the message:
> =20
> server.address.com:/var/www: Function not implemented
> =20
> When I try to mount the file on the client it just says that
> permission is denied.
> =20
> I have seen quite a bit about this function not implemented on the
> discussion forums but have found nothing that adequately answers my
> problem.

Hi=20

I would start to check some simple stuff:

modprobe nfs
lsmod
rpcinfo -p
exportfs -av

just to get an idea of what is wrong.


Cheers

--=20
Marcel de Riedmatten
pgp key: CFE703CA http://ftp.dotforge.ch/pub/users/mdr/mdr.gpg.asc
Empreinte: 4687 F9CB D8E2 AC1A B806  F812 C048 0875 CFE7 03CA

--=-DBiwMHOx7ZQW0QeetbGO
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA/XzoCwEgIdc/nA8oRAmqEAKCE3CT5S5wNnng19XXxcIh0vftzTgCfcvpA
0psLbk0c2TuMevaxxzjCdLo=
=PXCD
-----END PGP SIGNATURE-----

--=-DBiwMHOx7ZQW0QeetbGO--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
