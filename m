From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: nfs performance problem
Date: Tue, 5 Nov 2002 20:17:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021105201758.I23227@vestdata.no>
References: <005b01c284f5$ae1d6090$640a010a@winda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1899DH-0005kG-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 11:18:12 -0800
To: "poczta.dotcom.pl" <myciel@dotcom.pl>
In-Reply-To: <005b01c284f5$ae1d6090$640a010a@winda>; from myciel@dotcom.pl on Tue, Nov 05, 2002 at 07:03:43PM +0100
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

On Tue, Nov 05, 2002 at 07:03:43PM +0100, poczta.dotcom.pl wrote:
> Hi All
>=20
> I have really slow working nfs.
> Server is build on:
> - dual pentium Xeon 2GHz,
> - 2 3ware 7500 controllers,
> - raid 5 on 7 160GB discs on controler 1=20
> - raid 5 on 6 160GB disks on cotroller 2=20
>=20
> Serwer is used for ~500k maildirs,=20
> all clients (~20) are freebsd boxes, when nfs transfer is around 1MB/s =
for writing and 1.5MB/s for reading=20
> listing user directories even with very few file stakes up to 15 second=
s.
>=20
> I tried nfs-ALL patch, but it didn' t help.

How is local performance?
What filesystem do you use?
What's the output from "iostat -x -d -k 60 3"?



--=20
Ragnar Kj=F8rstad
Big Storage


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
