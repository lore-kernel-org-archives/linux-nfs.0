From: Garrick Staples <garrick@usc.edu>
Subject: Re: NFS3 in RHEL3
Date: Fri, 14 Apr 2006 16:38:58 -0700
Message-ID: <20060414233858.GJ18673@polop.usc.edu>
References: <443F37FA.2060402@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HO6W8Bs67z/y6Z+3"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUXsS-0005eA-5T
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 16:39:00 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FUXsR-0005aZ-1z
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 16:39:00 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11.20060308/8.12.11) with ESMTP id k3ENcwAw010494
	for <nfs@lists.sourceforge.net>; Fri, 14 Apr 2006 16:38:58 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11.20060308/8.12.11/Submit) id k3ENcwvR010492
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 16:38:58 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <443F37FA.2060402@oracle.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--HO6W8Bs67z/y6Z+3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 14, 2006 at 11:19:46AM +0530, shashi alleged:
> Hi
>=20
> A small doubt about NFS3 in Linux . If i mount a NFS share (From NetApp
>  , ONTAP 6.5 ) on a Linux machine with only ro,nolock options , then
> still the NFS mount options like
> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are still applied ? If they
> are applied , how can i check is those are applied or not ?
>=20
> In my Linux box , after mounting with only ro,nolock options .....
>=20
> [root@<hostname>]# mount | grep < Mount point>
> <NFS server> on < Mount point >  type nfs (ro,nolock,addr=3D144.20.129.24=
8)
>=20
> In this case , is other other options like
> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are applied ? if they are
> applied , what are the default values ?

Look in /proc/mounts for the actual options applied to the mount.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--HO6W8Bs67z/y6Z+3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFEQDKS0SBUxJbm9HMRAu3WAJwPCuQuGd5dzeNBuvKQZJBTqO80sQCgnRLN
heTStw4z6CQu8QyyK+rl2cI=
=LHId
-----END PGP SIGNATURE-----

--HO6W8Bs67z/y6Z+3--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
