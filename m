From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 17:31:11 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B3840164890B@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HTL-0002Lf-Im
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:31:19 -0800
Received: from srv-grp-s01.axime.com ([160.92.18.102])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HTK-0006XB-D4
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:31:18 -0800
To: "Fabiano Reis" <silos.reis@ig.com.br>
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

for testing we have increase the limit from 256 to 1024 en recompile.

the probleme seems to be the same !

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Fabiano Reis
> Sent: Tuesday, March 16, 2004 2:37 PM
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] linus 2.4.20 nfs performance problem
>=20
>=20
> looks like you are getting the maximum number of nfs operations by
> mountpoint. See nfs.sourceforge.net
>=20
> The maximum nfs operations by mountpoint for kernel < 2.5.47 is 256
>=20
> I=B4m getting the same problem with kernel 2.4.20. I ipgraded a=20
> nfs client to
> kernel 2.6 and I still getting the same problem. Maybe a=20
> solution is to
> upgrade the server and client to kernel 2.6 (I didnt tested it yet)
>=20
> -
> Fabiano
>=20
> ----- Original Message -----=20
> From: "Brasseur Val=E9ry" <Valery.Brasseur@atosorigin.com>
> To: <Charles.Lever@netapp.com>
> Cc: <nfs@lists.sourceforge.net>
> Sent: Tuesday, March 16, 2004 8:35 AM
> Subject: [NFS] linus 2.4.20 nfs performance problem
>=20
>=20
> I have a config where LInux machines (bi Xeon 2.4Ghz 2Gb=20
> memory, kernel
> 2.4.20 + trond patch) are accessing a Netapp 810 (or 825)
>=20
> there is a lot of process (#400)
> when in load a lots of process are in D state, the filer are=20
> around 5000
> nfsops and the network is near 50 mbit/s for each machine
>=20
> the machine and the filer are connect by a switch, machines=20
> are at 100mb and
> filer is at 1Gb
>=20
> the cpu on the machines are near &=E0% and load average is near=20
> 100 or more
>=20
>=20
> I don't know where is the bottleneck...
>=20
> is somebody can help me ?
>=20
>=20
> thanks in advance
> valery
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> =
administration.http://ads.osdn.com/?ad_id=3D1470&alloc_id=3D3638&op=3Dcli=
ck
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
