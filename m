From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: df hangs on down nfs server mounted with hard,intr, can't kill
Date: Tue, 9 Mar 2004 11:51:10 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0nP2-0000YJ-9Q
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 12:00:36 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B0nG4-0002S6-NH
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 11:51:20 -0800
To: "Wade Hampton" <wade.hampton@nsc1.net>, <nfs@lists.sourceforge.net>
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

hi wade-

the fact that "intr" doesn't work as expected is a bug, and
folks are attempting to address this at least partially in 2.6.

if you want a way to do a "df" without hanging your client,
try using a soft mount with a short-ish timeout for your
df requests.

caveat:  read the Linux NFS FAQ for more on using "soft" safely.

> -----Original Message-----
> From: Wade Hampton [mailto:wade.hampton@nsc1.net]=20
> Sent: Tuesday, March 09, 2004 2:33 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] df hangs on down nfs server mounted with=20
> hard,intr, can't kill
>=20
>=20
> [I posted this to the Fedora list yesterday.]
>=20
> I have a Fedora server with kernel 2.4.22-1-2163 SMP mounting=20
> a remote solaris server (hence choice of options):
>=20
>   rsize=3D32768,ro,hard,intr,tcp,nfsvers=3D3
>=20
> When the remote is down or disconnected, a "df" hangs (as=20
> expected), but I can't kill it, even as root or with kill -9.=20
>  The docs for mount=20
> indicate
> that the INTR option should allow for killing apps mounted=20
> with HARD. Is this a bug (glibc, 2.4 kernel, NFS, or Fedora's kernel)?
>=20
> I also coded a test program that calls statvfs(2) and it=20
> hangs on the statvfs(2) call when run against a down NFS=20
> server.  It too can't be interrupted or killed.
>=20
> My questions are:
>=20
> 1)  Is there a safe and reliable means to check for a down NFS server
>     (e.g., is showmount -e <server> safe enough?)
>=20
> 2)  Is the non-interruptable operation (even with INTR option)
>     a bug or feature?
>=20
> 3)  Is there a simple kernel call, /proc entry, or similar that can
>    be used to reliably check for free/used disk space and for a down
>    host, without hanging my application?
>  =20
>        A showmount -e followed by a statvfs() might work, but
>        there is the possibility of losing the host between the two
>        calls, resulting in an application hang.
>=20
> 4)  Is there a perl module to accomplish this?
>=20
> This would be very useful for network monitoring, e.g., when=20
> the server goes down and stays down for >1 minute, generate=20
> an SNMP trap and write to a log file.  It would be good if=20
> you can't put an SNMP agent on the server, but only on the=20
> client.  It is also useful for writing a highly reliable=20
> client application.
>=20
> As I have no control over the remote system, when it went=20
> down, I had to do a hard reboot of my Linux box to stop the=20
> hung apps.  This is a Windows solution, not a Linux solution....
> =20
> Note, I found this when writing some scripts for MRTG to=20
> check the disk utilization of partitions.  My df's hung so I=20
> didn't even get the proper values for my local partitions. =20
> After a few days, I had LOTS of hung MRTG apps and had to=20
> reboot (this test server is down for a week or two).
>=20
> Thanks
> --=20
> Wade Hampton
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President=20
> and CEO of GenToo technologies. Learn everything from=20
> fundamentals to system=20
> =
administration.http://ads.osdn.com/?ad_id=3D1470&alloc_id=3D3638&op=3Dcli=
ck
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
