From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: readdir and readdirplus...
Date: Wed, 24 Sep 2003 18:24:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B384016486B1@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2CRz-0007LP-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 09:25:11 -0700
Received: from srv-grp-s02.axime.com ([160.92.18.104])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2CRy-0000Tq-Hj
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 09:25:10 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

here is one of my nfsstat :

Client nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
0       0% 771483726  1% 6109    0% 827366925  0% 1040368089  0% 4862868 =
 0%=20
read       write      create     mkdir      symlink    mknod     =20
-1853693236  1% 1340911105  0% 132162422  0% 260671  0% 8216    0% 0     =
  0%=20
remove     rmdir      rename     link       readdir    readdirplus
174498032  0% 1639    0% 210405486  1% 44505153  0% 5748    0% 155051  =
0%=20
fsstat     fsinfo     pathconf   commit    =20
34851   0% 3       0% 0       0% 0       0%=20

and the patch apply cleanly !
any way to verify ?

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Wednesday, September 24, 2003 6:01 PM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] readdir and readdirplus...
>=20
>=20
> >>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> =
writes:
>=20
>      > I am using a linux 2.4.20+NFS-ALL patches.  my server is a
>      > Netapp Filer
>=20
>      > I am using NFSv3
>=20
>      > what I did not understand is that it's seems that linux does
>      > not use READDIRPLUS ... is it normal ? in sources I have seen
>      > that certain condition should be met... but I never see any
>      > READDIRPLUS request !!!
>=20
> My machine currently shows the following statistics against a filer:
>=20
> Client nfs v3:
> null       getattr    setattr    lookup     access     readlink
> 0       0% 6405   36% 777     4% 1719    9% 3534   20% 119     0%
> read       write      create     mkdir      symlink    mknod
> 2340   13% 1645    9% 155     0% 4       0% 2       0% 0       0%
> remove     rmdir      rename     link       readdir    readdirplus
> 165     0% 3       0% 13      0% 37      0% 21      0% 631     3%
> fsstat     fsinfo     pathconf   commit
> 50      0% 5       0% 0       0% 0       0%
>=20
> So READDIRPLUS should normally be quite usable. Are you sure that=20
> the patches applied cleanly?
>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
