From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: close() / nfs commit performance
Date: Mon, 30 Jun 2003 15:39:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X7JX-0000JA-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 15:39:59 -0700
To: "Edward Roper" <eroper@wanfear.com>
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

ed-

read the FAQ:  http://nfs.sourceforge.net/

close(2) on an NFS file means flush all outstanding
writes.  benchmarking without the close() means you're
measuring essentially client memory bandwidth.

the filer doesn't need v3 COMMITs because of its NVRAM
facility -- whether the client asks for UNSTABLE or
FILE_SYNC writes, it will always return a FILE_SYNC
result.  so writes to a filer are always fast, and
v3 writes to a filer are simpler than a pure disk-based
server.

> -----Original Message-----
> From: Edward Roper [mailto:eroper@wanfear.com]
> Sent: Monday, June 30, 2003 4:28 PM
> To: nfs@lists.sourceforge.net
> Cc: neilb@cse.unsw.edu.au
> Subject: [NFS] close() / nfs commit performance
>=20
>=20
> I have a system that I've been running some NFS benchmarks=20
> on. I've also
> been running the benchmarks on a Netapp F880. I have been using iozone
> as the testing tool. I am quite impressed with the linux=20
> system in every
> regard excepting it's close() / nfs commit performance (iozone -Rac).
> The following URL contains some graphs and spreadsheet data.
>=20
> http://www.wanfear.com/~eroper/nfs/
>=20
> Both the netapp and the linux system take a significant=20
> performance hit
> when close() is involved. However the Linux system drops to an almost
> unbelievably pathetic level.
>=20
> The graphs may also be of interest as they compare various=20
> block sizes,
> transport protos, sync/async options on the same linux server. I also
> have data for tcp,sync,32768 block sizes although it hasn't made it up
> there yet. All nfs data is v3.
>=20
> I'm hoping someone can tell me why there is such a huge write
> performance drop when close() is involved, and why it is such a more
> substantial drop than experienced with the netapp. I've also got data
> for two local iozone runs on the filesystem both with and without the
> close() option in iozone.
>=20
> Just in case anyone is interested in the specs (mordor =3D=3D=20
> linux server):
>=20
> 2.4.20-18.7-nfsserv (redhat(7.3) kernel with tcp-nfs built in)
> Pentium III 1.0ghz
> 1gb ram
> Intel(R) PRO/1000
> 3ware Storage Controller (Escalade 7500-8)(raid-5, 7 ata disks)
> The filesystem is ext3
>=20
> Thanks,
> Edward
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_06
1203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
