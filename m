From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS Performance
Date: Thu, 18 Apr 2002 13:03:02 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CEA5@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yI7e-0001aV-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 13:03:14 -0700
To: "'Gavin Woodhatch'" <gavin.woodhatch@netzone.ch>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

what's your backup media?  your tape drive may be the
real bottleneck.

> -----Original Message-----
> From: Gavin Woodhatch [mailto:gavin.woodhatch@netzone.ch]
> Sent: Thursday, April 18, 2002 3:19 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS Performance
>=20
>=20
> Hi All
>=20
> I am new to the list, but have been reading the Archives.
>=20
> I need to Backup about 50 GB of Data. The Data is on a NFS Mounted
> Partition. A local Backup is not possible.
>=20
> The Data is mainly small files (HTML Pages, Pictures etc.) But there
> are also some bigger files.
>=20
> The Network thruput vary's from about 1-2 MB/s to 9 -10 MB/s. It is a
> 100 Mbit Network (Switched), the NFS Server is connected with a 1
> Gbit Link.
>=20
> I am Running a 2.4.17 Kernel with Trond's 2.4.17 NFS-all Patch.
>=20
>=20
> I have tried the following mount options :
>=20
> -o vers=3D3,async,hard,intr,nolock
>=20
> Varied with differnt wsize and rsize (from 4096 to 32768, and also =
not
> specified) , also tried with the option tcp.
>=20
> The Max thruput changes a bit depending on the options but the
> avg. does not change a great deal. (about 80 - 120 MB/min)
>=20
> The NFS Server is a Auspex NS2000.
>=20
> Anyone got an Idea how to get Linux to read the small files faster, =
or
> howto just generaly make things faster (Read) ?
>=20
> Any Ideas would be most welcome.
>=20
> PS Sorry for the bad spelling, my english is rather rusty...
>=20
>=20
> --
>=20
> Freundliche Gr=FCsse (Kind Regards)
>=20
>=20
> NetZone Ltd.
> Gavin Woodhatch
>=20
> ******************************************************************
> *  NetZone AG                                        Webhosting  *
> *  http://www.netzone.ch                        info@netzone.ch  *
> *  Alpenweg 12                            Tel. +41 62 724 08 08  *
> *  CH-5035 Unterentfelden                 Fax. +41 62 724 08 06  *
> ******************************************************************
>=20
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
